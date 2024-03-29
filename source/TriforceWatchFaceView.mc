using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Math as Math;

using Toybox.Time.Gregorian as Date;
using Toybox.Application as App;
using Toybox.SensorHistory;

using Toybox.ActivityMonitor as Mon;

class TriforceWatchFaceView extends Ui.WatchFace {

    var background;
    var zerohearts;
    var onehearts;
    var twohearts;
    var threehearts;
    var fourhearts;
    var fivehearts;
    var zero5hearts;
    var one5hearts;
    var two5hearts;
    var three5hearts;
    var four5hearts;
    var center_x;
    var center_y;
    var quarterHeart;
    var threeQuarterHeart;
    var nayru;
    var farore;
    var din;
    var font;
    var steps;
    var stairs;
    var navi;
    var darknavi;
    var emptyTriforce;
    var filledTriforce;
    var useBodyBattery;
    var batteryIcon;
    static const ARC_MAX = 45; //length of the arc for the step indicator
    
    function initialize() {
        WatchFace.initialize();

        if (App has :Storage) {
            if (App.Properties.getValue("UseBodyBattery") == null) {
                App.Properties.setValue("UseBodyBattery", false);
                useBodyBattery = false;
            } else {
                System.println(App.Properties.getValue("UseBodyBattery"));
                useBodyBattery = App.Properties.getValue("UseBodyBattery");
            }
        } else {
            var app = App.getApp();
            if (app.getProperty("UseBodyBattery") == null) {
                app.setProperty("UseBodyBattery", false);
                useBodyBattery = false;
            } else {
                useBodyBattery = app.getProperty("UseBodyBattery");
            }
        }
        
        //useBodyBattery = app.getProperty("UseBodyBattery") == null ? false : app.getProperty("UseBodyBattery");
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    
        background = Ui.loadResource(Rez.Drawables.myBackground);
        zerohearts = Ui.loadResource(Rez.Drawables.zeroheart);
        onehearts = Ui.loadResource(Rez.Drawables.oneheart);
        twohearts = Ui.loadResource(Rez.Drawables.twoheart);
        threehearts = Ui.loadResource(Rez.Drawables.threeheart);
        fourhearts = Ui.loadResource(Rez.Drawables.fourheart);
        fivehearts = Ui.loadResource(Rez.Drawables.fiveheart);
        zero5hearts = Ui.loadResource(Rez.Drawables.zero5heart);
        one5hearts = Ui.loadResource(Rez.Drawables.one5heart);
        two5hearts = Ui.loadResource(Rez.Drawables.two5heart);
        three5hearts = Ui.loadResource(Rez.Drawables.three5heart);
        four5hearts = Ui.loadResource(Rez.Drawables.four5heart);
        quarterHeart = Ui.loadResource(Rez.Drawables.quarterHeart);
        threeQuarterHeart = Ui.loadResource(Rez.Drawables.threeQuarterHeart);
        nayru = Ui.loadResource(Rez.Drawables.nayru);
        din = Ui.loadResource(Rez.Drawables.din);
        farore = Ui.loadResource(Rez.Drawables.farore);
        steps = Ui.loadResource(Rez.Drawables.steps);
        stairs = Ui.loadResource(Rez.Drawables.stairs);
        navi = Ui.loadResource(Rez.Drawables.navi);
        darknavi = Ui.loadResource(Rez.Drawables.darkNavi);
        emptyTriforce = Ui.loadResource(Rez.Drawables.emptyTriforce);
        font = Ui.loadResource( Rez.Fonts.fonty );
        filledTriforce = Ui.loadResource(Rez.Drawables.filledTriangle);
        batteryIcon = Ui.loadResource(Rez.Drawables.battery);
        
        center_x = dc.getWidth()/2;
        center_y = dc.getHeight()/2;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        //dc.drawBitmap(0,0, background);
        var now = Sys.getClockTime();
        
        var settings = Sys.getDeviceSettings();
        
	    //setBatteryDisplay();
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        dc.drawBitmap(center_x-farore.getWidth(), center_y+5, nayru);
	    dc.drawBitmap(center_x, center_y+5, farore);
	    dc.drawBitmap(center_x-farore.getWidth()/2, center_y+5-farore.getHeight(), din);
                         
        var activityInfo = Toybox.ActivityMonitor.getInfo();
        updateBattery(dc, activityInfo);
        drawStepsIndicator(dc, activityInfo);
        drawMoveWarning(dc);
        setStepCountDisplay(dc);
        setStairCountDisplay(dc);
        setActivityMinDisplay(dc);
        setDateDisplay(dc);
        drawTime(dc, now, settings.is24Hour);
        setNotificationDisplay(dc, settings.phoneConnected, settings.notificationCount);
    }
    
