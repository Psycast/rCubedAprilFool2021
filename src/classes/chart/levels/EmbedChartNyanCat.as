package classes.chart.levels
{
    import af.assets.chartaudio.zNyanCat;
    import classes.chart.parse.ChartStepmania;
    import flash.utils.ByteArray;

    public class EmbedChartNyanCat extends EmbedChartBase
    {
        [Embed(source = "zNyanCat.sm", mimeType = 'application/octet-stream')]
        private static const EMBED_CHART:Class;

        private const info:Object = {"name": "Nyan Cat",
                "display": "<font color=\"#afafaf\">CAT</font><font color=\"#ffa0d9\">GOES</font><font color=\"#afafaf\">MEOW</font>",
                "difficulty": 37,
                "author": "PRGuitarman",
                "stepauthor": "gold stinger",
                "description": "endless cat",
                "levelscript": "NyanCat",
                "point": {"x": 900, "y": 1020},
                "minimap": 0x84E14B};

        public function EmbedChartNyanCat()
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
            return new zNyanCat();
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
