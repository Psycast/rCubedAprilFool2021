package arc
{
    import classes.chart.Note;
    import classes.chart.Song;
    import game.GameOptions;
    import classes.chart.NoteHold;
    import classes.chart.NoteMine;

    public class NoteMod extends Object
    {
        private var song:Song;
        private var notes:Array;
        private var holds:Array;
        private var mines:Array;

        private var DIRECTIONS:Array = ['L', 'D', 'U', 'R'];
        private var MIRROR_VALUE:int = 3;
        private const HALF_COLOUR:Object = {"red": "red", "blue": "red", "purple": "purple", "yellow": "blue", "pink": "purple", "orange": "yellow", "cyan": "pink", "green": "orange", "white": "white"}

        public var options:GameOptions;

        public var modDark:Boolean;
        public var modHidden:Boolean;
        public var modMirror:Boolean;
        public var modColumnColour:Boolean;
        public var modHalfTime:Boolean;
        public var modNoBackground:Boolean;
        public var modOffset:Boolean;
        public var modRate:Boolean;
        public var modJudgeWindow:Boolean;

        private var reverseLastFrame:int;

        public function NoteMod(song:Song, options:GameOptions)
        {
            this.song = song;
            this.options = options;

            this.DIRECTIONS = options.noteDirections;
            this.MIRROR_VALUE = this.DIRECTIONS.length - 1;

            updateMods();
        }

        public function updateMods():void
        {
            modDark = options.modEnabled("dark");
            modHidden = options.modEnabled("hidden");
            modMirror = options.modEnabled("mirror");
            modColumnColour = options.modEnabled("columncolour");
            modHalfTime = options.modEnabled("halftime");
            modNoBackground = options.modEnabled("nobackground");
            modOffset = options.offsetGlobal != 0;
            modRate = options.songRate != 1;
            modJudgeWindow = Boolean(options.judgeWindow);

            reverseLastFrame = -1;
        }

        public function start(options:GameOptions):void
        {
            this.options = options;
            this.DIRECTIONS = options.noteDirections;
            this.MIRROR_VALUE = this.DIRECTIONS.length - 1;

            updateMods();

            notes = song.chart.Notes;
            holds = song.chart.Holds;
            mines = song.chart.Mines;
        }

        private function valueOfDirection(direction:String):int
        {
            return DIRECTIONS.indexOf(direction.charAt(0));
        }

        private function directionOfValue(value:int):String
        {
            return DIRECTIONS[value].toString();
        }

        public static function noteModRequired(options:GameOptions):Boolean
        {
            var mod:NoteMod = new NoteMod(null, options);
            return mod.required();
        }

        public function required():Boolean
        {
            return modColumnColour || modHalfTime || modMirror || modOffset || modRate;
        }

        public function transformNote(index:int):Note
        {
            var note:Note = notes[index];
            if (note == null)
                return null;

            var pos:Number = note.time;
            var colour:String = note.colour;
            var frame:Number = note.frame - song.musicDelay;
            var dir:int = valueOfDirection(note.direction);

            //pos = frame / GameOptions.ENGINE_TICK_RATE;

            if (modRate)
            {
                pos /= options.songRate;
                frame /= options.songRate;
            }

            if (modOffset)
            {
                var goffset:int = Math.round(options.offsetGlobal);
                frame += goffset;
                pos += goffset / GameOptions.ENGINE_TICK_RATE;
            }

            if (modMirror)
                dir = -dir + MIRROR_VALUE;

            if (modColumnColour)
                colour = (dir % MIRROR_VALUE) ? "blue" : "red";

            if (modHalfTime)
                colour = HALF_COLOUR[colour] || colour;

            return new Note(directionOfValue(dir), pos, colour, int(frame));
        }

        public function transformTotalNotes():int
        {
            if (!notes)
                return 0;

            return notes.length;
        }

        public function transformHold(index:int):NoteHold
        {
            var note:NoteHold = holds[index];
            if (note == null)
                return null;

            var pos:Number = note.time;
            var colour:String = note.colour;
            var frame:Number = note.frame - song.musicDelay;
            var dir:int = valueOfDirection(note.direction);
            var tail:Number = note.tail;
            var frame_tail:int = note.tail;

            //pos = frame / GameOptions.ENGINE_TICK_RATE;

            if (modRate)
            {
                pos /= options.songRate;
                frame /= options.songRate;
                tail /= options.songRate;
                frame_tail = Math.max(1, frame_tail / options.songRate);
            }

            if (modOffset)
            {
                var goffset:int = Math.round(options.offsetGlobal);
                frame += goffset;
                pos += goffset / GameOptions.ENGINE_TICK_RATE;
            }

            if (modMirror)
                dir = -dir + MIRROR_VALUE;

            if (modColumnColour)
                colour = (dir % MIRROR_VALUE) ? "blue" : "red";

            if (modHalfTime)
                colour = HALF_COLOUR[colour] || colour;

            return new NoteHold(directionOfValue(dir), pos, colour, tail, int(frame), frame_tail);
        }

        public function transformTotalHolds():int
        {
            if (!holds)
                return 0;

            return holds.length;
        }

        public function transformMine(index:int):NoteMine
        {
            var note:NoteMine = mines[index];
            if (note == null)
                return null;

            var pos:Number = note.time;
            var frame:Number = note.frame - song.musicDelay;
            var dir:int = valueOfDirection(note.direction);

            //pos = frame / GameOptions.ENGINE_TICK_RATE;

            if (modRate)
            {
                pos /= options.songRate;
                frame /= options.songRate;
            }

            if (modOffset)
            {
                var goffset:int = Math.round(options.offsetGlobal);
                frame += goffset;
                pos += goffset / GameOptions.ENGINE_TICK_RATE;
            }

            if (modMirror)
                dir = -dir + MIRROR_VALUE;

            return new NoteMine(directionOfValue(dir), pos, int(frame));
        }

        public function transformTotalMines():int
        {
            if (!mines)
                return 0;

            return mines.length;
        }

        public function transformSongLength():Number
        {
            if (!notes || notes.length <= 0)
                return 0;

            var firstNote:Note;
            var lastNote:Note = notes[notes.length - 1];
            var time:Number = lastNote.time;

            if (holds.length > 0)
            {
                var lastHold:NoteHold = holds[holds.length - 1];
                time = Math.max(time, (lastHold.time + lastHold.tail));
            }

            if (mines.length > 0)
            {
                var lastMine:NoteMine = mines[mines.length - 1];
                time = Math.max(time, lastMine.time);
            }

            // Rates after everything.
            if (modRate)
            {
                time /= options.songRate;
            }

            return time + 3; // 1 seconds for fade out.
        }
    }
}