    function drawTime(dc, clockTime, is24hour) {
        var hours = clockTime.hour;
        var min = clockTime.min.format("%02d");

        // draw the minute hand
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        if (!is24hour) {
        	var amPm = "am";
	    	var isPm = hours >= 12;
	    	if (isPm) {
                if (hours != 12) {
	    		    hours = hours - 12;
                }
	    		amPm = "pm";
	    	}
            var textDim = dc.getTextDimensions(min, Gfx.FONT_MEDIUM) as Lang.Array<Lang.Number>;
	    	dc.drawText(center_x + textDim[0]+6, center_y-81, Gfx.FONT_SYSTEM_TINY, amPm, Gfx.TEXT_JUSTIFY_LEFT);
	    }
	    dc.drawText(center_x-5, center_y-80, Gfx.FONT_MEDIUM, hours, Gfx.TEXT_JUSTIFY_RIGHT);
	    dc.drawText(center_x, center_y-80, Gfx.FONT_MEDIUM, ":", Gfx.TEXT_JUSTIFY_CENTER);
	    dc.drawText(center_x+5, center_y-80, Gfx.FONT_MEDIUM, min, Gfx.TEXT_JUSTIFY_LEFT);
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
    
    function updateBattery(dc, activityInfo) {
        var battery = Sys.getSystemStats().battery;
        if (useBodyBattery) {
            if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory)) {
                var batStr = Lang.format("$1$%", [battery.format("%2d")]);
                var batPosition = center_y+(center_y*.65);
                dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
                dc.drawBitmap(center_x-batteryIcon.getWidth(), batPosition, batteryIcon);
                dc.drawText(center_x+5, batPosition-1, font, batStr, Gfx.TEXT_JUSTIFY_LEFT);
                var bodyBatt = Toybox.SensorHistory.getBodyBatteryHistory({:period=>1});
                bodyBatt = bodyBatt.next();

                if (bodyBatt != null) {
                    battery = bodyBatt.data;
                }
            }
        }
        var position_x = center_x-36;
        var position_y = center_y/20+5;
    	//var batteryDisplay = View.findDrawableById("BatteryDisplay");  
    
