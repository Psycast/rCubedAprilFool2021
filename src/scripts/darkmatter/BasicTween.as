package scripts.darkmatter
{
    import scripts.IScriptTickable;

    public class BasicTween implements IScriptTickable
    {
        public var target:*;
        public var prop:String;
        public var time:Number;
        public var length:Number;
        public var startValue:Number;
        public var endValue:Number;
        public var tween:Function;

        public var valueDifference:Number;

        protected var _canDestroy:Boolean = false;

        public function BasicTween(target:*, prop:String, length:Number, start:Number, end:Number, tween_method:String, curTime:Number = 0):void
        {
            this.target = target;
            this.prop = prop;
            this.time = curTime;
            this.length = length;
            this.startValue = start;
            this.endValue = end;
            this.tween = this[tween_method] as Function;

            this.valueDifference = end - start;
        }

        public function update(delta:Number, eclipsed:Number):void
        {
            time += eclipsed;

            // Complete
            if (time > length)
            {
                target[prop] = endValue;
                _canDestroy = true;
            }
            else
            {
                target[prop] = tween(time, startValue, valueDifference, length);
            }
        }

        public function destroy():void
        {

        }

        public function canDestroy():Boolean
        {
            return _canDestroy;
        }

        ////////////////////////////////////////////////////////////////////////
        /*
           -- For all easing functions:
           -- t = elapsed time
           -- b = begin
           -- c = change == ending - beginning
           -- d = duration (total time)
         */

        public function linear(t:Number, b:Number, c:Number, d:Number):Number
        {
            return c * t / d + b
        }

        public function inQuad(t:Number, b:Number, c:Number, d:Number):Number
        {
            t = t / d
            return c * Math.pow(t, 2) + b
        }

        public function outQuad(t:Number, b:Number, c:Number, d:Number):Number
        {
            t = t / d
            return -c * t * (t - 2) + b
        }

        public function inOutQuad(t:Number, b:Number, c:Number, d:Number):Number
        {
            t = t / d * 2
            if (t < 1)
                return c / 2 * Math.pow(t, 2) + b
            else
                return -c / 2 * ((t - 1) * (t - 3) - 1) + b

        }

        public function outInQuad(t:Number, b:Number, c:Number, d:Number):Number
        {
            if (t < d / 2)
                return outQuad(t * 2, b, c / 2, d)
            else
                return inQuad((t * 2) - d, b + c / 2, c / 2, d)

        }

        public function inCubic(t:Number, b:Number, c:Number, d:Number):Number
        {
            t = t / d
            return c * Math.pow(t, 3) + b
        }

        public function outCubic(t:Number, b:Number, c:Number, d:Number):Number
        {
            t = t / d - 1
            return c * (Math.pow(t, 3) + 1) + b
        }

        public function inOutCubic(t:Number, b:Number, c:Number, d:Number):Number
        {
            t = t / d * 2
            if (t < 1)
            {
                return c / 2 * t * t * t + b
            }
            else
            {
                t = t - 2
                return c / 2 * (t * t * t + 2) + b
            }
        }

        public function outInCubic(t:Number, b:Number, c:Number, d:Number):Number
        {
            if (t < d / 2)
                return outCubic(t * 2, b, c / 2, d)
            else
                return inCubic((t * 2) - d, b + c / 2, c / 2, d)

        }

        public function inQuart(t:Number, b:Number, c:Number, d:Number):Number
        {
            t = t / d
            return c * Math.pow(t, 4) + b
        }

        public function outQuart(t:Number, b:Number, c:Number, d:Number):Number
        {
            t = t / d - 1
            return -c * (Math.pow(t, 4) - 1) + b
        }

        public function inOutQuart(t:Number, b:Number, c:Number, d:Number):Number
        {
            t = t / d * 2
            if (t < 1)
            {
                return c / 2 * Math.pow(t, 4) + b
            }
            else
            {
                t = t - 2
                return -c / 2 * (Math.pow(t, 4) - 2) + b
            }
        }

        public function outInQuart(t:Number, b:Number, c:Number, d:Number):Number
        {
            if (t < d / 2)
                return outQuart(t * 2, b, c / 2, d)
            else
                return inQuart((t * 2) - d, b + c / 2, c / 2, d)
        }

        public function inQuint(t:Number, b:Number, c:Number, d:Number):Number
        {
            t = t / d
            return c * Math.pow(t, 5) + b
        }

        public function outQuint(t:Number, b:Number, c:Number, d:Number):Number
        {
            t = t / d - 1
            return c * (Math.pow(t, 5) + 1) + b
        }

        public function inOutQuint(t:Number, b:Number, c:Number, d:Number):Number
        {
            t = t / d * 2
            if (t < 1)
            {
                return c / 2 * Math.pow(t, 5) + b
            }
            else
            {
                t = t - 2
                return c / 2 * (Math.pow(t, 5) + 2) + b
            }
        }

        public function outInQuint(t:Number, b:Number, c:Number, d:Number):Number
        {
            if (t < d / 2)
                return outQuint(t * 2, b, c / 2, d)
            else
                return inQuint((t * 2) - d, b + c / 2, c / 2, d)

        }

        public function inSine(t:Number, b:Number, c:Number, d:Number):Number
        {
            return -c * Math.cos(t / d * (Math.PI / 2)) + c + b
        }

        public function outSine(t:Number, b:Number, c:Number, d:Number):Number
        {
            return c * Math.sin(t / d * (Math.PI / 2)) + b
        }

        public function inOutSine(t:Number, b:Number, c:Number, d:Number):Number
        {
            return -c / 2 * (Math.cos(Math.PI * t / d) - 1) + b
        }

        public function outInSine(t:Number, b:Number, c:Number, d:Number):Number
        {
            if (t < d / 2)
                return outSine(t * 2, b, c / 2, d)
            else
                return inSine((t * 2) - d, b + c / 2, c / 2, d)

        }

        public function inExpo(t:Number, b:Number, c:Number, d:Number):Number
        {
            if (t == 0)
                return b
            else
                return c * Math.pow(2, 10 * (t / d - 1)) + b - c * 0.001

        }

        public function outExpo(t:Number, b:Number, c:Number, d:Number):Number
        {
            if (t == d)
                return b + c
            else
                return c * 1.001 * (-Math.pow(2, -10 * t / d) + 1) + b

        }

        public function inOutExpo(t:Number, b:Number, c:Number, d:Number):Number
        {
            if (t == 0)
            {
                return b
            }
            if (t == d)
            {
                return b + c
            }
            t = t / d * 2
            if (t < 1)
            {
                return c / 2 * Math.pow(2, 10 * (t - 1)) + b - c * 0.0005
            }
            else
            {
                t = t - 1
                return c / 2 * 1.0005 * (-Math.pow(2, -10 * t) + 2) + b
            }
        }

        public function outInExpo(t:Number, b:Number, c:Number, d:Number):Number
        {
            if (t < d / 2)
                return outExpo(t * 2, b, c / 2, d)
            else
                return inExpo((t * 2) - d, b + c / 2, c / 2, d)

        }

        public function inCirc(t:Number, b:Number, c:Number, d:Number):Number
        {
            t = t / d
            return (-c * (Math.sqrt(1 - Math.pow(t, 2)) - 1) + b)
        }

        public function outCirc(t:Number, b:Number, c:Number, d:Number):Number
        {
            t = t / d - 1
            return (c * Math.sqrt(1 - Math.pow(t, 2)) + b)
        }

        public function inOutCirc(t:Number, b:Number, c:Number, d:Number):Number
        {
            t = t / d * 2
            if (t < 1)
            {
                return -c / 2 * (Math.sqrt(1 - t * t) - 1) + b
            }
            else
            {
                t = t - 2
                return c / 2 * (Math.sqrt(1 - t * t) + 1) + b
            }
        }

        public function outInCirc(t:Number, b:Number, c:Number, d:Number):Number
        {
            if (t < d / 2)
                return outCirc(t * 2, b, c / 2, d)
            else
                return inCirc((t * 2) - d, b + c / 2, c / 2, d)

        }

        public function inElastic(t:Number, b:Number, c:Number, d:Number, a:Number, p:Number = NaN):Number
        {
            if (t == 0)
            {
                return b
            }

            t = t / d

            if (t == 1)
            {
                return b + c
            }

            if (isNaN(p))
            {
                p = d * 0.3
            }

            var s:Number;

            if (!a || a < Math.abs(c))
            {
                a = c
                s = p / 4
            }
            else
            {
                s = p / (2 * Math.PI) * Math.asin(c / a)
            }

            t = t - 1

            return -(a * Math.pow(2, 10 * t) * Math.sin((t * d - s) * (2 * Math.PI) / p)) + b
        }

        //-- a: amplitud
        //-- p: period
        public function outElastic(t:Number, b:Number, c:Number, d:Number, a:Number = NaN, p:Number = NaN):Number
        {
            if (t == 0)
            {
                return b
            }

            t = t / d

            if (t == 1)
            {
                return b + c
            }

            if (isNaN(p))
            {
                p = d * 0.3
            }

            var s:Number;

            if (isNaN(a) || a < Math.abs(c))
            {
                a = c
                s = p / 4
            }
            else
            {
                s = p / (2 * Math.PI) * Math.asin(c / a)
            }

            return a * Math.pow(2, -10 * t) * Math.sin((t * d - s) * (2 * Math.PI) / p) + c + b
        }

        //-- p = period
        //-- a = amplitud
        public function inOutElastic(t:Number, b:Number, c:Number, d:Number, a:Number = NaN, p:Number = NaN):Number
        {
            if (t == 0)
            {
                return b
            }

            t = t / d * 2

            if (t == 2)
            {
                return b + c
            }

            if (isNaN(p))
            {
                p = d * (0.3 * 1.5)
            }
            if (isNaN(a))
            {
                a = 0
            }

            var s:Number;

            if (isNaN(a) || a < Math.abs(c))
            {
                a = c
                s = p / 4
            }
            else
            {
                s = p / (2 * Math.PI) * Math.asin(c / a)
            }

            if (t < 1)
            {
                t = t - 1
                return -0.5 * (a * Math.pow(2, 10 * t) * Math.sin((t * d - s) * (2 * Math.PI) / p)) + b
            }
            else
            {
                t = t - 1
                return a * Math.pow(2, -10 * t) * Math.sin((t * d - s) * (2 * Math.PI) / p) * 0.5 + c + b
            }
        }

        //-- a: amplitud
        //-- p: period
        public function outInElastic(t:Number, b:Number, c:Number, d:Number, a:Number = NaN, p:Number = NaN):Number
        {
            if (t < d / 2)
                return outElastic(t * 2, b, c / 2, d, a, p)
            else
                return inElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
        }

        public function inBack(t:Number, b:Number, c:Number, d:Number, s:Number = 1.70158):Number
        {
            t = t / d
            return c * t * t * ((s + 1) * t - s) + b
        }

        public function outBack(t:Number, b:Number, c:Number, d:Number, s:Number = 1.70158):Number
        {
            t = t / d - 1
            return c * (t * t * ((s + 1) * t + s) + 1) + b
        }

        public function inOutBack(t:Number, b:Number, c:Number, d:Number, s:Number = 1.70158):Number
        {
            s = s * 1.525
            t = t / d * 2
            if (t < 1)
            {
                return c / 2 * (t * t * ((s + 1) * t - s)) + b
            }
            else
            {
                t = t - 2
                return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
            }
        }

        public function outInBack(t:Number, b:Number, c:Number, d:Number, s:Number = 1.70158):Number
        {
            if (t < d / 2)
                return outBack(t * 2, b, c / 2, d, s)
            else
                return inBack((t * 2) - d, b + c / 2, c / 2, d, s)
        }

        public function outBounce(t:Number, b:Number, c:Number, d:Number):Number
        {
            t = t / d
            if (t < 1 / 2.75)
            {
                return c * (7.5625 * t * t) + b
            }
            else if (t < 2 / 2.75)
            {
                t = t - (1.5 / 2.75)
                return c * (7.5625 * t * t + 0.75) + b
            }
            else if (t < 2.5 / 2.75)
            {
                t = t - (2.25 / 2.75)
                return c * (7.5625 * t * t + 0.9375) + b
            }
            else
            {
                t = t - (2.625 / 2.75)
                return c * (7.5625 * t * t + 0.984375) + b
            }
        }

        public function inBounce(t:Number, b:Number, c:Number, d:Number):Number
        {
            return c - outBounce(d - t, 0, c, d) + b
        }

        public function inOutBounce(t:Number, b:Number, c:Number, d:Number):Number
        {
            if (t < d / 2)
                return inBounce(t * 2, 0, c, d) * 0.5 + b
            else
                return outBounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
        }

        public function outInBounce(t:Number, b:Number, c:Number, d:Number):Number
        {
            if (t < d / 2)
                return outBounce(t * 2, b, c / 2, d)
            else
                return inBounce((t * 2) - d, b + c / 2, c / 2, d)
        }
    }
}
