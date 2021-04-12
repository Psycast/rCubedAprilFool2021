package classes.chart.levels
{
    import af.assets.chartaudio.zMegalovania;
    import classes.chart.parse.ChartStepmania;
    import flash.utils.ByteArray;

    public class EmbedChartMegalovania extends EmbedChartBase
    {
        [Embed(source = "zMegalovania.sm", mimeType = 'application/octet-stream')]
        private static const EMBED_CHART:Class;

        private const info:Object = {"name": "Megalovania",
                "display": "<font color=\"#000000\">|</font>BAT<font color=\"#fc6ab8\">&lt;3</font>TLE<font color=\"#000000\">|</font>",
                "difficulty": 1,
                "author": "Toby Fox",
                "stepauthor": "DarkZtar",
                "description": "It's Battle Time!",
                "levelscript": "SansBattle",
                "point": {"x": 975, "y": 1219},
                "minimap": 0x84E14B};

        public function EmbedChartMegalovania()
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
            return new zMegalovania();
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
