/*

Drawable for the watch ticks.

Logic adapted from: https://gitlab.com/snaggen/ConnectIQ-ActiveAnalog/blob/master/source/AnalogView.mc

*/
using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Math;


class WatchTicks extends WatchUi.Drawable {
	// Tick dimensions
	static const SM_TICK_WIDTH = 1;
	static const SM_TICK_LEN = 5;
	static const LG_TICK_WIDTH = 2;
	static const LG_TICK_LEN = 7;
	// Colors
	static const SM_TICK_COLOR = Graphics.COLOR_DK_GRAY;
	static const LG_TICK_COLOR = Graphics.COLOR_LT_GRAY;
	// Useful constants
	static const TICKS_PER_HR = 4;
	static const NUM_TICKS = 24 * TICKS_PER_HR;
	static const ANGLE_PER_TICK = 2 * Math.PI / NUM_TICKS;

    function initialize(params) {
        Drawable.initialize(params);
    }

    function draw(dc) {
    	// Get Screen Height and Width    	
        var width = dc.getWidth();
        var height = dc.getHeight();

        // Set radius based on screen sizes and widths
        var outerRad = width / 2;
        var smallInnerRad = outerRad - SM_TICK_LEN;
        // Radius for full-sized ticks
        var largeInnerRad = outerRad - LG_TICK_LEN;
        // Init vars for each tick
        var innerRad, theta, x1, x2, y1, y2;
        for (var i = 0; i < NUM_TICKS; i++) {
        	if (i % TICKS_PER_HR == 0) {
        		// Large Tick
        		innerRad = largeInnerRad;
        		dc.setColor(LG_TICK_COLOR, LG_TICK_COLOR);
        		dc.setPenWidth(LG_TICK_WIDTH);
        	} else {
        		// Small Tick
        		innerRad = smallInnerRad;
    		   	dc.setColor(SM_TICK_COLOR, SM_TICK_COLOR);
        		dc.setPenWidth(SM_TICK_WIDTH);
        	}
        	
        	// Angle of individual tick
            theta = i * ANGLE_PER_TICK;
            x1 = outerRad + outerRad * Math.cos(theta);
            y1 = outerRad + outerRad * Math.sin(theta);
			x2 = outerRad + innerRad * Math.cos(theta);
			y2 = outerRad + innerRad * Math.sin(theta);
			// Actually draw the ticks
            dc.drawLine(x1, y1, x2, y2);
        }
    }
}
