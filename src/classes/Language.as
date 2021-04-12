/**
 * @author Jonathan (Velocity)
 */

package classes
{
    import classes.ui.Text;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;

    public class Language extends EventDispatcher
    {
        [Embed(source = "language.xml", mimeType = 'application/octet-stream')]
        private static const EMBED_DATA:Class;

        public static const FONT_NAME:String = new NotoSans.Bold().fontName;
        public static const UNI_FONT_NAME:String = new NotoSans.CJKBold().fontName;

        ///- Singleton Instance
        private static var _instance:Language = null;

        ///- Private Locals
        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _isLoaded:Boolean = false;
        private var _loadError:Boolean = false;

        public var data:Object;
        public var indexed:Array;

        ///- Constructor
        public function Language(en:SingletonEnforcer)
        {
            if (en == null)
                throw Error("Multi-Instance Blocked");
        }

        public static function get instance():Language
        {
            if (_instance == null)
                _instance = new Language(new SingletonEnforcer());
            return _instance;
        }

        public function isLoaded():Boolean
        {
            return _isLoaded && !_loadError;
        }

        public function isError():Boolean
        {
            return _loadError;
        }

        ///- Public Functions
        public function font(testStr:String = ""):String
        {
            return Text.isUnicode(testStr) ? UNI_FONT_NAME : FONT_NAME;
        }

        public function wrapFont(text:String):String
        {
            return "<font face=\"" + font(text) + "\">" + text + "</font>";
        }

        public function string(id:String, defaultValue:String = null):String
        {
            var lang_str:String = string2(id, _gvars.playerUser ? _gvars.playerUser.language : "us");
            if (defaultValue != null && lang_str.indexOf(id) != -1)
                lang_str = lang_str.replace(id, defaultValue);
            return lang_str;
        }

        public function string2(id:String, lang:String):String
        {
            // Get Text
            var text:String = id;
            if (!data)
            {

            }
            else if (data[lang] && data[lang][id])
            {
                text = data[lang][id];
            }
            else if (data["us"][id] != null)
            {
                text = data["us"][id];
            }
            if (data && text == id)
                trace(id);
            return wrapFont(text);
        }

        public function stringSimple(id:String, defaultValue:String = null):String
        {
            var lang_str:String = string2Simple(id, _gvars.playerUser ? _gvars.playerUser.language : "us");
            if (defaultValue != null && lang_str == id)
                lang_str = defaultValue;
            return lang_str;
        }

        public function string2Simple(id:String, lang:String):String
        {
            // Get Text
            var text:String = id;
            if (!data)
            {

            }
            else if (data[lang] && data[lang][id])
            {
                text = data[lang][id];
            }
            else if (data["us"][id] != null)
            {
                text = data["us"][id];
            }
            if (data && text == id)
                trace(id);
            return text;
        }

        ///- Language Loading
        public function load():void
        {
            _isLoaded = false;
            _loadError = false;

            try
            {
                var xmlMain:XML = new XML((new EMBED_DATA() as ByteArray).toString());
                var xmlChildren:XMLList = xmlMain.children();
            }
            catch (e:Error)
            {
                _loadError = true;
                this.dispatchEvent(new Event(GlobalVariables.LOAD_ERROR));
                return;
            }

            data = new Object();
            indexed = new Array();

            for (var a:uint = 0; a < xmlChildren.length(); ++a)
            {
                // Check for Language Object, if not, create one.
                var lang:String = xmlChildren[a].attribute("id").toString();
                if (data[lang] == null)
                {
                    data[lang] = new Object();
                }

                // Add Attributes to Object
                var langAttr:XMLList = xmlChildren[a].attributes();
                for (var b:uint = 0; b < langAttr.length(); b++)
                {
                    data[lang]["_" + langAttr[b].name()] = langAttr[b].toString();
                }

                // Add Text to Object
                var langNodes:XMLList = xmlChildren[a].children();
                for (var c:uint = 0; c < langNodes.length(); c++)
                {
                    data[lang][langNodes[c].attribute("id").toString()] = langNodes[c].children()[0].toString().replace(/\r\n/gi, "\n");
                }
                indexed[data[lang]["_index"]] = lang;
            }

            // Extra
            data["us"]["options_receptor_split_spacing"] = "Hand Split Gap:";
            data["us"]["options_mod_flashlight"] = "Flashlight";
            data["us"]["options_mod_dizzy"] = "Dizzy";
            data["us"]["options_mod_bleed"] = "<font color=\"#ff1919\">Bleed</font>";
            data["us"]["options_mod_autoplay"] = "<font color=\"#ff1919\">Autoplay</font>";
            data["us"]["options_mod__spawn_noteskin_nyancat"] = "<font color=\"#afafaf\">Nya</font><font color=\"#ffe68e\">n</font><font color=\"#ffa0d9\">Cat</font><font color=\"#ffe68e\">F</font><font color=\"#afafaf\">orever</font>";
            data["us"]["game_holdOK"] = "Hold OK";
            data["us"]["game_holdNG"] = "Hold NG";
            data["us"]["options_menu_input"] = "Inputs";
            data["us"]["options_column_count_4"] = "4 Key / Single:";
            data["us"]["options_column_count_6"] = "6 Key / Solo:";
            data["us"]["options_column_count_8"] = "8 Key / Double:";
            data["us"]["options_input_gameplay"] = "Gameplay Inputs:";
            data["us"]["options_input_other"] = "Other Inputs:";
            data["us"]["options_receptor"] = "Show Receptors";
            data["us"]["options_receptor_animations"] = "Show Receptors Animations";
            data["us"]["options_receptor_speed"] = "Receptor Flash Speed:";
            data["us"]["options_scroll_autoplay"] = "Autoplay";
            data["us"]["options_mod_antimatter"] = "<font color=\"#19d800\">He</font><font color=\"#ff9d00\">Lied</font>";
            data["us"]["options_mod_apr_1_2020"] = "<font color=\"#a7bece\">Mr</font><font color=\"#4190e0\">Undertale</font><font color=\"#a7bece\">Himself</font>";
            data["us"]["options_other_gameplay_toggles"] = "Other Mods:";
            data["us"]["options_enable_boos"] = "Enable Boos";
            data["us"]["options_enable_holds"] = "Enable Holds";
            data["us"]["options_enable_mines"] = "Enable Mines";
            data["us"]["options_enable_failure"] = "Enable Fail Out";
            data["us"]["options_mod_no_boo"] = "No Boos";
            data["us"]["options_mod_no_hold"] = "No Holds";
            data["us"]["options_mod_no_mine"] = "No Mines";
            data["us"]["options_mod_no_fail"] = "No Fail";

            _isLoaded = true;
            _loadError = false;
        }
    }
}

class SingletonEnforcer
{
}
