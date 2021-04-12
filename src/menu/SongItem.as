package menu
{

    public class SongItem
    {
        public var index:int = 0;

        // Song Data
        private var _songData:Object;
        private var _level:int = 0;
        public var active:Boolean = false;

        ////////////////////////////////////////////////////////////////////////
        //- Getters / Setters
        public function setData(song:Object):void
        {
            _songData = song;
            _level = song.level;
        }

        public function get songData():Object
        {
            return _songData;
        }

        public function get level():int
        {
            return _level;
        }
    }
}
