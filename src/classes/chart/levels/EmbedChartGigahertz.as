package classes.chart.levels
{
    import af.assets.chartaudio.zGIGAHERTZ;
    import classes.chart.parse.ChartStepmania;
    import flash.utils.ByteArray;

    public class EmbedChartGigahertz extends EmbedChartBase
    {
        [Embed(source = "zGIGAHERTZ.sm", mimeType = 'application/octet-stream')]
        private static const EMBED_CHART:Class;

        private const info:Object = {"name": "GIGAHERTZ",
                "display": "<font color=\"#00e9ff\">ELEC</font><font color=\"#fff600\">T</font><font color=\"#00e9ff\">RIC</font>",
                "difficulty": 120,
                "author": "Snack_X",
                "stepauthor": "gold stinger",
                "description": "This got framed hard, but not here.",
                "point": {"x": 1474, "y": 1116},
                "minimap": 0x655682};

        public function EmbedChartGigahertz()
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
            return new zGIGAHERTZ();
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
