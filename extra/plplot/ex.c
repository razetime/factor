

//     Sample plots using date / time formatting for axes
//
// Copyright (C) 2007 Andrew Ross
//
// This file is part of PLplot.
//
//  PLplot is free software; you can redistribute it and/or modify
// it under the terms of the GNU Library General Public License as published
// by the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// PLplot is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Library General Public License for more details.
//
// You should have received a copy of the GNU Library General Public License
// along with PLplot; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
//



#include <math.h>
#include <string.h>
#include <ctype.h>

#include <plplot/plplot.h>
#include <plplot/plConfig.h>

#ifndef PI
#define PI    3.1415926535897932384
#endif

#ifndef M_PI
#define M_PI    3.1415926535897932384
#endif

static PLFLT x[365], y[365];
static PLFLT xerr1[365], xerr2[365], yerr1[365], yerr2[365];

// Function prototypes

void plot1( void );
void plot2( void );
void plot3( void );
void plot4( void );

//--------------------------------------------------------------------------
// main
//
// Draws several plots which demonstrate the use of date / time formats for
// the axis labels.
// Time formatting is done using the strfqsas routine from the qsastime
// library.  This is similar to strftime, but works for a broad
// date range even on 32-bit systems.  See the
// documentation of strfqsas for full details of the available formats.
//
// 1) Plotting temperature over a day (using hours / minutes)
// 2) Plotting
//
// Note: We currently use the default call for plconfigtime (done in
// plinit) which means continuous times are interpreted as seconds since
// 1970-01-01, but that may change in future, more extended versions of
// this example.
//
//--------------------------------------------------------------------------

int
main( int argc, char *argv[] )
{
    // Parse command line arguments
    plparseopts( &argc, argv, PL_PARSE_FULL );

    // Initialize plplot
    plinit();

    // Change the escape character to a '@' instead of the default '#'
    plsesc( '@' );

    plot1();


    // Don't forget to call plend() to finish off!
    plend();
    exit( 0 );
}

// Plot a model diurnal cycle of temperature
void
plot1( void )
{
    int   i, npts;
    PLFLT xmin, xmax, ymin, ymax;

    // Data points every 10 minutes for 1 day
    npts = 73;

    xmin = 0;
    xmax = 60.0 * 60.0 * 24.0; // Number of seconds in a day
    ymin = 10.0;
    ymax = 20.0;

    for ( i = 0; i < npts; i++ )
    {
        x[i] = xmax * ( (PLFLT) i / (PLFLT) npts );
        y[i] = 15.0 - 5.0 * cos( 2 * M_PI * ( (PLFLT) i / (PLFLT) npts ) );
        // Set x error bars to +/- 5 minute
        xerr1[i] = x[i] - 60 * 5;
        xerr2[i] = x[i] + 60 * 5;
        // Set y error bars to +/- 0.1 deg C
        yerr1[i] = y[i] - 0.1;
        yerr2[i] = y[i] + 0.1;
    }

    pladv( 0 );

    // Rescale major ticks marks by 0.5
    plsmaj( 0.0, 0.5 );
    // Rescale minor ticks and error bar marks by 0.5
    plsmin( 0.0, 0.5 );

    plvsta();
    plwind( xmin, xmax, ymin, ymax );

    // Draw a box with ticks spaced every 3 hour in X and 1 degree C in Y.
    plcol0( 1 );
    // Set time format to be hours:minutes
    pltimefmt( "%H:%M" );
    plbox( "bcnstd", 3.0 * 60 * 60, 3, "bcnstv", 1, 5 );

    plcol0( 3 );
    pllab( "Time (hours:mins)", "Temperature (degC)", "@frPLplot Example 29 - Daily temperature" );

    plcol0( 4 );

    plline( npts, x, y );
    plcol0( 2 );
    plerrx( npts, xerr1, xerr2, y );
    plcol0( 3 );
    plerry( npts, x, yerr1, yerr2 );

    // Rescale major / minor tick marks back to default
    plsmin( 0.0, 1.0 );
    plsmaj( 0.0, 1.0 );
}

