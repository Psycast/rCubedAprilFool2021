package classes.chart.levels
{
    import af.assets.chartaudio.zSpeedOfLink;
    import classes.chart.parse.ChartOSU;
    import flash.utils.ByteArray;

    public class EmbedChartSpeedOfLink extends EmbedChartBase
    {
        [Embed(source = "zSpeedOfLink.osu", mimeType = 'application/octet-stream')]
        private static const EMBED_CHART:Class;

        private const info:Object = {"name": "Speed Of Link",
                "display": "<font color=\"#9dff87\">ZOOOM</font>",
                "difficulty": 102,
                "author": "antiPLUR",
                "stepauthor": "Shoegazer",
                "description": "Zoom Zoom.\n\nMods: Bleeding",
                "point": {"x": 1573, "y": 1419},
                "minimap": 0xCE5BA0};

        public function EmbedChartSpeedOfLink()
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
            return new zSpeedOfLink();
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
