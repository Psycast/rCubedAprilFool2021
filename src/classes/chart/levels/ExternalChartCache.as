package classes.chart.levels
{

    import flash.filesystem.File;

    public class ExternalChartCache
    {
        private static const CACHE_VERSION:int = 2;

        private var CACHE:Object = {"cache_version": CACHE_VERSION};
        private var cacheFileName:String = "chart_cache.json"; // "song_cache" + File.separator + 

        private var didLoad:Boolean = false;
        private var isDirty:Boolean = false;

        public function ExternalChartCache()
        {
            load();
        }

        public function load():void
        {
            if (didLoad)
                return;

            didLoad = true;

            var data:String = AirContext.readTextFile(AirContext.getAppFile(cacheFileName));
            try
            {
                var FILE_CACHE:Object = JSON.parse(data);

                // valid cache & version
                if ((FILE_CACHE["cache_version"] || 0) == CACHE_VERSION)
                    CACHE = FILE_CACHE;

                trace("loaded cache");
            }
            catch (e:Error)
            {

                trace("error on cache");
            }
        }

        public function save():void
        {
            if (isDirty)
            {
                AirContext.writeTextFile(new File(AirContext.getAppPath(cacheFileName)), JSON.stringify(CACHE));
                isDirty = false;
                trace("saving cache");
            }
            else
            {
                trace("no cache changes to save");
            }
        }

        public function getValue(path:String):Object
        {
            return CACHE[path] || null;
        }

        public function setValue(path:String, value:Object):void
        {
            CACHE[path] = value;
            isDirty = true;
        }
    }
}
