package com.flashfla.utils
{

    public class SoundUtils
    {
        public static function getVolume(val:Number):Number
        {
            var out:Number = Math.round(inSine(val, 0, 1, 1) * 100) / 100;
            out = (val <= 0 ? 0 : (out + 0.01)); // Always 1% volume unless actually 0.
            out = (val >= 1 ? 1 : out);
            return out;
        }

        private static function inSine(t:Number, b:Number, c:Number, d:Number):Number
        {
            return -c * Math.cos(t / d * (Math.PI / 2)) + c + b;
        }
    }
}
