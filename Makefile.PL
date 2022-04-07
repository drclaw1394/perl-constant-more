use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'constant::more',
    VERSION_FROM      => 'lib/constant/more.pm', 
    PREREQ_PM         => {}, 
    ABSTRACT_FROM     => 'lib/constant/more.pod',
    AUTHOR            => 'Ruben Westerberg <drclaw@mac.com>',
    LICENSE           => 'perl',
);
