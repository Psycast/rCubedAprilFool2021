package popups
{
    import classes.ui.ScrollBar;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.geom.Rectangle;

    public class ListFileBrowser extends Sprite
    {
        private var _pane:Sprite;

        private var _width:Number = 772;
        private var _height:Number = 439;

        private var _vscroll:ScrollBar;
        private var songButtons:Vector.<FileBrowserItem> = new Vector.<FileBrowserItem>();
        private var renderElements:Vector.<Object>;
        private var renderCount:int = 0;

        private var _scrollY:Number = 0;
        private var _calcHeight:int = 0;

        private var _selectedSongData:Object;

        public function ListFileBrowser(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
        {
            tabChildren = tabEnabled = false;

            this.x = xpos;
            this.y = ypos;

            if (parent != null)
            {
                parent.addChild(this);
            }

            addChildren();
        }

        public function addChildren():void
        {
            _pane = new Sprite();
            _pane.addEventListener(MouseEvent.MOUSE_WHEEL, e_scrollWheel);
            addChild(_pane);

            _vscroll = new ScrollBar(this, _width - 27, 1, 26, _height - 2, null, null, e_scrollVerticalUpdate);

            draw();

            scrollRect = new Rectangle(0, 0, _width, _height);
        }

        public function draw():void
        {
            _pane.graphics.clear();
            _pane.graphics.beginFill(0x000000, 0);
            _pane.graphics.drawRect(0, 0, _width, _height);
            _pane.graphics.endFill();
        }


        /**
         * Sets the data for the Song Selector to use as a reference for drawing.
         * @param list Array on EngineLevel Items to use.
         */
        public function setRenderList(list:Array):void
        {
            clearButtons(true);

            var i:int;

            renderCount = list.length;

            _scrollY = 0;
            _calcHeight = (Math.ceil(renderCount) * (5 + FileBrowserItem.FIXED_HEIGHT));
            //_vscroll.scrollFactor = scrollFactorVertical;
            _vscroll.visible = doScroll;

            renderElements = new Vector.<Object>(renderCount, true);
            for (i = 0; i < list.length; i++)
                renderElements[i] = list[i];

            updateChildrenVisibility();
        }


        /**
         * Creates and Removes Song Buttons from the stage, depending on the scroll position.
         * This method uses Pooling on Song Buttons to minimize the amount of SongButtons
         * created on screen.
         */
        public function updateChildrenVisibility():void
        {
            if (renderElements == null || renderElements.length == 0)
                return;

            var i:int;

            var songButton:FileBrowserItem;
            var _y:Number;
            var _inBounds:Boolean;
            var songObject:Object;

            var GAP:int = (FileBrowserItem.FIXED_HEIGHT + 5);
            var startingIndex:int = int(Math.max(0, Math.floor((_scrollY * -1) / GAP) - 1));
            var lastIndex:int = Math.min(renderCount, startingIndex + (Math.ceil(_height / GAP)) + 4);
            var START_POINT:int = _scrollY;

            // Update Existing
            var len:int = songButtons.length - 1;
            for (i = len; i >= 0; i--)
            {
                songButton = songButtons[i];
                songButton.garbageSweep = false;

                _y = START_POINT + int(songButton.index) * GAP;
                _inBounds = (_y > -GAP && _y < _height);

                // Unlink SongButton no longer on stage.
                if (!_inBounds)
                    removeSongButton(songButton);

                // Update Position
                else
                    moveSongButton(_y, songButton);
            }

            // Add New Song Buttons
            for (i = startingIndex; i < lastIndex; i++)
            {
                songObject = renderElements[i];

                // Check for Existing Button
                if (findSongButton(songObject) != null)
                    continue;

                // Create Song Button
                _y = START_POINT + i * GAP;
                _inBounds = (_y > -GAP && _y < height);

                if (_inBounds)
                {
                    songButton = getSongButton();
                    songButton.index = i;
                    songButton.setData(songObject);
                    _pane.addChild(songButton);
                    moveSongButton(_y, songButton);
                    songButtons[songButtons.length] = songButton;
                }
            }

            // Remove Old Song Buttons
            len = songButtons.length - 1;
            for (i = len; i >= 0; i--)
            {
                songButton = songButtons[i];
                if (songButton.garbageSweep == false)
                    removeSongButton(songButton);
            }
        }

        /**
         * Moves the SongButton to the y value. Also marks the song button
         * as in use for the removal sweep.
         * @param _y
         * @param btn
         */
        public function moveSongButton(_y:int, btn:FileBrowserItem):void
        {
            btn.y = _y;
            btn.garbageSweep = true;
        }

        /**
         * Finds the on stage SongButton for the given EngineLevel.
         * @param level EngineLevel to look for.
         * @return If a SongButton exist already for this level.
         */
        public function findSongButton(level:Object):FileBrowserItem
        {
            if (songButtons.length == 0)
                return null;

            var len:int = songButtons.length - 1;
            for (; len >= 0; len--)
            {
                if (songButtons[len].songData === level)
                    return songButtons[len];
            }
            return null;
        }

        /**
         * Removes the SongButton from stage, along with moving it
         * back into the object pool.
         * @param btn SongButton to remove.
         */
        public function removeSongButton(btn:FileBrowserItem):void
        {
            var idx:int = songButtons.indexOf(btn);
            if (idx >= 0)
                songButtons.splice(idx, 1);

            btn.parent.removeChild(btn);
            putSongButton(btn);
        }

        /**
         * Clears the component of old data.
         */
        public function clear():void
        {
            clearButtons();

            renderCount = 0;
            renderElements = null;
            _calcHeight = 0;
            _vscroll.visible = false;
            _vscroll.scrollTo(0, false);
        }

        /**
         * Removes all SongButtons from the stage.
         * @param force Force Remove, regardless of sweep value.
         */
        public function clearButtons(force:Boolean = false):void
        {
            var songButton:FileBrowserItem;

            // Remove Old Song Buttons
            var len:int = songButtons.length - 1;
            for (; len >= 0; len--)
            {
                songButton = songButtons[len];
                if (songButton.garbageSweep == false || force)
                    removeSongButton(songButton);
            }
        }

        /**
         * Resets the scroll back to 0;
         */
        public function scrollReset():void
        {
            _vscroll.scrollTo(0, false);
        }

        /**
         * Check the requirement if scrolling should happen.
         * @return
         */
        public function get doScroll():Boolean
        {
            return _calcHeight > _height;
        }

        /**
         * Gets the current vertical scroll factor.
         * Scroll factor is the percent of the height the scrollpane is compared to the overall content height.
         */
        public function get scrollFactorVertical():Number
        {
            return Math.max(Math.min(_height / _calcHeight, 1), 0) || 0;
        }

        public function set scrollVertical(val:Number):void
        {
            _scrollY = -((_calcHeight - _height) * Math.max(Math.min(val, 1), 0));
            updateChildrenVisibility();
        }

        private function e_scrollWheel(e:MouseEvent):void
        {
            if (doScroll)
            {
                _vscroll.scrollTo(_vscroll.scroll + (scrollFactorVertical / 2) * (e.delta > 1 ? -1 : 1), false);
                scrollVertical = _vscroll.scroll;
            }
        }

        private function e_scrollVerticalUpdate(e:Event):void
        {
            scrollVertical = _vscroll.scroll;
        }


        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        /** SongButton Pool Vector */
        private static var __vectorSongButton:Vector.<FileBrowserItem> = new Vector.<FileBrowserItem>();

        /** Retrieves a SongButton instance from the pool. */
        public static function getSongButton():FileBrowserItem
        {
            if (__vectorSongButton.length == 0)
                return new FileBrowserItem();
            else
                return __vectorSongButton.pop();
        }

        /** Stores a SongButton instance in the pool.
         *  Don't keep any references to the object after moving it to the pool! */
        public static function putSongButton(songbutton:FileBrowserItem):void
        {
            if (songbutton)
            {
                songbutton.highlight = false;
                __vectorSongButton[__vectorSongButton.length] = songbutton;
            }
        }
    }
}
