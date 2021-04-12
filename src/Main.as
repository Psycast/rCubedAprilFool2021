/**
 * @author Jonathan (Velocity)
 */

package
{
    import assets.GameBackgroundColor;
    import classes.Alert;
    import classes.AnimateTransition;
    import classes.Language;
    import classes.Noteskins;
    import classes.Playlist;
    import classes.User;
    import classes.ui.BoxButton;
    import classes.ui.ProgressBar;
    import classes.ui.Text;
    import com.flashdynamix.utils.SWFProfiler;
    import com.flashfla.utils.ObjectUtil;
    import com.flashfla.utils.SystemUtil;
    import com.greensock.TweenLite;
    import com.greensock.TweenMax;
    import com.greensock.easing.SineInOut;
    import com.greensock.plugins.AutoAlphaPlugin;
    import com.greensock.plugins.TintPlugin;
    import com.greensock.plugins.TweenPlugin;
    import flash.desktop.NativeApplication;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.system.Capabilities;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.ui.Keyboard;
    import game.GameMenu;
    import menu.MainMenu;
    import menu.MenuPanel;
    import popups.PopupContextMenu;
    import popups.PopupOptions;

    CONFIG::vsync
    {
        import flash.events.VsyncStateChangeAvailabilityEvent;
    }

    public class Main extends MenuPanel
    {
        public static const GAME_WIDTH:int = 780;
        public static const GAME_HEIGHT:int = 480;
        public static const GAME_LOGIN_PANEL:String = "GameLoginPanel";
        public static const GAME_MENU_PANEL:String = "GameMenuPanel";
        public static const GAME_PLAY_PANEL:String = "GamePlayPanel";
        public static const POPUP_OPTIONS:String = "PopupOptions";
        public static const EVENT_PANEL_SWITCHED:String = "maineventswitched";

        public var _gvars:GlobalVariables = GlobalVariables.instance;
        public var _playlist:Playlist = Playlist.instance;
        public var _lang:Language = Language.instance;
        public var _noteskins:Noteskins = Noteskins.instance;

        public var loadComplete:Boolean = false;
        public var disablePopups:Boolean = false;

        private var activeAlert:Alert;
        private var alertsQueue:Array = [];
        private var popupQueue:Array = [];
        private var lastPanel:MenuPanel;
        public var activePanel:MenuPanel;

        public var activePanelName:String;

        public var loadStatus:TextField;
        public var epilepsyWarning:TextField;

        public var ver:Text;
        public var bg:GameBackgroundColor;

        public var transitions:Vector.<AnimateTransition> = new <AnimateTransition>[];

        ///- Constructor
        public function Main():void
        {
            super(this);

            //- Set GlobalVariables Stage
            _gvars.gameMain = this;

            if (stage)
            {
                //- Set up vSync
                CONFIG::vsync
                {
                    stage.addEventListener(VsyncStateChangeAvailabilityEvent.VSYNC_STATE_CHANGE_AVAILABILITY, onVsyncStateChangeAvailability);
                }

                gameInit();
            }
            else
            {
                this.addEventListener(Event.ADDED_TO_STAGE, gameInit);
            }
        }

        CONFIG::vsync
        public function onVsyncStateChangeAvailability(event:VsyncStateChangeAvailabilityEvent):void
        {
            if (event.available)
                stage.vsyncEnabled = _gvars.air_useVSync;
            else
                stage.vsyncEnabled = true;
        }

        private function gameInit(e:Event = null):void
        {
            //- Remove Stage Listener
            if (e != null)
                this.removeEventListener(Event.ADDED_TO_STAGE, gameInit);

            //- Setup Tween Override mode
            TweenPlugin.activate([TintPlugin, AutoAlphaPlugin]);
            TweenLite.defaultOverwrite = "all";
            stage.stageFocusRect = false;

            //- Load Air Items
            _gvars.loadAirOptions();
            stage.nativeWindow.title = Constant.AIR_WINDOW_TITLE;
            NativeApplication.nativeApplication.addEventListener(Event.EXITING, _gvars.onNativeProcessClose);

            // Special Flags
            Flags.doLoad();

            //- Set Vars
            _gvars.flashvars = stage.loaderInfo.parameters;

            //- Background
            this.stage.color = 0x000000;

            bg = new GameBackgroundColor();
            this.addChild(bg);

            epilepsyWarning = new TextField();
            epilepsyWarning.x = 10;
            epilepsyWarning.y = stage.stageHeight * 0.15;
            epilepsyWarning.width = GAME_WIDTH - 20;
            epilepsyWarning.selectable = false;
            epilepsyWarning.embedFonts = true;
            epilepsyWarning.antiAliasType = AntiAliasType.ADVANCED;
            epilepsyWarning.defaultTextFormat = Constant.TEXT_FORMAT_CENTER;
            epilepsyWarning.textColor = 0xFFFFFF;
            epilepsyWarning.alpha = 0.2;
            epilepsyWarning.text = "WARNING: This game may potentially trigger seizures for people with photosensitive epilepsy.\nGamer discretion is advised."
            this.addChild(epilepsyWarning);

            TweenMax.to(epilepsyWarning, 1, {alpha: 0.6, ease: SineInOut.ease, yoyo: true, repeat: -1});

            //- Add Debug Tracking
            ver = new Text(this, stage.width - 5, 2, "SPECIAL");
            ver.alpha = 0.15;
            ver.align = Text.RIGHT;
            ver.mouseEnabled = false;
            ver.cacheAsBitmap = true;

            CONFIG::debug
            {
                stage.nativeWindow.x = (Capabilities.screenResolutionX - stage.nativeWindow.width) * 0.5;
                stage.nativeWindow.y = (Capabilities.screenResolutionY - stage.nativeWindow.height) * 0.5;
            }

            //- Build global right-click context menu
            buildContextMenu();

            //- Load Game Data
            _gvars.playerUser = new User(false, true);
            _gvars.activeUser = _gvars.playerUser;

            _playlist.load();
            _lang.load();
            _noteskins.load();

            //- Key listener
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardKeyDown, false, 0, true);
            stage.focus = this.stage;

            // Import Save Data
            LocalStore.doDataImport();

            //- No Reason
            CONFIG::debug
            {
                addAlert("Development Build - " + CONFIG::timeStamp + " - NOT FOR RELEASE", 120, Alert.RED);
            }

            switchTo(GAME_LOGIN_PANEL);
        }

        public function buildContextMenu():void
        {
            //- Backup Menu incase
            var cm:ContextMenu = new ContextMenu();

            //- Toggle Fullscreen
            var fscmi:ContextMenuItem = new ContextMenuItem(_lang.stringSimple("show_menu", "Show Menu"));
            fscmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, toggleContextPopup);
            cm.customItems.push(fscmi);

            //- Assign Menu Context
            this.contextMenu = cm;

            //- Profiler
            SWFProfiler.init(stage, this);
        }

        ///- Panels
        override public function switchTo(_panel:String, useNew:Boolean = false):Boolean
        {
            var isFound:Boolean = false;
            var nextPanel:MenuPanel;

            //- Add Requested Panel
            switch (_panel)
            {
                case GAME_LOGIN_PANEL:
                    nextPanel = new LoginMenu(this);
                    isFound = true;
                    break;

                case GAME_MENU_PANEL:
                    nextPanel = new MainMenu(this);
                    isFound = true;

                    if (this.contains(epilepsyWarning))
                    {
                        removeChild(epilepsyWarning);
                    }

                    break;

                case GAME_PLAY_PANEL:
                    nextPanel = new GameMenu(this);
                    isFound = true;
                    break;
            }

            if (isFound)
            {
                //- Remove last panel if exist
                if (activePanel != null)
                {
                    removeLastPanel(activePanel);
                    activePanel.mouseEnabled = false;
                    activePanel.mouseChildren = false;
                }

                activePanel = nextPanel;

                this.addChildAt(activePanel, 2);
                if (!activePanel.hasInit)
                {
                    activePanel.init();
                    activePanel.hasInit = true;
                }
                activePanel.stageAdd();
            }

            if (isFound)
            {
                this.activePanelName = _panel;
                dispatchEvent(new Event(EVENT_PANEL_SWITCHED));
            }

            return isFound;
        }

        private function removeLastPanel(removePanel:MenuPanel):void
        {
            if (removePanel)
            {
                removePanel.dispose();

                if (this.contains(removePanel))
                    this.removeChild(removePanel);

                removePanel = null;
            }
            SystemUtil.gc();
        }

        public function beginTransition():void
        {
            pauseTransition();

            // Create New
            var transition:AnimateTransition = new AnimateTransition(this.stage);

            unpauseTransition();

            // Track New
            transitions.push(transition);
        }

        private function pauseTransition():void
        {
            for (var i:int = transitions.length - 1; i >= 0; i--)
            {
                if (transitions[i].parent == null)
                    transitions.removeAt(i);
                else
                    transitions[i].pause();
            }
        }

        private function unpauseTransition():void
        {
            for (var i:int = transitions.length - 1; i >= 0; i--)
                transitions[i].resume();
        }

        ///- Popupa
        override public function addPopup(_panel:*, newLayer:Boolean = false):void
        {
            pauseTransition();

            if (newLayer && _panel is MenuPanel)
            {
                removeChildClass(ObjectUtil.getClass(_panel));
                this.addChild(_panel);
                if (!_panel.hasInit)
                {
                    _panel.init();
                    _panel.hasInit = true;
                }
                _panel.stageAdd();
            }
            else
            {
                if (current_popup)
                {
                    removePopup();
                }

                //- Add Requested Popop
                if (_panel is String)
                {
                    switch (_panel)
                    {
                        case POPUP_OPTIONS:
                            current_popup = new PopupOptions(this);
                            break;
                    }
                }
                else if (_panel is MenuPanel)
                {
                    current_popup = _panel;
                }
                this.addChildAt(current_popup, 3);
                if (!current_popup.hasInit)
                {
                    current_popup.init();
                    current_popup.hasInit = true;
                }
                current_popup.stageAdd();
            }

            unpauseTransition();
        }

        public function addPopupQueue(_panel:*, newLayer:Boolean = false):void
        {
            popupQueue.push({"panel": _panel, "layer": newLayer});
        }

        public function displayPopupQueue():void
        {
            if (popupQueue.length > 0)
            {
                var pop:Object = popupQueue.shift();
                addPopup(pop["panel"], pop["layer"]);
            }
        }

        override public function removePopup():void
        {
            if (current_popup)
            {
                current_popup.stageRemove();
                if (this.contains(current_popup))
                    this.removeChild(current_popup);
                current_popup = null;
            }
            stage.focus = this.stage;
            SystemUtil.gc();
            displayPopupQueue();
        }

        private function removeChildClass(clazz:Class):void
        {
            for (var i:int = 0; i < this.numChildren; i++)
            {
                if (this.getChildAt(i) is clazz)
                {
                    this.removeChildAt(i);
                    break;
                }
            }
        }

        ///- Game Alerts
        public function addAlert(message:String, age:int = 120, color:uint = 0x000000):void
        {
            if (activeAlert == null)
            {
                activeAlert = new Alert(message, age, color);
                activeAlert.x = GAME_WIDTH - activeAlert.width - 5;
                activeAlert.y = GAME_HEIGHT - activeAlert.height - 5;
                this.addChild(activeAlert);

                this.addEventListener(Event.ENTER_FRAME, alertOnFrame);
            }
            else
            {
                alertsQueue.push({ms: message, ag: age, col: color});
            }
        }

        private function alertOnFrame(e:Event):void
        {
            // Progress Active Alert
            if (activeAlert)
            {
                activeAlert.progress();
                if (activeAlert.time > activeAlert.age)
                {
                    this.removeChild(activeAlert);
                    activeAlert = null;
                    this.removeEventListener(Event.ENTER_FRAME, alertOnFrame);
                }
            }

            // Add new alert if the old alert is finished
            if (activeAlert == null && alertsQueue.length >= 1)
            {
                var newAlert:Object = alertsQueue.splice(0, 1)[0];
                addAlert(newAlert.ms, newAlert.ag, newAlert.col);
            }

            // General cleanup in case
            if (activeAlert == null && alertsQueue.length == 0)
            {
                this.removeEventListener(Event.ENTER_FRAME, alertOnFrame);
            }
        }

        ///- Fullscreen Handling
        private function toggleContextPopup(e:Event = null):void
        {
            if (current_popup is PopupContextMenu)
            {
                removePopup();
            }
            else
            {
                if (!disablePopups)
                {
                    addPopup(new PopupContextMenu(this));
                }
            }
        }

        ///- Key Handling
        private function keyboardKeyDown(e:KeyboardEvent):void
        {
            var keyCode:int = e.keyCode;
            if (!disablePopups)
            {
                // Options
                if (keyCode == _gvars.playerUser.keyOptions && (stage.focus == null || !(stage.focus is TextField)))
                {
                    if (current_popup is PopupOptions)
                    {
                        removePopup();
                    }
                    else
                    {
                        addPopup(Main.POPUP_OPTIONS);
                    }
                }
            }
            //CONFIG::debug
            //{
            if (keyCode == Keyboard.F6)
            {
                Flags.resetEvent();
                addAlert("Resetting Event Flags", 60, Alert.RED);
            }
            if (keyCode == Keyboard.F7)
            {
                Flags.finishEvent();
                addAlert("Finishing Event Flags", 60, Alert.GREEN);
            }
            if (keyCode == Keyboard.F8)
            {
                Flags.resetSecrets();
                addAlert("Resetting Secret Flags", 60, Alert.RED);
            }
            //}
        }
    }
}
