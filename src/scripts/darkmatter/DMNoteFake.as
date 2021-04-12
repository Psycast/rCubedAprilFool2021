package scripts.darkmatter
{
    import flash.display.Sprite;
    import flash.display.Bitmap;
    import af.assets.DM.NoteFakeSprite;

    public class DMNoteFake extends Sprite
    {
        public var spr:NoteFakeSprite;

        public var ROTATION_RESET:Number = 0;

        public function DMNoteFake(rot:Number):void
        {
            spr = new NoteFakeSprite();
            spr.rotation = rot;
            ROTATION_RESET = rot;
            addChild(spr);
        }
    }

}
