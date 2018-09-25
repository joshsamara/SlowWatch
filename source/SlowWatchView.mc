using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Math;

class SlowWatchView extends WatchUi.WatchFace {
    // TODO CONFIGS
    static const USE_12_HOUR = true;
    // Useful numeric constants
    static const HOURS_PER_DAY = 24;
    static const MIN_PER_HOUR = 60.0;
    static const MIN_PER_DAY = MIN_PER_HOUR * HOURS_PER_DAY;
    static const NUM_HOUR_OFFSET = 18; 	// Furthest right is 18 on a clock
    // Colors
    static const HAND_COLOR = Graphics.COLOR_BLUE;
    static const HOUR_COLOR = Graphics.COLOR_LT_GRAY;
    static const SM_TICK_COLOR = Graphics.COLOR_DK_GRAY;
    static const MD_TICK_COLOR = Graphics.COLOR_DK_GRAY;
    static const LG_TICK_COLOR = Graphics.COLOR_LT_GRAY;
    // Tick Constants
    static const TICKS_PER_HR = 4;
    static const NUM_TICKS = HOURS_PER_DAY * TICKS_PER_HR;
    static const ANGLE_PER_TICK = 2.0 * Math.PI / NUM_TICKS;
    // Tick visual constants
    static const SM_TICK_WIDTH = 1;
    static const SM_TICK_LEN = 16;
    static const LG_TICK_WIDTH = 2;
    static const LG_TICK_LEN = 16;
    // Hour Constants
    static const HOUR_FONT = Graphics.FONT_XTINY;
    static const HOUR_JUSTIFY = Graphics.TEXT_JUSTIFY_CENTER;
    // Hour visual constants
    static const ANGLE_PER_HOUR = 2.0 * Math.PI / HOURS_PER_DAY;
    static const HOUR_RAD_OFFSET = 7;
    static const TEXT_HEIGHT_OFFSET = Graphics.getFontHeight(HOUR_FONT) / 2;
    // Hand constants
    static const HAND_WIDTH = 2;
    // Other constants
    static const OUTTER_PADDING = 2;
    static const MAGIC_OFFSET = 6; // Min offset between different rings
    // Globals to set on app startup
    var HEIGHT, WIDTH, RADIUS, TEXT_WIDTH;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        // Pre-set global vars
        HEIGHT = dc.getHeight();
        WIDTH = dc.getWidth();
        RADIUS = WIDTH / 2;
        TEXT_WIDTH = dc.getTextWidthInPixels("23", HOUR_FONT);
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
        drawCircle(dc);
        drawTicks(dc);
        drawHours(dc);
        drawHand(dc);
    }


    function drawCircle(dc) {
        // dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_RED);
        // dc.drawCircle(RADIUS, RADIUS, RADIUS);
        // dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_GREEN);
        // dc.drawCircle(RADIUS, RADIUS, RADIUS-1);
        // dc.drawCircle(RADIUS, RADIUS, RADIUS - TEXT_WIDTH - MAGIC_OFFSET);
    }

    function drawTicks(dc) {
        // Outer radius should be outside the numbers
        var outerRad = RADIUS - (TEXT_WIDTH + MAGIC_OFFSET) - OUTTER_PADDING;
        var smallInnerRad = outerRad - SM_TICK_LEN;
        // Radius for full-sized ticks
        var largeInnerRad = outerRad - LG_TICK_LEN;
        // Init vars for each tick
        var innerRad, theta, x1, x2, y1, y2;
        for (var i = 0; i < NUM_TICKS; i++) {
            if (i % TICKS_PER_HR == 0) {
                // Large Tick (Every hour)
                innerRad = largeInnerRad;
                dc.setColor(LG_TICK_COLOR, LG_TICK_COLOR);
                dc.setPenWidth(LG_TICK_WIDTH);
            } else if (i % (TICKS_PER_HR / 2) == 0) {
                // Medium Tick (Every half hour)
                innerRad = smallInnerRad;
                dc.setPenWidth(SM_TICK_WIDTH);
                dc.setColor(MD_TICK_COLOR, MD_TICK_COLOR);
            } else {
                // Small Tick (Every 15 min)
                innerRad = smallInnerRad;
                dc.setPenWidth(SM_TICK_WIDTH);
                dc.setColor(SM_TICK_COLOR, SM_TICK_COLOR);
            }

            // Angle of individual tick
            theta = i * ANGLE_PER_TICK;
            // Round to avoid squigly ticks
            x1 = Math.round(RADIUS + outerRad * Math.cos(theta));
            y1 = Math.round(RADIUS + outerRad * Math.sin(theta));
            x2 = Math.round(RADIUS + innerRad * Math.cos(theta));
            y2 = Math.round(RADIUS + innerRad * Math.sin(theta));
            // Actually draw the ticks
            dc.drawLine(x1, y1, x2, y2);
        }

    }

    function drawHours(dc) {
        dc.setColor(HOUR_COLOR, Graphics.COLOR_BLACK);

        var innerRad = RADIUS - OUTTER_PADDING;
        // Pre-init any vars used per hour
        var theta, hourVal, hourStr, x, xOffset, y, yOffset;
        for (var i = 0; i < HOURS_PER_DAY; i++) {
            // The hour text to render starting at the rightmost (18)
            if (USE_12_HOUR) {
                hourVal = (NUM_HOUR_OFFSET + i) % 12;
                if (hourVal == 0) { hourVal = 12; }
            } else {
                hourVal = (NUM_HOUR_OFFSET + i) % HOURS_PER_DAY;
            }
            hourStr = hourVal.format("%02d");

            // Angle of indivudal hours
            theta = i * ANGLE_PER_HOUR;
            // Offet of tick + Width of text
            xOffset = (innerRad - TEXT_WIDTH / 2 ) * Math.cos(theta);
            // Offset of height based on angle + Constant height offset
            yOffset = (innerRad - TEXT_HEIGHT_OFFSET) * Math.sin(theta) - TEXT_HEIGHT_OFFSET;

            // Actually draw the text
            x = RADIUS + xOffset;
            y = RADIUS + yOffset;
            dc.drawText(x, y, HOUR_FONT, hourStr, HOUR_JUSTIFY);
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

        var outerRad = RADIUS - (TEXT_WIDTH + MAGIC_OFFSET) - OUTTER_PADDING;
        var x = RADIUS + outerRad * Math.cos(theta);
        var y = RADIUS + outerRad * Math.sin(theta);

        dc.setPenWidth(1);
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
