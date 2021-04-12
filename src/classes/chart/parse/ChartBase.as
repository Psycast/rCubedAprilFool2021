package classes.chart.parse
{

    import flash.utils.ByteArray;

    public class ChartBase
    {
        public var ignoreValidation:Boolean = false;

        public var validColumnCounts:Array = [4, 6, 8];

        public var COLUMNS:Object = {"4": ['L', 'D', 'U', 'R'],
                "6": ['L', 'Q', 'D', 'U', 'W', 'R'],
                "8": ['L', 'D', 'U', 'R', 'Q', 'W', 'T', 'Y']};

        public var data:Object = {"notes": []};
        public var charts:Array = [];

        public var loaded:Boolean = false;
        public var parsed:Boolean = false;

        public function parse():void
        {

        }

        public function load(fileData:ByteArray):Boolean
        {
            return false;
        }

        public function getChartTimeFast(chart_index:Object = null):Number
        {
            return 0;
        }
    }
}
