package popups
{
    import arc.ArcGlobals;
    import assets.GameBackgroundColor;
    import classes.Alert;
    import classes.Language;
    import classes.Noteskins;
    import classes.NoteskinsStruct;
    import classes.Playlist;
    import classes.User;
    import classes.chart.Song;
    import classes.replay.Base64Decoder;
    import classes.replay.Base64Encoder;
    import classes.ui.Box;
    import classes.ui.BoxButton;
    import classes.ui.BoxCheck;
    import classes.ui.BoxSlider;
    import classes.ui.BoxText;
    import classes.ui.ColorField;
    import classes.ui.MouseTooltip;
    import classes.ui.Prompt;
    import classes.ui.Text;
    import classes.ui.ValidatedText;
    import com.bit101.components.ComboBox;
    import com.bit101.components.Window;
    import com.flashfla.utils.ArrayUtil;
    import com.flashfla.utils.ColorUtil;
    import com.flashfla.utils.ObjectUtil;
    import com.flashfla.utils.SoundUtils;
    import com.flashfla.utils.StringUtil;
    import com.flashfla.utils.SystemUtil;
    import com.flashfla.utils.sprintf;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.filters.BlurFilter;
    import flash.geom.Point;
    import flash.media.SoundMixer;
    import flash.media.SoundTransform;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.text.TextFieldAutoSize;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.utils.ByteArray;
    import game.GameOptions;
    import game.controls.GameNote;
    import menu.MenuPanel;

    public class PopupOptions extends MenuPanel
    {
        private const TAB_MAIN:int = 0;
        private const TAB_VISUAL_MODS:int = 1;
        private const TAB_COLORS:int = 2;
        private const TAB_OTHER:int = 3;

        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _avars:ArcGlobals = ArcGlobals.instance;
        private var _lang:Language = Language.instance;
        private var _noteskins:Noteskins = Noteskins.instance;
        private var _playlist:Playlist = Playlist.instance;

        private var DEFAULT_OPTIONS:GameOptions = new GameOptions();
        private var DEFAULT_USER:User = new User();

        //- Background
        private var box:Box;
        private var bmd:BitmapData;
        private var bmp:Bitmap;

        private var CURRENT_TAB:int = TAB_MAIN;

        private var keyListenerTarget:*;

        //- Arrays
        private var keyGlobalInputs:Array = ["restart", "quit", "options", "autoplay"];
        private var judgeTitles:Array = ["amazing", "perfect", "good", "average", "miss", "boo", "holdOK", "holdNG"];
        private var displayArray:Array = ["JUDGE", "JUDGE_ANIMATIONS", "RECEPTOR", "RECEPTOR_ANIMATIONS", "HEALTH", "SCORE", "COMBO", "PACOUNT", "SONGPROGRESS", "AMAZING", "PERFECT", "TOTAL", "SCREENCUT", "GAME_TOP_BAR", "GAME_BOTTOM_BAR"];
        private var enableToggles:Array = ["Boos", "Holds", "Mines", "Failure"];
        private var noteColorComboArray:Array = [];
        private var startUpScreenSelections:Array = [];

        //- Menu
        private var menuMain:BoxButton;
        private var menuVisualMods:BoxButton;
        private var menuGameColors:BoxButton;
        private var menuInput:BoxButton;
        private var closeOptions:BoxButton;
        private var resetOptions:BoxButton;
        private var editorOptions:BoxButton;
        private var _contextImportExport:ContextMenu;
        private var hover_message:MouseTooltip;

        //- Options
        private var optionGameSpeed:ValidatedText;
        private var optionOffset:ValidatedText;
        private var optionJudgeOffset:ValidatedText;
        private var gameJudgeOffset:Text;
        private var autoJudgeOffsetCheck:BoxCheck;
        private var gameAutoJudgeOffset:Text;
        private var optionReceptorSpacing:ValidatedText;
        private var optionReceptorSplitSpacing:ValidatedText;
        private var optionNoteScale:BoxSlider;
        private var optionGameVolume:BoxSlider;
        private var gameVolumeValueDisplay:Text;
        private var optionFPS:ValidatedText;
        private var optionRate:ValidatedText;
        private var optionScrollDirections:Vector.<BoxCheck>;
        private var optionEnableToggles:Array;
        private var menuVolumeValueDisplay:Text;
        private var noteScaleValueDisplay:Text;
        private var optionMenuVolume:BoxSlider;
        private var optionAutofail:Array;
        private var useVSyncCheckbox:BoxCheck;
        private var useWebsocketCheckbox:BoxCheck;
        private var openWebsocketOverlay:BoxButton;

        private var optionDisplays:Array;
        private var optionVisualGameMods:Array;
        private var optionJudgeSpeed:BoxSlider;
        private var gameJudgeSpeedDisplay:Text;
        private var optionReceptorAnimationSpeed:BoxSlider;
        private var gameReceptorAnimationSpeedDisplay:Text;
        private var optionGameMods:Array;
        private var optionNoteskins:Array;
        private var optionNoteskinPreview:GameNote;
        private var optionOpenCustomNoteskinEditor:BoxButton;
        private var optionImportCustomNoteskin:BoxButton;
        private var optionCopyCustomNoteskin:BoxButton;
        private var noteskin_struct:Object = NoteskinsStruct.getDefaultStruct();
        private var fileData:ByteArray;

        private var optionJudgeColors:Array;
        private var optionComboColors:Array;
        private var optionComboColorCheck:BoxCheck;
        private var optionNoteColors:Array;
        private var optionRawGoodTracker:ValidatedText;

        private var optionGlobalKeyInputs:Array;
        private var optionColumnKeyInputs:Array;

        private var receptorRotations:Object = {4: [90, 0, 180, 270],
                6: [90, 135, 0, 180, 225, 270],
                8: [90, 0, 180, 270, 90, 0, 180, 270]};

        public function PopupOptions(myParent:MenuPanel)
        {
            super(myParent);
        }

        override public function stageAdd():void
        {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            stage.focus = this.stage;

            bmd = new BitmapData(Main.GAME_WIDTH, Main.GAME_HEIGHT, false, 0x000000);
            bmd.draw(stage);
            bmd.applyFilter(bmd, bmd.rect, new Point(), new BlurFilter(16, 16, 3));
            bmp = new Bitmap(bmd);

            this.addChild(bmp);

            var bgbox:Box = new Box(this, 20, 10, false, false);
            bgbox.setSize(Main.GAME_WIDTH - 40, Main.GAME_HEIGHT - 20);
            bgbox.color = 0x000000;
            bgbox.normalAlpha = 0.5;
            bgbox.activeAlpha = 1;

            box = new Box(this, 20, 10, false, false);
            box.setSize(Main.GAME_WIDTH - 40, Main.GAME_HEIGHT - 20);
            box.activeAlpha = 0.4;

            // Import / Export Context Menu
            _contextImportExport = new ContextMenu();
            var expOptionsImport:ContextMenuItem = new ContextMenuItem(_lang.stringSimple("popup_options_import"));
            expOptionsImport.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, e_contextOptionsImport);
            var expOptionsExport:ContextMenuItem = new ContextMenuItem(_lang.stringSimple("popup_options_export"));
            expOptionsExport.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, e_contextOptionsExport);
            _contextImportExport.customItems.push(expOptionsImport, expOptionsExport);

            // Render Options
            renderOptions();
        }

        private function e_contextOptionsExport(e:ContextMenuEvent):void
        {
            var optionsString:String = JSON.stringify(_gvars.activeUser.save(true));
            var success:Boolean = SystemUtil.setClipboard(optionsString);
            if (success)
            {
                _gvars.gameMain.addAlert(_lang.string("clipboard_success"), 120, Alert.GREEN);
            }
            else
            {
                _gvars.gameMain.addAlert(_lang.string("clipboard_failure"), 120, Alert.RED);
            }
        }

        private function e_contextOptionsImport(e:ContextMenuEvent):void
        {
            new Prompt(box.parent, 320, _lang.string("popup_options_import"), 100, "IMPORT", e_importOptions);
        }

        private function e_importOptions(optionsJSON:String):void
        {
            try
            {
                var item:Object = JSON.parse(optionsJSON);
                _gvars.activeUser.settings = item;
                _gvars.gameMain.addAlert("Settings Imported!", 120, Alert.GREEN);
                renderOptions();
            }
            catch (e:Error)
            {
                _gvars.gameMain.addAlert("Import Fail...", 120, Alert.GREEN);
            }
        }

        private function renderMenu():void
        {
            var tab_width:int = 170;
            menuMain = new BoxButton(box, 15, 15, tab_width, 25, _lang.string("options_menu_main"), 12, clickHandler);
            menuMain.menu_select = TAB_MAIN;

            menuVisualMods = new BoxButton(box, menuMain.x + tab_width + 10, 15, tab_width, 25, _lang.string("options_menu_visual_mods"), 12, clickHandler);
            menuVisualMods.menu_select = TAB_VISUAL_MODS;

            menuGameColors = new BoxButton(box, menuVisualMods.x + tab_width + 10, 15, tab_width, 25, _lang.string("options_menu_game_colors"), 12, clickHandler);
            menuGameColors.menu_select = TAB_COLORS;

            menuInput = new BoxButton(box, menuGameColors.x + tab_width + 10, 15, tab_width, 25, _lang.string("options_menu_input"), 12, clickHandler);
            menuInput.menu_select = TAB_OTHER;

            //- Close
            closeOptions = new BoxButton(box, box.width - 95, box.height - 42, 80, 27, _lang.string("menu_close"), 12, clickHandler);
            closeOptions.contextMenu = _contextImportExport;

            //- Reset
            resetOptions = new BoxButton(box, box.width - 180, box.height - 42, 80, 27, _lang.string("menu_reset"), 12, clickHandler);
            resetOptions.color = 0xff0000;

            //- Editor
            editorOptions = new BoxButton(null, box.width - 265, box.height - 42, 80, 27, _lang.string("menu_editor"));
            editorOptions.editor_multiplayer = null;

            editorOptions.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
            box.addChild(editorOptions);
        }

        override public function stageRemove():void
        {
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            for (var index:int = 0; index < box.numChildren; index++)
            {
                var item:DisplayObject = box.getChildAt(index);
                item.removeEventListener(MouseEvent.CLICK, clickHandler);
                item.removeEventListener(Event.CHANGE, changeHandler);
            }

            box.dispose();
            this.removeChild(box);
            this.removeChild(bmp);
            bmd = null;
            bmp = null;
            box = null;
        }

        private function renderOptions():void
        {
            if (box == null)
            {
                return;
            }

            for (var index:int = box.numChildren - 1; index >= 0; index--)
            {
                var olditem:DisplayObject = box.getChildAt(index);
                olditem.removeEventListener(MouseEvent.CLICK, clickHandler);
                olditem.removeEventListener(Event.CHANGE, changeHandler);
                box.removeChild(olditem);
            }

            renderMenu();

            var BASE_Y_POSITION:int = 50;
            var item:Object;
            var xOff:int = 15;
            var yOff:int = BASE_Y_POSITION;

            if (CURRENT_TAB == TAB_MAIN)
            {
                menuMain.active = true;
                menuMain.color = GameBackgroundColor.BG_POPUP;
                menuMain.normalAlpha = 0.9;
                menuMain.activeAlpha = 1;

                /// Col 1
                //- Speed
                var gameSpeed:Text = new Text(box, xOff, yOff, _lang.string("options_speed"));
                yOff += 20;

                optionGameSpeed = new ValidatedText(box, xOff, yOff, 100, 20, ValidatedText.R_FLOAT_P, changeHandler);
                yOff += 30;

                //- Global Offset
                var gameOffset:Text = new Text(box, xOff, yOff, _lang.string("options_global_offset"));
                yOff += 20;

                optionOffset = new ValidatedText(box, xOff, yOff, 100, 20, ValidatedText.R_FLOAT, changeHandler);
                yOff += 30;

                //- Judge Offset
                gameJudgeOffset = new Text(box, xOff, yOff, _lang.string("options_judge_offset"));
                yOff += 20;

                optionJudgeOffset = new ValidatedText(box, xOff, yOff, 100, 20, ValidatedText.R_FLOAT, changeHandler);

                //- Auto Judge Offset
                xOff += 105;
                autoJudgeOffsetCheck = new BoxCheck(box, xOff, yOff, clickHandler);
                autoJudgeOffsetCheck.addEventListener(MouseEvent.MOUSE_OVER, e_autoJudgeMouseOver, false, 0, true);
                gameAutoJudgeOffset = new Text(box, xOff - 2, yOff - 20, _lang.string("options_auto_judge_offset"));
                xOff -= 105;
                yOff += 30;

                //- Receptor Spacing
                var gameReceptorSpacing:Text = new Text(box, xOff, yOff, _lang.string("options_receptor_spacing"));
                yOff += 20;

                optionReceptorSpacing = new ValidatedText(box, xOff, yOff, 100, 20, ValidatedText.R_INT, changeHandler);
                yOff += 30;

                //- Receptor Split Spacing
                var gameReceptorSplitSpacing:Text = new Text(box, xOff, yOff, _lang.string("options_receptor_split_spacing"));
                yOff += 20;

                optionReceptorSplitSpacing = new ValidatedText(box, xOff, yOff, 100, 20, ValidatedText.R_INT, changeHandler);
                yOff += 30;

                //- Note Scale
                var gameNoteScale:Text = new Text(box, xOff, yOff, _lang.string("options_note_scale"));
                yOff += 20;

                optionNoteScale = new BoxSlider(box, xOff, yOff, 100, 10, changeHandler);
                optionNoteScale.minValue = 0.1;
                optionNoteScale.maxValue = 1.5;
                yOff += 10;

                noteScaleValueDisplay = new Text(box, xOff, yOff, Math.round(_gvars.activeUser.noteScale * 100) + "%");
                yOff += 20;

                // Engine Framerate
                var gameFPS:Text = new Text(box, xOff, yOff, _lang.string("options_framerate"));
                yOff += 20;

                optionFPS = new ValidatedText(box, xOff, yOff, 100, 20, ValidatedText.R_INT_P, changeHandler);
                yOff += 30;

                // Song Rate
                var gameRate:Text = new Text(box, xOff, yOff, _lang.string("options_rate"));
                yOff += 20;

                optionRate = new ValidatedText(box, xOff, yOff, 100, 20, ValidatedText.R_FLOAT_P, changeHandler);
                yOff += 40;

                /// Col 2
                xOff += 176;
                yOff = BASE_Y_POSITION;

                //- Direction
                optionScrollDirections = new <BoxCheck>[];
                var gameDirection:Text = new Text(box, xOff, yOff, _lang.string("options_scroll"));
                yOff += 20;

                var directionData:Array = _gvars.SCROLL_DIRECTIONS;
                for (var i:int = 0; i < directionData.length; i++)
                {
                    var gameDirectionOptionText:Text = new Text(box, xOff + 22, yOff, _lang.string("options_scroll_" + directionData[i]));
                    yOff += 2;

                    var optionScrollCheck:BoxCheck = new BoxCheck(box, xOff + 2, yOff, clickHandler);
                    optionScrollCheck.slideDirection = directionData[i];
                    optionScrollDirections.push(optionScrollCheck);
                    yOff += 20;
                }

                /// Col 3
                xOff += 176;
                yOff = BASE_Y_POSITION;

                // Autofail
                optionAutofail = [];
                var gameAutofail:Text = new Text(box, xOff, yOff, _lang.string("options_autofail"));
                yOff += 20;

                for (i = 0; i < judgeTitles.length; i++)
                {
                    var optionAutofailText:Text = new Text(box, xOff + 77, yOff - 1, _lang.string("game_" + judgeTitles[i]));

                    var optionAutofailInput:ValidatedText = new ValidatedText(box, xOff, yOff, 70, 20, ValidatedText.R_INT_P, changeHandler);
                    optionAutofailInput.autofail = judgeTitles[i];
                    optionAutofailInput.field.maxChars = 5;
                    optionAutofail.push(optionAutofailInput);
                    yOff += 25;
                }
                // raw goods aren't a judge title, and is two words - so separate accordingly
                optionAutofailText = new Text(box, xOff + 77, yOff - 1, _lang.string("game_raw_goods"));

                optionAutofailInput = new ValidatedText(box, xOff, yOff, 70, 20, ValidatedText.R_FLOAT_P, changeHandler);
                optionAutofailInput.autofail = "rawGoods";
                optionAutofailInput.field.maxChars = 6;
                optionAutofail.push(optionAutofailInput);
                yOff += 25;

                /// Col 4
                xOff += 176;
                yOff = BASE_Y_POSITION;

                CONFIG::vsync
                {
                    var useVSyncCheckboxText:Text = new Text(box, xOff + 20, yOff, _lang.string("air_options_use_vsync"));
                    yOff += 2;

                    useVSyncCheckbox = new BoxCheck(box, xOff, yOff, clickHandler);
                    yOff += 30;
                }

                var useWebsocketCheckboxText:Text = new Text(box, xOff + 20, yOff, _lang.string("air_options_use_websockets"));
                yOff += 2;

                useWebsocketCheckbox = new BoxCheck(box, xOff, yOff, clickHandler);
                useWebsocketCheckbox.addEventListener(MouseEvent.MOUSE_OVER, e_websocketMouseOver, false, 0, true);
                yOff += 30;

                // https://github.com/flashflashrevolution/web-stream-overlay
                openWebsocketOverlay = new BoxButton(box, xOff, yOff, 150, 27, _lang.string("options_overlay_instructions"), 12, clickHandler);
                yOff += 30;

                yOff += 20;

                // Game Volume
                var gameVolume:Text = new Text(box, xOff, yOff, _lang.string("options_volume"));
                yOff += 20;

                optionGameVolume = new BoxSlider(box, xOff, yOff, 100, 10, changeHandler);
                optionGameVolume.maxValue = 1;
                yOff += 10;

                gameVolumeValueDisplay = new Text(box, xOff, yOff, Math.round(_gvars.activeUser.gameVolume * 100) + "%");
                yOff += 20;

                // Menu Music Volume
                var menuVolume:Text = new Text(box, xOff, yOff, _lang.string("air_options_menu_volume"));
                yOff += 20;

                optionMenuVolume = new BoxSlider(box, xOff, yOff, 100, 10, changeHandler);
                optionMenuVolume.maxValue = 1;
                yOff += 10;

                menuVolumeValueDisplay = new Text(box, xOff, yOff, Math.round(_gvars.menuMusicSoundVolume * 100) + "%");
                yOff += 20;
            }
            else if (CURRENT_TAB == TAB_VISUAL_MODS)
            {
                menuVisualMods.active = true;
                menuVisualMods.color = GameBackgroundColor.BG_POPUP;
                menuVisualMods.normalAlpha = 0.9;
                menuVisualMods.activeAlpha = 1;

                ///- Col 1
                //- Display
                optionDisplays = [];
                var gameDisplay:Text = new Text(box, xOff, yOff, _lang.string("options_display"));
                yOff += 20;

                for (i = 0; i < displayArray.length; i++)
                {
                    var gameDisplayName:Text;
                    if (displayArray[i] == "----")
                    {
                        gameDisplayName = new Text(box, xOff + 23, yOff - 8, "----");
                        yOff += 10;
                    }
                    else
                    {
                        gameDisplayName = new Text(box, xOff + 23, yOff - 3, _lang.string("options_" + displayArray[i].toLowerCase()));

                        var gameDisplayCheck:BoxCheck = new BoxCheck(box, xOff + 3, yOff, clickHandler);
                        gameDisplayCheck.display = displayArray[i];
                        optionDisplays.push(gameDisplayCheck);
                        yOff += 20;
                    }
                    if (displayArray[i] == "JUDGE_ANIMATIONS")
                    {
                        yOff -= 4;
                        var gameJudgeSpeed:Text = new Text(box, xOff + 23, yOff, _lang.string("options_judge_speed"));
                        yOff += 23;

                        optionJudgeSpeed = new BoxSlider(box, xOff + 23, yOff, 100, 10, changeHandler);
                        optionJudgeSpeed.minValue = 0.25;
                        optionJudgeSpeed.maxValue = 3;

                        gameJudgeSpeedDisplay = new Text(box, xOff + 128, yOff - 5, _gvars.activeUser.judgeSpeed.toFixed(2) + "x");
                        yOff += 20;
                    }
                    if (displayArray[i] == "RECEPTOR_ANIMATIONS")
                    {
                        yOff -= 4;
                        var gameReceptorAnimationSpeed:Text = new Text(box, xOff + 23, yOff, _lang.string("options_receptor_speed"));
                        yOff += 23;

                        optionReceptorAnimationSpeed = new BoxSlider(box, xOff + 23, yOff, 100, 10, changeHandler);
                        optionReceptorAnimationSpeed.minValue = 0.25;
                        optionReceptorAnimationSpeed.maxValue = 3;

                        gameReceptorAnimationSpeedDisplay = new Text(box, xOff + 128, yOff - 5, _gvars.activeUser.receptorAnimationSpeed.toFixed(2) + "x");
                        yOff += 20;
                    }
                }

                ///- Col 2
                xOff += 206;
                yOff = BASE_Y_POSITION;

                //- Mods
                optionGameMods = [];
                var gameModsName:Text = new Text(box, xOff, yOff, _lang.string("options_game_mods"));
                yOff += 20;

                var modsData:Array = _gvars.GAME_MODS;
                for (i = 0; i < modsData.length; i++)
                {
                    if (modsData[i] == "----")
                    {
                        var gameModOptionTextSpacer:Text = new Text(box, xOff + 23, yOff - 8, "----");
                        yOff += 10;
                        continue;
                    }
                    var gameModOptionText:Text = new Text(box, xOff + 23, yOff - 3, _lang.string("options_mod_" + modsData[i]));

                    var optionModCheck:BoxCheck = new BoxCheck(box, xOff + 3, yOff, clickHandler);
                    optionModCheck.mod = modsData[i];
                    optionGameMods.push(optionModCheck);
                    yOff += 20;
                }

                ///- Col 3
                xOff += 146;
                yOff = BASE_Y_POSITION;

                //- Visual Mods
                optionVisualGameMods = [];
                var gameVisualModsName:Text = new Text(box, xOff, yOff, _lang.string("options_visual_mods"));
                yOff += 20;

                var modsVisualData:Array = _gvars.VISUAL_MODS;
                for (i = 0; i < modsVisualData.length; i++)
                {
                    if (modsVisualData[i] == "----")
                    {
                        var gameVisualModOptionTextSpacer:Text = new Text(box, xOff + 23, yOff - 8, "----");
                        yOff += 10;
                        continue;
                    }
                    var gameVisualModOptionText:Text = new Text(box, xOff + 23, yOff - 3, _lang.string("options_mod_" + modsVisualData[i]));

                    var optionVisualModCheck:BoxCheck = new BoxCheck(box, xOff + 3, yOff, clickHandler);
                    optionVisualModCheck.visual_mod = modsVisualData[i];
                    optionVisualGameMods.push(optionVisualModCheck);
                    yOff += 20;
                }

                // Enable Toggles
                yOff += 30;
                optionEnableToggles = [];
                var gameEnableToggle:Text = new Text(box, xOff, yOff, _lang.string("options_other_gameplay_toggles"));
                yOff += 20;

                for (i = 0; i < enableToggles.length; i++)
                {
                    var gameEnableName:Text;

                    gameEnableName = new Text(box, xOff + 23, yOff - 3, _lang.string("options_enable_" + enableToggles[i].toLowerCase()));

                    var gameEnableCheck:BoxCheck = new BoxCheck(box, xOff + 3, yOff, clickHandler);
                    gameEnableCheck.enable_toggle = enableToggles[i];
                    optionEnableToggles.push(gameEnableCheck);
                    yOff += 20;
                }


                ///- Col 4
                xOff += 176;
                yOff = BASE_Y_POSITION;

                //- Noteskins
                optionNoteskins = [];
                var gameNoteskin:Text = new Text(box, xOff, yOff, _lang.string("options_noteskin"));
                yOff += 20;

                var gameNoteskinName:Text;
                var gameNoteskinCheck:BoxCheck;

                // Custom
                gameNoteskinName = new Text(box, xOff + 23, yOff - 3, _lang.string("options_noteskin_custom"));

                gameNoteskinCheck = new BoxCheck(box, xOff + 3, yOff, clickHandler);
                gameNoteskinCheck.skin = 0;
                optionNoteskins.push(gameNoteskinCheck);
                yOff += 20;

                var noteskinData:Object = _noteskins.data;
                var noteskin_ids:Array = [];
                for each (item in noteskinData)
                    if (item["_hidden"] == null)
                        noteskin_ids.push(item.id);
                noteskin_ids.sort(Array.NUMERIC);
                for each (var noteskin_id:String in noteskin_ids)
                {
                    item = noteskinData[noteskin_id];
                    gameNoteskinName = new Text(box, xOff + 23, yOff - 3, item.name);

                    gameNoteskinCheck = new BoxCheck(box, xOff + 3, yOff, clickHandler);
                    gameNoteskinCheck.skin = item.id;
                    optionNoteskins.push(gameNoteskinCheck);
                    yOff += 20;
                }

                optionOpenCustomNoteskinEditor = new BoxButton(box, xOff + 3, yOff + 1, 179, 23, _lang.string("options_open_noteskin_editor"), 12, clickHandler);
                yOff += 25;

                optionImportCustomNoteskin = new BoxButton(box, xOff + 3, yOff + 1, 179, 23, _lang.string("options_import_noteskin_json"), 12, clickHandler);
                yOff += 25;

                optionCopyCustomNoteskin = new BoxButton(box, xOff + 3, yOff + 1, 179, 23, _lang.string("options_copy_noteskin_data"), 12, clickHandler);
            }
            else if (CURRENT_TAB == TAB_COLORS)
            {
                menuGameColors.active = true;
                menuGameColors.color = GameBackgroundColor.BG_POPUP;
                menuGameColors.normalAlpha = 0.9;
                menuGameColors.activeAlpha = 1;

                ///- Col 1
                var gameJudgeColorTitle:Text = new Text(box, xOff + 5, yOff, _lang.string("options_judge_colors_title"));
                gameJudgeColorTitle.width = 211;
                gameJudgeColorTitle.align = Text.CENTER;
                yOff += 24;

                optionJudgeColors = [];
                for (i = 0; i < judgeTitles.length; i++)
                {
                    var gameJudgeColor:Text = new Text(box, xOff, yOff, _lang.string("game_" + judgeTitles[i]));
                    gameJudgeColor.width = 70;
                    gameJudgeColor.align = Text.RIGHT;

                    var optionJudgeColor:ValidatedText = new ValidatedText(box, xOff + 75, yOff, 70, 20, ValidatedText.R_COLOR, changeHandler);
                    optionJudgeColor.judge_color_id = i;
                    optionJudgeColor.field.maxChars = 7;

                    var gameJudgeColorDisplay:ColorField = new ColorField(box, xOff + 150, yOff, 0, 45, 20, changeHandler);
                    gameJudgeColorDisplay.key_name = "optionJudgeColor";

                    var optionJudgeColorReset:BoxButton = new BoxButton(box, xOff + 200, yOff, 20, 20, "R", 12, clickHandler);
                    optionJudgeColorReset.judge_color_reset_id = i;
                    optionJudgeColorReset.color = 0xff0000;
                    optionJudgeColors.push({"text": optionJudgeColor, "display": gameJudgeColorDisplay, "reset": optionJudgeColorReset});

                    yOff += 25;
                }

                yOff += 25;

                ///- Col 2
                xOff += 245;
                yOff = BASE_Y_POSITION;

                var gameComboColorTitle:Text = new Text(box, xOff + 5, yOff, _lang.string("options_combo_colors_title"));
                gameComboColorTitle.width = 211;
                gameComboColorTitle.align = Text.CENTER;
                yOff += 24;

                optionComboColors = [];
                for (i = 0; i < DEFAULT_OPTIONS.comboColours.length; i++)
                {
                    var gameComboColor:Text = new Text(box, xOff, yOff, _lang.string("options_combo_colors_" + i));
                    gameComboColor.width = 70;
                    gameComboColor.align = Text.RIGHT;

                    var optionComboColor:ValidatedText = new ValidatedText(box, xOff + 75, yOff, 70, 20, ValidatedText.R_COLOR, changeHandler);
                    optionComboColor.combo_color_id = i;
                    optionComboColor.field.maxChars = 7;

                    var gameComboColorDisplay:ColorField = new ColorField(box, xOff + 150, yOff, 0, 45, 20, changeHandler);
                    gameComboColorDisplay.key_name = "gameComboColorDisplay";

                    var optionComboColorReset:BoxButton = new BoxButton(box, xOff + 200, yOff, 20, 20, "R", 12, clickHandler);
                    optionComboColorReset.combo_color_reset_id = i;
                    optionComboColorReset.color = 0xff0000;

                    if (i > 0)
                    {
                        optionComboColorCheck = new BoxCheck(box, xOff + 225, yOff + 3, clickHandler);
                        optionComboColorCheck.combo_color_enable_id = i;
                    }

                    optionComboColors.push({"text": optionComboColor, "display": gameComboColorDisplay, "reset": optionComboColorReset, "enable": optionComboColorCheck});

                    yOff += 25;
                }

                var gameRawGoodTracker:Text = new Text(box, xOff, yOff, _lang.string("options_raw_goods_tracker"));
                gameRawGoodTracker.width = 70;
                gameRawGoodTracker.align = Text.RIGHT;
                optionRawGoodTracker = new ValidatedText(box, xOff + 75, yOff, 70, 20, ValidatedText.R_FLOAT_P, changeHandler)

                ///- Col 3
                xOff += 245;
                yOff = BASE_Y_POSITION;

                var gameNoteColorTitle:Text = new Text(box, xOff + 5, yOff, _lang.string("options_note_colors_title"));
                gameNoteColorTitle.width = 211;
                gameNoteColorTitle.align = Text.CENTER;
                yOff += 24;

                // Create ComboBox Data
                noteColorComboArray = [];
                for (i = 0; i < DEFAULT_OPTIONS.noteColors.length; i++)
                {
                    noteColorComboArray.push({"label": _lang.stringSimple("note_colors_" + DEFAULT_OPTIONS.noteColors[i]), "data": DEFAULT_OPTIONS.noteColors[i]});
                }

                optionNoteColors = [];
                for (i = 0; i < DEFAULT_OPTIONS.noteColors.length; i++)
                {
                    var gameNoteColor:Text = new Text(box, xOff, yOff, _lang.string("note_colors_" + DEFAULT_OPTIONS.noteColors[i]));
                    gameNoteColor.width = 70;
                    gameNoteColor.align = Text.RIGHT;

                    var gameNoteColorCombo:ComboBox = new ComboBox(box, xOff + 75, yOff, _lang.stringSimple("note_colors_" + DEFAULT_OPTIONS.noteColors[i]), noteColorComboArray);
                    gameNoteColorCombo.width = 105;
                    gameNoteColorCombo.openPosition = ComboBox.BOTTOM;
                    gameNoteColorCombo.fontSize = 11;
                    gameNoteColorCombo.addEventListener(Event.SELECT, gameNoteColorSelect);
                    box.addChild(gameNoteColorCombo);
                    optionNoteColors.push(gameNoteColorCombo);
                    yOff += 25;
                }

            }
            else if (CURRENT_TAB == TAB_OTHER)
            {
                menuInput.active = true;
                menuInput.color = GameBackgroundColor.BG_POPUP;
                menuInput.normalAlpha = 0.9;
                menuInput.activeAlpha = 1;

                var inputBorderSprite:Sprite = new Sprite();
                inputBorderSprite.graphics.lineStyle(1, 0xffffff, 0.35);
                box.addChild(inputBorderSprite);

                // Params
                var resetY:Number = 155;
                var inputGroups:Array = [4];
                if (Flags.SEEN_SOLO_CUTSCENE)
                {
                    if (!Flags.SETUP_KEYS)
                    {
                        Flags.SETUP_KEYS = true;
                        LocalStore.setVariable("af2021_setup_keys", true);
                    }

                    resetY = BASE_Y_POSITION - 5;
                    inputGroups = [4, 6, 8];
                    _lang.data["us"]["options_column_count_4"] = "4 Key / Single:";

                    resetOptions.x = box.width - 95;
                    resetOptions.y = box.height - 74;

                    editorOptions.x = box.width - 95;
                    editorOptions.y = box.height - 106;
                }
                else
                {
                    _lang.data["us"]["options_column_count_4"] = "Gameplay:";
                }

                //- Global Keys
                var gameKeyInput:BoxText;

                optionGlobalKeyInputs = [];
                xOff = box.width - 185;
                yOff = resetY;

                var gameKeyOtherText:Text = new Text(box, xOff, yOff, _lang.string("options_input_other"), 14);
                yOff += 23;
                for (i = 0; i < keyGlobalInputs.length; i++)
                {
                    inputBorderSprite.graphics.beginFill(0x000000, 0.25);
                    inputBorderSprite.graphics.drawRect(xOff, yOff, 170, 25);
                    inputBorderSprite.graphics.endFill();

                    var gameKeyText:Text = new Text(box, xOff + 57, yOff + 3, _lang.string("options_scroll_" + keyGlobalInputs[i]));

                    gameKeyInput = new BoxText(box, xOff + 2, yOff + 2, 50, 20);
                    gameKeyInput.autoSize = TextFieldAutoSize.CENTER;
                    gameKeyInput.mouseEnabled = true;
                    gameKeyInput.mouseChildren = false;
                    gameKeyInput.useHandCursor = true;
                    gameKeyInput.buttonMode = true;
                    gameKeyInput.key = keyGlobalInputs[i];
                    gameKeyInput.addEventListener(MouseEvent.CLICK, clickHandler);
                    optionGlobalKeyInputs.push(gameKeyInput);
                    yOff += 31;
                }

                // Gameplay Inputs
                xOff = 15;
                yOff = resetY;
                optionColumnKeyInputs = [];
                var data:Object = _noteskins.getInfo(_gvars.activeUser.activeNoteskin);
                var hasRotation:Boolean = (data.rotation != 0);

                var receptorSize:Number = 38;
                var inputWidth:Number = 64;
                var inputGap:Number = 10;
                var inputHeight:Number = 99;
                var curOffX:Number = 0;
                var n:int;

                for each (var columnCount:int in inputGroups)
                {
                    var gameSetKeyText:Text = new Text(box, xOff, yOff, _lang.string("options_column_count_" + columnCount), 14);
                    yOff += 23;

                    var noteScale:Number = -1;
                    for (i = 0; i < columnCount; i++)
                    {
                        curOffX = xOff + (inputWidth * i);
                        if (i > 0)
                            curOffX += (inputGap * i);

                        inputBorderSprite.graphics.beginFill(0x000000, 0.25);
                        inputBorderSprite.graphics.drawRect(curOffX, yOff, inputWidth, inputHeight);
                        inputBorderSprite.graphics.endFill();

                        // Set Image
                        var columnDirectionNote:MovieClip = _noteskins.getReceptor(data.id, "D");

                        if (hasRotation)
                            columnDirectionNote.rotation = receptorRotations[columnCount][i];

                        if (noteScale < 0)
                            noteScale = Math.min(1, (receptorSize / Math.max(columnDirectionNote.width, columnDirectionNote.height)));

                        columnDirectionNote.scaleX = columnDirectionNote.scaleY = noteScale;
                        box.addChild(columnDirectionNote);

                        columnDirectionNote.x = curOffX + (inputWidth / 2);
                        columnDirectionNote.y = yOff + (receptorSize / 2) + 5;

                        // Set Inputs
                        for (n = 0; n < 2; n++)
                        {
                            gameKeyInput = new BoxText(box, curOffX + ((inputWidth - 50) / 2), yOff + (n * 25) + receptorSize + 10, 50, 20);
                            gameKeyInput.autoSize = TextFieldAutoSize.CENTER;
                            gameKeyInput.mouseEnabled = true;
                            gameKeyInput.mouseChildren = false;
                            gameKeyInput.useHandCursor = true;
                            gameKeyInput.buttonMode = true;
                            gameKeyInput.column_set = columnCount;
                            gameKeyInput.column_index = i;
                            gameKeyInput.column_index_set = n;
                            gameKeyInput.addEventListener(MouseEvent.CLICK, clickHandler);
                            optionColumnKeyInputs.push(gameKeyInput);
                        }
                    }

                    for (n = 0; n < 2; n++)
                    {
                        var optionKeySetReset:BoxButton = new BoxButton(box, curOffX + inputWidth + inputGap, yOff + (n * 25) + receptorSize + 10, 21, 21, "R", 12, clickHandler);
                        optionKeySetReset.reset_keys = i;
                        optionKeySetReset.reset_keys_set = n;
                        optionKeySetReset.color = 0xff0000;
                    }

                    yOff += inputHeight + 7;
                }

            }
            setSettings();
        }

        private function changeHandler(e:Event):void
        {
            if (e.target == optionGameSpeed)
            {
                _gvars.activeUser.gameSpeed = optionGameSpeed.validate(1, 0.1);
            }
            else if (e.target == optionOffset)
            {
                _gvars.activeUser.GLOBAL_OFFSET = optionOffset.validate(0);
            }
            else if (e.target == optionJudgeOffset)
            {
                _gvars.activeUser.JUDGE_OFFSET = optionJudgeOffset.validate(0);
            }
            else if (e.target == optionReceptorSpacing)
            {
                _gvars.activeUser.receptorGap = optionReceptorSpacing.validate(80);
            }
            else if (e.target == optionReceptorSplitSpacing)
            {
                _gvars.activeUser.receptorSplitGap = optionReceptorSplitSpacing.validate(0);
            }
            else if (e.target == optionNoteScale)
            {
                var sliderValue:int = Math.round(Math.max(Math.min(optionNoteScale.slideValue, optionNoteScale.maxValue), optionNoteScale.minValue) * 100);

                // Snap to larger value when close.
                var snapTarget:int = 25;
                var snapValue:int = sliderValue % snapTarget;
                if (snapValue == 1 || snapValue == snapTarget - 1)
                    sliderValue = Math.round(sliderValue / snapTarget) * snapTarget;

                _gvars.activeUser.noteScale = sliderValue / 100;
                noteScaleValueDisplay.text = sliderValue + "%";
            }
            else if (e.target == optionJudgeSpeed)
            {
                _gvars.activeUser.judgeSpeed = (Math.round((optionJudgeSpeed.slideValue * 100) / 5) * 5) / 100; // Snap to 0.05 intervals.
                gameJudgeSpeedDisplay.text = _gvars.activeUser.judgeSpeed.toFixed(2) + "x";
            }
            else if (e.target == optionReceptorAnimationSpeed)
            {
                _gvars.activeUser.receptorAnimationSpeed = (Math.round((optionReceptorAnimationSpeed.slideValue * 100) / 5) * 5) / 100; // Snap to 0.05 intervals.
                gameReceptorAnimationSpeedDisplay.text = _gvars.activeUser.receptorAnimationSpeed.toFixed(2) + "x";
            }
            else if (e.target == optionFPS)
            {
                _gvars.activeUser.frameRate = optionFPS.validate(60);
                _gvars.activeUser.frameRate = Math.max(Math.min(_gvars.activeUser.frameRate, 250), 10);
            }
            else if (e.target == optionRate)
            {
                _gvars.activeUser.songRate = optionRate.validate(1, 0.1);
            }
            else if (e.target == optionRawGoodTracker)
            {
                _gvars.activeUser.rawGoodTracker = optionRawGoodTracker.validate(0, 0);
            }
            else if (e.target.hasOwnProperty("autofail"))
            {
                var autofail:String = StringUtil.upperCase(e.target.autofail);
                _gvars.activeUser["autofail" + autofail] = e.target.validate(0, 0);
            }
            else if (e.target.hasOwnProperty("judge_color_id"))
            {
                var jid:int = e.target.judge_color_id;
                _gvars.activeUser.judgeColours[jid] = e.target.validate(0, 0);
                optionJudgeColors[jid]["display"].color = _gvars.activeUser.judgeColours[jid];
            }
            else if (e.target.hasOwnProperty("combo_color_id"))
            {
                var cid:int = e.target.combo_color_id;
                _gvars.activeUser.comboColours[cid] = e.target.validate(0, 0);
                optionComboColors[cid]["display"].color = _gvars.activeUser.comboColours[cid];
            }
            else if (e.target is ColorField)
            {
                var sourceArray:Array;
                switch (e.target.key_name)
                {
                    case "optionJudgeColor":
                        sourceArray = optionJudgeColors;
                        break;
                    case "gameComboColorDisplay":
                        sourceArray = optionComboColors;
                        break;
                }
                for each (var item:Object in sourceArray)
                {
                    if (item.display == e.target)
                    {
                        (item.text as BoxText).text = "#" + StringUtil.pad((e.target as ColorField).color.toString(16).substr(0, 6), 6, "0", StringUtil.STR_PAD_LEFT);
                        (item.text as BoxText).dispatchEvent(new Event(Event.CHANGE));
                    }
                }
            }
            else if (e.target == optionGameVolume)
            {
                _gvars.activeUser.gameVolume = optionGameVolume.slideValue;
                if (isNaN(_gvars.activeUser.gameVolume))
                {
                    _gvars.activeUser.gameVolume = 1;
                }
                _gvars.activeUser.gameVolume = Math.max(Math.min(_gvars.activeUser.gameVolume, optionGameVolume.maxValue), optionGameVolume.minValue);
                gameVolumeValueDisplay.text = Math.round(_gvars.activeUser.gameVolume * 100) + "%";
                _gvars.activeUser.gameVolumeSoundTransform.volume = SoundUtils.getVolume(_gvars.activeUser.gameVolume);
                SoundMixer.soundTransform = _gvars.activeUser.gameVolumeSoundTransform;
            }
            else if (e.target == optionMenuVolume)
            {
                _gvars.menuMusicSoundVolume = optionMenuVolume.slideValue;
                if (isNaN(_gvars.menuMusicSoundVolume))
                {
                    _gvars.menuMusicSoundVolume = 1;
                }
                _gvars.menuMusicSoundVolume = Math.max(Math.min(_gvars.menuMusicSoundVolume, optionMenuVolume.maxValue), optionMenuVolume.minValue);
                menuVolumeValueDisplay.text = Math.round(_gvars.menuMusicSoundVolume * 100) + "%";
                _gvars.menuMusicSoundTransform.volume = SoundUtils.getVolume(_gvars.menuMusicSoundVolume);

                if (_gvars.menuMusic && _gvars.menuMusic.isPlaying)
                    _gvars.menuMusic.soundChannel.soundTransform = _gvars.menuMusicSoundTransform;
            }
        }

        private function keyDownHandler(e:KeyboardEvent):void
        {
            if (keyListenerTarget)
            {
                var keyCode:uint = e.keyCode;
                var keyChar:String = StringUtil.keyCodeChar(keyCode).toUpperCase();
                if (keyChar != "")
                {
                    if (keyListenerTarget.hasOwnProperty("key"))
                        _gvars.activeUser["key" + StringUtil.upperCase(keyListenerTarget.key)] = keyCode;
                    else if (keyListenerTarget.hasOwnProperty("column_set"))
                        _gvars.activeUser.keyBuilder[keyListenerTarget.column_index_set][keyListenerTarget.column_set][keyListenerTarget.column_index] = keyCode;

                    keyListenerTarget.text = keyChar;
                    keyListenerTarget = null;
                        //setSettings();
                }
            }
        }

        private function e_autoJudgeMouseOver(e:Event):void
        {
            autoJudgeOffsetCheck.addEventListener(MouseEvent.MOUSE_OUT, e_autoJudgeMouseOut);
            displayToolTip(autoJudgeOffsetCheck.x + 40, autoJudgeOffsetCheck.y + 15, _lang.string("popup_auto_judge_offset"));
        }

        private function e_autoJudgeMouseOut(e:Event):void
        {
            autoJudgeOffsetCheck.removeEventListener(MouseEvent.MOUSE_OUT, e_autoJudgeMouseOut);
            removeChild(hover_message);
        }

        private function e_websocketMouseOver(e:Event = null):void
        {
            if (_gvars.air_useWebsockets)
            {
                var activePort:uint = _gvars.websocketPortNumber("websocket");
                if (activePort > 0)
                {
                    useWebsocketCheckbox.addEventListener(MouseEvent.MOUSE_OUT, e_websocketMouseOut);
                    displayToolTip(useWebsocketCheckbox.x + 40, useWebsocketCheckbox.y + 15, sprintf(_lang.string("air_options_active_port"), {"port": _gvars.websocketPortNumber("websocket").toString()}), "left");
                }
            }
        }

        private function e_websocketMouseOut(e:Event):void
        {
            useWebsocketCheckbox.removeEventListener(MouseEvent.MOUSE_OUT, e_websocketMouseOut);
            removeChild(hover_message);
        }

        private function displayToolTip(tx:Number, ty:Number, text:String, align:String = "left"):void
        {
            if (!hover_message)
                hover_message = new MouseTooltip();
            hover_message.message = text;

            switch (align)
            {
                default:
                case "left":
                    hover_message.x = tx;
                    hover_message.y = ty;
                    break;
                case "right":
                    hover_message.x = tx - hover_message.width;
                    hover_message.y = ty;
                    break;
            }

            addChild(hover_message);
        }

        private function clickHandler(e:MouseEvent):void
        {
            //- Menu Select
            if (e.target.hasOwnProperty("menu_select"))
            {
                CURRENT_TAB = e.target.menu_select;
                renderOptions();
            }

            //- Scroll Direction
            else if (e.target.hasOwnProperty("slideDirection"))
            {
                var dir:String = e.target.slideDirection;
                _gvars.activeUser.slideDirection = dir;
            }

            //- Keys
            else if (e.target.hasOwnProperty("key") || e.target.hasOwnProperty("column_set"))
            {
                setSettings();
                keyListenerTarget = e.target;
                keyListenerTarget.htmlText = _lang.string("options_key_pick");
                return;
            }
            else if (e.target.hasOwnProperty("reset_keys"))
            {
                var columnCount:int = e.target.reset_keys;
                var keySet:int = e.target.reset_keys_set;
                var keyCount:int = DEFAULT_USER.keyBuilder[keySet][columnCount].length;

                for (var i:int = 0; i < keyCount; i++)
                    _gvars.activeUser.keyBuilder[keySet][columnCount][i] = DEFAULT_USER.keyBuilder[keySet][columnCount][i];

                keyListenerTarget = null;

                setSettings();
                return;
            }

            //- Visual Mods
            else if (e.target.hasOwnProperty("visual_mod"))
            {
                var visual_mod:String = e.target.visual_mod;
                if (_gvars.activeUser.activeVisualMods.indexOf(visual_mod) != -1)
                {
                    ArrayUtil.removeValue(visual_mod, _gvars.activeUser.activeVisualMods);
                }
                else
                {
                    _gvars.activeUser.activeVisualMods.push(visual_mod);
                }
            }

            //- Mods
            else if (e.target.hasOwnProperty("mod"))
            {
                var mod:String = e.target.mod;
                if (_gvars.activeUser.activeMods.indexOf(mod) != -1)
                {
                    ArrayUtil.removeValue(mod, _gvars.activeUser.activeMods);
                }
                else
                {
                    _gvars.activeUser.activeMods.push(mod);
                }
            }

            //- Noteskin
            else if (e.target.hasOwnProperty("skin"))
            {
                _gvars.activeUser.activeNoteskin = e.target.skin;
            }

            //- Custom Noteskin Editor
            else if (e.target == optionOpenCustomNoteskinEditor)
            {
                navigateToURL(new URLRequest(Constant.NOTESKIN_EDITOR_URL), "_blank");
                return;
            }

            //- Import Custom Noteskin
            else if (e.target == optionImportCustomNoteskin)
            {
                new Prompt(box.parent, 320, _lang.string("popup_noteskin_import_json"), 100, "IMPORT", e_importNoteskin);
            }

            //- Copy Custom Noteskin
            else if (e.target == optionCopyCustomNoteskin)
            {
                var success:Boolean = SystemUtil.setClipboard(noteskinsString());
                if (success)
                    GlobalVariables.instance.gameMain.addAlert(_lang.string("clipboard_success"), 120, Alert.GREEN);
                else
                    GlobalVariables.instance.gameMain.addAlert(_lang.string("clipboard_failure"), 120, Alert.RED);
                return;
            }

            //- Displays
            else if (e.target.hasOwnProperty("display"))
            {
                _gvars.activeUser["DISPLAY_" + e.target.display] = !_gvars.activeUser["DISPLAY_" + e.target.display];
                if (e.target.display == "SONG_FLAG" || e.target.display == "SONG_NOTE")
                {
                    _gvars.gameMain.activePanel.draw();
                }
            }

            //- Enable Toggles
            else if (e.target.hasOwnProperty("enable_toggle"))
            {
                _gvars.activeUser["enable" + e.target.enable_toggle] = !_gvars.activeUser["enable" + e.target.enable_toggle];
            }

            //- Auto Judge Offset
            else if (e.target == autoJudgeOffsetCheck)
            {
                _gvars.activeUser.AUTO_JUDGE_OFFSET = !_gvars.activeUser.AUTO_JUDGE_OFFSET;
                optionJudgeOffset.selectable = _gvars.activeUser.AUTO_JUDGE_OFFSET;
                optionJudgeOffset.alpha = _gvars.activeUser.AUTO_JUDGE_OFFSET ? 0.55 : 1.0;
            }

            // Judge Color Reset
            else if (e.target.hasOwnProperty("judge_color_reset_id"))
            {
                _gvars.activeUser.judgeColours[e.target.judge_color_reset_id] = DEFAULT_OPTIONS.judgeColours[e.target.judge_color_reset_id];
                renderOptions();
            }

            // Combo Color Reset
            else if (e.target.hasOwnProperty("combo_color_reset_id"))
            {
                _gvars.activeUser.comboColours[e.target.combo_color_reset_id] = DEFAULT_OPTIONS.comboColours[e.target.combo_color_reset_id];
                renderOptions();
            }

            // Combo Color Enable/Disable
            else if (e.target.hasOwnProperty("combo_color_enable_id"))
            {
                _gvars.activeUser.enableComboColors[e.target.combo_color_enable_id] = !_gvars.activeUser.enableComboColors[e.target.combo_color_enable_id];
            }

            // Game Background Color Reset
            else if (e.target.hasOwnProperty("game_color_reset_id"))
            {
                var gid:int = e.target.game_color_reset_id;
                _gvars.activeUser.gameColours[gid] = DEFAULT_OPTIONS.gameColours[gid];
                if (gid == 0)
                    _gvars.activeUser.gameColours[2] = ColorUtil.darkenColor(DEFAULT_OPTIONS.gameColours[gid], 0.27);
                if (gid == 1)
                    _gvars.activeUser.gameColours[3] = ColorUtil.brightenColor(DEFAULT_OPTIONS.gameColours[gid], 0.08);
                renderOptions();
            }

            //- Reset
            else if (e.target == resetOptions)
            {
                var confirmP:Window = new Window(box, 0, 0, "Confirm Settings Reset");
                confirmP.hasMinimizeButton = false;
                confirmP.hasCloseButton = false;
                confirmP.setSize(110, 105);
                confirmP.x = (box.width / 2 - confirmP.width / 2);
                confirmP.y = (box.height / 2 - confirmP.height / 2);
                box.addChild(confirmP);

                function doReset(e:Event):void
                {
                    box.removeChild(confirmP);
                    if (_gvars.activeUser == _gvars.playerUser)
                    {
                        _gvars.activeUser.settings = new User().settings;
                        _avars.resetSettings();
                    }
                    renderOptions();
                }

                function closeReset(e:Event):void
                {
                    box.removeChild(confirmP);
                }

                var resB:BoxButton = new BoxButton(confirmP, 5, 5, 100, 35, "RESET", 12, doReset);
                resB.color = 0x330000;
                resB.textColor = "#990000";

                var conB:BoxButton = new BoxButton(confirmP, 5, 45, 100, 35, "Close", 12, closeReset);
                conB.color = 0;
                conB.textColor = "#000000";
            }
            //- Editor
            else if (e.target.hasOwnProperty("editor_multiplayer"))
            {
                _gvars.options = new GameOptions();
                _gvars.options.isEditor = true;
                _gvars.options.song = new Song({level: 1337, type: "EDITOR", name: "Editor"});
                _gvars.options.fill();
                removePopup();
                _gvars.gameMain.switchTo(Main.GAME_PLAY_PANEL);
                return;
            }

            //- Close
            else if (e.target == closeOptions)
            {
                if (_gvars.activeUser == _gvars.playerUser)
                {
                    _gvars.activeUser.saveLocal();
                }
                SoundMixer.soundTransform = new SoundTransform(SoundUtils.getVolume(_gvars.activeUser.gameVolume));
                LocalStore.setVariable("menuMusicSoundVolume", _gvars.menuMusicSoundVolume);
                removePopup();
                return;
            }

            //- Vsync Toggle
            else if (e.target == useVSyncCheckbox)
            {
                CONFIG::vsync
                {
                    _gvars.air_useVSync = !_gvars.air_useVSync;
                    LocalStore.setVariable("air_useVSync", _gvars.air_useVSync);
                    stage.vsyncEnabled = _gvars.air_useVSync;
                    _gvars.gameMain.addAlert("Set VSYNC: " + stage.vsyncEnabled, 120, Alert.RED);
                }
            }

            // Use HTTP Websockets
            else if (e.target == useWebsocketCheckbox)
            {
                if (_gvars.air_useWebsockets)
                {
                    _gvars.destroyWebsocketServer();
                    _gvars.air_useWebsockets = false;
                    LocalStore.setVariable("air_useWebsockets", _gvars.air_useWebsockets);
                }
                else
                {
                    if (_gvars.initWebsocketServer())
                    {
                        _gvars.air_useWebsockets = true;
                        LocalStore.setVariable("air_useWebsockets", _gvars.air_useWebsockets);
                        e_websocketMouseOver();
                    }
                    else
                    {
                        _gvars.gameMain.addAlert(_lang.string("air_options_unable_to_start_websockets"), 120, Alert.RED);
                    }
                }
            }

            // HTTP Websockets Instructions
            else if (e.target == openWebsocketOverlay)
            {
                navigateToURL(new URLRequest(Constant.WEBSOCKET_OVERLAY_URL), "_blank");
                return;
            }

            // Set Settings
            setSettings();

            // Set focus back
            stage.focus = this.stage;
        }

        private function gameNoteColorSelect(e:Event):void
        {
            var data:Object = e.target.selectedItem.data;
            for (var i:int = 0; i < optionNoteColors.length; i++)
            {
                if (optionNoteColors[i] == e.target)
                {
                    _gvars.activeUser.noteColours[i] = data;
                }
            }
        }

        private function e_importNoteskin(noteskinJSON:String):void
        {
            try
            {
                var json:Object = JSON.parse(noteskinJSON);
                if (json["rects"] != null && json["data"] != null)
                {
                    ObjectUtil.merge(noteskin_struct, json["rects"]);

                    var imageDecoder:Base64Decoder = new Base64Decoder();
                    imageDecoder.decode(json["data"]);
                    fileData = imageDecoder.toByteArray();
                }
                LocalStore.setVariable("custom_noteskin", noteskinsString(), 20971520); // 20MB Mins size requested.
                Noteskins.instance.loadCustomNoteskin();
                GlobalVariables.instance.gameMain.addAlert(_lang.string("popup_noteskin_saved"), 90, Alert.GREEN);
            }
            catch (e:Error)
            {
            }
        }

        private function noteskinsString():String
        {
            if (fileData == null)
            {
                try
                {
                    var json:Object = JSON.parse(LocalStore.getVariable("custom_noteskin", null));
                    var imgDecode:Base64Decoder = new Base64Decoder();
                    imgDecode.decode(json["data"]);
                    fileData = imgDecode.toByteArray();

                    ObjectUtil.merge(noteskin_struct, json["rects"]);
                }
                catch (e:Error)
                {
                }
            }

            if (fileData == null)
                return null;

            // Base64 Encode Image
            var imgEncode:Base64Encoder = new Base64Encoder();
            imgEncode.encodeBytes(fileData);

            var export_json:Object = {"name": GlobalVariables.instance.activeUser.name + " - Custom Export",
                    "data": imgEncode.toString(),
                    "rects": ObjectUtil.differences(NoteskinsStruct.getDefaultStruct(), noteskin_struct)}

            return JSON.stringify(export_json);
        }

        public function setSettings():void
        {
            var i:int;
            var item:*;

            if (box == null)
            {
                return;
            }

            if (CURRENT_TAB == TAB_MAIN)
            {
                // Set Speed
                optionGameSpeed.text = _gvars.activeUser.gameSpeed.toString();

                // Set Scroll
                for each (item in optionScrollDirections)
                {
                    item.checked = (_gvars.activeUser.slideDirection == item.slideDirection);
                }

                // Set Offset
                optionOffset.text = _gvars.activeUser.GLOBAL_OFFSET.toString();

                // Set Judge Offset
                optionJudgeOffset.text = _gvars.activeUser.JUDGE_OFFSET.toString();

                // Set Auto Judge Offset
                autoJudgeOffsetCheck.checked = _gvars.activeUser.AUTO_JUDGE_OFFSET;
                optionJudgeOffset.selectable = !_gvars.activeUser.AUTO_JUDGE_OFFSET;
                optionJudgeOffset.alpha = _gvars.activeUser.AUTO_JUDGE_OFFSET ? 0.55 : 1.0;

                // Set Receptor Spacing
                optionReceptorSpacing.text = _gvars.activeUser.receptorGap.toString();

                // Set Receptor Split Spacing
                optionReceptorSplitSpacing.text = _gvars.activeUser.receptorSplitGap.toString();

                // Set Note Scale
                optionNoteScale.slideValue = _gvars.activeUser.noteScale;

                // Set Volume
                optionGameVolume.slideValue = _gvars.activeUser.gameVolume;

                // Set Menu Volume
                optionMenuVolume.slideValue = _gvars.menuMusicSoundVolume;

                // Set Framerate
                optionFPS.text = _gvars.activeUser.frameRate.toString();

                // Set Song Rate
                optionRate.text = _gvars.activeUser.songRate.toString();

                // Set Autofails
                for each (item in optionAutofail)
                {
                    item.text = _gvars.activeUser["autofail" + StringUtil.upperCase(item.autofail)];
                }

                useWebsocketCheckbox.checked = _gvars.air_useWebsockets;

                CONFIG::vsync
                {
                    useVSyncCheckbox.checked = _gvars.air_useVSync;
                }
            }
            else if (CURRENT_TAB == TAB_VISUAL_MODS)
            {
                // Set Game Mods
                for each (item in optionGameMods)
                {
                    item.checked = (_gvars.activeUser.activeMods.indexOf(item.mod) != -1);
                }

                // Set Visual Game Mods
                for each (item in optionVisualGameMods)
                {
                    item.checked = (_gvars.activeUser.activeVisualMods.indexOf(item.visual_mod) != -1);
                }

                // Set Enable Toggles
                for each (item in optionEnableToggles)
                {
                    item.checked = (_gvars.activeUser["enable" + item.enable_toggle]);
                }

                optionJudgeSpeed.slideValue = _gvars.activeUser.judgeSpeed;
                optionReceptorAnimationSpeed.slideValue = _gvars.activeUser.receptorAnimationSpeed;

                // Set Noteskin
                for each (item in optionNoteskins)
                {
                    item.checked = (item.skin == _gvars.activeUser.activeNoteskin);
                }
                if (optionNoteskinPreview != null)
                {
                    if (box.contains(optionNoteskinPreview))
                        box.removeChild(optionNoteskinPreview);
                    optionNoteskinPreview.dispose();
                    optionNoteskinPreview = null;
                }
                optionNoteskinPreview = new GameNote(0, "U", "blue", 0, 0, _gvars.activeUser.activeNoteskin);
                optionNoteskinPreview.x = 690;
                optionNoteskinPreview.y = 90;
                optionNoteskinPreview.rotation = (_noteskins.getInfo(_gvars.activeUser.activeNoteskin).rotation * 2);
                optionNoteskinPreview.scaleX = optionNoteskinPreview.scaleY = Math.min(1, (64 / Math.max(optionNoteskinPreview.width, optionNoteskinPreview.height)));
                box.addChild(optionNoteskinPreview);

                // Set Display
                for each (item in optionDisplays)
                {
                    item.checked = (_gvars.activeUser["DISPLAY_" + item.display]);
                }
            }
            else if (CURRENT_TAB == TAB_COLORS)
            {
                // Set Judge Colors
                for (i = 0; i < judgeTitles.length; i++)
                {
                    optionJudgeColors[i]["text"].text = "#" + StringUtil.pad(_gvars.activeUser.judgeColours[i].toString(16).substr(0, 6), 6, "0", StringUtil.STR_PAD_LEFT);
                    optionJudgeColors[i]["display"].color = _gvars.activeUser.judgeColours[i];
                }
                // Set Combo Colors
                for (i = 0; i < DEFAULT_OPTIONS.comboColours.length; i++)
                {
                    optionComboColors[i]["text"].text = "#" + StringUtil.pad(_gvars.activeUser.comboColours[i].toString(16).substr(0, 6), 6, "0", StringUtil.STR_PAD_LEFT);
                    optionComboColors[i]["display"].color = _gvars.activeUser.comboColours[i];
                    if (i > 0)
                    {
                        optionComboColors[i]["enable"].checked = (_gvars.activeUser.enableComboColors[i]);
                    }
                }

                // Set Raw Good Tracker
                optionRawGoodTracker.text = _gvars.activeUser.rawGoodTracker.toString();

                for (i = 0; i < DEFAULT_OPTIONS.noteColors.length; i++)
                {
                    (optionNoteColors[i] as ComboBox).selectedItemByData = _gvars.activeUser.noteColours[i];
                }
            }
            else if (CURRENT_TAB == TAB_OTHER)
            {
                // Set Global Keys
                for each (item in optionGlobalKeyInputs)
                {
                    item.text = StringUtil.keyCodeChar(_gvars.activeUser["key" + StringUtil.upperCase(item.key)]).toUpperCase();
                }

                // Set Global Keys
                for each (item in optionColumnKeyInputs)
                {
                    var code:int = _gvars.activeUser.keyBuilder[item.column_index_set][item.column_set][item.column_index];
                    if (code == 0)
                        item.text = '';
                    else
                        item.text = StringUtil.keyCodeChar(code).toUpperCase();
                }
            }

            // Save Local
            if (_gvars.activeUser == _gvars.playerUser)
            {
                _gvars.activeUser.saveLocal();
            }
        }
    }
}
