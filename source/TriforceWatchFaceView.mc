using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Math as Math;

using Toybox.Time.Gregorian as Date;
using Toybox.Application as App;

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
    var minute_radius;
    var hour_radius;
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
    static const ARC_MAX = 52; //length of the arc for the step indicator
    static const RAD_90_DEG = 1.570796;
    
    function initialize() {
        WatchFace.initialize();
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
        font = Ui.loadResource( Rez.Fonts.fonty );
        
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
        dc.drawBitmap(center_x-farore.getWidth(), center_y-2, nayru);
	    dc.drawBitmap(center_x, center_y-2, farore);
	    dc.drawBitmap(center_x-farore.getWidth()/2, center_y-2-farore.getHeight(), din);
                    
        updateBattery(dc);
        
        var activityInfo = Toybox.ActivityMonitor.getInfo();
        var stepPercent = activityInfo.steps.toFloat()/activityInfo.stepGoal.toFloat();
        drawStepsIndicator(dc, stepPercent);
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
	    	var isPm = hours > 12;
	    	if (isPm) {
	    		hours = hours - 12;
	    		amPm = "pm";
	    	}
	    	dc.drawText(center_x + dc.getTextDimensions(min, Gfx.FONT_SMALL)[0]+5, center_y/4-2, Gfx.FONT_SYSTEM_TINY, amPm, Gfx.TEXT_JUSTIFY_LEFT);
	    }
	    dc.drawText(center_x-5, center_y/4, Gfx.FONT_SMALL, hours, Gfx.TEXT_JUSTIFY_RIGHT);
	    dc.drawText(center_x, center_y/4, Gfx.FONT_SMALL, ":", Gfx.TEXT_JUSTIFY_CENTER);
	    dc.drawText(center_x+5, center_y/4, Gfx.FONT_SMALL, min, Gfx.TEXT_JUSTIFY_LEFT);
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
    
    function updateBattery(dc) {
        var battery = Sys.getSystemStats().battery;
        var position_x = center_x-36;
    	//var batteryDisplay = View.findDrawableById("BatteryDisplay");  
    
    	if (battery <= 100 and battery > 90) { //5 hearts
    		dc.drawBitmap(position_x, 5, fivehearts);
    		if (battery > 90 and battery <= 95) {
    			dc.drawBitmap(position_x+61, 5, threeQuarterHeart);
    		}
        }
        else if (battery > 80 and battery <= 90) { //4.5 hearts
            dc.drawBitmap(position_x, 5, four5hearts);
            if (battery > 80 and battery <= 85) {
            	dc.drawBitmap(position_x+61, 5, quarterHeart);
            }
        }
        else if (battery > 70 and battery <= 80) { //4 hearts
    		dc.drawBitmap(position_x, 5, fourhearts);
    		if (battery > 70 and battery <= 75) {
    			dc.drawBitmap(position_x+46, 5, threeQuarterHeart);
    		}
        }
        else if (battery > 60 and battery <= 70) { //3.5 hearts
    		dc.drawBitmap(position_x, 5, three5hearts);
    		if (battery > 60 and battery <= 65) {
    			dc.drawBitmap(position_x+46, 5, quarterHeart);
    		}
        }
        else if (battery > 50 and battery <= 60) { //3 hearts
    		dc.drawBitmap(position_x, 5, threehearts);
    		if (battery > 50 and battery <= 55) {
    			dc.drawBitmap(position_x+30, 5, threeQuarterHeart);
    		}
        }
        else if (battery > 40 and battery <= 50) { //2.5 hearts
    		dc.drawBitmap(position_x, 5, two5hearts);
    		if (battery > 40 and battery <= 45) {
    			dc.drawBitmap(position_x+30, 5, quarterHeart);
    		}
        }
        else if (battery > 30 and battery <= 40) { //2 hearts
    		dc.drawBitmap(position_x, 5, twohearts);
    		if (battery > 30 and battery <= 35) {
    			dc.drawBitmap(position_x+15, 5, threeQuarterHeart);
    		}
        }
        else if (battery > 20 and battery <= 30) { //1.5 hearts
    		dc.drawBitmap(position_x, 5, one5hearts);
    		if (battery > 20 and battery <= 25) {
    			dc.drawBitmap(position_x+15, 5, quarterHeart);
    		}
        }
        else if (battery > 10 and battery <= 20) { //1 heart
    		dc.drawBitmap(position_x, 5, onehearts);
    		if (battery > 10 and battery <= 15) { //3/4 heart
        		dc.drawBitmap(position_x-1, 5, threeQuarterHeart);
        	} 	
        }
        else if (battery > 0 and battery <= 10) { //.5 hearts
            dc.drawBitmap(position_x, 5, zero5hearts);
        	if (battery > 0 and battery <= 5) { //1/4 heart
        		dc.drawBitmap(position_x-1, 5, quarterHeart);
        	}	
        }
    }
    
    private function setDateDisplay(dc) {        
    	var now = Time.now();
	    var date = Date.info(now, Time.FORMAT_LONG);
	    var dateString = Lang.format("$1$ $2$ $3$", [date.day_of_week, date.month, date.day]);
	    
	    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
	    dc.drawText(center_x+14, center_y-45, font, dateString, Gfx.TEXT_JUSTIFY_LEFT);
    }
    
    private function setBatteryDisplay() {
    	var battery = Sys.getSystemStats().battery;
    	var batteryDisplay = View.findDrawableById("BatteryDisplay"); 	
	    batteryDisplay.setText(battery.format("%d")+"%");	
    }
    
    private function setStepCountDisplay(dc) {
    	var stepCount = Mon.getInfo().steps.toString();		
	    dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
	    var textDim = dc.getTextDimensions(stepCount,font);
	    dc.drawText(center_x-farore.getWidth()/2, center_y+50, font, stepCount, Gfx.TEXT_JUSTIFY_CENTER);
	    dc.drawBitmap((center_x-farore.getWidth()/2)-textDim[0]/2-steps.getWidth()-2, center_y+50, steps);
    }
    
    private function setStairCountDisplay(dc) {
    	var stairCount = Mon.getInfo().floorsClimbed.toString();
    	dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
    	dc.drawText(center_x, center_y+1, font, stairCount, Gfx.TEXT_JUSTIFY_LEFT);
    	dc.drawBitmap(center_x-16, center_y-1, stairs);
    }
    
    private function setActivityMinDisplay(dc) {
    	var actMin = Mon.getInfo().activeMinutesWeek.total.toString();
    	dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_TRANSPARENT);
    	dc.drawText(center_x+farore.getWidth()/2, center_y+50, font, actMin, Gfx.TEXT_JUSTIFY_CENTER);
    }
    
    private function setNotificationDisplay(dc, phoneConnected, notificationCount) {
    	var notifications = "0";
    	if (phoneConnected && notificationCount > 0) {
    		dc.drawBitmap(center_x/4+2, center_y-55, navi);
    	}
    	else {
    		dc.drawBitmap(center_x/4+2, center_y-55, darknavi);
    	}
    	dc.drawText(center_x/4+darknavi.getWidth()+2, center_y-45, font, notificationCount, Gfx.TEXT_JUSTIFY_LEFT);
    }
    
    function drawStepsIndicator(dc, stepPercent) {
        var fillPercent = stepPercent;
        var borderColor = Gfx.COLOR_WHITE;
        var fillColor = Gfx.COLOR_GREEN;
       
        //don't let the percentage completely exceed 100%
        if (fillPercent > 1.0) {
           fillPercent = 1.0;
        }
        //var x = $.gDeviceSettings.screenWidth/2;
        //var y = $.gDeviceSettings.screenHeight/2;
        var r = center_x-1;
        // erase the background (if any)
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.setPenWidth(5);
        dc.drawArc(center_x, center_y, r-3, Gfx.ARC_CLOCKWISE, 207, 153);

        if (fillPercent > 0) {
            var arcSize = fillPercent*ARC_MAX;
            // only show a completed step bar if we've reached our goal
            if (arcSize > ARC_MAX-1 && arcSize != ARC_MAX && fillPercent != 1.0) {
                arcSize = ARC_MAX-1;
            } else if (arcSize <= 0.51) {
                arcSize = 1;
            }
            dc.setColor(fillColor, Gfx.COLOR_TRANSPARENT);
            dc.setPenWidth(5);
            dc.drawArc(center_x, center_y, r-3, Gfx.ARC_CLOCKWISE, 206, 206-arcSize);
        }
        dc.setColor(borderColor, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        // draw the outer and inner arc borders
        dc.drawArc(center_x, center_y, r, Gfx.ARC_CLOCKWISE, 207, 153);
        dc.drawArc(center_x, center_y, r-5, Gfx.ARC_CLOCKWISE, 207, 153);
        // draw the top and bottom borders
        for (var i=0; i < 5; i++) {
            dc.drawArc(center_x, center_y, r-i, Gfx.ARC_CLOCKWISE, 154, 153);
            dc.drawArc(center_x, center_y, r-i, Gfx.ARC_CLOCKWISE, 207, 206);
        }
    }
    
        // draw the move indicator (if required)
    function drawMoveWarning(dc) {
        var moveBarLevel = Toybox.ActivityMonitor.getInfo().moveBarLevel;
        // if the move bar level is above the minimum then display the indicator...
        if (moveBarLevel > Toybox.ActivityMonitor.MOVE_BAR_LEVEL_MIN) {
            dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_TRANSPARENT);

            //var x = $.gDeviceSettings.screenWidth/2;
            //var y = $.gDeviceSettings.screenHeight/2;
            var r = center_x-5;
            dc.setPenWidth(5);
            for (var i=1; i < moveBarLevel; i++) {
                dc.drawArc(center_x, center_y, center_x-3, Gfx.ARC_COUNTER_CLOCKWISE, 3+i*5, 6+i*5);
            }
            dc.drawArc(center_x, center_y, center_x-3, Gfx.ARC_COUNTER_CLOCKWISE, 333, 351);
            dc.setPenWidth(1);
        }
    }
}