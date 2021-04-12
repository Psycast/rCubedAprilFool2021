package menu.title
{
    import flash.display.Sprite;
    import menu.MenuSongSelection;
    import classes.DeltaTimeline;
    import af.assets.TitleAnimation;
    import af.assets.MenuSplashMusic;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.utils.getTimer;
    import scripts.IScriptTickable;
    import flash.media.SoundChannel;
    import scripts.darkmatter.BasicTween;
    import af.assets.TitleBackground;
    import com.flashfla.utils.SystemUtil;
    import flash.ui.Mouse;

    public class TitleSplash extends Sprite
    {
        public var selection:MenuSongSelection;

        public var bg:Sprite;

        public var music:SoundChannel;

        public var title_animation:TitleAnimation;

        public var tickables:Array = [];

        private var timeline:DeltaTimeline;
        private var lastTimer:Number;
        private var data:Array;

        public function TitleSplash(par:MenuSongSelection):void
        {
            Mouse.hide();

            par.addChild(this);

            selection = par;

            this.graphics.beginFill(0, 1);
            this.graphics.drawRect(0, 0, 780, 480);
            this.graphics.endFill();

            bg = new TitleBackground();
            bg.alpha = 0;
            addChild(bg);

            timeline = new DeltaTimeline(this);
            timeline.TLPlay(seqData);

            stage.addEventListener(KeyboardEvent.KEY_DOWN, e_keyDown, false, 15);
            stage.addEventListener(Event.ENTER_FRAME, e_enterFrame);

            lastTimer = getTimer();
        }

        public function dispose():void
        {
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, e_keyDown);
            stage.removeEventListener(Event.ENTER_FRAME, e_enterFrame);
            this.removeChild(bg);
            this.removeChild(title_animation);
            timeline = null;
            tickables = null;
            music.stop();
        }

        private function e_keyDown(e:KeyboardEvent):void
        {
            e.stopImmediatePropagation();
        }

        private function e_enterFrame(e:Event):void
        {
            // Understand Delta
            var curTimer:int = getTimer();
            var delta:Number = (curTimer - lastTimer) / (1000 / 60);
            var eclipsed:Number = (curTimer - lastTimer) / 1000;
            lastTimer = curTimer;

            // Update
            for each (var tickable:IScriptTickable in tickables)
                tickable.update(delta, eclipsed);

            // Delete
            var desTickable:IScriptTickable;
            if (tickables.length > 0)
            {
                for (var i:int = 0; i < tickables.length; i++)
                {
                    desTickable = tickables[i];
                    if (desTickable.canDestroy())
                    {
                        desTickable.destroy();
                        tickables.splice(i, 1);
                        i--;
                    }
                }
            }

            // Add
            timeline.TLTick(delta, eclipsed);
        }

        public function Text(msg:String, xpo:Number, ypo:Number, fontSize:Number = 12, holdTime:Number = 3, align:String = "left"):void
        {
            tickables[tickables.length] = new AnimationTitleText(this, msg, xpo, ypo, fontSize, holdTime, align);
        }

        public function StartHype():void
        {
            music = new MenuSplashMusic().play(0);
        }

        public function StartAnimation():void
        {
            title_animation = new TitleAnimation();
            title_animation.x = 202;
            title_animation.y = 230;
            title_animation.gotoAndStop(1);
            this.addChild(title_animation);
            tickables[tickables.length] = new AnimationSyncTickable(title_animation);
            //tickables[tickables.length] = new AnimationBeatTickable(title_animation);
        }

        public function FadeBackground(len:Number, ease:String):void
        {
            tickables[tickables.length] = new BasicTween(bg, "alpha", len, 0, 1, ease);
        }

        public function MoveTitle(len:Number, prop:String, change:Number, ease:String):void
        {
            tickables[tickables.length] = new BasicTween(title_animation, prop, len, title_animation[prop], title_animation[prop] + change, ease);
        }

        public function DoTransition():void
        {
            GlobalVariables.instance.gameMain.beginTransition();
            dispose();
            selection.startIntroCutscene();
            this.parent.removeChild(this);
            SystemUtil.gc();
        }

        //public var seqData:Array = [[3, "DoTransition"]];

        public var seqData:Array = [[0, "StartHype"],
            [2, "FadeBackground", 12, "outSine"],
            [0, "Text", "Created By:", 20, 380, 24, 4],
            [0.5, "Text", "Velocity", 20, 410, 40, 4],
            [5.5, "Text", "With great assistance from:", 20, 380, 24, 4],
            [0.5, "Text", "gold stinger", 20, 410, 30, 4],
            [7.399, "StartAnimation"],
            [5, "Text", "-- April 1st 2021 --", 20, 385, 32, 5, "center"],
            [7, "MoveTitle", 1.5, "y", -50, "outSine"],
            [0, "Text", "Featuring content from:", 20, 380, 24, 18.5],
            [1, "Text", "gold stinger", 20, 410, 30, 4, "left"],
            [0.5, "Text", "Halogen-", 20, 410, 30, 4, "center"],
            [0.5, "Text", "CosmoVibe", 20, 410, 30, 4, "right"],
            [5.5, "Text", "hi19hi19", 20, 410, 30, 4, "left"],
            [0.5, "Text", "DarkZtar", 20, 410, 30, 4, "center"],
            [0.5, "Text", "Puuro", 20, 410, 30, 4, "right"],
            [5.5, "Text", "Shoegazer", 20, 410, 30, 4, "left"],
            [0.5, "Text", "vinh_", 20, 410, 30, 4, "center"],
            [0.5, "Text", "Fullerene-", 20, 410, 30, 4, "right"],
            [5, "MoveTitle", 1.5, "y", 50, "outSine"],
            [5, "DoTransition"]];
    }
}
