package scripts.darkmatter
{
    import flash.display.Sprite;
    import flash.display.MovieClip;
    import af.assets.MCOsuNote;
    import scripts.IScriptTickable;
    import classes.Noteskins;

    public class GameNoteOsu extends Sprite implements IScriptTickable
    {
        private var id:int;
        private var timingCircle:MCOsuNote;
        private var noteCircle:MCOsuNote;
        private var noteDisplay:Sprite;

        private var noteMode:int = 0;
        private var time:int = 0;
        private var noteReadahead:Number = 1;
        private var noteFadeTimer:Number = 0;

        private var _canDestroy:Boolean = false;

        public function GameNoteOsu(mid:int, mx:Number, my:Number, mcolor:String, mdirection:String, mtime:Number)
        {
            this.id = mid;

            timingCircle = new MCOsuNote();
            timingCircle.gotoAndStop("timing");
            timingCircle.scaleX = timingCircle.scaleY = 2;
            addChild(timingCircle);

            noteCircle = new MCOsuNote();
            noteCircle.gotoAndStop(mcolor);
            addChild(noteCircle);

            noteDisplay = Noteskins.instance.getNote(2, mcolor, mdirection);
            noteDisplay.scaleX = noteDisplay.scaleY = 0.75;
            //noteDisplay.x = -24;
            //noteDisplay.y = -24;
            addChild(noteDisplay);
        }

        public function update(delta:Number, eclipsed:Number):void
        {
            time += eclipsed;

            if (noteMode == 0)
            {
                noteFadeTimer += eclipsed;
                this.alpha = easeInOutCubic(noteFadeTimer / 0.5);
                if (this.alpha >= 1)
                    noteMode = 1;
            }

            if (noteMode <= 1)
            {
                timingCircle.scaleX = timingCircle.scaleY = 2 - time;
                if (timingCircle.scaleX < 0.9)
                {
                    noteFadeTimer = 0;
                    noteMode = 2;
                }
            }

            if (noteMode == 2)
            {
                noteFadeTimer += eclipsed;
                this.alpha = 1 - easeInOutCubic(noteFadeTimer / 0.5);
                if (this.alpha <= 0)
                    noteMode = 5;
            }

        }

        public function destroy():void
        {
            timingCircle = null;
            noteCircle = null;
        }


        private function easeInOutCubic(x:Number):Number
        {
            return x < 0.5 ? 4 * x * x * x : 1 - Math.pow(-2 * x + 2, 3) / 2;
        }

        public function canDestroy():Boolean
        {
            return _canDestroy;
        }
    }
}
