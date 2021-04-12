package classes
{
    import classes.chart.levels.EmbedChartBase;
    import classes.chart.levels.EmbedChartDarkMatter;
    import classes.chart.levels.EmbedChartExtremeMegaMix;
    import classes.chart.levels.EmbedChartGigahertz;
    import classes.chart.levels.EmbedChartHello2021;
    import classes.chart.levels.EmbedChartMagnolia;
    import classes.chart.levels.EmbedChartMarigold;
    import classes.chart.levels.EmbedChartMegalovania;
    import classes.chart.levels.EmbedChartMyosotis;
    import classes.chart.levels.EmbedChartNyanCat;
    import classes.chart.levels.EmbedChartPeaceBreaker;
    import classes.chart.levels.EmbedChartPopCulture;
    import classes.chart.levels.EmbedChartRevenge;
    import classes.chart.levels.EmbedChartSoundChimera;
    import classes.chart.levels.EmbedChartSpeedOfLink;
    import classes.chart.levels.EmbedChartUnrealSuperHero;
    import classes.chart.levels.EmbedChartVoyage1970;
    import com.flashfla.utils.ArrayUtil;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.net.URLLoader;

    public class Playlist extends EventDispatcher
    {
        // Hardcoded Data
        private var embedLevels:Vector.<EmbedChartBase>;
        private var worldLevels:Array = [];

        ///- Singleton Instance
        private static var _instance:Playlist = null;
        private static var _instanceCanon:Playlist = null;

        ///- Private Locals
        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _loader:URLLoader;
        private var _isLoaded:Boolean = false;
        private var _isLoading:Boolean = false;
        private var _loadError:Boolean = false;

        ///- Public Locals
        public var generatedQueues:Array;
        public var genreList:Array;
        public var playList:Array;
        public var indexList:Array;
        public var engine:Object;

        ///- Fixed Levels
        public var LEVEL_EXTREME_MEGAMIX:EmbedChartBase = new EmbedChartExtremeMegaMix();
        public var LEVEL_NYAN_CAT:EmbedChartBase = new EmbedChartNyanCat();
        public var LEVEL_DARK_MATTER:EmbedChartBase = new EmbedChartDarkMatter();
        public var LEVEL_MEGALOVANIA:EmbedChartBase = new EmbedChartMegalovania();

        public var LEVEL_SOUND_CHIMERA:EmbedChartBase = new EmbedChartSoundChimera();
        public var LEVEL_SPEED_OF_LINK:EmbedChartBase = new EmbedChartSpeedOfLink();
        public var LEVEL_PEACE_BREAKER:EmbedChartBase = new EmbedChartPeaceBreaker();
        public var LEVEL_VOYAGE_1970:EmbedChartBase = new EmbedChartVoyage1970();

        public var LEVEL_REVENGE:EmbedChartBase = new EmbedChartRevenge();
        public var LEVEL_GIGAHERTZ:EmbedChartBase = new EmbedChartGigahertz();
        public var LEVEL_HELLO_2021:EmbedChartBase = new EmbedChartHello2021();
        public var LEVEL_UNREAL_SUPERHERO:EmbedChartBase = new EmbedChartUnrealSuperHero();

        public var LEVEL_POP_CULTURE:EmbedChartPopCulture = new EmbedChartPopCulture();
        public var LEVEL_MAGNOLIA:EmbedChartMagnolia = new EmbedChartMagnolia();
        public var LEVEL_MYOSOTIS:EmbedChartMyosotis = new EmbedChartMyosotis();
        public var LEVEL_MARIGOLD:EmbedChartMarigold = new EmbedChartMarigold();

        ///- Constructor
        public function Playlist()
        {
            embedLevels = new <EmbedChartBase>[LEVEL_EXTREME_MEGAMIX,
                LEVEL_DARK_MATTER,
                LEVEL_NYAN_CAT,
                LEVEL_MEGALOVANIA,
                LEVEL_SOUND_CHIMERA,
                LEVEL_VOYAGE_1970,
                LEVEL_SPEED_OF_LINK,
                LEVEL_PEACE_BREAKER,
                LEVEL_REVENGE,
                LEVEL_UNREAL_SUPERHERO,
                LEVEL_GIGAHERTZ,
                LEVEL_HELLO_2021,
                LEVEL_POP_CULTURE,
                LEVEL_MAGNOLIA,
                LEVEL_MYOSOTIS,
                LEVEL_MARIGOLD];

            for (var i:int = 0; i < embedLevels.length; i++)
                embedLevels[i].setID(i + 1);
        }

        public static function clearCanon():void
        {
            _instanceCanon = null;
        }

        public static function get instanceCanon():Playlist
        {
            return _instanceCanon;
        }

        public static function get instance():Playlist
        {
            if (_instance == null)
                _instance = new Playlist();
            return _instance;
        }

        public function isLoaded():Boolean
        {
            return _isLoaded && !_loadError;
        }

        public function isError():Boolean
        {
            return _loadError;
        }

        ///- Playlist Loading
        public function load():void
        {
            _gvars.TOTAL_PUBLIC_SONGS = 0;

            generatedQueues = new Array();
            genreList = new Array();
            playList = new Array();
            indexList = new Array();

            if (_instanceCanon == null)
            {
                _instanceCanon = new Playlist();
                _instanceCanon._isLoaded = true;
                _instanceCanon.genreList = genreList;
                _instanceCanon.playList = playList;
                _instanceCanon.indexList = indexList;
                _instanceCanon.generatedQueues = generatedQueues;
            }

            genreList[1] = [];
            generatedQueues[1] = [];

            for each (var a:EmbedChartBase in embedLevels)
            {
                addSongElement(a, a.getID());
            }

            indexList.sortOn("level", Array.NUMERIC);
            _isLoaded = true;
            _loadError = false;
            this.dispatchEvent(new Event(GlobalVariables.LOAD_COMPLETE));
        }

        public function addSongElement(a:EmbedChartBase, id:int, replace:Boolean = false):void
        {
            var data:Object = a.getInfo();

            var songData:Array = [];
            for (var b:* in data)
            {
                songData[b] = data[b];
            }
            songData.embedData = a;
            songData.level = id;
            songData.style = "";
            songData.order = songData.level;
            songData.playhash = songData.previewhash = String(songData.level);
            songData.price = -1;
            songData.credits = -1;

            songData.genre = 1;
            songData.style = "";
            songData.releasedate = songData.level;
            songData.min_nps = songData.max_nps = 1;
            songData.song_rating = 5;
            songData.prerelease = false;
            songData.access = 0;
            songData.song_type = 0;

            // Extra Info
            songData.index = genreList[1].length;
            songData.timeSecs = (Number(songData.time.split(":")[0]) * 60) + Number(songData.time.split(":")[1]);

            // Author with URL
            songData.authorwithurl = songData["author"];
            songData.stepauthorwithurl = songData["stepauthor"];

            // Max Score Totals
            songData.scoreTotal = songData.arrows * 1550;
            songData.scoreRaw = songData.arrows * 50;

            // Add to lists
            playList[songData.level] = songData;

            if (replace)
            {
                songData.hasCutscene = false;
                indexList[id - 1] = songData;
                genreList[1][id - 1] = songData;
                generatedQueues[1][id - 1] = songData;
            }
            else
            {
                songData.hasCutscene = true;
                indexList.push(songData);
                genreList[1].push(songData);
                generatedQueues[1].push(songData.level);
            }
        }

        public function get embedChartLength():Number
        {
            return embedLevels.length;
        }

        public function getSong(genre:int, index:int = -1):Object
        {
            // Returns the indexed song for the All genre
            if (genre <= -1 && indexList[index] != null)
                return indexList[index];

            // If a index is set, use the genre list to get the correct song.
            else if (index >= 0 && genreList[genre] != null && genreList[genre][index] != null)
                return genreList[genre][index];

            // Return the song from the playlist, using the levelid as the default.
            else if (playList[genre] != null)
                return playList[genre];

            return {error: "not_found"};
        }
    }
}
