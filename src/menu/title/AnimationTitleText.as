package menu.title
{
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.AntiAliasType;
    import flash.text.GridFitType;
    import flash.text.TextFormat;
    import scripts.IScriptTickable;

    public class AnimationTitleText extends Sprite implements IScriptTickable
    {
        private var _message:String;
        private var _textTF:TextField;

        private var _y:Number = 0;

        private var STATE:int = 0;

        private var T:Number = 0;

        private var HOLD:Number = 3;

        public function AnimationTitleText(par:TitleSplash, msg:String, xpo:Number, ypo:Number, fontSize:Number, holdTime:Number = 3, align:String = "left"):void
        {
            par.addChild(this);

            this.x = xpo;
            this.y = ypo + 50;
            this._y = ypo;
            this.alpha = 0;

            this.HOLD = holdTime;

            this.mouseChildren = false;
            this.mouseEnabled = false;

            // Build Text
            _textTF = new TextField();
            _textTF.selectable = false;
            _textTF.embedFonts = true;
            _textTF.antiAliasType = AntiAliasType.ADVANCED;
            _textTF.gridFitType = GridFitType.PIXEL;
            _textTF.width = 740;
            //_textTF.border = true;
            //_textTF.borderColor = 0xff0000;
            _textTF.defaultTextFormat = new TextFormat(Constant.TEXT_FORMAT.font, fontSize, 0xFFFFFF, null, null, null, null, null, align);
            _textTF.text = msg;
            this.addChild(_textTF);
        }

        public function update(delta:Number, eclipsed:Number):void
        {
            T += eclipsed;

            // Fade In
            if (STATE == 0)
            {
                this.alpha = outQuad(T, 0, 1, 1);
                this.y = outQuad(T, _y + 50, -50, 1);
                if (T >= 1)
                {
                    STATE = 1;
                    T -= 1;
                }
            }
            // Hold
            else if (STATE == 1)
            {
                if (T >= this.HOLD)
                {
                    STATE = 2;
                    T -= this.HOLD;
                }
            }
            // Fade Out
            else if (STATE == 2)
            {
                this.alpha = inQuad(T, 1, -1, 1);
                this.y = inQuad(T, _y, 50, 1);
                if (T >= 1)
                {
                    STATE = 3;
                    T -= 1;
                }
            }
        }

        public function destroy():void
        {
            _textTF = null;
        }

        public function canDestroy():Boolean
        {
            return STATE == 3;
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
    }
}
