package classes.chart.levels
{
    import af.assets.chartaudio.zPopCulture;
    import classes.chart.parse.ChartStepmania;
    import flash.utils.ByteArray;

    public class EmbedChartPopCulture extends EmbedChartBase
    {
        [Embed(source = "zPopCulture.sm", mimeType = 'application/octet-stream')]
        private static const EMBED_CHART:Class;

        private const info:Object = {"name": "Pop Culture",
                "display": "<font color=\"#c9c9b1\">T</font><font color=\"#edd628\">A</font><font color=\"#c9c9b1\">P</font> <font color=\"#edd628\">T</font><font color=\"#c9c9b1\">A</font><font color=\"#edd628\">P</font> <font color=\"#c9c9b1\">R</font><font color=\"#edd628\">E</font><font color=\"#c9c9b1\">V</font><font color=\"#edd628\">O</font><font color=\"#c9c9b1\">L</font><font color=\"#edd628\">U</font><font color=\"#c9c9b1\">T</font><font color=\"#edd628\">I</font><font color=\"#c9c9b1\">O</font><font color=\"#edd628\">N</font>",
                "difficulty": 40,
                "author": "Madeon",
                "stepauthor": "CosmoVibe",
                "description": "",
                "point": {"x": 1019, "y": 134},
                "minimap": 0x1565B6};

        public function EmbedChartPopCulture()
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
            return new zPopCulture();
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
