package App::skos2unimarc;

use strict;
use warnings;

use Moo;
use MooX::Options;

use DateTime;

use RDF::Trine;
use RDF::Trine::Store::DBI;
use RDF::Query;
use DBI;

use IO::All;
use YAML;

option 'files' => (
    is       => 'ro',
    short    => 'f',
    format   => 's@',
    required => 1,
    doc      => 'Files to convert to UNIMARC(A)',
  );

option 'output' => (
    is       => 'ro',
    short    => 'o',
    format   => 's',
    required => 0,
    doc      => 'Filename where to store the YAML version of the data.',
    default  => sub { 'skos2unimarc.yml' },
);

sub run {
  my ($self) = @_;

  # 1.
  my $dsn   = 'dbi:SQLite:dbname=skos2unimarc.db';
  my $dbh   = DBI->connect( $dsn, '', '' );
  my $store = RDF::Trine::Store::DBI->new( 'skos2unimarc', $dbh );
  my $model = RDF::Trine::Model->new($store);

  # 2.
  foreach my $file ( @{ $self->files } ) {
    my $parser = RDF::Trine::Parser->guess_parser_by_filename( $file );
    $parser->parse_file_into_model( "file://$file", $file, $model );
  }

  # 3.
  my $uri   = 'http://skos.um.es/unescothes/CS000';
  my $query = <<"SPARQL" . "\n}";
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX vann: <http://purl.org/vocab/vann/>
SELECT * WHERE {
?c skos:inScheme <$uri> .
OPTIONAL { ?c skos:prefLabel ?pLabel FILTER langMatches(lang(?pLabel), 'fr') } .
OPTIONAL { ?c skos:altLabel ?aLabel FILTER langMatches(lang(?aLabel), 'fr') } .
OPTIONAL { ?c skos:narrower ?narrower } .
OPTIONAL { ?c skos:broader ?broader } .
OPTIONAL { ?c skos:related ?related } .
OPTIONAL { ?c skos:scopeNote ?sNote FILTER langMatches(lang(?sNote), 'fr') } .
SPARQL

  my $concepts = {};
  my $q   = RDF::Query->new($query);
  my @res = $q->execute($model);
  foreach my $res (@res) {
    my $uri = $res->{c}->uri_value;
    $uri =~ /\/(C.*)$/;
    unless ( defined( $concepts->{$uri} ) ) {
      $concepts->{$uri} = { uri => $uri, id => $1, };
    }

    if (defined( $res->{pLabel} )) {
      my $label = $res->{pLabel}->as_hash();
      if ( $label->{language} eq 'fr' ) {
        $concepts->{$uri}{prefLabel} = $label->{literal};
      }
    }

    if (defined( $res->{aLabel} )) {
      my $label = $res->{aLabel}->as_hash();
      if ( $label->{language} eq 'fr' ) {
        $concepts->{$uri}{altLabel}{$label->{literal}}++;
      }
    }

    if (defined( $res->{narrower} )) {
      $concepts->{$uri}{narrower}{$res->{narrower}->uri_value}++;
    }

    if (defined( $res->{broader} )) {
      $concepts->{$uri}{broader}{$res->{broader}->uri_value}++;
    }

    if (defined( $res->{related} )) {
      $concepts->{$uri}{related}{$res->{related}->uri_value}++;
    }

    if (defined( $res->{sNote} )) {
      $concepts->{$uri}{scopeNote} = $res->{sNote}->literal_value;
    }
  }

  # 4.
  foreach my $concept (sort keys %$concepts) {
    my $marc_records = {};
    my $record = [];

    push @$record, ['LDR', '~', '~', '_', '00000nx  j2200000   45  '];

    push @$record, ['001', '~', '~', '_', $concepts->{$concept}{id}];

    push @$record, ['100', ' ', ' ', 'a', DateTime->now->ymd('') . 'afrey0103    ba0'];

    push @$record, ['250', ' ', ' ', 'a', $concepts->{$concept}{prefLabel}];

    if (defined( $concepts->{$concept}{scopeNote} )) {
      push @$record, ['330', '1', ' ', 'a', $concepts->{$concept}{scopeNote}];
    }

    if (defined( $concepts->{$concept}{altLabel} )) {
      foreach my $term (keys %{$concepts->{$concept}{altLabel}}) {
        push @$record, ['450', ' ', ' ', 'a', $term];
      }
    }

    if (defined( $concepts->{$concept}{related} )) {
      foreach my $term (keys %{$concepts->{$concept}{related}}) {
        push @$record, ['550', ' ', ' ', '3', $concepts->{$term}{id}, 'a', $concepts->{$term}{prefLabel}];
      }
    }

    if (defined( $concepts->{$concept}{broader} )) {
      foreach my $term (keys %{$concepts->{$concept}{broader}}) {
        push @$record, ['550', ' ', ' ', '5', 'g', '3', $concepts->{$term}{id}, 'a', $concepts->{$term}{prefLabel}];
      }
    }

    if (defined( $concepts->{$concept}{narrower} )) {
      foreach my $term (keys %{$concepts->{$concept}{narrower}}) {
        push @$record, ['550', ' ', ' ', '5', 'h', '3', $concepts->{$term}{id}, 'a', $concepts->{$term}{prefLabel}];
      }
    }

    $marc_records->{record} = $record;
    io( $self->output)->append( Dump( $marc_records ) );
  }
}

1;
