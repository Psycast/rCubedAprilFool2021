package classes.chart.levels
{
    import af.assets.chartaudio.zExtremeMegaMix;
    import classes.chart.parse.ChartStepmania;
    import flash.utils.ByteArray;

    public class EmbedChartExtremeMegaMix extends EmbedChartBase
    {
        [Embed(source = "zExtremeMegaMix.sm", mimeType = 'application/octet-stream')]
        private static const EMBED_CHART:Class;

        private const info:Object = {"name": "EXTREME SOUNDCLOWN MEGAMIX V",
                "display": "<font color=\"#FF6161\">C</font><font color=\"#FF8080\">E</font><font color=\"#FFA0A0\">L</font><font color=\"#FFBFBF\">E</font><font color=\"#FFDFDF\">B</font><font color=\"#FFFEFE\">R</font><font color=\"#DCE3FE\">A</font><font color=\"#BAC8FE\">T</font><font color=\"#98ACFE\">I</font><font color=\"#7691FE\">O</font><font color=\"#5475FE\">N</font>",
                "difficulty": 75,
                "author": "Gyrotron",
                "stepauthor": "gold stinger",
                "description": "Heyo",
                "point": {"x": 422, "y": 1052},
                "minimap": 0x84E14B};

        public function EmbedChartExtremeMegaMix()
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
            return new zExtremeMegaMix();
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
