package classes.chart.levels
{

    import flash.filesystem.File;

    public class ExternalChartCache
    {
        private var CACHE:Object = {};
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

            var data:String = AirContext.readTextFile(AirContext.getAppFile(cacheFileName));
            try
            {
                CACHE = JSON.parse(data);
                didLoad = true;
                isDirty = false;
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
