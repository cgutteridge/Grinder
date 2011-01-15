package Spreadsheet::ParseExcel::FmtUnicode;

###############################################################################
#
# Spreadsheet::ParseExcel::FmtUnicode - A class for Cell formats.
#
# Used in conjunction with Spreadsheet::ParseExcel.
#
# Copyright (c) 2009      John McNamara
# Copyright (c) 2006-2008 Gabor Szabo
# Copyright (c) 2000-2006 Kawai Takanori
#
# perltidy with standard settings.
#
# Documentation after __END__
#

use strict;
use warnings;

use Unicode::Map;
use base 'Spreadsheet::ParseExcel::FmtDefault';

our $VERSION = '0.58';

#------------------------------------------------------------------------------
# new (for Spreadsheet::ParseExcel::FmtUnicode)
#------------------------------------------------------------------------------
sub new {
    my ( $sPkg, %hKey ) = @_;
    my $sMap = $hKey{Unicode_Map};
    my $oMap;
    $oMap = Unicode::Map->new($sMap) if $sMap;
    my $oThis = {
        Unicode_Map => $sMap,
        _UniMap     => $oMap,
    };
    bless $oThis;
    return $oThis;
}

#------------------------------------------------------------------------------
# TextFmt (for Spreadsheet::ParseExcel::FmtUnicode)
#------------------------------------------------------------------------------
sub TextFmt {
    my ( $oThis, $sTxt, $sCode ) = @_;
    if ( $oThis->{_UniMap} ) {
        if ( !defined($sCode) ) {
            my $sSv = $sTxt;
            $sTxt =~ s/(.)/\x00$1/sg;
            $sTxt = $oThis->{_UniMap}->from_unicode($sTxt);
            $sTxt = $sSv unless ($sTxt);
        }
        elsif ( $sCode eq 'ucs2' ) {
            $sTxt = $oThis->{_UniMap}->from_unicode($sTxt);
        }

        #        $sTxt = $oThis->{_UniMap}->from_unicode($sTxt)
        #                     if(defined($sCode) && $sCode eq 'ucs2');
        return $sTxt;
    }
    else {
        return $sTxt;
    }
}
1;

__END__

=pod

=head1 NAME

Spreadsheet::ParseExcel::FmtUnicode - A class for Cell formats.

=head1 SYNOPSIS

See the documentation for Spreadsheet::ParseExcel.

=head1 DESCRIPTION

This module is used in conjunction with Spreadsheet::ParseExcel. See the documentation for Spreadsheet::ParseExcel.

=head1 AUTHOR

Maintainer 0.40+: John McNamara jmcnamara@cpan.org

Maintainer 0.27-0.33: Gabor Szabo szabgab@cpan.org

Original author: Kawai Takanori kwitknr@cpan.org

=head1 COPYRIGHT

Copyright (c) 2009-2010 John McNamara

Copyright (c) 2006-2008 Gabor Szabo

Copyright (c) 2000-2006 Kawai Takanori

All rights reserved.

You may distribute under the terms of either the GNU General Public License or the Artistic License, as specified in the Perl README file.

=cut
