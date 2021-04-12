package popups
{
    import assets.GameBackgroundColor;
    import classes.Language;
    import classes.ui.Box;
    import classes.ui.BoxButton;
    import com.greensock.TweenLite;
    import com.greensock.easing.Back;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.filters.BlurFilter;
    import flash.geom.Point;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;

    import menu.MenuPanel;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    public class PopupSecretFind extends MenuPanel
    {
        private var _lang:Language = Language.instance;
        private var _gvars:GlobalVariables = GlobalVariables.instance;

        //- Background
        private var box:Box;
        private var bmp:Bitmap;

        private var msgTitle:String;
        private var msgText:String;
        private var msgBtn:String;

        private var closeCallback:Function;
        private var closeOptions:BoxButton;

        public function PopupSecretFind(myParent:MenuPanel, unlockTitle:String, unlockText:String, btnText:String, callback:Function)
        {
            super(myParent);

            msgTitle = unlockTitle;
            msgText = unlockText;
            msgBtn = btnText;

            closeCallback = callback;
        }

        override public function stageAdd():void
        {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, e_keyDown);

            var boxWidth:Number = 300;
            var boxHeight:Number = 250;

            var bmd:BitmapData = new BitmapData(Main.GAME_WIDTH, Main.GAME_HEIGHT, false, 0x000000);
            bmd.draw(stage);
            bmd.applyFilter(bmd, bmd.rect, new Point(), new BlurFilter(16, 16, 3));
            bmp = new Bitmap(bmd);
            bmd = null;
            bmp.alpha = 0;
            this.addChild(bmp);

            var bh:Sprite = new Sprite();
            bh.x = (Main.GAME_WIDTH / 2);
            bh.y = (Main.GAME_HEIGHT / 2);
            bh.scaleX = 0.5;
            bh.scaleY = 0.5;
            bh.alpha = 0;
            this.addChild(bh);

            var bgbox:Box = new Box(bh, -(boxWidth / 2), -(boxHeight / 2), false, false);
            bgbox.setSize(boxWidth, boxHeight);
            bgbox.color = 0x000000;
            bgbox.normalAlpha = 0.5;
            bgbox.activeAlpha = 1;

            box = new Box(bh, -(boxWidth / 2), -(boxHeight / 2), false, false);
            box.setSize(boxWidth, boxHeight);
            box.activeAlpha = 0.4;

            var th:Sprite = new Sprite();
            var textbmd:BitmapData = new BitmapData(box.width, box.height, true, 0x000000);

            var messageDisplay:TextField;
            var yOff:Number = 0;

            //- Token Name
            messageDisplay = new TextField();
            messageDisplay.x = 10;
            messageDisplay.y = 0;
            messageDisplay.width = box.width - 20;
            messageDisplay.selectable = false;
            messageDisplay.embedFonts = true;
            messageDisplay.antiAliasType = AntiAliasType.ADVANCED;
            messageDisplay.width = box.width - 20;
            messageDisplay.autoSize = TextFieldAutoSize.CENTER;
            messageDisplay.defaultTextFormat = Constant.TEXT_FORMAT_CENTER;
            messageDisplay.htmlText = "<FONT SIZE=\"20\">SECRET FIND</FONT>";
            th.addChild(messageDisplay);
            yOff = messageDisplay.y + messageDisplay.height;

            //- Token Message
            messageDisplay = new TextField();
            messageDisplay.x = 10;
            messageDisplay.y = yOff + 5;
            messageDisplay.width = box.width - 20;
            messageDisplay.selectable = false;
            messageDisplay.embedFonts = true;
            messageDisplay.antiAliasType = AntiAliasType.ADVANCED;
            messageDisplay.width = box.width - 20;
            messageDisplay.wordWrap = true;
            messageDisplay.defaultTextFormat = Constant.TEXT_FORMAT_CENTER;
            messageDisplay.autoSize = TextFieldAutoSize.CENTER;
            messageDisplay.htmlText = msgTitle.replace(/\r\n/gi, "\n");
            th.addChild(messageDisplay);
            yOff = messageDisplay.y + messageDisplay.height + 15;

            // Divider
            th.graphics.lineStyle(1, 0xffffff);
            th.graphics.moveTo(10, yOff);
            th.graphics.lineTo(box.width - 20, yOff);

            yOff += 15;

            //- Unlock Message
            messageDisplay = new TextField();
            messageDisplay.x = 10;
            messageDisplay.y = yOff + 5;
            messageDisplay.width = box.width - 20;
            messageDisplay.selectable = false;
            messageDisplay.embedFonts = true;
            messageDisplay.antiAliasType = AntiAliasType.ADVANCED;
            messageDisplay.width = box.width - 20;
            messageDisplay.wordWrap = true;
            messageDisplay.defaultTextFormat = Constant.TEXT_FORMAT_CENTER;
            messageDisplay.autoSize = TextFieldAutoSize.CENTER;
            messageDisplay.text = msgText;
            th.addChild(messageDisplay);

            // Draw Text
            textbmd.draw(th);
            box.addChild(new Bitmap(textbmd));

            //- Close
            closeOptions = new BoxButton(box, 15, box.height - 42, box.width - 30, 27, msgBtn, 12, clickHandler);

            TweenLite.to(bmp, 1, {alpha: 1});
            TweenLite.to(bh, 1, {alpha: 1, scaleX: 1, scaleY: 1, ease: Back.easeOut});
        }

        override public function stageRemove():void
        {
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, e_keyDown);
            closeOptions.dispose();

            box.dispose();
            bmp = null;
            box = null;
        }

        private function e_keyDown(e:KeyboardEvent):void
        {
            if (e.keyCode == Keyboard.ENTER)
            {
                removePopup();
                closeCallback();
                return;
            }
        }

        private function clickHandler(e:MouseEvent):void
        {
            //- Close
            if (e.target == closeOptions)
            {
                removePopup();
                closeCallback();
                return;
            }
        }
    }
}
