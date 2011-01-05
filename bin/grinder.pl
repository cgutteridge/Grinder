#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

# options

# --config
# --in
# --format
# --out
# --xslt

# --set x=y
# --delineator x=y

# --verbose
# --quiet

# --help
# --version

my %options = ( config=>[], set=>[], delineator=>[], noise=>1, in=>"-", out=>"-", xslt=>"", format=>"csv" );

Getopt::Long::Configure("permute");

my $show_help;
my $show_version;
my $verbose;
my $quiet;
GetOptions( 
	'help|?' => \$show_help,
	'version' => \$show_version,

	'verbose+' => \$verbose,
	'quiet' => \$quiet,

	'in=s' => \$options{"in"},
	'out=s' => \$options{"out"},
	'xslt=s' => \$options{"xslt"},
	'format=s' => \$options{"format"},

	'config=s' => $options{"config"},
	'set=s' => $options{"set"},
	'delineator=s' => $options{"delineator"},
) || show_usage();
show_version() if $show_version;
show_usage( 1 ) if $show_help;
show_usage() if( scalar @ARGV != 0 ); 

$options{noise} = 0 if( $quiet );
$options{noise} = 1+$verbose if( $verbose );

# TODO: Print usage
# TODO: Print version
use Data::Dumper;
print Dumper( \%options );

my $grinder = new Grinder( %options );
$grinder->debug();

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

# set = {} or [] or $
# delineator = {} or [] or $

# in (default -)
# out (default -)
# xslt
# format (default csv)
# config = [] or $
# noise (default 1)

sub new
{
	my( $class, %options ) = @_;
print Dumper( \%options );
	my $self = bless { 
		set=>{}, 
		delineator=>{},
		format=>"csv",
		noise=>1,
		in=>"-",
		out=>"-",
	}, $class;

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
		if( $opt_key eq "set" || $opt_key eq "delineator" )
		{
			$v = [ $v ] if( ref( $v ) eq "" );	
			if( ref( $v ) eq "ARRAY" )
			{
				foreach my $touple ( @{$v} )
				{
					my( $id, $value ) = split( /=/, $touple );
					$self->{$opt_key}->{$id} = $value;
				}
			}
			else
			{
				foreach my $id ( keys %{$v} )
				{
					$self->{$opt_key}->{$id} = $v->{$id};
				}
			}
			next;
		}

		$self->{$opt_key} = $v;
	}

	return $self;
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


