# $File: //member/autrijus/Lingua-ZH-Toke/Makefile.PL $ $Author: autrijus $
# $Revision: #2 $ $Change: 3668 $ $DateTime: 2003/01/19 19:59:30 $

use 5.006001;
use ExtUtils::MakeMaker;

if ($] < 5.007 and not eval { require Encode::compat; 1 }) {
    warn << '.';
If you wish to use unicode strings with Lingua::ZH::Toke,
please install Encode::compat from CPAN first.

Otherwise, only Big5 strings are available.
.
}

WriteMakefile(
    AUTHOR		=> 'Autrijus Tang (autrijus@autrijus.org)',
    ABSTRACT		=> 'Chinese Tokenizer on steroids',
    NAME		=> 'Lingua::ZH::Toke',
    VERSION_FROM	=> 'Toke.pm',
    PREREQ_PM		=> {
	'Lingua::ZH::TaBE' => '0',
    }
);
 
1;
