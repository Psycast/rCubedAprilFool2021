/**
 * @author Jonathan (Velocity)
 */

package
{
    import be.aboutme.airserver.AIRServer;
    import be.aboutme.airserver.endpoints.socket.SocketEndPoint;
    import be.aboutme.airserver.endpoints.socket.handlers.websocket.WebSocketClientHandlerFactory;
    import be.aboutme.airserver.messages.Message;
    import by.blooddy.crypto.image.PNGEncoder;
    import classes.Playlist;
    import classes.SongPlayerBytes;
    import classes.StatTracker;
    import classes.User;
    import classes.chart.Song;
    import com.flashfla.net.DynamicURLLoader;
    import com.flashfla.utils.DateUtil;
    import flash.display.BitmapData;
    import flash.display.StageDisplayState;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.media.SoundTransform;
    import flash.net.FileReference;
    import game.GameOptions;
    import game.GameScoreResult;

    public class GlobalVariables extends EventDispatcher
    {
        ///- Singleton Instance
        private static var _instance:GlobalVariables = null;
        private var _loader:DynamicURLLoader;

        ///- Constants
        public static const LOAD_COMPLETE:String = "LoadComplete";
        public static const LOAD_ERROR:String = "LoadError";
        public static const HIGHSCORES_LOAD_COMPLETE:String = "HighscoresLoadComplete";
        public static const HIGHSCORES_LOAD_ERROR:String = "HighscoresLoadError";
        public var flashvars:Object;
        public var gameMain:Main;

        public var options:GameOptions;

        ///- Game Data
        public var TOTAL_GENRES:uint = 13;
        public var TOTAL_SONGS:uint = 0;
        public var TOTAL_PUBLIC_SONGS:uint = 0;

        public var HEALTH_JUDGE_ADD:int = 2;
        public var HEALTH_JUDGE_MISS:int = -10;
        public var HEALTH_JUDGE_BOO:int = -5;
        public var HEALTH_JUDGE_MINE:int = -15;

        public var TOTAL_STEPS:int = 31;
        public var BEAT_DELAY:int = -31;
        public var SCROLL_DIRECTIONS:Array = ["up", "down"];
        public var GAME_MODS:Array = ["hidden", "sudden", "blink", "----", "rotating", "rotate_cw", "rotate_ccw", "dizzy", "flashlight", "wave", "drunk", "tornado", "mini_resize", "tap_pulse", "bleed"];
        public var VISUAL_MODS:Array = ["mirror", "dark", "hide", "mini", "columncolour", "halftime", "----", "nobackground"];
        public var songStartTime:String = "0";
        public var songStartHash:String = "0";
        public var songData:Array = [];
        public var songHighscores:Object = {};

        ///- User Vars
        public var userSession:String = "";
        public var activeUser:User;
        public var playerUser:User;

        ///- GamePlay
        public var songQueue:Array = [];
        public var totalSongQueue:Array = [];
        public var gameIndex:int = 0;
        public var replayHistory:Array = [];
        public var songResults:Vector.<GameScoreResult> = new <GameScoreResult>[];
        public var songResultRanks:Array = [];
        public var songRestarts:int;

        ///- Session Stats
        public var sessionStats:StatTracker = new StatTracker();
        public var songStats:StatTracker = new StatTracker();

        public var menuMusic:SongPlayerBytes;
        public var menuMusicSoundVolume:Number = 1;
        public var menuMusicSoundTransform:SoundTransform = new SoundTransform();

        ///- Air Options
        public var air_useVSync:Boolean = true;
        public var air_useWebsockets:Boolean = false;

        private var websocket_server:AIRServer;
        private static var websocket_message:Message = new Message();

        public function loadAirOptions():void
        {
            air_useVSync = LocalStore.getVariable("air_useVSync", false);
            air_useWebsockets = LocalStore.getVariable("air_useWebsockets", false);

            if (air_useWebsockets)
                initWebsocketServer();

            menuMusicSoundVolume = menuMusicSoundTransform.volume = LocalStore.getVariable("menuMusicSoundVolume", 0.15);
        }

        public function websocketPortNumber(type:String):uint
        {
            if (websocket_server != null)
            {
                return websocket_server.getPortNumber(type);
            }
            return 0;
        }

        public function initWebsocketServer():Boolean
        {
            if (websocket_server == null)
            {
                websocket_server = new AIRServer();
                websocket_server.addEndPoint(new SocketEndPoint(21235, new WebSocketClientHandlerFactory()));

                // didn't start, remove reference
                if (!websocket_server.start())
                {
                    websocket_server.stop();
                    websocket_server = null;
                    return false;
                }
                return true;
            }
            return false;
        }

        public function destroyWebsocketServer():void
        {
            if (websocket_server != null)
            {
                websocket_server.stop();
                websocket_server = null;
            }
        }

        public function websocketSend(cmd:String, data:Object):void
        {
            if (websocket_server != null)
            {
                websocket_message.command = cmd;
                websocket_message.data = data;
                websocket_server.sendMessageToAllClients(websocket_message);
            }
        }

        public function onNativeProcessClose(e:Event):void
        {
            if (websocket_server != null)
            {
                websocket_server.stop();
            }
        }

        ///- Public
        //- Song Data
        public function getSongFile(song:Object, preview:Boolean = false):Song
        {
            return loadSongFile(song);
        }

        private function loadSongFile(song:Object):Song
        {
            //- Make new Song
            var newSong:Song = new Song(song);
            song.file = newSong;

            return newSong;
        }

        public static function getSongIconIndex(_song:Object, _rank:Object):int
        {
            var songIcon:int = 0;
            if (_rank)
            {
                var arrows:int = _song.arrows;
                var scoreRaw:int = _song.scoreRaw;
                if (_rank.arrows > 0)
                {
                    arrows = _rank.arrows;
                    scoreRaw = arrows * 50;
                }
                // No Score
                if (_rank.score == 0)
                    songIcon = 0;

                // No Score
                if (_rank.score > 0)
                    songIcon = 1;

                // FC* - When current score isn't FC but a FC has been achieved before.
                if (_rank.fcs > 0)
                    songIcon = 7;

                // FC
                if (_rank.perfect + _rank.good + _rank.average == arrows && _rank.miss == 0 && _rank.maxcombo == arrows)
                    songIcon = 2;

                // SDG
                if (scoreRaw - _rank.rawscore < 250)
                    songIcon = 3;

                // BlackFlag
                if (_rank.perfect == arrows - 1 && _rank.good == 1 && _rank.average == 0 && _rank.miss == 0 && _rank.boo == 0 && _rank.maxcombo == arrows)
                    songIcon = 4;

                // BooFlag
                if (_rank.perfect == arrows && _rank.good == 0 && _rank.average == 0 && _rank.miss == 0 && _rank.boo == 1 && _rank.maxcombo == arrows)
                    songIcon = 5;

                // AAA
                if (_rank.rawscore == scoreRaw)
                    songIcon = 6;
            }
            return songIcon;
        }


        public static function getSongIconIndexBitmask(_song:Object, _rank:Object):int
        {
            var songIcon:int = 0;
            if (_rank)
            {
                var arrows:int = _song.arrows;
                var scoreRaw:int = _song.scoreRaw;
                if (_rank.arrows > 0)
                {
                    arrows = _rank.arrows;
                    scoreRaw = arrows * 50;
                }
                // Played
                if (_rank.score > 0)
                    songIcon |= (1 << 0);

                // FC* - When current score isn't FC but a FC has been achieved before.
                if (_rank.fcs > 0)
                    songIcon |= (1 << 7);

                // FC
                if (_rank.perfect + _rank.good + _rank.average == arrows && _rank.miss == 0 && _rank.maxcombo == arrows)
                    songIcon |= (1 << 1);

                // SDG
                if (scoreRaw - _rank.rawscore < 250)
                    songIcon |= (1 << 2);

                // BlackFlag
                if (_rank.perfect == arrows - 1 && _rank.good == 1 && _rank.average == 0 && _rank.miss == 0 && _rank.boo == 0 && _rank.maxcombo == arrows)
                    songIcon |= (1 << 3);

                // BooFlag
                if (_rank.perfect == arrows && _rank.good == 0 && _rank.average == 0 && _rank.miss == 0 && _rank.boo == 1 && _rank.maxcombo == arrows)
                    songIcon |= (1 << 4);

                // AAA
                if (_rank.rawscore == scoreRaw)
                    songIcon |= (1 << 5);
            }
            return songIcon;
        }

        public static const SONG_ICON_TEXT:Array = ["<font color=\"#9C9C9C\">UNPLAYED</font>", "", "<font color=\"#00FF00\">FC</font>",
            "<font color=\"#f2a254\">SDG</font>", "<font color=\"#2C2C2C\">BLACKFLAG</font>",
            "<font color=\"#473218\">BOOFLAG</font>", "<font color=\"#FFFF38\">AAA</font>", "<font color=\"#00FF00\">FC*</font>"];

        public static const SONG_ICON_TEXT_FLAG:Array = ["Unplayed", "Played", "Full Combo",
            "Single Digit Good", "Blackflag", "Booflag", "AAA", "Full Combo*"];

        public static function getSongIcon(_song:Object, _rank:Object):String
        {
            return SONG_ICON_TEXT[getSongIconIndex(_song, _rank)];
        }

        //- ScreenShot Handling
        /**
         * Takes a screenshot of the stage and saves it to disk.
         */
        public function takeScreenShot(filename:String = null):void
        {
            // Create Bitmap of Stage
            var b:BitmapData = new BitmapData(Main.GAME_WIDTH, Main.GAME_HEIGHT, false, 0x000000);
            b.draw(gameMain.stage);

            try
            {
                var _file:FileReference = new FileReference();
                _file.save(PNGEncoder.encode(b), AirContext.createFileName((filename != null ? filename : "R^3 - " + DateUtil.toRFC822(new Date()).replace(/:/g, ".")) + ".png"));
            }
            catch (e:Error)
            {
                gameMain.addAlert("ERROR: Unable to save image.", 120);
            }
        }

        //- Full Screen
        public function toggleFullScreen(e:Event = null):void
        {
            if (gameMain.stage)
            {
                if (gameMain.stage.displayState == StageDisplayState.NORMAL)
                {
                    gameMain.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
                }
                else
                {
                    gameMain.stage.displayState = StageDisplayState.NORMAL;
                }
            }
        }

        ///- Constructor
        public function GlobalVariables(en:SingletonEnforcer)
        {
            if (en == null)
            {
                throw Error("Multi-Instance Blocked");
            }
        }

        public static function get instance():GlobalVariables
        {
            if (_instance == null)
            {
                _instance = new GlobalVariables(new SingletonEnforcer());
            }
            return _instance;
        }
    }
}

class SingletonEnforcer
{
}
