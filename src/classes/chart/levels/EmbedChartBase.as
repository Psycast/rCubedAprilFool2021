package classes.chart.levels
{
    import classes.chart.LevelScriptRuntime;
    import classes.chart.parse.ChartBase;
    import com.flashfla.utils.TimeUtil;
    import flash.media.Sound;
    import flash.utils.ByteArray;

    public class EmbedChartBase
    {
        public var ID:int;

        public var DEFAULT_CHART_ID:int = 0;

        public var parser:ChartBase;

        public function setID(val:int):void
        {
            this.ID = val;
        }

        public function getID():int
        {
            return ID;
        }

        public function getInfo():Object
        {
            return null;
        }

        public function getAllCharts():Array
        {
            return null;
        }

        public function getAudioData():*
        {
            return null;
        }

        public function getChartData():ByteArray
        {
            return null;
        }

        public function getValidChartData(chart_index:Object = null):Object
        {
            if (parser.charts[chart_index] != null)
                return parser.charts[chart_index];

            return parser.charts[DEFAULT_CHART_ID];
        }

        public function getNoteData(chart_index:Object = null):Array
        {
            return null;
        }

        public function getHoldData(chart_index:Object = null):Array
        {
            return null;
        }

        public function getMineData(chart_index:Object = null):Array
        {
            return null;
        }

        public function getColumnCount(chart_index:Object = null):int
        {
            return 4;
        }

        public function getScriptData():LevelScriptRuntime
        {
            return null;
        }

        public function parseData():void
        {
            return;
        }

        public function getChartTime(chart_index:Object = null):String
        {
            if (!this.parser.parsed)
                return getChartTimeFormat(this.parser.getChartTimeFast(chart_index));

            // We have parsed data, use note timings.
            var nd:Array = getNoteData(chart_index);
            var hd:Array = getHoldData(chart_index);
            var md:Array = getMineData(chart_index);

            if (nd.length <= 0)
                return "0:00";

            var maxTime:Number = nd[nd.length - 1][0];

            if (hd.length > 0)
                for (var i:int = hd.length - 1; i >= 0; i--)
                    maxTime = Math.max(maxTime, hd[i][0] + hd[i][3]);

            if (md.length > 0)
                maxTime = Math.max(maxTime, md[md.length - 1][0]);

            return getChartTimeFormat(maxTime);
        }

        public function getChartTimeFormat(maxTime:Number):String
        {
            if (isNaN(maxTime) || maxTime < 0)
                return "0:00";

            var s:Number = maxTime % 60;
            var m:Number = Math.floor((maxTime % 3600) / 60);
            var h:Number = Math.floor(maxTime / (60 * 60));

            var hourStr:String = (h == 0) ? "" : (h) + ":";
            var minuteStr:String = (h == 0) ? (m + ":") : (TimeUtil.doubleDigitFormat(m) + ":");
            var secondsStr:String = TimeUtil.doubleDigitFormat(s);

            return hourStr + minuteStr + secondsStr;
        }
    }
}
