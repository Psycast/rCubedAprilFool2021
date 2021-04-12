package classes.chart.levels
{
    import af.assets.chartaudio.zVoyage1970;
    import classes.chart.parse.ChartOSU;
    import flash.utils.ByteArray;

    public class EmbedChartVoyage1970 extends EmbedChartBase
    {
        [Embed(source = "zVoyage1970.osu", mimeType = 'application/octet-stream')]
        private static const EMBED_CHART:Class;

        private const info:Object = {"name": "Voyage 1970",
                "display": "<font color=\"#636363\">J</font><font color=\"#6C6C6C\">O</font><font color=\"#757575\">U</font><font color=\"#7E7E7E\">R</font><font color=\"#878787\">N</font><font color=\"#919191\">E</font><font color=\"#9A9A9A\">Y</font><font color=\"#A3A3A3\">S</font> <font color=\"#B6B6B6\">P</font><font color=\"#BFBFBF\">A</font><font color=\"#C8C8C8\">S</font><font color=\"#D1D1D1\">T</font>",
                "difficulty": 91,
                "author": "ZUN",
                "stepauthor": "Halogen-",
                "description": "Linear Notation.\n\nMods: Bleeding",
                "point": {"x": 927, "y": 1607},
                "minimap": 0xCE5BA0};

        public function EmbedChartVoyage1970()
        {
            this.DEFAULT_CHART_ID = 0;

            parser = new ChartOSU();
            parser.ignoreValidation = true;
            parser.load(getChartData());

            info['arrows'] = parser.data.notes[DEFAULT_CHART_ID].arrows;
            info['holds'] = parser.data.notes[DEFAULT_CHART_ID].holds;
            info['mines'] = parser.data.notes[DEFAULT_CHART_ID].mines;
            info['time'] = getChartTime(DEFAULT_CHART_ID);
        }

        override public function getInfo():Object
        {
            return info;
        }

        override public function getAudioData():*
        {
            return new zVoyage1970();
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
