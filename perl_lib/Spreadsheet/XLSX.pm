package Spreadsheet::XLSX;

use 5.006000;
use strict;
use warnings;

our @ISA = qw();

our $VERSION = '0.13';

use Archive::Zip;
use Spreadsheet::XLSX::Fmt2007;
use Data::Dumper;
use Spreadsheet::ParseExcel;

################################################################################

sub new {

	my ($class, $filename, $converter) = @_;
	
	my $self = {};
	
	$self -> {zip} = Archive::Zip -> new ();

	if (ref $filename) {
	
		$self -> {zip} -> readFromFileHandle ($filename) == Archive::Zip::AZ_OK or die ("Cannot open data as Zip archive");
	
	} 
	else {
	
		$self -> {zip} -> read ($filename) == Archive::Zip::AZ_OK or die ("Cannot open $filename as Zip archive");
	
	};

	my $member_shared_strings = $self -> {zip} -> memberNamed ('xl/sharedStrings.xml');
	
	my @shared_strings = ();

	if ($member_shared_strings) {
	
		my $mstr = $member_shared_strings->contents; 
		$mstr =~ s/<t\/>/<t><\/t>/gsm;  # this handles an empty t tag in the xml <t/>
		foreach my $si ($mstr =~ /<si.*?>(.*?)<\/si/gsm) {
			my $str;
			foreach my $t ($si =~ /<t.*?>(.*?)<\/t/gsm) {
				$t = $converter -> convert ($t) if $converter;
				$str .= $t;
			}
			push @shared_strings, $str;
		}	
	}
        my $member_styles = $self -> {zip} -> memberNamed ('xl/styles.xml');

        my @styles = ();

	my %style_info = ();

        if ($member_styles) {

                foreach my $t ($member_styles -> contents =~ /xf\ numFmtId="([^"]*)"(?!.*\/cellStyleXfs)/gsm) { #"
                       # $t = $converter -> convert ($t) if $converter;
                        push @styles, $t;

                }
		my $default = $1 || '';

		foreach my $t1 (@styles){
			$member_styles -> contents =~ /numFmtId="$t1" formatCode="([^"]*)/;
			my $formatCode = $1 || '';
			if ($formatCode eq $default || not($formatCode)){
				if ($t1 == 9 || $t1==10){ $formatCode="0.00000%";}
				elsif ($t1 == 14){ $formatCode="m-d-yy";}
				else {
					$formatCode="";
				}
			}
			$style_info{$t1} = $formatCode;
			$default = $1 || '';
		}

        }

	my $member_rels = $self -> {zip} -> memberNamed ('xl/_rels/workbook.xml.rels') or die ("xl/_rels/workbook.xml.rels not found in this zip\n");
	
	my %rels = ();

	foreach ($member_rels -> contents =~ /\<Relationship (.*?)\/?\>/g) {
	
		/^Id="(.*?)".*?Target="(.*?)"/ or next;
		
		$rels {$1} = $2;
	
	}

	my $member_workbook = $self -> {zip} -> memberNamed ('xl/workbook.xml') or die ("xl/workbook.xml not found in this zip\n");
	my $oBook = Spreadsheet::ParseExcel::Workbook->new;
	$oBook->{SheetCount} = 0;
	$oBook->{FmtClass} = Spreadsheet::XLSX::Fmt2007->new;
	$oBook->{Flg1904}=0;
	if ($member_workbook->contents =~ /date1904="1"/){
		$oBook->{Flg1904}=1;
	}
	my @Worksheet = ();
	
	foreach ($member_workbook -> contents =~ /\<(.*?)\/?\>/g) {
	
		/^(\w+)\s+/;
		
		my ($tag, $other) = ($1, $');

		my @pairs = split /\" /, $other;

		$tag eq 'sheet' or next;
		
		my $sheet = {
			MaxRow => 0,
			MaxCol => 0,
			MinRow => 1000000,
			MinCol => 1000000,
		};
		
		foreach ($other =~ /(\S+=".*?")/gsm) {

			my ($k, $v) = split /=?"/; #"
	
			if ($k eq 'name') {
				$sheet -> {Name} = $v;
				$sheet -> {Name} = $converter -> convert ($sheet -> {Name}) if $converter;
			}
			elsif ($k eq 'r:id')	{
			
				$sheet -> {path} = $rels {$v};
				
			};
					
		}
		my $wsheet = Spreadsheet::ParseExcel::Worksheet->new(%$sheet);
		push @Worksheet, $wsheet;
		$oBook->{Worksheet}[$oBook->{SheetCount}] = $wsheet;
		$oBook->{SheetCount}+=1;
				
	}

	$self -> {Worksheet} = \@Worksheet;
	
	foreach my $sheet (@Worksheet) {
		
		my $member_sheet = $self -> {zip} -> memberNamed ("xl/$sheet->{path}") or next;
	
		my ($row, $col);
		
		my $flag = 0;
		my $s    = 0;
		my $s2   = 0;
		my $sty  = 0;
		foreach ($member_sheet -> contents =~ /(\<.*?\/?\>|.*?(?=\<))/g) {
			if (/^\<c r=\"([A-Z])([A-Z]?)(\d+)\"/) {
				
				$col = ord ($1) - 65;
				
				if ($2) {
                			$col++;
					$col *= 26;
					$col += (ord ($2) - 65);
				}
				
				$row = $3 - 1;
				
				$s   = m/t=\"s\"/      ?  1 : 0;
				$s2  = m/t=\"str\"/    ?  1 : 0;
				$sty = m/s="([0-9]+)"/ ? $1 : 0;

			}
			elsif (/^<v/) {
				$flag = 1;
			}
			elsif (/^<\/v/) {
				$flag = 0;
			}
			elsif (length ($_) && $flag) {
				my $v = $s ? $shared_strings [$_] : $_;
				if ($v eq "</c>"){$v="";}
				my $type = "Text";
				my $thisstyle = "";
				if (not($s) && not($s2)){
					$type="Numeric";
					$thisstyle = $style_info{$styles[$sty]};
					if ($thisstyle =~ /(?<!Re)d|m|y/){
						$type="Date";
					}
				}	
				$sheet -> {MaxRow} = $row if $sheet -> {MaxRow} < $row;
				$sheet -> {MaxCol} = $col if $sheet -> {MaxCol} < $col;
				$sheet -> {MinRow} = $row if $sheet -> {MinRow} > $row;
				$sheet -> {MinCol} = $col if $sheet -> {MinCol} > $col;
				if ($v =~ /(.*)E\-(.*)/gsm && $type eq "Numeric"){
					$v=$1/(10**$2);  # this handles scientific notation for very small numbers
				}
				my $cell =Spreadsheet::ParseExcel::Cell->new(

					Val    => $v,
					Format => $thisstyle,
					Type => $type
					
				);

				$cell->{_Value} = $oBook->{FmtClass}->ValFmt($cell, $oBook);
				if ($type eq "Date" && $v<1){  #then this is Excel time field
					$cell->{Type}="Text";
					$cell->{Val}=$cell->{_Value};
				}
				$sheet -> {Cells} [$row] [$col] = $cell;
			}
					
		}
		
		$sheet -> {MinRow} = 0 if $sheet -> {MinRow} > $sheet -> {MaxRow};
		$sheet -> {MinCol} = 0 if $sheet -> {MinCol} > $sheet -> {MaxCol};

	}
foreach my $stys (keys %style_info){
}
	bless ($self, $class);

	return $oBook;

}

