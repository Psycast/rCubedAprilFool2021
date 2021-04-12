package menu
{
    import com.greensock.TweenLite;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.BitmapFilter;
    import flash.filters.BlurFilter;
    import flash.filters.ColorMatrixFilter;
    import flash.filters.GlowFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.utils.getDefinitionByName;

    public class AvatarWrapper extends Sprite
    {
        private static const AVATAR_COLOR:Object = {"Velocity": 0xF80F0A,
                "CosmoVibe": 0xB293FF,
                "Goldstinger": 0xD7E0FF,
                "Halogen": 0xA6DEFF,
                "hi19hi19": 0xBDFFC4,
                "Temmie": 0xFEFF0E}

        public var index:int;

        public var mc_avatar:MovieClip;
        public var mc_name:MovieClip;
        public var mc_shadow:MovieClip;

        public var mc_rage:MovieClip;
        public var mc_rage_source:BitmapData;

        public var character:String;
        public var state:String;

        public function AvatarWrapper(index:int):void
        {
            this.index = index;
        }

        public function dispose():void
        {
            RageOff();
        }

        public function SetSprite(sprite:String):void
        {
            this.character = sprite;

            var pA:Class = getDefinitionByName("af.assets::PA" + sprite) as Class;
            var pN:Class = getDefinitionByName("af.assets::PN" + sprite) as Class;

            mc_avatar = new pA();
            mc_shadow = new pA();
            mc_rage_source = new BitmapData(mc_avatar.width, mc_avatar.height, true, 0);
            mc_name = new pN();

            if (index == 0)
                mc_avatar.scaleX = mc_shadow.scaleX = -1;

            if (sprite == "RobinHoot")
                mc_shadow.gotoAndStop("default_clip");

            mc_name.gotoAndStop(2 - index);

            var colorTransform:ColorTransform = mc_shadow.transform.colorTransform;
            colorTransform.color = AVATAR_COLOR[sprite] || 0x20FFFF;
            mc_shadow.transform.colorTransform = colorTransform;

            mc_rage_source.draw(mc_avatar, null, new ColorTransform(1, 1, 1, 1, 0xFF, 0xFF, 0xFF, 0));

            mc_avatar.alpha = mc_shadow.alpha = mc_name.alpha = 0;

            addChild(mc_shadow);
            addChild(mc_avatar);
            addChild(mc_name);
        }

        public function ShowName(val:Number):void
        {
            mc_name.alpha = val;
        }

        /**
         * Whenh a chat message starts.
         */
        public function ChatStart():void
        {
            mc_shadow.alpha = 1;
            TweenLite.to(mc_shadow, 0.5, {"x": (index == 0 ? -10 : 10)});
        }

        /**
         * What a chat message starts and the talker isn't this avatar.
         */
        public function ChatEnd():void
        {
            SetAnimation("default");
            TweenLite.to(mc_shadow, 0.5, {"x": 0});
        }

        /**
         * When requested to hide chat shadow / name.
         */
        public function ChatHide():void
        {
            SetAnimation("default");
            TweenLite.to(mc_shadow, 0.5, {"alpha": 0, "x": 0});
            ShowName(0);
        }

        public function ChatFinish():void
        {
            if (state == "chat")
                SetAnimation("default");
        }

        public function ChatAnimate():void
        {
            if (state == "default")
                SetAnimation("chat");
        }

        public function SetAnimation(anima:String):void
        {
            for each (var label:Object in mc_avatar.currentLabels)
            {
                if (label.name == anima)
                {
                    state = anima;
                    mc_avatar.gotoAndPlay(label.frame);
                    return;
                }
            }
            trace("Unknown animation for", this.character, ":", anima);
        }

        public function FadeIn():void
        {
            TweenLite.to(mc_avatar, 0.5, {"alpha": 1});
        }

        public function FadeOut():void
        {
            TweenLite.to([mc_avatar, mc_name, mc_shadow], 0.5, {"alpha": 0});

            if (holder != null)
                TweenLite.to(holder, 0.5, {"alpha": 0});
        }

        ////////////////////////////////////////
        // Rage Effects
        private static var matrix:Array = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0];

        private var rageInit:Boolean = false;
        private var granularity:int = 40;
        private var area:int = 20;
        private var padding:int = 250;
        private var tint:uint = 0xF80F0A;
        private var seed:int = Math.round(Math.random() * 300);

        private var bounds:Object;
        private var offsets:Array;
        private var scaler:Number = 2;
        private var noise_source:BitmapData;
        private var noise_bitmap_threshold:BitmapData;
        private var bitmap:BitmapData;
        private var bitmap_matrix:Matrix;
        private var noise_bitmap:Bitmap;

        private var holder:Bitmap;

        private var blur:BlurFilter;
        private var cmfilter:BitmapFilter;
        private var filter_point:Point = new Point(0, 0);

        public function RageOff():void
        {
            if (rageInit)
            {
                mc_avatar.filters = [];
                removeChild(holder);
                this.removeEventListener(Event.ENTER_FRAME, e_rageOnEnter);
                rageInit = false;
            }
        }

        public function RageInit(color:uint):void
        {

            tint = color;
            bounds = mc_avatar.getBounds(mc_avatar);

            var offset_y:Number = area + padding;
            var offset_x:Number = area + padding;
            var w:Number = bounds.width + offset_x;
            var h:Number = bounds.height + offset_y;

            offsets = [new Point(), new Point(), new Point(), new Point(), new Point()];

            bounds.x -= (offset_x / 2);
            bounds.y -= (offset_y / 2);
            bitmap_matrix = new Matrix(1, 0, 0, 1, bounds.x * -1, bounds.y * -1);

            mc_avatar.filters = [new GlowFilter(tint, 0.8, area, area, 1, 3, false, false), new GlowFilter(tint, 0.6, 5, 5, 2, 1, true, false)];

            noise_source = new BitmapData(w / scaler, h / scaler);
            noise_bitmap_threshold = new BitmapData(w, h);
            bitmap = new BitmapData(w, h, true, 0);
            blur = new BlurFilter(6, 6, 1);
            cmfilter = new ColorMatrixFilter(matrix);

            noise_bitmap = new Bitmap();
            noise_bitmap.scaleX = noise_bitmap.scaleY = scaler;

            holder = new Bitmap();
            holder.smoothing = true;
            holder.pixelSnapping = "never";
            holder.bitmapData = bitmap;
            holder.x = bounds.x;
            holder.y = bounds.y;
            holder.filters = [blur, new GlowFilter(tint, 0.8, 5, 5, 4, 1, true, false)];
            holder.alpha = 0;

            this.addChildAt(holder, 0);

            TweenLite.to(holder, 0.5, {"alpha": 1});

            this.addEventListener(Event.ENTER_FRAME, e_rageOnEnter);

            rageInit = true;
        }

        private function e_rageOnEnter(e:Event):void
        {
            noise_source.lock();
            noise_bitmap_threshold.lock();
            bitmap.lock();

            for each (var point:Point in offsets)
            {
                point.y += 0.6;
                point.x += 0.1;
            }

            noise_source.perlinNoise(granularity / scaler, granularity / scaler, 5, seed, false, false, 1, true, offsets);
            noise_bitmap.bitmapData = noise_source;

            bitmap.draw(mc_rage_source, bitmap_matrix);
            bitmap.applyFilter(bitmap, noise_bitmap_threshold.rect, filter_point, blur);

            noise_bitmap_threshold.draw(noise_bitmap, noise_bitmap.transform.matrix);
            noise_bitmap_threshold.threshold(bitmap, bitmap.rect, filter_point, "<=", 8176, 16777215, 65280, false);

            bitmap.applyFilter(bitmap, noise_bitmap_threshold.rect, filter_point, cmfilter);
            bitmap.merge(noise_bitmap_threshold, noise_bitmap_threshold.rect, filter_point, 255, 255, 255, 0);

            noise_source.unlock();
            noise_bitmap_threshold.unlock();
            bitmap.unlock();
        }
    }
}
