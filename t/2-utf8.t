#!/usr/bin/perl
# $File: //member/autrijus/Lingua-ZH-Toke/t/2-utf8.t $ $Author: autrijus $
# $Revision: #1 $ $Change: 3664 $ $DateTime: 2003/01/19 19:46:40 $

use strict;
use Test;

BEGIN {
    eval { require Encode::compat } if $] < 5.007;
    eval { require Encode } or do {
	plan tests => 0;
	exit;
    };
    plan tests => 20;
}

use utf8;
require Lingua::ZH::Toke;
ok($Lingua::ZH::Toke::VERSION) if $Lingua::ZH::Toke::VERSION or 1;
Lingua::ZH::Toke->import('utf8');

# Create Lingua::ZH::Toke::Sentence object (->Sentence also works)
my $token = Lingua::ZH::Toke->new( '那人卻在/燈火闌珊處/益發意興闌珊' );

my $tmp = $token;


# Easy tokenization via array deferencing
ok($tmp = $tmp->[0], '那人卻在',    'Tokenization - Fragment');
ok($tmp = $tmp->[2], '卻在',	    'Tokenization - Phrase');
ok($tmp = $tmp->[0], '卻',	    'Tokenization - Character');
ok($tmp = $tmp->[0], 'ㄑㄩㄝˋ',	    'Tokenization - Pronounciation');
ok($tmp = $tmp->[2], 'ㄝ',	    'Tokenization - Phonetic');

# Magic histogram via hash deferencing
ok($token->{'那人卻在'},    1,	    'Histogram - Fragment');
ok($token->{'意興闌珊'},    1,	    'Histogram - Phrase');
ok($token->{'發意興闌'},    undef,  'Histogram - No Phrase');
ok($token->{'珊'},	    2,	    'Histogram - Character');
ok($token->{'ㄧˋ'},	    2,	    'Histogram - Pronounciation');
ok($token->{'ㄨ'},	    3,	    'Histogram - Phonetic');

my @phrases = qw(那 人 卻在 燈火 闌珊 處 益發 意興闌珊);

# Iteration
while ($tmp = <$token>) {	# iterate each fragment
    while (<$tmp>) {		# iterate each phrase
	ok($_, shift(@phrases), 'Iteration');
    }
}

1;
