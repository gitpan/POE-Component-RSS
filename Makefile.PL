use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'POE::Component::RSS',
    'VERSION_FROM'	=> 'VERSION', # finds $VERSION
    'PREREQ_PM'		=> { 'POE' => 0.11,
                       'XML::RSS' => 0.9,
		       'Test::More' => 0.08,
                     }, 
    'dist'              => { 'COMPRESS' => 'gzip -9f',
                             'SUFFIX' => 'gz'
                           },
    'AUTHOR'            => 'sungo (eek+cpan@eekeek.org)',
    'ABSTRACT'          => 'A module for event based RSS parsing',
);
