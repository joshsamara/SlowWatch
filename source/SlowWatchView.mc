using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Math;

class SlowWatchView extends WatchUi.WatchFace {
    // Useful numeric constants
    static const HOURS_PER_DAY = 24;
    static const MIN_PER_HOUR = 60.0;
    static const MIN_PER_DAY = MIN_PER_HOUR * HOURS_PER_DAY;
    static const NUM_HOUR_OFFSET = 18; 	// Furthest right is 18 on a clock
    // Colors
    static const HAND_COLOR = Graphics.COLOR_BLUE;
    static const HOUR_COLOR = Graphics.COLOR_LT_GRAY;
    static const SM_TICK_COLOR = Graphics.COLOR_DK_GRAY;
    static const LG_TICK_COLOR = Graphics.COLOR_LT_GRAY;
    // Tick Constants
    static const TICKS_PER_HR = 4;
    static const NUM_TICKS = HOURS_PER_DAY * TICKS_PER_HR;
    static const ANGLE_PER_TICK = 2 * Math.PI / NUM_TICKS;
    // Tick visual constants
    static const SM_TICK_WIDTH = 1;
    static const SM_TICK_LEN = 5;
    static const LG_TICK_WIDTH = 2;
    static const LG_TICK_LEN = 7;
    // Hour Constants
    static const HOUR_FONT = Graphics.FONT_XTINY;
    static const HOUR_JUSTIFY = Graphics.TEXT_JUSTIFY_CENTER;
    // Hour visual constants
    static const ANGLE_PER_HOUR = 2 * Math.PI / HOURS_PER_DAY;
    static const HOUR_RAD_OFFSET = 7;
    static const TEXT_HEIGHT_OFFSET = Graphics.getFontHeight(HOUR_FONT) / 2;
    static const MAGIC_OFFSET = 4;  // Offset that just looks better
    // Globals to set on app startup
    var HEIGHT, WIDTH, RADIUS;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        // Pre-set shared vars
        HEIGHT = dc.getHeight();
        WIDTH = dc.getWidth();
        RADIUS = WIDTH / 2;
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
        drawTicks(dc);
        drawHours(dc);
        drawHand(dc);
    }

    function drawTicks(dc) {
        var smallInnerRad = RADIUS - SM_TICK_LEN;
        // Radius for full-sized ticks
        var largeInnerRad = RADIUS - LG_TICK_LEN;
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
            x1 = RADIUS + RADIUS * Math.cos(theta);
            y1 = RADIUS + RADIUS * Math.sin(theta);
            x2 = RADIUS + innerRad * Math.cos(theta);
            y2 = RADIUS + innerRad * Math.sin(theta);
            // Actually draw the ticks
            dc.drawLine(x1, y1, x2, y2);
        }

    }

    function drawHours(dc) {
        dc.setColor(HOUR_COLOR, Graphics.COLOR_BLACK);

        var innerRad = RADIUS - HOUR_RAD_OFFSET;
        // Pre-init any vars used per hour
        var theta, textWidth, hourVal, x, xOffset, y, yOffset;
        for (var i = 0; i < HOURS_PER_DAY; i++) {
            // The hour text to render starting at the rightmost (18)
            hourVal = ((NUM_HOUR_OFFSET + i) % HOURS_PER_DAY).toString();
            textWidth = dc.getTextWidthInPixels(hourVal, HOUR_FONT);

            // Large texts just look better with an arbitrary offset
            if (textWidth > 10) { textWidth -= MAGIC_OFFSET; }
            // Angle of indivudal hours
            theta = i * ANGLE_PER_HOUR;
            // Offet of tick + Width of text
            xOffset = (innerRad - textWidth) * Math.cos(theta);
            // Offset of height based on angle + Constant height offset
            yOffset = (innerRad - TEXT_HEIGHT_OFFSET) * Math.sin(theta) - TEXT_HEIGHT_OFFSET;

            // Actually draw the text
            x = RADIUS + xOffset;
            y = RADIUS + yOffset;
            dc.drawText(x, y, HOUR_FONT, hourVal, HOUR_JUSTIFY);
        }
    }

    function drawHand(dc) {
        // Get the hours
        var clockTime = System.getClockTime();
        var hourWithOffset = (clockTime.hour - NUM_HOUR_OFFSET) % HOURS_PER_DAY;
        var hours = hourWithOffset * MIN_PER_HOUR + clockTime.min;
        // Set radius based on screen sizes and widths
        var theta = (hours / MIN_PER_DAY) * 2 * Math.PI;
        // Draw the watch hand

        var x = RADIUS + RADIUS * Math.cos(theta);
        var y = RADIUS + RADIUS * Math.sin(theta);

        dc.setPenWidth(2);
        dc.setColor(HAND_COLOR, HAND_COLOR);
        dc.drawLine(RADIUS, RADIUS, x, y);
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
