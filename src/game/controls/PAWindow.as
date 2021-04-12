package game.controls
{
    import classes.Language;
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFieldAutoSize;
    import flash.text.AntiAliasType;
    import game.GameOptions;

    public class PAWindow extends Sprite
    {
        private static var _lang:Language = Language.instance;

        public var scores:Array;
        private var holds:Boolean = false;

        private var options:GameOptions;

        public function PAWindow(options:GameOptions, hasHolds:Boolean)
        {
            this.options = options;
            this.holds = hasHolds;

            scores = new Array();

            var ypos:int = 0;
            var scoreSize:int = 32;

            var labelDesc:Array = [{colour: options.judgeColours[0], title: _lang.stringSimple("game_amazing")},
                {colour: options.judgeColours[1], title: _lang.stringSimple("game_perfect")},
                {colour: options.judgeColours[2], title: _lang.stringSimple("game_good")},
                {colour: options.judgeColours[3], title: _lang.stringSimple("game_average")},
                {colour: options.judgeColours[4], title: _lang.stringSimple("game_miss")},
                {colour: options.judgeColours[5], title: _lang.stringSimple("game_boo")}];
            if (!options.displayAmazing)
            {
                labelDesc.splice(0, 1);
                ypos = 49;
            }

            if (this.holds)
            {
                labelDesc.push({colour: options.judgeColours[6], title: "OK"})
                labelDesc.push({colour: options.judgeColours[7], title: "NG"})
            }

            for each (var label:Object in labelDesc)
            {
                var field:TextField = new TextField();

                if (label.colour != 0)
                {
                    field.defaultTextFormat = new TextFormat(_lang.font(), 13, label.colour, true);
                    field.antiAliasType = AntiAliasType.ADVANCED;
                    field.embedFonts = true;
                    field.selectable = false;
                    field.autoSize = TextFieldAutoSize.RIGHT;
                    field.y = ypos;
                    field.x = 50;
                    field.width = 10;
                    field.text = label.title + ":";
                    addChild(field);

                    field = new TextField();
                    field.defaultTextFormat = new TextFormat(_lang.font(), scoreSize--, label.colour, true);
                    field.antiAliasType = AntiAliasType.ADVANCED;
                    field.embedFonts = true;
                    field.selectable = false;
                    field.autoSize = TextFieldAutoSize.LEFT;
                    field.y = ypos - 22 + (36 - scoreSize);
                    field.x = 60;
                    field.text = "0";
                    addChild(field);
                    ypos += 41;
                }
                scores.push(field);
            }
        }

        public function reset():void
        {
            update(0, 0, 0, 0, 0, 0, 0, 0);
        }

        public function update(amazing:int, perfect:int, good:int, average:int, miss:int, boo:int, hok:int, hng:int):void
        {
            var offset:int = 0;
            if (options.displayAmazing)
            {
                updateScore(0, amazing);
                updateScore(1, perfect);
                offset = 1;
            }
            else
            {
                updateScore(0, amazing + perfect);
            }

            updateScore(offset + 1, good);
            updateScore(offset + 2, average);
            updateScore(offset + 3, miss);
            updateScore(offset + 4, boo);
            if (holds)
            {
                updateScore(offset + 5, hok);
                updateScore(offset + 6, hng);
            }
        }

        public function updateScore(field:int, score:int):void
        {
            scores[field].text = score.toString();
        }
    }
}
