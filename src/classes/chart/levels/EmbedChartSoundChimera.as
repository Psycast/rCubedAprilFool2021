package classes.chart.levels
{
    import af.assets.chartaudio.zSoundChimera;
    import classes.chart.parse.ChartOSU;
    import flash.utils.ByteArray;

    public class EmbedChartSoundChimera extends EmbedChartBase
    {
        // Embed Charts
        [Embed(source = "zSoundChimeraNymph.osu", mimeType = 'application/octet-stream')]
        private static const EMBED_CHART_0:Class;
        [Embed(source = "zSoundChimeraGorgon.osu", mimeType = 'application/octet-stream')]
        private static const EMBED_CHART_1:Class;
        [Embed(source = "zSoundChimeraManticore.osu", mimeType = 'application/octet-stream')]
        private static const EMBED_CHART_2:Class;
        [Embed(source = "zSoundChimeraPolymerization.osu", mimeType = 'application/octet-stream')]
        private static const EMBED_CHART_3:Class;

        private const info:Object = {"name": "Sound Chimera",
                "display": "<font color=\"#E5C18C\">Vibration</font> <font color=\"#C36B3E\">Alchemy</font>",
                "difficulty": 84,
                "author": "Laur",
                "stepauthor": "vinh_",
                "description": "This was going to be harder, but I needed something easier.\n\nJust survive.\n\nMods: Bleeding",
                "point": {"x": 1252, "y": 1305},
                "minimap": 0xCE5BA0};

        public function EmbedChartSoundChimera()
        {
            this.DEFAULT_CHART_ID = 0;

            parser = new ChartOSU();
            parser.ignoreValidation = true;
            parser.load(new EMBED_CHART_0() as ByteArray);
            parser.load(new EMBED_CHART_1() as ByteArray);
            parser.load(new EMBED_CHART_2() as ByteArray);
            parser.load(new EMBED_CHART_3() as ByteArray);

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
            return new zSoundChimera();
        }

        override public function getChartData():ByteArray
        {
            return new EMBED_CHART_0() as ByteArray;
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
