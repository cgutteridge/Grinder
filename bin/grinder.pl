#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

# options

# --verbose
# --quiet
# --config
# --in
# --format
# --out
# --xslt
# --set x=y
# --delineator x=y

my %options = ();



# TODO: read command line options

#  TODO:open source document
#  TODO:open target for XML (tmp or in)

#  TODO:convert to XML 

#  TODO:end or

#  TODO:open tmp document
#  TODO:open target for RDF
#  TODO:spawn xslt bin

#  TODO:insert boilerplate and stream to out

#########################

package Grinder;

use strict;
use warnings;

sub new
{
	my( $class, %options ) = @_;

	my $self = bless {}, $class;

	if( $options{config} )
	{
		foreach my $config_fn ( @{$options{config}} )
		{
			#  TODO:read config file into $self
		}
	}

	#  passed-in options overrides config, or appends to
	foreach my $opt_key ( keys %options )
	{
		my $v = $options{$opt_key};
		if( ref( $v ) eq "ARRAY" )
		{
			$self->{$opt_key} = [] if( ! defined $self->{$opt_key} );
			push @{ $self->{$opt_key} }, @{$v};
		}
		else
		{
			$self->{$opt_key} = $v;
		}
	}
}

sub debug
{
	my( $self ) = @_;

	use Data::Dumper;
	print STDERR Dumper( $self );
}

sub error
{
	my( $self, $msg ) = @_;

	print STDERR "Grinder Error: $msg\n";
	exit 1;
}


