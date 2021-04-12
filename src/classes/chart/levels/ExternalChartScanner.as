package classes.chart.levels
{
    import flash.filesystem.File;
    import classes.FileTracker;

    public class ExternalChartScanner
    {
        public static const parseableExt:Array = ["sm", "ssc", "osu"];

        public static function getPossibleChartPaths(file:File, track:FileTracker = null, level:int = 0, maxLevel:int = 2):FileTracker
        {
            if (!track)
                track = new FileTracker();

            if (file == null || file.exists == false)
            {
                return track;
            }
            if (file.isDirectory)
            {
                track.dir_paths.push(file.nativePath);
                track.dirs++;
                var files:Array = file.getDirectoryListing();
                for each (var f:File in files)
                {
                    if (f.isDirectory)
                    {
                        if (level < maxLevel)
                            getPossibleChartPaths(f, track, level + 1);
                    }
                    else
                    {
                        if (f.extension != null && parseableExt.indexOf(f.extension.toLowerCase()) != -1)
                        {
                            track.file_paths.push(f.nativePath);
                            track.files++;
                            track.size += f.size;
                        }
                    }
                }
            }
            else
            {
                if (f.extension != null && parseableExt.indexOf(file.extension.toLowerCase()) != -1)
                {
                    track.file_paths.push(file.nativePath);
                    track.files++;
                    track.size += file.size;
                }
            }
            return track;
        }

        public static function filterValid(tracker:FileTracker):Vector.<ExternalChartBase>
        {
            var out:Vector.<ExternalChartBase> = new <ExternalChartBase>[];
            var emb:ExternalChartBase;

            for each (var stringPath:String in tracker.file_paths)
            {
                emb = new ExternalChartBase();
                if (emb.load(new File(stringPath)))
                {
                    out.push(emb);
                }
            }

            return out;
        }
    }
}
