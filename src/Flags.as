package
{

    public class Flags
    {
        public static var SEEN_TITLE:Boolean = true;
        public static var ANTIMATTER:Boolean = false;
        public static var KEYBOARD_BREAKER:Boolean = false;

        public static var ENABLE_BROWSER:Boolean = true;
        public static var SEEN_SOLO_CUTSCENE:Boolean = false;
        public static var SETUP_KEYS:Boolean = false;
        public static var CUTSCENE_BITS:int = 0;

        public static var PLAY_EXTERNAL_FILE:Boolean = false;

        public static function canPlayLevel1():Boolean
        {
            for (var i:int = 2; i <= 16; i++)
            {
                if ((CUTSCENE_BITS & (1 << i)) == 0)
                    return false;
            }
            return true;
        }

        public static function resetEvent():void
        {
            CUTSCENE_BITS = 0;
            SEEN_SOLO_CUTSCENE = false;
            SETUP_KEYS = false;
            //SEEN_TITLE = false;

            LocalStore.deleteVariable("af2021_cutscene_bits");
            LocalStore.deleteVariable("af2021_seen_solo_cutscene");
            LocalStore.deleteVariable("af2021_setup_keys");
            LocalStore.deleteVariable("af2021_title_splash");
        }

        public static function finishEvent():void
        {
            CUTSCENE_BITS = 0xFFFFFFFF;
            SEEN_SOLO_CUTSCENE = true;
            SETUP_KEYS = true;
            SEEN_TITLE = true;

            LocalStore.setVariable("af2021_cutscene_bits", CUTSCENE_BITS);
            LocalStore.setVariable("af2021_seen_solo_cutscene", SEEN_SOLO_CUTSCENE);
            LocalStore.setVariable("af2021_setup_keys", SETUP_KEYS);
            LocalStore.setVariable("af2021_title_splash", SEEN_TITLE);
        }

        public static function resetSecrets():void
        {
            //ENABLE_BROWSER = false;
            ANTIMATTER = false;
            KEYBOARD_BREAKER = false;
        }

        public static function doLoad():void
        {
            if (AirContext.doesFileExist(AirContext.getAppPath("looking.txt")))
            {
                trace("Enabling File Browser");
                ENABLE_BROWSER = true;
            }
            if (AirContext.doesFileExist(AirContext.getAppPath("darkness.txt")))
            {
                trace("Enabling AntiMatter");
                ANTIMATTER = true;
            }
            if (AirContext.doesFileExist(AirContext.getAppPath("painful.txt")))
            {
                trace("Enabling 8k Hello 2021");
                KEYBOARD_BREAKER = true;
            }
            CUTSCENE_BITS = LocalStore.getVariable("af2021_cutscene_bits", 0);
            SEEN_SOLO_CUTSCENE = LocalStore.getVariable("af2021_seen_solo_cutscene", false);
            SETUP_KEYS = LocalStore.getVariable("af2021_setup_keys", false);
            SEEN_TITLE = LocalStore.getVariable("af2021_title_splash", false);

            if (!SEEN_TITLE)
            {
                CUTSCENE_BITS = 0;
                SEEN_SOLO_CUTSCENE = false;
                SETUP_KEYS = false;
            }
        }
    }
}
