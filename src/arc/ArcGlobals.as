package arc
{
    import classes.Playlist;
    import flash.events.EventDispatcher;

    public class ArcGlobals extends EventDispatcher
    {
        private static var _instance:ArcGlobals = null;

        public static function get instance():ArcGlobals
        {
            if (_instance == null)
            {
                _instance = new ArcGlobals(new SingletonEnforcer());
            }
            return _instance;
        }

        public function ArcGlobals(en:SingletonEnforcer)
        {
            if (en == null)
            {
                throw Error("Multi-Instance Blocked");
            }

            load();
        }

        public var configInterface:Object = {};

        public function interfaceLoad():void
        {
            configInterface = LocalStore.getVariable("arcLayout", {});
        }

        public function interfaceSave():void
        {
            LocalStore.setVariable("arcLayout", configInterface);
            LocalStore.flush();
        }

        public var configMusicOffset:int = 0;

        public function musicOffsetLoad():void
        {
            configMusicOffset = LocalStore.getVariable("arcMusicOffset", 0);
        }

        public function musicOffsetSave():void
        {
            LocalStore.setVariable("arcMusicOffset", configMusicOffset);
            LocalStore.flush();
        }

        public function load():void
        {
            musicOffsetLoad();
            interfaceLoad();
        }

        public function resetSettings():void
        {
            LocalStore.deleteVariable("arcMusicOffset");
            LocalStore.deleteVariable("arcLayout");

            LocalStore.flush();

            load();
        }
    }
}

class SingletonEnforcer
{
}
