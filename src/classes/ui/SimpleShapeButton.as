package classes.ui
{
    import flash.display.Sprite;
    import flash.events.MouseEvent;

    public class SimpleShapeButton extends Sprite
    {
        private var _commands:Vector.<int>;
        private var _data:Vector.<Number>;

        public function SimpleShapeButton(commands:Vector.<int>, data:Vector.<Number>)
        {
            super();

            _commands = commands;
            _data = data;

            drawBox(false);

            this.mouseChildren = false;
            this.tabEnabled = false;
            this.useHandCursor = true;
            this.buttonMode = true;

            addEventListener(MouseEvent.MOUSE_OVER, e_mouseOver);
        }

        private function e_mouseOver(e:MouseEvent):void
        {
            addEventListener(MouseEvent.MOUSE_OUT, e_mouseOut);
            drawBox(true);
        }

        private function e_mouseOut(e:MouseEvent):void
        {
            removeEventListener(MouseEvent.MOUSE_OUT, e_mouseOut);
            drawBox(false);
        }

        private function drawBox(doHover:Boolean):void
        {
            graphics.clear();
            graphics.lineStyle(0, 0, 0);
            graphics.beginFill(0xffffff, doHover ? 0.2 : 0);
            graphics.drawPath(_commands, _data);
            graphics.endFill();
        }

    }

}
