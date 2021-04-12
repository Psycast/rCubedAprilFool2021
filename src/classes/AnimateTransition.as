package classes
{
    import flash.display.Stage;
    import flash.display.Sprite;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.geom.Rectangle;
    import flash.geom.Point;
    import flash.events.Event;
    import flash.utils.getTimer;

    public class AnimateTransition extends Sprite
    {
        public var DT:Number;
        public var DATA:Vector.<AnimateTile>;
        public var TIMER_PAUSED:Boolean = false;

        public function AnimateTransition(cstage:Stage):void
        {
            this.mouseEnabled = false;
            this.mouseChildren = false;

            if (cstage)
            {
                DT = getTimer();

                DATA = new Vector.<AnimateTile>();

                cstage.addChildAt(this, 1);

                var fullRaw:BitmapData = new BitmapData(780, 480, false, 0);
                fullRaw.draw(cstage);

                var drawPoint:Point = new Point(0, 0);

                for (var gx:int = 0; gx < 26; gx++)
                {
                    for (var gy:int = 0; gy < 16; gy++)
                    {
                        var cellData:BitmapData = new BitmapData(30, 30);
                        var cellBM:Bitmap = new Bitmap(cellData);

                        cellData.copyPixels(fullRaw, new Rectangle(gx * 30, gy * 30, 30, 30), drawPoint);

                        var cellAnimate:AnimateTile = new AnimateTile(cellBM, 15 + gx * 15 + gy * 15, DATA);
                        cellAnimate.x = gx * 30 + 15;
                        cellAnimate.y = gy * 30 + 15;
                        addChild(cellAnimate);
                        DATA.push(cellAnimate);
                    }
                }
                cstage.addEventListener(Event.ENTER_FRAME, e_onEnterFrame, false, int.MAX_VALUE - 5, true);
            }
        }

        public function pause():void
        {
            TIMER_PAUSED = true;
            this.visible = false;
        }

        public function resume():void
        {
            TIMER_PAUSED = false;
            this.visible = true;
        }

        public function remove():void
        {
            if (DATA.length > 0)
            {
                for each (var cell:AnimateTile in DATA)
                {
                    cell.remove();
                }
                DATA = null;
                stage.removeEventListener(Event.ENTER_FRAME, e_onEnterFrame);
                stage.removeChild(this);
            }
        }

        public function e_onEnterFrame(e:Event):void
        {
            var NDT:Number = getTimer();
            var CDT:Number = NDT - DT;

            if (!TIMER_PAUSED)
            {
                for each (var cell:AnimateTile in DATA)
                {
                    cell.update(CDT);
                }
            }

            DT = NDT;

            if (DATA.length <= 0)
            {
                stage.removeEventListener(Event.ENTER_FRAME, e_onEnterFrame);
                stage.removeChild(this);
            }
        }
    }
}

import flash.display.Bitmap;
import flash.display.Sprite;

internal class AnimateTile extends Sprite
{
    private var DATA:Vector.<AnimateTile>;
    public var BPM:Bitmap;
    public var DELAY:Number = 0;
    public var TIME:Number = 0;
    public var SPEED:Number = 1000;

    public function AnimateTile(bpm:Bitmap, delay:Number, data:Vector.<AnimateTile>)
    {
        this.BPM = bpm;
        this.BPM.x = -15;
        this.BPM.y = -15;
        addChild(BPM);

        this.DELAY = delay;
        this.DATA = data;
    }

    public function update(delta:Number):void
    {
        if (this.DELAY > 0)
            this.DELAY -= delta;
        else
        {
            TIME += delta;

            var ratio:Number = TIME / SPEED;
            if (ratio < 0)
                ratio = 0;
            if (ratio > 1)
                ratio = 1;

            var easration:Number = (-(Math.cos(Math.PI * ratio) - 1) / 2);

            this.alpha = 1 - easration;
            this.rotation = 125 * easration;
            this.scaleX = this.scaleY = 1 - easration;

            if (TIME > SPEED)
            {
                DATA.removeAt(DATA.indexOf(this));
                this.parent.removeChild(this);
            }
        }
    }

    public function remove():void
    {
        this.removeChild(BPM);
        BPM = null;
        this.parent.removeChild(this);
    }
}