1;
__END__

=head1 NAME

Spreadsheet::XLSX - Perl extension for reading MS Excel 2007 files;

=head1 SYNOPSIS

 use Text::Iconv;
 my $converter = Text::Iconv -> new ("utf-8", "windows-1251");
 
 # Text::Iconv is not really required.
 # This can be any object with the convert method. Or nothing.

 use Spreadsheet::XLSX;
 
 my $excel = Spreadsheet::XLSX -> new ('test.xlsx', $converter);
 
 foreach my $sheet (@{$excel -> {Worksheet}}) {
 
 	printf("Sheet: %s\n", $sheet->{Name});
 	
 	$sheet -> {MaxRow} ||= $sheet -> {MinRow};
 	
         foreach my $row ($sheet -> {MinRow} .. $sheet -> {MaxRow}) {
         
 		$sheet -> {MaxCol} ||= $sheet -> {MinCol};
 		
 		foreach my $col ($sheet -> {MinCol} ..  $sheet -> {MaxCol}) {
 		
 			my $cell = $sheet -> {Cells} [$row] [$col];
 
 			if ($cell) {
 			    printf("( %s , %s ) => %s\n", $row, $col, $cell -> {Val});
 			}
 
 		}
 
 	}
 
 }

=head1 DESCRIPTION

This module is a (quick and dirty) emulation of Spreadsheet::ParseExcel for 
Excel 2007 (.xlsx) file format.  It supports styles and many of Excel's quirks, 
but not all.  It populates the classes from Spreadsheet::ParseExcel for interoperability; 
including Workbook, Worksheet, and Cell.

=head1 SEE ALSO

=over 2

=item Text::CSV_XS, Text::CSV_PP

http://search.cpan.org/~hmbrand/

A pure perl version is available on http://search.cpan.org/~makamaka/

=item Spreadsheet::ParseExcel

http://search.cpan.org/~kwitknr/

=item Spreadsheet::ReadSXC

http://search.cpan.org/~terhechte/

=item Spreadsheet::BasicRead

http://search.cpan.org/~gng/ for xlscat likewise functionality (Excel only)

=item Spreadsheet::ConvertAA

http://search.cpan.org/~nkh/ for an alternative set of cell2cr () /
cr2cell () pair

=item Spreadsheet::Perl

http://search.cpan.org/~nkh/ offers a Pure Perl implementation of a
spreadsheet engine. Users that want this format to be supported in
Spreadsheet::Read are hereby motivated to offer patches. It's not high
on my todo-list.

=item xls2csv

http://search.cpan.org/~ken/ offers an alternative for my C<xlscat -c>,
in the xls2csv tool, but this tool focusses on character encoding
transparency, and requires some other modules.

=item Spreadsheet::Read

http://search.cpan.org/~hmbrand/ read the data from a spreadsheet (interface 
module)

=back

=head1 AUTHOR

Dmitry Ovsyanko, E<lt>do@eludia.ru<gt>, http://eludia.ru/wiki/

Patches by:

	Steve Simms
	Joerg Meltzer
	Loreyna Yeung	
	Rob Polocz
	Gregor Herrmann
	H.Merijn Brand
	endacoe
	Pat Mariani
	Sergey Pushkin
	
=head1 ACKNOWLEDGEMENTS	

	Thanks to TrackVia Inc. (http://www.trackvia.com) for paying for Rob Polocz working time.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Dmitry Ovsyanko

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
