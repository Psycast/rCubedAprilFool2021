package scripts.darkmatter
{

    public class DarkMatterTimeline
    {
        public static var TIMELINE_CALC:Boolean = false;

        public static function getTimeline():Array
        {
            if (!TIMELINE_CALC)
            {
                var arrLen:int = TIMELINE.length;
                var isAbsolute:Boolean = true;
                var lastAbol:Number = 0;
                var i:int;

                // Convert Relative Time to Absolute
                for (i = 0; i < arrLen; i++)
                {
                    if (TIMELINE[i][1] == "SetTimelineMode")
                    {
                        lastAbol = TIMELINE[i][0];
                        isAbsolute = TIMELINE[i][2] == "Absolute";
                        TIMELINE.removeAt(i);
                        arrLen--;
                        i--;
                        continue;
                    }

                    if (isAbsolute)
                        lastAbol = TIMELINE[i][0];
                    else
                    {
                        lastAbol += TIMELINE[i][0];
                        TIMELINE[i][0] = lastAbol;
                    }
                }

                TIMELINE.sortOn(["0"], [Array.NUMERIC]);

                // Convert Absolute to Relative
                lastAbol = 0;
                var curTime:Number = 0;
                for (i = 0; i < arrLen; i++)
                {
                    curTime = TIMELINE[i][0];
                    TIMELINE[i][0] -= lastAbol;
                    lastAbol = curTime;
                }

                TIMELINE_CALC = true;

            }
            return TIMELINE;
        }

        private static var SHAKE_INTENSE:int = 8;
        private static var SHAKE_INTENSE_HIGH:int = 22;
        private static var SHAKE_REDUCTION:Number = 0.5;
        private static var SHAKE_REDUCTION_HIGH:Number = 1.25;

        private static var TIPSY_SYO:int = 120; // Peak Outer
        private static var TIPSY_SYE:int = 40; // Peak Inner
        private static var TIPSY_SYR:int = 80; // Reset
        private static var TIPSY_SYREVERSE:int = 160; // Reset
        private static var TIPSY_EASE:String = "outSine";
        private static var TIPSY_EASE2:String = "outElastic";

        private static var NORMAL_SCROLLSPEED:Number = 2;
        private static var WALL_SCROLLSPEED:Number = 0.75;

        public static const TIMELINE:Array = [
            // Gameplay
            [0, "SetTimelineMode", "Absolute"],
            [0, "FilterMask", true],
            [0, "SetDisplacementFilter", "Corrupt"],
            [0, "MoveX", 0, 0, 0, "linear"],
            [0, "SetDirection", 6.441, -0.05, -1, "inQuint"],
            [0, "SetReadahead", 14000],
            [1, "SetReadahead", 1000],


            // Intro
            [1.728, "Pulse", 14.049, 0.293],
            [3.484, "ColumnFlip", 0.293, "outSine"],
            [3.777, "ColumnFlip", 0.293, "outSine"],
            [4.070, "MoveX", 0, 0, 0, "linear"],
            [5.826, "ColumnInvert", 0.293, "outSine"],
            [6.118, "ColumnInvert", 0.293, "outSine"],
            [6.411, "MoveX", 0, 0, 0, "linear"],
            [8.167, "ColumnFlip", 0.293, "outSine"],
            [8.460, "ColumnFlip", 0.293, "outSine"],
            [8.753, "MoveX", 0, 0, 0, "linear"],
            [10.509, "ColumnInvert", 0.293, "outSine"],
            [10.801, "ColumnInvert", 0.293, "outSine"],
            [11.094, "MoveX", 0, 0, 0, "linear"],
            [11.094, "PlayCharAction", "Spawn"],
            [11.094, "PlayCharAnimation", "Idle"],
            [15.777, "ConfusionOffset", 2.341, -2167, 0, "outSine"],
            [15.777, "NoteScale", 2.341, 0.7, 1.8, "inSine"],
            [15.777, "MoveXN", 2.341, "L", 0, -100, "inSine"],
            [15.777, "MoveXN", 2.341, "D", 0, -32, "inSine"],
            [15.777, "MoveXN", 2.341, "U", 0, 32, "inSine"],
            [15.777, "MoveXN", 2.341, "R", 0, 100, "inSine"],
            [18.118, "NoteScale", 1.757, 1.8, 0, "outSine"],
            [18.118, "MoveXN", 1.757, "L", -100, 0, "outSine"],
            [18.118, "MoveXN", 1.757, "D", -32, 0, "outSine"],
            [18.118, "MoveXN", 1.757, "U", 32, 0, "outSine"],
            [18.118, "MoveXN", 1.757, "R", 100, 0, "outSine"],
            [18.118, "PlayCharAction", "Cast"],
            [18.118, "PlayCharAnimation", "Cast"],
            [19.875, "NoteScale", 0.292, 0, 0.7, "outSine"],
            [19.875, "SetDisplacementFilter", ""],
            [20.167, "PlayCharAction", "Hide"],

            // Section 1a - Displacement Shifts
            [20.460, "SetDisplacementFilter", "Shift"],
            [20.460, "FilterVariable", 3.366, "scaleX", -3750, "linear"],
            [23.826, "FilterVariable", 0.585, "scaleX", 0, "outElastic"],
            [25.143, "SetDisplacementFilter", "Wiggle"],
            [25.143, "FilterVariable", 3.366, "scaleX", -100, "linear"],
            [28.509, "FilterVariable", 0.585, "scaleX", 0, "outElastic"],
            [29.826, "FilterMask", false],
            [29.826, "SetDisplacementFilter", ""],

            // Section 1b - Perspective Warp
            [29.765, "FieldTween", 7.778, "rotationX", 0, -60, "linear"],
            [29.765, "NoteScale", 7.778, 0.7, 0.5, "linear"],
            [29.765, "MoveY", 7.778, 0, -130, "inCubic"],
            [37.543, "FieldTween", 1.063, "rotationX", -60, 0, "inOutBack"],
            [37.543, "NoteScale", 1.063, 0.5, 0.7, "inOutBack"],
            [37.543, "MoveY", 1.063, -130, 0, "inOutBack"],

            // Wall 1
            [38.606, "ConfusionOffset", 0.586, 360, 0, "outSine"],
            [38.606, "MoveXN", 0.586, "L", 0, 19, "outSine"],
            [38.606, "MoveXN", 0.586, "D", 0, 7, "outSine"],
            [38.606, "MoveXN", 0.586, "U", 0, -7, "outSine"],
            [38.606, "MoveXN", 0.586, "R", 0, -19, "outSine"],
            [38.606, "MoveY", 0.586, 0, TIPSY_SYR, "outSine"],
            [38.606, "EnableMod", "speed_update"],
            [38.606, "SetSpeed", 0.586, NORMAL_SCROLLSPEED, WALL_SCROLLSPEED, "outSine"],
            [38.606, "WallShow"],
            [39.192, "FilterMask", true],
            [39.192, "SetDisplacementFilter", "Wall"],
            [39.192, "FlashBang", 1.165],
            [39.192, "PlayCharAction", "Spawn"], // Walls 1
            [39.192, "PlayCharAnimation", "Idle"],

            // A Slam Center -> Left
            [39.484, "SetTimelineMode", "Relative"],
            [0, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", 19, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 7, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", -7, -190, "outBack"],
            [0, "MoveXN", 0.293, "R", -19, -210, "outBack"],
            [0, "ScreenShakeReduction", SHAKE_REDUCTION],
            [0, "ScreenShake", SHAKE_INTENSE],
            [0, "PlayCharAnimation", "Swipe"],

            // A Slam Left -> Right
            [0.354, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", -150, 210, "outBack"],
            [0, "MoveXN", 0.293, "D", -170, 190, "outBack"],
            [0, "MoveXN", 0.293, "U", -190, 170, "outBack"],
            [0, "MoveXN", 0.293, "R", -210, 150, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE],
            [0, "PlayCharAnimation", "Swipe", -1],

            // A Slam Right -> Left
            [0.354, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", 210, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 190, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", 170, -190, "outBack"],
            [0, "MoveXN", 0.293, "R", 150, -210, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE],
            [0, "PlayCharAnimation", "Swipe"],

            // A Reset Left -> Center
            [0.354, "MoveXN", 0.586, "L", -150, 19, "inOutSine"],
            [0, "MoveXN", 0.586, "D", -170, 7, "inOutSine"],
            [0, "MoveXN", 0.586, "U", -190, -7, "inOutSine"],
            [0, "MoveXN", 0.586, "R", -210, -19, "inOutSine"],

            // A Slam Center -> Split
            [0.586, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "PlayCharAnimation", "Idle"],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.146, "MoveXN", 0.293, "L", 19, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 7, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", -7, 170, "outBack"],
            [0, "MoveXN", 0.293, "R", -19, 150, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE],
            [0, "PlayCharAnimation", "Push"],

            // Reset -> End
            [0.293, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],

            // A End
            [42.795, "SetTimelineMode", "Relative"],
            [0, "PlayCharAnimation", "Cast"],
            [0, "MoveXN", 0.293, "U", 170, -7, "outBack"],
            [0.146, "MoveXN", 0.293, "L", -150, 19, "outBack"],
            [0.146, "MoveXN", 0.293, "D", -170, 7, "outBack"],
            [0.146, "MoveXN", 0.293, "R", 150, -19, "outBack"],
            [0.136, "SetSpeed", 0.146, WALL_SCROLLSPEED, 0.01, "outSine"],
            [0.010, "MoveY", 0.143, TIPSY_SYR, TIPSY_SYREVERSE, TIPSY_EASE],
            [0.136, "SetSpeed", 0.146, 0.01, WALL_SCROLLSPEED, "outSine"],
            [0.010, "MoveYN", 0.143, "L", TIPSY_SYREVERSE, TIPSY_SYR + 10, TIPSY_EASE],
            [0, "MoveYN", 0.143, "D", TIPSY_SYREVERSE, TIPSY_SYR - 40, TIPSY_EASE],
            [0, "MoveYN", 0.143, "U", TIPSY_SYREVERSE, TIPSY_SYR - 30, TIPSY_EASE],
            [0, "MoveYN", 0.143, "R", TIPSY_SYREVERSE, TIPSY_SYR + 20, TIPSY_EASE],
            [0.136, "MoveYN", 0.143, "L", TIPSY_SYR + 10, TIPSY_SYR, TIPSY_EASE],
            [0, "MoveYN", 0.143, "D", TIPSY_SYR - 40, TIPSY_SYR, TIPSY_EASE],
            [0, "MoveYN", 0.143, "U", TIPSY_SYR - 30, TIPSY_SYR, TIPSY_EASE],
            [0, "MoveYN", 0.143, "R", TIPSY_SYR + 20, TIPSY_SYR, TIPSY_EASE],
            [0, "PlayCharAnimation", "Idle"],

            // B Slam Center -> Left
            [44.106, "SetTimelineMode", "Relative"],
            [0, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", 19, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 7, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", -7, -190, "outBack"],
            [0, "MoveXN", 0.293, "R", -19, -210, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE],
            [0, "PlayCharAnimation", "Swipe"],

            // B Slam Left -> Right
            [0.354, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", -150, 210, "outBack"],
            [0, "MoveXN", 0.293, "D", -170, 190, "outBack"],
            [0, "MoveXN", 0.293, "U", -190, 170, "outBack"],
            [0, "MoveXN", 0.293, "R", -210, 150, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE],
            [0, "PlayCharAnimation", "Swipe", -1],

            // B Slam Right -> Left
            [0.354, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", 210, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 190, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", 170, -190, "outBack"],
            [0, "MoveXN", 0.293, "R", 150, -210, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE],
            [0, "PlayCharAnimation", "Swipe"],

            // B Reset Left -> Center
            [0.354, "MoveXN", 0.586, "L", -150, 19, "inOutSine"],
            [0, "MoveXN", 0.586, "D", -170, 7, "inOutSine"],
            [0, "MoveXN", 0.586, "U", -190, -7, "inOutSine"],
            [0, "MoveXN", 0.586, "R", -210, -19, "inOutSine"],

            // B Slam Center -> Split
            [0.586, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "PlayCharAnimation", "Idle"],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.146, "MoveXN", 0.293, "L", 19, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 7, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", -7, 170, "outBack"],
            [0, "MoveXN", 0.293, "R", -19, 150, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE],
            [0, "PlayCharAnimation", "Push"],

            // Reset -> End
            [0.293, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],

            // B End
            [47.240, "SetTimelineMode", "Absolute"],
            [47.240, "PlayCharAnimation", "Cast"],
            [47.240, "MoveXN", 1.536, "L", -150, 19, "outBounce"],
            [47.240, "MoveXN", 1.536, "D", -170, 7, "outBounce"],
            [47.240, "MoveXN", 1.536, "U", 170, -7, "outBounce"],
            [47.240, "MoveXN", 1.536, "R", 150, -19, "outBounce"],
            [47.240, "ConfusionOffsetN", 1.536, "L", -360, 0, "outBounce"],
            [47.240, "ConfusionOffsetN", 1.536, "D", -360, 0, "outBounce"],
            [47.240, "ConfusionOffsetN", 1.536, "U", 360, 0, "outBounce"],
            [47.240, "ConfusionOffsetN", 1.536, "R", 360, 0, "outBounce"],
            [47.240, "PlayCharAnimation", "Idle"],

            // C Slam Center -> Left
            [48.789, "SetTimelineMode", "Relative"],
            [0, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", 19, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 7, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", -7, -190, "outBack"],
            [0, "MoveXN", 0.293, "R", -19, -210, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE],
            [0, "PlayCharAnimation", "Swipe"],

            // C Slam Left -> Right
            [0.354, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", -150, 210, "outBack"],
            [0, "MoveXN", 0.293, "D", -170, 190, "outBack"],
            [0, "MoveXN", 0.293, "U", -190, 170, "outBack"],
            [0, "MoveXN", 0.293, "R", -210, 150, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE],
            [0, "PlayCharAnimation", "Swipe", -1],

            // C Slam Right -> Left
            [0.354, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", 210, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 190, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", 170, -190, "outBack"],
            [0, "MoveXN", 0.293, "R", 150, -210, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE],
            [0, "PlayCharAnimation", "Swipe"],

            // C Reset Left -> Center
            [0.354, "MoveXN", 0.586, "L", -150, 19, "inOutSine"],
            [0, "MoveXN", 0.586, "D", -170, 7, "inOutSine"],
            [0, "MoveXN", 0.586, "U", -190, -7, "inOutSine"],
            [0, "MoveXN", 0.586, "R", -210, -19, "inOutSine"],

            // C Slam Center -> Split
            [0.586, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "PlayCharAnimation", "Idle"],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.146, "MoveXN", 0.293, "L", 19, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 7, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", -7, 170, "outBack"],
            [0, "MoveXN", 0.293, "R", -19, 150, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE],
            [0, "PlayCharAnimation", "Push"],

            // Reset -> End
            [0.293, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],

            // C End
            [52.158, "SetTimelineMode", "Relative"],
            [0, "PlayCharAnimation", "Cast"],
            [0, "MoveXN", 0.293, "U", 170, -7, "outBack"],
            [0.146, "MoveXN", 0.293, "L", -150, 19, "outBack"],
            [0.146, "MoveXN", 0.293, "D", -170, 7, "outBack"],
            [0.146, "MoveXN", 0.293, "R", 150, -19, "outBack"],
            [0.136, "SetSpeed", 0.146, WALL_SCROLLSPEED, 0.01, "outSine"],
            [0.010, "MoveY", 0.143, TIPSY_SYR, TIPSY_SYREVERSE, TIPSY_EASE],
            [0.136, "SetSpeed", 0.146, 0.01, WALL_SCROLLSPEED, "outSine"],
            [0.010, "MoveYN", 0.143, "L", TIPSY_SYREVERSE, TIPSY_SYR + 10, TIPSY_EASE],
            [0, "MoveYN", 0.143, "D", TIPSY_SYREVERSE, TIPSY_SYR - 40, TIPSY_EASE],
            [0, "MoveYN", 0.143, "U", TIPSY_SYREVERSE, TIPSY_SYR - 30, TIPSY_EASE],
            [0, "MoveYN", 0.143, "R", TIPSY_SYREVERSE, TIPSY_SYR + 20, TIPSY_EASE],
            [0.136, "MoveYN", 0.143, "L", TIPSY_SYR + 10, TIPSY_SYR, TIPSY_EASE],
            [0, "MoveYN", 0.143, "D", TIPSY_SYR - 40, TIPSY_SYR, TIPSY_EASE],
            [0, "MoveYN", 0.143, "U", TIPSY_SYR - 30, TIPSY_SYR, TIPSY_EASE],
            [0, "MoveYN", 0.143, "R", TIPSY_SYR + 20, TIPSY_SYR, TIPSY_EASE],
            [0, "PlayCharAnimation", "Idle"],

            // D Slam Center -> Left
            [53.472, "SetTimelineMode", "Relative"],
            [0, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", 19, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 7, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", -7, -190, "outBack"],
            [0, "MoveXN", 0.293, "R", -19, -210, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE],
            [0, "PlayCharAnimation", "Swipe"],

            // D Slam Left -> Right
            [0.354, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", -150, 210, "outBack"],
            [0, "MoveXN", 0.293, "D", -170, 190, "outBack"],
            [0, "MoveXN", 0.293, "U", -190, 170, "outBack"],
            [0, "MoveXN", 0.293, "R", -210, 150, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE],
            [0, "PlayCharAnimation", "Swipe", -1],

            // D Slam Right -> Left
            [0.354, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", 210, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 190, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", 170, -190, "outBack"],
            [0, "MoveXN", 0.293, "R", 150, -210, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE],
            [0, "PlayCharAnimation", "Swipe"],

            // D Reset -> End
            [0.293, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],

            // D End
            [55.521, "SetTimelineMode", "Absolute"],
            [55.521, "FilterVariable", 1, "scaleX", 0, "linear"],
            [55.521, "FilterVariable", 1, "scaleY", 0, "linear"],
            [55.521, "NoteScale", 2.049, 0.7, 0, "outSine"],
            [55.521, "MoveY", 2.049, TIPSY_SYR, 150, "linear"],
            [55.521, "MoveXN", 2.049, "L", -150, 90, "linear"],
            [55.521, "MoveXN", 2.049, "D", -170, 30, "linear"],
            [55.521, "MoveXN", 2.049, "U", -190, -30, "linear"],
            [55.521, "MoveXN", 2.049, "R", -210, -90, "linear"],
            [55.521, "PlayCharAction", "Hide"], // Walls 1 End
            [55.521, "PlayCharAnimation", "Idle"],

            [57.570, "WallHide"],
            [57.570, "FilterMask", false],
            [57.570, "SetDisplacementFilter", ""],
            [57.631, "SetSpeed", 0.586, WALL_SCROLLSPEED, NORMAL_SCROLLSPEED, "outSine"],
            [57.631, "MoveY", 0.585, 150, 0, "outSine"],
            [57.631, "MoveXN", 0.293, "L", 90, 0, "linear"],
            [57.631, "MoveXN", 0.293, "D", 30, 0, "linear"],
            [57.631, "MoveXN", 0.293, "U", -30, 0, "linear"],
            [57.631, "MoveXN", 0.293, "R", -90, 0, "linear"],
            [57.631, "NoteScale", 0.293, 0, 0.7, "linear"],
            [70.000, "DisableMod", "speed_update"],

            // Section 2
            [57.923, "Pulse", 14.049, 0.293],
            [59.679, "ColumnFlip", 0.293, "outSine"],
            [59.972, "ColumnFlip", 0.293, "outSine"],
            [60.265, "MoveX", 0, 0, 0, "linear"],
            [62.021, "ColumnInvert", 0.293, "outSine"],
            [62.313, "ColumnInvert", 0.293, "outSine"],
            [62.606, "MoveX", 0, 0, 0, "linear"],
            [64.362, "ColumnFlip", 0.293, "outSine"],
            [64.655, "ColumnFlip", 0.293, "outSine"],
            [64.948, "MoveX", 0, 0, 0, "linear"],
            [66.704, "ColumnInvert", 0.293, "outSine"],
            [66.996, "ColumnInvert", 0.293, "outSine"],
            [67.289, "MoveX", 0, 0, 0, "linear"],
            [71.972, "ConfusionOffset", 3.512, -2667, 0, "outSine"],
            [71.972, "NoteScale", 2.341, 0.7, 0.2, "outSine"],
            [71.972, "MoveXN", 2.341, "L", 0, -150, "inSine"],
            [71.972, "MoveXN", 2.341, "D", 0, -50, "inSine"],
            [71.972, "MoveXN", 2.341, "U", 0, 50, "inSine"],
            [71.972, "MoveXN", 2.341, "R", 0, 150, "inSine"],
            [74.314, "NoteScale", 1.17, 0.2, 0.7, "outSine"],
            [74.314, "MoveXN", 1.757, "L", -150, 0, "outSine"],
            [74.314, "MoveXN", 1.757, "D", -50, 0, "outSine"],
            [74.314, "MoveXN", 1.757, "U", 50, 0, "outSine"],
            [74.314, "MoveXN", 1.757, "R", 150, 0, "outSine"],
            [74.314, "PlayCharAction", "Spawn"],
            [74.314, "PlayCharAnimation", "Idle"],
            [75.769, "PlayCharAction", "Cast"],
            [75.769, "PlayCharAnimation", "Cast"],

            // Flip -> Reverse
            [75.665, "SetNoteskin", 2], // Time - readahead
            [75.777, "MoveYN", 0.586, "L", 0, 310, "outBack"],
            [75.777, "SetDirectionN", 0.586, "L", -1, 1, "outBack"],
            [76.227, "SetHoldRotationN", "L", 180],
            [76.070, "MoveYN", 0.586, "D", 0, 310, "outBack"],
            [76.070, "SetDirectionN", 0.586, "D", -1, 1, "outBack"],
            [76.520, "SetHoldRotationN", "D", 180],
            [76.362, "MoveYN", 0.586, "U", 0, 310, "outBack"],
            [76.362, "SetDirectionN", 0.586, "U", -1, 1, "outBack"],
            [76.812, "SetHoldRotationN", "U", 180],
            [76.655, "MoveYN", 0.586, "R", 0, 310, "outBack"],
            [76.655, "SetDirectionN", 0.586, "R", -1, 1, "outBack"],
            [77.105, "SetHoldRotationN", "R", 180],
            [76.655, "FieldTween", 7.035, "rotationX", 0, -55, "linear"],
            [76.655, "NoteScale", 7.035, 0.7, 0.5, "linear"],
            [76.655, "PlayCharAction", "ScaleSmall"],
            [77.241, "MoveY", 6.448, 310, 370, "inCubic"],
            [78.484, "PlayCharAction", "CastOff"],
            [83.690, "FieldTween", 1.063, "rotationX", -55, 0, "inOutBack"],
            [83.690, "NoteScale", 1.063, 0.5, 0.7, "inOutBack"],
            [83.690, "MoveY", 1.063, 360, 310, "inOutBack"],

            [84.753, "PlayCharAction", "Cast"],
            [84.753, "PlayCharAnimation", "Raise"],
            [84.850, "PlayCharAction", "ScaleNormal"],

            // Flip -> Normal
            [84.948, "MoveY", 0.586, 310, 0, "outBack"],
            [84.948, "SetDirection", 0.586, 1, -1, "outSine"],
            [84.948, "SetHoldRotation", 0],
            [86.021, "FieldTween", 5.772, "rotationX", 0, 45, "linear"],
            [86.021, "NoteScale", 5.772, 0.7, 0.5, "linear"],
            [86.021, "MoveY", 5.772, 0, -50, "inCubic"],
            [88.753, "PlayCharAction", "CastOff"],
            [91.793, "FieldTween", 1.063, "rotationX", 45, 0, "inOutBack"],
            [91.793, "NoteScale", 1.063, 0.5, 0.7, "inOutBack"],
            [91.793, "MoveY", 1.063, -50, 0, "inOutBack"],
            [92.000, "SetNoteskin", 1], // Time - readahead
            [93.045, "PlayCharAnimation", "Idle"],

            // Wall 2
            [94.740, "PlayCharAnimation", "Cast"],
            [94.740, "ConfusionOffset", 0.586, 360, 0, "outSine"],
            [94.740, "MoveXN", 0.586, "L", 0, 19, "outSine"],
            [94.740, "MoveXN", 0.586, "D", 0, 7, "outSine"],
            [94.740, "MoveXN", 0.586, "U", 0, -7, "outSine"],
            [94.740, "MoveXN", 0.586, "R", 0, -19, "outSine"],
            [94.740, "MoveY", 0.586, 0, TIPSY_SYR, "outSine"],
            [94.740, "WallShow"],
            [94.740, "EnableMod", "speed_update"],
            [94.740, "SetSpeed", 0.586, NORMAL_SCROLLSPEED, WALL_SCROLLSPEED, "outSine"],
            [95.326, "FilterMask", true],
            [95.326, "SetDisplacementFilter", "Wall"],
            [95.326, "FlashBang", 1.165],
            [94.387, "PlayCharAnimation", "Idle"],

            // A Slam Center -> Left
            [95.679, "SetTimelineMode", "Relative"],
            [0, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", 19, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 7, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", -7, -190, "outBack"],
            [0, "MoveXN", 0.293, "R", -19, -210, "outBack"],
            [0, "ScreenShakeReduction", SHAKE_REDUCTION_HIGH],
            [0, "ScreenShake", SHAKE_INTENSE_HIGH],
            [0, "PlayCharAnimation", "Swipe"],

            // A Slam Left -> Right
            [0.354, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", -150, 210, "outBack"],
            [0, "MoveXN", 0.293, "D", -170, 190, "outBack"],
            [0, "MoveXN", 0.293, "U", -190, 170, "outBack"],
            [0, "MoveXN", 0.293, "R", -210, 150, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE_HIGH],
            [0, "PlayCharAnimation", "Swipe", -1],

            // A Slam Right -> Left
            [0.354, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", 210, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 190, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", 170, -190, "outBack"],
            [0, "MoveXN", 0.293, "R", 150, -210, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE_HIGH],
            [0, "PlayCharAnimation", "Swipe"],

            // A Reset Left -> Center
            [0.354, "MoveXN", 0.586, "L", -150, 19, "inOutSine"],
            [0, "MoveXN", 0.586, "D", -170, 7, "inOutSine"],
            [0, "MoveXN", 0.586, "U", -190, -7, "inOutSine"],
            [0, "MoveXN", 0.586, "R", -210, -19, "inOutSine"],

            // A Slam Center -> Split
            [0.586, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "PlayCharAnimation", "Idle"],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.146, "MoveXN", 0.293, "L", 19, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 7, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", -7, 170, "outBack"],
            [0, "MoveXN", 0.293, "R", -19, 150, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE_HIGH],
            [0, "PlayCharAnimation", "Push"],

            // Reset -> End
            [0.293, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],

            // A End
            [98.96, "SetTimelineMode", "Relative"],
            [0, "PlayCharAnimation", "Cast"],
            [0, "MoveXN", 0.293, "U", 170, -7, "outBack"],
            [0.146, "MoveXN", 0.293, "L", -150, 19, "outBack"],
            [0.146, "MoveXN", 0.293, "D", -170, 7, "outBack"],
            [0.146, "MoveXN", 0.293, "R", 150, -19, "outBack"],
            [0.136, "SetSpeed", 0.146, WALL_SCROLLSPEED, 0.01, "outSine"],
            [0.010, "MoveY", 0.143, TIPSY_SYR, TIPSY_SYREVERSE, TIPSY_EASE],
            [0.136, "SetSpeed", 0.146, 0.01, WALL_SCROLLSPEED, "outSine"],
            [0.010, "MoveYN", 0.143, "L", TIPSY_SYREVERSE, TIPSY_SYR + 10, TIPSY_EASE],
            [0, "MoveYN", 0.143, "D", TIPSY_SYREVERSE, TIPSY_SYR - 40, TIPSY_EASE],
            [0, "MoveYN", 0.143, "U", TIPSY_SYREVERSE, TIPSY_SYR - 30, TIPSY_EASE],
            [0, "MoveYN", 0.143, "R", TIPSY_SYREVERSE, TIPSY_SYR + 20, TIPSY_EASE],
            [0.136, "MoveYN", 0.143, "L", TIPSY_SYR + 10, TIPSY_SYR, TIPSY_EASE],
            [0, "MoveYN", 0.143, "D", TIPSY_SYR - 40, TIPSY_SYR, TIPSY_EASE],
            [0, "MoveYN", 0.143, "U", TIPSY_SYR - 30, TIPSY_SYR, TIPSY_EASE],
            [0, "MoveYN", 0.143, "R", TIPSY_SYR + 20, TIPSY_SYR, TIPSY_EASE],
            [0, "PlayCharAnimation", "Idle"],

            // B Slam Center -> Left
            [100.362, "SetTimelineMode", "Relative"],
            [0, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", 19, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 7, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", -7, -190, "outBack"],
            [0, "MoveXN", 0.293, "R", -19, -210, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE_HIGH],
            [0, "PlayCharAnimation", "Swipe"],

            // B Slam Left -> Right
            [0.354, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", -150, 210, "outBack"],
            [0, "MoveXN", 0.293, "D", -170, 190, "outBack"],
            [0, "MoveXN", 0.293, "U", -190, 170, "outBack"],
            [0, "MoveXN", 0.293, "R", -210, 150, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE_HIGH],
            [0, "PlayCharAnimation", "Swipe", -1],

            // B Slam Right -> Left
            [0.354, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", 210, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 190, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", 170, -190, "outBack"],
            [0, "MoveXN", 0.293, "R", 150, -210, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE_HIGH],
            [0, "PlayCharAnimation", "Swipe"],

            // B Reset Left -> Center
            [0.354, "MoveXN", 0.586, "L", -150, 19, "inOutSine"],
            [0, "MoveXN", 0.586, "D", -170, 7, "inOutSine"],
            [0, "MoveXN", 0.586, "U", -190, -7, "inOutSine"],
            [0, "MoveXN", 0.586, "R", -210, -19, "inOutSine"],

            // B Slam Center -> Split
            [0.586, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "PlayCharAnimation", "Idle"],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.146, "MoveXN", 0.293, "L", 19, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 7, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", -7, 170, "outBack"],
            [0, "MoveXN", 0.293, "R", -19, 150, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE_HIGH],
            [0, "PlayCharAnimation", "Push"],

            // Reset -> End
            [0.293, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],

            // B End
            [103.582, "SetTimelineMode", "Absolute"],
            [103.582, "PlayCharAnimation", "Cast"],
            [103.582, "MoveXN", 1.536, "L", -150, 19, "outBounce"],
            [103.582, "MoveXN", 1.536, "D", -170, 7, "outBounce"],
            [103.582, "MoveXN", 1.536, "U", 170, -7, "outBounce"],
            [103.582, "MoveXN", 1.536, "R", 150, -19, "outBounce"],
            [103.582, "ConfusionOffsetN", 1.536, "L", -360, 0, "outBounce"],
            [103.582, "ConfusionOffsetN", 1.536, "D", -360, 0, "outBounce"],
            [103.582, "ConfusionOffsetN", 1.536, "U", 360, 0, "outBounce"],
            [103.582, "ConfusionOffsetN", 1.536, "R", 360, 0, "outBounce"],

            // C Slam Center -> Left
            [105.045, "SetTimelineMode", "Relative"],
            [0, "PlayCharAnimation", "Idle"],
            [0, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", 19, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 7, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", -7, -190, "outBack"],
            [0, "MoveXN", 0.293, "R", -19, -210, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE_HIGH],
            [0, "PlayCharAnimation", "Swipe"],

            // C Slam Left -> Right
            [0.354, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", -150, 210, "outBack"],
            [0, "MoveXN", 0.293, "D", -170, 190, "outBack"],
            [0, "MoveXN", 0.293, "U", -190, 170, "outBack"],
            [0, "MoveXN", 0.293, "R", -210, 150, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE_HIGH],
            [0, "PlayCharAnimation", "Swipe", -1],

            // C Slam Right -> Left
            [0.354, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", 210, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 190, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", 170, -190, "outBack"],
            [0, "MoveXN", 0.293, "R", 150, -210, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE_HIGH],
            [0, "PlayCharAnimation", "Swipe"],

            // C Reset Left -> Center
            [0.354, "MoveXN", 0.586, "L", -150, 19, "inOutSine"],
            [0, "MoveXN", 0.586, "D", -170, 7, "inOutSine"],
            [0, "MoveXN", 0.586, "U", -190, -7, "inOutSine"],
            [0, "MoveXN", 0.586, "R", -210, -19, "inOutSine"],

            // C Slam Center -> Split
            [0.586, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "PlayCharAnimation", "Idle"],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.146, "MoveXN", 0.293, "L", 19, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 7, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", -7, 170, "outBack"],
            [0, "MoveXN", 0.293, "R", -19, 150, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE_HIGH],
            [0, "PlayCharAnimation", "Push"],

            // Reset -> End
            [0.293, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],

            // C End
            [108.18, "SetTimelineMode", "Relative"],
            [0, "PlayCharAnimation", "Cast"],
            [0, "MoveXN", 0.293, "U", 170, -7, "outBack"],
            [0.146, "MoveXN", 0.293, "L", -150, 19, "outBack"],
            [0.146, "MoveXN", 0.293, "D", -170, 7, "outBack"],
            [0.146, "MoveXN", 0.293, "R", 150, -19, "outBack"],
            [0.136, "SetSpeed", 0.146, WALL_SCROLLSPEED, 0.01, "outSine"],
            [0.010, "MoveY", 0.143, TIPSY_SYR, TIPSY_SYREVERSE, TIPSY_EASE],
            [0.136, "SetSpeed", 0.146, 0.01, WALL_SCROLLSPEED, "outSine"],
            [0.010, "MoveYN", 0.143, "L", TIPSY_SYREVERSE, TIPSY_SYR + 10, TIPSY_EASE],
            [0, "MoveYN", 0.143, "D", TIPSY_SYREVERSE, TIPSY_SYR - 40, TIPSY_EASE],
            [0, "MoveYN", 0.143, "U", TIPSY_SYREVERSE, TIPSY_SYR - 30, TIPSY_EASE],
            [0, "MoveYN", 0.143, "R", TIPSY_SYREVERSE, TIPSY_SYR + 20, TIPSY_EASE],
            [0.136, "MoveYN", 0.143, "L", TIPSY_SYR + 10, TIPSY_SYR, TIPSY_EASE],
            [0, "MoveYN", 0.143, "D", TIPSY_SYR - 40, TIPSY_SYR, TIPSY_EASE],
            [0, "MoveYN", 0.143, "U", TIPSY_SYR - 30, TIPSY_SYR, TIPSY_EASE],
            [0, "MoveYN", 0.143, "R", TIPSY_SYR + 20, TIPSY_SYR, TIPSY_EASE],
            [0, "PlayCharAnimation", "Idle"],

            // D Slam Center -> Left
            [109.728, "SetTimelineMode", "Relative"],
            [0, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", 19, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 7, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", -7, -190, "outBack"],
            [0, "MoveXN", 0.293, "R", -19, -210, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE_HIGH],
            [0, "PlayCharAnimation", "Swipe"],

            // D Slam Left -> Right
            [0.354, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", -150, 210, "outBack"],
            [0, "MoveXN", 0.293, "D", -170, 190, "outBack"],
            [0, "MoveXN", 0.293, "U", -190, 170, "outBack"],
            [0, "MoveXN", 0.293, "R", -210, 150, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE_HIGH],
            [0, "PlayCharAnimation", "Swipe", -1],

            // D Slam Right -> Left
            [0.354, "MoveYN", 0.146, "L", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0, "MoveYN", 0.146, "D", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "U", TIPSY_SYR, TIPSY_SYE, TIPSY_EASE],
            [0, "MoveYN", 0.146, "R", TIPSY_SYR, TIPSY_SYO, TIPSY_EASE],
            [0.146, "MoveYN", 0.439, "L", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "D", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "U", TIPSY_SYE, TIPSY_SYR, TIPSY_EASE2],
            [0, "MoveYN", 0.439, "R", TIPSY_SYO, TIPSY_SYR, TIPSY_EASE2],
            [0.085, "MoveXN", 0.293, "L", 210, -150, "outBack"],
            [0, "MoveXN", 0.293, "D", 190, -170, "outBack"],
            [0, "MoveXN", 0.293, "U", 170, -190, "outBack"],
            [0, "MoveXN", 0.293, "R", 150, -210, "outBack"],
            [0, "ScreenShake", SHAKE_INTENSE_HIGH],
            [0, "PlayCharAnimation", "Swipe"],

            // D End
            [111.631, "SetTimelineMode", "Absolute"],
            [111.631, "WallHide"],
            [111.631, "FilterVariable", 1, "scaleX", 0, "linear"],
            [111.631, "FilterVariable", 1, "scaleY", 0, "linear"],
            [111.631, "NoteScale", 1.049, 0.7, 0, "outSine"],
            [111.631, "MoveY", 1.049, TIPSY_SYR, 150, "linear"],
            [111.631, "MoveXN", 1.049, "L", -150, 90, "linear"],
            [111.631, "MoveXN", 1.049, "D", -170, 30, "linear"],
            [111.631, "MoveXN", 1.049, "U", -190, -30, "linear"],
            [111.631, "MoveXN", 1.049, "R", -210, -90, "linear"],
            [111.631, "PlayCharAnimation", "Idle"],
            [111.631, "PlayCharAction", "Hide"], // Walls 2 End

            // Final
            [112.801, "FilterMask", false],
            [112.801, "SetDisplacementFilter", ""],
            [112.801, "SetSpeed", 0, WALL_SCROLLSPEED, 0, "linear"],
            [112.801, "ConfusionOffsetN", 1.049, "L", -1167, 0, "outSine"],
            [112.801, "NoteScaleN", 0.658, "L", 0, 5, "outCubic"],
            [113.460, "NoteScaleN", 0.658, "L", 5, 0.7, "inCubic"],

            [114.118, "NoteScaleN", 1, "L", 0.7, 0.7, "linear"],
            [114.118, "MoveYN", 1.049, "L", 150, 127, "outSine"],
            [114.118, "ConfusionOffsetN", 1.049, "L", 0, -90, "outSine"],
            [114.118, "NoteScaleN", 1, "R", 0.7, 0.7, "linear"],
            [114.118, "MoveYN", 1.049, "R", 150, 172, "outSine"],
            [114.118, "ConfusionOffsetN", 1.049, "R", 0, -90, "outSine"]

            ];
    }
}
