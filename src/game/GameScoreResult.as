package game
{
    import classes.User;
    import classes.chart.Song;
    import flash.utils.ByteArray;

    public class GameScoreResult
    {
        public var game_index:int;
        public var level:int;
        public var song:Song;
        public var song_entry:Object;
        public var note_count:int;

        public var legacyLastRank:Object;

        public var user:User;
        public var options:GameOptions;

        public var amazing:int = 0;
        public var perfect:int = 0;
        public var good:int = 0;
        public var average:int = 0;
        public var boo:int = 0;
        public var miss:int = 0;
        public var combo:int = 0;
        public var max_combo:int = 0;
        public var score:int = 0;

        public var holdsok:int = 0;
        public var holdsng:int = 0;

        public var autoPlayCounter:int = 0;

        public function get is_aaa():Boolean
        {
            return (((amazing + perfect) == note_count) && max_combo == note_count && good == 0 && average == 0 && boo == 0 && miss == 0);
        }

        public function get is_fc():Boolean
        {
            return (max_combo == note_count && miss == 0);
        }

        public function get raw_goods():Number
        {
            return good + (average * 1.8) + (miss * 2.4) + (boo * 0.2);
        }

        public var restarts:int;
        public var restart_stats:Object;
        public var last_note:int;

        // Accuracy
        public var accuracy:Number;
        public var accuracy_deviation:Number;

        public function get accuracy_frames():Number
        {
            return GameOptions.ENGINE_TICK_RATE * accuracy / 1000;
        }

        public function get accuracy_deviation_frames():Number
        {
            return GameOptions.ENGINE_TICK_RATE * accuracy_deviation / 1000;
        }

        // Replay v3
        public var replay:Array;
        public var replay_hit:Array;

        // Binary Replays (aka Replay v4)
        public var replay_bin_notes:Array;
        public var replay_bin_boos:Array;
        private var _replay_bin:ByteArray;

        public var start_time:String;
        public var start_hash:String;
        public var end_time:String;

        /** Ratio of Song Completion: 0 -> 1 */
        public var song_progress:Number;
        public var playtime_secs:Number;

        // Judge Settings
        public var MIN_TIME:int = 0;
        public var MAX_TIME:int = 0;
        public var GAP_TIME:int = 0;
        public var judge:Array;

        /**
         * Updates variables that need to be calculated after others are set.
         * @param _gvars GlobalVariables reference.
         */
        public function update(_gvars:GlobalVariables):void
        {
            updateJudge();
        }

        /**
         * Updates Judge Region Min Time, Max Time, and Total Size
         * either from the default judge, or a custom set judge.
         */
        public function updateJudge():void
        {
            // Get Judge Window
            judge = Constant.JUDGE_WINDOW;
            if (options.judgeWindow)
                judge = options.judgeWindow;

            // Get Judge Window Size
            for (var jn:int = 0; jn < judge.length; jn++)
            {
                var jni:Object = judge[jn];
                if (jni.t < MIN_TIME)
                    MIN_TIME = jni.t;

                if (jni.t > MAX_TIME)
                    MAX_TIME = jni.t;
            }

            GAP_TIME = MAX_TIME - MIN_TIME;
        }

        /**
         * Gets the judge region for the given ms difference.
         * @param time Judge Time
         * @return Judge Region
         */
        public function getJudgeRegion(time:int):Object
        {
            var lastJudge:Object;

            for each (var j:Object in judge)
                if (time > j.t)
                    lastJudge = j;

            return lastJudge;
        }

        /**
         * Gets the total score for the result.
         * @return
         */
        public function get score_total():Number
        {
            return Math.max(0, ((amazing + perfect) * 500) + (good * 250) + (average * 50) + (max_combo * 1000) - (miss * 300) - (boo * 15) + score);
        }

        /**
         * Gets the PA string displayed in several places.
         * Example: 1653-1-0-0-0
         * @return
         */
        public function get pa_string():String
        {
            return (amazing + perfect) + "-" + good + "-" + average + "-" + miss + "-" + boo;
        }

        /**
         * Gets a friendly screenshot path based on the song name, score, and pa string.
         * @return
         */
        public function get screenshot_path():String
        {
            return "R^3 - " + song_entry.name + " - " + score + " - " + pa_string;
        }
    }
}
