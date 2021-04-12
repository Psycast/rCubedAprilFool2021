package classes.chart
{
    import game.GameOptions;
    import game.GamePlay;

    /**
     * @author FictionVoid
     */
    public class LevelScriptRuntime implements ILevelScriptRuntime
    {
        private var options:GameOptions;
        private var gameplay:GamePlay;
        private var level_script:ILevelScript;

        public function LevelScriptRuntime(gameplay:GamePlay, script:ILevelScript)
        {
            this.options = gameplay.getScriptVariable("options") as GameOptions;
            this.gameplay = gameplay;
            this.level_script = script;
            level_script.init(this);
        }

        public function doProgressTick(frame:int):void
        {
            level_script.doFrameEvent(frame);
        }

        public function doTickEvent(position:int):void
        {
            level_script.doTickEvent(position);
        }

        public function destroy():void
        {
            level_script.destroy();
        }

        public function restart():void
        {
            level_script.restart();
        }

        public function getOptions():GameOptions
        {
            return options;
        }

        public function getGameplay():GamePlay
        {
            return gameplay;
        }

        public function postUIHook():void
        {
            level_script.postUIHook();
        }

        public function registerNoteskin(json_data:String):Boolean
        {
            return true;
        }

        public function unregisterNoteskin(id:int):Boolean
        {
            return true;
        }

        public function addMod(mod:String):void
        {
            options.mods.push(mod);
            options.modCache[mod] = true;
        }

        public function removeMod(mod:String):void
        {
            var i:int = options.mods.indexOf(mod);
            if (i >= 0)
                options.mods.splice(i, 1);

            delete options.modCache[mod];
        }

        public function setNotescale(value:Number):void
        {
            options.noteScale = value;
        }

        public function setNoteskin(id:int):void
        {
            options.noteskin = id;
        }

        public function setNotePool(enabled:Boolean):void
        {
            options.DISABLE_NOTE_POOL = !enabled;
        }

    }

}
