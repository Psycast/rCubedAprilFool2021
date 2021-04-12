package classes.chart
{

    public class NoteHold
    {
        public var direction:String;
        public var time:Number;
        public var colour:String;
        public var tail:Number;
        public var frame:Number;
        public var frame_tail:Number;

        /**
         * Defines a new Note object.
         * @param	direction
         * @param	time
         * @param	colour
         * @param	frame
         */
        public function NoteHold(direction:String, time:Number, colour:String, tail:Number, frame:Number = -1, frame_tail:Number = -1):void
        {
            this.direction = direction;
            this.time = time;
            this.colour = colour;
            this.tail = tail;
            this.frame = frame;
            this.frame_tail = frame_tail;
        }
    }
}
