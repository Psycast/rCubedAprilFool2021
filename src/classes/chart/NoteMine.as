package classes.chart
{

    public class NoteMine
    {
        public var direction:String;
        public var time:Number;
        public var frame:Number;

        /**
         * Defines a new Note object.
         * @param	direction
         * @param	time
         * @param	colour
         * @param	frame
         */
        public function NoteMine(direction:String, time:Number, frame:Number = -1):void
        {
            this.direction = direction;
            this.time = time;
            this.frame = frame;
        }
    }
}
