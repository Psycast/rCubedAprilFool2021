package popups
{
    import classes.ui.Text;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.MouseEvent;

    public class FileBrowserItem extends Sprite
    {
        public static const FIXED_WIDTH:int = 500;
        public static const FIXED_HEIGHT:int = 28;

        /** Index in Vector */
        public var index:int = 0;

        /** Marks the Button as in-use to avoid removal in song selector. */
        public var garbageSweep:Boolean = false;

        public var songData:Object;

        private var _over:Boolean = false;
        private var _highlight:Boolean = false;

        private var _lblSongName:Text;

        public function FileBrowserItem(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
        {
            tabChildren = tabEnabled = false;

            this.x = xpos;
            this.y = ypos;

            this.buttonMode = true;
            this.useHandCursor = true;
            this.mouseChildren = false;

            if (parent != null)
            {
                parent.addChild(this);
            }

            _lblSongName = new Text(this, 5, 6, "--");
            _lblSongName.setAreaParams(FIXED_WIDTH - 10, 14);
            drawBox();

            addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
        }

        /**
         * Draws the background rectangle.
         */
        public function drawBox():void
        {
            //- Draw Box
            this.graphics.clear();
            this.graphics.lineStyle(1, 0xFFFFFF, (highlight ? 0.8 : 0.55));
            this.graphics.beginFill(0x000000, (highlight ? 0.25 : 0.15));
            this.graphics.drawRect(0, 0, FIXED_WIDTH, FIXED_HEIGHT);
            this.graphics.endFill();
        }

        ///////////////////////////////////
        // public methods
        ///////////////////////////////////

        public function setData(songData:Object):void
        {
            this.songData = songData;
            _lblSongName.text = "[" + songData.author + "] " + songData.name;
        }

        ///////////////////////////////////
        // event handlers
        ///////////////////////////////////

        /**
         * Internal mouseOver handler.
         * @param event The MouseEvent passed by the system.
         */
        protected function onMouseOver(event:MouseEvent):void
        {
            _over = true;
            addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
            drawBox();
        }

        /**
         * Internal mouseOut handler.
         * @param event The MouseEvent passed by the system.
         */
        protected function onMouseOut(event:MouseEvent):void
        {
            _over = false;
            removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
            drawBox();
        }

        ///////////////////////////////////
        // getter/setters
        ///////////////////////////////////
        public function get highlight():Boolean
        {
            return _highlight || _over;
        }

        public function set highlight(val:Boolean):void
        {
            _highlight = val;
            drawBox();
        }
    }
}
