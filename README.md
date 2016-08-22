# App-skos2unimarc

L'objectif de ce logiciel est de convertir un fichier SKOS en UNIMARC(A) en vue de son intégration dans un SIGB, et plus précisément dans PMB. 

Le projet a été développé dans le cadre de mon travail d'enseignant à l'IESSID pour soutenir le travail d'un étudiant : Alberto Rodriguez.

# Comment installer ce logiciel ?

Le programme n'ayant pas encore été publié sur le CPAN, il est nécessaire de passer par quelques étapes supplémentaires pour l'installer :

1. installer [Perl](http://www.perl.org) ;
1. installer App::cpanminus ; voici une [documentation utile](http://perlmaven.com/how-to-install-a-perl-module-from-cpan) pour apprendre à réaliser cette opération ;
1. installer Dist::Zilla ;
1. télécharger l'[archive contenant le logiciel)(https://github.com/edipretoro/App-skos2unimarc/archive/master.zip) ;
1. décompresser l'archive ;
1. ouvrir un terminal et se rendre dans le répertoire où se trouve le logiciel
1. taper la commande `dzil install`

# Comment utiliser ce logiciel ?

Voici la commande à saisir : `perl ./bin/skos2unimarc.pl -f fichier.skos -o fichier_unimarc.mrc`.

La durée de traitement est évidemment variable en fonction de la taille du thésaurus. 
