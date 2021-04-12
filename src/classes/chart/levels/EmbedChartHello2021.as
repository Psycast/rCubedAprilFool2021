package classes.chart.levels
{
    import af.assets.chartaudio.zHello2021;
    import classes.chart.parse.ChartStepmania;
    import flash.utils.ByteArray;

    public class EmbedChartHello2021 extends EmbedChartBase
    {
        [Embed(source = "zHello2021.sm", mimeType = 'application/octet-stream')]
        private static const EMBED_CHART:Class;

        private const info:Object = {"name": "Hello (BPM) 2021",
                "display": "<font color=\"#FF0000\">さ</font><font color=\"#FF7F00\">よ</font><font color=\"#FFFF00\">う</font><font color=\"#7FFF00\">な</font><font color=\"#00FF00\">ら</font> <font color=\"#00FEFF\">[ </font><font color=\"#007FFF\">2 </font><font color=\"#0000FF\">0 </font><font color=\"#7F00FF\">2 </font><font color=\"#FF00FE\">0 </font><font color=\"#FF007F\">]</font>",
                "difficulty": 180,
                "author": "Camellia",
                "stepauthor": "gold stinger",
                "description": "nothing to be said",
                "point": {"x": 1738, "y": 1215},
                "minimap": 0x655682};

        public function EmbedChartHello2021()
        {
            this.DEFAULT_CHART_ID = 0;

            parser = new ChartStepmania();
            parser.ignoreValidation = true;
            parser.load(getChartData());

            info['arrows'] = parser.data.notes[DEFAULT_CHART_ID].arrows;
            info['holds'] = parser.data.notes[DEFAULT_CHART_ID].holds;
            info['mines'] = parser.data.notes[DEFAULT_CHART_ID].mines;
            info['time'] = getChartTime(DEFAULT_CHART_ID);
        }

        override public function parseData():void
        {
            if (!parser.parsed)
                parser.parse();
        }

        override public function getInfo():Object
        {
            return info;
        }

        override public function getAudioData():*
        {
            return new zHello2021();
        }

        override public function getChartData():ByteArray
        {
            return new EMBED_CHART() as ByteArray;
        }

        override public function getAllCharts():Array
        {
            return parser.data['notes'];
        }

        override public function getNoteData(chart_index:Object = null):Array
        {
            return getValidChartData(chart_index)['notes'];
        }

        override public function getHoldData(chart_index:Object = null):Array
        {
            return getValidChartData(chart_index)['holds'];
        }

        override public function getMineData(chart_index:Object = null):Array
        {
            return getValidChartData(chart_index)['mines'];
        }

        override public function getColumnCount(chart_index:Object = null):int
        {
            return getValidChartData(chart_index)['columns'];
        }
    }
}
