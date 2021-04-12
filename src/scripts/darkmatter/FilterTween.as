package scripts.darkmatter
{

    import flash.display.MovieClip;
    import flash.display.DisplayObject;

    public class FilterTween extends BasicTween
    {
        public var applyTo:DisplayObject;
        public var applyArr:Array;

        public function FilterTween(target:*, applied:DisplayObject, prop:String, length:Number, start:Number, end:Number, tween_method:String, curTime:Number = 0):void
        {
            this.applyTo = applied;
            this.applyArr = [target];
            super(target, prop, length, start, end, tween_method, curTime);
        }

        override public function update(delta:Number, eclipsed:Number):void
        {
            time += eclipsed;

            // Complete
            if (time > length)
            {
                target[prop] = endValue;
                applyTo.filters = applyArr;
                _canDestroy = true;
            }
            else
            {
                target[prop] = tween(time, startValue, valueDifference, length);
                applyTo.filters = applyArr;
            }
        }

    }
}
