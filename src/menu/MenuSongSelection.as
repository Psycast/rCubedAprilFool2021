/**
 * @author Jonathan (Velocity)
 */

package menu
{
    import af.assets.AFCloud;
    import af.assets.AFMinimapIcon;
    import af.assets.AFSongNameDifficulty;
    import af.assets.AFUI;
    import af.assets.AFWorldMapImage;
    import af.assets.AFWorldMapPlayer;
    import af.assets.MenuMusic;
    import arc.ArcGlobals;
    import assets.menu.icons.fa.iconRight;
    import classes.FileTracker;
    import classes.Language;
    import classes.Playlist;
    import classes.SongPlayerBytes;
    import classes.chart.levels.ExternalChartBase;
    import classes.chart.levels.ExternalChartScanner;
    import classes.ui.Prompt;
    import classes.ui.SimpleBoxButton;
    import classes.ui.SimpleShapeButton;
    import classes.ui.Text;
    import com.bit101.components.PushButton;
    import com.flashfla.utils.SoundUtils;
    import com.greensock.TweenLite;
    import com.greensock.easing.BounceOut;
    import com.greensock.easing.Quart;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.filesystem.File;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.ui.Keyboard;
    import flash.ui.Mouse;
    import flash.utils.getTimer;
    import game.GameOptions;
    import menu.title.TitleSplash;
    import popups.PopupFileBrowser;
    import popups.PopupSecretFind;

    public class MenuSongSelection extends MenuPanel
    {
        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _avars:ArcGlobals = ArcGlobals.instance;
        private var _lang:Language = Language.instance;
        private var _playlist:Playlist = Playlist.instance;

        private var genreLength:int = 0;
        private var songItems:Vector.<SongItem>;

        private var lastTime:int = 0;

        private var songList:Array;

        private var optionsSimple:SimpleBoxButton;
        private var fileBrowserButton:SimpleBoxButton;

        private var worldMap:AFWorldMapImage;
        private var worldMapSongName:AFSongNameDifficulty;
        private var worldMapClouds:AFCloud;
        private var worldMapIcon:AFWorldMapPlayer;

        private var minimap:Sprite;
        private var minimapIcon:AFMinimapIcon;

        private var ui:AFUI;
        private var lblSongName:Text;
        private var lblSongDifficulty:Text;
        private var lblAuthorName:Text;
        private var lblTime:Text;
        private var lblStepAuthor:Text;
        private var lblNoteCount:Text;

        private var navLeftBtn:SimpleShapeButton;
        private var navRightBtn:SimpleShapeButton;
        private var navPlayBtn:SimpleShapeButton;

        private var songDifficulties:Array = [];
        private var difficultyHolder:Sprite;
        private var difficultySelector:iconRight;

        private var activeCutscene:MenuCutscene;

        // Info Page
        public static var options:MenuSongSelectionOptions = new MenuSongSelectionOptions();

        ///- Constructor
        public function MenuSongSelection(myParent:MenuPanel)
        {
            super(myParent);
        }

        override public function init():Boolean
        {
            scrollRect = new Rectangle(0, 0, 780, 480);

            draw();

            return true;
        }

        override public function dispose():void
        {
            songItems = null;

            super.dispose();
        }

        override public function draw():void
        {
            if (worldMap == null)
            {
                worldMap = new AFWorldMapImage();
                this.addChild(worldMap);

                worldMapIcon = new AFWorldMapPlayer();
                worldMap.addChild(worldMapIcon);

                worldMapClouds = new AFCloud();
                worldMapClouds.y = 800;
                worldMap.addChild(worldMapClouds);

                worldMapSongName = new AFSongNameDifficulty();
                worldMap.addChild(worldMapSongName);

                lblSongName = new Text(worldMapSongName, -150, -115, "name", 24);
                lblSongName.setAreaParams(300, 36, "center");

                lblSongDifficulty = new Text(worldMapSongName, -11, -151, "0", 14);
                lblSongDifficulty.setAreaParams(38, 26, "center");
            }

            if (ui == null)
            {
                ui = new AFUI();
                ui.fileBrowserButton.visible = Flags.ENABLE_BROWSER;
                this.addChild(ui);

                minimap = new Sprite();
                minimap.x = 202;
                ui.addChild(minimap);

                minimapIcon = new AFMinimapIcon();
                minimapIcon.y = 23;
                minimap.addChild(minimapIcon);

                lblAuthorName = new Text(ui, 60, 427, "author", 12);
                lblAuthorName.setAreaParams(170, 25, "right");

                lblTime = new Text(ui, 60, 452, "time", 12);
                lblTime.setAreaParams(170, 25, "right");

                lblStepAuthor = new Text(ui, 556, 427, "stepauthor", 12);
                lblStepAuthor.setAreaParams(170, 25, "left");

                lblNoteCount = new Text(ui, 556, 452, "notes", 12);
                lblNoteCount.setAreaParams(170, 25, "left");

                difficultyHolder = new Sprite();
                difficultyHolder.x = 10;
                difficultyHolder.y = 55;
                ui.addChild(difficultyHolder);

                difficultySelector = new iconRight();
                difficultySelector.scaleX = difficultySelector.scaleY = 0.2;

                optionsSimple = new SimpleBoxButton(72, 56);
                optionsSimple.x = 708;
                optionsSimple.addEventListener(MouseEvent.CLICK, clickHandler);
                ui.addChild(optionsSimple);

                fileBrowserButton = new SimpleBoxButton(72, 56);
                fileBrowserButton.x = 708;
                fileBrowserButton.y = 75;
                fileBrowserButton.visible = Flags.ENABLE_BROWSER;
                fileBrowserButton.addEventListener(MouseEvent.CLICK, clickHandler);
                ui.addChild(fileBrowserButton);

                navLeftBtn = new SimpleShapeButton(new <int>[1, 2, 2, 2, 2, 2, 2], new <Number>[0, 0, 41, 0, 59, 18, 59, 75, 41, 93, 0, 93, 0, 0]);
                navLeftBtn.y = 284;
                navLeftBtn.addEventListener(MouseEvent.CLICK, clickHandler);
                ui.addChild(navLeftBtn);

                navRightBtn = new SimpleShapeButton(new <int>[1, 2, 2, 2, 2, 2, 2], new <Number>[59, 0, 59, 93, 18, 93, 0, 75, 0, 18, 18, 0, 59, 0]);
                navRightBtn.x = 721;
                navRightBtn.y = 284;
                navRightBtn.addEventListener(MouseEvent.CLICK, clickHandler);
                ui.addChild(navRightBtn);

                navPlayBtn = new SimpleShapeButton(new <int>[1, 2, 2, 2, 2, 2, 2, 2, 2], new <Number>[13, 0, 219, 0, 233, 14, 233, 39, 217, 55, 16, 55, 0, 39, 0, 14, 13, 0]);
                navPlayBtn.x = 276;
                navPlayBtn.y = 413;
                navPlayBtn.addEventListener(MouseEvent.CLICK, clickHandler);
                ui.addChild(navPlayBtn);
            }

            //- Build Content
            buildPlayList();
            buildInfoBox();
            buildMinimap();

            // Intro Animation
            if (!Flags.SEEN_TITLE)
            {
                Flags.SEEN_TITLE = true;
                var titleAnimation:TitleSplash = new TitleSplash(this);
            }
            else
            {
                startMusic();
            }
        }

        override public function stageAdd():void
        {
            //- Add Listeners
            addEventListener(Event.ENTER_FRAME, e_onEnterFrame);

            if (stage)
                stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler, false, 0, true);

            if (Flags.PLAY_EXTERNAL_FILE)
            {
                addPopup(new PopupFileBrowser(this));
                Flags.PLAY_EXTERNAL_FILE = false;
            }
        }

        override public function stageRemove():void
        {
            //- Remove Listeners
            removeEventListener(Event.ENTER_FRAME, e_onEnterFrame);

            if (stage)
                stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
        }

        public function e_onEnterFrame(e:Event):void
        {
            if (lastTime == 0)
                lastTime = getTimer();

            var curTime:int = getTimer();
            var diff:int = curTime - lastTime;
            var ratio:Number = (diff / 1000);

            worldMapClouds.x -= (14 * ratio);

            if (worldMapClouds.x < -(worldMapClouds.width / 2))
                worldMapClouds.x += (worldMapClouds.width / 2);

            lastTime = curTime;
        }

        public function startMusic():void
        {
            // Music
            if (_gvars.menuMusic == null)
            {
                _gvars.menuMusic = new SongPlayerBytes(null);
                _gvars.menuMusic.sound = new MenuMusic();
            }
            _gvars.menuMusic.start();
        }

        public function startIntroCutscene():void
        {
            startMusic();
            _gvars.menuMusic.fadeVolume(0.20);
            activeCutscene = new MenuCutscene(this);
            addChild(activeCutscene);
            activeCutscene.init(-3);
        }

        public function buildMinimap():void
        {
            minimap.graphics.clear();
            minimap.graphics.lineStyle(2, 0, 1, true);

            var gap:int = 380 / (genreLength * 2 - 1);

            for (var i:int = 0; i < genreLength; i++)
            {
                var color:uint = (songItems[i].songData.minimap || 0x000000);
                minimap.graphics.beginFill(color, 0.5);
                minimap.graphics.drawRect(i * (gap * 2), 20, 10, 10);
                minimap.graphics.endFill();

                if (i < genreLength - 1)
                {
                    minimap.graphics.moveTo(i * (gap * 2) + 10, 25);
                    minimap.graphics.lineTo((i + 1) * (gap * 2), 25);
                }
            }
            updateMinimap();
        }

        public function updateMinimap(doScroll:Boolean = false):void
        {
            var gap:int = 380 / (genreLength * 2 - 1);
            if (doScroll)
                TweenLite.to(minimapIcon, 0.5, {"x": (options.activeIndex * (gap * 2)) + 5});
            else
                minimapIcon.x = (options.activeIndex * (gap * 2)) + 5;
        }

        //******************************************************************************************//
        // Song Playlist / Item Logic
        //******************************************************************************************//
        /**
         * Generates a valid song list given the applied terms such as genre, search and filters.
         * Is also responsible for displaying the results in the scroll pane.
         */
        public function buildPlayList():void
        {
            //- Clear out/reset pane items and pages.
            songItems = new Vector.<SongItem>();

            //- Init Variables
            var song:Array;
            var sI:SongItem;

            //- Set Song array based on selected genre
            songList = _playlist.indexList;
            genreLength = songList.length;

            //- Sanity
            if (songList == null || songList.length <= 0)
            {
                options.activeIndex = -1;
                options.activeSongID = -1;
                return;
            }

            //- Build Playlist
            for (var sX:int = 0; sX < songList.length; sX++)
            {
                song = songList[sX];
                sI = new SongItem();
                sI.setData(song);
                sI.index = sX;
                songItems[songItems.length] = sI;
            }

            //- Update Selected Index
            // No song items to select, bail.
            if (songList.length <= 0)
                return;

            // Find and select last active song id.
            var hasSelected:Boolean = false;
            for (sX = 0; sX < songList.length; sX++)
            {
                song = songList[sX];
                if (options.activeSongID == song.level)
                {
                    setActiveIndex(sX, -1, false, false);
                    hasSelected = true;
                    break;
                }
            }

            // No active valid song found, clear saved actives.
            if (!hasSelected)
            {
                options.activeIndex = -1;
                options.activeSongID = -1;
            }

            // No song selected, select the first in the list if valid.
            if (options.activeIndex == -1)
            {
                setActiveIndex(0, -1, false, false);
            }
        }

        /**
         * Selects and highlights a Song Item in the playlist for the given index.
         * @param index New Index
         * @param last Last Selected Index, if not -1, unhighlights the given index.
         * @param doScroll Scrolls to the song item when true.
         * @param mpUpdate Send update to multiplayer for selection. Only send for user selection events.
         */
        public function setActiveIndex(index:int, last:int, doScroll:Boolean = false, mpUpdate:Boolean = true):void
        {
            // No need to do anything if nothing changed, or nothing to select
            if (index == last)
                return;

            // Reset on invalid index.
            if (songItems.length <= 0 || index < 0 || index >= songItems.length)
            {
                options.activeIndex = -1;
                options.activeSongID = -1;
                return;
            }

            // Set Index
            options.activeIndex = index;

            // Set Song
            options.activeSongID = songItems[index].level;

            // Set Active Highlights
            songItems[index].active = true;
            if (last >= 0 && last < songItems.length)
            {
                songItems[last].active = false;

                // Play Sound
                if (last == 0 && index == songItems.length - 1)
                    AudioManager.playSound("nav_left");
                else if (last == songItems.length - 1 && index == 0)
                    AudioManager.playSound("nav_right");
                else if (last > index)
                    AudioManager.playSound("nav_left");
                else
                    AudioManager.playSound("nav_right");
            }

            // Update Map
            var mapPoint:Object;
            if (songItems[index].songData.point != null)
                mapPoint = songItems[index].songData.point;
            else
                mapPoint = {"x": 450, "y": 1626};

            worldMapIcon.x = worldMapSongName.x = mapPoint.x;
            worldMapIcon.y = worldMapSongName.y = mapPoint.y;
            var gp:Point = worldMapIcon.localToGlobal(new Point(0, 0));

            gp.x -= worldMap.x;
            gp.y -= worldMap.y;

            if (doScroll)
                TweenLite.to(worldMap, 0.5, {"x": ((Main.GAME_WIDTH / 2) - gp.x), "y": ((Main.GAME_HEIGHT / 2) - gp.y) + 50, "ease": Quart.easeOut});
            else
            {
                worldMap.x = ((Main.GAME_WIDTH / 2) - gp.x);
                worldMap.y = ((Main.GAME_HEIGHT / 2) - gp.y) + 50;
            }
            updateMinimap(doScroll);
        }

        /**
         * Called from the playlist scroll pane when a song item is clicked.
         * When a new song is selected, sets the active index and draws the info box for the new song information.
         * If the same item is clicked twice, begins loading of the song.
         * @param e
         */
        private function songItemClicked(e:Event = null):void
        {
            if (e.target is SongItem)
            {
                var tarSongItem:SongItem = (e.target as SongItem);
                if (tarSongItem.index != options.activeIndex)
                {
                    setActiveIndex(tarSongItem.index, options.activeIndex);
                    buildInfoBox();
                }
                else
                {
                    playSong(tarSongItem.level);
                }
            }
        }


        //******************************************************************************************//
        // Info Box Logic
        //******************************************************************************************//

        /**
         * General builder for the Info Box.
         */
        public function buildInfoBox():void
        {
            // Get Song Details
            var songDetails:Object = _playlist.getSong(options.activeSongID);

            //- Sanity
            if (songDetails.error != null)
                return;

            //- Build Info Box
            buildInfoBoxSongDetails(songDetails);
        }

        /**
         * Builds the Song Details and Information Display for the InfoBox for the given song.
         * @param songDetails Song Object
         */
        public function buildInfoBoxSongDetails(songDetails:Object):void
        {
            if (songDetails.level == 1 && !Flags.canPlayLevel1())
            {
                lblSongName.text = "???";
                lblSongDifficulty.text = "???";
            }
            else
            {
                lblSongName.text = songDetails['display'];
                lblSongDifficulty.text = songDetails['difficulty'];
            }

            // Display All Difficulties
            songDifficulties.length = 0;

            if ((Flags.CUTSCENE_BITS & (1 << songDetails.level)) != 0)
            {
                var charts:Array = songDetails.embedData.getAllCharts();

                if (charts != null)
                {
                    var arrLen:int = charts.length;

                    difficultyHolder.removeChildren();
                    difficultyHolder.visible = true;
                    difficultyHolder.addChild(difficultySelector);

                    options.lastChartIndex = songDetails.embedData.DEFAULT_CHART_ID;

                    // Hide 8k chart.
                    if (songDetails.name == "Hello (BPM) 2021")
                        if (!Flags.KEYBOARD_BREAKER || !Flags.SEEN_SOLO_CUTSCENE || !Flags.SETUP_KEYS)
                            arrLen = 1;

                    // Build UI
                    for (var i:int = 0; i < arrLen; i++)
                    {
                        var chartSelectButton:DifficultyItem = new DifficultyItem(i, charts[i]);
                        chartSelectButton.addEventListener(MouseEvent.CLICK, e_difficultChange, false, 0, true);
                        difficultyHolder.addChild(chartSelectButton);
                        songDifficulties.push(chartSelectButton);
                    }

                    songDifficulties.sortOn("sorting_key", Array.NUMERIC);

                    options.lastChartIndex = Math.max(0, Math.min(songDifficulties.length - 1, options.lastChartIndex));

                    // Place UI
                    for (i = 0; i < songDifficulties.length; i++)
                    {
                        songDifficulties[i].index = i;
                        songDifficulties[i].y = i * 30;

                        if (i == options.lastChartIndex)
                        {
                            songDifficulties[i].x = 10;
                            difficultySelector.y = i * 30 + 13;
                        }
                    }
                }
                else
                {
                    difficultyHolder.visible = false;
                    options.lastChartIndex = 0;
                }
            }
            else
            {
                difficultyHolder.visible = false;
                options.lastChartIndex = songDetails.embedData.DEFAULT_CHART_ID;
            }

            updateInfoBoxSongDetails();
        }

        private function updateInfoBoxSongDetails():void
        {
            // Get Song Details
            var songDetails:Object = _playlist.getSong(options.activeSongID);

            //- Sanity
            if (songDetails.error != null)
                return;

            var charts:Array = songDetails.embedData.getAllCharts();

            if (charts != null && ((Flags.CUTSCENE_BITS & (1 << songDetails.level)) != 0))
            {
                // Get Selected Difficulty Song Details
                var chartData:Object = charts[songDifficulties[options.lastChartIndex].chart_id];

                lblAuthorName.text = chartData['author'] || songDetails['author'];
                lblStepAuthor.text = chartData['stepauthor'] || songDetails['stepauthor'];
                lblTime.text = chartData['time'] || songDetails['time'];
                lblNoteCount.text = sumArrows(chartData, songDetails).toString();
            }
            else
            {
                lblAuthorName.text = "???"; //songDetails['author'];
                lblStepAuthor.text = "???"; //songDetails['stepauthor'];
                lblTime.text = "???"; //songDetails['time'];
                lblNoteCount.text = "???"; //songDetails['arrows'];
            }
        }

        private function sumArrows(chart:Object = null, song:Object = null):Number
        {
            if (chart != null)
                return chart['arrows'] + chart['holds'];

            return song['arrows'];
        }

        private function e_difficultChange(e:MouseEvent):void
        {
            var tag:DifficultyItem = e.target as DifficultyItem;

            changeDifficulty(tag.index);
        }

        private function changeDifficulty(diffIndex:int):void
        {
            var newIndex:int = Math.max(0, Math.min(songDifficulties.length - 1, diffIndex));

            if (newIndex == options.lastChartIndex)
                return;

            // Play Sound
            if (newIndex < options.lastChartIndex)
                AudioManager.playSound("diff_up");
            else
                AudioManager.playSound("diff_down");

            for (var i:int = 0; i < songDifficulties.length; i++)
            {
                songDifficulties[i].y = i * 30;

                if (i == newIndex)
                {
                    TweenLite.to(songDifficulties[i], 0.3, {"x": 10, "ease": BounceOut.ease});
                    difficultySelector.y = i * 30 + 13;
                }
                if (i == options.lastChartIndex)
                    TweenLite.to(songDifficulties[i], 0.3, {"x": 0, "ease": BounceOut.ease});
            }

            options.lastChartIndex = newIndex;

            updateInfoBoxSongDetails();
        }

        /**
         * Reset the song queue and adds the provided level to the queue and starts the queue.
         * @param level Level ID to add.
         */
        public function playSong(level:int, skipSelectSound:Boolean = false):void
        {
            if (level < 0)
                return;

            if (!skipSelectSound)
                AudioManager.playSound("nav_select");

            var songData:Object = _playlist.getSong(level);

            if (songData.error == null)
            {
                if (songData.hasCutscene)
                {
                    if ((Flags.CUTSCENE_BITS & (1 << level)) == 0 && !skipSelectSound)
                    {
                        _gvars.menuMusic.fadeVolume(0.20);
                        activeCutscene = new MenuCutscene(this);
                        addChild(activeCutscene);
                        activeCutscene.init(level);
                        return;
                    }
                }

                _gvars.songQueue = [];
                _gvars.menuMusic.fadeStop();
                _gvars.songQueue.push(songData);
                playQueue();
            }
        }

        /**
         * Begins the current queue, while filtering out unplayable songs to prevent issues.
         */
        private function playQueue():void
        {
            if (_gvars.songQueue.length <= 0)
                return;

            _gvars.songQueue.length = 1;

            _gvars.options = new GameOptions();
            _gvars.options.fill();

            var levelData:Object = _gvars.songQueue[0];
            if ((Flags.CUTSCENE_BITS & (1 << levelData.level)) == 0)
            {
                Flags.CUTSCENE_BITS ^= (1 << levelData.level);
                LocalStore.setVariable("af2021_cutscene_bits", Flags.CUTSCENE_BITS);
                _gvars.options.selectedChartID = levelData.embedData.DEFAULT_CHART_ID;
            }
            else
            {
                _gvars.options.selectedChartID = (songDifficulties.length > 0 ? songDifficulties[options.lastChartIndex].chart_id : 0);
            }
            _gvars.gameMain.beginTransition();
            switchTo(Main.GAME_PLAY_PANEL);
        }

        public function endCutscene(startPlay:Boolean = false, level:int = -1):void
        {
            Mouse.show();

            // Reset Audio
            _gvars.menuMusicSoundTransform.volume = SoundUtils.getVolume(_gvars.menuMusicSoundVolume);

            if (_gvars.menuMusic && _gvars.menuMusic.isPlaying)
                _gvars.menuMusic.soundChannel.soundTransform = _gvars.menuMusicSoundTransform;

            if (activeCutscene != null)
            {
                if (activeCutscene.level == -3)
                    LocalStore.setVariable("af2021_title_splash", Flags.SEEN_TITLE);

                activeCutscene.dispose();
            }

            if (startPlay)
                playSong(level, true);
            else
                removeChild(activeCutscene);
        }

        //******************************************************************************************//
        // Event Handlers
        //******************************************************************************************//
        /**
         * General Click Handler for multiple objects.
         * @param e
         */
        private function clickHandler(e:Event):void
        {
            // Options
            if (e.target == optionsSimple)
            {
                AudioManager.playSound("nav_select");
                switchTo(MainMenu.MENU_OPTIONS);
                return;
            }

            else if (e.target == fileBrowserButton)
            {
                addPopup(new PopupFileBrowser(this));
                return;
            }

            // Nav Left / Right
            else if (e.target == navLeftBtn || e.target == navRightBtn)
            {
                var newIndex:int = options.activeIndex + (e.target == navLeftBtn ? -1 : 1);
                var lastIndex:int = options.activeIndex;

                if (newIndex < 0)
                    newIndex = genreLength - 1;
                else if (newIndex > genreLength - 1)
                    newIndex = 0;

                if (newIndex != lastIndex)
                {
                    setActiveIndex(newIndex, lastIndex, true);
                    buildInfoBox();
                    stage.focus = null;
                }

            }

            // Play Button
            else if (e.target == navPlayBtn)
            {
                playSong(options.activeSongID);
            }
            stage.focus = stage;
        }


        private var keyHistory:Array = [];

        /**
         * General Keyboard Key Down Handler for multiple objects.
         * @param e
         */
        private function keyHandler(e:KeyboardEvent):void
        {
            // Don't do anything with popups open.
            if (_gvars.gameMain.current_popup != null)
                return;

            keyHistory.unshift("|" + e.keyCode + "|");
            if (keyHistory.length > 10)
                keyHistory.length = 10;

            // Check and Reset
            if (checkInputHistory(keyHistory))
            {
                keyHistory.length = 0;
                return;
            }

            var newIndex:int = options.activeIndex;
            var lastIndex:int = options.activeIndex;

            switch (e.keyCode)
            {
                case Keyboard.LEFT:
                    newIndex -= 1;
                    break;

                case Keyboard.RIGHT:
                    newIndex += 1;
                    break;

                case Keyboard.UP:
                    changeDifficulty(options.lastChartIndex - 1);
                    return;

                case Keyboard.DOWN:
                    changeDifficulty(options.lastChartIndex + 1);
                    return;

                case Keyboard.F9:
                    if (!Flags.ENABLE_BROWSER)
                        return;

                    addPopup(new PopupFileBrowser(this));
                    return;

                case Keyboard.F10:
                    if (!Flags.ENABLE_BROWSER)
                        return;

                    var ff:File = new File();
                    ff.addEventListener(Event.SELECT, dirSelected);
                    ff.browseForDirectory("Select a directory");

                    function dirSelected(e:Event):void
                    {
                        var paths:FileTracker = ExternalChartScanner.getPossibleChartPaths(ff);
                        var hasMultiple:Boolean = false;
                        var exterFiles:Vector.<ExternalChartBase> = new <ExternalChartBase>[];
                        var emb:ExternalChartBase;

                        // Load Everything, Check how many valid loadable files.
                        if (paths.files > 0)
                            exterFiles = ExternalChartScanner.filterValid(paths);

                        // No Valid Found
                        if (exterFiles.length <= 0)
                            return;

                        // Set Level
                        if (exterFiles.length > 1)
                            new Prompt(stage, 320, "Charts Embed Select: (0 - " + (exterFiles.length - 1) + ")", 100, "SELECT", e_selectEmbed);
                        else
                            e_selectEmbed("0");

                        function e_selectEmbed(val:String):void
                        {
                            var index:int = parseInt(val);
                            if (isNaN(index) || index < 0 || index >= exterFiles.length)
                                index = 0;

                            emb = exterFiles[index];
                            emb.setID(_playlist.embedChartLength + 1);

                            var charts:Number = emb.getAllCharts().length;

                            if (charts <= 0)
                                return;

                            _playlist.addSongElement(emb, emb.getID(), true);

                            if (charts > 1)
                                new Prompt(stage, 320, "Charts Id Select: (0 - " + (charts - 1) + ")", 100, "SELECT", e_selectChart);
                            else
                                e_selectChart("0");
                        }

                        function e_selectChart(val:String):void
                        {
                            var index:int = parseInt(val);
                            if (isNaN(index))
                                index = 0;

                            options.activeIndex = emb.getID();
                            options.activeSongID = emb.getID();

                            // Start File
                            var songData:Object = _playlist.getSong(emb.getID());
                            _gvars.menuMusic.fadeStop();
                            _gvars.songQueue.push(songData);

                            _gvars.options = new GameOptions();
                            _gvars.options.fill();
                            _gvars.options.selectedChartID = parseInt(val);
                            _gvars.gameMain.beginTransition();
                            switchTo(Main.GAME_PLAY_PANEL);
                        }
                    }
                    return;

                case Keyboard.ENTER:
                    if (!((stage.focus is PushButton) || (stage.focus is TextField)) && options.activeSongID >= 0)
                    {
                        playSong(options.activeSongID);
                    }
                    return;
            }

            if (genreLength == 0)
                return;

            if (newIndex < 0)
                newIndex = genreLength - 1;
            else if (newIndex > genreLength - 1)
                newIndex = 0;

            if (newIndex != lastIndex)
            {
                setActiveIndex(newIndex, lastIndex, true);
                buildInfoBox();
                stage.focus = null;
            }
        }

        public function checkInputHistory(history:Array):Boolean
        {
            var his:String = keyHistory.join("");

            // darkness
            if (his.indexOf("|83||83||69||78||75||82||65||68|") >= 0 && !Flags.ANTIMATTER)
            {
                addPopup(new PopupSecretFind(this, "DESCENDING BEAR", "The true experience.\n\nCredits to Taro & Puuro for the original NotITG chart.\nFrom: Mod Boot Camp 3", "PLAY", function():void
                {
                    Flags.ANTIMATTER = true;
                    setActiveIndex(1, options.activeIndex, true);
                    buildInfoBox();
                    changeDifficulty(0);
                    playSong(options.activeSongID);
                    stage.focus = null;
                }));
                return true;
            }

            // painful
            if (his.indexOf("|76||85||70||78||73||65||80|") >= 0 && !Flags.KEYBOARD_BREAKER && Flags.SETUP_KEYS && ((Flags.CUTSCENE_BITS & (1 << 12)) != 0))
            {
                addPopup(new PopupSecretFind(this, "Impossible?", "You can't possibly think about surviving this right?\n\nIt shouldn't exist, but it does.", "PLAY", function():void
                {
                    Flags.KEYBOARD_BREAKER = true;
                    setActiveIndex(11, options.activeIndex, true);
                    buildInfoBox();
                    changeDifficulty(1);
                    playSong(options.activeSongID);
                    stage.focus = null;
                }));
                return true;
            }

            // looking
            if (his.indexOf("|71||78||73||75||79||79||76|") >= 0 && !Flags.ENABLE_BROWSER)
            {
                addPopup(new PopupSecretFind(this, "Looking Glass", "Playing your own files has never been easier. Press F9 to get started.", "CLOSE", function():void
                {
                    Flags.ENABLE_BROWSER = true;
                    ui.fileBrowserButton.visible = Flags.ENABLE_BROWSER;
                    fileBrowserButton.visible = Flags.ENABLE_BROWSER;
                }));
                return true;
            }

            return false;
        }

        public function playCacheFile(info:Object, id:int):void
        {
            Flags.PLAY_EXTERNAL_FILE = true;

            var emb:ExternalChartBase = new ExternalChartBase();
            emb.load(new File(info.loc));
            emb.setID(_playlist.embedChartLength + 1);
            _playlist.addSongElement(emb, emb.getID(), true);

            options.activeIndex = emb.getID();
            options.activeSongID = emb.getID();

            // Start File
            var songData:Object = _playlist.getSong(emb.getID());
            _gvars.menuMusic.fadeStop();
            _gvars.songQueue.push(songData);

            _gvars.options = new GameOptions();
            _gvars.options.fill();
            _gvars.options.selectedChartID = id;
            _gvars.gameMain.beginTransition();
            switchTo(Main.GAME_PLAY_PANEL);
        }
    }
}
