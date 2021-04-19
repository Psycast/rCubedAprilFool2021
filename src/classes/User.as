/**
 * @author Jonathan (Velocity)
 */

package classes
{
    import arc.ArcGlobals;
    import com.flashfla.utils.ArrayUtil;
    import com.flashfla.utils.SoundUtils;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.media.SoundMixer;
    import flash.media.SoundTransform;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;
    import flash.ui.Keyboard;

    public class User extends EventDispatcher
    {
        //- Constants
        public static const ADMIN_ID:Number = 6;
        public static const DEVELOPER_ID:Number = 83;
        public static const BANNED_ID:Number = 8;
        public static const CHAT_MOD_ID:Number = 24;
        public static const FORUM_MOD_ID:Number = 5;
        public static const MULTI_MOD_ID:Number = 44;
        public static const MUSIC_PRODUCER_ID:Number = 46;
        public static const PROFILE_MOD_ID:Number = 56;
        public static const SIM_AUTHOR_ID:Number = 47;
        public static const VETERAN_ID:Number = 49;

        ///- Private Locals
        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _avars:ArcGlobals = ArcGlobals.instance;
        private var _loader:URLLoader;
        private var _isLoaded:Boolean = false;
        private var _isLoading:Boolean = false;
        private var _loadError:Boolean = false;

        //- User Vars
        public var name:String = "Guest";
        public var id:int = 0;
        public var groups:Array = [];
        public var language:String = "us";

        public var joinDate:String = "The Past";
        public var skillLevel:Number = 0;
        public var skillRating:Number = 0;
        public var gameRank:Number = 0;
        public var gamesPlayed:Number = 0;
        public var grandTotal:Number = 0;
        public var averageRank:Number = 0;
        public var avatar:Loader;

        //- Game Data
        public var GLOBAL_OFFSET:Number = 0;
        public var JUDGE_OFFSET:Number = 0;
        public var AUTO_JUDGE_OFFSET:Boolean = false;
        public var DISPLAY_JUDGE:Boolean = true;
        public var DISPLAY_JUDGE_ANIMATIONS:Boolean = true;
        public var DISPLAY_RECEPTOR:Boolean = true;
        public var DISPLAY_RECEPTOR_ANIMATIONS:Boolean = true;
        public var DISPLAY_HEALTH:Boolean = true;
        public var DISPLAY_GAME_TOP_BAR:Boolean = true;
        public var DISPLAY_GAME_BOTTOM_BAR:Boolean = true;
        public var DISPLAY_SCORE:Boolean = true;
        public var DISPLAY_COMBO:Boolean = true;
        public var DISPLAY_PACOUNT:Boolean = true;
        public var DISPLAY_AMAZING:Boolean = true;
        public var DISPLAY_PERFECT:Boolean = true;
        public var DISPLAY_TOTAL:Boolean = true;
        public var DISPLAY_SCREENCUT:Boolean = false;
        public var DISPLAY_SONGPROGRESS:Boolean = true;

        public var judgeColours:Array = [0x78ef29, 0x12e006, 0x01aa0f, 0xf99800, 0xfe0000, 0x804100, 0xFCC200, 0x990000];
        public var comboColours:Array = [0x0099CC, 0x00AD00, 0xFCC200, 0xC7FB30, 0x6C6C6C, 0xF99800, 0xB06100, 0x990000, 0xDC00C2]; // Normal, FC, AAA, SDG, BlackFlag, AvFlag, BooFlag, MissFlag, RawGood
        public var enableComboColors:Array = [true, true, true, false, false, false, false, false, false];
        public var gameColours:Array = [0x1495BD, 0x033242, 0x0C6A88, 0x074B62];
        public var noteColours:Object = ["red", "blue", "purple", "yellow", "pink", "orange", "cyan", "green", "white"];
        public var rawGoodTracker:Number = 0;

        public var autofailAmazing:int = 0;
        public var autofailPerfect:int = 0;
        public var autofailGood:int = 0;
        public var autofailAverage:int = 0;
        public var autofailMiss:int = 0;
        public var autofailBoo:int = 0;
        public var autofailRawGoods:Number = 0;
        public var autofailHoldOK:Number = 0;
        public var autofailHoldNG:Number = 0;

        public var keyLeft:int = Keyboard.LEFT;
        public var keyDown:int = Keyboard.DOWN;
        public var keyUp:int = Keyboard.UP;
        public var keyRight:int = Keyboard.RIGHT;
        public var keyRestart:int = Keyboard.SLASH;
        public var keyQuit:int = Keyboard.CONTROL;
        public var keyOptions:int = 145; // Scrolllock
        public var keyAutoplay:int = Keyboard.F8;

        public var enableBoos:Boolean = true;
        public var enableHolds:Boolean = true;
        public var enableMines:Boolean = true;
        public var enableFailure:Boolean = false;

        public var keyBuilder:Array = [{4: [Keyboard.LEFT, Keyboard.DOWN, Keyboard.UP, Keyboard.RIGHT],
                5: [Keyboard.A, Keyboard.S, Keyboard.SPACE, Keyboard.K, Keyboard.L],
                6: [Keyboard.A, Keyboard.S, Keyboard.D, Keyboard.J, Keyboard.K, Keyboard.L],
                7: [Keyboard.A, Keyboard.S, Keyboard.D, Keyboard.SPACE, Keyboard.J, Keyboard.K, Keyboard.L],
                8: [Keyboard.A, Keyboard.S, Keyboard.D, Keyboard.F, Keyboard.H, Keyboard.J, Keyboard.K, Keyboard.L],
                9: [Keyboard.A, Keyboard.S, Keyboard.D, Keyboard.F, Keyboard.G, Keyboard.H, Keyboard.J, Keyboard.K, Keyboard.L],
                10: [Keyboard.Q, Keyboard.W, Keyboard.E, Keyboard.R, Keyboard.T, Keyboard.Y, Keyboard.U, Keyboard.I, Keyboard.O, Keyboard.P]},
            {4: [0, 0, 0, 0],
                5: [0, 0, 0, 0, 0],
                6: [0, 0, 0, 0, 0, 0],
                7: [0, 0, 0, 0, 0, 0, 0],
                8: [0, 0, 0, 0, 0, 0, 0, 0],
                9: [0, 0, 0, 0, 0, 0, 0, 0, 0],
                10: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}];

        public var activeNoteskin:int = 1;
        public var activeMods:Array = [];
        public var activeVisualMods:Array = [];
        public var slideDirection:String = "up";
        public var judgeSpeed:Number = 1;
        public var gameSpeed:Number = 1.5;
        public var receptorGap:Number = 80;
        public var receptorSplitGap:Number = 0;
        public var receptorAnimationSpeed:Number = 1;
        public var noteScale:Number = 1;
        public var gameVolume:Number = 1;
        public var gameVolumeSoundTransform:SoundTransform;
        public var screencutPosition:Number = 0.5;
        public var frameRate:int = 60;
        public var songRate:Number = 1;

        //- Permissions
        public var isActiveUser:Boolean;
        public var isGuest:Boolean;
        public var isVeteran:Boolean;
        public var isAdmin:Boolean;
        public var isDeveloper:Boolean
        public var isForumBanned:Boolean;
        public var isGameBanned:Boolean;
        public var isProfileBanned:Boolean;
        public var isModerator:Boolean;
        public var isForumModerator:Boolean;
        public var isProfileModerator:Boolean;
        public var isChatModerator:Boolean;
        public var isMultiModerator:Boolean;
        public var isMusician:Boolean;
        public var isSimArtist:Boolean;

        ///- Constructor
        /**
         * Defines the creation of a new User object for the currect active user. Not to be confused with MPUser.
         *
         * @param	loadData Loads the user data on creation.
         * @param	isActiveUser Sets the active user flag.
         * @tiptext
         */
        public function User(loadData:Boolean = false, isActiveUser:Boolean = false, userid:int = -1):void
        {
            this.isActiveUser = isActiveUser;

            if (loadData)
            {
                if (userid > -1)
                {
                    loadUser(userid);
                }
                else
                {
                    load();
                }
            }
        }

        public function refreshUser():void
        {
            _gvars.userSession = "0";
            _gvars.playerUser = new User(true, true);
            _gvars.activeUser = _gvars.playerUser;
        }

        ///- Public
        ///- Profile Loading
        public function isLoaded():Boolean
        {
            return _isLoaded && !_loadError;
        }

        public function isError():Boolean
        {
            return _loadError;
        }

        public function load():void
        {
            // Kill old Loading Stream
            if (_loader && _isLoading)
            {
                removeLoaderListeners();
                _loader.close();
            }

            _isLoaded = false;
            _loadError = false;
            _loader = new URLLoader();
            addLoaderListeners();

            var req:URLRequest = new URLRequest(Constant.USER_INFO_URL + "?d=" + new Date().getTime());
            var requestVars:URLVariables = new URLVariables();
            Constant.addDefaultRequestVariables(requestVars);
            requestVars.session = _gvars.userSession;
            req.data = requestVars;
            req.method = URLRequestMethod.POST;
            _loader.load(req);
            _isLoading = true;
        }

        public function loadUser(userid:int):void
        {
            _isLoaded = false;
            _loader = new URLLoader();
            addLoaderListeners();

            var req:URLRequest = new URLRequest(Constant.USER_INFO_LITE_URL + "?d=" + new Date().getTime());
            var requestVars:URLVariables = new URLVariables();
            Constant.addDefaultRequestVariables(requestVars);
            requestVars.userid = userid;
            req.data = requestVars;
            req.method = URLRequestMethod.POST;
            _loader.load(req);
            _isLoading = true;
        }

        private function profileLoadComplete(e:Event):void
        {
            removeLoaderListeners();
            try
            {
                var _data:Object = JSON.parse(e.target.data);

                loadUserData(_data);

                _isLoaded = true;
                this.dispatchEvent(new Event(GlobalVariables.LOAD_COMPLETE));
            }
            catch (err:Error)
            {
                _loadError = true;
                this.dispatchEvent(new Event(GlobalVariables.LOAD_ERROR));
            }
        }

        public function loadUserData(_data:Object):void
        {
            // Public
            this.name = _data["name"];
            this.id = _data["id"];
            this.groups = _data["groups"];
            this.joinDate = _data["joinDate"];
            this.gameRank = _data["gameRank"];
            this.gamesPlayed = _data["gamesPlayed"];
            this.grandTotal = _data["grandTotal"];
            this.skillLevel = _data["skillLevel"];
            this.skillRating = _data["skillRating"];

            setupPermissions();

            // Load Avatar
            loadAvatar();

            // Only Input FFR settings once.
            var isNewLoginUser:Boolean = LocalStore.getVariable("last_known_userid", 0) != this.id;

            // Setup Settings from server or local
            if (isNewLoginUser && _data["settings"] != null && !this.isGuest)
                settings = JSON.parse(_data.settings);
            else
                loadLocal();

            // Store Current User ID to avoid loading server settings mutliple times.
            LocalStore.setVariable("last_known_userid", this.id);
        }

        private function profileLoadError(e:Event = null):void
        {
            removeLoaderListeners();
            _loadError = true;
            this.dispatchEvent(new Event(GlobalVariables.LOAD_ERROR));
        }

        private function addLoaderListeners():void
        {
            _loader.addEventListener(Event.COMPLETE, profileLoadComplete);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, profileLoadError);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, profileLoadError);
        }

        private function removeLoaderListeners():void
        {
            _isLoaded = false;
            _loader.removeEventListener(Event.COMPLETE, profileLoadComplete);
            _loader.removeEventListener(IOErrorEvent.IO_ERROR, profileLoadError);
            _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, profileLoadError);
        }

        private function setupPermissions():void
        {
            this.isGuest = (this.id <= 2);
            this.isVeteran = ArrayUtil.in_array(this.groups, [VETERAN_ID]);
            this.isAdmin = ArrayUtil.in_array(this.groups, [ADMIN_ID]);
            this.isDeveloper = ArrayUtil.in_array(this.groups, [DEVELOPER_ID])
            this.isForumBanned = ArrayUtil.in_array(this.groups, [BANNED_ID]);
            this.isModerator = ArrayUtil.in_array(this.groups, [ADMIN_ID, FORUM_MOD_ID, CHAT_MOD_ID, PROFILE_MOD_ID, MULTI_MOD_ID]);
            this.isForumModerator = ArrayUtil.in_array(this.groups, [FORUM_MOD_ID, ADMIN_ID]);
            this.isProfileModerator = ArrayUtil.in_array(this.groups, [PROFILE_MOD_ID, ADMIN_ID]);
            this.isChatModerator = ArrayUtil.in_array(this.groups, [CHAT_MOD_ID, ADMIN_ID]);
            this.isMultiModerator = ArrayUtil.in_array(this.groups, [MULTI_MOD_ID, ADMIN_ID]);
            this.isMusician = ArrayUtil.in_array(this.groups, [MUSIC_PRODUCER_ID]);
            this.isSimArtist = ArrayUtil.in_array(this.groups, [SIM_AUTHOR_ID]);
        }

        public function loadAvatar():void
        {
            this.avatar = new Loader();
            if (isActiveUser && this.id > 2)
            {
                this.avatar.contentLoaderInfo.addEventListener(Event.COMPLETE, avatarLoadComplete);

                function avatarLoadComplete(e:Event):void
                {
                    LocalStore.setVariable("uAvatar", LoaderInfo(e.target).bytes);
                    avatar.removeEventListener(Event.COMPLETE, avatarLoadComplete);
                }
            }
            this.avatar.load(new URLRequest(Constant.USER_AVATAR_URL + "?uid=" + this.id + "&cHeight=99&cWidth=99"));
        }

        ///- Settings
        public function get settings():Object
        {
            return save(true);
        }

        public function set settings(_settings:Object):void
        {
            if (_settings == null)
                return;

            var arrLen:int;
            var i:int;

            if (_settings.viewOffset != null)
                this.GLOBAL_OFFSET = _settings.viewOffset;
            if (_settings.judgeOffset != null)
                this.JUDGE_OFFSET = _settings.judgeOffset;
            if (_settings.autoJudgeOffset != null)
                this.AUTO_JUDGE_OFFSET = _settings.autoJudgeOffset;
            if (_settings.viewJudge != null)
                this.DISPLAY_JUDGE = _settings.viewJudge;
            if (_settings.viewJudgeAnimations != null)
                this.DISPLAY_JUDGE_ANIMATIONS = _settings.viewJudgeAnimations;
            if (_settings.viewReceptor != null)
                this.DISPLAY_RECEPTOR = _settings.viewReceptor;
            if (_settings.viewReceptorAnimations != null)
                this.DISPLAY_RECEPTOR_ANIMATIONS = _settings.viewReceptorAnimations;
            if (_settings.viewHealth != null)
                this.DISPLAY_HEALTH = _settings.viewHealth;
            if (_settings.viewGameTopBar != null)
                this.DISPLAY_GAME_TOP_BAR = _settings.viewGameTopBar;
            if (_settings.viewGameBottomBar != null)
                this.DISPLAY_GAME_BOTTOM_BAR = _settings.viewGameBottomBar;
            if (_settings.viewScore != null)
                this.DISPLAY_SCORE = _settings.viewScore;
            if (_settings.viewCombo != null)
                this.DISPLAY_COMBO = _settings.viewCombo;
            if (_settings.viewPACount != null)
                this.DISPLAY_PACOUNT = _settings.viewPACount;
            if (_settings.viewAmazing != null)
                this.DISPLAY_AMAZING = _settings.viewAmazing;
            if (_settings.viewPerfect != null)
                this.DISPLAY_PERFECT = _settings.viewPerfect;
            if (_settings.viewTotal != null)
                this.DISPLAY_TOTAL = _settings.viewTotal;
            if (_settings.viewScreencut != null)
                this.DISPLAY_SCREENCUT = _settings.viewScreencut;
            if (_settings.viewSongProgress != null)
                this.DISPLAY_SONGPROGRESS = _settings.viewSongProgress;

            if (_settings.enableBoos != null)
                this.enableBoos = _settings.enableBoos;
            if (_settings.enableFailure != null)
                this.enableFailure = _settings.enableFailure;
            if (_settings.enableHolds != null)
                this.enableHolds = _settings.enableHolds;
            if (_settings.enableMines != null)
                this.enableMines = _settings.enableMines;

            if (_settings.noteskin != null)
                this.activeNoteskin = _settings.noteskin;
            if (_settings.direction != null)
                this.slideDirection = _settings.direction;
            if (_settings.speed != null)
                this.gameSpeed = _settings.speed;
            if (_settings.judgeSpeed != null)
                this.judgeSpeed = _settings.judgeSpeed;
            if (_settings.gap != null)
                this.receptorGap = _settings.gap;
            if (_settings.split_gap != null)
                this.receptorSplitGap = _settings.split_gap;
            if (_settings.noteScale != null)
                this.noteScale = _settings.noteScale;
            if (_settings.screencutPosition != null)
                this.screencutPosition = _settings.screencutPosition;
            if (_settings.frameRate != null)
                this.frameRate = _settings.frameRate;
            if (_settings.songRate != null)
                this.songRate = _settings.songRate;
            if (_settings.visual != null)
                this.activeVisualMods = _settings.visual;
            if (_settings.comboColours != null)
            {
                arrLen = Math.min(this.judgeColours.length, _settings.judgeColours.length);
                for (i = 0; i < arrLen; i++)
                {
                    this.judgeColours[i] = _settings.judgeColours[i];
                }
            }
            if (_settings.comboColours != null)
            {
                arrLen = Math.min(this.comboColours.length, _settings.comboColours.length);
                for (i = 0; i < arrLen; i++)
                {
                    this.comboColours[i] = _settings.comboColours[i];
                }
            }
            if (_settings.enableComboColors != null)
            {
                for (i = 0; i < enableComboColors.length; i++)
                {
                    this.enableComboColors[i] = _settings.enableComboColors[i];
                }
            }
            if (_settings.gameColours != null)
                this.gameColours = _settings.gameColours;
            if (_settings.noteColours != null)
                this.noteColours = _settings.noteColours;
            if (_settings.rawGoodTracker != null)
                this.rawGoodTracker = _settings.rawGoodTracker;
            if (_settings.gameVolume != null)
            {
                this.gameVolume = _settings.gameVolume;
                this.gameVolumeSoundTransform = new SoundTransform(SoundUtils.getVolume(this.gameVolume));
            }

            // MultiInput
            if (_settings.keyBuilder != null)
            {
                var keyColumn:String;
                var keyGroups:int = Math.min(keyBuilder.length, _settings.keyBuilder.length);
                for (i = 0; i < keyGroups; i++)
                {
                    for (keyColumn in _settings.keyBuilder[i])
                    {
                        this.keyBuilder[i][keyColumn] = _settings.keyBuilder[i][keyColumn];
                    }
                }
            }
            // Backup From Old Setup
            else
            {
                if (_settings.keys[0] != null)
                {
                    this.keyLeft = _settings.keys[0];
                    this.keyBuilder[0][4][0] = _settings.keys[0];
                }
                if (_settings.keys[1] != null)
                {
                    this.keyDown = _settings.keys[1];
                    this.keyBuilder[0][4][1] = _settings.keys[1];
                }
                if (_settings.keys[2] != null)
                {
                    this.keyUp = _settings.keys[2];
                    this.keyBuilder[0][4][2] = _settings.keys[2];
                }
                if (_settings.keys[3] != null)
                {
                    this.keyRight = _settings.keys[3];
                    this.keyBuilder[0][4][3] = _settings.keys[3];
                }
            }

            // Global Keys
            if (_settings.keys[4] != null)
                this.keyRestart = _settings.keys[4];
            if (_settings.keys[5] != null)
                this.keyQuit = _settings.keys[5];
            if (_settings.keys[6] != null)
                this.keyOptions = _settings.keys[6];
            if (_settings.keys[7] != null)
                this.keyAutoplay = _settings.keys[7];

            if (isActiveUser)
                SoundMixer.soundTransform = gameVolumeSoundTransform;

            if (_gvars.SCROLL_DIRECTIONS.indexOf(this.slideDirection) == -1)
                this.slideDirection = _gvars.SCROLL_DIRECTIONS[0];
        }

        public function save(returnObject:Boolean = false):Object
        {
            if (id <= 2 && !returnObject)
                return {};

            var gameSave:Object = new Object();
            gameSave.viewOffset = this.GLOBAL_OFFSET;
            gameSave.judgeOffset = this.JUDGE_OFFSET;
            gameSave.autoJudgeOffset = this.AUTO_JUDGE_OFFSET;
            gameSave.viewJudge = this.DISPLAY_JUDGE;
            gameSave.viewJudgeAnimations = this.DISPLAY_JUDGE_ANIMATIONS;
            gameSave.viewReceptor = this.DISPLAY_RECEPTOR;
            gameSave.viewReceptorAnimations = this.DISPLAY_RECEPTOR_ANIMATIONS;
            gameSave.viewHealth = this.DISPLAY_HEALTH;
            gameSave.viewGameTopBar = this.DISPLAY_GAME_TOP_BAR;
            gameSave.viewGameBottomBar = this.DISPLAY_GAME_BOTTOM_BAR;
            gameSave.viewScore = this.DISPLAY_SCORE;
            gameSave.viewCombo = this.DISPLAY_COMBO;
            gameSave.viewPACount = this.DISPLAY_PACOUNT;
            gameSave.viewAmazing = this.DISPLAY_AMAZING;
            gameSave.viewPerfect = this.DISPLAY_PERFECT;
            gameSave.viewTotal = this.DISPLAY_TOTAL;
            gameSave.viewScreencut = this.DISPLAY_SCREENCUT;
            gameSave.viewSongProgress = this.DISPLAY_SONGPROGRESS;

            gameSave.enableBoos = this.enableBoos;
            gameSave.enableFailure = this.enableFailure;
            gameSave.enableHolds = this.enableHolds;
            gameSave.enableMines = this.enableMines;

            gameSave.keys = [this.keyBuilder[0][4][0], this.keyBuilder[0][4][1], this.keyBuilder[0][4][2], this.keyBuilder[0][4][3], this.keyRestart, this.keyQuit, this.keyOptions, this.keyAutoplay];
            gameSave.keyBuilder = this.keyBuilder;

            gameSave.judgeSpeed = this.judgeSpeed;
            gameSave.speed = this.gameSpeed;
            gameSave.direction = this.slideDirection;
            gameSave.noteskin = this.activeNoteskin;
            gameSave.gap = this.receptorGap;
            gameSave.split_gap = this.receptorSplitGap;
            gameSave.noteScale = this.noteScale;
            gameSave.screencutPosition = this.screencutPosition;
            gameSave.frameRate = this.frameRate;
            gameSave.visual = this.activeVisualMods;
            gameSave.judgeColours = this.judgeColours;
            gameSave.comboColours = this.comboColours;
            gameSave.enableComboColors = this.enableComboColors;
            gameSave.gameColours = this.gameColours;
            gameSave.noteColours = this.noteColours;
            gameSave.rawGoodTracker = this.rawGoodTracker;
            gameSave.gameVolume = this.gameVolume;

            if (returnObject)
                return gameSave;

            return {};
        }

        public function saveLocal():void
        {
            LocalStore.setVariable("sEncode", JSON.stringify(save(true)));
            LocalStore.flush();
        }

        public function loadLocal():void
        {
            var encodedSettings:String = LocalStore.getVariable("sEncode", null);
            if (encodedSettings != null)
            {
                try
                {
                    settings = JSON.parse(encodedSettings);
                }
                catch (e:Error)
                {

                }
            }
        }
    }
}
