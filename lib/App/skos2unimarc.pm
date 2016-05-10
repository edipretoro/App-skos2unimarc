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

1;
