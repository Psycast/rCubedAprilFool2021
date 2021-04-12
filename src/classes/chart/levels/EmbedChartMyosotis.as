package classes.chart.levels
{
    import af.assets.chartaudio.zMyosotis;
    import classes.chart.parse.ChartStepmania;
    import flash.utils.ByteArray;

    public class EmbedChartMyosotis extends EmbedChartBase
    {
        [Embed(source = "zMyosotis.sm", mimeType = 'application/octet-stream')]
        private static const EMBED_CHART:Class;

        private const info:Object = {"name": "Myosotis [Deemo (2015)]",
                "display": "<font color=\"#61b2f4\">MYO</font><font color=\"#E9BA24\">SO</font><font color=\"#61b2f4\">TIS</font>",
                "difficulty": 75,
                "author": "M2U & NICODE feat. Guriri/Lucy",
                "stepauthor": "CosmoVibe",
                "description": "",
                "point": {"x": 1173, "y": 345},
                "minimap": 0x1565B6};

        public function EmbedChartMyosotis()
        {
            this.DEFAULT_CHART_ID = 3;

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
            return new zMyosotis();
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
