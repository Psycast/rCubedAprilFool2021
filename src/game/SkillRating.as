package game
{

    public class SkillRating
    {

        public static const ALPHA:Number = 9.9750396740034;
        public static const BETA:Number = 0.0193296437339205;
        public static const LAMBDA:Number = 18206628.7286425;

        public static const D1:Number = 17678803623.9633;
        public static const D2:Number = 733763392.922176;
        public static const D3:Number = 28163834.4879901;
        public static const D4:Number = -434698.513947563;
        public static const D5:Number = 3060.24243867853;

        static public function getSongWeight(result:GameScoreResult):Number
        {
            return 0;
        }

        static public function getRawGoods(result:Object):Number
        {
            return (result.good) + (result.average * 1.8) + (result.miss * 2.4) + (result.boo * 0.2);
        }

    }
}
