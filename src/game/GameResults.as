package game
{
    import arc.ArcGlobals;
    import assets.menu.icons.fa.iconPhoto;
    import assets.menu.icons.fa.iconRight;
    import assets.menu.icons.fa.iconSmallT;
    import assets.results.ResultsBackground;
    import by.blooddy.crypto.SHA1;
    import classes.Language;
    import classes.Playlist;
    import classes.ui.BoxButton;
    import classes.ui.BoxIcon;
    import classes.ui.StarSelector;
    import classes.ui.Text;
    import com.flashfla.net.DynamicURLLoader;
    import com.flashfla.utils.NumberUtil;
    import com.flashfla.utils.TimeUtil;
    import com.flashfla.utils.sprintf;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.SecurityErrorEvent;
    import game.graph.GraphAccuracy;
    import game.graph.GraphBase;
    import game.graph.GraphCombo;
    import menu.MenuPanel;
    import flash.display.BitmapData;
    import scripts.graphs.FakeGraph;
    import flash.display.Bitmap;

    public class GameResults extends MenuPanel
    {
        public static const GRAPH_WIDTH:int = 718;
        public static const GRAPH_HEIGHT:int = 117;
        public static const GRAPH_COMBO:int = 0;
        public static const GRAPH_ACCURACY:int = 1;

        private var graph_cache:Object = {"0": {}, "1": {}};

        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _avars:ArcGlobals = ArcGlobals.instance;
        private var _lang:Language = Language.instance;
        private var _loader:DynamicURLLoader;
        private var _playlist:Playlist = Playlist.instance;

        // Results
        private var resultsTime:String = TimeUtil.getCurrentDate();
        private var resultIndex:int = 0;
        private var songResults:Vector.<GameScoreResult>;
        private var songRankIndex:int = -1;

        // Title Bar
        private var navScreenShot:BoxIcon;

        // Game Result
        private var resultsDisplay:ResultsBackground;
        private var navRating:Sprite;
        private var resultsMods:Text;

        // Graph
        private var graphType:int = 0;
        private var graphToggle:BoxIcon;
        private var graphAccuracy:BoxIcon;
        private var activeGraph:GraphBase;
        private var graphDraw:Sprite;
        private var graphOverlay:Sprite;
        private var graphOverlayText:Text;

        // Menu Bar
        private var navReplay:BoxButton;
        private var navOptions:BoxButton;
        private var navMenu:BoxButton;

        public function GameResults(myParent:MenuPanel)
        {
            super(myParent);
        }

        override public function init():Boolean
        {
            songResults = _gvars.songResults.concat();

            // More songs to play, jump to gameplay or loading.
            if (_gvars.songQueue.length > 0)
            {
                switchTo(GameMenu.GAME_LOADING);
                return false;
            }
            else
            {
                _gvars.songResults.length = 0;
            }
            return true;
        }

        //******************************************************************************************//
        // Panel Stage Functions
        //******************************************************************************************//

        override public function stageAdd():void
        {
            // Add keyboard navigation
            stage.addEventListener(KeyboardEvent.KEY_DOWN, eventHandler);

            // Add Mouse Move for graphs
            stage.addEventListener(MouseEvent.MOUSE_MOVE, e_graphHover);

            // Reset Window Title
            stage.nativeWindow.title = Constant.AIR_WINDOW_TITLE;

            // Get Graph Type
            graphType = LocalStore.getVariable("result_graph_type", 0);

            // Background
            resultsDisplay = new ResultsBackground();
            resultsDisplay.song_description.styleSheet = Constant.STYLESHEET;
            this.addChild(resultsDisplay);

            // Avatar
            var result:GameScoreResult = songResults[songResults.length - 1];
            if (result.user)
            {
                var userAvatar:DisplayObject = result.user.avatar;
                if (userAvatar && userAvatar.height > 0 && userAvatar.width > 0)
                {
                    userAvatar.x = 616 + ((99 - userAvatar.width) / 2);
                    userAvatar.y = 114 + ((99 - userAvatar.height) / 2);
                    this.addChild(userAvatar);
                }
            }

            var buttonMenu:Sprite = new Sprite();
            var buttonMenuItems:Array = [];
            buttonMenu.x = 22;
            buttonMenu.y = 428;
            this.addChild(buttonMenu);

            // Main Bavigation Buttons
            navOptions = new BoxButton(buttonMenu, 0, 0, 170, 40, _lang.string("game_results_menu_options"), 17, eventHandler);
            buttonMenuItems.push(navOptions);

            navReplay = new BoxButton(buttonMenu, 0, 0, 170, 40, _lang.string("game_results_menu_replay_song"), 17, eventHandler);
            buttonMenuItems.push(navReplay);
            navMenu = new BoxButton(buttonMenu, 0, 0, 170, 40, _lang.string("game_results_menu_exit_menu"), 17, eventHandler);
            buttonMenuItems.push(navMenu);

            var BUTTON_GAP:int = 11;
            var BUTTON_WIDTH:int = (735 - (Math.max(0, (buttonMenuItems.length - 1)) * BUTTON_GAP)) / buttonMenuItems.length;
            for (var bx:int = 0; bx < buttonMenuItems.length; bx++)
            {
                buttonMenuItems[bx].width = BUTTON_WIDTH;
                buttonMenuItems[bx].x = BUTTON_WIDTH * bx + BUTTON_GAP * bx;
            }

            // Song Notes / Star Rating Button
            navRating = new Sprite();
            navRating.buttonMode = true;
            navRating.mouseChildren = false;
            navRating.addEventListener(MouseEvent.CLICK, eventHandler);
            StarSelector.drawStar(navRating.graphics, 18, 0, 0, true, 0xF2D60D, 1);
            resultsDisplay.addChild(navRating);

            // Song Results Buttons
            navScreenShot = new BoxIcon(this, 522, 6, 32, 32, new iconPhoto(), eventHandler);
            navScreenShot.setIconColor("#E2FEFF");
            navScreenShot.setHoverText(_lang.string("game_results_queue_save_screenshot"), "bottom");

            // Graph
            resultsMods = new Text(this, 18, 276, "---");

            // Background
            var levelScript:String = result.song.entry.levelscript || "";
            if (levelScript == "DarkMatter" && Flags.ANTIMATTER)
            {
                var bg:Bitmap = FakeGraph.getMatterBG();
                bg.x = 30;
                bg.y = 298;
                this.addChild(bg);
            }

            graphDraw = new Sprite();
            graphDraw.x = 30;
            graphDraw.y = 298;
            this.addChild(graphDraw);

            graphOverlay = new Sprite();
            graphOverlay.x = 30;
            graphOverlay.y = 298;
            graphOverlay.mouseChildren = false;
            graphOverlay.mouseEnabled = false;
            this.addChild(graphOverlay);

            graphToggle = new BoxIcon(this, 10, 298, 16, 18, new iconRight(), eventHandler);
            graphToggle.padding = 6;
            graphToggle.setHoverText(_lang.string("result_next_graph_type"), "right");

            graphAccuracy = new BoxIcon(this, 10, 318, 16, 18, new iconSmallT());
            graphAccuracy.padding = 6;
            graphAccuracy.delay = 250;

            // Display Game Result
            displayGameResult(songResults.length > 1 ? -1 : 0);

            _gvars.gameMain.displayPopupQueue();
        }

        override public function stageRemove():void
        {
            // Remove keyboard navigation
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, eventHandler);

            // Remove Mouse Move for graphs
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, e_graphHover);

            super.stageRemove();
        }

        //******************************************************************************************//
        // Results Display Logic
        //******************************************************************************************//

        public function displayGameResult(gameIndex:int):void
        {
            // Set Index
            resultIndex = gameIndex;


            // Variables
            var skillLevel:String = (songResults[0].user != null) ? ("[Lv." + songResults[0].user.skillLevel + "]" + " ") : "";
            var displayTime:String = "";
            var song_entry:Object;
            var songTitle:String = "";
            var songSubTitle:String = "";

            var scoreTotal:int = 0;

            // Song Results
            var result:GameScoreResult;

            result = songResults[resultIndex];
            song_entry = result.song_entry;

            var charts:Array = song_entry.embedData.getAllCharts();
            var chartData:Object = charts[result.options.selectedChartID];

            var seconds:Number = Math.floor(song_entry.timeSecs * (1 / result.options.songRate));
            var songLength:String = (Math.floor(seconds / 60)) + ":" + (seconds % 60 >= 10 ? "" : "0") + (seconds % 60);
            var rateString:String = result.options.songRate != 1 ? " [x" + result.options.songRate + "]" : "";

            // Song Title
            songTitle = song_entry.name + rateString;
            songSubTitle = sprintf(_lang.string("game_results_subtitle_difficulty"), {"value": (chartData['difficulty'] || song_entry['difficulty'])}) + " - " + sprintf(_lang.string("game_results_subtitle_length"), {"value": songLength});
            if (song_entry.author != "")
                songSubTitle += " - " + _lang.wrapFont(sprintf(_lang.stringSimple("game_results_subtitle_author"), {"value": (chartData['author'] || song_entry['author'])}));
            if (song_entry.stepauthor != "")
                songSubTitle += " - " + _lang.wrapFont(sprintf(_lang.stringSimple("game_results_subtitle_stepauthor"), {"value": (chartData['stepauthor'] || song_entry['stepauthor'])}));

            displayTime = result.end_time;
            scoreTotal = result.score_total;

            // Song Notes / Star
            navRating.visible = (result.song_entry != null);

            // Cached Rank Index
            songRankIndex = result.game_index + 1;


            // Skill rating
            var song_weight:Number = SkillRating.getSongWeight(result);
            if (result.last_note > 0)
                song_weight = 0;

            // Display Results
            if (Text.isUnicode(songTitle))
                resultsDisplay.song_title.defaultTextFormat.font = Language.UNI_FONT_NAME;
            if (Text.isUnicode(songSubTitle))
                resultsDisplay.song_description.defaultTextFormat.font = Language.UNI_FONT_NAME;

            resultsDisplay.results_username.htmlText = "<B>Results for " + skillLevel + result.user.name + ":</B>";
            resultsDisplay.results_time.htmlText = "<B>" + displayTime + "</B>";
            resultsDisplay.song_title.htmlText = "<B>" + _lang.wrapFont(songTitle) + "</B>";
            resultsDisplay.song_description.htmlText = "<B>" + songSubTitle + "</B>";

            resultsDisplay.result_amazing.htmlText = "<B>" + NumberUtil.numberFormat(result.amazing) + "</B>";
            resultsDisplay.result_perfect.htmlText = "<B>" + NumberUtil.numberFormat(result.perfect) + "</B>";
            resultsDisplay.result_good.htmlText = "<B>" + NumberUtil.numberFormat(result.good) + "</B>";
            resultsDisplay.result_average.htmlText = "<B>" + NumberUtil.numberFormat(result.average) + "</B>";
            resultsDisplay.result_miss.htmlText = "<B>" + NumberUtil.numberFormat(result.miss) + "</B>";
            resultsDisplay.result_boo.htmlText = "<B>" + NumberUtil.numberFormat(result.boo) + "</B>";

            resultsDisplay.result_rawgoods.htmlText = "<B>" + NumberUtil.numberFormat(result.raw_goods, 1, true) + "</B>";
            resultsDisplay.result_rawscore.htmlText = "<B>" + NumberUtil.numberFormat(result.score) + "</B>";
            resultsDisplay.result_total.htmlText = "<B>" + NumberUtil.numberFormat(scoreTotal) + "</B>";
            resultsDisplay.result_maxcombo.htmlText = "<B>" + NumberUtil.numberFormat(result.max_combo) + "</B>";
            resultsDisplay.result_holdsok.htmlText = "<B>" + NumberUtil.numberFormat(result.holdsok) + "</B>";
            resultsDisplay.result_holdsng.htmlText = "<B>" + NumberUtil.numberFormat(result.holdsng) + "</B>";

            // Align Rating Star to Song Title
            navRating.x = resultsDisplay.song_title.x + (resultsDisplay.song_title.width / 2) - (resultsDisplay.song_title.textWidth / 2) - 22;
            navRating.y = resultsDisplay.song_title.y + 4;

            // Mod Text
            resultsMods.text = "Scroll Speed: " + result.options.scrollSpeed;
            if (result.restarts > 0)
                resultsMods.text += ", Restarts: " + result.restarts;
            var mods:Array = [];
            var ignoreMods:Array = ["nobackground", "mirror", "rotation_lock", "scale_lock", "speed_update"];
            for each (var mod:String in result.options.mods)
                if (ignoreMods.indexOf(mod) != -1)
                    continue;
                else
                    mods.push(_lang.string("options_mod_" + mod));
            if (result.options.judgeWindow)
                mods.push(_lang.string("options_mod_judge"));
            if (result.autoPlayCounter > 0)
                mods.unshift(_lang.string("options_mod_autoplay"));

            // Enable Toggles
            if (!result.options.enableBoos)
                mods.push(_lang.string("options_mod_no_boo"));
            if (!result.options.enableHolds)
                mods.push(_lang.string("options_mod_no_hold"));
            if (!result.options.enableMines)
                mods.push(_lang.string("options_mod_no_mine"));
            if (!result.options.enableFailure)
                mods.push(_lang.string("options_mod_no_fail"));

            //mods.push("<font color=\"#53ff49\">True Note Position</font>");
            //mods.push("<font color=\"#ef2626\">Health Alterations</font>");

            if (mods.length > 0)
                resultsMods.text += ", Game Mods: " + mods.join(", ");
            if (result.last_note > 0)
                resultsMods.text += ", Last Note: " + result.last_note;

            if (gameIndex != -1)
            {
                graphAccuracy.setHoverText(sprintf(_lang.string("result_accuracy_deviation"), {"acc_frame": result.accuracy_frames.toFixed(3),
                        "acc_dev_frame": result.accuracy_deviation_frames.toFixed(3),
                        "acc_ms": result.accuracy.toFixed(3),
                        "acc_dev_ms": result.accuracy_deviation.toFixed(3)}), "right");
            }

            drawResultGraph(result);
        }

        //******************************************************************************************//
        // Graph Logic
        //******************************************************************************************//

        /**
         * Displays a valid graph for the given GameScoreResult, this checks if the
         * selected graph can be displayed for the given result.
         *
         * @param result Current GameScoreResult
         */
        private function drawResultGraph(result:GameScoreResult):void
        {
            var graph_type:int = graphType;

            // Check for Totals Index
            if (graph_type == GRAPH_ACCURACY && (result.song == null || result.replay_bin_notes == null))
                graph_type = GRAPH_COMBO;

            // Graph Toggle
            graphToggle.visible = (result.song != null);
            graphAccuracy.visible = (result.song != null);

            // Remove Old Graph
            if (activeGraph != null)
            {
                activeGraph.onStageRemove();
            }

            activeGraph = getGraph(graph_type, result);
            activeGraph.onStage(this);
            activeGraph.draw();
            activeGraph.drawOverlay(stage.mouseX - graphOverlay.x, stage.mouseY - graphOverlay.y);
        }

        /**
         * Gets the request graph object, either from cache of by creation.
         * @param graph_type Graph Type
         * @param result GameScoreResult
         * @return Graph Class
         */
        public function getGraph(graph_type:int, result:GameScoreResult):GraphBase
        {
            var cache_id:String = graph_type + "_" + resultIndex;

            // From Cache
            if (graph_cache[cache_id] != null)
            {
                return graph_cache[cache_id];
            }

            // Create New
            else
            {
                var new_graph:GraphBase;

                if (graph_type == GRAPH_ACCURACY)
                {
                    new_graph = new GraphAccuracy(graphDraw, graphOverlay, result);
                }
                else
                {
                    new_graph = new GraphCombo(graphDraw, graphOverlay, result);
                }

                graph_cache[cache_id] = new_graph;

                return new_graph;
            }
        }

        /**
         * Updates the active graph overlay with the current mouse coordinates
         * @param e
         */
        private function e_graphHover(e:MouseEvent):void
        {
            //trace(e.stageX - graphOverlay.x, e.stageY - graphOverlay.y); 
            if (activeGraph != null)
            {
                activeGraph.drawOverlay(e.stageX - graphOverlay.x, e.stageY - graphOverlay.y);
            }
        }

        //******************************************************************************************//
        // Helper Functions
        //******************************************************************************************//

        /**
         * Handles Auto Judge Offset options by changing the judge offset and saving
         * the user settings. This is called when scores are saved successfully and
         * passes in the site response post vars, not GameScoreResult.
         * @param result Post Vars
         */
        private function updateJudgeOffset(result:GameScoreResult):void
        {
            if (_gvars.activeUser.AUTO_JUDGE_OFFSET && // Auto Judge Offset enabled 
                (result.amazing + result.perfect + result.good + result.average >= 50) && // Accuracy data is reliable
                result.accuracy !== 0)
            {
                _gvars.activeUser.JUDGE_OFFSET = Number(result.accuracy_frames.toFixed(3));
            }
        }

        /**
         * Calculates the max combo in a game score result based on the replay.
         * This is used for queue results to display the max combo across
         * multiple songs for the UI.
         * @param gameResult
         * @return int
         */
        private function getMaxCombo(gameResult:GameScoreResult):int
        {
            var maxCombo:int = 0;
            var curCombo:int = 0;
            for (var x:int = 0; x < gameResult.replay_hit.length; x++)
            {
                var curNote:int = gameResult.replay_hit[x];
                if (curNote > 0)
                {
                    curCombo += 1;
                }
                else if (curNote <= 0)
                {
                    curCombo = 0;
                }
                if (curCombo > maxCombo)
                    maxCombo = curCombo;
            }
            return maxCombo;
        }

        /**
         * Generates a score has that needs to be matched on the server for
         * a score to be considered valid.
         * @param result PostVars
         * @return SHA1 Hash
         */
        private function getSaveHash(result:Object):String
        {
            var dataSerial:String = "";
            dataSerial += "yeppp";
            return SHA1.hash(dataSerial);
        }

        //******************************************************************************************//
        // Event Handlers
        //******************************************************************************************//

        /**
         * Handles all UI events, both mouse and keyboard.
         * @param e
         */
        private function eventHandler(e:* = null):void
        {
            var target:DisplayObject = e.target;

            // Don't do anything with popups open.
            if (_gvars.gameMain.current_popup != null)
                return;

            // Handle Key events and click in the same function
            if (e.type == "keyDown")
            {
                target = null;
                var keyCode:int = e.keyCode;
                if (keyCode == _gvars.playerUser.keyRestart)
                {
                    target = navReplay;
                }
                else if (keyCode == _gvars.playerUser.keyQuit)
                {
                    target = navMenu;
                    stage.removeEventListener(KeyboardEvent.KEY_DOWN, eventHandler);
                }
            }

            if (!target)
                return;

            // Play Sound
            AudioManager.playSound("nav_select");

            // Based on target
            if (target == navScreenShot)
            {
                var ext:String = "";
                if (resultIndex >= 0)
                {
                    ext = songResults[resultIndex].screenshot_path;
                }
                _gvars.takeScreenShot(ext);
            }

            else if (target == navReplay)
            {
                _gvars.options.fill();

                _gvars.songQueue = _gvars.totalSongQueue.concat();
                _gvars.gameMain.beginTransition();
                switchTo(GameMenu.GAME_LOADING);
            }

            else if (target == navOptions)
            {
                addPopup(Main.POPUP_OPTIONS);
            }

            else if (target == navMenu)
            {

                _gvars.gameMain.beginTransition();
                switchTo(Main.GAME_MENU_PANEL);
            }

            else if (target == graphToggle)
            {
                if (resultIndex >= 0)
                {
                    graphType = (graphType + 1) % 2;
                    LocalStore.setVariable("result_graph_type", graphType);
                    drawResultGraph(songResults[resultIndex]);
                }
            }
        }

        /**
         * Adds the event listeners for the url loader.
         * @param completeHandler On Complete Handler
         * @param errorHandler On Error Handler
         */
        private function addLoaderListeners(completeHandler:Function, errorHandler:Function):void
        {
            _loader.addEventListener(Event.COMPLETE, completeHandler);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
        }

        /**
         * Removes the event listeners for the url loader.
         * @param completeHandler On Complete Handler
         * @param errorHandler On Error Handler
         */
        private function removeLoaderListeners(completeHandler:Function, errorHandler:Function):void
        {
            _loader.removeEventListener(Event.COMPLETE, completeHandler);
            _loader.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
        }
    }
}
