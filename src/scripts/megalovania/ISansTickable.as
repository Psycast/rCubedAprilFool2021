package scripts.megalovania
{

    import scripts.SansBattleScript;

    public interface ISansTickable
    {
        function update(delta:Number, eclipsed:Number, script:SansBattleScript):void;
        function destroy():void;
    }

}
