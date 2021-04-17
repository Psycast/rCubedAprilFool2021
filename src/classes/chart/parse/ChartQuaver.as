package classes.chart.parse
{
    import com.flashfla.utils.StringUtil;
    import flash.utils.ByteArray;

    /**
     * Quaver actually just uses a standard YAML serializion format.
     * Flash doesn't have one of those, and the only one I found made the game just crash.
     * It's good enough for Quaver Files unless it does some really crazy things.
     */
    public class ChartQuaver extends ChartBase
    {
        public var COLORS:Object = {"4": ["white", "blue", "blue", "white"],
                "7": ["white", "blue", "white", "red", "white", "blue", "white"]};

        public var ARRAY_TOKEN:Array = ['- ', '  '];

        private var collections:Object;

        override public function load(fileData:ByteArray):Boolean
        {
            try
            {
                fileData.position = 0;

                var buff:String = fileData.readUTFBytes(fileData.length).replace(/\r\n|\r/gm, "\n");

                var bufflines:Array = buff.split("\n");

                collections = {};

                // Advanced File Basic
                var buckets:Array = [collections];
                var bucket_keys:Array = [null];
                var bucket_depths:Array = [0];
                var bucket_depth:int = 0;
                var bucket_last_depth:int = 0;

                var line:String;
                var collection_key:String;

                var key:String;
                var val:*;
                var keyToken:String;

                var stackBucket:Object;
                var stackBucketKey:String;

                for (var l:int = 0; l < bufflines.length; l++)
                {
                    line = bufflines[l];

                    bucket_depth = 0;

                    var splitIndex:int = line.indexOf(":");
                    var startArrayItem:Boolean = false;

                    key = line.substr(0, splitIndex);
                    val = parseValue(StringUtil.trim(line.substr(splitIndex + 1)));
                    keyToken = key.substr(0, 2);

                    // Empty Line
                    if (line.length == 0 || splitIndex < 0)
                        continue;

                    // Bucket Depth
                    if (ARRAY_TOKEN.indexOf(keyToken) >= 0)
                    {
                        startArrayItem ||= (keyToken.indexOf("-") >= 0);
                        while (true)
                        {
                            key = key.substr(2);
                            keyToken = key.substr(0, 2);
                            bucket_depth++;

                            startArrayItem ||= (keyToken.indexOf("-") >= 0);

                            if (ARRAY_TOKEN.indexOf(keyToken) < 0)
                                break;
                        }
                    }

                    // New Array Item at the same depth.
                    if (startArrayItem && bucket_depth == bucket_last_depth)
                    {
                        stackBucket = buckets.pop();
                        stackBucketKey = bucket_keys.pop();
                        bucket_depths.pop();

                        if (stackBucketKey == null)
                            buckets[buckets.length - 1].push(stackBucket);
                    }

                    // Depth changed, close up open buckets.
                    if (bucket_depth < bucket_last_depth)
                    {
                        var returnDepth:Number = bucket_depths.pop();
                        while (returnDepth >= bucket_depth)
                        {
                            stackBucket = buckets.pop();
                            stackBucketKey = bucket_keys.pop();

                            // Either Object or Array, no key means array.
                            if (stackBucketKey == null)
                                buckets[buckets.length - 1].push(stackBucket);
                            else
                                buckets[buckets.length - 1][stackBucketKey] = stackBucket;

                            // Don't empty the buffer, the main collection resides at 0.
                            if (bucket_depths.length <= 1)
                                break;

                            returnDepth = bucket_depths.pop();
                        }
                    }

                    // Start New Object
                    if (startArrayItem)
                    {
                        buckets[buckets.length] = {};
                        bucket_keys[bucket_keys.length] = null;
                        bucket_depths[bucket_depths.length] = bucket_depth;
                    }

                    // New Array
                    if (val == null)
                    {
                        buckets[buckets.length] = [];
                        bucket_keys[bucket_keys.length] = key;
                        bucket_depths[bucket_depths.length] = bucket_depth;
                    }
                    else
                    {
                        buckets[buckets.length - 1][key] = val;
                    }

                    // Save Last State
                    bucket_last_depth = bucket_depth;
                }

                // Collapse Remaining Buckets
                while (buckets.length > 1)
                {
                    stackBucket = buckets.pop();
                    stackBucketKey = bucket_keys.pop();

                    // Either Object or Array, no key means array.
                    if (stackBucketKey == null)
                        buckets[buckets.length - 1].push(stackBucket);
                    else
                        buckets[buckets.length - 1][stackBucketKey] = stackBucket;
                }

                function parseValue(val:String):*
                {
                    if (val == "" || val.length == 0)
                        return null;

                    if (val == "[]")
                        return [];

                    else if (val == "''")
                        return '';

                    else if (val.charAt(0) == "'")
                        return val.substr(1, val.length - 2);

                    // Has quote escape characters, maintains \\ as well.
                    else if (val.charAt(0) == '"')
                        return val.substr(1, val.length - 2).replace(/\\\\/gm, "!---slash-replace---!").replace(/\\/gm, "").replace(/!---slash-replace---!/gm, "\\");

                    return val;
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

                // No Notes in the file.
                if (noteArray.length <= 0)
                {
                    trace("QUA: Invalid: [No Notes]");
                    return false;
                }

                // Calculate some Difficulty, just so we can "sort" charts.
                // jk, just use NPS including LNs. (Make LN maps appear harder)
                data['difficulty'] = Math.round((noteArray.length + noteHoldArray.length) / (noteArray[noteArray.length - 1][0]));

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
