package classes.chart.levels
{
    import af.assets.chartaudio.zMarigold;
    import classes.chart.parse.ChartStepmania;
    import flash.utils.ByteArray;

    public class EmbedChartMarigold extends EmbedChartBase
    {
        [Embed(source = "zMarigold.sm", mimeType = 'application/octet-stream')]
        private static const EMBED_CHART:Class;

        private const info:Object = {"name": "Marigold [Deemo (2017)]",
                "display": "<font color=\"#F7DE08\">MAR</font><font color=\"#e5b300\">IG</font><font color=\"#F7DE08\">OLD</font>",
                "difficulty": 90,
                "author": "M2U feat. Guriri/グリリ",
                "stepauthor": "CosmoVibe",
                "description": "",
                "point": {"x": 1451, "y": 255},
                "minimap": 0x1565B6};

        public function EmbedChartMarigold()
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
            return new zMarigold();
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
