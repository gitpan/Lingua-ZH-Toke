#!/usr/bin/perl
# $File: //member/autrijus/Lingua-ZH-Toke/t/3-encoding.t $ $Author: autrijus $
# $Revision: #1 $ $Change: 3664 $ $DateTime: 2003/01/19 19:46:40 $

use strict;
use Test;

BEGIN {
    eval { require encoding } or do {
	plan tests => 0;
	exit;
    };
    plan tests => 20;
}

use encoding 'big5';
require Lingua::ZH::Toke;
ok($Lingua::ZH::Toke::VERSION) if $Lingua::ZH::Toke::VERSION or 1;
Lingua::ZH::Toke->import('utf8');

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
ok($token->{'���H�o�b'},    1,	    'Histogram - Fragment');
ok($token->{'�N�����'},    1,	    'Histogram - Phrase');
ok($token->{'�o�N����'},    undef,  'Histogram - No Phrase');
ok($token->{'��'},	    2,	    'Histogram - Character');
ok($token->{'����'},	    2,	    'Histogram - Pronounciation');
ok($token->{'��'},	    3,	    'Histogram - Phonetic');

my @phrases = qw(�� �H �o�b �O�� ��� �B �q�o �N�����);

# Iteration
while ($tmp = <$token>) {	# iterate each fragment
    while (<$tmp>) {		# iterate each phrase
	ok($_, shift(@phrases), 'Iteration');
    }
}

1;