package game
{
    import arc.ArcGlobals;
    import assets.gameplay.viewUD;
    import classes.Alert;
    import classes.Language;
    import classes.Noteskins;
    import classes.chart.LevelScriptRuntime;
    import classes.chart.Note;
    import classes.chart.NoteHold;
    import classes.chart.NoteMine;
    import classes.chart.Song;
    import classes.chart.levels.EmbedChartBase;
    import classes.replay.ReplayNote;
    import classes.ui.BoxButton;
    import classes.ui.ProgressBar;
    import com.flashfla.utils.Average;
    import com.flashfla.utils.RollingAverage;
    import com.flashfla.utils.TimeUtil;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.GradientType;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.PerspectiveProjection;
    import flash.geom.Rectangle;
    import flash.net.URLLoader;
    import flash.ui.Mouse;
    import flash.utils.getTimer;
    import game.controls.Combo;
    import game.controls.ComboStatic;
    import game.controls.GameNote;
    import game.controls.GameNoteHold;
    import game.controls.GameNoteMine;
    import game.controls.Judge;
    import game.controls.LifeBar;
    import game.controls.NoteBox;
    import game.controls.PAWindow;
    import game.controls.Score;
    import menu.MenuPanel;
    import scripts.DarkMatterScript;
    import scripts.NyancatForeverScript;
    import scripts.SansBattleScript;

    public class GamePlay extends MenuPanel
    {
        public static const GAME_DISPOSE:int = -1;
        public static const GAME_PLAY:int = 0;
        public static const GAME_END:int = 1;
        public static const GAME_RESTART:int = 2;
        public static const GAME_PAUSE:int = 3;

        public static const LAYOUT_RECEPTORS:String = "receptors";
        public static const LAYOUT_JUDGE:String = "judge";
        public static const LAYOUT_HEALTH:String = "health";
        public static const LAYOUT_SCORE:String = "score";
        public static const LAYOUT_COMBO:String = "combo";
        public static const LAYOUT_COMBO_TOTAL:String = "combototal";
        public static const LAYOUT_COMBO_STATIC:String = "combostatic";
        public static const LAYOUT_COMBO_TOTAL_STATIC:String = "combototalstatic";
        public static const LAYOUT_PA:String = "pa";

        public static const LAYOUT_MP_JUDGE:String = "mpjudge";
        public static const LAYOUT_MP_COMBO:String = "mpcombo";
        public static const LAYOUT_MP_PA:String = "mppa";
        public static const LAYOUT_MP_HEADER:String = "mpheader";

        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _avars:ArcGlobals = ArcGlobals.instance;
        private var _noteskins:Noteskins = Noteskins.instance;
        private var _lang:Language = Language.instance;
        private var _loader:URLLoader;
        public var _keys:Array;
        public var _dirs:Array;
        public var song:Song;
        public var song_background:MovieClip;
        public var levelScript:LevelScriptRuntime;

        public var keyToColumn:Object = {};

        public var defaultLayout:Object;

        public var displayBlackBG:Sprite;
        public var gameplayUI:viewUD;
        public var progressDisplay:ProgressBar;
        public var noteBox:NoteBox;
        public var noteBoxContainer:Sprite;
        public var paWindow:PAWindow;
        public var score:Score;
        public var combo:Combo;
        public var comboTotal:Combo;
        public var comboStatic:ComboStatic;
        public var comboTotalStatic:ComboStatic;
        public var screenCut:Sprite;
        public var flashLight:Sprite;
        public var exitEditor:BoxButton;
        public var resetEditor:BoxButton;

        public var player1Life:LifeBar;
        public var player1Judge:Judge;
        public var player1JudgeOffset:int;

        private var mpHeader:Array;
        private var mpCombo:Array;
        private var mpJudge:Array;
        private var mpPA:Array;

        public var msStartTime:Number = 0;
        public var absoluteStart:int = 0;
        public var absolutePosition:int = 0;
        public var songPausePosition:int = 0;
        public var songDelay:int = 0;
        public var songDelayStarted:Boolean = false;
        public var songOffset:RollingAverage;
        public var frameRate:RollingAverage;
        public var gamePosition:int = 0;
        public var gameProgress:int = 0;
        public var globalOffset:int = 0;
        public var globalOffsetRounded:int = 0;
        public var accuracy:Average;
        public var judgeOffset:int = 0;
        public var autoJudgeOffset:Boolean = false;
        public var judgeSettings:Array;
        public var judgeHoldSettings:Array;
        public var judgeMissTime:int;
        public var judgeHoldMissTime:int;

        public var quitDoubleTap:int = -1;
        public var inputDisabled:Boolean = false;

        public var disablePause:Boolean = false;
        public var disableRestart:Boolean = false;

        public var options:GameOptions;

        public var gameLastNoteTime:Number;
        public var gameFirstNoteFrame:Number;
        public var gameSongFrames:int;

        public var gameLife:int;
        public var gameScore:int;
        public var gameRawGoods:Number;
        public var gameReplay:Array;

        /** Contains a list of scores or other flags used in replay_hit.
         * The value is either:
         * [100]  Amazing
         * [50]   Perfect
         * [25]   Good
         * [5]    Average
         * [0]    Miss & Boo
         * [-5]   Missed Note After End Game
         * [-10]  End of Replay Hit Tag
         */
        private var gameReplayHit:Array;

        private var binReplayNotes:Array;
        private var binReplayBoos:Array;

        private var replayPressCount:Number = 0;

        public var hitAmazing:int;
        public var hitPerfect:int;
        public var hitGood:int;
        public var hitAverage:int;
        public var hitMiss:int;
        public var hitBoo:int;
        public var hitCombo:int;
        public var hitMaxCombo:int;

        public var hitHoldOK:int;
        public var hitHoldNG:int;

        private var noteBoxOffset:Object = {"x": 0, "y": 0};
        private var noteBoxPositionDefault:Object;

        private var autoPlayCounter:int = 0;

        public var GAME_STATE:uint = GAME_PLAY;

        private var SOCKET_SONG_MESSAGE:Object = {};
        private var SOCKET_SCORE_MESSAGE:Object = {};

        // Anti-GPU Rampdown Hack
        private var GPU_PIXEL_BMD:BitmapData;
        private var GPU_PIXEL_BITMAP:Bitmap;

        private var myPerspective:PerspectiveProjection = new PerspectiveProjection();

        public function GamePlay(myParent:MenuPanel)
        {
            super(myParent);
        }

        override public function init():Boolean
        {
            options = _gvars.options;
            song = options.song;

            // Per Level Scripts
            var ls:String = song.entry.levelscript || "";
            if (ls == "NyanCat")
                levelScript = new LevelScriptRuntime(this, new NyancatForeverScript());
            else if (ls == "SansBattle")
                levelScript = new LevelScriptRuntime(this, new SansBattleScript());
            else if (ls == "DarkMatter" && Flags.ANTIMATTER)
                levelScript = new LevelScriptRuntime(this, new DarkMatterScript());

            // Init
            if (!options.isEditor)
                options.setColumnCount((song.entry.embedData as EmbedChartBase).getColumnCount(options.selectedChartID) || 4);

            if (!options.isEditor && song.chart.Notes.length == 0)
            {
                _gvars.gameMain.addAlert("Chart has no notes, returning to main menu...", 120, Alert.RED);
                switchTo(Main.GAME_MENU_PANEL);
                return false;
            }

            // Setup Keys
            var noteDirs:Array = options.noteDirections;
            var keyBuilder:Array = _gvars.activeUser.keyBuilder;
            for (var n:int = 0; n < keyBuilder.length; n++)
            {
                var keySet:Object = keyBuilder[n][noteDirs.length]
                for (var i:int = 0; i < noteDirs.length; i++)
                {
                    if (keySet[i] != 0)
                        keyToColumn[keySet[i]] = noteDirs[i];
                }
            }
            return true;
        }

        // protected function initStage3D(e:Event):void
        // {
        //     // //var context3D:Context3D = stage.stage3Ds[0].context3D;
        //     //context3D.createProgram()		
        // }

        override public function stageAdd():void
        {
            if (_gvars.menuMusic)
                _gvars.menuMusic.stop();

            // Create Background
            initBackground();
            initPlayerVars();

            // Init Core
            initCore();

            if (options.isEditor)
            {
                options.isAutoplay = true;
                stage.frameRate = options.frameRate;
                stage.addEventListener(Event.ENTER_FRAME, editorOnEnterFrame, false, int.MAX_VALUE, true);
            }
            else
            {
                stage.frameRate = song.frameRate;
                stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, int.MAX_VALUE - 10, true);
                stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardKeyDown, false, int.MAX_VALUE - 10, true);
                stage.addEventListener(KeyboardEvent.KEY_UP, keyboardKeyUp, false, int.MAX_VALUE - 10, true);
            }

            // Prebuild Websocket Message, this is updated instead of creating a new object every message.
            SOCKET_SONG_MESSAGE = {"player": {
                        "settings": options.settingsEncode(),
                        "name": _gvars.activeUser.name,
                        "userid": _gvars.activeUser.id,
                        "avatar": Constant.USER_AVATAR_URL + "?uid=" + _gvars.activeUser.id,
                        "skill_rating": _gvars.activeUser.skillRating,
                        "skill_level": _gvars.activeUser.skillLevel,
                        "game_rank": _gvars.activeUser.gameRank,
                        "game_played": _gvars.activeUser.gamesPlayed,
                        "game_grand_total": _gvars.activeUser.grandTotal
                    },
                    "engine": (song.entry.engine == null ? null : {"id": song.entry.engine.id,
                            "name": song.entry.engine.name,
                            "config": song.entry.engine.config_url,
                            "domain": song.entry.engine.domain})
                    ,
                    "song": {
                        "name": song.entry.name,
                        "level": song.entry.level,
                        "difficulty": song.entry.difficulty,
                        "style": song.entry.style,
                        "author": song.entry.author,
                        "author_url": song.entry.author_url,
                        "stepauthor": song.entry.stepauthor,
                        "genre": song.entry.genre,
                        "nps_min": song.entry.min_nps,
                        "nps_max": song.entry.max_nps,
                        "release_date": song.entry.releasedate,
                        "song_rating": song.entry.song_rating,
                        // Trust the chart, not the playlist.
                        "time": song.chartTimeFormatted,
                        "time_seconds": song.chartTime,
                        "note_count": song.totalNotes,
                        "nps_avg": (song.totalNotes / song.chartTime)
                    },
                    "best_score": null};

            SOCKET_SCORE_MESSAGE = {"amazing": 0,
                    "perfect": 0,
                    "good": 0,
                    "average": 0,
                    "miss": 0,
                    "boo": 0,
                    "score": 0,
                    "combo": 0,
                    "maxcombo": 0,
                    "restarts": 0,
                    "last_hit": null};

            // Set Defaults for Editor Mode
            if (options.isEditor)
            {
                SOCKET_SONG_MESSAGE["song"]["name"] = "Editor Mode";
                SOCKET_SONG_MESSAGE["song"]["author"] = "rCubed Engine";
                SOCKET_SONG_MESSAGE["song"]["difficulty"] = 0;
                SOCKET_SONG_MESSAGE["song"]["time"] = "10:00";
                SOCKET_SONG_MESSAGE["song"]["time_seconds"] = 600;
            }

            // Init Game
            initUI();
            initVars();

            // Preload next Song
            if (_gvars.songQueue.length > 0)
            {
                _gvars.getSongFile(_gvars.songQueue[0]);
            }

            stage.focus = this.stage;

            interfaceSetup();

            _gvars.gameMain.disablePopups = true;

            if (!options.isEditor)
                Mouse.hide();
        }

        override public function stageRemove():void
        {
            stage.frameRate = 60;
            if (options.isEditor)
            {
                options.isEditor = false;
                _gvars.activeUser.screencutPosition = options.screencutPosition;
                stage.removeEventListener(Event.ENTER_FRAME, editorOnEnterFrame);
            }
            else
            {
                stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardKeyDown);
                stage.removeEventListener(KeyboardEvent.KEY_UP, keyboardKeyUp);
            }

            _gvars.gameMain.disablePopups = false;

            Mouse.show();
        }

        /*#########################################################################################*\
         *       _____       _ _   _       _ _
         *       \_   \_ __ (_) |_(_) __ _| (_)_______
         *	     / /\/ '_ \| | __| |/ _` | | |_  / _ \
         *	  /\/ /_ | | | | | |_| | (_| | | |/ /  __/
         *	  \____/ |_| |_|_|\__|_|\__,_|_|_/___\___|
         *
           \*#########################################################################################*/

        private function initCore():void
        {
            song.updateMusicDelay();
            songDelay = -globalOffset;
        }

        private function initBackground():void
        {
            // Anti-GPU Rampdown Hack
            GPU_PIXEL_BMD = new BitmapData(1, 1, false, 0x010101);
            GPU_PIXEL_BITMAP = new Bitmap(GPU_PIXEL_BMD);
            this.addChild(GPU_PIXEL_BITMAP);
        }

        private function initUI():void
        {
            noteBox = new NoteBox(song, options);
            noteBox.position();

            noteBoxContainer = new Sprite();
            noteBoxContainer.x = Main.GAME_WIDTH / 2;
            noteBoxContainer.y = Main.GAME_HEIGHT / 2;
            noteBoxContainer.addChild(noteBox);

            //myPerspective.fieldOfView = 140;
            //myPerspective.projectionCenter = new Point(340, 190);
            //noteBoxContainer.transform.perspectiveProjection = myPerspective;

            this.addChild(noteBoxContainer);

            buildFlashlight();

            buildScreenCut();

            gameplayUI = new viewUD();
            this.addChild(gameplayUI);

            if (!options.displayGameTopBar)
                gameplayUI.top_bar.visible = false;

            if (!options.displayGameBottomBar)
                gameplayUI.bottom_bar.visible = false;

            if (options.displayPA)
            {
                paWindow = new PAWindow(options, (song.chart.Holds.length > 0));
                this.addChild(paWindow);
            }

            if (options.displayScore)
            {
                score = new Score(options);
                this.addChild(score);
            }

            if (options.displayCombo)
            {
                combo = new Combo(options);
                combo.alignment = Combo.ALIGN_RIGHT;
                this.addChild(combo);

                comboStatic = new ComboStatic(_lang.string("game_combo"));
                this.addChild(comboStatic);
            }

            if (options.displayComboTotal)
            {
                comboTotal = new Combo(options);
                this.addChild(comboTotal);

                comboTotalStatic = new ComboStatic(_lang.string("game_combo_total"));
                this.addChild(comboTotalStatic);
            }

            if (options.displaySongProgress)
            {
                progressDisplay = new ProgressBar(gameplayUI, 161, 9.35, 458, 20, 4, 0x545454, 0.1);
            }

            buildJudge();
            buildHealth();

            if (options.isEditor)
            {
                gameplayUI.mouseChildren = false;
                gameplayUI.mouseEnabled = false;

                function closeEditor(e:MouseEvent):void
                {
                    GAME_STATE = GAME_END;
                }

                function resetLayout(e:MouseEvent):void
                {
                    for (var key:String in options.layout)
                        delete options.layout[key];
                    _avars.interfaceSave();
                    interfaceSetup();
                }

                exitEditor = new BoxButton(this, (Main.GAME_WIDTH - 75) / 2, (Main.GAME_HEIGHT - 30) / 2, 75, 30, _lang.string("menu_close"), 12, closeEditor);
                resetEditor = new BoxButton(this, exitEditor.x, exitEditor.y + 35, 75, 30, _lang.string("menu_reset"), 12, resetLayout);
            }
        }

        private function initPlayerVars():void
        {
            player1JudgeOffset = Math.round(options.offsetJudge);
            globalOffsetRounded = Math.round(options.offsetGlobal);
            globalOffset = (options.offsetGlobal - globalOffsetRounded) * 1000 / GameOptions.ENGINE_TICK_RATE;

            if (options.judgeWindow)
                judgeSettings = options.judgeWindow;
            else
                judgeSettings = Constant.JUDGE_WINDOW;

            if (options.judgeHoldWindow)
                judgeHoldSettings = options.judgeHoldWindow;
            else
                judgeHoldSettings = Constant.HOLD_JUDGE_WINDOW;

            judgeOffset = options.offsetJudge * 1000 / GameOptions.ENGINE_TICK_RATE;
            autoJudgeOffset = options.autoJudgeOffset;
        }

        private function initVars(postStart:Boolean = true):void
        {
            inputDisabled = false;

            // Game Vars
            _keys = [];
            _dirs = [];
            gameLife = 50;
            gameScore = 0;
            gameRawGoods = 0;
            gameReplay = [];
            gameReplayHit = [];

            binReplayNotes = [];
            binReplayBoos = [];

            replayPressCount = 0;

            hitAmazing = 0;
            hitPerfect = 0;
            hitGood = 0;
            hitAverage = 0;
            hitMiss = 0;
            hitBoo = 0;
            hitCombo = 0;
            hitMaxCombo = 0;

            hitHoldOK = 0;
            hitHoldNG = 0;

            judgeMissTime = judgeSettings[judgeSettings.length - 1]["t"];
            judgeHoldMissTime = judgeHoldSettings[judgeHoldSettings.length - 1]["t"];

            updateHealth(0);
            if (song != null && song.totalNotes > 0)
            {
                gameLastNoteTime = song.getNote(song.totalNotes - 1).time;
                gameFirstNoteFrame = song.getNote(0).frame;

                if (song.totalHolds > 0)
                {
                    var lastHold:NoteHold;
                    for (var i:int = 0; i < song.totalHolds; i++)
                    {
                        lastHold = song.getHold(i);
                        gameLastNoteTime = Math.max(gameLastNoteTime, lastHold.time + lastHold.tail);
                    }
                }

                if (song.totalMines > 0)
                {
                    var lastMine:NoteMine = song.getMine(song.totalMines - 1);
                    gameLastNoteTime = Math.max(gameLastNoteTime, lastMine.time);
                }

                gameLastNoteTime *= 1000;
            }
            if (comboTotal)
                comboTotal.update(song.totalNotes);

            msStartTime = getTimer();
            absoluteStart = getTimer();
            gamePosition = 0;
            gameProgress = 0;
            absolutePosition = 0;
            if (song != null)
            {
                songOffset = new RollingAverage(song.frameRate * 4, _avars.configMusicOffset);
                frameRate = new RollingAverage(song.frameRate * 4, song.frameRate);
            }
            accuracy = new Average();

            songDelayStarted = false;

            updateFieldVars();

            if (options.isAutoplay)
                autoPlayCounter++;

            // Handle Early Charts - Pad Charts till atleast 3 seconds before first note.
            if (song != null && song.totalNotes > 0)
            {
                var firstNote:Note = song.getNote(0);
                if (firstNote.time < 3)
                    absoluteStart += (3 - firstNote.time) * 1000;
            }

            // Websocket
            if (_gvars.air_useWebsockets && postStart)
            {
                SOCKET_SCORE_MESSAGE["amazing"] = hitAmazing;
                SOCKET_SCORE_MESSAGE["perfect"] = hitPerfect;
                SOCKET_SCORE_MESSAGE["good"] = hitGood;
                SOCKET_SCORE_MESSAGE["average"] = hitAverage;
                SOCKET_SCORE_MESSAGE["boo"] = hitBoo;
                SOCKET_SCORE_MESSAGE["miss"] = hitMiss;
                SOCKET_SCORE_MESSAGE["holdok"] = hitHoldOK;
                SOCKET_SCORE_MESSAGE["holdng"] = hitHoldNG;
                SOCKET_SCORE_MESSAGE["combo"] = hitCombo;
                SOCKET_SCORE_MESSAGE["maxcombo"] = hitMaxCombo;
                SOCKET_SCORE_MESSAGE["score"] = gameScore;
                SOCKET_SCORE_MESSAGE["last_hit"] = null;
                SOCKET_SCORE_MESSAGE["restarts"] = _gvars.songRestarts;
                _gvars.websocketSend("NOTE_JUDGE", SOCKET_SCORE_MESSAGE);
                _gvars.websocketSend("SONG_START", SOCKET_SONG_MESSAGE);
            }
        }

        /*#########################################################################################*\
         *        __                 _
         *       /__\_   _____ _ __ | |_ ___
         *      /_\ \ \ / / _ \ '_ \| __/ __|
         *     //__  \ V /  __/ | | | |_\__ \
         *     \__/   \_/ \___|_| |_|\__|___/
         *
           \*#########################################################################################*/

        private function logicTick():void
        {
            gameProgress++;

            // Anti-GPU Rampdown Hack:
            // By doing a sparse but steady amount of screen updates using a single pixel in the
            // top left, the GPU is kept active on laptops. This fixes the issue when a skip can
            // appear to happen when the GPU re-awakes to begin drawing updates after a break in
            // a song.
            if (gameProgress % 15 == 0)
            {
                if ((gameProgress & 1) == 0)
                    GPU_PIXEL_BMD.setPixel(0, 0, 0x010101);
                else
                    GPU_PIXEL_BMD.setPixel(0, 0, 0x020202);
            }

            if (options.modEnabled("bleed") && gameProgress % 9 == 0)
            {
                // Not too early, not to late.
                if (gameProgress > gameFirstNoteFrame && gamePosition < gameLastNoteTime)
                    updateHealth(-1);
            }

            if (levelScript != null)
                levelScript.doProgressTick(gameProgress);

            if (quitDoubleTap > 0)
            {
                quitDoubleTap--;
            }

            if (gamePosition >= gameLastNoteTime + 3000 || quitDoubleTap == 0)
            {
                GAME_STATE = GAME_END;
                return;
            }

            var notes:Array = noteBox.notes;
            for (var n:int = 0; n < notes.length; n++)
            {
                var curNote:GameNote = notes[n];

                // Game Bot
                if (options.isAutoplay && (gamePosition - curNote.TIME - judgeOffset) >= 0)
                {
                    judgeScorePosition(curNote.DIR, curNote.TIME - judgeOffset);
                    n--;
                    continue;
                }

                // Remove Old note
                if (gamePosition - curNote.TIME + judgeOffset > judgeMissTime)
                {
                    binReplayNotes[curNote.ID] = null;
                    commitJudge(curNote.DIR, gameProgress, -10);
                    noteBox.removeNote(curNote.ID);
                    n--;
                    continue;
                }
            }

            var mines:Array = noteBox.mines;
            for (n = 0; n < mines.length; n++)
            {
                var curMine:GameNoteMine = mines[n];

                // Mine Hitbox exist only on the frame it passes the receptor.
                if ((gamePosition - curMine.TIME - judgeOffset) >= 0 && curMine.STATE == GameNoteMine.ARMED)
                {
                    curMine.STATE = GameNoteMine.PASSED;
                    if (_dirs[curMine.DIR] === true)
                    {
                        AudioManager.playSound("bomb");
                        hitCombo = 0;
                        updateHealth(_gvars.HEALTH_JUDGE_MINE);
                        _dirs[curMine.DIR] = false;
                    }
                }

                // Remove Old note
                if (gamePosition - curMine.TIME + judgeOffset > judgeMissTime)
                {
                    noteBox.removeMine(curMine.ID);
                    n--;
                    continue;
                }
            }

            var holds:Array = noteBox.holds;
            for (n = 0; n < holds.length; n++)
            {
                var curHold:GameNoteHold = holds[n];

                // Game Bot
                if (options.isAutoplay && (gamePosition - curHold.TIME - curHold.TAIL - judgeOffset) >= 0 && curHold.STATE == GameNoteHold.HELD)
                {
                    judgeHoldReleasePosition(curHold.DIR, (curHold.TIME + curHold.TAIL) - judgeOffset);
                    n--;
                    continue;
                }

                // Remove Old note
                if (gamePosition - curHold.TIME + judgeOffset > judgeHoldMissTime && curHold.STATE == GameNoteHold.SPAWN)
                {
                    curHold.STATE = GameNoteHold.MISSED;
                    curHold.updateTail(gamePosition + judgeOffset);
                    continue;
                }

                // Remove Old note
                if (gamePosition - curHold.TIME - curHold.TAIL - judgeOffset > judgeHoldMissTime)
                {
                    noteBox.removeHold(curHold.ID);

                    if (_dirs[curHold.DIR] && curHold.STATE == GameNoteHold.HELD)
                        commitHoldJudge(curHold.DIR, gameProgress, 15);
                    else
                        commitHoldJudge(curHold.DIR, gameProgress, -15);

                    n--;
                    continue;
                }
            }
        }

        private function onEnterFrame(e:Event):void
        {
            switch (GAME_STATE)
            {
                case GAME_PLAY:
                    var lastAbsolutePosition:int = absolutePosition;
                    absolutePosition = getTimer() - absoluteStart;

                    if (!songDelayStarted)
                    {
                        if (absolutePosition < songDelay)
                        {
                            song.stop();
                        }
                        else
                        {
                            songDelayStarted = true;
                            song.start();
                        }
                    }

                    var songPosition:int = song.getPosition() + songDelay;
                    if (song.musicIsPlaying && songPosition > 100)
                        songOffset.addValue(songPosition - absolutePosition);

                    frameRate.addValue(1000 / (absolutePosition - lastAbsolutePosition));

                    gamePosition = Math.round(absolutePosition + songOffset.value);

                    var targetProgress:int = Math.round(gamePosition * GameOptions.ENGINE_TICK_RATE / 1000 - 0.5);
                    var threshold:int = Math.round(1 / (frameRate.value / GameOptions.ENGINE_TICK_RATE));
                    if (threshold < 1)
                        threshold = 1;

                    while (gameProgress < targetProgress && threshold-- > 0)
                        logicTick();

                    if (options.modEnabled("tap_pulse"))
                    {
                        noteBoxOffset.x = Math.max(Math.min(Math.abs(noteBoxOffset.x) < 0.5 ? 0 : (noteBoxOffset.x * 0.992), noteBox.positionOffsetMax.max_x), noteBox.positionOffsetMax.min_x);
                        noteBoxOffset.y = Math.max(Math.min(Math.abs(noteBoxOffset.y) < 0.5 ? 0 : (noteBoxOffset.y * 0.992), noteBox.positionOffsetMax.max_y), noteBox.positionOffsetMax.min_y);

                        noteBoxContainer.x = (Main.GAME_WIDTH / 2) + noteBoxOffset.x;
                        noteBoxContainer.y = (Main.GAME_HEIGHT / 2) + noteBoxOffset.y;
                    }

                    noteBox.update(gamePosition, gameProgress);

                    if (levelScript)
                        levelScript.doTickEvent(gamePosition);

                    if (progressDisplay)
                        progressDisplay.update((gamePosition / gameLastNoteTime) * 100, false);
                    break;

                case GAME_END:
                    endGame();
                    break;

                case GAME_RESTART:
                    restartGame();
                    break;
            }

            e.stopImmediatePropagation();
        }

        private function keyboardKeyUp(e:KeyboardEvent):void
        {
            if (inputDisabled)
                return;

            var keyCode:int = e.keyCode;

            // Set Key as unused.
            _keys[keyCode] = false;

            if (gameLife > 0 || !options.enableFailure)
            {
                var dir:String = keyToColumn[keyCode];

                if (dir != null)
                {
                    _dirs[dir] = false;
                    judgeHoldReleasePosition(dir, Math.round(getTimer() - absoluteStart + songOffset.value));
                }
            }
            e.stopImmediatePropagation();
        }

        private function keyboardKeyDown(e:KeyboardEvent):void
        {
            if (inputDisabled)
                return;

            var keyCode:int = e.keyCode;

            // Don't allow key presses unless the key is up.
            if (_keys[keyCode])
            {
                return;
            }

            // Set Key as used.
            _keys[keyCode] = true;

            // Handle judgement of key presses.
            if (gameLife > 0 || !options.enableFailure)
            {
                var dir:String = keyToColumn[keyCode];

                if (dir != null)
                {
                    _dirs[dir] = true;
                    //trace("press", dir, _dirs);
                    judgeScorePosition(dir, Math.round(getTimer() - absoluteStart + songOffset.value));
                }
            }

            // Game Restart
            if (keyCode == _gvars.playerUser.keyRestart)
            {
                if (!disableRestart)
                    GAME_STATE = GAME_RESTART;
                else
                    _gvars.gameMain.addAlert("Unable to Restart", 120, 0x960101);
            }

            // Quit
            else if (keyCode == _gvars.playerUser.keyQuit)
            {
                if (_gvars.songQueue.length > 0)
                {
                    if (quitDoubleTap > 0)
                    {
                        _gvars.songQueue = [];
                        GAME_STATE = GAME_END;
                    }
                    else
                    {
                        quitDoubleTap = options.frameRate / 4;
                    }
                }
                else
                {
                    GAME_STATE = GAME_END;
                }
            }

            // Pause
            else if (keyCode == 19 && (CONFIG::debug || _gvars.playerUser.isAdmin || _gvars.playerUser.isDeveloper))
            {
                if (!disablePause)
                    togglePause();
                else
                    _gvars.gameMain.addAlert("Unable to Pause", 120, 0x960101);
            }

            // Auto-Play
            else if (keyCode == _gvars.playerUser.keyAutoplay)
            {
                options.isAutoplay = !options.isAutoplay;
                _gvars.gameMain.addAlert("Bot Play: " + options.isAutoplay, 60, 0x960101);
                if (combo)
                    combo.update(hitCombo, hitAmazing, hitPerfect, hitGood, hitAverage, hitMiss, hitBoo, gameRawGoods);
                if (comboTotal)
                    comboTotal.update(song.totalNotes);
                if (options.isAutoplay)
                    autoPlayCounter++;
            }

            e.stopImmediatePropagation();
        }

        private function editorOnEnterFrame(e:Event):void
        {
            // State 0 = Gameplay
            if (GAME_STATE == GAME_END)
            {
                endGame();
                return;
            }
        }


        /*#########################################################################################*\
         *	   ___                         ___                 _   _
         *	  / _ \__ _ _ __ ___   ___    / __\   _ _ __   ___| |_(_) ___  _ __  ___
         *	 / /_\/ _` | '_ ` _ \ / _ \  / _\| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
         *	/ /_\\ (_| | | | | | |  __/ / /  | |_| | | | | (__| |_| | (_) | | | \__ \
         *	\____/\__,_|_| |_| |_|\___| \/    \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
         *
           \*#########################################################################################*/

        public function togglePause():void
        {
            if (GAME_STATE == GAME_PLAY)
            {
                GAME_STATE = GAME_PAUSE;
                songPausePosition = getTimer();
                song.pause();

                if (_gvars.air_useWebsockets)
                {
                    _gvars.websocketSend("SONG_PAUSE", SOCKET_SONG_MESSAGE);
                }
            }
            else if (GAME_STATE == GAME_PAUSE)
            {
                GAME_STATE = GAME_PLAY;
                absoluteStart += (getTimer() - songPausePosition);
                song.resume();

                if (_gvars.air_useWebsockets)
                {
                    _gvars.websocketSend("SONG_RESUME", SOCKET_SONG_MESSAGE);
                }
            }
        }

        private function endGame():void
        {
            _gvars.gameMain.beginTransition();

            if (levelScript)
                levelScript.destroy();

            // Stop Music Play
            if (song)
                song.stop();

            // Fill missing notes from replay.
            if (gameReplayHit.length > 0)
            {
                while (gameReplayHit.length < song.totalNotes)
                {
                    gameReplayHit.push(-5);
                }
            }
            gameReplayHit.push(-10);
            gameReplay.sort(ReplayNote.sortFunction)

            var noteCount:int = hitAmazing + hitPerfect + hitGood + hitAverage + hitMiss;

            // Save results for display
            if (!options.isEditor)
            {
                var newGameResults:GameScoreResult = new GameScoreResult();
                newGameResults.game_index = _gvars.gameIndex++;
                newGameResults.level = song.id;
                newGameResults.song = song;
                newGameResults.song_entry = song.entry;
                newGameResults.note_count = song.totalNotes;
                newGameResults.amazing = hitAmazing;
                newGameResults.perfect = hitPerfect;
                newGameResults.good = hitGood;
                newGameResults.average = hitAverage;
                newGameResults.boo = hitBoo;
                newGameResults.miss = hitMiss;
                newGameResults.combo = hitCombo;
                newGameResults.max_combo = hitMaxCombo;
                newGameResults.score = gameScore;
                newGameResults.holdsok = hitHoldOK;
                newGameResults.holdsng = hitHoldNG;
                newGameResults.last_note = noteCount < song.totalNotes ? noteCount : 0;
                newGameResults.accuracy = accuracy.value;
                newGameResults.accuracy_deviation = accuracy.deviation;
                newGameResults.options = this.options;
                newGameResults.restart_stats = _gvars.songStats.data;
                newGameResults.replay = gameReplay.concat();
                newGameResults.replay_hit = gameReplayHit.concat();
                newGameResults.replay_bin_notes = binReplayNotes;
                newGameResults.replay_bin_boos = binReplayBoos;
                newGameResults.user = _gvars.activeUser;
                newGameResults.restarts = _gvars.songRestarts;
                newGameResults.start_time = _gvars.songStartTime;
                newGameResults.start_hash = _gvars.songStartHash;
                newGameResults.end_time = TimeUtil.getCurrentDate();
                newGameResults.song_progress = (gamePosition / gameLastNoteTime);
                newGameResults.playtime_secs = ((getTimer() - msStartTime) / 1000);
                newGameResults.autoPlayCounter = autoPlayCounter;

                newGameResults.update(_gvars);
                _gvars.songResults.push(newGameResults);
            }

            _gvars.sessionStats.addFromStats(_gvars.songStats);
            _gvars.songStats.reset();

            if (!options.isEditor)
            {
                _avars.configMusicOffset = songOffset.value;
                _avars.musicOffsetSave();
            }

            // Websocket
            if (_gvars.air_useWebsockets)
            {
                SOCKET_SCORE_MESSAGE["amazing"] = hitAmazing;
                SOCKET_SCORE_MESSAGE["perfect"] = hitPerfect;
                SOCKET_SCORE_MESSAGE["good"] = hitGood;
                SOCKET_SCORE_MESSAGE["average"] = hitAverage;
                SOCKET_SCORE_MESSAGE["boo"] = hitBoo;
                SOCKET_SCORE_MESSAGE["miss"] = hitMiss;
                SOCKET_SCORE_MESSAGE["holdok"] = hitHoldOK;
                SOCKET_SCORE_MESSAGE["holdng"] = hitHoldNG;
                SOCKET_SCORE_MESSAGE["combo"] = hitCombo;
                SOCKET_SCORE_MESSAGE["maxcombo"] = hitMaxCombo;
                SOCKET_SCORE_MESSAGE["score"] = gameScore;
                SOCKET_SCORE_MESSAGE["last_hit"] = null;
                _gvars.websocketSend("NOTE_JUDGE", SOCKET_SCORE_MESSAGE);
                _gvars.websocketSend("SONG_END", SOCKET_SONG_MESSAGE);
            }

            // Cleanup
            initVars(false);

            song.stop();
            song = null;

            if (song_background)
            {
                this.removeChild(song_background);
                song_background = null;
            }

            // Remove Notes
            if (noteBox != null)
            {
                noteBox.reset();
            }

            // Remove UI
            if (GPU_PIXEL_BITMAP)
            {
                this.removeChild(GPU_PIXEL_BITMAP);
                GPU_PIXEL_BITMAP = null;
                GPU_PIXEL_BMD = null;
            }
            if (displayBlackBG)
            {
                this.removeChild(displayBlackBG);
                displayBlackBG = null;
            }
            if (progressDisplay)
            {
                gameplayUI.removeChild(progressDisplay);
                progressDisplay = null;
            }
            if (player1Life)
            {
                this.removeChild(player1Life);
                player1Life = null;
            }
            if (player1Judge)
            {
                this.removeChild(player1Judge);
                player1Judge = null;
            }
            if (gameplayUI)
            {
                this.removeChild(gameplayUI);
                gameplayUI = null;
            }
            if (noteBox)
            {
                noteBoxContainer.removeChild(noteBox);
                this.removeChild(noteBoxContainer);
                noteBox = null;
                noteBoxContainer = null;
            }
            if (displayBlackBG)
            {
                this.removeChild(displayBlackBG);
                displayBlackBG = null;
            }
            if (flashLight)
            {
                this.removeChild(flashLight);
                flashLight = null;
            }
            if (screenCut)
            {
                this.removeChild(screenCut);
                screenCut = null;
            }
            if (exitEditor)
            {
                exitEditor.dispose();
                this.removeChild(exitEditor);
                exitEditor = null;
            }

            GAME_STATE = GAME_DISPOSE;

            // Go to results
            switchTo((options.isEditor) ? Main.GAME_MENU_PANEL : GameMenu.GAME_RESULTS);
        }

        private function restartGame():void
        {
            if (levelScript)
                levelScript.restart();

            // Remove Notes
            noteBox.reset();

            if (paWindow)
                paWindow.reset();

            noteBoxOffset = {"x": 0, "y": 0};

            // Track
            var tempGT:Number = ((hitAmazing + hitPerfect) * 500) + (hitGood * 250) + (hitAverage * 50) + (hitCombo * 1000) - (hitMiss * 300) - (hitBoo * 15) + gameScore;
            _gvars.songStats.amazing += hitAmazing;
            _gvars.songStats.perfect += hitPerfect;
            _gvars.songStats.good += hitGood;
            _gvars.songStats.average += hitAverage;
            _gvars.songStats.miss += hitMiss;
            _gvars.songStats.boo += hitBoo;
            _gvars.songStats.raw_score += gameScore;
            _gvars.songStats.amazing += hitAmazing;
            _gvars.songStats.grandtotal += tempGT;
            _gvars.songStats.restarts++;

            // Restart
            song.reset();
            GAME_STATE = GAME_PLAY;
            initPlayerVars();
            initVars();
            if (player1Judge)
                player1Judge.hideJudge();
            _gvars.songRestarts++;

            // Websocket
            if (_gvars.air_useWebsockets)
            {
                SOCKET_SCORE_MESSAGE["restarts"] = _gvars.songRestarts;
                _gvars.websocketSend("NOTE_JUDGE", SOCKET_SCORE_MESSAGE);
                _gvars.websocketSend("SONG_RESTART", SOCKET_SONG_MESSAGE);
            }
        }

        /*#########################################################################################*\
         *			_____     ___               _   _
         *	 /\ /\  \_   \   / __\ __ ___  __ _| |_(_) ___  _ __
         *	/ / \ \  / /\/  / / | '__/ _ \/ _` | __| |/ _ \| '_ \
         *	\ \_/ /\/ /_   / /__| | |  __/ (_| | |_| | (_) | | | |
         *	 \___/\____/   \____/_|  \___|\__,_|\__|_|\___/|_| |_|
         *
           \*#########################################################################################*/
        private function buildFlashlight():void
        {
            if (options.modEnabled("flashlight"))
            {
                if (flashLight == null)
                {
                    var _matrix:Matrix = new Matrix();
                    _matrix.createGradientBox(Main.GAME_WIDTH, Main.GAME_HEIGHT, 1.5707963267948966);
                    flashLight = new Sprite();
                    flashLight.graphics.clear();
                    flashLight.graphics.beginGradientFill(GradientType.LINEAR, [0, 0, 0, 0, 0, 0], [0.95, 0.55, 0, 0, 0.55, 0.95], [0x00, 0x52, 0x6C, 0x92, 0xAC, 0xFF], _matrix);
                    flashLight.graphics.drawRect(0, -Main.GAME_HEIGHT, Main.GAME_WIDTH, Main.GAME_HEIGHT * 3);
                    flashLight.graphics.endFill();
                }
                if (!contains(flashLight))
                    addChild(flashLight);
            }
            else if (flashLight != null && this.contains(flashLight))
            {
                removeChild(flashLight);
            }
        }

        private function buildScreenCut():void
        {
            if (!options.displayScreencut && !options.isEditor)
                return;

            if (screenCut)
            {
                if (this.contains(screenCut))
                    this.removeChild(screenCut);
                screenCut = null;
            }
            screenCut = new Sprite();
            screenCut.graphics.lineStyle(3, 0x39C4E1, 1);
            screenCut.graphics.beginFill(0x000000);

            switch (options.scrollDirection)
            {
                case "down":
                    screenCut.x = 0;
                    screenCut.y = options.screencutPosition * Main.GAME_HEIGHT;
                    screenCut.graphics.drawRect(-Main.GAME_WIDTH, -(Main.GAME_HEIGHT * 3), Main.GAME_WIDTH * 3, Main.GAME_HEIGHT * 3);

                    if (options.isEditor)
                    {
                        screenCut.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void
                        {
                            screenCut.startDrag(false, new Rectangle(0, 5, 0, Main.GAME_HEIGHT - 7));
                        });
                        screenCut.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void
                        {
                            screenCut.stopDrag();
                            options.screencutPosition = (screenCut.y / Main.GAME_HEIGHT);
                        });
                    }
                    break;
                default:
                    screenCut.x = 0;
                    screenCut.y = Main.GAME_HEIGHT - (options.screencutPosition * Main.GAME_HEIGHT);
                    screenCut.graphics.drawRect(-Main.GAME_WIDTH, 0, Main.GAME_WIDTH * 3, Main.GAME_HEIGHT * 3);

                    if (options.isEditor)
                    {
                        screenCut.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void
                        {
                            screenCut.startDrag(false, new Rectangle(0, 5, 0, Main.GAME_HEIGHT - 7));
                        });
                        screenCut.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void
                        {
                            screenCut.stopDrag();
                            options.screencutPosition = 1 - (screenCut.y / Main.GAME_HEIGHT);
                        });
                    }
                    break;
            }
            screenCut.graphics.endFill();
            if (options.isEditor)
            {
                screenCut.buttonMode = true;
                screenCut.useHandCursor = true;
            }
            this.addChild(screenCut);
        }

        private function buildJudge():void
        {
            if (!options.displayJudge)
                return;
            player1Judge = new Judge(options);
            addChild(player1Judge);

            if (options.isEditor)
                player1Judge.showJudge(100, true);
        }

        private function buildHealth():void
        {
            if (!options.displayHealth)
                return;
            player1Life = new LifeBar();
            player1Life.x = Main.GAME_WIDTH - 37;
            player1Life.y = 71.5;
            addChild(player1Life);
        }

        private function interfaceLayout(key:String, defaults:Boolean = true):Object
        {
            if (defaults)
            {
                var ret:Object = new Object();
                var def:Object = defaultLayout[key];
                for (var i:String in def)
                    ret[i] = def[i];
                var layout:Object = options.layout[key];
                for (i in layout)
                    ret[i] = layout[i];
                return ret;
            }
            else if (!options.layout[key])
                options.layout[key] = new Object();
            return options.layout[key];
        }

        private function interfaceSetup():void
        {
            defaultLayout = new Object();
            defaultLayout[LAYOUT_JUDGE] = {x: 392, y: 228};
            defaultLayout[LAYOUT_HEALTH] = {x: Main.GAME_WIDTH - 37, y: 71.5};
            defaultLayout[LAYOUT_RECEPTORS] = {x: 230, y: 0};
            defaultLayout[LAYOUT_PA] = {x: 6, y: 96};
            defaultLayout[LAYOUT_SCORE] = {x: 392, y: 440};
            defaultLayout[LAYOUT_COMBO] = {x: 222, y: 402, properties: {alignment: Combo.ALIGN_RIGHT}};
            defaultLayout[LAYOUT_COMBO_TOTAL] = {x: 544, y: 402};
            defaultLayout[LAYOUT_COMBO_STATIC] = {x: 228, y: 436};
            defaultLayout[LAYOUT_COMBO_TOTAL_STATIC] = {x: 502, y: 436};

            noteBoxPositionDefault = interfaceLayout(LAYOUT_RECEPTORS);

            interfacePosition(noteBox, interfaceLayout(LAYOUT_RECEPTORS));
            interfacePosition(player1Judge, interfaceLayout(LAYOUT_JUDGE));
            interfacePosition(player1Life, interfaceLayout(LAYOUT_HEALTH));
            interfacePosition(score, interfaceLayout(LAYOUT_SCORE));
            interfacePosition(combo, interfaceLayout(LAYOUT_COMBO));
            interfacePosition(comboTotal, interfaceLayout(LAYOUT_COMBO_TOTAL));
            interfacePosition(paWindow, interfaceLayout(LAYOUT_PA));
            interfacePosition(comboStatic, interfaceLayout(LAYOUT_COMBO_STATIC));
            interfacePosition(comboTotalStatic, interfaceLayout(LAYOUT_COMBO_TOTAL_STATIC));

            if (options.isEditor)
            {
                interfaceEditor(noteBox, interfaceLayout(LAYOUT_RECEPTORS, false), true);
                interfaceEditor(player1Judge, interfaceLayout(LAYOUT_JUDGE, false));
                interfaceEditor(player1Life, interfaceLayout(LAYOUT_HEALTH, false));
                interfaceEditor(score, interfaceLayout(LAYOUT_SCORE, false));
                interfaceEditor(combo, interfaceLayout(LAYOUT_COMBO, false));
                interfaceEditor(comboTotal, interfaceLayout(LAYOUT_COMBO_TOTAL, false));
                interfaceEditor(paWindow, interfaceLayout(LAYOUT_PA, false));
                interfaceEditor(comboStatic, interfaceLayout(LAYOUT_COMBO_STATIC, false));
                interfaceEditor(comboTotalStatic, interfaceLayout(LAYOUT_COMBO_TOTAL_STATIC, false));
            }

            noteBox.x -= (Main.GAME_WIDTH / 2);
            noteBox.y -= (Main.GAME_HEIGHT / 2);

            if (levelScript)
                levelScript.postUIHook();
        }

        private function interfacePosition(sprite:Sprite, layout:Object):void
        {
            if (!sprite)
                return;

            if ("x" in layout)
                sprite.x = layout["x"];
            if ("y" in layout)
                sprite.y = layout["y"];
            if ("rotation" in layout)
                sprite.rotation = layout["rotation"];
            if ("visible" in layout)
                sprite.visible = layout["visible"];
            for (var p:String in layout.properties)
                sprite[p] = layout.properties[p];
        }

        private function interfaceEditor(sprite:Sprite, layout:Object, isOffsets:Boolean = false):void
        {
            if (!sprite)
                return;

            sprite.mouseChildren = false;
            sprite.buttonMode = true;
            sprite.useHandCursor = true;

            sprite.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void
            {
                sprite.startDrag(false);
            });
            sprite.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void
            {
                sprite.stopDrag();
                layout["x"] = sprite.x;
                layout["y"] = sprite.y;

                if (isOffsets)
                {
                    layout["x"] += (Main.GAME_WIDTH / 2);
                    layout["y"] += (Main.GAME_HEIGHT / 2);
                }
                _avars.interfaceSave();
            });
        }

        /*#########################################################################################*\
         *	   ___                           _
         *	  / _ \__ _ _ __ ___   ___ _ __ | | __ _ _   _
         *	 / /_\/ _` | '_ ` _ \ / _ \ '_ \| |/ _` | | | |
         *	/ /_\\ (_| | | | | | |  __/ |_) | | (_| | |_| |
         *	\____/\__,_|_| |_| |_|\___| .__/|_|\__,_|\__, |
         *							  |_|            |___/
           \*#########################################################################################*/

        /**
         * Judge a note score based on the current song position in ms.
         * @param dir Note Direction
         * @param position Time in MS.
         * @return
         */
        private function judgeScorePosition(dir:String, position:int):Boolean
        {
            var positionJudged:int = position + judgeOffset;

            var score:int = 0;
            var frame:int = 0;
            var booConflict:Boolean = false;
            for each (var note:GameNote in noteBox.notes)
            {
                if (note.DIR != dir)
                    continue;

                var diff:Number = positionJudged - note.TIME;
                var lastJudge:Object = null;
                for each (var j:Object in judgeSettings)
                {
                    if (diff > j.t)
                        lastJudge = j;
                }
                score = lastJudge ? lastJudge.s : 0;
                if (score)
                    frame = lastJudge.f;
                if (!score)
                {
                    var pdiff:int = gameProgress - note.TICK + player1JudgeOffset;
                    if (pdiff >= -3 && pdiff <= 3)
                        booConflict = true;
                }
                if (score > 0)
                    break;
                else if (diff <= judgeSettings[0].t)
                    break;
            }
            if (score)
            {
                commitJudge(dir, frame + note.TICK - player1JudgeOffset, score);
                noteBox.removeNote(note.ID);
                accuracy.addValue(note.TIME - position);
                binReplayNotes[note.ID] = (positionJudged - note.TIME);

                judgeHoldPressPosition(note.DIR, note.TIME);
            }
            else if (options.enableBoos)
            {
                var booFrame:int = gameProgress;
                if (booConflict)
                {
                    var noteIndex:int = 0;
                    note = noteBox.notes[noteIndex++] || noteBox.spawnNextNote(gameProgress);
                    while (note)
                    {
                        if (booFrame + player1JudgeOffset < note.TICK - 3)
                            break;
                        if (note.DIR == dir)
                            booFrame = note.TICK + 4 - player1JudgeOffset;

                        note = noteBox.notes[noteIndex++] || noteBox.spawnNextNote(gameProgress);
                    }
                }

                if (booFrame >= gameFirstNoteFrame)
                    binReplayBoos.push({"d": dir, "t": position, "i": binReplayBoos.length});
                commitJudge(dir, booFrame, -5);
            }

            if (options.modEnabled("tap_pulse"))
            {
                if (dir == "L")
                    noteBoxOffset.x -= Math.abs(options.receptorSpacing * 0.20);
                if (dir == "R")
                    noteBoxOffset.x += Math.abs(options.receptorSpacing * 0.20);
                if (dir == "U")
                    noteBoxOffset.y -= Math.abs(options.receptorSpacing * 0.15);
                if (dir == "D")
                    noteBoxOffset.y += Math.abs(options.receptorSpacing * 0.15);
            }

            return Boolean(score);
        }

        private function judgeHoldPressPosition(dir:String, position:int):Boolean
        {
            for each (var note:GameNoteHold in noteBox.holds)
            {
                if (note.DIR != dir || note.STATE != GameNoteHold.SPAWN)
                    continue;

                if (note.TIME == position)
                {
                    note.STATE = GameNoteHold.HELD;
                    note.updateTail(gamePosition + judgeOffset);
                    return true;
                }
            }

            return false;
        }

        /**
         * Judge a note score based on the current song position in ms.
         * @param dir Note Direction
         * @param position Time in MS.
         * @return
         */
        private function judgeHoldReleasePosition(dir:String, position:int):Boolean
        {
            var positionJudged:int = position + judgeOffset;

            var note:GameNoteHold;
            var score:int = 0;
            var frame:int = 0;
            for each (note in noteBox.holds)
            {
                if (note.DIR != dir || note.STATE != GameNoteHold.HELD)
                    continue;

                var diff:Number = positionJudged - (note.TIME + note.TAIL);
                var lastJudge:Object = null;
                for each (var j:Object in judgeHoldSettings)
                {
                    if (diff > j.t)
                        lastJudge = j;
                }
                score = lastJudge ? lastJudge.s : 0;
                if (score)
                    frame = lastJudge.f;
                if (score > 0)
                    break;
                else if (diff <= judgeHoldSettings[0].t)
                    break;
            }

            if (score)
            {
                commitHoldJudge(dir, frame + note.TICK - player1JudgeOffset, 15);
                noteBox.removeHold(note.ID);
            }
            else
            {
                for each (note in noteBox.holds)
                {
                    if (note.DIR == dir && note.STATE == GameNoteHold.HELD)
                    {
                        note.STATE = GameNoteHold.MISSED;
                        note.updateTail(position);
                    }
                }
            }

            return Boolean(score);
        }

        private function commitJudge(dir:String, frame:int, score:int):void
        {
            var jscore:int = score;
            noteBox.receptorFeedback(dir, score);
            switch (score)
            {
                case 100:
                    hitAmazing++;
                    hitCombo++;
                    gameScore += 50;
                    updateHealth(_gvars.HEALTH_JUDGE_ADD);
                    if (options.displayAmazing)
                    {
                        checkAutofail(options.autofail[0], hitAmazing);
                    }
                    else
                    {
                        jscore = 50;
                        checkAutofail(options.autofail[0] + options.autofail[1], hitAmazing + hitPerfect);
                    }
                    checkAutofail(options.autofail[6], gameRawGoods);
                    break;

                case 50:
                    hitPerfect++;
                    hitCombo++;
                    gameScore += 50;
                    updateHealth(_gvars.HEALTH_JUDGE_ADD);
                    checkAutofail(options.autofail[1], hitPerfect);
                    checkAutofail(options.autofail[6], gameRawGoods);
                    break;

                case 25:
                    hitGood++;
                    hitCombo++;
                    gameScore += 25;
                    gameRawGoods += 1;
                    updateHealth(_gvars.HEALTH_JUDGE_ADD);
                    checkAutofail(options.autofail[2], hitGood);
                    checkAutofail(options.autofail[6], gameRawGoods);
                    break;

                case 5:
                    hitAverage++;
                    hitCombo++;
                    gameScore += 5;
                    gameRawGoods += 1.8;
                    checkAutofail(options.autofail[3], hitAverage);
                    checkAutofail(options.autofail[6], gameRawGoods);
                    break;

                case -5:
                    if (frame <= gameFirstNoteFrame)
                        return;

                    hitBoo++;
                    gameScore -= 5;
                    gameRawGoods += 0.2;
                    checkAutofail(options.autofail[5], hitBoo);
                    checkAutofail(options.autofail[6], gameRawGoods);
                    updateHealth(_gvars.HEALTH_JUDGE_BOO);
                    break;

                case -10:
                    hitMiss++;
                    hitCombo = 0;
                    gameScore -= 10;
                    gameRawGoods += 2.4;
                    checkAutofail(options.autofail[4], hitMiss);
                    checkAutofail(options.autofail[6], gameRawGoods);
                    updateHealth(_gvars.HEALTH_JUDGE_MISS);
                    break;
            }

            if (player1Judge)
                player1Judge.showJudge(jscore);

            if (hitCombo > hitMaxCombo)
                hitMaxCombo = hitCombo;

            if (score == -10)
                gameReplayHit.push(0);
            else if (score == -5)
                score = 0;

            if (score > 0)
                gameReplayHit.push(score);

            if (score >= 0)
                gameReplay.push(new ReplayNote(dir, frame, (getTimer() - msStartTime), score));

            updateFieldVars();

            // Websocket
            if (_gvars.air_useWebsockets)
            {
                SOCKET_SCORE_MESSAGE["amazing"] = hitAmazing;
                SOCKET_SCORE_MESSAGE["perfect"] = hitPerfect;
                SOCKET_SCORE_MESSAGE["good"] = hitGood;
                SOCKET_SCORE_MESSAGE["average"] = hitAverage;
                SOCKET_SCORE_MESSAGE["boo"] = hitBoo;
                SOCKET_SCORE_MESSAGE["miss"] = hitMiss;
                SOCKET_SCORE_MESSAGE["holdok"] = hitHoldOK;
                SOCKET_SCORE_MESSAGE["holdng"] = hitHoldNG;
                SOCKET_SCORE_MESSAGE["combo"] = hitCombo;
                SOCKET_SCORE_MESSAGE["maxcombo"] = hitMaxCombo;
                SOCKET_SCORE_MESSAGE["score"] = gameScore;
                SOCKET_SCORE_MESSAGE["last_hit"] = score;
                _gvars.websocketSend("NOTE_JUDGE", SOCKET_SCORE_MESSAGE);
            }
        }

        private function commitHoldJudge(dir:String, frame:int, score:int):void
        {
            var jscore:int = score;
            noteBox.receptorFeedback(dir, score);
            switch (score)
            {
                case 15:
                    hitHoldOK++;
                    break;
                case -15:
                    hitHoldNG++;
                    break;
            }

            if (hitCombo > hitMaxCombo)
                hitMaxCombo = hitCombo;

            if (player1Judge)
                player1Judge.showJudge(jscore);

            updateFieldVars();

            // Websocket
            if (_gvars.air_useWebsockets)
            {
                SOCKET_SCORE_MESSAGE["amazing"] = hitAmazing;
                SOCKET_SCORE_MESSAGE["perfect"] = hitPerfect;
                SOCKET_SCORE_MESSAGE["good"] = hitGood;
                SOCKET_SCORE_MESSAGE["average"] = hitAverage;
                SOCKET_SCORE_MESSAGE["boo"] = hitBoo;
                SOCKET_SCORE_MESSAGE["miss"] = hitMiss;
                SOCKET_SCORE_MESSAGE["holdok"] = hitHoldOK;
                SOCKET_SCORE_MESSAGE["holdng"] = hitHoldNG;
                SOCKET_SCORE_MESSAGE["combo"] = hitCombo;
                SOCKET_SCORE_MESSAGE["maxcombo"] = hitMaxCombo;
                SOCKET_SCORE_MESSAGE["score"] = gameScore;
                SOCKET_SCORE_MESSAGE["last_hit"] = score;
                _gvars.websocketSend("NOTE_JUDGE", SOCKET_SCORE_MESSAGE);
            }
        }

        private function checkAutofail(autofail:Number, hit:Number):void
        {
            if (autofail > 0 && hit >= autofail)
                GAME_STATE = GAME_END;
        }

        /*#########################################################################################*\
         *		   _                 _                   _       _
         *	/\   /(_)___ _   _  __ _| |  /\ /\ _ __   __| | __ _| |_ ___  ___
         *	\ \ / / / __| | | |/ _` | | / / \ \ '_ \ / _` |/ _` | __/ _ \/ __|
         *	 \ V /| \__ \ |_| | (_| | | \ \_/ / |_) | (_| | (_| | ||  __/\__ \
         *	  \_/ |_|___/\__,_|\__,_|_|  \___/| .__/ \__,_|\__,_|\__\___||___/
         *									  |_|
           \*#########################################################################################*/

        private function updateHealth(val:int):void
        {
            gameLife += val;
            if (gameLife <= 0)
            {
                gameLife = 0;
                if (options.enableFailure)
                    GAME_STATE = GAME_END;
            }
            else if (gameLife > 100)
            {
                gameLife = 100;
            }
            if (player1Life)
                player1Life.health = gameLife;
        }

        private function updateFieldVars():void
        {
            //gameplayUI.sDisplay_score.text = gameScore.toString();

            if (paWindow)
                paWindow.update(hitAmazing, hitPerfect, hitGood, hitAverage, hitMiss, hitBoo, hitHoldOK, hitHoldNG);

            if (score)
                score.update(gameScore);

            if (combo)
                combo.update(hitCombo, hitAmazing, hitPerfect, hitGood, hitAverage, hitMiss, hitBoo, gameRawGoods);
        }

        public function getScriptVariable(key:String):*
        {
            return this[key];
        }

        public function setScriptVariable(key:String, val:*):void
        {
            this[key] = val;
        }
    }
}
