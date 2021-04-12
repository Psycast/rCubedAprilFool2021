package
{
    import classes.Language;
    import flash.geom.Matrix;
    import flash.net.URLVariables;
    import flash.text.StyleSheet;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    public class Constant
    {
        // Engine Brand Name
        public static const BRAND_NAME_LONG:String = R3::BRAND_NAME_LONG;
        public static const BRAND_NAME_SHORT:String = R3::BRAND_NAME_SHORT;
        public static var BRAND_NAME_LONG_UPPER:String = BRAND_NAME_LONG.toLocaleUpperCase();
        public static var BRAND_NAME_LONG_LOWER:String = BRAND_NAME_LONG.toLocaleLowerCase();
        public static var BRAND_NAME_SHORT_UPPER:String = BRAND_NAME_SHORT.toLocaleUpperCase();
        public static var BRAND_NAME_SHORT_LOWER:String = BRAND_NAME_SHORT.toLocaleLowerCase();

        public static const AIR_VERSION:String = R3::VERSION;
        public static const AIR_WINDOW_TITLE:String = "FFR (World Tour (and Space)) [2021]";
        public static const LOCAL_SO_NAME:String = "april-2021-save-data-storage";
        public static const MAIN_LOCAL_SO_NAME:String = "90579262-509d-4370-9c2e-564667e511d7";
        public static const ENGINE_VERSION:int = 3;

        public static const ROOT_URL:String = "https://" + R3::ROOT_URL + "/";

        // User URLs
        public static const USER_REGISTER_URL:String = ROOT_URL + "vbz/register.php";
        public static const USER_LOGIN_URL:String = ROOT_URL + "game/r3/r3-siteLogin.php";
        public static const USER_INFO_URL:String = ROOT_URL + "game/r3/r3-userInfo.php";
        public static const USER_INFO_LITE_URL:String = ROOT_URL + "game/r3/r3-userSmallInfo.php";
        public static const USER_AVATAR_URL:String = ROOT_URL + "avatar_imgembedded.php";

        // Embed Fonts
        BreeSerif;
        Ultra;
        BebasNeue;
        Xolonium.Bold;
        Xolonium.Regular;
        HussarBold.Italic;
        HussarBold.Regular;
        NotoSans.CJKBold;
        NotoSans.Bold;

        public static const TEXT_FORMAT:TextFormat = new TextFormat(Language.FONT_NAME, 14, 0xFFFFFF, true);
        public static const TEXT_FORMAT_12:TextFormat = new TextFormat(Language.FONT_NAME, 12, 0xFFFFFF, true);
        public static const TEXT_FORMAT_CENTER:TextFormat = new TextFormat(Language.FONT_NAME, 14, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.CENTER);
        public static const TEXT_FORMAT_UNICODE:TextFormat = new TextFormat(Language.UNI_FONT_NAME, 14, 0xFFFFFF, true);

        // Other
        public static const NOTESKIN_EDITOR_URL:String = ROOT_URL + "~velocity/ffrjs/noteskin";
        public static const WEBSOCKET_OVERLAY_URL:String = "https://github.com/flashflashrevolution/web-stream-overlay";
        public static const LEGACY_GENRE:int = 13;
        public static const JUDGE_WINDOW:Array = [{t: -118, s: 5, f: -3},
            {t: -85, s: 25, f: -2},
            {t: -51, s: 50, f: -1},
            {t: -18, s: 100, f: 0},
            {t: 17, s: 50, f: 1},
            {t: 50, s: 25, f: 2},
            {t: 84, s: 25, f: 3},
            {t: 117, s: 0}];
        public static const HOLD_JUDGE_WINDOW:Array = [{t: -275, s: 15, f: -3},
            {t: 180, s: 0}];

        // Static Initializer
        public static var GRADIENT_MATRIX:Matrix;
        public static var STYLESHEET:StyleSheet;
        {
            GRADIENT_MATRIX = new Matrix();
            GRADIENT_MATRIX.createGradientBox(100, 100, (Math.PI / 180) * 225);

            STYLESHEET = new StyleSheet();
            STYLESHEET.setStyle("A", {textDecoration: "underline", fontWeight: "bold"});
        }

        // Functions
        /**
         * Cleans the scroll direction from older engine names to the current names.
         * Only used on loaded replays to understand older scroll direction values.
         * @param dir
         * @return
         */
        public static function cleanScrollDirection(dir:String):String
        {
            dir = dir.toLowerCase();

            switch (dir)
            {
                case "slideright":
                    return "right"; // Legacy/Velocity
                case "slideleft":
                    return "left"; // Legacy/Velocity
                case "rising":
                    return "up"; // Legacy/Velocity
                case "falling":
                    return "down"; // Legacy/Velocity
                case "diagonalley":
                    return "diagonalley"; // Legacy/Velocity
            }
            return dir;
        }

        /**
         * Adds default URLVariables to the passed requestVars.
         * @param requestVars
         */
        public static function addDefaultRequestVariables(requestVars:URLVariables):void
        {
            requestVars['ver'] = Constant.ENGINE_VERSION;
            requestVars['is_air'] = true;
            requestVars['air_ver'] = Constant.AIR_VERSION;
        }
    }
}
