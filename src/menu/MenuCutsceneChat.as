package menu
{
    import flash.text.TextFormat;
    import flash.text.TextField;
    import flash.text.AntiAliasType;
    import flash.display.Sprite;
    import scripts.IScriptTickable;
    import flash.geom.Point;
    import flash.text.TextFieldAutoSize;
    import flash.media.SoundChannel;

    public class MenuCutsceneChat extends Sprite implements IScriptTickable
    {
        private var cutscene:MenuCutscene;

        public static var ITEMS:Array = [];

        public var T:Number = 0;
        private var _fullText:String = "";
        public var currentChar:int = 0;
        public var voice:String = "";
        public var timeout:Number = 0;
        public var TEXT_SPEED:Number = 0.033;

        public var avatarIndex:int = -1;

        private var voiceAudio:SoundChannel;

        public var endFunc:String = "";

        public var _field:TextField;
        public var _fieldBounds:Point = new Point(0, 0);

        public function MenuCutsceneChat(cutscene:MenuCutscene, font:TextFormat, speedModifier:Number = 1):void
        {
            this.cutscene = cutscene;

            TEXT_SPEED /= speedModifier;

            font.leading = -2;

            _field = new TextField();
            _field.embedFonts = true;
            //_field.wordWrap = true;
            _field.multiline = true;
            _field.antiAliasType = AntiAliasType.ADVANCED;
            _field.embedFonts = true;
            _field.defaultTextFormat = font;
            _field.gridFitType = "pixel";
            _field.autoSize = "left"; //TextFieldAutoSize.CENTER;
            //_field.sharpness = 400;
            //_field.thickness = 50;
            _field.selectable = false;
            //_field.border = true;
            //_field.borderColor = 0xff0000;
            addChild(_field);

            ITEMS[ITEMS.length] = this;
        }

        public function get fullText():String
        {
            return _fullText;
        }

        public function set fullText(str:String):void
        {
            _fullText = str;

            // Get Full Bounds
            var curText:String = _field.htmlText;

            _field.htmlText = str;
            _fieldBounds.x = _field.textWidth;
            _fieldBounds.y = _field.textHeight;
            _field.htmlText = curText;

            _field.x = 327 - (_fieldBounds.x / 2);
            _field.y = 30 - (_fieldBounds.y / 2);
        }

        public function get text():String
        {
            return _field.htmlText;
        }

        public function set text(str:String):void
        {
            _field.htmlText = str;
        }

        public function setSize(w:int, h:int):void
        {
            _field.width = w;
            _field.height = h;
        }

        public function update(delta:Number, eclipsed:Number):void
        {
            T += eclipsed;

            // Update Per Character
            while (currentChar < fullText.length && T > TEXT_SPEED)
            {
                T -= TEXT_SPEED;
                currentChar++;
                text = fullText.substr(0, currentChar);

                if (voice != "")
                {
                    if (voiceAudio == null)
                    {
                        voiceAudio = AudioManager.playSound(voice, true);
                    }
                }
            }

            if (currentChar == fullText.length)
            {
                timeout -= Math.min(eclipsed, timeout);
                if (voiceAudio != null)
                {
                    if (avatarIndex >= 0)
                        cutscene.avatars[avatarIndex].ChatFinish();
                    voiceAudio.stop();
                    voiceAudio = null;
                }
                if (timeout <= 0)
                {
                    if (endFunc != "")
                    {
                        cutscene[endFunc]();
                        endFunc = "";
                    }
                }
            }
        }

        public function destroy():void
        {
            var i:int = ITEMS.indexOf(this);
            ITEMS.splice(i, 1);

            if (endFunc != "")
                cutscene[endFunc]();
        }

        public static function clear():void
        {
            for (var i:int = ITEMS.length - 1; i >= 0; i--)
                ITEMS[i].cutscene.RemoveTickable(ITEMS[i]);
            ITEMS = [];
        }

        public function canDestroy():Boolean
        {
            return false;
        }
    }
}
