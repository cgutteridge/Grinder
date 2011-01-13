#!/usr/bin/perl

# License: GPL
# Copyright: University of Southampton 2011
# Author: Christopher Gutteridge; http://id.ecs.soton.ac.uk/person/1248


use strict;
use warnings;

use Getopt::Long;

my %options = ( 
	config=>[], 	set=>[], 	delineator=>[], 
	include=>[],
	noise=>1, 	in=>undef, 	out=>undef, 
	xslt=>undef, 	format=>undef,	worksheet=>undef, 
);

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
	'worksheet=i' => \$options{"worksheet"},

	'config=s' => $options{"config"},
	'include=s' => $options{"include"},
	'set=s' => $options{"set"},
	'delineator=s' => $options{"delineator"},
) || show_usage();

show_version() if $show_version;

show_help() if $show_help;

show_usage() if( scalar @ARGV != 0 ); 

$options{noise} = 0 if( $quiet );
$options{noise} = 1+$verbose if( $verbose );

my $grinder = new Grinder( %options );

$grinder->grind();

exit;

		  ############################################################

sub show_version
{
	print STDERR "Grinder: version XYZ\n";	
	exit;
}

sub show_usage
{
	print STDERR <<END;
Usage: $0 [OPTION]... [--in filename|url] [--out filename] [--xslt filename]
Usage: $0 [OPTION]... [--config filename] 

$0 --help for more information.
END
	exit 1;
}

sub show_help
{
	print STDERR <<END;
Usage: $0 [OPTION]... [--in filename] [--out filename] [--xslt filename]
Usage: $0 [OPTION]... [--config filename] 

 --config <filename>	Load options from a config file, although command
						 line options override.

 --in <filename|url>	File to load spreadsheet from. Default "-" (stdin),
						 or if it starts with http: or https: then it is 
						 treaded as a URL.

 --format <format>	  Format of spreadsheet.
						 csv (default) - Comma separated values
						 tsv - Tab separated values
						 psv - Pipe character separated values (eg. biztalk)
						 excel - Excel document (.xsl NOT .xslx)
						 colon - Colon-separated (eg. passwd)
 --worksheet <number>   For multi sheet files, which sheet (default 1)

 --out <filename>	   File to output result to. Default "-" (stdout)

 --xslt <filename>	  If specified, run the XML generated throught this 
						 XSLT transform and output that.

 --set <x>=<y>		  Set a variable in the intermediate stage XML, sets 
						 <set id='x'>y</set>. This overrides values set in
						 config file(s) but is overridden by values set 
						 using *SET in the input data.

 --delineator <x>=<y>   Set a character <y> to use to split data in cells 
						 in a column with heading <x>.
							   
 --include <filename>   Include the XML from <filename> at the top of the XML
						 output from the XSLT. Has no affect if xslt is not
						 set. Also assumes that the XSLT will add a 
						 <!--TOP--> to the XML it produces that can be used 
						 as the hook to insert the <filename> data.

 --verbose			  Include more debug information. May be repeated for 
						 even more information.

 --quiet				Supress even normal warnings (but not errors).

 --help				 Show this help and exit.

 --version			  Show the Grinder version and exit.

END
	exit;
}


		  ############################################################
		  ############################################################
		  ############################################################


package Grinder;

use strict;
use warnings;

# set = {} or [] or $
# delineator = {} or [] or $
# include = [] or $

# in (default -)
# out (default -)
# xslt
# format (default csv)
# worksheet (default 1), excel format only
# config = [] or $
# noise (default 1)

