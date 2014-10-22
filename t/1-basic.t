#!/usr/bin/perl
# $File: //member/autrijus/Lingua-ZH-Toke/t/1-basic.t $ $Author: autrijus $
# $Revision: #2 $ $Change: 9669 $ $DateTime: 2004/01/11 13:11:05 $

use strict;
use Test;

BEGIN { plan tests => 20 }

require Lingua::ZH::Toke;
ok($Lingua::ZH::Toke::VERSION) if $Lingua::ZH::Toke::VERSION or 1;

# Create Lingua::ZH::Toke::Sentence object (->Sentence also works)
my $token = Lingua::ZH::Toke->new( '���H�o�b/�O������B/�q�o�N�����' );

my $tmp = $token;

# Easy tokenization via array deferencing
ok($tmp = $tmp->[0], '���H�o�b',    'Tokenization - Fragment');
ok($tmp = $tmp->[2], '�o�b',	    'Tokenization - Phrase');
ok($tmp = $tmp->[0], '�o',	    'Tokenization - Character');
ok($tmp = $tmp->[0], '��������',	    'Tokenization - Pronounciation');
ok($tmp = $tmp->[2], '��',	    'Tokenization - Phonetic');

# Magic histogram via hash deferencing
ok($token->{"���H�o�b"},    1,	    'Histogram - Fragment');
ok($token->{"�N�����"},    1,	    'Histogram - Phrase');
ok($token->{"�o�N����"},    undef,  'Histogram - No Phrase');
ok($token->{"��"},	    2,	    'Histogram - Character');
ok($token->{"����"},	    2,	    'Histogram - Pronounciation');
ok($token->{"��"},	    3,	    'Histogram - Phonetic');

my @phrases = qw(�� �H �o�b �O�� ��� �B �q�o �N�����);

# Iteration
while ($tmp = <$token>) {	# iterate each fragment
    while (<$tmp>) {		# iterate each phrase
	ok($_, shift(@phrases), 'Iteration');
    }
}

1;
