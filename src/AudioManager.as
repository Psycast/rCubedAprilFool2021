package
{
    import flash.media.SoundChannel;
    import flash.utils.getDefinitionByName;
    import flash.media.Sound;
    import af.assets.snd_nav_left;
    import af.assets.snd_nav_right;
    import af.assets.snd_diff_down;
    import af.assets.snd_diff_up;
    import af.assets.snd_nav_select;
    import af.assets.snd_bomb;
    import af.assets.snd_txtasr;
    import af.assets.snd_txttem;
    import af.assets.snd_txtvel;
    import af.assets.snd_txtgol;
    import af.assets.snd_txtcos;
    import af.assets.snd_txthi;
    import af.assets.snd_txthal;

    public class AudioManager
    {
        private static var cache:Object = {};

        // Import
        snd_nav_left;
        snd_nav_right;
        snd_diff_down;
        snd_diff_up;
        snd_nav_select;

        snd_bomb;

        snd_txtasr;
        snd_txtvel;
        snd_txttem;
        snd_txtgol;
        snd_txtcos;
        snd_txthi;
        snd_txthal;

        public static function playSound(key:String, doLoop:Boolean = false):SoundChannel
        {
            if (cache[key] == null)
            {
                var pA:Class = getDefinitionByName("af.assets::snd_" + key) as Class;
                var snd:Sound = new pA();
                cache[key] = snd;
            }

            var sndChannel:SoundChannel = (cache[key] as Sound).play(0, doLoop ? 1000 : 0);

            return sndChannel;
        }
    }
}
