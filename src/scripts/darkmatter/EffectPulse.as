package scripts.darkmatter
{
    import scripts.IScriptTickable;
    import game.controls.NoteBox;
    import flash.display.MovieClip;

    public class EffectPulse implements IScriptTickable
    {
        public var loop:Number = 0;

        public var _lifeTime:Number = 0;
        public var _loopTime:Number = 0;

        public var runTimer:Number = 0;
        public var loopTimer:Number = 0;

        public var recp:Vector.<MovieClip>;

        public function EffectPulse(target:NoteBox, lifeTime:Number, loopTime:Number, initialOffset:Number = 0)
        {
            _lifeTime = lifeTime;
            _loopTime = loopTime;
            runTimer += (initialOffset / 1000);

            recp = new <MovieClip>[target.getReceptor("L"), target.getReceptor("D"), target.getReceptor("U"), target.getReceptor("R")];
            recp.fixed = true;
        }

        private var pulseInTimer:Number;
        private var pulseOutTimer:Number;
        private var recpI:int;

        public function update(delta:Number, eclipsed:Number):void
        {
            runTimer += eclipsed;
            loopTimer += eclipsed;

            if (loopTimer > _loopTime)
            {
                loopTimer -= _loopTime;
                loop++;
            }

            pulseOutTimer = (_loopTime * 0.8);
            pulseInTimer = _loopTime - pulseOutTimer;
            recpI = recp.length - 1;

            // Pulse Out
            if (loopTimer < pulseOutTimer)
            {
                for (; recpI >= 0; recpI--)
                {
                    recp[recpI].rotation = recp[recpI].ORIG_ROT + (90 * loop) + outSine(loopTimer, 0, 90, pulseOutTimer);
                    recp[recpI].scaleX = recp[recpI].scaleY = outSine(loopTimer, 1.3, -0.6, pulseOutTimer); // 2x -> 1x
                }
            }
            // Pulse In
            else
            {
                for (; recpI >= 0; recpI--)
                {
                    recp[recpI].rotation = recp[recpI].ORIG_ROT + (90 * (loop + 1));
                    recp[recpI].scaleX = recp[recpI].scaleY = inSine(loopTimer - pulseOutTimer, 0.7, 0.6, pulseInTimer); // 1x -> 2x
                }
            }

        /*
           0 speed*0.8 rotate 0 90 outSine		// 0 + (iterations * 90) = Final
           0 speed*0.8 notescale 2 1 outSine
           speed*0.8 speed*0.2 notescale 1 2 inSine
         */
        }

        public function destroy():void
        {

        }

        public function canDestroy():Boolean
        {
            return runTimer > _lifeTime;
        }


        /*
           -- For all easing functions:
           -- t = elapsed time
           -- b = begin
           -- c = change == ending - beginning
           -- d = duration (total time)
         */

        public function inSine(t:Number, b:Number, c:Number, d:Number):Number
        {
            return -c * Math.cos(t / d * (Math.PI / 2)) + c + b
        }

        public function outSine(t:Number, b:Number, c:Number, d:Number):Number
        {
            return c * Math.sin(t / d * (Math.PI / 2)) + b
        }

    }
}
