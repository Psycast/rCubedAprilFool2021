package classes.chart
{
    import arc.NoteMod;
    import classes.chart.levels.EmbedChartBase;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.SampleDataEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundMixer;
    import flash.utils.ByteArray;
    import game.GameOptions;

    public class Song extends EventDispatcher
    {
        private var _gvars:GlobalVariables = GlobalVariables.instance;

        public var id:uint;
        public var entry:Object;

        public var sound:Sound;
        public var chart:NoteChart;

        public var noteMod:NoteMod;
        public var options:GameOptions;
        public var soundChannel:SoundChannel;
        public var musicPausePosition:int;
        public var musicIsPlaying:Boolean = false;

        public var isChartLoaded:Boolean = false;
        public var isMusicLoaded:Boolean = false;

        public var musicDelay:int = 0;

        public var isLoaded:Boolean = false;

        private var localFileData:ByteArray = null;
        private var localFileHash:String = "";

        public function Song(song:Object):void
        {
            this.entry = song;
            this.id = song.level;

            // Mod Charts don't handle rates.
            var levelscript:String = this.entry.levelscript || "";
            if (levelscript == "NyanCat" || levelscript == "SansBattle" || (levelscript == "DarkMatter" && Flags.ANTIMATTER))
                _gvars.options.songRate = 1;

            options = _gvars.options;
            noteMod = new NoteMod(this, options);
            rateRate = options.songRate;

            load();
        }

        private function load():void
        {
            if (options.isEditor)
            {
                chart = new NoteChart();
                chart.Notes = [];
                chart.Holds = [];
                isMusicLoaded = true;
                isChartLoaded = true;
                loadComplete();
                return;
            }

            var dataSource:EmbedChartBase = this.entry.embedData;

            // Load Audio
            var musicBytes:* = dataSource.getAudioData();
            if (musicBytes is ByteArray)
            {
                musicBytes.position = 0;
                sound = new Sound();
                sound.loadCompressedDataFromByteArray(musicBytes, musicBytes.length);
            }
            else
                sound = musicBytes;

            // Song Rate
            if (rateRate != 1)
            {
                rateSound = sound;
                sound = new Sound();
                sound.addEventListener("sampleData", onRateSound);
            }

            chart = new NoteChart();
            chart.Notes = [];

            // Fully Parse Chart Data
            dataSource.parseData();

            // Load Notes
            var noteData:Array = dataSource.getNoteData(options.selectedChartID);
            for (var i:int = 0; i < noteData.length; i++)
            {
                chart.Notes[chart.Notes.length] = new Note(noteData[i][1], noteData[i][0], noteData[i][2], Math.floor(noteData[i][0] * GameOptions.ENGINE_TICK_RATE))
            }

            // Load Holds
            chart.Holds = [];
            var holdData:Array = dataSource.getHoldData(options.selectedChartID);
            for (i = 0; i < holdData.length; i++)
            {
                chart.Holds[chart.Holds.length] = new NoteHold(holdData[i][1], holdData[i][0], holdData[i][2], holdData[i][3], Math.floor(holdData[i][0] * GameOptions.ENGINE_TICK_RATE), Math.floor(holdData[i][3] * GameOptions.ENGINE_TICK_RATE));
            }

            // Load Mines
            chart.Mines = [];
            var mineData:Array = dataSource.getMineData(options.selectedChartID);
            for (i = 0; i < mineData.length; i++)
            {
                chart.Mines[chart.Mines.length] = new NoteMine(mineData[i][1], mineData[i][0], Math.floor(mineData[i][0] * GameOptions.ENGINE_TICK_RATE));
            }

            isMusicLoaded = true;
            isChartLoaded = true;

            loadComplete();
        }

        public function get progress():int
        {
            return (isMusicLoaded && isChartLoaded) ? 100 : 0;
        }

        public function loadComplete():void
        {
            if (isChartLoaded && isMusicLoaded)
            {
                isLoaded = true;
                dispatchEvent(new Event(Event.COMPLETE));
            }
        }

        public function getSoundObject():Sound
        {
            if (rateRate != 1)
                return rateSound;
            return sound;
        }

        private function stopSound(e:*):void
        {
            musicIsPlaying = false;
        }

        ///- Song Function
        public function start(seek:int = 0):void
        {
            updateMusicDelay();
            if (soundChannel)
            {
                soundChannel.removeEventListener(Event.SOUND_COMPLETE, stopSound);
                soundChannel.stop();
            }
            if (sound)
            {
                soundChannel = sound.play(musicDelay * 1000 / GameOptions.ENGINE_TICK_RATE + seek);
                soundChannel.soundTransform = SoundMixer.soundTransform;
                soundChannel.addEventListener(Event.SOUND_COMPLETE, stopSound);
            }
            musicIsPlaying = true;
        }

        public function stop():void
        {
            if (soundChannel)
            {
                soundChannel.removeEventListener(Event.SOUND_COMPLETE, stopSound);
                soundChannel.stop();
                musicPausePosition = 0;
                soundChannel = null;
            }
            musicIsPlaying = false;
        }

        public function pause():void
        {
            var pausePosition:int = 0;
            if (soundChannel)
                pausePosition = soundChannel.position;
            stop();
            musicPausePosition = pausePosition;
        }

        public function resume():void
        {
            if (sound)
            {
                soundChannel = sound.play(musicPausePosition);
                soundChannel.addEventListener(Event.SOUND_COMPLETE, stopSound);
            }
            musicIsPlaying = true;
        }

        public function reset():void
        {
            stop();
            start();
        }

        ///- Note Functions
        public function getNote(index:int):Note
        {
            if (noteMod.required())
            {
                return noteMod.transformNote(index);
            }
            else
            {
                return chart.Notes[index];
            }
        }

        public function get totalNotes():int
        {
            if (noteMod.required())
            {
                return noteMod.transformTotalNotes();
            }

            if (!chart.Notes)
            {
                return 0;
            }

            return chart.Notes.length;
        }

        ///- Hold Functions
        public function getHold(index:int):NoteHold
        {
            if (noteMod.required())
            {
                return noteMod.transformHold(index);
            }
            else
            {
                return chart.Holds[index];
            }
        }

        public function get totalHolds():int
        {
            if (noteMod.required())
            {
                return noteMod.transformTotalHolds();
            }

            if (!chart.Holds)
            {
                return 0;
            }

            return chart.Holds.length;
        }

        ///- Mine Functions
        public function getMine(index:int):NoteMine
        {
            if (noteMod.required())
            {
                return noteMod.transformMine(index);
            }
            else
            {
                return chart.Mines[index];
            }
        }

        public function get totalMines():int
        {
            if (noteMod.required())
            {
                return noteMod.transformTotalMines();
            }

            if (!chart.Mines)
            {
                return 0;
            }

            return chart.Mines.length;
        }

        public function get chartTime():Number
        {
            if (noteMod.required())
            {
                return noteMod.transformSongLength();
            }

            if (!chart.Notes || chart.Notes.length <= 0)
            {
                return 0;
            }

            return getNote(totalNotes - 1).time + 3; // 3 second for fadeout.
        }

        public function get chartTimeFormatted():String
        {
            var totalSecs:int = chartTime;
            var minutes:String = Math.floor(totalSecs / 60).toString();
            var seconds:String = (totalSecs % 60).toString();

            if (seconds.length == 1)
            {
                seconds = "0" + seconds;
            }

            return minutes + ":" + seconds;
        }

        public function get frameRate():int
        {
            return _gvars.activeUser.frameRate;
        }

        public function updateMusicDelay():void
        {
            options = _gvars.options;
            rateRate = options.songRate;
            noteMod.start(options);
            musicDelay = 0;
        }

        public function getPosition():int
        {
            return soundChannel ? soundChannel.position - musicDelay * 1000 / GameOptions.ENGINE_TICK_RATE : 0;
        }


        private var rateReverse:Boolean = false;
        private var rateRate:Number = 1;
        private var rateSound:Sound;
        private var rateSample:int = 0;
        private var rateSampleCount:int = 0;
        private var rateSamples:ByteArray = new ByteArray();
        private var mp3Rate:Number = 1;

        private function onRateSound(e:SampleDataEvent):void
        {
            var osamples:int = 0;
            var sample:int = 0;
            var sampleDiff:int = 0;
            while (osamples < 4096)
            {
                sample = (e.position + osamples) * rateRate;
                sampleDiff = sample - rateSample;
                while (sampleDiff < 0 || sampleDiff >= rateSampleCount)
                {
                    rateSample += rateSampleCount;
                    rateSamples.position = 0;
                    sampleDiff = sample - rateSample;
                    var seekExtract:Boolean = (sampleDiff < 0 || sampleDiff > 8192);
                    rateSampleCount = (rateSound as Object).extract(rateSamples, 4096, seekExtract ? sample * mp3Rate : -1);

                    if (seekExtract)
                    {
                        rateSample = sample;
                        sampleDiff = sample - rateSample;
                    }

                    if (rateSampleCount <= 0)
                        return;
                }
                rateSamples.position = 8 * sampleDiff;
                e.data.writeFloat(rateSamples.readFloat());
                e.data.writeFloat(rateSamples.readFloat());
                osamples++;
            }
        }
    }
}
