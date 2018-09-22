/*

Drawable for the numbers.

*/
using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Math;


class WatchHours extends WatchUi.Drawable {
	// Font Customization
	static const HOUR_COLOR = Graphics.COLOR_LT_GRAY;
	static const HOUR_FONT = Graphics.FONT_XTINY;
	static const HOUR_JUSTIFY = Graphics.TEXT_JUSTIFY_CENTER;
	// Useful constants
	static const HOUR_RAD_OFFSET = 7;
	static const TEXT_HEIGHT_OFFSET = Graphics.getFontHeight(HOUR_FONT) / 2;
	static const MAGIC_OFFSET = 4;  // Offset that just looks better
	static const NUM_HOURS = 24;
	static const NUM_HOUR_OFFSET = 18; 	// Furthest right is 18 on a clock 
	static const ANGLE_PER_HOUR = 2 * Math.PI / NUM_HOURS;


    function initialize(params) {
        Drawable.initialize(params);
    }

    function draw(dc) {
    	dc.setColor(HOUR_COLOR, Graphics.COLOR_BLACK);
    
    	// Get Screen Height and Width    	
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        // Set radius based on screen sizes and widths
        var outerRad = width / 2;
        var innerRad = outerRad - HOUR_RAD_OFFSET;
        
        // Pre-init any vars used per hour
        var theta, textWidth, hourVal, x, xOffset, y, yOffset;
        for (var i = 0; i < NUM_HOURS; i++) {
        	// The hour text to render starting at the rightmost (18)
        	hourVal = ((NUM_HOUR_OFFSET + i) % NUM_HOURS).toString();
        	textWidth = dc.getTextWidthInPixels(hourVal, HOUR_FONT);

			if (textWidth > 10) {
				// Large texts just look better with an arbitrary offset
				textWidth -= MAGIC_OFFSET;
			}
        	// Angle of indivudal hours
        	theta = i * ANGLE_PER_HOUR;
        	// Offet of tick + Width of text
        	xOffset = (innerRad - textWidth) * Math.cos(theta);
        	// Offset of height based on angle + Constant height offset 
        	yOffset = (innerRad - TEXT_HEIGHT_OFFSET) * Math.sin(theta) - TEXT_HEIGHT_OFFSET;
                    
            // Actually draw the text
			x = outerRad + xOffset;
			y = outerRad + yOffset;
			dc.drawText(x, y, HOUR_FONT, hourVal, HOUR_JUSTIFY);
        }
    }
}
