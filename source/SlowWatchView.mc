using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;

class SlowWatchView extends WatchUi.WatchFace {
	static const HOUR_PER_DAY = 24;
	static const MIN_PER_HOUR = 60.0;
	static const MIN_PER_DAY = MIN_PER_HOUR * HOUR_PER_DAY;
	static const HAND_COLOR = Graphics.COLOR_BLUE;
	static const NUM_HOUR_OFFSET = 18; 	// Furthest right is 18 on a clock

    function initialize() {
        WatchFace.initialize();
    }


    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
		// Get the hours
        var clockTime = System.getClockTime();
        var hourWithOffset = (clockTime.hour - NUM_HOUR_OFFSET) % HOUR_PER_DAY;
        var hours = hourWithOffset * MIN_PER_HOUR + clockTime.min;
        // Find the angle
		var width = dc.getWidth();
        var height = dc.getHeight();
        // Set radius based on screen sizes and widths
        var outerRad = width / 2;
        var theta = (hours / MIN_PER_DAY) * 2 * Math.PI;
        // Draw the watch hand
        dc.setColor(HAND_COLOR, HAND_COLOR);

        var x = outerRad + outerRad * Math.cos(theta);
        var y = outerRad + outerRad * Math.sin(theta);

        dc.setPenWidth(2);
		dc.drawLine(outerRad, outerRad, x, y);

    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }
}
