package game.controls
{
    import flash.display.Sprite;
    import classes.Noteskins;

    public class GameNoteMine extends Sprite
    {
        private static var _noteskins:Noteskins = Noteskins.instance;

        public static const ARMED:int = 0;
        public static const PASSED:int = 1;

        private var _note:Sprite;
        public var ID:int = 0;
        public var DIR:String;
        public var COLOR:String;
        public var TIME:int = 0;
        public var TICK:int = 0;
        public var STATE:int = 0;
        public var SPAWN_PROGRESS:int = 0;

        public function GameNoteMine(id:int, dir:String, time:int = 0, tick:int = 0)
        {
            this.ID = id;
            this.DIR = dir;
            this.TIME = time;
            this.TICK = tick;

            var _noteInfo:Object = _noteskins.getInfo(9);
            _note = _noteskins.getNote(9, "blue", "L");
            _note.x = -(_noteInfo.width >> 1);
            _note.y = -(_noteInfo.height >> 1);
            this.addChild(_note);
        }
    }
}