sub new
{
	my( $class, %options ) = @_;

	my $self = bless { 
		set => {}, 
		delineator => {},
		include => [],
	}, $class;

	# normal options
	foreach my $opt_key ( keys %options )
	{
		next if( $opt_key eq "set" || $opt_key eq "delineator" );
		if( $opt_key eq "include" ) 
		{
			if( ref( $options{$opt_key} ) eq "" ) 
			{
				push @{$self->{$opt_key}}, $options{$opt_key};
			}
			else
			{
				push @{$self->{$opt_key}}, @{$options{$opt_key}};
			}
			next;
		}
		$self->{$opt_key} = $options{$opt_key};
	}

	if( $options{config} )
	{
		foreach my $config_file ( @{$options{config}} )
		{
			my $config_fh = $self->open_input_file( $config_file );
			my $line_no = 0;
			while( my $line = readline( $config_fh ) )
			{
				$line_no++;	
				chomp $line;
				next if( $line =~ m/^\s*$/ );
				next if( $line =~ m/^\s*#/ );
				if( $line =~ m/^\s*([^:]+):\s*(.*)$/ )
				{
					my( $left, $right ) = ( $1, $2 );
					$right=~s/\s*$//;
					if( $left eq "set" || $left eq "delineator" )
					{
						my( $id, $value ) = split( /=/, $right );
						$self->{$left}->{$id} = $value;
					}
					elsif( $left eq "include" )
					{
						push @{$self->{include}}, $right;
					}
					elsif( !defined $options{$left} )
					{
						# second definition in a config over-writes
						# but does not over-write passed-in option
						$self->{$left} = $right;
					}
					next;
				}
						
				$self->message( "Syntax error in config file '$config_file' at line #$line_no.", 1 );
				$self->message( "Line #$line_no: $line", 2 );
			}

			close( $config_fh );
		}
	}

	#  passed-in options overrides config for hash type fields
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

	}

	$self->{format} = "csv" unless defined $self->{format};
	$self->{noise} = 1 unless defined $self->{noise};
	$self->{in} = "-" unless defined $self->{in};
	$self->{out} = "-" unless defined $self->{out};
	$self->{tmp_dir} = "/tmp" unless defined $self->{tmp_dir};
	$self->{xslt_proc} = '/usr/bin/xsltproc @@XSL@@ @@XML@@' unless defined $self->{xslt_proc};

	return $self;
}

sub open_input_file
{
	my( $self, $filename ) = @_;

	my $fh;

	if( $filename eq "-" )
	{
		$fh = *STDIN;
		binmode( $fh, ":utf8" );
	}
	else
	{
		open( $fh, "<:utf8", $filename ) || $self->error( "Failed to open '$filename' for reading: $!" );
	}
	$self->message( "Opened '$filename' for reading.", 2 );

	return $fh;
}

sub open_output_file
{
	my( $self, $filename ) = @_;

	my $fh;

	if( $filename eq "-" )
	{
		$fh = *STDOUT;
		binmode( $fh, ":utf8" );
	}
	else
	{
		open( $fh, ">:utf8", $filename ) || $self->error( "Failed to open '$filename' for writing: $!" );
	}
	$self->message( "Opened '$filename' for writing.", 2 );

	return $fh;
}

sub close_file
{
	my( $self, $file_handle, $filename ) = @_;

	if( !close( $file_handle ) ) 
	{
		$self->message( "Could not close a file handle on $filename: $!", 1 );
	}
	$self->message( "Closed '$filename'.", 2 );
}

