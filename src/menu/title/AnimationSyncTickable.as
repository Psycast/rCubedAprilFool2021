package menu.title
{
    import scripts.IScriptTickable;
    import flash.display.MovieClip;

    public class AnimationSyncTickable implements IScriptTickable
    {
        public var target:MovieClip;
        public var T:Number = 0;
        public var lastFrame:int = 1;

        public function AnimationSyncTickable(syncTarget:MovieClip):void
        {
            target = syncTarget;
        }

        public function update(delta:Number, eclipsed:Number):void
        {
            if (canDestroy())
                return;

            T += eclipsed;

            lastFrame = Math.min(target.totalFrames, (T * 45) + 1); // Should be 60 since 60fps but I wanted the animation to go slightly slower.

            target.gotoAndStop(lastFrame)
        }

        public function destroy():void
        {
            target.gotoAndStop(target.totalFrames);
        }

        public function canDestroy():Boolean
        {
            return lastFrame >= target.totalFrames;
        }
    }
}
