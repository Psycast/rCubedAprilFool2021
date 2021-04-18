package classes.chart.parse
{
    import com.flashfla.parser.YAML;
    import flash.utils.ByteArray;

    /**
     * Quaver actually just uses a standard YAML serializion format.
     * Flash doesn't have one of those, and the only one I found made the game just crash.
     * I wrote my own that should be good enough for Quaver Files unless it does some really crazy things.
     * - Velocity
     */
    public class ChartQuaver extends ChartBase
    {
        public var COLORS:Object = {"4": ["white", "blue", "blue", "white"],
                "7": ["white", "blue", "white", "red", "white", "blue", "white"]};

        private var collections:Object;

        override public function load(fileData:ByteArray):Boolean
        {
            try
            {
                fileData.position = 0;

                var buff:String = fileData.readUTFBytes(fileData.length).replace(/\r\n|\r/gm, "\n");

                // Decode YAML
                collections = YAML.decode(buff);

                // Build data
                var audioExt:String = collections["AudioFile"].substr(-3).toLowerCase();
                if (!ignoreValidation && (audioExt != "mp3"))
                {
                    trace("QUA: Invalid: [", audioExt, "]");
                    return false;
                }

                data['music'] = collections["AudioFile"];
                data['title'] = collections["Title"];
                data['artist'] = collections["Artist"];
                data['stepauthor'] = collections["Creator"];
                data['banner'] = collections["BackgroundFile"];

                // Build NoteMap Object
                var columnCount:int = standardType(collections["Mode"]);
                var noteCollection:Array = collections["HitObjects"];
                var noteArray:Array = [];
                var noteHoldArray:Array = [];
                var noteEntry:Array;
                var collectionEntry:Object;
                for (var note:int = 0; note < noteCollection.length; note++)
                {
                    collectionEntry = noteCollection[note];

                    var noteTime:int = parseFloat(collectionEntry["StartTime"]);
                    var noteColumn:int = parseInt(collectionEntry["Lane"]) - 1;

                    noteEntry = [(noteTime / 1000), COLUMNS[columnCount][noteColumn], COLORS[columnCount][noteColumn]];

                    // Held Note
                    if (collectionEntry["EndTime"] != null)
                    {
                        noteEntry[noteEntry.length] = (parseFloat(collectionEntry["EndTime"]) / 1000) - noteEntry[0];

                        noteHoldArray[noteHoldArray.length] = noteEntry;
                    }

                    noteArray[noteArray.length] = noteEntry;
                }

                // No Notes in the file.
                if (noteArray.length <= 0)
                {
                    trace("QUA: Invalid: [No Notes]");
                    return false;
                }

                // Calculate some Difficulty, just so we can "sort" charts.
                data['nps'] = Math.round((noteArray.length + noteHoldArray.length) / (noteArray[noteArray.length - 1][0]));
                data['difficulty'] = data['nps'];

                // Fill Chart Data
                var noteArrayObject:Object = {"class": collections["DifficultyName"],
                        "class_color": getDifficultyClass(data['difficulty']), //collections["DifficultyName"],
                        "desc": collections["Description"],
                        "difficulty": data['difficulty'],
                        "arrows": noteArray.length,
                        "holds": noteHoldArray.length,
                        "mines": 0,
                        "radar_values": "0,0,0,0,0",
                        "type": columnCount,
                        "stepauthor": collections["Creator"]};

                var chartArrayObject:Object = {"columns": columnCount,
                        "data": noteArrayObject,
                        "notes": noteArray,
                        "holds": noteHoldArray,
                        "mines": []};

                data["notes"].push(noteArrayObject);
                charts.push(chartArrayObject);
            }
            catch (e:Error)
            {
                trace("QUA: Error Catch: " + e);
                return false;
            }

            this.loaded = true;
            this.parsed = true;
            return true;
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////
        /**
         * Converts a given chart type into it's respective column count.
         * @param type
         * @return
         */
        private function standardType(type:String):int
        {
            switch (type)
            {
                case 'Keys4':
                    return 4;

                case 'Keys7':
                    return 7;
            }

            return 0;
        }

        private function getDifficultyClass(val:Number):String
        {
            if (val >= 14)
                return "Edit";
            if (val >= 11)
                return "Challenge";
            if (val >= 9)
                return "Hard";
            if (val >= 6.5)
                return "Medium";
            if (val >= 3.5)
                return "Easy";

            return "Beginner";
        }
    }
}
