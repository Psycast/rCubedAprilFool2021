package scripts.darkmatter
{
    import scripts.IScriptTickable;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.display.DisplayObjectContainer;

    public class EffectFlashbang implements IScriptTickable
    {
        private var _lifeTime:Number;

        private var runTimer:Number;

        private var overlay:Sprite;

        public function EffectFlashbang(len:Number, par:DisplayObjectContainer, initialTime:Number = 0):void
        {
            _lifeTime = len;
            runTimer = initialTime;

            overlay = new Sprite();
            overlay.graphics.lineStyle(0, 0, 0);
            overlay.graphics.beginFill(0xFFFFFF, 1);
            overlay.graphics.drawRect(0, 0, 780, 480);
            overlay.graphics.endFill();

            par.addChild(overlay);
        }

        public function update(delta:Number, eclipsed:Number):void
        {
            runTimer += eclipsed;
            overlay.alpha = linear(runTimer, 1, -1, _lifeTime);
        }

        public function destroy():void
        {
            overlay.parent.removeChild(overlay);
        }

        public function canDestroy():Boolean
        {
            return runTimer > _lifeTime;
        }

        public function linear(t:Number, b:Number, c:Number, d:Number):Number
        {
            return c * t / d + b
        }
    }
}
