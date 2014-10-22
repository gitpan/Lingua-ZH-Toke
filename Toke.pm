# $File: //member/autrijus/Lingua-ZH-Toke/Toke.pm $ $Author: autrijus $
# $Revision: #2 $ $Change: 3666 $ $DateTime: 2003/01/19 19:47:11 $

package Lingua::ZH::Toke;
$Lingua::ZH::Toke::VERSION = '0.01';

use strict;
use Lingua::ZH::TaBE ();

=head1 NAME

Lingua::ZH::Toke - Chinese Tokenizer on steroids

=head1 SYNOPSIS

    use Lingua::ZH::Toke;	# add 'utf8' to use unicode strings

    # Create Lingua::ZH::Toke::Sentence object (->Sentence also works)
    my $token = Lingua::ZH::Toke->new( '���H�o�b/�O������B/�q�o�N�����' );

    # Easy tokenization via array deferencing
    print $token->[0]		# Fragment       - ���H�o�b
		->[2]		# Phrase         - �o�b
		->[0]		# Character      - �o
		->[0]		# Pronounciation - ��������
		->[2];		# Phonetic        - ��

    # Magic histogram via hash deferencing
    print $token->{'���H�o�b'};	# 1 - One such fragment there
    print $token->{'�N�����'};	# 1 - One such phrase there
    print $token->{'�o�N����'};	# undef - That's not a phrase
    print $token->{'��'};	# 2 - Two such character there
    print $token->{'����'};	# 2 - Two such pronounciation: �q�N
    print $token->{'��'};	# 3 - Three such phonetics: �����B

    # Iteration over fragments
    while (my $fragment = <$token>) {
	# Iteration over phrases
	while (my $phrase = <$token>) {
	    # ...
	}
    }

=head1 DESCRIPTION

This module puts a thin wrapper around L<Lingua::ZH::TaBE>, by blessing
refereces to B<TaBE>'s objects into its English counterparts.

Besides offering more readable class names, this module also offers
various overloaded methods for tokenization; please see L</SYNOPSIS> for
the three major ones.

Since L<Lingua::ZH::TaBE> is a Big5-oriented module, we also provide a
simple utf8 layer around it; if you have Perl version 5.6.1 or later,
just use this:

    use utf8;
    use Lingua::ZH::Toke 'utf8';

With the C<utf8> flag set, all B<Toke> objects will stringify to unicode
strings, and constructors will take either unicode strings, or
big5-encoded bytestrings.

Note that on Perl 5.6.x, L<Encode::compat> is needed for the C<utf8>
feature to work.

=head1 METHODS

The constructor methods correspond to the six object levels:
C<-&gt;Sentence>, C<-&gt;Fragment>, C<-&gt;Phrase>, C<-&gt;Character>,
C<-&gt;Pronounciation> and C<-&gt;Phonetic>.  Each of them takes one
string argument, representing the string to be tokenized.

The C<-&gt;new> method is an alias to C<-&gt;>Sentence>.

All object methods, except C<-&gt;new>, are passed to the underlying
B<Lingua::ZH::TaBE> object.

=head1 CAVEATS

This module does not care about efficiency or memory consumption yet,
hence it's likely to fail miserably if you demand either of them.
Patches welcome.

As the name suggests, the chosen interface is very bizzare.  Use it at
the risk of your own sanity.

=cut

use vars '$AUTOLOAD';

my @hier = qw(Chu Chunk Tsi Zhi Yin ZuYin);
my @name = qw(Sentence Fragment Phrase Character Pronounciation Phonetic);

my %next; @next{'', @hier} = (@hier, '');
my %tabe; @tabe{@hier, @name} = (@hier, @hier);
my %toke; @toke{@name, @hier} = (@name, @name);

for my $h (\%next, \%tabe, \%toke) {
    $h->{_tabe($_)} = $h->{_toke($_)} = $h->{$_} for grep $_, keys %$h;
}

{ no strict 'refs'; @{_toke($_) . '::ISA'} = __PACKAGE__ for @name }

my (%hist, %iter, $_b2u, $_u2b);

BEGIN { $_b2u = $_u2b = sub { ${$_[0]} } }

sub import {
    my $class    = shift;
    my $encoding = shift;
    if ($encoding eq 'utf8') {
	if ($] < 5.007) {
	    eval { require Encode::compat; 1 }
		or die "Pre-5.8 perls needs Encode::compat to use the 'utf8' feature";
	}

	require Encode;

	$_b2u = sub {
	    Encode::decode( big5 => ${$_[0]} )
	};
	$_u2b = sub {
	    Encode::is_utf8(${$_[0]})
	    	? Encode::encode( big5 => ${$_[0]} )
	    	: ${$_[0]};
	};
    }
}

use overload (
    '""'  => sub { $_b2u->(@_) },
    '0+'  => sub { scalar @{$_[0]} },
    '@{}' => sub {
	my $meth = ${$_[0]}->can(lc("$next{_tabe($_[0])}s")) or return [];
	[ map bless(\$_, _toke($_)), $meth->(${$_[0]}) ]
    },
    '%{}' => sub {
	$hist{overload::StrVal(${$_[0]})} ||= do {
	    my %o; $o{$_}++ for @{$_[0]};
	    my %h;
	    for my $c (@{$_[0]}) {
		$h{$_} += $c->{$_} for keys %$c;
	    }
	    +{ %o, %h };
	};
    },
    '<>'  => sub {
	$_[0]->[$iter{overload::StrVal($_[0])}++];
    },
    'fallback'	=> 1,
);

my $Tabe;

sub new {
    my $class  = shift;
    my $child  = $_[1] || $class;
    my $method = $tabe{ref($child) || $child} || $hier[0];
    my $obj    = ($Tabe ||= Lingua::ZH::TaBE->new)->$method($_u2b->(\$_[0]));
    my $self   = bless(\$obj, _toke($obj));
}

sub AUTOLOAD {
    no strict 'refs';
    $AUTOLOAD =~ s/.*:://;

    my $name = _toke($AUTOLOAD)
	or return ${$_[0]}->$AUTOLOAD(@_[1..$#_]);

    return $name->new(@_[1..$#_]);
}

sub CLONE { }
sub DESTROY { }

sub _tabe { 'Lingua::ZH::TaBE::' . ($tabe{ref($_[0]) || $_[0]} || die $_[0]) }
sub _toke { 'Lingua::ZH::Toke::' . ($toke{ref($_[0]) || $_[0]} || die $_[0]) }

1;

=head1 SEE ALSO

L<Lingua::ZH::TaBE>, L<Encode::compat>, L<Encode>

=head1 AUTHORS

Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>

=head1 COPYRIGHT

Copyright 2003 by Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
