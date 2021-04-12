package scripts
{
    import classes.chart.ILevelScript;
    import classes.chart.ILevelScriptRuntime;
    import game.controls.NoteBox;
    import game.GamePlay;
    import classes.DeltaTimeline;
    import flash.utils.getTimer;
    import flash.geom.Point;
    import flash.display.MovieClip;
    import scripts.darkmatter.BasicTween;
    import scripts.darkmatter.EffectPulse;
    import scripts.darkmatter.DarkMatterTimeline;
    import flash.display.Sprite;
    import flash.filters.DisplacementMapFilter;
    import flash.display.BitmapDataChannel;
    import flash.filters.DisplacementMapFilterMode;
    import flash.display.BitmapData;
    import af.assets.DMDisplaceWall;
    import af.assets.DMDisplaceCorrupt;
    import scripts.darkmatter.EffectFlashbang;
    import af.assets.DMDisplaceShift;
    import scripts.darkmatter.FilterTween;
    import flash.display.Bitmap;
    import af.assets.DM.Wall;
    import scripts.darkmatter.CharKarhisLogic;

    public class DarkMatterScript implements ILevelScript
    {
        private var runtime:ILevelScriptRuntime;

        private var receptorLocations:Object = {"L": new Point(-90, 0),
                "D": new Point(-30, 0),
                "U": new Point(30, 0),
                "R": new Point(90, 0)};

        private var receptorMoveScale:Object = {"L": -2,
                "D": -1,
                "U": 1,
                "R": 2};

        private var mainX:Number = 160;
        private var mainY:Number = 90;

        private var receptors:Vector.<MovieClip>;
        private var receptorCount:int = 0;

        public var gp:GamePlay;
        public var nb:NoteBox;

        public var noteBoxContainerMask:Sprite;
        public var LAST_DM_FILTER:DisplacementMapFilter;

        public var lastTimer:int = 0;
        private var timeline:DeltaTimeline;
        public var tickables:Array = [];


        public var offset:Number = 0;
        public var rot:Number = 0;
        private var centerGlobal:Point;

        private var karhis:CharKarhisLogic;
        private var wallLeft:Bitmap;
        private var wallRight:Bitmap;

        ////////////////////////////////////////////////////////////////////////////////////////////////////
        public function init(runtime:ILevelScriptRuntime):void
        {
            this.runtime = runtime;
            this.gp = runtime.getGameplay();

            // Set Gameplay Variables
            this.gp.disablePause = true;
            this.gp.disableRestart = true;
            this.gp.options.scrollSpeed = 2;
            this.gp.options.scrollDirection = "up";
            this.gp.options.noteskin = 1;
            this.gp.options.noteScale = 0.7;
            this.gp.options.receptorSplitSpacing = 0;
            this.gp.options.receptorSpacing = 85;
            this.gp.options.enableBoos = false;
            this.gp.options.enableHolds = true;
            this.gp.options.enableMines = true;
            this.gp.options.enableFailure = false;

            // Hide UI
            this.gp.options.displayGameBottomBar = false;
            this.gp.options.displayGameTopBar = false;
            this.gp.options.displayHealth = false;
            this.gp.options.displayPA = false;
            this.gp.options.displayScreencut = false;
            this.gp.options.displayJudge = false;
            //this.gp.options.displaySongProgress = false;

            // Disable Mirror
            var mirIdx:int = this.gp.options.mods.indexOf("mirror");
            if (mirIdx >= 0)
            {
                this.gp.options.mods.removeAt(mirIdx);
                delete this.gp.options.modCache["mirror"];
                this.gp.song.noteMod.modMirror = false;
            }

            // Add Custom Mods
            runtime.addMod("antimatter");
            runtime.addMod("rotation_lock");
            runtime.addMod("scale_lock");

            // Start Timeline
            lastTimer = getTimer();
            timeline = new DeltaTimeline(this);
            timeline.TLPlay(DarkMatterTimeline.getTimeline());
        }

        public function postUIHook():void
        {
            CenterX = this.gp.x;
            CenterY = this.gp.y;

            // Consistent Starting Position
            this.nb = gp.noteBox;
            this.nb.x = -160;
            this.nb.y = -240;

            var worldPoint:Point = this.nb.globalToLocal(new Point(390, 90));

            mainX = worldPoint.x;
            mainY = worldPoint.y;

            receptors = new <MovieClip>[this.nb.getReceptor("L"), this.nb.getReceptor("D"), this.nb.getReceptor("U"), this.nb.getReceptor("R")];
            receptors.fixed = true;
            receptorCount = receptors.length - 1;

            // Add Walls
            wallLeft = new Bitmap(new Wall());
            wallLeft.x = wallLeftReset;
            this.gp.addChildAt(wallLeft, 0);

            wallRight = new Bitmap(new Wall());
            wallRight.x = wallRightReset;
            this.gp.addChildAt(wallRight, 0);

            // Add Karhis
            karhis = new CharKarhisLogic();
            karhis.x = 390;
            karhis.y = 240;
            karhis.scaleY = 0;
            this.gp.addChildAt(karhis, 0);
            karhis.UpdateHome();
        }

        public function hasFrameScript(frame:int):Boolean
        {
            return true;
        }

        public function doTickEvent(position:int):void
        {
            var curTimer:int = getTimer();
            var delta:Number = (curTimer - lastTimer) / (1000 / gp.stage.frameRate);
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

            // Update Other
            karhis.update(delta, eclipsed);
            ShakeUpdate(delta, eclipsed);
        }

        public function doFrameEvent(frame:int):void
        {

        }

        public function destroy():void
        {

        }

        public function restart():void
        {

        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        public var CenterX:Number = 0;
        public var CenterY:Number = 0;
        public var ShakeIntensity:Number = 0;
        public var ShakeTimer:Number = 0;
        public var ShakeReduction:Number = 0.5;

        public function ScreenShake(intenstity:int):void
        {
            ShakeIntensity = intenstity;
            ShakeTimer = 0;
        }

        public function ShakeUpdate(delta:Number, eclipsed:Number):void
        {
            // Shake
            if (ShakeIntensity > 0)
                ShakeTimer += eclipsed;
            else
            {
                this.gp.x = CenterX;
                this.gp.y = CenterY;
            }

            if (ShakeTimer > 0.03334)
            {
                ShakeTimer -= 0.03334;
                ShakeIntensity -= ShakeReduction;
                this.gp.x = CenterX + ShakeIntensity * (Math.random() > 0.5 ? 1 : -1);
                this.gp.y = CenterY + ShakeIntensity * (Math.random() > 0.5 ? 1 : -1);
            }
        }

        public function ScreenShakeReduction(val:Number):void
        {
            ShakeReduction = val;
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        private var wallLeftReset:Number = -600;
        private var wallRightReset:Number = 868;

        public function WallShow(curTime:Number = 0):void
        {
            tickables[tickables.length] = new BasicTween(wallLeft, "x", 0.568, wallLeftReset, -372, "outBack", curTime);
            tickables[tickables.length] = new BasicTween(wallRight, "x", 0.568, wallRightReset, 640, "outBack", curTime);
        }

        public function WallHide(curTime:Number = 0):void
        {
            tickables[tickables.length] = new BasicTween(wallLeft, "x", 0.568, -372, wallLeftReset, "linear", curTime);
            tickables[tickables.length] = new BasicTween(wallRight, "x", 0.568, 640, wallRightReset, "linear", curTime);
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        public function PlayCharAction(cmd:String):void
        {
            if (cmd == "Spawn")
            {
                tickables[tickables.length] = new BasicTween(karhis, "scaleY", 0.168, 0, 1, "outSine");
            }
            else if (cmd == "Hide")
            {
                karhis.CastCircle(false);
                tickables[tickables.length] = new BasicTween(karhis, "scaleY", 0.168, 1, 0, "outSine");
            }
            else if (cmd == "Cast")
            {
                karhis.CastCircle(true);
            }
            else if (cmd == "CastOff")
            {
                karhis.CastCircle(false);
            }
            else if (cmd == "ScaleSmall")
            {
                tickables[tickables.length] = new BasicTween(karhis, "scaleX", 8.098, 1, 0.6, "linear");
                tickables[tickables.length] = new BasicTween(karhis, "scaleY", 8.098, 1, 0.6, "linear");
            }
            else if (cmd == "ScaleNormal")
            {
                tickables[tickables.length] = new BasicTween(karhis, "scaleX", 1.366, 0.6, 1, "linear");
                tickables[tickables.length] = new BasicTween(karhis, "scaleY", 1.366, 0.6, 1, "linear");
            }
        }

        public function PlayCharAnimation(cmd:String, scale:Number = 1):void
        {
            karhis.PlayAnimation(cmd, scale);
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        public function EnableMod(mod:String):void
        {
            runtime.addMod(mod);
        }

        public function DisableMod(mod:String):void
        {
            runtime.removeMod(mod);
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        public function FilterMask(isEnabled:Boolean):void
        {
            if (isEnabled)
            {
                var dmpoint:Point = this.gp.noteBoxContainer.globalToLocal(new Point());

                // Masking (Notes and Filter)
                if (noteBoxContainerMask == null)
                {
                    noteBoxContainerMask = new Sprite();
                    noteBoxContainerMask.graphics.beginFill(0xff0000, 1);
                    noteBoxContainerMask.graphics.drawRect(0, 0, 780, 480);
                    noteBoxContainerMask.graphics.endFill();
                }
                noteBoxContainerMask.x = dmpoint.x;
                noteBoxContainerMask.y = dmpoint.y;

                this.gp.noteBoxContainer.addChild(noteBoxContainerMask);

                this.gp.noteBoxContainer.graphics.clear();
                this.gp.noteBoxContainer.graphics.beginFill(0x000000, 0);
                this.gp.noteBoxContainer.graphics.drawRect(dmpoint.x, dmpoint.y, 780, 480);
                this.gp.noteBoxContainer.graphics.endFill();
                /*
                   this.gp.noteBoxContainer.graphics.beginFill(0xff0000, 1);
                   this.gp.noteBoxContainer.graphics.drawRect(dmpoint.x, dmpoint.y, 25, 25);
                   this.gp.noteBoxContainer.graphics.endFill();
                   this.gp.noteBoxContainer.graphics.beginFill(0xff0000, 1);
                   this.gp.noteBoxContainer.graphics.drawRect(dmpoint.x + 780 - 25, dmpoint.y, 25, 25);
                   this.gp.noteBoxContainer.graphics.endFill();
                   this.gp.noteBoxContainer.graphics.beginFill(0xff0000, 1);
                   this.gp.noteBoxContainer.graphics.drawRect(dmpoint.x + 780 - 25, dmpoint.y + 480 - 25, 25, 25);
                   this.gp.noteBoxContainer.graphics.endFill();
                   this.gp.noteBoxContainer.graphics.beginFill(0xff0000, 1);
                   this.gp.noteBoxContainer.graphics.drawRect(dmpoint.x, dmpoint.y + 480 - 25, 25, 25);
                   this.gp.noteBoxContainer.graphics.endFill();
                 */

                this.gp.noteBoxContainer.mask = noteBoxContainerMask;
            }
            else
            {
                if (this.gp.noteBoxContainer.contains(noteBoxContainerMask))
                {
                    this.gp.noteBoxContainer.removeChild(noteBoxContainerMask);
                    this.gp.noteBoxContainer.graphics.clear();
                    this.gp.noteBoxContainer.mask = null;
                }
            }
        }

        private var DM_DISP_POINT:Point = new Point();

        public function SetDisplacementFilter(filter:String):void
        {
            var DM_FILTER:DisplacementMapFilter;
            var FILTER_BMD:BitmapData;

            if (filter == "Wall")
                DM_FILTER = new DisplacementMapFilter(new DMDisplaceWall(), DM_DISP_POINT, BitmapDataChannel.GREEN, BitmapDataChannel.RED, 65, 350, DisplacementMapFilterMode.COLOR, 0xffffff, 0);
            else if (filter == "Corrupt")
                DM_FILTER = new DisplacementMapFilter(new DMDisplaceCorrupt(), DM_DISP_POINT, BitmapDataChannel.RED, BitmapDataChannel.RED, 250, 50, DisplacementMapFilterMode.WRAP);
            else if (filter == "Shift")
                DM_FILTER = new DisplacementMapFilter(new DMDisplaceShift(), DM_DISP_POINT, BitmapDataChannel.BLUE, BitmapDataChannel.RED, 0, 0, DisplacementMapFilterMode.WRAP);
            else if (filter == "Wiggle")
                DM_FILTER = new DisplacementMapFilter(new DMDisplaceShift(), DM_DISP_POINT, BitmapDataChannel.RED, BitmapDataChannel.RED, 0, 0, DisplacementMapFilterMode.WRAP);

            if (DM_FILTER != null)
                this.gp.noteBoxContainer.filters = [DM_FILTER];
            else
                this.gp.noteBoxContainer.filters = [];

            LAST_DM_FILTER = DM_FILTER;
        }

        public function FilterVariable(len:Number, prop:String, value:Number, ease:String, curTime:Number = 0):void
        {
            tickables[tickables.length] = new FilterTween(LAST_DM_FILTER, this.gp.noteBoxContainer, prop, len, LAST_DM_FILTER[prop], value, ease, curTime);
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        public function FieldTween(len:Number, prop:String, startVal:Number, endVal:Number, ease:String, curTime:Number = 0):void
        {
            tickables[tickables.length] = new BasicTween(this.gp.noteBoxContainer, prop, len, startVal, endVal, ease, curTime);
        }

        public function SetReadahead(val:Number):void
        {
            this.nb.readahead = val;
        }

        public function SetSpeed(len:Number, startVal:Number, endVal:Number, ease:String, curTime:Number = 0):void
        {
            tickables[tickables.length] = new BasicTween(this.gp.options, "scrollSpeed", len, startVal, endVal, ease, curTime);
            tickables[tickables.length] = new BasicTween(this.nb, "scrollSpeed", len, startVal, endVal, ease, curTime);
        }

        public function SetNoteskin(val:Number):void
        {
            this.gp.options.noteskin = val;
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        public function Pulse(len:Number, pulse:Number, curTime:Number = 0):void
        {
            tickables[tickables.length] = new EffectPulse(nb, len, pulse, curTime);
        }

        public function FlashBang(len:Number, curTime:Number = 0):void
        {
            tickables[tickables.length] = new EffectFlashbang(len, this.gp, curTime);
        }

        public function MoveX(len:Number, startVal:Number, endVal:Number, ease:String, curTime:Number = 0):void
        {
            for (var recpI:int = receptorCount; recpI >= 0; recpI--)
            {
                MoveXN(len, receptors[recpI].KEY, startVal, endVal, ease, curTime);
            }
        }

        public function MoveXN(len:Number, dir:String, startVal:Number, endVal:Number, ease:String, curTime:Number = 0):void
        {
            var rec1:MovieClip = nb.getReceptor(dir);
            var sX:Number = mainX + receptorLocations[rec1.KEY].x + startVal;
            var eX:Number = mainX + receptorLocations[rec1.KEY].x + endVal;

            tickables[tickables.length] = new BasicTween(rec1, "x", len, sX, eX, ease, curTime);
        }

        public function MoveY(len:Number, startVal:Number, endVal:Number, ease:String, curTime:Number = 0):void
        {
            for (var recpI:int = receptorCount; recpI >= 0; recpI--)
            {
                MoveYN(len, receptors[recpI].KEY, startVal, endVal, ease, curTime);
            }
        }

        public function MoveYN(len:Number, dir:String, startVal:Number, endVal:Number, ease:String, curTime:Number = 0):void
        {
            var rec1:MovieClip = nb.getReceptor(dir);
            var sY:Number = mainY + receptorLocations[rec1.KEY].y + startVal;
            var eY:Number = mainY + receptorLocations[rec1.KEY].y + endVal;

            tickables[tickables.length] = new BasicTween(rec1, "y", len, sY, eY, ease, curTime);
        }

        public function ColumnFlip(len:Number, ease:String, curTime:Number = 0):void
        {
            ColumnSwap(len, "L", "R", ease, curTime);
            ColumnSwap(len, "D", "U", ease, curTime);
        }

        public function ColumnInvert(len:Number, ease:String, curTime:Number = 0):void
        {
            ColumnSwap(len, "L", "D", ease, curTime);
            ColumnSwap(len, "U", "R", ease, curTime);
        }

        public function ColumnSwap(len:Number, dir1:String, dir2:String, ease:String, curTime:Number = 0):void
        {
            var rec1:MovieClip = nb.getReceptor(dir1);
            var rec2:MovieClip = nb.getReceptor(dir2);

            tickables[tickables.length] = new BasicTween(rec1, "x", len, rec1.x, rec2.x, ease, curTime);
            tickables[tickables.length] = new BasicTween(rec1, "y", len, rec1.y, rec2.y, ease, curTime);
            tickables[tickables.length] = new BasicTween(rec2, "x", len, rec2.x, rec1.x, ease, curTime);
            tickables[tickables.length] = new BasicTween(rec2, "y", len, rec2.y, rec1.y, ease, curTime);
        }

        public function NoteScale(len:Number, startVal:Number, endVal:Number, ease:String, curTime:Number = 0):void
        {
            for (var recpI:int = receptorCount; recpI >= 0; recpI--)
            {
                NoteScaleN(len, receptors[recpI].KEY, startVal, endVal, ease, curTime);
            }
        }

        public function NoteScaleN(len:Number, dir:String, startVal:Number, endVal:Number, ease:String, curTime:Number = 0):void
        {
            var rec1:MovieClip = nb.getReceptor(dir);
            tickables[tickables.length] = new BasicTween(rec1, "scaleX", len, startVal, endVal, ease, curTime);
            tickables[tickables.length] = new BasicTween(rec1, "scaleY", len, startVal, endVal, ease, curTime);
        }

        public function ConfusionOffset(len:Number, startVal:Number, endVal:Number, ease:String, curTime:Number = 0):void
        {
            for (var recpI:int = receptorCount; recpI >= 0; recpI--)
            {
                ConfusionOffsetN(len, receptors[recpI].KEY, startVal, endVal, ease, curTime);
            }
        }

        public function ConfusionOffsetN(len:Number, dir:String, startVal:Number, endVal:Number, ease:String, curTime:Number = 0):void
        {
            var recpI:MovieClip = nb.getReceptor(dir);
            tickables[tickables.length] = new BasicTween(recpI, "rotation", len, startVal + recpI.ORIG_ROT, endVal + recpI.ORIG_ROT, ease, curTime);
        }

        public function SetDirection(len:Number, startVal:Number, endVal:Number, ease:String, curTime:Number = 0):void
        {
            for (var recpI:int = receptorCount; recpI >= 0; recpI--)
            {
                SetDirectionN(len, receptors[recpI].KEY, startVal, endVal, ease, curTime);
            }
        }

        public function SetDirectionN(len:Number, dir:String, startVal:Number, endVal:Number, ease:String, curTime:Number = 0):void
        {
            tickables[tickables.length] = new BasicTween(nb.getReceptor(dir), "DIRECTION", len, startVal, endVal, ease, curTime);
        }

        public function SetHoldRotation(endVal:Number):void
        {
            for (var recpI:int = receptorCount; recpI >= 0; recpI--)
            {
                receptors[recpI].HOLD_ROTATION = endVal;
            }
        }

        public function SetHoldRotationN(dir:String, endVal:Number):void
        {
            nb.getReceptor(dir).HOLD_ROTATION = endVal;
        }
    }
}
