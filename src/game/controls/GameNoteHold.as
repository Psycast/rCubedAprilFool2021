package game.controls
{
    import flash.display.Sprite;
    import classes.Noteskins;
    import game.GameOptions;
    import flash.display.CapsStyle;

    public class GameNoteHold extends Sprite
    {
        public static const SPAWN:int = 0;
        public static const HELD:int = 1;
        public static const MISSED:int = 2;

        private static const HOLD_COLORS:Object = {"red": 0x965151,
                "orange": 0x966e51,
                "yellow": 0x938e4f,
                "green": 0x5b9651,
                "blue": 0x515896,
                "cyan": 0x519696,
                "purple": 0x89568c,
                "pink": 0xbc85bc,
                "white": 0x9e9e9e}

        private static var _noteskins:Noteskins = Noteskins.instance;

        private var _note:Sprite;
        public var NOTESKIN:int = 0;
        public var ID:int = 0;
        public var DIR:String;
        public var COLOR:String;
        public var COLOR_HOLD:uint;
        public var TIME:int = 0;
        public var TAIL:int = 0;
        public var TICK:int = 0;
        public var STATE:int = 0;
        public var SPAWN_PROGRESS:int = 0;
        public var TAIL_LENGTH_MULTI:Number = 1;

        public function GameNoteHold(id:int, dir:String, color:String, time:int = 0, tick:int = 0, activeNoteSkin:int = 1)
        {
            this.NOTESKIN = activeNoteSkin;
            this.ID = id;
            this.DIR = dir;
            this.COLOR = color;
            this.TIME = time;
            this.TICK = tick;
            this.COLOR_HOLD = HOLD_COLORS[color];
        }

        public function setSpeed(options:GameOptions):void
        {
            this.TAIL_LENGTH_MULTI = GameOptions.ENGINE_SCROLL_PIXELS * options.scrollSpeed;
        }

        public function setTail(val:int):void
        {
            this.TAIL = val;
            updateTail(0);
        }

        public function updateTail(cur_time:int, useScaling:Boolean = false):void
        {
            var col:uint = 0x444444;
            if (STATE == HELD)
                col = this.COLOR_HOLD; //0xff8c00;
            if (STATE == MISSED)
                col = 0x5e017a;

            var lineSize:Number = 12;
            if (useScaling)
                lineSize = 12 * (scaleX * 1.43);

            var tailReduce:int = (cur_time - this.TIME);
            if (tailReduce < 0)
                tailReduce = 0;

            var tailLengthOffset:int = (tailReduce / 1000 * TAIL_LENGTH_MULTI);
            var tailLengthClip:int = ((this.TAIL - tailReduce) / 1000 * TAIL_LENGTH_MULTI);
            this.graphics.clear();
            if (tailLengthClip > 0)
            {
                this.graphics.lineStyle(lineSize, col, 1, true);
                this.graphics.moveTo(0, tailLengthOffset)
                this.graphics.lineTo(0, tailLengthOffset + tailLengthClip - (lineSize / 2));
            }
        }

        public function dispose():void
        {
            if (_note != null && this.contains(_note))
            {
                this.removeChild(_note);
            }

            _note = null;
        }

    }

}