    	if (battery <= 100 and battery > 90) { //5 hearts
    		dc.drawBitmap(position_x, position_y, fivehearts);
    		if (battery > 90 and battery <= 95) {
    			dc.drawBitmap(position_x+61, position_y, threeQuarterHeart);
    		}
        }
        else if (battery > 80 and battery <= 90) { //4.5 hearts
            dc.drawBitmap(position_x, position_y, four5hearts);
            if (battery > 80 and battery <= 85) {
            	dc.drawBitmap(position_x+61, position_y, quarterHeart);
            }
        }
        else if (battery > 70 and battery <= 80) { //4 hearts
    		dc.drawBitmap(position_x, position_y, fourhearts);
    		if (battery > 70 and battery <= 75) {
    			dc.drawBitmap(position_x+46, position_y, threeQuarterHeart);
    		}
        }
        else if (battery > 60 and battery <= 70) { //3.5 hearts
    		dc.drawBitmap(position_x, position_y, three5hearts);
    		if (battery > 60 and battery <= 65) {
    			dc.drawBitmap(position_x+46, position_y, quarterHeart);
    		}
        }
        else if (battery > 50 and battery <= 60) { //3 hearts
    		dc.drawBitmap(position_x, position_y, threehearts);
    		if (battery > 50 and battery <= 55) {
    			dc.drawBitmap(position_x+30, position_y, threeQuarterHeart);
    		}
        }
        else if (battery > 40 and battery <= 50) { //2.5 hearts
    		dc.drawBitmap(position_x, position_y, two5hearts);
    		if (battery > 40 and battery <= 45) {
    			dc.drawBitmap(position_x+30, position_y, quarterHeart);
    		}
        }
        else if (battery > 30 and battery <= 40) { //2 hearts
    		dc.drawBitmap(position_x, position_y, twohearts);
    		if (battery > 30 and battery <= 35) {
    			dc.drawBitmap(position_x+15, position_y, threeQuarterHeart);
    		}
        }
        else if (battery > 20 and battery <= 30) { //1.5 hearts
    		dc.drawBitmap(position_x, position_y, one5hearts);
    		if (battery > 20 and battery <= 25) {
    			dc.drawBitmap(position_x+15, position_y, quarterHeart);
    		}
        }
        else if (battery > 10 and battery <= 20) { //1 heart
    		dc.drawBitmap(position_x, position_y, onehearts);
    		if (battery > 10 and battery <= 15) { //3/4 heart
        		dc.drawBitmap(position_x-1, position_y, threeQuarterHeart);
        	} 	
        }
        else if (battery > 0 and battery <= 10) { //.5 hearts
            dc.drawBitmap(position_x, position_y, zero5hearts);
        	if (battery > 0 and battery <= 5) { //1/4 heart
        		dc.drawBitmap(position_x-1, position_y, quarterHeart);
        	}	
        }
    }
    
    private function setDateDisplay(dc) {        
    	var now = Time.now();
	    var date = Date.info(now, Time.FORMAT_LONG);
	    var dateString = Lang.format("$1$ $2$ $3$", [date.day_of_week, date.month, date.day]);
	    
	    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
	    dc.drawText(center_x+18, center_y-35, font, dateString, Gfx.TEXT_JUSTIFY_LEFT);
    }
    
    private function setStepCountDisplay(dc) {
    	var stepCount = Mon.getInfo().steps.toString();		
	    dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
	    var textDim = dc.getTextDimensions(stepCount,font) as Lang.Array<Lang.Number>;
	    dc.drawText(center_x-farore.getWidth()/2, center_y+55, font, stepCount, Gfx.TEXT_JUSTIFY_CENTER);
	    dc.drawBitmap((center_x-farore.getWidth()/2)-textDim[0]/2-steps.getWidth()-2, center_y+55, steps);
    }
    
    private function setStairCountDisplay(dc) {
    	var stairCount = Mon.getInfo().floorsClimbed.toString();
    	dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_TRANSPARENT);
    	dc.drawText(center_x+1, center_y+6, font, stairCount, Gfx.TEXT_JUSTIFY_LEFT);
    	dc.drawBitmap(center_x-16, center_y+6, stairs);
    }
    
    private function setActivityMinDisplay(dc) {
    	var actMin = Mon.getInfo().activeMinutesWeek.total.toString();
    	dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_TRANSPARENT);
    	dc.drawText(center_x+farore.getWidth()/2, center_y+55, font, actMin, Gfx.TEXT_JUSTIFY_CENTER);
    }
    
    private function setNotificationDisplay(dc, phoneConnected, notificationCount) {
    	var notifications = "0";
    	if (phoneConnected && notificationCount > 0) {
    		dc.drawBitmap(center_x/4+2, center_y-45, navi);
    	}
    	else {
    		dc.drawBitmap(center_x/4+2, center_y-45, darknavi);
    	}
    	dc.drawText(center_x/4+darknavi.getWidth()+2, center_y-35, font, notificationCount, Gfx.TEXT_JUSTIFY_LEFT);
    }
    
    function drawStepsIndicator(dc, activityInfo) {
        var stepPercent = activityInfo.steps.toFloat()/activityInfo.stepGoal.toFloat();
        var fillPercent = stepPercent;
        var borderColor = Gfx.COLOR_WHITE;
        var fillColor = Gfx.COLOR_BLUE;
       
        //don't let the percentage completely exceed 100%
        if (fillPercent > 1.0) {
           fillPercent = 1.0;
           dc.drawBitmap(center_x-farore.getWidth(), center_y+5, filledTriforce);
        }

        var r = center_x-2;
        // erase the background (if any)
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.setPenWidth(5);
        dc.drawArc(center_x, center_y, r-3, Gfx.ARC_COUNTER_CLOCKWISE, 170, 8);

        if (fillPercent > 0) {
            var arcSize = fillPercent*ARC_MAX;
            // only show a completed step bar if we've reached our goal
            if (arcSize > ARC_MAX-1 && arcSize != ARC_MAX && fillPercent != 1.0) {
                arcSize = ARC_MAX-1;
            } else if (arcSize <= 1) {
                arcSize = 1;
            }
            dc.setColor(fillColor, Gfx.COLOR_TRANSPARENT);
            dc.setPenWidth(5);
            dc.drawArc(center_x, center_y, r-3, Gfx.ARC_COUNTER_CLOCKWISE, 176, 176+arcSize);
        }
        dc.setColor(borderColor, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        // draw the outer and inner arc borders
        dc.drawArc(center_x, center_y, r, Gfx.ARC_CLOCKWISE, 175+ARC_MAX, 175);
        // draw the top and bottom borders
        for (var i=0; i < 6; i++) {
            dc.drawArc(center_x, center_y, r-i, Gfx.ARC_CLOCKWISE, 176, 175);
            dc.drawArc(center_x, center_y, r-i, Gfx.ARC_CLOCKWISE, 221, 220);
        }
        
        var activityPercent = activityInfo.activeMinutesWeek.total.toFloat()/activityInfo.activeMinutesWeekGoal.toFloat();
        fillPercent = activityPercent;
        borderColor = Gfx.COLOR_WHITE;
        fillColor = Gfx.COLOR_DK_GREEN;
       
        //don't let the percentage completely exceed 100%
        if (fillPercent > 1.0) {
           fillPercent = 1.0;
           dc.drawBitmap(center_x, center_y+5, filledTriforce);
        }

        // erase the background (if any)
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.setPenWidth(5);
        //dc.drawArc(center_x, center_y, r-3, Gfx.ARC_COUNTER_CLOCKWISE, 170, 207);

        if (fillPercent > 0) {
            var arcSize = fillPercent*ARC_MAX;
            // only show a completed step bar if we've reached our goal
            if (arcSize > ARC_MAX-1 && arcSize != ARC_MAX && fillPercent != 1.0) {
                arcSize = ARC_MAX-1;
            } else if (arcSize <= 1) {
                arcSize = 1;
            }
            dc.setColor(fillColor, Gfx.COLOR_TRANSPARENT);
            dc.setPenWidth(5);
            dc.drawArc(center_x, center_y, r-3, Gfx.ARC_COUNTER_CLOCKWISE, 319, 320+arcSize);
        }
        dc.setColor(borderColor, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        // draw the outer and inner arc borders
        dc.drawArc(center_x, center_y, r, Gfx.ARC_CLOCKWISE, 319+ARC_MAX, 319);
        // draw the top and bottom borders
        for (var i=0; i < 6; i++) {
            dc.drawArc(center_x, center_y, r-i, Gfx.ARC_CLOCKWISE, 320, 319);
            dc.drawArc(center_x, center_y, r-i, Gfx.ARC_CLOCKWISE, 5, 4);
        }
        
        var stairPercent = activityInfo.floorsClimbed.toFloat()/activityInfo.floorsClimbedGoal.toFloat();
        fillPercent = stairPercent;
        borderColor = Gfx.COLOR_WHITE;
        fillColor = Gfx.COLOR_DK_RED;
       
        //don't let the percentage completely exceed 100%
        if (fillPercent > 1.0) {
           fillPercent = 1.0;
           dc.drawBitmap(center_x-farore.getWidth()/2, center_y+5-farore.getHeight(), filledTriforce);
        }

		var arcMax = 75;
        if (fillPercent > 0) {
            var arcSize = fillPercent*arcMax;
            // only show a completed step bar if we've reached our goal
            if (arcSize > arcMax-1 && arcSize != arcMax && fillPercent != 1.0) {
                arcSize = arcMax-1;
            } else if (arcSize <= 1) {
                arcSize = 1;
            }
            dc.setColor(fillColor, Gfx.COLOR_TRANSPARENT);
            dc.setPenWidth(5);
            dc.drawArc(center_x, center_y, r-3, Gfx.ARC_COUNTER_CLOCKWISE, 232, 232+arcSize);
        }
        dc.setColor(borderColor, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        // draw the outer and inner arc borders
        dc.drawArc(center_x, center_y, r, Gfx.ARC_CLOCKWISE, 232+arcMax, 232);
        // draw the top and bottom borders
        for (var i=0; i < 6; i++) {
            dc.drawArc(center_x, center_y, r-i, Gfx.ARC_CLOCKWISE, 233, 232);
            dc.drawArc(center_x, center_y, r-i, Gfx.ARC_CLOCKWISE, 308, 307);
        }
    }
    
        // draw the move indicator (if required)
    function drawMoveWarning(dc) {
        var moveBarLevel = Toybox.ActivityMonitor.getInfo().moveBarLevel;
        // if the move bar level is above the minimum then display the indicator...
        if (moveBarLevel > Toybox.ActivityMonitor.MOVE_BAR_LEVEL_MIN) {
        	dc.drawBitmap(center_x-farore.getWidth()/2, center_y+5-farore.getHeight(), emptyTriforce);
        	if (moveBarLevel > Toybox.ActivityMonitor.MOVE_BAR_LEVEL_MAX/2) {
            	dc.drawBitmap(center_x-farore.getWidth(), center_y+5, emptyTriforce);
            	if (moveBarLevel >= Toybox.ActivityMonitor.MOVE_BAR_LEVEL_MAX) {
	    			dc.drawBitmap(center_x, center_y+5, emptyTriforce);
	    		}
	    	}	
        }
    }
}