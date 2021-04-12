package popups
{
    import assets.menu.icons.fa.iconClose;
    import assets.menu.icons.fa.iconFolder;
    import assets.menu.icons.fa.iconUpLevel;
    import classes.FileTracker;
    import classes.Language;
    import classes.chart.levels.ExternalChartBase;
    import classes.chart.levels.ExternalChartCache;
    import classes.chart.levels.ExternalChartScanner;
    import classes.ui.Box;
    import classes.ui.BoxIcon;
    import classes.ui.Text;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.filesystem.File;
    import flash.filters.BlurFilter;
    import flash.geom.Point;
    import flash.utils.Timer;
    import flash.utils.getTimer;
    import menu.MenuPanel;
    import menu.MenuSongSelection;
    import flash.display.Loader;
    import flash.events.SecurityErrorEvent;
    import flash.events.IOErrorEvent;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.display.LoaderInfo;

    public class PopupFileBrowser extends MenuPanel
    {
        private var _lang:Language = Language.instance;

        public var lc:LoaderContext = new LoaderContext();

        public static var pathCache:ExternalChartCache = new ExternalChartCache();
        public static var rootFolder:File;

        public static var pathList:Vector.<String>;

        //- Background
        private var box:Box;
        private var bmd:BitmapData;
        private var bmp:Bitmap;
        private var dividers:Sprite;

        private var upFolder:BoxIcon;
        private var displayFolderPath:Text;
        private var selectFolder:BoxIcon;
        private var closeWindow:BoxIcon;

        private var songBrowser:ListFileBrowser;
        private var songDetails:Sprite;
        private var songDetailsWidth:Number = 0;
        private var songDifficulties:Array = [];

        private var uiLock:Sprite;
        private var loadingPathIndex:Text;
        private var loadingPathFolder:Text;
        private var loadingPathSong:Text;

        public function PopupFileBrowser(myParent:MenuPanel)
        {
            super(myParent);
        }

        override public function stageAdd():void
        {
            bmd = new BitmapData(Main.GAME_WIDTH, Main.GAME_HEIGHT, false, 0x000000);
            bmd.draw(stage);
            bmd.applyFilter(bmd, bmd.rect, new Point(), new BlurFilter(16, 16, 3));
            bmp = new Bitmap(bmd);

            this.addChild(bmp);

            var bgbox:Box = new Box(this, -1, -1, false, false);
            bgbox.setSize(Main.GAME_WIDTH + 2, Main.GAME_HEIGHT + 2);
            bgbox.color = 0x000000;
            bgbox.normalAlpha = 0.5;
            bgbox.activeAlpha = 1;

            box = new Box(this, -1, -1, false, false);
            box.setSize(Main.GAME_WIDTH + 2, Main.GAME_HEIGHT + 2);
            box.activeAlpha = 0.4;

            dividers = new Sprite();
            dividers.graphics.lineStyle(1, 0xffffff, 0.35);
            box.addChild(dividers);

            // Top Bar Item
            closeWindow = new BoxIcon(box, box.width - 32, 6, 27, 27, new iconClose(), clickHandler);
            selectFolder = new BoxIcon(box, closeWindow.x - 32, 6, 27, 27, new iconFolder(), clickHandler);

            displayFolderPath = new Text(box, 40, 6, "&lt;no folder selected&gt;");
            displayFolderPath.setAreaParams(selectFolder.x - displayFolderPath.x - 5, 27);
            displayFolderPath.useHandCursor = true;
            displayFolderPath.buttonMode = true;
            displayFolderPath.addEventListener(MouseEvent.CLICK, clickHandler);

            dividers.graphics.beginFill(0x000000, 0.2);
            dividers.graphics.drawRect(displayFolderPath.x - 2, displayFolderPath.y, displayFolderPath.width + 2, displayFolderPath.height);
            dividers.graphics.endFill();

            upFolder = new BoxIcon(box, 6, 6, 27, 27, new iconUpLevel(), clickHandler);

            // Song List
            songBrowser = new ListFileBrowser(box, 6, 39);
            songBrowser.addEventListener(MouseEvent.CLICK, e_songListClick);

            songDetails = new Sprite();
            songDetails.x = 511;
            songDetails.y = 39;
            songDetailsWidth = box.width - 37 - songDetails.x;
            box.addChild(songDetails);

            dividers.graphics.beginFill(0x000000, 0.2);
            dividers.graphics.drawRect(songDetails.x, songDetails.y, songDetailsWidth, box.height - 44);
            dividers.graphics.endFill();

            dividers.graphics.beginFill(0x000000, 0.2);
            dividers.graphics.drawRect(box.width - 32, 39, closeWindow.width, box.height - 44);
            dividers.graphics.endFill();

            // UI Lock
            uiLock = new Sprite();
            uiLock.graphics.lineStyle(0, 0, 0);
            uiLock.graphics.beginFill(0x000000, 0.7);
            uiLock.graphics.drawRect(0, 0, 780, 480);
            uiLock.graphics.endFill();

            var lockUIText:Text = new Text(uiLock, 0, 0, "Loading Files", 24);
            lockUIText.setAreaParams(780, 480, "center");

            loadingPathIndex = new Text(uiLock, 0, 380, "", 20);
            loadingPathIndex.setAreaParams(780, 30, "center");
            loadingPathFolder = new Text(uiLock, 0, 411, "", 22);
            loadingPathFolder.setAreaParams(780, 30, "center");
            loadingPathSong = new Text(uiLock, 0, 440, "", 18);
            loadingPathSong.setAreaParams(780, 30, "center");

            if (rootFolder != null && pathList == null)
                refreshFolder();
            else if (rootFolder != null && pathList != null)
            {
                displayFolderPath.text = rootFolder.nativePath;
                buildFileList();
            }
        }

        override public function stageRemove():void
        {
            closeWindow.dispose();
            box.dispose();
            this.removeChild(box);
            this.removeChild(bmp);
            bmd = null;
            bmp = null;
            box = null;
        }

        public function buildFileList():void
        {
            var renderList:Array = [];
            var cacheValue:Object;

            // List Building
            var path:String;
            var endOfFolder:Number;
            var arLen:Number = pathList.length;
            for (var i:int = 0; i < arLen; i++)
            {
                cacheValue = pathCache.getValue(pathList[i]);
                path = pathList[i];
                endOfFolder = path.lastIndexOf(File.separator) + 1;
                renderList[i] = {"folder": path.substr(0, endOfFolder), "file": path.substr(endOfFolder), "data": [{"loc": pathList[i], "info": cacheValue}]};
            }

            // Folder Merging
            var elm1:Object;
            var elm2:Object;
            var n:int;
            renderList.sortOn(["folder"], [Array.CASEINSENSITIVE]);
            for (i = 0; i < arLen - 1; i++)
            {
                elm1 = renderList[i];
                for (n = i + 1; n < arLen; n++)
                {
                    elm2 = renderList[n];
                    if (elm1.folder == elm2.folder)
                    {
                        while (elm2.data.length > 0)
                            elm1.data.push(elm2.data.pop());

                        renderList.removeAt(n);
                        n--;
                        arLen--;
                    }
                    else
                        break;
                }
            }

            // Sorting
            for (i = 0; i < arLen; i++)
            {
                elm1 = renderList[i];
                elm1.author = elm1.data[0].info.author;
                elm1.name = elm1.data[0].info.name;
                elm1.banner = elm1.data[0].info.banner;
            }
            renderList.sortOn(["author", "name"], [Array.CASEINSENSITIVE, Array.CASEINSENSITIVE]);

            // Display
            songBrowser.setRenderList(renderList);
        }

        private function dirSelected(e:Event):void
        {
            rootFolder = e.target as File;
            refreshFolder();
        }

        private function clickHandler(e:MouseEvent):void
        {
            if (e.target == upFolder)
            {
                if (rootFolder != null)
                {
                    rootFolder = rootFolder.parent;
                    refreshFolder();
                }
            }
            if (e.target == selectFolder || e.target == displayFolderPath)
            {
                var tempFolder:File = new File();
                tempFolder.addEventListener(Event.SELECT, dirSelected);
                tempFolder.browseForDirectory("Select a directory");
            }
            //- Close
            if (e.target == closeWindow)
            {
                removePopup();
                return;
            }
        }

        private function refreshFolder():void
        {
            if (rootFolder == null)
                return;

            pathList = new <String>[];

            displayFolderPath.text = rootFolder.nativePath;

            lockUI = true;

            var loadStartTime:Number = getTimer();

            var delayTimer:Timer = new Timer(100, 1);
            delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, e_loadDelay);
            delayTimer.start();

            function e_loadDelay(e:Event):void
            {
                var filePaths:FileTracker = ExternalChartScanner.getPossibleChartPaths(rootFolder);

                if (filePaths.file_paths.length <= 0)
                {
                    lockUI = false;
                    buildFileList();
                    return;
                }

                var loadTimer:Timer = new Timer(20, 1);
                loadTimer.addEventListener(TimerEvent.TIMER_COMPLETE, e_parseTimer);

                var pathIndex:int = 0;
                var pathTotal:int = filePaths.file_paths.length;

                loadingPathIndex.text = pathIndex + " / " + pathTotal;
                loadingPathFolder.text = '';
                loadingPathSong.text = '';

                function e_parseTimer(e:TimerEvent):void
                {
                    var emb:ExternalChartBase;
                    var stringPath:String;
                    var startTimer:Number = getTimer();
                    var isDelay:Boolean = false;
                    var cacheObj:Object;

                    while (pathIndex < pathTotal)
                    {
                        stringPath = filePaths.file_paths[pathIndex];
                        if ((cacheObj = pathCache.getValue(stringPath)) != null)
                        {
                            if (cacheObj.valid == 1)
                                pathList.push(stringPath);
                        }
                        else
                        {
                            var chartFile:File = new File(stringPath);

                            loadingPathIndex.text = pathIndex + " / " + pathTotal;

                            if (chartFile.parent.parent.nativePath == rootFolder.nativePath)
                            {
                                loadingPathFolder.text = chartFile.parent.name;
                                loadingPathSong.text = '';
                            }
                            else
                            {
                                loadingPathFolder.text = chartFile.parent.parent.name;
                                loadingPathSong.text = chartFile.parent.name;
                            }

                            cacheObj = {"valid": 0}
                            emb = new ExternalChartBase();
                            if (emb.load(chartFile, true))
                            {
                                var chartData:Object = emb.getInfo();
                                var chartCharts:Array = emb.getAllCharts();

                                cacheObj = {"valid": 1,
                                        "name": chartData['name'],
                                        "author": chartData['author'],
                                        "stepauthor": chartData['stepauthor'],
                                        "difficulty": chartData['difficulty'],
                                        "music": chartData['music'],
                                        "banner": chartData['banner'],
                                        "chart": []}

                                for (var i:int = 0; i < chartCharts.length; i++)
                                {
                                    var difficultyData:Object = chartCharts[i];
                                    cacheObj['chart'][i] = {"class": difficultyData['class'],
                                            "class_color": difficultyData['class_color'],
                                            "desc": difficultyData['desc'],
                                            "difficulty": difficultyData['difficulty'],
                                            "type": difficultyData['type'],
                                            "radar_values": difficultyData['radar_values'],
                                            "arrows": difficultyData['arrows'],
                                            "holds": difficultyData['holds'],
                                            "mines": difficultyData['mines']};
                                }
                            }

                            pathCache.setValue(stringPath, cacheObj);

                            if (cacheObj.valid == 1)
                                pathList.push(stringPath);
                        }
                        pathIndex++;

                        var endTimer:Number = getTimer();
                        if (endTimer - startTimer > 100)
                        {
                            isDelay = true;
                            break;
                        }
                    }

                    // Loaded All Files
                    if (pathIndex >= pathTotal)
                    {
                        pathCache.save();
                        lockUI = false;

                        buildFileList();
                        return;
                    }

                    // Not Finished, Continue next frame.
                    if (isDelay && pathIndex < pathTotal)
                    {
                        loadTimer.start();
                    }
                }

                loadTimer.start();
            }
        }

        private function e_songListClick(e:MouseEvent):void
        {
            if (e.target is FileBrowserItem)
            {
                var item:FileBrowserItem = e.target as FileBrowserItem;
                setInfoBox(item.songData);
            }
        }

        public function setInfoBox(info:Object):void
        {
            songDetails.removeChildren();
            songDifficulties.length = 0;

            var infoTitle:Text;
            var infoDetails:Text;
            var tY:int = 83;

            // Create Holder Sprite
            var sr:Sprite = drawInfoBannerSprite(0, 0.3);
            sr.x = 10;
            sr.y = 10;
            songDetails.addChild(sr);

            // Mask
            var srm:Sprite = drawInfoBannerSprite(0, 1);
            sr.addChild(srm);
            sr.mask = srm;

            // Border
            var srb:Sprite = drawInfoBannerSprite(0.35, 0);
            srb.x = 10;
            srb.y = 10;
            songDetails.addChild(srb);

            // Banner
            if (info.banner != "")
            {
                // Check Extension
                var bannerExt:String = info.banner.substr(info.banner.lastIndexOf(".") + 1).toLowerCase();
                if (bannerExt == "jpg" || bannerExt == "png" || bannerExt == "gif" || bannerExt == "jpeg")
                {
                    var path:String = "file:///" + info.folder + info.banner;
                    var imageLoader:Loader = new Loader();
                    imageLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, e_bannerLoaded);
                    imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, e_bannerLoaded);
                    imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, e_bannerLoaded);
                    imageLoader.load(new URLRequest(path), lc);

                    function e_bannerLoaded(e:Event):void
                    {
                        // Position Loaded Banner Image
                        if (e.type == Event.COMPLETE && e.target != null && ((e.target as LoaderInfo).content) != null)
                        {
                            var bmp:Bitmap = ((e.target as LoaderInfo).content) as Bitmap;
                            bmp.smoothing = true;
                            bmp.pixelSnapping = "always";
                            sr.addChildAt(bmp, 1);

                            var imageScale:Number = 214 / bmp.width;

                            bmp.scaleX = bmp.scaleY = imageScale;

                            if (bmp.height < 70)
                            {
                                bmp.scaleX = bmp.scaleY = 1;
                                imageScale = 70 / bmp.height;
                                bmp.scaleX = bmp.scaleY = imageScale;
                                bmp.x = -((bmp.width - 214) / 2);
                            }
                            else
                                bmp.y = -((bmp.height - 70) / 2);
                        }
                    }
                }
            }

            // Print Song Info
            var infoDisplay:Array = [[info['data'][0]['info']['name'], 14], [info['data'][0]['info']['author'], 12]];
            for (var item:String in infoDisplay)
            {
                // Info Display
                infoDetails = new Text(songDetails, 5, tY, infoDisplay[item][0], infoDisplay[item][1]);
                infoDetails.setAreaParams(songDetailsWidth - 10, 23, "center");
                tY += 23;
            }

            // Build UI
            var sources:Array = info.data;
            for (var s:int = 0; s < sources.length; s++)
            {
                var charts:Array = sources[s].info.chart;
                for (var i:int = 0; i < charts.length; i++)
                {
                    var chartSelectButton:FileBrowserDifficultyItem = new FileBrowserDifficultyItem(i, sources[s]);
                    chartSelectButton.addEventListener(MouseEvent.CLICK, e_difficultySelect, false, 0, true);
                    songDetails.addChild(chartSelectButton);
                    songDifficulties.push(chartSelectButton);
                }
            }

            songDifficulties.sortOn("sorting_key", Array.NUMERIC);

            // Place UI
            tY = 0;
            for (i = songDifficulties.length - 1; i >= 0; i--)
            {
                songDifficulties[i].x = 9;
                songDifficulties[i].y = 405 - tY;
                tY += 30;
            }
        }

        public function drawInfoBannerSprite(border:Number, bg:Number):Sprite
        {
            var srm:Sprite = new Sprite();
            srm.graphics.lineStyle(2, 0xffffff, border, true);
            srm.graphics.beginFill(0, bg);
            srm.graphics.drawRoundRect(0, 0, 215, 70, 25, 25);
            srm.graphics.endFill();
            return srm;
        }

        private function e_difficultySelect(e:MouseEvent):void
        {
            var tar:FileBrowserDifficultyItem = e.target as FileBrowserDifficultyItem;

            removePopup();
            (my_Parent as MenuSongSelection).playCacheFile(tar.cache_info, tar.chart_id);
        }

        public function set lockUI(val:Boolean):void
        {
            if (val)
            {
                this.addChild(uiLock);
            }
            else
            {
                if (this.contains(uiLock))
                {
                    this.removeChild(uiLock);
                }
            }
        }
    }
}