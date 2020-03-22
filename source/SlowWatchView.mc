using Toybox.Application;
using Toybox.ActivityMonitor;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Math;
using Toybox.System;
using Toybox.WatchUi;

class SlowWatchView extends WatchUi.WatchFace {
    // TODO: Make the following configs
    static const USE_12_HOUR = true;
    // Numbers and pre-calculated constants
    static const HOURS_PER_DAY = 24;
    static const MIN_PER_HOUR = 60;
    static const MIN_PER_DAY = MIN_PER_HOUR * HOURS_PER_DAY;
    static const TAU = 2 * Math.PI;
    /*
    * Day "progress" meter (aka 24 clock)
    *
    * Broken into sections to indicate part of the day
    * 0 Too Early     12am-04am (Red)
    * 1 Also early    04am-08am (Orange)
    * 2 Morning       08am-12pm (Green) 
    * 3 Afternoon     12pm-04pm (Blue)
    * 4 Evening       04pm-08pm (Purple)
    * 5 Late          08pm-12am (Dark blue)
    *  
    */
    // Progress colors
    static const COLOR_PROGRESS_0 = Graphics.COLOR_RED;
    static const COLOR_PROGRESS_1 = Graphics.COLOR_ORANGE;
    static const COLOR_PROGRESS_2 = Graphics.COLOR_DK_GREEN;
    static const COLOR_PROGRESS_3 = Graphics.COLOR_BLUE;
    static const COLOR_PROGRESS_4 = Graphics.COLOR_PURPLE;
    static const COLOR_PROGRESS_5 = Graphics.COLOR_DK_BLUE;
    // Progress cutoffs
    static const PROGRESS_0_END = 4;  // 4a
    static const PROGRESS_1_END = 8;  // 8a
    static const PROGRESS_2_END = 12; // 12p
    static const PROGRESS_3_END = 16; // 4p
    static const PROGRESS_4_END = 20; // 8p
    static const PROGRESS_5_END = 24;  // 12a
    // Progress other draw constants
    static const PROGRESS_WIDTH = 16;
    static const PROGRESS_TICK_WIDTH = 4;
    static const COLOR_PROGRESS_TICK = Graphics.COLOR_YELLOW;
    // Informational colors
    static const COLOR_TIME = Graphics.COLOR_WHITE;
    static const COLOR_HEART = Graphics.COLOR_RED;
    static const COLOR_STEP = Graphics.COLOR_BLUE;
    static const COLOR_STEP_COMPLETE = Graphics.COLOR_DK_BLUE;
    // Time Constants
    static const TIME_FONT = Graphics.FONT_NUMBER_THAI_HOT;
    static const TIME_Y_FONT_MULTIPLIER = 1.75;
    // Counter Constants
    static const COUNTER_FONT = Graphics.FONT_MEDIUM;
    static const HEART_DEFAULT = "--";
    static const HEART_Y_MULTIPLIER = 0.33;
    static const STEP_DEFAULT = "----";
    static const STEP_Y_MULTIPLIER = 1.33;
    // Rendering constants
    static const RENDER_OFFSET_ANGLE = Math.PI / 2;  // 0 is on the bottom of the map
    static const OUTTER_PADDING = 2;
    static const MAGIC_OFFSET = 6; // Min offset between different rings
    // Tick colors (@deprecated)
    static const COLOR_HAND = Graphics.COLOR_RED;
    static const COLOR_CROSS = Graphics.COLOR_DK_GRAY;
    static const COLOR_MIN = Graphics.COLOR_RED;
    static const COLOR_HOUR = Graphics.COLOR_DK_GRAY;
    static const COLOR_HOUR_CARDINAL = Graphics.COLOR_LT_GRAY;
    static const COLOR_TICK_INACTIVE = Graphics.COLOR_TRANSPARENT;
    static const COLOR_SM_TICK = Graphics.COLOR_DK_GRAY;
    static const COLOR_LG_TICK = Graphics.COLOR_LT_GRAY;
    static const COLOR_LG_TICK_INACTIVE = Graphics.COLOR_DK_GRAY;
    // Tick Constants (@deprecated)
    static const TICKS_PER_HR = 4;
    static const NUM_TICKS = HOURS_PER_DAY * TICKS_PER_HR;
    static const ANGLE_PER_TICK = TAU / NUM_TICKS;
    // Tick visual constants (@deprecated)
    static const SM_TICK_WIDTH = 1;
    static const SM_TICK_LEN = 56;
    static const LG_TICK_WIDTH = 2;
    static const LG_TICK_LEN = 56;
    static const LG_TICK_LEN_INACTIVE = 32;
    // Hour Constants (@deprecated)
    static const HOUR_FONT = Graphics.FONT_XTINY;
    static const HOUR_JUSTIFY = Graphics.TEXT_JUSTIFY_CENTER;
    // Hour visual constants  (@deprecated)
    static const ANGLE_PER_HOUR = 2.0 * Math.PI / HOURS_PER_DAY;
    static const HOUR_RAD_OFFSET = 7;
    static const TEXT_HEIGHT_OFFSET = Graphics.getFontHeight(HOUR_FONT) / 2;
    // Hand constants (@deprecated)
    static const HAND_WIDTH = 2;
    // Cross constatnts (@deprecated)
    static const CROSS_WIDTH = LG_TICK_WIDTH;
    static const CROSS_LEN = 16;
    static const PROGREES_START_ANGLE = 270;  // TODO - calc this
    static const RAD_CONVERSION = 180 / Math.PI;
    /* 
    * Globals to set on app startup
    * 
    * HEIGHT        - Screen Height
    * WIDTH         - Screen Width
    * RADIUS        - Full circle radius
    * DRAW_RADIUS_0 - Outermost draw radius
    * DRAW_RADIUS_1 - Second outermost draw radius
    * DRAW_RADIUS_2 - Third outermost draw radius
    * TEXT_WIDTH    - Width of text on the screen
    */
    var HEIGHT, WIDTH, RADIUS, DRAW_RADIUS_0, DRAW_RADIUS_1, DRAW_RADIUS_2, TEXT_WIDTH;
    /*
    * Globals set on every onUpdate
    *
    * CURRENT_HOUR       - Current hour
    * CURRENT_MINS       - Current mins
    * CURRENT_TOTAL_MINS - Current total min (hours * 60 + min)
    * TIME_ANGLE         - Angle of the hand on the face
    * Active hours is a window of even hours near the current hour
    * ACTIVE_HOUR_FLOOR   - Closest even number (rounded down)
    * ACTIVE_HOUR_CEIL    - Closest even number (rounded up)
    */
    var CURRENT_HOUR, CURRENT_MINS, CURRENT_TOTAL_MINS, TIME_ANGLE, ACTIVE_HOUR_FLOOR, ACTIVE_HOUR_CEIL;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }


    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        setGlobals(dc);
        // Below order matters
        drawProgressBar(dc);
        drawProgressTick(dc);
        drawTime(dc);
        drawHeartRate(dc);
        drawSteps(dc);
        // @deprecated - No Longer Used
        // This was to draw a bunch of ticks for a 24hour watch
        // This is now done by a 'progress' meter
        // drawHours(dc);
        // drawCross(dc);
        // drawTicks(dc);
        // drawHand(dc);
    }

    /*
    * Setup all globals
    */
    function setGlobals(dc) {
        // Pre-set global vars
        HEIGHT = dc.getHeight();
        WIDTH = dc.getWidth();
        RADIUS = WIDTH / 2;
        TEXT_WIDTH = dc.getTextWidthInPixels("23", HOUR_FONT);

        var clockTime = System.getClockTime();
        CURRENT_HOUR = clockTime.hour;
        CURRENT_MINS = clockTime.min;
        // Total minutes remaining
        CURRENT_TOTAL_MINS = CURRENT_HOUR * MIN_PER_HOUR + clockTime.min;
        // Angle of the min hand
        TIME_ANGLE = (CURRENT_TOTAL_MINS / MIN_PER_DAY.toFloat()) * TAU + RENDER_OFFSET_ANGLE;
        // Set active consts
        ACTIVE_HOUR_FLOOR = CURRENT_HOUR & ~1;
        ACTIVE_HOUR_CEIL = ACTIVE_HOUR_FLOOR + 2;
        // Set drawing constants
        DRAW_RADIUS_0 = RADIUS;
        // RADIUS_1 is the same with the text padding
        DRAW_RADIUS_1 = DRAW_RADIUS_0 - (LG_TICK_LEN + MAGIC_OFFSET);
        // Same as 1 with padding for the largest tick
        DRAW_RADIUS_2 = DRAW_RADIUS_1 - (TEXT_WIDTH + MAGIC_OFFSET);
    }



    /*
    * Draw that outline circle; Color based on the current time
    */
    function drawProgressBar(dc) {
        // The arc angle works in the inverse of what our other angles expect
        var arcAngle = - (TIME_ANGLE * RAD_CONVERSION);
        // Set the color based on the current hour
        // NOTE: Probably works as a switch statement
        var progressColor;
        if (0 <= CURRENT_HOUR && CURRENT_HOUR < PROGRESS_0_END) {
      progressColor = COLOR_PROGRESS_0;
        } else if (CURRENT_HOUR < PROGRESS_1_END) {
          progressColor = COLOR_PROGRESS_1;
        } else if (CURRENT_HOUR < PROGRESS_2_END) {
          progressColor = COLOR_PROGRESS_2;
      } else if (CURRENT_HOUR < PROGRESS_3_END) {
          progressColor = COLOR_PROGRESS_3;
      } else if (CURRENT_HOUR < PROGRESS_4_END) {
        progressColor = COLOR_PROGRESS_4;
      } else if (CURRENT_HOUR < PROGRESS_5_END) {
          progressColor = COLOR_PROGRESS_5;
        } else {
          // Shouldn't get hit (but it'll be bright if it does)
            progressColor = Graphics.COLOR_YELLOW;
        }

        var largeInnerRad = DRAW_RADIUS_0 - PROGRESS_WIDTH / 2;
        dc.setPenWidth(PROGRESS_WIDTH + 2);
        // Draw 'filled' section
        dc.setColor(progressColor, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(RADIUS, RADIUS, largeInnerRad, Graphics.ARC_CLOCKWISE, PROGREES_START_ANGLE, arcAngle);
        // Draw remaining background
        // dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        // dc.drawArc(RADIUS, RADIUS, largeInnerRad, Graphics.ARC_CLOCKWISE, arcAngle, PROGREES_START_ANGLE);
    }
    
    /*
    * Draw a small progress indicator
    */ 
    function drawProgressTick(dc) {
        var outerRad = DRAW_RADIUS_0;
        var innerRad = outerRad - PROGRESS_WIDTH;
        
        var x0 = RADIUS + innerRad * Math.cos(TIME_ANGLE);
        var y0 = RADIUS + innerRad * Math.sin(TIME_ANGLE);
        var x = RADIUS + outerRad * Math.cos(TIME_ANGLE);
        var y = RADIUS + outerRad * Math.sin(TIME_ANGLE);

        dc.setPenWidth(HAND_WIDTH + 2);
        dc.setColor(COLOR_PROGRESS_TICK, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x0, y0, x, y);
    }

    /*
    * Draw a simple time
    */
    function drawTime(dc) {
        // TODO - 12vs24 hr format
        var hourStr = (CURRENT_HOUR % 12).format("%02d");
        var minStr = CURRENT_MINS.format("%02d");
        var timestring = hourStr + ":" + minStr;

        var offsets = dc.getTextDimensions(timestring, TIME_FONT);

        var x = RADIUS;
        var y = RADIUS - offsets[1] / TIME_Y_FONT_MULTIPLIER;
        dc.setColor(COLOR_TIME, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, TIME_FONT, timestring, HOUR_JUSTIFY);
    }

    /* 
    * Draw the heart rate
    */
    function drawHeartRate(dc) {
        // Poll for the current info (1 latest tick)
        var heart = ActivityMonitor.getHeartRateHistory(1, true).next();
        // Default if we can't get the info
        heart = (heart == null) ? HEART_DEFAULT : heart.heartRate;
        // Draw
        var x = RADIUS;
        var y = RADIUS * HEART_Y_MULTIPLIER;
        dc.setColor(COLOR_HEART, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, COUNTER_FONT, heart, HOUR_JUSTIFY);
    }

    /*
    * Draw the current steps
    */
    function drawSteps(dc) {
        // Poll for the current info
        var activityInfo = Toybox.ActivityMonitor.getInfo();
        var current = activityInfo.steps;
        var goal = activityInfo.stepGoal;
        // Default if we can't get info
        if (current == null) { current = STEP_DEFAULT; }
        if (goal == null) { goal = STEP_DEFAULT; }
        // Format as "CURRENT / GOAL"
        var stepStr = current + " / " + goal;
        // Use a differnt color if we're done
        var color;
        if (current <= goal) {
            color = COLOR_STEP;
        } else {
            color = COLOR_STEP_COMPLETE;
        }
        // DRAW
        var x = RADIUS;
        var y = RADIUS * STEP_Y_MULTIPLIER;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, COUNTER_FONT, stepStr, HOUR_JUSTIFY);
    }


    // NOTE -- Currently unused but can probably be used
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

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }


    /* ==========================================
    *
    *  No longer used below
    *
    *  ==========================================
    */

    // @deprecated Draw ticks along outter edges of the watch
    function drawTicks(dc) {
        // Outer radius should be outside the numbers
        var outerRad = DRAW_RADIUS_0;
        var smallInnerRad = outerRad - SM_TICK_LEN;
        // Radius for full-sized ticks
        var largeInnerRad = outerRad - LG_TICK_LEN;
        var inactiveInnerRad = outerRad - LG_TICK_LEN_INACTIVE;
        // Calculate the tick of the current minute
        var minTick = Math.ceil(CURRENT_MINS * NUM_TICKS / MIN_PER_HOUR);
        // Set active tick ranges
        var activeFloor = ACTIVE_HOUR_FLOOR * TICKS_PER_HR;
        var activeCeil = ACTIVE_HOUR_CEIL * TICKS_PER_HR;
        // Init vars for each tick
        var innerRad, theta, x1, x2, y1, y2, isMajor, isLarge, isActive, tickColor, tickWidth, isMinTick, isCardinal;
        for (var i = 0; i < NUM_TICKS; i++) {
            // Large ticks every hour
            isLarge = (i % TICKS_PER_HR) == 0;
            // Major ticks every 2 hours
            isMajor = (i % (TICKS_PER_HR * 2)) == 0;
            // Cardinal ticks are in each cardinal direction
            isCardinal = (i % (TICKS_PER_HR * 6)) == 0;
            // Active ticks are near the hand
            isActive = (activeFloor <= i) && (i <= activeCeil);
            // Check if we're on the special minute hand
            isMinTick = i == minTick;

            // Inner draw radius
            if (isActive || isCardinal) {
                innerRad = isLarge ? largeInnerRad : smallInnerRad;
            } else {
                innerRad = inactiveInnerRad;
            }
            // Draw width
            tickWidth = (isLarge or isMinTick) ? LG_TICK_WIDTH : SM_TICK_WIDTH;
            // Set colors
            if (isMinTick) {
                // Special-cased minute "hand" tick overrides
                tickColor = COLOR_MIN;
            } else if (isActive || isMajor) {
                tickColor = isLarge ? COLOR_LG_TICK : COLOR_SM_TICK;
            } else if (isLarge) {
                tickColor = COLOR_LG_TICK_INACTIVE;
            } else {
                tickColor = COLOR_TICK_INACTIVE;
                continue;
            }
            // Angle of individual tick
            theta = RENDER_OFFSET_ANGLE + i * ANGLE_PER_TICK;
            // Round to avoid squigly ticks
            x1 = Math.round(RADIUS + outerRad * Math.cos(theta));
            y1 = Math.round(RADIUS + outerRad * Math.sin(theta));
            x2 = Math.round(RADIUS + innerRad * Math.cos(theta));
            y2 = Math.round(RADIUS + innerRad * Math.sin(theta));
            // Actually draw the ticks
            dc.setColor(tickColor, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(tickWidth);
            dc.drawLine(x1, y1, x2, y2);
        }
    }

    // @deprecated Draw a cross in the center
    function drawCross(dc) {
        dc.setPenWidth(CROSS_WIDTH);
        dc.setColor(COLOR_CROSS, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(RADIUS - CROSS_LEN, RADIUS, RADIUS + CROSS_LEN, RADIUS);
        dc.drawLine(RADIUS, RADIUS - CROSS_LEN, RADIUS, RADIUS + CROSS_LEN);
    }

    // @deprecated Draw hour ticks along the watch
    function drawHours(dc) {
        // Set the draw radius
        var innerRad = DRAW_RADIUS_1;
        // Pre-init any vars used per hour
        var theta, hourVal, hourStr, x, xOffset, y, yOffset, isActive, isCardinal, hourColor;
        for (var i = 0; i < HOURS_PER_DAY; i+=2) {
            isActive = (ACTIVE_HOUR_FLOOR <= i) && (i <= ACTIVE_HOUR_CEIL);
            // "Cardinal" hours are the hours in every cardinal direction
            isCardinal = (i % 6) == 0;

            // Skip non-cardinal/ non-active hours
            if (!(isActive or isCardinal)) { continue; }

            // Set a display valuea of the hour
            if (USE_12_HOUR) {
                hourVal = i % 12;
                if (hourVal == 0) { hourVal = 12; }
            } else {
                hourVal = i;
            }
            hourStr = hourVal.format("%02d");

            hourColor = isCardinal ? COLOR_HOUR_CARDINAL : COLOR_HOUR;
            // Angle of indivudal hours
            theta = RENDER_OFFSET_ANGLE + i * ANGLE_PER_HOUR;
            // Offet of tick + Width of text
            xOffset = (innerRad - TEXT_WIDTH / 2 ) * Math.cos(theta);
            // Offset of height based on angle + Constant height offset
            yOffset = (innerRad - MAGIC_OFFSET) * Math.sin(theta) - TEXT_HEIGHT_OFFSET;

            // Actually draw the text
            x = RADIUS + xOffset;
            y = RADIUS + yOffset;
            dc.setColor(hourColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y, HOUR_FONT, hourStr, HOUR_JUSTIFY);
        }
    }

    // @deprecated Draw a hand pointing to the time
    function drawHand(dc) {
        // Draw the watch hand up to the tick with a little extra
        var outerRad = DRAW_RADIUS_0;
        var x = RADIUS + outerRad * Math.cos(TIME_ANGLE);
        var y = RADIUS + outerRad * Math.sin(TIME_ANGLE);

        dc.setPenWidth(HAND_WIDTH);
        dc.setColor(COLOR_HAND, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(RADIUS, RADIUS, x, y);
        dc.fillCircle(RADIUS, RADIUS, HAND_WIDTH * 2);
    }
}
