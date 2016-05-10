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

}

1;
