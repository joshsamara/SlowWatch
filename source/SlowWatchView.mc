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
    static const NUM_HOUR_OFFSET = 18;  // Furthest right is 18 on a clock
    // Colors
    static const HAND_COLOR = Graphics.COLOR_GREEN;
    static const MIN_COLOR = Graphics.COLOR_DK_GREEN;
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
    static const SM_TICK_LEN = 24;
    static const LG_TICK_WIDTH = 2;
    static const LG_TICK_LEN = 24;
    // Hour Constants
    static const HOUR_ANGLE_OFFSET = Math.PI / 2;  // Clock starts 1/4 around
    static const HOUR_FONT = Graphics.FONT_XTINY;
    static const HOUR_JUSTIFY = Graphics.TEXT_JUSTIFY_CENTER;
    // Hour visual constants
    static const ANGLE_PER_HOUR = 2.0 * Math.PI / HOURS_PER_DAY;
    static const HOUR_RAD_OFFSET = 7;
    static const TEXT_HEIGHT_OFFSET = Graphics.getFontHeight(HOUR_FONT) / 2;
    // Hand constants
    static const HAND_WIDTH = 2;
    // Progress constants
    static const PROGRESS_COLOR = Graphics.COLOR_BLUE;
    static const PROGRESS_WIDTH = 8;
    static const PROGRESS_START_HR = 12;
    // TODO - calc this
    static const PROGREES_START_ANGLE = 270;
    static const RAD_CONVERSION = 180 / Math.PI;
    // Other constants
    static const MIN_RENDER_OFFSET = 15;
    static const OUTTER_PADDING = 2;
    static const MAGIC_OFFSET = 6; // Min offset between different rings
    // Globals to set on app startup
    // HEIGHT - Screen Height
    // WIDTH - Screen Width
    // RADIUS - Full circle radius
    // DRAW_RADIUS_0 - Outermost draw radius
    // DRAW_RADIUS_1 - Second outermost draw radius
    // DRAW_RADIUS_2 - Third outermost draw radius
    // TEXT_WIDTH - Width of text on the screen
    var HEIGHT, WIDTH, RADIUS, DRAW_RADIUS_0, DRAW_RADIUS_1, DRAW_RADIUS_2, TEXT_WIDTH;
    // Globals set on every onUpdate
    // CURRENT_MINS - Current mins
    // CURRENT_MINS - Current total min (hours * 60 + min)
    // TIME_ANGLE - Angle of the hand on the face
    var CURRENT_MINS, CURRENT_TOTAL_MINS, TIME_ANGLE;

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
        setGlobals();
        drawTicks(dc);
        drawProgress(dc);
        drawHours(dc);
        drawHand(dc);
    }

    function setGlobals() {
        var clockTime = System.getClockTime();
        var hourWithOffset = clockTime.hour % HOURS_PER_DAY;
        CURRENT_MINS = clockTime.min;
        // CURRENT_MINS = 55;
        // Total minutes remaining
        CURRENT_TOTAL_MINS = hourWithOffset * MIN_PER_HOUR + clockTime.min;
        // Angle of the min hand
        TIME_ANGLE = (CURRENT_TOTAL_MINS / MIN_PER_DAY) * 2 * Math.PI + (HOUR_ANGLE_OFFSET);
        // Set drawing constants
        DRAW_RADIUS_0 = RADIUS;
        // RADIUS_1 is the same with the text padding
        DRAW_RADIUS_1 = DRAW_RADIUS_0 - (LG_TICK_LEN + MAGIC_OFFSET);
        // Same as 1 with padding for the largest tick
        DRAW_RADIUS_2 = DRAW_RADIUS_1 - (TEXT_WIDTH + MAGIC_OFFSET);
    }


    function drawProgress(dc) {
        // The arc angle works in the inverse of what our other angles expect
        var arcAngle = - (TIME_ANGLE * RAD_CONVERSION);
        dc.setColor(PROGRESS_COLOR, Graphics.COLOR_TRANSPARENT);

        var largeInnerRad = DRAW_RADIUS_0 - PROGRESS_WIDTH / 2;
        dc.setPenWidth(PROGRESS_WIDTH + 2);
        dc.drawArc(RADIUS, RADIUS, largeInnerRad, Graphics.ARC_CLOCKWISE, PROGREES_START_ANGLE, arcAngle);
    }

    function drawTicks(dc) {
        // Outer radius should be outside the numbers
        var outerRad = DRAW_RADIUS_0;
        var smallInnerRad = outerRad - SM_TICK_LEN;
        // Radius for full-sized ticks
        var largeInnerRad = outerRad - LG_TICK_LEN;
        // Calculate the tick of the current minute
        var offsetMin = (CURRENT_MINS + MIN_RENDER_OFFSET) % 60;  // Ticks start at '15'min
        var minTick = Math.ceil(offsetMin * NUM_TICKS / MIN_PER_HOUR);
        // Init vars for each tick
        var innerRad, theta, x1, x2, y1, y2;
        for (var i = 0; i < NUM_TICKS; i++) {
            if (i % TICKS_PER_HR == 0) {
                // Large Tick (Every hour)
                innerRad = largeInnerRad;
                dc.setColor(LG_TICK_COLOR, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(LG_TICK_WIDTH);
            } else if (i % (TICKS_PER_HR / 2) == 0) {
                // Medium Tick (Every half hour)
                innerRad = smallInnerRad;
                dc.setPenWidth(SM_TICK_WIDTH);
                dc.setColor(MD_TICK_COLOR, Graphics.COLOR_TRANSPARENT);
            } else {
                // Small Tick (Every 15 min)
                innerRad = smallInnerRad;
                dc.setPenWidth(SM_TICK_WIDTH);
                dc.setColor(SM_TICK_COLOR, Graphics.COLOR_TRANSPARENT);
            }

            if (minTick == i) {
                // Note the min tick
                dc.setColor(MIN_COLOR, Graphics.COLOR_TRANSPARENT);
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
        dc.setColor(HOUR_COLOR, Graphics.COLOR_TRANSPARENT);

        var innerRad = DRAW_RADIUS_1;
        // Pre-init any vars used per hour
        var theta, hourVal, hourStr, x, xOffset, y, yOffset;
        for (var i = 0; i < HOURS_PER_DAY; i++) {
            // Only show even numbers
            if (i % 2 == 1) { continue; }
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
            yOffset = (innerRad - MAGIC_OFFSET) * Math.sin(theta) - TEXT_HEIGHT_OFFSET;

            // Actually draw the text
            x = RADIUS + xOffset;
            y = RADIUS + yOffset;
            dc.drawText(x, y, HOUR_FONT, hourStr, HOUR_JUSTIFY);
        }
    }

    function drawHand(dc) {
        // Draw the watch hand up to the tick with a little extra
        var outerRad = DRAW_RADIUS_0;
        var x = RADIUS + outerRad * Math.cos(TIME_ANGLE);
        var y = RADIUS + outerRad * Math.sin(TIME_ANGLE);

        dc.setPenWidth(HAND_WIDTH);
        dc.setColor(HAND_COLOR, Graphics.COLOR_TRANSPARENT);
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
