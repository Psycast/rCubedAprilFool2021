package game
{
    import arc.ArcGlobals;
    import classes.User;
    import classes.chart.Song;
    import classes.chart.parse.ChartBase;

    public class GameOptions extends Object
    {
        public var DISABLE_NOTE_POOL:Boolean = false;

        public static var ENGINE_TICK_RATE:Number = 30;
        public static var ENGINE_SCROLL_PIXELS:Number = 300;

        public var selectedChartID:int = 0;

        public var frameRate:int = 60;
        public var songRate:Number = 1;

        public var scrollDirection:String = "up";
        public var judgeSpeed:Number = 1;
        public var scrollSpeed:Number = 1.5;
        public var receptorSpacing:int = 80;
        public var receptorSplitSpacing:int = 0;
        public var receptorAnimationSpeed:Number = 1;
        public var noteScale:Number = 1;
        public var screencutPosition:Number = 0.5;
        public var mods:Array = [];
        public var noteskin:int = 1;

        public var offsetGlobal:Number = 0;
        public var offsetJudge:Number = 0;
        public var autoJudgeOffset:Boolean = false;

        public var displayGameTopBar:Boolean = true;
        public var displayGameBottomBar:Boolean = true;
        public var displayJudge:Boolean = true;
        public var displayJudgeAnimations:Boolean = true;
        public var displayReceptor:Boolean = true;
        public var displayReceptorAnimations:Boolean = true;
        public var displayHealth:Boolean = true;
        public var displayScore:Boolean = true;
        public var displayCombo:Boolean = true;
        public var displayComboTotal:Boolean = true;
        public var displayPA:Boolean = true;
        public var displayAmazing:Boolean = true;
        public var displayPerfect:Boolean = true;
        public var displayScreencut:Boolean = false;
        public var displaySongProgress:Boolean = true;

        public var enableBoos:Boolean = true;
        public var enableHolds:Boolean = true;
        public var enableMines:Boolean = true;
        public var enableFailure:Boolean = true;

        public var displayMP:Boolean = true;
        public var displayMPJudge:Boolean = true;
        public var displayMPPA:Boolean = true;
        public var displayMPCombo:Boolean = true;

        public var judgeColours:Array = [0x78ef29, 0x12e006, 0x01aa0f, 0xf99800, 0xfe0000, 0x804100, 0xFCC200, 0x990000];
        public var comboColours:Array = [0x0099CC, 0x00AD00, 0xFCC200, 0xC7FB30, 0x6C6C6C, 0xF99800, 0xB06100, 0x990000, 0xDC00C2]; // Normal, FC, AAA, SDG, BlackFlag, AvFlag, BooFlag, MissFlag, RawGood
        public var enableComboColors:Array = [true, true, true, false, false, false, false, false, false];
        public var gameColours:Array = [0x1495BD, 0x033242, 0x0C6A88, 0x074B62];
        public var noteDirections:Array = ['L', 'D', 'U', 'R'];
        public var noteColors:Array = ["red", "blue", "purple", "yellow", "pink", "orange", "cyan", "green", "white"];
        public var noteSwapColours:Object = {"red": "red", "blue": "blue", "purple": "purple", "yellow": "yellow", "pink": "pink", "orange": "orange", "cyan": "cyan", "green": "green", "white": "white"};
        public var rawGoodTracker:Number = 0;

        public var layout:Object = {};

        public var judgeWindow:Array = null;
        public var judgeHoldWindow:Array = null;

        public var song:Song = null;
        public var isEditor:Boolean = false;
        public var isAutoplay:Boolean = false;
        public var autofail:Array = [0, 0, 0, 0, 0, 0, 0];

        // Scalings
        public var scalingDizzyMod:Number = 360;

        public function setColumnCount(val:int):void
        {
            noteDirections = ChartBase.COLUMNS[val] || ChartBase.COLUMNS["4"];
        }

        public function fillFromUser(user:User):void
        {
            frameRate = user.frameRate;
            songRate = user.songRate;

            scrollDirection = user.slideDirection;
            judgeSpeed = user.judgeSpeed;
            scrollSpeed = user.gameSpeed;
            receptorSpacing = user.receptorGap;
            receptorSplitSpacing = user.receptorSplitGap;
            receptorAnimationSpeed = user.receptorAnimationSpeed;
            noteScale = user.noteScale;
            screencutPosition = user.screencutPosition;
            mods = user.activeMods.concat(user.activeVisualMods);
            modCache = null;
            noteskin = user.activeNoteskin;

            offsetGlobal = user.GLOBAL_OFFSET;
            offsetJudge = user.JUDGE_OFFSET;
            autoJudgeOffset = user.AUTO_JUDGE_OFFSET;

            enableBoos = user.enableBoos;
            enableHolds = user.enableHolds;
            enableMines = user.enableMines;
            enableFailure = user.enableFailure;

            displayJudge = user.DISPLAY_JUDGE;
            displayJudgeAnimations = user.DISPLAY_JUDGE_ANIMATIONS;
            displayReceptor = user.DISPLAY_RECEPTOR;
            displayReceptorAnimations = user.DISPLAY_RECEPTOR_ANIMATIONS;
            displayHealth = user.DISPLAY_HEALTH;
            displayGameTopBar = user.DISPLAY_GAME_TOP_BAR;
            displayGameBottomBar = user.DISPLAY_GAME_BOTTOM_BAR;
            displayScore = user.DISPLAY_SCORE;
            displayCombo = user.DISPLAY_COMBO;
            displayComboTotal = user.DISPLAY_TOTAL;
            displayPA = user.DISPLAY_PACOUNT;
            displayAmazing = user.DISPLAY_AMAZING;
            displayPerfect = user.DISPLAY_PERFECT;
            displayScreencut = user.DISPLAY_SCREENCUT;
            displaySongProgress = user.DISPLAY_SONGPROGRESS;

            judgeColours = user.judgeColours.concat();
            comboColours = user.comboColours.concat();
            enableComboColors = user.enableComboColors.concat();
            gameColours = user.gameColours.concat();
            rawGoodTracker = user.rawGoodTracker;

            for (var i:int = 0; i < noteColors.length; i++)
            {
                noteSwapColours[noteColors[i]] = user.noteColours[i];
            }

            autofail = [user.autofailAmazing,
                user.autofailPerfect,
                user.autofailGood,
                user.autofailAverage,
                user.autofailMiss,
                user.autofailBoo,
                user.autofailRawGoods];
        }

        public function fillFromArcGlobals():void
        {
            var avars:ArcGlobals = ArcGlobals.instance;

            var layoutKey:String = "sp";
            if (!avars.configInterface[layoutKey])
                avars.configInterface[layoutKey] = {};
            layout = avars.configInterface[layoutKey];
            layoutKey = scrollDirection;
            if (!layout[layoutKey])
                layout[layoutKey] = {};
            layout = layout[layoutKey];
        }

        public function fill():void
        {
            fillFromUser(GlobalVariables.instance.activeUser);
            fillFromArcGlobals();
        }

        public var modCache:Object = null;

        public function modEnabled(mod:String):Boolean
        {
            if (!modCache)
            {
                modCache = new Object();
                for each (var gameMod:String in mods)
                    modCache[gameMod] = true;
            }
            return mod in modCache;
        }

        public function settingsEncode():Object
        {
            var settings:Object = new Object();
            settings["viewOffset"] = offsetGlobal;
            settings["judgeOffset"] = offsetJudge;
            settings["autoJudgeOffset"] = autoJudgeOffset;
            settings["viewJudge"] = displayJudge;
            settings["viewHealth"] = displayHealth;
            settings["viewScore"] = displayScore;
            settings["viewCombo"] = displayCombo;
            settings["viewTotal"] = displayComboTotal;
            settings["viewPACount"] = displayPA;
            settings["viewAmazing"] = displayAmazing;
            settings["viewPerfect"] = displayPerfect;
            settings["viewScreencut"] = displayScreencut;
            settings["viewSongProgress"] = displaySongProgress;
            settings["speed"] = scrollSpeed;
            settings["judgeSpeed"] = judgeSpeed;
            settings["receptorAnimationSpeed"] = receptorAnimationSpeed;
            settings["direction"] = scrollDirection;
            settings["noteskin"] = noteskin;
            settings["gap"] = receptorSpacing;
            settings["noteScale"] = noteScale;
            settings["screencutPosition"] = screencutPosition;
            settings["songRate"] = songRate;
            settings["frameRate"] = frameRate;
            settings["visual"] = mods;
            settings["songRate"] = 1;

            // New - November 2016 Update
            settings["viewGameTopBar"] = displayGameTopBar;
            settings["viewGameBottomBar"] = displayGameBottomBar;
            settings["noteSwapColours"] = [];
            for (var i:int = 0; i < noteColors.length; i++)
            {
                settings["noteSwapColours"][i] = noteSwapColours[noteColors[i]];
            }

            var user:User = GlobalVariables.instance.activeUser;
            settings["keys"] = [user.keyLeft, user.keyDown, user.keyUp, user.keyRight, user.keyRestart, user.keyQuit, user.keyOptions];

            return settings;
        }

        public function isScoreValid(score:Boolean = true, replay:Boolean = true):Boolean
        {
            return true;
        }

        public function isScoreUpdated(score:Boolean = true, replay:Boolean = true):Boolean
        {
            return true;
        }

        public function getNewNoteColor(color:String):String
        {
            return noteSwapColours[color];
        }
    }
}
