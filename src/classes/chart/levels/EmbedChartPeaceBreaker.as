package classes.chart.levels
{
    import af.assets.chartaudio.zPeaceBreaker;
    import classes.chart.parse.ChartOSU;
    import flash.utils.ByteArray;

    public class EmbedChartPeaceBreaker extends EmbedChartBase
    {
        [Embed(source = "zPeaceBreakerWristBreaker.osu", mimeType = 'application/octet-stream')]
        private static const EMBED_CHART_0:Class;
        [Embed(source = "zPeaceBreakerFinalPunishment.osu", mimeType = 'application/octet-stream')]
        private static const EMBED_CHART_1:Class;

        private const info:Object = {"name": "PEACE BREAKER",
                "display": "<font color=\"#fc6ab8\">BRO</font>\/<font color=\"#a00000\">KEN</font>",
                "difficulty": 120,
                "author": "xi",
                "stepauthor": "Fullerene-",
                "description": "Just survive.\n\nMods: Bleeding",
                "point": {"x": 1315, "y": 1651},
                "minimap": 0xCE5BA0};

        public function EmbedChartPeaceBreaker()
        {
            this.DEFAULT_CHART_ID = 1;

            parser = new ChartOSU();
            parser.ignoreValidation = true;
            parser.load(new EMBED_CHART_0() as ByteArray);
            parser.load(new EMBED_CHART_1() as ByteArray);

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
            return new zPeaceBreaker();
        }

        override public function getChartData():ByteArray
        {
            return new EMBED_CHART_1() as ByteArray;
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
