#!/usr/bin/env perl

use Modern::Perl '2015';
use Project::Libs;
use App::skos2unimarc;

App::skos2unimarc->new_with_options->run;