sub unlink_file
{
	my( $self, $filename ) = @_;

	if( !unlink( $filename ) ) 
	{
		$self->message( "Could not unlink $filename: $!", 1 );
	}
	$self->message( "Unlinked '$filename'.", 2 );
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

sub message
{
	my( $self, $msg, $priority ) = @_;

	if( $priority <= $self->{noise} )
	{
		print STDERR "$msg\n";
	}
}

sub grind
{
	my( $self ) = @_;

	# could take extra options to over-ride current ones, esp in & out

	my $in_fh;
	my $in_file = $self->{in};
	if( $self->{in} =~ m/^https?:/ )
	{
		$in_file = $self->{tmp_dir}."/grinder.in$$.xml";
		if( ! eval 'use LWP::UserAgent; 1;' ) 
		{
			$self->error( "Failed to load Perl Module: LWP::UserAgent" );
		}	
		my $ua = LWP::UserAgent->new;

		my $req = HTTP::Request->new( GET => $self->{in} );
		my $res = $ua->request( $req );
		if( !$res )
		{
			$self->error( "Failed to load URL '".$self->{in}."': ".$res->status_line );
		}	
		my $in_file_out_fh = $self->open_output_file( $in_file ); # shake it all about
		print { $in_file_out_fh } $res->content;
		$self->close_file( $in_file_out_fh, $in_file );
	}
	$in_fh = $self->open_input_file( $in_file );

	my $xml_file;
	if( defined $self->{xslt} && $self->{xslt} ne "" )
	{
		$xml_file = $self->{tmp_dir}."/grinder.$$.xml";
	}
	else
	{
		$xml_file = $self->{out};
	}

	my $xml_out_fh = $self->open_output_file( $xml_file );

	$self->{parse} = { rows=>0, set=>{} };	
	foreach my $k ( keys %{ $self->{set} } ) { $self->{parse}->{set}->{$k} = $self->{set}->{$k}; }

	if( $self->{format} eq "excel" ) { $self->process_excel( $in_fh, $xml_out_fh ); }
	elsif( $self->{format} eq "csv" ) { $self->process_csv( $in_fh, $xml_out_fh ); }
	elsif( $self->{format} eq "tsv" ) { $self->process_tsv( $in_fh, $xml_out_fh ); }
	elsif( $self->{format} eq "colon" ) { $self->process_colon( $in_fh, $xml_out_fh ); }
	elsif( $self->{format} eq "psv" ) { $self->process_psv( $in_fh, $xml_out_fh ); }
	else { $self->error( "Unknown format '".$self->{format}."'" ); }

	# Output end of XML file
	for my $set_id ( keys %{$self->{set}} )
	{
		my $value = $self->{set}->{$set_id};
		$value =~ s/&/&amp;/g;
		$value =~ s/>/&gt;/g;
		$value =~ s/</&lt;/g;
		$value =~ s/"/&quot;/g;
		print { $xml_out_fh } "  <set id='$set_id'>$value</set>\n";
	}

	print { $xml_out_fh } <<END;
</grinder-data>
END
	$self->close_file( $xml_out_fh, $xml_file );
	$self->close_file( $in_fh, $self->{in} );

	# delete tmp file if input was from a URL
	if( $self->{in} =~ m/^https?:/ )
	{
		$self->unlink_file( $in_file );
	}


	# If no XSLT then we are done
	if( !defined $self->{xslt} || $self->{xslt} eq "" )
	{
		exit;
	}


	# Read include files
	my @lines = ();
	foreach my $inc_file ( @{$self->{include}} )
	{
		my $inc_fh = $self->open_input_file( $inc_file );
		while( my $line = readline( $inc_fh ) ) { push @lines, $line; }
		$self->close_file( $inc_fh, $inc_file );
	}
	my $include = join( '', @lines );


	# Process XSLT
	
	my $cmd = $self->{xslt_proc};
	$cmd =~ s/\@\@XML\@\@/$xml_file/g;
	$cmd =~ s/\@\@XSL\@\@/$self->{xslt}/g;

	my $xsltproc;
	open( $xsltproc, "-|:utf8", $cmd ) || $self->error( "Failed to exec '$cmd': $!" );
	$self->message( "Executed '$cmd' for writing.", 2 );

	my $out_fh = $self->open_output_file( $self->{out} );
	
	while( my $line = readline( $xsltproc ) )
	{
		$line =~ s/<!--TOP-->/$include/g;
		print { $out_fh } $line;
	}	

	$self->close_file( $out_fh, $self->{out} );	
	$self->close_file( $xsltproc, $cmd );	

	$self->unlink_file( $xml_file );	
}

sub process_row
{
	my( $self, $out, $cells ) = @_;

	# Skip empty rows
	my $empty = 1;
	foreach my $cell ( @{$cells} )
	{
		if( defined $cell && $cell ne "" ) { $empty = 0; last; }
	}
	return if( $empty );

	# *STAR directive fields
	if( substr( $cells->[0],0,1 ) eq "*" )
	{
		if( $cells->[0] eq "*SET" )
		{
			$self->{parse}->{set}->{$cells->[1]} = $cells->[2];
		}
		else
		{
			$self->message( "Unknown * directive: ".$cells->[0] );
		}
		return;
	}

	# Read headings
	if( !defined $self->{parse}->{fields} )
	{
		my $fields = {};
		foreach my $cell ( @{$cells} )
		{
			if( !defined $cell ) 
			{
				push @{$self->{parse}->{fields}}, undef;
				next;
			}
			$cell =~ s/^\s+//;
			$cell =~ s/\s+$//;
			$cell = lc $cell;
			if( $cell eq "" )
			{
				push @{$self->{parse}->{fields}}, undef;
				next;
			}
			if( defined $fields->{$cell} )
			{
				$self->message( "Duplicate column heading '$cell'", 1 );
				next;
			}
			$cell =~ s/\s/-/g;
			push @{$self->{parse}->{fields}}, $cell;
			$fields->{$cell} = 1;
		}

		# Output Header
		print { $out } <<END;
<?xml version="1.0" encoding='utf-8'?>
<grinder-data xmlns="http://purl.org/openorg/grinder/ns/">
END

		return;
	}

	print { $out } "  <row>\n";
	for my $i ( 0..(scalar @{$self->{parse}->{fields}} - 1 ) )
	{
		my $field = $self->{parse}->{fields}->[$i];
		next if !defined $field;
	
		my $value = $cells->[$i];
		next if !defined $value;

		$value =~ s/^\s+//;
		$value =~ s/\s+$//;

		my @values;
		if( $self->{delineator}->{$field} )
		{
			my $del = $self->{delineator}->{$field};
			@values = split( /\s*$del\s*/, $value );
		}
		else
		{
			@values = ( $value );
		}

		foreach my $value ( @values )
		{
			$value =~ s/&/&amp;/g;
			$value =~ s/>/&gt;/g;
			$value =~ s/</&lt;/g;
			$value =~ s/"/&quot;/g;
			print { $out } "	<$field>$value</$field>\n";
		}
		$self->{parse}->{rows}++;
	}
	print { $out } "  </row>\n";
	
}

sub process_excel
{
	my( $self, $in, $out ) = @_;

	if( ! eval 'use Spreadsheet::ParseExcel; 1;' ) 
	{
		$self->error( "Failed to load Perl Module: Spreadsheet::ParseExcel" );
	}	

	my $parser = Spreadsheet::ParseExcel->new();
	my $workbook = $parser->parse( $in );
	if ( !defined $workbook ) 
	{
		$self->error( "Failed to parse Excel file: ".$parser->error() );
	}

	my $n = $self->{worksheet} || 1;
	my @worksheets = $workbook->worksheets();
	if( !defined $worksheets[$n-1] )
	{
		$self->error( "Workbook does not have a worksheet #$n" );
	}
	my $worksheet = $worksheets[$n-1];

	my ( $row_min, $row_max ) = $worksheet->row_range();
	my ( $col_min, $col_max ) = $worksheet->col_range();

	for my $row ( $row_min .. $row_max ) 
	{
		my @cells = ();
		for my $col ( 0 .. $col_max ) 
		{
			my $cell = $worksheet->get_cell( $row, $col );
			my $v;
			if( $cell ) { $v = $cell->value(); };
			push @cells, $v;
		}
		$self->process_row( $out, \@cells );
	}
}

sub process_psv
{
	my( $self, $in, $out ) = @_;

	while( my $line = readline( $in ) )
	{
		chomp $line;

		$self->process_row( $out, [ split /\|/, $line ] );
	}
}

sub process_colon
{
	my( $self, $in, $out ) = @_;

	while( my $line = readline( $in ) )
	{
		chomp $line;

		$self->process_row( $out, [ split /:/, $line ] );
	}
}

sub process_csv
{
	my( $self, $in, $out ) = @_;

	if( ! eval 'use Text::CSV; 1;' ) 
	{
		$self->error( "Failed to load Perl Module: Text::CSV" );
	}	

	my $csv = Text::CSV->new();

	while( my $line = readline( $in ) )
	{
		if( !$csv->parse($line) ) 
		{
			my $err = $csv->error_input;
			$self->message( "Failed to parse line: $err", 1 );
			next;
		}
		
		$self->process_row( $out, [ $csv->fields() ] );
	}
}

1;
