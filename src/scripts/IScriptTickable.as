package scripts
{

    public interface IScriptTickable
    {
        function update(delta:Number, eclipsed:Number):void;
        function destroy():void;
        function canDestroy():Boolean;
    }

}
