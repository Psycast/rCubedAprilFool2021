/**
 * @author Jonathan (Velocity)
 */

package menu
{
    import classes.Language;
    import classes.ui.Text;
    import com.flashfla.utils.SystemUtil;
    import flash.display.Sprite;

    public class MainMenu extends MenuPanel
    {
        public static const MENU_SONGSELECTION:String = "MenuSongSelection";
        public static const MENU_OPTIONS:String = "MenuOptions";

        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _lang:Language = Language.instance;

        public var _MenuSingleplayer:MenuPanel;

        private var user_text:Text;
        private var menuItemBox:Sprite;

        public var panel:MenuPanel;

        ///- Constructor
        public function MainMenu(myParent:MenuPanel)
        {
            super(myParent);
        }

        override public function init():Boolean
        {
            //- Add Menu Music to Stage
            if (_gvars.menuMusic)
            {
                if (!_gvars.menuMusic.isPlaying)
                {
                    _gvars.menuMusic.start();
                }
            }

            _gvars.gameMain.bg.visible = false;
            _gvars.gameMain.ver.visible = false;

            switchTo(MENU_SONGSELECTION);
            return false;
        }

        override public function dispose():void
        {
            if (_MenuSingleplayer)
            {
                _MenuSingleplayer.stageRemove();
                _MenuSingleplayer.dispose();
                if (this.contains(_MenuSingleplayer))
                    this.removeChild(_MenuSingleplayer);
                _MenuSingleplayer = null;
            }
            super.stageRemove();
        }

        override public function draw():void
        {
            panel.draw();
        }

        override public function switchTo(_panel:String, useNew:Boolean = false):Boolean
        {
            //- Check Parent Function first.
            if (super.switchTo(_panel, useNew))
                return true;

            //- Do current panel.
            var isFound:Boolean = false;
            var initValid:Boolean = false;
            var doStageAddAnyway:Boolean = false;

            if (_panel == MENU_OPTIONS)
            {
                addPopup(Main.POPUP_OPTIONS);
                return true;
            }

            if (panel != null)
            {
                panel.stageRemove();
                this.removeChild(panel);
            }

            switch (_panel)
            {
                case MENU_SONGSELECTION:
                    if (_MenuSingleplayer == null || useNew)
                        _MenuSingleplayer = new MenuSongSelection(this);
                    panel = _MenuSingleplayer;
                    isFound = true;
                    break;
            }
            this.addChild(panel);

            if (panel.hasInit)
                doStageAddAnyway = true;

            if (!panel.hasInit)
            {
                initValid = panel.init();
                panel.hasInit = true;
            }

            if (initValid || doStageAddAnyway)
                panel.stageAdd();

            SystemUtil.gc();
            return isFound;
        }
    }
}
