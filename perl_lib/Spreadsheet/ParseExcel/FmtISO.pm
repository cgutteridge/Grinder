package Spreadsheet::ParseExcel::FmtISO;

use Spreadsheet::ParseExcel::FmtDefault;

our @ISA = qw/ Spreadsheet::ParseExcel::FmtDefault /;

sub new {
    my ( $sPkg, %hKey ) = @_;
    my $oThis = {};
    bless $oThis;
    return $oThis;
}
 
sub FmtStringDef 
{
	my ( $oThis, $iFmtIdx, $oBook, $rhFmt ) = @_;

	return "yyyy-mm-dd;@" if( $iFmtIdx == 166 );
	#return "0.0;@" if( $iFmtIdx == 167 );
	#return "##;@" if( $iFmtIdx == 167 );

	my $def = $oThis->SUPER::FmtStringDef( $iFmtIdx, $oBook,$rhFmt );

	return $def;
}

1;
