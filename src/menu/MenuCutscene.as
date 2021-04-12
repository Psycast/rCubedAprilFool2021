package menu
{
    import af.assets.AFChatBackground;
    import classes.DeltaTimeline;
    import ext.scripts.SansDetermination;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.TimerEvent;
    import flash.text.TextFormat;
    import flash.ui.Keyboard;
    import flash.utils.Timer;
    import flash.utils.getDefinitionByName;
    import flash.utils.getTimer;
    import scripts.IScriptTickable;
    import flash.ui.Mouse;

    public class MenuCutscene extends Sprite
    {
        private var ssmenu:MenuSongSelection;
        public var level:int;

        private var timeline:DeltaTimeline;
        private var lastTimer:Number;
        private var data:Array;
        private var paused:Boolean = false;

        public var tickables:Array = [];

        private var bg:AFChatBackground;
        public var avatars:Array = [null, null];

        private var overlay:MovieClip;

        public var state:int = 0;

        // Chat
        private var last_chat:int = -1;

        public function MenuCutscene(menu:MenuSongSelection)
        {
            this.ssmenu = menu;
        }

        public function init(level:int):void
        {
            this.level = level;

            Mouse.hide();

            data = MenuCutsceneData.getLevel(level);

            timeline = new DeltaTimeline(this);
            timeline.TLPlay(data);

            stage.addEventListener(KeyboardEvent.KEY_DOWN, e_keyDown, false, 14);
            stage.addEventListener(Event.ENTER_FRAME, e_enterFrame);

            bg = new AFChatBackground();
            bg.alpha = 0;
            this.addChild(bg);

            lastTimer = getTimer();
        }

        public function dispose():void
        {
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, e_keyDown);
            stage.removeEventListener(Event.ENTER_FRAME, e_enterFrame);
        }

        private function e_keyDown(e:KeyboardEvent):void
        {
            e.stopImmediatePropagation();
        }

        private function e_enterFrame(e:Event):void
        {
            // Understand Delta
            var curTimer:int = getTimer();
            var delta:Number = (curTimer - lastTimer) / (1000 / 60);
            var eclipsed:Number = (curTimer - lastTimer) / 1000;
            lastTimer = curTimer;

            if (paused)
                return;

            // Fading
            if (state == 0 && bg.alpha < 1)
            {
                bg.alpha = Math.min(1, bg.alpha + (1 * eclipsed));
                if (bg.alpha >= 1)
                    state = 1;
            }
            else if (state == 2 && this.alpha > 0)
            {
                this.alpha = Math.max(0, this.alpha - (1 * eclipsed));
                if (this.alpha <= 0)
                    this.ssmenu.endCutscene();
            }

            // timeline
            timeline.TLTick(delta, eclipsed);

            for each (var tickable:IScriptTickable in tickables)
                tickable.update(delta, eclipsed);
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        public function SetOverlay(mcstr:String):void
        {
            if (overlay != null)
            {
                this.removeChild(overlay);
                overlay = null;
            }

            var pOverlay:Class = getDefinitionByName("af.assets::" + mcstr) as Class;
            overlay = new pOverlay();
            overlay.gotoAndStop(1);
            this.addChild(overlay);
        }

        public function OverlayPlay(label:String):void
        {
            if (overlay != null)
            {
                overlay.gotoAndPlay(label);
            }
        }

        public function OverlayWait(label:String):void
        {
            if (overlay != null)
            {
                timeline.TLPause();

                var tt:Timer = new Timer(100);
                tt.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void
                {
                    if (overlay.currentLabel == label)
                    {
                        timeline.TLResume();
                        tt.stop();
                    }
                });
                tt.start();
            }
        }

        public function SetSprites(left_sprite:String, right_sprite:String):void
        {
            SetSprite(0, left_sprite);
            SetSprite(1, right_sprite);
        }

        public function SetSprite(index:int, sprite:String):void
        {
            if (avatars[index] != null)
            {
                removeChild(avatars[index]);
                avatars[index] = null;
            }

            var newAvatar:AvatarWrapper = new AvatarWrapper(index);
            newAvatar.SetSprite(sprite);
            newAvatar.x = index == 0 ? 230 : 512;
            newAvatar.y = 153;
            avatars[index] = newAvatar;
            addChild(newAvatar);
        }

        public function SetAnimation(index:int, scene:String):void
        {
            if (avatars[index] != null)
                avatars[index].SetAnimation(scene);
        }

        public function Rage(index:int, color:uint):void
        {
            avatars[index].RageInit(color);
        }

        public function RageOff(index:int):void
        {
            avatars[index].RageOff();
        }

        public function FadeIn(index:int, time:Number):void
        {
            if (avatars[index] != null)
            {
                avatars[index].FadeIn();
            }
        }

        public function FadeOut(index:int, time:Number):void
        {
            if (avatars[index] != null)
            {
                avatars[index].FadeOut();
            }
        }

        public function Chat(index:int, text:String, speedMulti:Number = 1, timeout:Number = 2):void
        {
            MenuCutsceneChat.clear();

            var otherIndex:int = index == 0 ? 1 : 0;

            avatars[index].ShowName(1);

            if (avatars[otherIndex] != null)
                avatars[otherIndex].ShowName(0);

            // User Taling Change
            if (last_chat != index)
            {
                if (last_chat >= 0)
                    avatars[last_chat].ChatEnd();

                avatars[index].ChatStart();

                last_chat = index;
            }

            avatars[index].ChatAnimate();

            var chatTextfield:MenuCutsceneChat = new MenuCutsceneChat(this, ChatSetFont(avatars[index].character), speedMulti);
            chatTextfield.x = 52;
            chatTextfield.y = 387;
            chatTextfield.setSize(655, 90);
            chatTextfield.text = "";
            chatTextfield.voice = ChatSetVoice(avatars[index].character);
            chatTextfield.fullText = text;
            chatTextfield.timeout = timeout;
            chatTextfield.avatarIndex = index;
            //chatTextfield.interactive = true;
            chatTextfield.endFunc = "ChatResume";

            this.addChild(chatTextfield);
            tickables[tickables.length] = chatTextfield;

            timeline.TLPause();
        }

        public function ChatOther(text:String, speedMulti:Number = 1, timeout:Number = 2):void
        {
            MenuCutsceneChat.clear();

            avatars[0].ShowName(0);
            avatars[1].ShowName(0);

            if (last_chat >= 0)
                avatars[last_chat].ChatEnd();

            last_chat = -1;

            var chatTextfield:MenuCutsceneChat = new MenuCutsceneChat(this, ChatSetFont("Narrator"), speedMulti);
            chatTextfield.x = 52;
            chatTextfield.y = 387;
            chatTextfield.setSize(655, 90);
            chatTextfield.text = "";
            chatTextfield.voice = ChatSetVoice("Narrator");
            chatTextfield.fullText = text;
            chatTextfield.timeout = timeout;
            chatTextfield.endFunc = "ChatResume"; //EndFunc;

            this.addChild(chatTextfield);
            tickables[tickables.length] = chatTextfield;

            timeline.TLPause();
        }

        public function ChatResume():void
        {
            timeline.TLResume();
        }

        public function ChatHide():void
        {
            if (last_chat >= 0)
                avatars[last_chat].ChatHide();

            MenuCutsceneChat.clear();

            last_chat = -1;
        }

        public function Play():void
        {
            this.ssmenu.endCutscene(true, this.level);
        }

        public function Bail():void
        {
            state = 2;
        }

        public function RemoveTickable(object:Sprite):void
        {
            if (object.parent != null)
                object.parent.removeChild(object);

            (object as IScriptTickable).destroy();

            var index:int = tickables.indexOf(object);
            if (index > -1)
            {
                tickables.splice(index, 1);
            }
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        private function ChatSetFont(char:String):TextFormat
        {
            switch (char)
            {
                case "RobinHoot":
                    return new TextFormat(Constant.TEXT_FORMAT_UNICODE.font, 20, 0xD5FFC4, true);

                case "Velocity":
                    return new TextFormat(Constant.TEXT_FORMAT_UNICODE.font, 20, 0xFFC6A5, true);

                case "Goldstinger":
                    return new TextFormat(Constant.TEXT_FORMAT_UNICODE.font, 20, 0xCEE5FF, true);

                case "CosmoVibe":
                    return new TextFormat(Constant.TEXT_FORMAT_UNICODE.font, 20, 0xF0D6FF, true);

                case "Temmie":
                    return new TextFormat(new SansDetermination().fontName, 20, 0xFFF7BC, true);

                case "hi19hi19":
                    return new TextFormat(Constant.TEXT_FORMAT_UNICODE.font, 20, 0xFFF7BC, true);

                case "Halogen":
                    return new TextFormat(Constant.TEXT_FORMAT_UNICODE.font, 20, 0xCEE5FF, true);

                default:
                    return new TextFormat(Constant.TEXT_FORMAT_UNICODE.font, 20, 0xFFFFFF, true);
            }
        }

        private function ChatSetVoice(char:String):String
        {
            switch (char)
            {
                case "RobinHoot":
                    return "txtasr";

                case "Velocity":
                    return "txtvel";

                case "Goldstinger":
                    return "txtgol";

                case "CosmoVibe":
                    return "txtcos";

                case "Temmie":
                    return "txttem";

                case "hi19hi19":
                    return "txthi";

                case "Halogen":
                    return "txthal";

                default:
                    return "";
            }
        }
    }
}
