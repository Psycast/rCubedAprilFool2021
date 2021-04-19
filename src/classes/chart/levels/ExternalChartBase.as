package classes.chart.levels
{
    import classes.chart.parse.ChartBase;
    import classes.chart.parse.ChartOSU;
    import classes.chart.parse.ChartQuaver;
    import classes.chart.parse.ChartSSC;
    import classes.chart.parse.ChartStepmania;
    import flash.events.ErrorEvent;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;

    public class ExternalChartBase extends EmbedChartBase
    {
        public static const VALID_CHART_EXTENSIONS:Array = ["sm", "ssc", "osu", "qua"];

        private var CHART_BYTES:ByteArray;
        private var AUDIO_BYTES:ByteArray;

        private var fileQueue:Array = [];

        private var info:Object = {"name": "External File",
                "display": "???",
                "difficulty": 1,
                "author": "???",
                "stepauthor": "???",
                "description": "???"}

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
            return AUDIO_BYTES;
        }

        override public function getChartData():ByteArray
        {
            return CHART_BYTES;
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

        //----------------------------------------------------------------------------------------------------------//

        public function load(folder:File, skipMusicLoad:Boolean = false):Boolean
        {
            // Search Folder for Parseable Files
            if (folder.isDirectory)
            {
                for each (var file:File in folder.getDirectoryListing())
                {
                    if (VALID_CHART_EXTENSIONS.indexOf(file.extension.toLowerCase()) != -1)
                    {
                        fileQueue.push(file);
                    }
                }
            }
            // Given File, Assume Good
            else
            {
                if (VALID_CHART_EXTENSIONS.indexOf(folder.extension.toLowerCase()) != -1)
                {
                    fileQueue.push(folder);
                }
            }

            // Validate and Load File Queue, Stop after first valid chart.
            while (fileQueue.length > 0)
            {
                var firstFile:File = fileQueue.pop();

                parser = getParser(firstFile.extension.toLowerCase());

                CHART_BYTES = readFile(firstFile);

                if (parser.load(CHART_BYTES))
                {
                    info['ext'] = firstFile.extension.toLowerCase();
                    info['name'] = parser.data.title || "???";
                    info['display'] = parser.data.title || "???";
                    info['author'] = parser.data.artist || "???";
                    info['stepauthor'] = parser.data.stepauthor || "???";
                    info['difficulty'] = parser.data.difficulty || 1;
                    info['arrows'] = parser.data.notes[DEFAULT_CHART_ID].arrows;
                    info['holds'] = parser.data.notes[DEFAULT_CHART_ID].holds;
                    info['mines'] = parser.data.notes[DEFAULT_CHART_ID].mines;
                    info['time'] = getChartTime(DEFAULT_CHART_ID);
                    info['music'] = parser.data.music || "";
                    info['banner'] = parser.data.banner || "";
                    info['background'] = parser.data.background || "";

                    // Folder Path
                    var path:String = firstFile.nativePath;
                    var endOfFolder:int = path.lastIndexOf(File.separator) + 1;
                    info['folder'] = path.substr(0, endOfFolder);

                    // Music Validation
                    if (parser.data.music.length < 4 || parser.data.music.substr(-3).toLowerCase() != "mp3")
                        return false;

                    if (!skipMusicLoad)
                    {
                        var musicFile:File = firstFile.parent.resolvePath(parser.data.music);

                        if (!musicFile.exists)
                            return false;

                        AUDIO_BYTES = readFile(firstFile.parent.resolvePath(parser.data.music));
                    }

                    fileQueue.length = 0;
                    return true;
                }
            }

            return false;
        }

        public function getParser(ext:String):ChartBase
        {
            switch (ext)
            {
                case "sm":
                    return new ChartStepmania();

                case "ssc":
                    return new ChartSSC();

                case "osu":
                    return new ChartOSU();

                case "qua":
                    return new ChartQuaver();
            }

            return null;
        }

        public function readFile(file:File):ByteArray
        {
            var fileStream:FileStream = new FileStream();
            fileStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, e_error);
            fileStream.addEventListener(IOErrorEvent.IO_ERROR, e_error);
            var readData:ByteArray = new ByteArray();
            fileStream.open(file, FileMode.READ);
            fileStream.readBytes(readData);
            fileStream.close();

            return readData;

            function e_error(e:ErrorEvent):void
            {

            }
        }
    }
}
