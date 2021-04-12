package scripts.darkmatter
{
    import af.assets.DM.CharCast;
    import af.assets.DM.CharCastTriangle;
    import af.assets.DM.CharKarhis;
    import af.assets.DM.CharKarhisAttacks;
    import flash.display.Sprite;
    import scripts.IScriptTickable;

    public class CharKarhisLogic extends Sprite implements IScriptTickable
    {
        public var STATE:String = "";

        public var returnX:Number = 0;
        public var returnY:Number = 0;

        public var bob_timer:Number = 0;
        public var bob_y:Number = 0;
        public var bob_scalex:Number = 0;
        public var bob_scaley:Number = 0;

        public var karhis:CharKarhis;
        public var castBackground:CharCast;
        public var overlayAnimation:CharKarhisAttacks;

        public var castTriangles:Vector.<CharCastTriangle> = new <CharCastTriangle>[];
        public var charCastTriangleSpeed:Vector.<Number> = new <Number>[70, -110, -190, 160, 280];

        public var showCircle:Boolean = false;

        public function CharKarhisLogic():void
        {
            charCastTriangleSpeed.fixed = true;

            castBackground = new CharCast();
            castBackground.alpha = 0;
            castBackground.scaleX = castBackground.scaleY = 1.2;
            addChild(castBackground);

            for (var i:int = 0; i < charCastTriangleSpeed.length; i++)
            {
                var castTri:CharCastTriangle = new CharCastTriangle();
                castTri.rotation = Math.random() * 360;
                castTri.scaleY = 0.6 + (Math.random() * 0.4);
                castTri.alpha = 0;
                addChild(castTri);
                castTriangles.push(castTri);
            }

            karhis = new CharKarhis();
            karhis.gotoAndStop("Idle");
            addChild(karhis);

            overlayAnimation = new CharKarhisAttacks();
            overlayAnimation.gotoAndStop("Idle");
            addChild(overlayAnimation);
        }

        public function UpdateHome():void
        {
            returnX = this.x;
            returnY = this.y;
        }

        public function CastCircle(val:Boolean):void
        {
            showCircle = val;
        }

        public function PlayAnimation(cmd:String, scaleX:Number = 1):void
        {
            STATE = cmd;
            karhis.gotoAndStop(cmd);
            overlayAnimation.gotoAndStop(cmd);
            overlayAnimation.alpha = 1;

            this.scaleX = scaleX;
        }

        public function update(delta:Number, eclipsed:Number):void
        {
            bob_timer += eclipsed;
            bob_y = Math.sin(bob_timer / 2) * 6;
            bob_scalex = 0.8 + Math.sin(bob_timer * 2.4) * 0.020;
            bob_scaley = 0.8 + Math.sin(bob_timer * 2.4) * 0.025;

            // Cast Background
            var i:int;
            if (castBackground.alpha > 0)
            {
                castBackground.rotation += 10 * eclipsed;
                for (i = 0; i < charCastTriangleSpeed.length; i++)
                    castTriangles[i].rotation += charCastTriangleSpeed[i] * eclipsed;
            }

            if (showCircle)
            {
                if (castBackground.alpha < 1)
                {
                    castBackground.alpha = Math.min(1, castBackground.alpha + 2 * eclipsed);
                    for (i = 0; i < charCastTriangleSpeed.length; i++)
                        castTriangles[i].alpha = Math.min(0.4, castTriangles[i].alpha + 2 * eclipsed);
                }
            }
            else
            {
                if (castBackground.alpha > 0)
                {
                    castBackground.alpha = Math.max(0, castBackground.alpha - 2 * eclipsed);
                    for (i = 0; i < charCastTriangleSpeed.length; i++)
                        castTriangles[i].alpha = Math.max(0, castTriangles[i].alpha - 2 * eclipsed);
                }
            }

            // Overlay
            if (overlayAnimation != null && overlayAnimation.alpha > 0)
            {
                overlayAnimation.alpha = Math.max(0, overlayAnimation.alpha - 1 * eclipsed);
                overlayAnimation.scaleX = bob_scalex;
                overlayAnimation.scaleX = bob_scaley;
            }

            karhis.scaleX = bob_scalex;
            karhis.scaleY = bob_scaley;

            this.y = returnY + bob_y;
        }

        public function destroy():void
        {

        }

        public function canDestroy():Boolean
        {
            return false;
        }
    }
}
