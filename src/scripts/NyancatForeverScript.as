package scripts
{
    import classes.chart.ILevelScript;
    import classes.chart.ILevelScriptRuntime;
    import game.controls.NoteBox;
    import game.GamePlay;
    import flash.media.SoundChannel;
    import flash.media.Sound;
    import flash.media.SoundMixer;
    import game.GameOptions;
    import game.controls.GameNote;
    import classes.ui.Text;
    import flash.text.TextFormat;
    import classes.Language;

    public class NyancatForeverScript implements ILevelScript
    {
        private var runtime:ILevelScriptRuntime;

        private var loop:int = 1;
        private var idOffset:int = 288;
        private var noteRemoval:int = 33;

        public var gp:GamePlay;
        public var nb:NoteBox;
        public var chartNotesLength:int;
        public var noteLoopTotal:int = 254;

        public var snd:Sound;
        public var sndChannel:SoundChannel;

        public var runtimeText:Text;

        ////////////////////////////////////////////////////////////////////////////////////////////////////
        public function init(runtime:ILevelScriptRuntime):void
        {
            this.runtime = runtime;
            this.gp = runtime.getGameplay();
            this.gp.disablePause = true;
            this.gp.disableRestart = true;
        }

        public function postUIHook():void
        {
            if (runtimeText == null)
            {
                runtimeText = new Text(null, 10, 4, "00:00", 20);
                runtimeText.setAreaParams(780, 30, "center");
                runtimeText.visible = false;
            }
            runtimeText.text = "00:00";

            if (gp.progressDisplay != null)
                gp.progressDisplay.setColor(0xc90c8a);

            if (gp.comboStatic != null)
            {
                gp.comboStatic.field.defaultTextFormat = new TextFormat(Language.UNI_FONT_NAME, 17, 0xfc5dc7, true);
                gp.comboStatic.field.text = gp.comboStatic.field.text;
            }
            if (gp.comboTotalStatic != null)
            {
                gp.comboTotalStatic.field.defaultTextFormat = new TextFormat(Language.UNI_FONT_NAME, 17, 0xfc5dc7, true);
                gp.comboTotalStatic.field.text = gp.comboTotalStatic.field.text;
            }

            gp.addChild(runtimeText);
            runtime.addMod("_spawn_noteskin_nyancat");
            runtime.setNoteskin(11);

            nb = this.gp.noteBox;
            chartNotesLength = nb.song.chart.Notes.length;
            //gp.absoluteStart -= 1500;
            gp.songDelayStarted = true;
        }

        public function hasFrameScript(frame:int):Boolean
        {
            return false;
        }

        public function doFrameEvent(frame:int):void
        {
            runtimeText.text = formatTime(Math.floor(frame / 30)).toString();
            if (frame == 1)
            {
                snd = nb.song.getSoundObject();
                sndChannel = snd.play(nb.song.musicDelay * 1000 / GameOptions.ENGINE_TICK_RATE);
                    //sndChannel.soundTransform = SoundMixer.soundTransform;
            }
            else if (sndChannel.position >= 31708)
            {
                loop++;
                runtimeText.visible = true;

                var sp:Number = sndChannel.position;
                var repeatTime:Number = 27.099; // 27.069 should be correct but ¯\_(ツ)_/¯

                trace("repeat", loop, (sp - 27069));

                // Remove Notes past repeat point
                var lastRemovedID:int = idOffset;
                for (var index:int = nb.notes.length - 1; index >= 0; index--)
                {
                    var removeNoteRef:GameNote = nb.notes[index];
                    nb.notePool[removeNoteRef.NOTESKIN][removeNoteRef.DIR][removeNoteRef.COLOR].unmarkObject(removeNoteRef);
                    removeNoteRef.visible = false;
                    lastRemovedID = removeNoteRef.ID;
                }
                nb.notes = [];

                // Update Old to new times
                for (var noteIndex:int = 0; noteIndex < chartNotesLength; noteIndex++)
                {
                    nb.song.chart.Notes[noteIndex]["time"] += repeatTime;
                    nb.song.chart.Notes[noteIndex]["frame"] = int(nb.song.chart.Notes[noteIndex]["time"] * 30);
                }

                // Reset Spawn Index
                trace("skipping", (lastRemovedID - idOffset), "notes");
                nb.noteCount = 3 + (lastRemovedID - idOffset);

                // Remove Initial <noteRemoval> Notes, adjusts prehit id offsets as well.
                if (loop == 2)
                {
                    for (var re:int = 0; re < noteRemoval; re++)
                        nb.song.chart.Notes.shift();

                    idOffset -= noteRemoval;
                    chartNotesLength = nb.song.chart.Notes.length;
                }

                // Update Total display (if visible)
                if (gp.comboTotal)
                    gp.comboTotal.update((loop * noteLoopTotal) + noteRemoval);

                // Update Level End Timer
                gp.gameLastNoteTime = nb.song.chart.Notes[chartNotesLength - 1]["time"] * 1000;

                // Reset Audio
                sndChannel.stop();
                sndChannel = null;
                sndChannel = snd.play(sp - 27069);
                    //sndChannel.soundTransform = SoundMixer.soundTransform;
            }
        }

        public function doTickEvent(position:int):void
        {

        }

        public function destroy():void
        {
            if (sndChannel)
            {
                sndChannel.stop();
                sndChannel = null;
            }
        }

        public function restart():void
        {
            if (sndChannel)
            {
                sndChannel.stop();
                sndChannel = null;
            }
        }

        public function formatTime(seconds:int):String
        {
            return ((seconds > 3600 ? Math.floor(seconds / 3600) + ":" : "") + (seconds % 3600 < 600 ? "0" : "") + Math.floor(seconds % 3600 / 60) + ":" + (seconds % 60 < 10 ? "0" : "") + seconds % 60);
        }
    }
}
