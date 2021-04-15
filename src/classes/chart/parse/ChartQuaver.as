package classes.chart.parse
{
    import com.flashfla.utils.StringUtil;
    import flash.utils.ByteArray;

    /**
     * Quaver actually just uses a standard YAML serializion format.
     * Flash doesn't have one of those, and the only one I found made the game just close.
     * I really don't know why, but I glued this together, but it really should be made proper.
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

                var bufflines:Array = buff.split("\n");

                collections = {};

                var bucket:Object;

                // Read File Basic
                var line:String;
                var collection_key:String;

                var inArray:Boolean = false;

                for (var l:int = 0; l < bufflines.length; l++)
                {
                    line = bufflines[l];

                    var splitIndex:int = line.indexOf(":");

                    var key:String = line.substr(0, splitIndex);
                    var val:String = StringUtil.trim(line.substr(splitIndex + 1));
                    var keyToken:String = key.substr(0, 2);

                    if (line.length == 0 || splitIndex < 0)
                        continue;

                    // Check Array Exit
                    if (inArray)
                    {
                        if (keyToken != "- " && keyToken != "  ")
                        {
                            inArray = false;
                            if (bucket != null)
                            {
                                collections[collection_key].push(bucket);
                                bucket = null;
                                collection_key = null;
                            }
                        }
                    }

                    function parseValue(val:String):*
                    {
                        if (val == "[]")
                            return [];

                        else if (val == "''")
                            return '';

                        return val;
                    }

                    // Array Start
                    if (val == "")
                    {
                        var nextLineToken:String = bufflines[l + 1].substr(0, 2);
                        if (nextLineToken == "  " || nextLineToken == "- ")
                        {
                            inArray = true;
                            collection_key = key;
                            collections[key] = [];
                        }
                        continue;
                    }

                    // Array Builder
                    if (inArray)
                    {
                        key = key.substr(2);

                        var indentCheck:String = key.substr(0, 2);
                        if (indentCheck == "- " || indentCheck == "  ")
                        {
                            // De-dent
                            while (true)
                            {

                                keyToken = indentCheck;
                                key = key.substr(2);
                                indentCheck = key.substr(0, 2);

                                if (indentCheck != "- " && indentCheck != "  ")
                                    break;
                            }
                        }

                        // Remove Token
                        switch (keyToken)
                        {
                            case "- ":
                                if (bucket != null)
                                {
                                    collections[collection_key].push(bucket);
                                }
                                bucket = {};
                                bucket[key] = parseValue(val);
                                break;

                            case "  ":
                                bucket[key] = parseValue(val);
                                break;
                        }
                    }
                    else
                    {
                        collection_key = null;
                        collections[key] = parseValue(val);
                        continue;
                    }
                }

                // Remaing item in bucket.
                if (bucket != null)
                {
                    collections[collection_key].push(bucket);
                }

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
                data['difficulty'] = 0; // Quaver calculates this on load, is not saved.
                data['banner'] = collections["BackgroundFile"];

                // Build NoteMap Object
                var columnCount:int = standardType(collections["Mode"]);
                var noteCollection:Array = collections["HitObjects"];
                var noteArray:Array = [];
                var noteHoldArray:Array = [];
                var noteEntry:Array;
                var collectionEntry:Object;
                for (l = 0; l < noteCollection.length; l++)
                {
                    collectionEntry = noteCollection[l];

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

                // Fill Chart Data
                var noteArrayObject:Object = {"class": collections["DifficultyName"],
                        "class_color": "Hard", //collections["DifficultyName"],
                        "desc": "",
                        "difficulty": 0,
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
    }
}
