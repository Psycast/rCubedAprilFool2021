package classes
{

    public class DeltaTimeline
    {
        private var TL_Parent:*;

        private var TL_Functions:Object = {};

        public var TL_Running:Boolean = false;
        public var TL_Line:Number = 0;
        public var TL_T:Number = 0;
        public var TL_PanicFunc:String = "";
        public var TL_RunCount:Number = 0;

        public var TLActionList:Array = [];
        public var TLLabels:Object = {};
        public var TLVars:Object = {"pi": Math.PI};
        public var TLCurrentLine:Array = [];

        public function DeltaTimeline(parentCaller:*)
        {
            this.TL_Parent = parentCaller;
        }

        public function TLTick(delta:Number, eclipsed:Number):void
        {
            TL_RunCount = 0;
            while (true)
            {
                if (!TL_Running || TL_Line < 0 || TL_Line > TLActionList.length || TL_T < TLCurrentLine[0])
                    break;

                if (TLCurrentLine[1].toString().substr(0, 1) != ":") // Label Check
                {
                    // Try Internal Load
                    try
                    {
                        if (TL_Functions[TLCurrentLine[1]] == null)
                            if (this[TLCurrentLine[1]] != null)
                                TL_Functions[TLCurrentLine[1]] = (this[TLCurrentLine[1]] as Function);
                    }
                    catch (e:Error)
                    {
                        //trace("-I-", TLCurrentLine[1] + "(" + ((TLCurrentLine[2] as Array).join(", ")) + ") [" + TL_Line + "," + TL_RunCount + "]");
                        //trace(e);
                    }

                    // Try External Load
                    try
                    {
                        if (TL_Functions[TLCurrentLine[1]] == null)
                            if (TL_Parent[TLCurrentLine[1]] != null)
                                TL_Functions[TLCurrentLine[1]] = (TL_Parent[TLCurrentLine[1]] as Function);
                    }
                    catch (e:Error)
                    {
                        trace("-E-", TLCurrentLine[1] + "(" + ((TLCurrentLine[2] as Array).join(", ")) + ") [" + TL_Line + "," + TL_RunCount + "]");
                            //trace(e);
                    }

                    // Call Function
                    try
                    {
                        var CallFunction:Function = TL_Functions[TLCurrentLine[1]];
                        CallFunction.apply(null, TLCurrentLine[2]);
                            //trace(TLCurrentLine[0], TLCurrentLine[1] + "(" + ((TLCurrentLine[2] as Array).join(", ")) + ") [" + TL_Line + "," + TL_RunCount + "]");
                    }
                    catch (e:Error)
                    {
                        trace("-C-", TLCurrentLine[1] + "(" + ((TLCurrentLine[2] as Array).join(", ")) + ") [" + TL_Line + "," + TL_RunCount + "]");
                    }
                }

                TL_T -= TLCurrentLine[0];
                TL_Line++;

                if (!TLLoadLine())
                    break;

                TL_RunCount++;

                if (TL_RunCount >= 1000)
                {
                    TL_Running = false;
                    trace("TLTick: Infinite Loop Detected, Line ", TL_Line);
                    break;
                }
            }
            if (TL_Running)
                TL_T += eclipsed;
        }

        public function TLPlay(seqData:Array):void
        {
            // Reset
            TLActionList = [];
            TLLabels = {};
            TLVars = {"pi": Math.PI};

            var Count:Number = seqData.length;
            var LineText:Array;

            for (var i:int = 0; i < Count; i++)
            {
                LineText = seqData[i];
                TLActionList.push(LineText);

                var TokenString:String = LineText[1].toString();

                // Jump Labels
                if (TokenString.substr(0, 1) == ":")
                    TLLabels[TokenString.substr(1)] = (i + 1);
            }

            TL_T = 0;
            TL_Line = 1;

            TLLoadLine();

            TL_Running = true;
        }

        public function TLLoadLine():Boolean
        {
            TLCurrentLine = [];

            if (TL_Line < 0 || TL_Line > TLActionList.length)
                return false;

            var Text:Array = TLActionList[TL_Line - 1];
            var ParamCount:Number = Text.length;
            var FunctionArgs:Array = [];

            TLCurrentLine.push(TLTokenValue(Text[0], true)); // 0 = Time Delay
            TLCurrentLine.push(TLFunctionRedirect(Text[1])); // 1 = Function Name or Label
            TLCurrentLine.push(FunctionArgs);

            for (var i:int = 2; i < ParamCount; i++)
                FunctionArgs.push(TLTokenValue(Text[i]));

            return true;
        }

        private function TLFunctionRedirect(func_name:String):String
        {
            if (func_name == "Sound")
                return "PlaySound";

            return func_name;
        }

        private function TLTokenValue(Token:*, doPause:Boolean = false):*
        {
            var TokenString:String = Token.toString();

            if (TokenString.substr(0, 1) == "$")
                return TLVars[Token.substr(1)];

            return Token;
        }

        public function TLPanic(callback:String):void
        {
            TL_PanicFunc = callback;
        }

        public function TLPause():void
        {
            TL_Running = false;
        }

        public function TLResume():void
        {
            TL_Running = true;
        }

        public function TLIsRunning():Boolean
        {
            return TL_Running;
        }

        public function TLStop():void
        {
            TLActionList = [];
            TLCurrentLine = [];
            TL_Running = false;
        }

        // Timeline CPU
        public function deg2rad(deg:Number):Number
        {
            return deg / 180.0 * Math.PI;
        }

        public function SET(key:String, value1:*):void
        {
            TLVars[key] = value1;
        }

        public function ADD(key:String, value1:Number, value2:Number):void
        {
            TLVars[key] = value1 + value2;
        }

        public function SUB(key:String, value1:Number, value2:Number):void
        {
            TLVars[key] = value1 - value2;
        }

        public function MUL(key:String, value1:Number, value2:Number):void
        {
            TLVars[key] = value1 * value2;
        }

        public function DIV(key:String, value1:Number, value2:Number):void
        {
            TLVars[key] = value1 / value2;
        }

        public function MOD(key:String, value1:Number, value2:Number):void
        {
            TLVars[key] = value1 % value2;
        }

        public function FLOOR(key:String, value1:Number):void
        {
            TLVars[key] = Math.floor(value1);
        }

        public function DEG(key:String, value1:Number):void
        {
            TLVars[key] = value1 * 180 / Math.PI;
        }

        public function RAD(key:String, value1:Number):void
        {
            TLVars[key] = value1 * Math.PI / 180;
        }

        public function SIN(key:String, value1:Number):void
        {
            TLVars[key] = Math.sin(deg2rad(value1));
        }

        public function COS(key:String, value1:Number):void
        {
            TLVars[key] = Math.cos(deg2rad(value1));
        }

        public function ANGLE(key:String, to_x:Number, to_y:Number, from_x:Number, from_y:Number):void
        {
            TLVars[key] = ((((Math.atan2(to_y - from_y, to_x - from_x)) * 180 / Math.PI) + 180) % 360);
        }

        public function RND(key:String, value1:Number):void
        {
            TLVars[key] = Math.floor(Math.random() * value1);
        }

        public function JMPABS(jumpTarget:*):void
        {
            //if (jumpTarget.toString().match(/^[0-9]+$/gi))
            if (jumpTarget is Number)
            {
                TL_Line = jumpTarget - 1;
            }
            else
            {
                if (TLLabels[jumpTarget] != null)
                    TL_Line = TLLabels[jumpTarget] - 1;
                else
                    trace("Invalid JMPABS target -> \"" + jumpTarget + "\" at line " + TL_Line);
            }
        }

        public function JMPREL(target:int):void
        {
            TL_Line += (target - 1);
        }

        public function JMPZ(jumpTarget:*, value1:Number):void
        {
            if (value1 == 0)
                JMPABS(jumpTarget);
        }

        public function JMPNZ(jumpTarget:*, value1:Number):void
        {
            if (value1 != 0)
                JMPABS(jumpTarget);
        }

        public function JMPE(jumpTarget:*, value1:Number, value2:Number):void
        {
            if (value1 == value2)
                JMPABS(jumpTarget);
        }

        public function JMPNE(jumpTarget:*, value1:Number, value2:Number):void
        {
            if (value1 != value2)
                JMPABS(jumpTarget);
        }

        public function JMPL(jumpTarget:*, value1:*, value2:*):void
        {
            if (value1 < value2)
                JMPABS(jumpTarget);
        }

        public function JMPNL(jumpTarget:*, value1:Number, value2:Number):void
        {
            if (value1 >= value2)
                JMPABS(jumpTarget);
        }

        public function JMPG(jumpTarget:*, value1:Number, value2:Number):void
        {
            if (value1 > value2)
                JMPABS(jumpTarget);
        }

        public function JMPNG(jumpTarget:*, value1:Number, value2:Number):void
        {
            if (value1 <= value2)
                JMPABS(jumpTarget);
        }
    }
}
