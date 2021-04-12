package game.controls
{
    import classes.GameReceptor;
    import classes.Noteskins;
    import classes.chart.Note;
    import classes.chart.NoteHold;
    import classes.chart.Song;
    import com.flashfla.utils.ObjectPool;
    import com.flashfla.utils.ObjectPoolHolds;
    import com.flashfla.utils.ObjectPoolMines;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import game.GameOptions;
    import classes.chart.NoteMine;

    public class NoteBox extends Sprite
    {
        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _noteskins:Noteskins = Noteskins.instance;
        private var options:GameOptions;
        public var song:Song;

        public var scrollSpeed:Number;
        public var readahead:Number;

        public var totalNotes:int;
        public var noteCount:int;
        public var notePool:Array;
        public var notes:Array;

        public var totalHolds:int;
        public var holdCount:int;
        public var holdPool:Array;
        public var holds:Array;
        public var holdPlane:Sprite;

        public var totalMines:int;
        public var mineCount:int;
        public var minePool:ObjectPoolMines;
        public var mines:Array;

        public var columnCount:int = 4;
        public var receptorMap:Object;
        public var receptorArray:Array;

        private var lastGamePosition:int = 0;
        public var positionOffsetMax:Object;
        private var receptorAlpha:Number;

        private var enabledHolds:Boolean = true;
        private var enabledMines:Boolean = true;

        private var updateReceptorRef:MovieClip;
        private var updateOffsetRef:Number;
        private var updateBaseOffsetRef:Number;

        private var receptorRotations:Object = {4: [90, 0, 180, 270],
                6: [90, 135, 0, 180, 225, 270],
                8: [90, 0, 180, 270, 90, 0, 180, 270]};

        public function NoteBox(song:Song, options:GameOptions)
        {
            this.song = song;
            this.options = options;

            enabledHolds = this.options.enableHolds;
            enabledMines = this.options.enableMines;

            this.columnCount = options.noteDirections.length;

            var i:int = 0;
            var direction:String;
            var color:String

            // Create Object Pools
            notePool = [];
            holdPool = [];
            minePool = new ObjectPoolMines();
            for each (var item:Object in _noteskins.data)
            {
                notePool[item.id] = {};
                holdPool[item.id] = {};
                for each (direction in options.noteDirections)
                {
                    notePool[item.id][direction] = [];
                    holdPool[item.id][direction] = [];
                    for each (color in options.noteColors)
                    {
                        notePool[item.id][direction][color] = new ObjectPool();
                        holdPool[item.id][direction][color] = new ObjectPoolHolds();
                    }
                }
            }

            // Check for invalid Noteskin / Pool
            if (notePool[options.noteskin] == null)
            {
                options.noteskin = 1;
            }

            // Prefill Object Pools for active noteskin.
            var preLoadCount:int = 4;
            for each (direction in options.noteDirections)
            {
                for each (color in options.noteColors)
                {
                    var pool:ObjectPool = notePool[options.noteskin][direction][color];

                    for (i = 0; i < preLoadCount; i++)
                    {
                        var gameNote:GameNote = pool.addObject(new GameNote(0, direction, color, 1 * 1000, 0, options.noteskin));
                        gameNote.visible = false;
                        pool.unmarkObject(gameNote);
                        addChild(gameNote);
                    }
                }
            }

            // Setup Receptors
            i = 0;
            receptorMap = {};
            receptorArray = [];

            var recp:MovieClip;

            for each (direction in options.noteDirections)
            {
                recp = _noteskins.getReceptor(options.noteskin, direction);
                recp.KEY = direction;
                recp.INDEX = receptorArray.length;
                receptorMap[direction] = recp;
                addChildAt(recp, 0);
                receptorArray[receptorArray.length] = recp;

                if (recp is GameReceptor)
                    (recp as GameReceptor).animationSpeed = options.receptorAnimationSpeed;
            }

            // Holds
            holdPlane = new Sprite();
            addChildAt(holdPlane, 0);

            // Other Stuff
            scrollSpeed = options.scrollSpeed;
            readahead = (Main.GAME_HEIGHT / GameOptions.ENGINE_SCROLL_PIXELS * 1000 / scrollSpeed) + 250;
            receptorAlpha = 1.0;

            notes = [];
            noteCount = 0;
            totalNotes = song.totalNotes;

            holds = [];
            holdCount = 0;
            totalHolds = song.totalHolds;

            mines = [];
            mineCount = 0;
            totalMines = song.totalMines;
        }

        public function noteRealSpawnRotation(dir:String, noteskin:int):Number
        {
            var hasRotation:Boolean = (_noteskins.data[noteskin]["rotation"] != 0);

            if (hasRotation)
                return receptorRotations[columnCount][receptorMap[dir].INDEX];

            return 0;
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        public function get nextNote():Note
        {
            return noteCount < totalNotes ? song.getNote(noteCount) : null;
        }

        public function spawnNextNote(engine_tick:int, current_position:int = 0):GameNote
        {
            if (nextNote)
            {
                return spawnArrow(nextNote, current_position);
            }

            return null;
        }

        public function spawnArrow(note:Note, engine_tick:int, current_position:int = 0):GameNote
        {
            var direction:String = note.direction;
            var colour:String = options.getNewNoteColor(note.colour);
            var gameNote:GameNote;
            if (options.DISABLE_NOTE_POOL)
            {
                gameNote = new GameNote(noteCount++, direction, colour, note.time * 1000, note.frame, options.noteskin);
            }
            else
            {
                var spawnPoolRef:ObjectPool = notePool[options.noteskin][direction][colour];
                if (!spawnPoolRef)
                {
                    spawnPoolRef = notePool[options.noteskin][direction][colour] = new ObjectPool();
                }

                gameNote = spawnPoolRef.getObject();
                if (gameNote)
                {
                    gameNote.ID = noteCount++;
                    gameNote.DIR = direction;
                    gameNote.TIME = note.time * 1000;
                    gameNote.TICK = note.frame;
                    gameNote.alpha = 1;
                }
                else
                {
                    gameNote = spawnPoolRef.addObject(new GameNote(noteCount++, direction, colour, note.time * 1000, note.frame, options.noteskin));
                    addChild(gameNote);
                }
            }

            gameNote.SPAWN_PROGRESS = gameNote.TIME - 1000; // readahead;
            gameNote.rotation = receptorMap[direction].rotation;

            if (options.modEnabled("_spawn_noteskin_data_rotation"))
                gameNote.rotation = noteRealSpawnRotation(direction, options.noteskin);

            if (options.modEnabled("_spawn_noteskin_nyancat"))
                gameNote.rotation = options.scrollDirection == "up" ? 180 : 0;

            if (options.noteScale != 1.0)
            {
                gameNote.scaleX = gameNote.scaleY = options.noteScale;
            }
            else if (options.modEnabled("mini") && !options.modEnabled("mini_resize") && options.noteScale == 1.0)
            {
                gameNote.scaleX = gameNote.scaleY = 0.75;
            }
            else
            {
                gameNote.scaleX = gameNote.scaleY = 1;
            }

            if (options.modEnabled("note_dark"))
            {
                gameNote.alpha = 0.2;
            }

            gameNote.visible = true;
            this.setChildIndex(gameNote, 5);
            notes.push(gameNote);

            updateNotePosition(gameNote, current_position, engine_tick);

            return gameNote;
        }

        public function updateNotePosition(note:GameNote, position:int, engine_tick:int):void
        {
            updateReceptorRef = receptorMap[note.DIR];
            updateOffsetRef = (note.TIME - position) / 1000 * GameOptions.ENGINE_SCROLL_PIXELS * scrollSpeed;
            updateBaseOffsetRef = (position - note.SPAWN_PROGRESS) / (note.TIME - note.SPAWN_PROGRESS);

            if (updateReceptorRef.VERTEX == "x")
            {
                note.x = updateReceptorRef.x - updateOffsetRef * updateReceptorRef.DIRECTION;
                note.y = updateReceptorRef.y;
            }
            else if (updateReceptorRef.VERTEX == "y")
            {
                note.y = updateReceptorRef.y - updateOffsetRef * updateReceptorRef.DIRECTION;
                note.x = updateReceptorRef.x;
            }

            // Position Mods
            if (options.modEnabled("tornado"))
            {
                var tornadoOffset:Number = Math.sin(updateBaseOffsetRef * Math.PI) * (options.receptorSpacing / 2);
                if (updateReceptorRef.VERTEX == "x")
                {
                    note.y += tornadoOffset;
                }
                if (updateReceptorRef.VERTEX == "y")
                {
                    note.x += tornadoOffset;
                }
            }

            // Rotation Mods
            if (options.modEnabled("rotating"))
            {
                note.rotation = (updateBaseOffsetRef * 6 * 90) + updateReceptorRef.rotation;
            }

            if (options.modEnabled("dizzy_note"))
            {
                var dizRotValue:Number = (position / 22);
                note.rotation = updateReceptorRef.rotation + dizRotValue;
            }

            if (options.modEnabled("rotation_lock"))
            {
                note.rotation = updateReceptorRef.rotation;
            }

            // Alpha Mods
            // switched hidden and sudden, mods were reversed!
            if (options.modEnabled("hidden"))
            {
                note.alpha = 1 - updateBaseOffsetRef;
            }

            if (options.modEnabled("sudden"))
            {
                note.alpha = updateBaseOffsetRef;
            }

            if (options.modEnabled("blink"))
            {
                var blink_offset:Number = (1 - updateBaseOffsetRef) % 0.4;
                var blink_hidden:Boolean = (blink_offset > 0.2);
                note.alpha = (blink_hidden ? 0 : (note.alpha != 1 && note.alpha != 0 ? note.alpha : 1));
            }

            // Scale Mods
            if (options.noteScale == 1 && options.modEnabled("mini_resize") && !options.modEnabled("mini"))
            {
                note.scaleX = note.scaleY = 1 - (updateBaseOffsetRef * 0.65);
            }

            if (options.modEnabled("scale_lock"))
            {
                note.scaleX = updateReceptorRef.scaleX;
                note.scaleY = updateReceptorRef.scaleY;
            }

            //note.rotationX = updateReceptorRef.rotationX;
            //note.rotationY = updateReceptorRef.rotationY;
            //note.rotationZ = updateReceptorRef.rotationZ;
        }

        private var removeNoteIndex:int = 0;
        private var removeNoteRef:GameNote;

        public function removeNote(id:int):void
        {
            for (removeNoteIndex = 0; removeNoteIndex < notes.length; removeNoteIndex++)
            {
                removeNoteRef = notes[removeNoteIndex];
                if (removeNoteRef.ID == id)
                {
                    if (!options.DISABLE_NOTE_POOL)
                    {
                        notePool[removeNoteRef.NOTESKIN][removeNoteRef.DIR][removeNoteRef.COLOR].unmarkObject(removeNoteRef);
                        removeNoteRef.visible = false;
                    }
                    else
                    {
                        removeChild(removeNoteRef);
                    }

                    notes.splice(removeNoteIndex, 1);
                    break;
                }
            }
        }


        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        public function get nextHold():NoteHold
        {
            return holdCount < totalHolds ? song.getHold(holdCount) : null;
        }

        public function spawnHold(note:NoteHold, engine_tick:int, current_position:int = 0):GameNoteHold
        {
            var direction:String = note.direction;
            var colour:String = options.getNewNoteColor(note.colour);
            var gameNote:GameNoteHold;

            var spawnPoolRef:ObjectPoolHolds = holdPool[options.noteskin][direction][colour];
            if (!spawnPoolRef)
            {
                spawnPoolRef = holdPool[options.noteskin][direction][colour] = new ObjectPoolHolds();
            }

            gameNote = spawnPoolRef.getObject();
            if (gameNote)
            {
                gameNote.ID = holdCount++;
                gameNote.DIR = direction;
                gameNote.TIME = note.time * 1000;
                gameNote.TICK = note.frame;
                gameNote.STATE = GameNoteHold.SPAWN;
                gameNote.alpha = 1;
            }
            else
            {
                gameNote = spawnPoolRef.addObject(new GameNoteHold(holdCount++, direction, colour, note.time * 1000, note.frame, options.noteskin));
                holdPlane.addChild(gameNote);
            }
            gameNote.setSpeed(options);
            gameNote.setTail(note.tail * 1000);

            gameNote.SPAWN_PROGRESS = gameNote.TIME - 1000; // readahead;

            if (options.modEnabled("note_dark"))
            {
                gameNote.alpha = 0.2;
            }

            gameNote.visible = true;
            holdPlane.setChildIndex(gameNote, 0);
            holds.push(gameNote);

            updateHoldPosition(gameNote, current_position, engine_tick);

            return gameNote;
        }

        public function updateHoldPosition(note:GameNoteHold, position:int, engine_tick:int):void
        {
            updateReceptorRef = receptorMap[note.DIR];
            updateOffsetRef = (note.TIME - position) / 1000 * GameOptions.ENGINE_SCROLL_PIXELS * scrollSpeed;
            updateBaseOffsetRef = (position - note.SPAWN_PROGRESS) / (note.TIME - note.SPAWN_PROGRESS);

            if (updateReceptorRef.VERTEX == "x")
            {
                note.x = updateReceptorRef.x - updateOffsetRef * updateReceptorRef.DIRECTION;
                note.y = updateReceptorRef.y;
            }
            else if (updateReceptorRef.VERTEX == "y")
            {
                note.y = updateReceptorRef.y - updateOffsetRef * updateReceptorRef.DIRECTION;
                note.x = updateReceptorRef.x;
            }

            if (updateReceptorRef.HOLD_ROTATION != note.rotation)
                note.rotation = updateReceptorRef.HOLD_ROTATION;

            // Position Mods
            if (options.modEnabled("tornado") && updateOffsetRef > 0)
            {
                var tornadoOffset:Number = Math.sin(updateBaseOffsetRef * Math.PI) * (options.receptorSpacing / 2);
                if (updateReceptorRef.VERTEX == "x")
                {
                    note.y += tornadoOffset;
                }
                if (updateReceptorRef.VERTEX == "y")
                {
                    note.x += tornadoOffset;
                }
            }

            // Scale Mods
            var useLineScale:Boolean = options.modEnabled("scale_lock");
            if (useLineScale)
            {
                note.scaleX = updateReceptorRef.scaleX;
            }

            // Alpha Mods
            // switched hidden and sudden, mods were reversed!
            if (options.modEnabled("hidden"))
            {
                note.alpha = 1 - updateBaseOffsetRef;
            }

            if (options.modEnabled("sudden"))
            {
                note.alpha = updateBaseOffsetRef;
            }

            if (options.modEnabled("blink"))
            {
                var blink_offset:Number = (1 - updateBaseOffsetRef) % 0.4;
                var blink_hidden:Boolean = (blink_offset > 0.2);
                note.alpha = (blink_hidden ? 0 : (note.alpha != 1 && note.alpha != 0 ? note.alpha : 1));
            }

            if (options.modEnabled("speed_update"))
                note.setSpeed(options);

            if (note.STATE == GameNoteHold.HELD || useLineScale)
                note.updateTail(position, useLineScale);
        }

        private var removeHoldIndex:int = 0;
        private var removeHoldRef:GameNoteHold;

        public function removeHold(id:int):void
        {
            for (removeHoldIndex = 0; removeHoldIndex < holds.length; removeHoldIndex++)
            {
                removeHoldRef = holds[removeHoldIndex];
                if (removeHoldRef.ID == id)
                {
                    if (!options.DISABLE_NOTE_POOL)
                    {
                        holdPool[removeHoldRef.NOTESKIN][removeHoldRef.DIR][removeHoldRef.COLOR].unmarkObject(removeHoldRef);
                        removeHoldRef.visible = false;
                    }
                    else
                    {
                        removeChild(removeHoldRef);
                    }

                    holds.splice(removeHoldIndex, 1);
                    break;
                }
            }
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        public function get nextMine():NoteMine
        {
            return mineCount < totalMines ? song.getMine(mineCount) : null;
        }

        public function spawnMine(note:NoteMine, engine_tick:int, current_position:int = 0):GameNoteMine
        {
            var direction:String = note.direction;
            var gameMine:GameNoteMine;
            if (options.DISABLE_NOTE_POOL)
            {
                gameMine = new GameNoteMine(mineCount++, direction, note.time * 1000, note.frame);
            }
            else
            {
                gameMine = minePool.getObject();
                if (gameMine)
                {
                    gameMine.ID = mineCount++;
                    gameMine.DIR = direction;
                    gameMine.TIME = note.time * 1000;
                    gameMine.TICK = note.frame;
                    gameMine.STATE = GameNoteMine.ARMED;
                    gameMine.alpha = 1;
                }
                else
                {
                    gameMine = minePool.addObject(new GameNoteMine(mineCount++, direction, note.time * 1000, note.frame));
                    addChild(gameMine);
                }
            }

            gameMine.SPAWN_PROGRESS = gameMine.TIME - 1000; // readahead;

            if (options.noteScale != 1.0)
            {
                gameMine.scaleX = gameMine.scaleY = options.noteScale;
            }
            else if (options.modEnabled("mini") && !options.modEnabled("mini_resize") && options.noteScale == 1.0)
            {
                gameMine.scaleX = gameMine.scaleY = 0.75;
            }
            else
            {
                gameMine.scaleX = gameMine.scaleY = 1;
            }

            if (options.modEnabled("note_dark"))
            {
                gameMine.alpha = 0.2;
            }

            gameMine.visible = true;
            this.setChildIndex(gameMine, 5);
            mines.push(gameMine);

            updateMinePosition(gameMine, current_position, engine_tick);

            return gameMine;
        }

        public function updateMinePosition(note:GameNoteMine, position:int, engine_tick:int):void
        {
            updateReceptorRef = receptorMap[note.DIR];
            updateOffsetRef = (note.TIME - position) / 1000 * GameOptions.ENGINE_SCROLL_PIXELS * scrollSpeed;
            updateBaseOffsetRef = (position - note.SPAWN_PROGRESS) / (note.TIME - note.SPAWN_PROGRESS);

            if (updateReceptorRef.VERTEX == "x")
            {
                note.x = updateReceptorRef.x - updateOffsetRef * updateReceptorRef.DIRECTION;
                note.y = updateReceptorRef.y;
            }
            else if (updateReceptorRef.VERTEX == "y")
            {
                note.y = updateReceptorRef.y - updateOffsetRef * updateReceptorRef.DIRECTION;
                note.x = updateReceptorRef.x;
            }

            // Position Mods
            if (options.modEnabled("tornado"))
            {
                var tornadoOffset:Number = Math.sin(updateBaseOffsetRef * Math.PI) * (options.receptorSpacing / 2);
                if (updateReceptorRef.VERTEX == "x")
                {
                    note.y += tornadoOffset;
                }
                if (updateReceptorRef.VERTEX == "y")
                {
                    note.x += tornadoOffset;
                }
            }

            // Alpha Mods
            // switched hidden and sudden, mods were reversed!
            if (options.modEnabled("hidden"))
            {
                note.alpha = 1 - updateBaseOffsetRef;
            }

            if (options.modEnabled("sudden"))
            {
                note.alpha = updateBaseOffsetRef;
            }

            if (options.modEnabled("blink"))
            {
                var blink_offset:Number = (1 - updateBaseOffsetRef) % 0.4;
                var blink_hidden:Boolean = (blink_offset > 0.2);
                note.alpha = (blink_hidden ? 0 : (note.alpha != 1 && note.alpha != 0 ? note.alpha : 1));
            }

            // Scale Mods
            if (options.noteScale == 1 && options.modEnabled("mini_resize") && !options.modEnabled("mini"))
            {
                note.scaleX = note.scaleY = 1 - (updateBaseOffsetRef * 0.65);
            }

            if (options.modEnabled("scale_lock"))
            {
                note.scaleX = updateReceptorRef.scaleX;
                note.scaleY = updateReceptorRef.scaleY;
            }

            //note.rotationX = updateReceptorRef.rotationX;
            //note.rotationY = updateReceptorRef.rotationY;
            //note.rotationZ = updateReceptorRef.rotationZ;
        }

        private var removeMineIndex:int = 0;
        private var removeMineRef:GameNoteMine;

        public function removeMine(id:int):void
        {
            for (removeMineIndex = 0; removeMineIndex < mines.length; removeMineIndex++)
            {
                removeMineRef = mines[removeMineIndex];
                if (removeMineRef.ID == id)
                {
                    if (!options.DISABLE_NOTE_POOL)
                    {
                        minePool.unmarkObject(removeMineRef);
                        removeMineRef.visible = false;
                    }
                    else
                    {
                        removeChild(removeMineRef);
                    }

                    mines.splice(removeMineIndex, 1);
                    break;
                }
            }
        }


        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        public function getReceptor(dir:String):MovieClip
        {
            return receptorMap[dir];
        }

        public function receptorFeedback(dir:String, score:int):void
        {
            if (!options.displayReceptorAnimations)
                return;

            var f:int = 2;
            var c:uint = 0;

            switch (score)
            {
                case 100:
                case 50:
                case 15:
                    f = 2;
                    c = options.judgeColours[0];
                    break;
                case 25:
                    f = 7;
                    c = options.judgeColours[2];
                    break;
                case 5:
                case -5:
                    f = 12;
                    c = options.judgeColours[3];
                    break;
                default:
                    return;
            }

            var recepterFeedbackRef:MovieClip = receptorMap[dir];
            if (recepterFeedbackRef is GameReceptor)
            {
                (recepterFeedbackRef as GameReceptor).playAnimation(c);
            }
            else
            {
                recepterFeedbackRef.gotoAndPlay(f);
            }
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        public function update(position:int, engine_tick:int):void
        {
            var eclipsed:Number = (position - lastGamePosition) / 1000;
            /*
               var curSine:Number = Math.sin(position / 1000);
               for each (receptor in receptorArray)
               {
               receptor.DIRECTION = curSine;
               receptor.y += curSine * 2;
               }
             */

            var nextRef:Note = nextNote;
            while (nextRef && nextRef.time * 1000 - position < readahead)
            {
                spawnArrow(nextRef, engine_tick, position);
                nextRef = nextNote;
            }

            if (enabledHolds)
            {
                var nextHoldRef:NoteHold = nextHold;
                while (nextHoldRef && nextHoldRef.time * 1000 - position < readahead)
                {
                    spawnHold(nextHoldRef, engine_tick, position);
                    nextHoldRef = nextHold;
                }
            }

            if (enabledMines)
            {
                var nextMineRef:NoteMine = nextMine;
                while (nextMineRef && nextMineRef.time * 1000 - position < readahead)
                {
                    spawnMine(nextMineRef, engine_tick, position);
                    nextMineRef = nextMine;
                }
            }

            if (options.modEnabled("wave"))
            {
                var waveOffset:int = 0;
                for each (var receptor:MovieClip in receptorArray)
                {
                    if (receptor.VERTEX == "x")
                    {
                        receptor.y = receptor.ORIG_Y + (Math.sin((position + waveOffset) / 1000) * 35);
                    }
                    else if (receptor.VERTEX == "y")
                    {
                        receptor.x = receptor.ORIG_X + (Math.sin((position + waveOffset) / 1000) * 35);
                    }
                    waveOffset += 165;
                }
            }

            if (options.modEnabled("drunk"))
            {
                var drunkOffset:int = 0;
                for each (receptor in receptorArray)
                {
                    receptor.rotation = receptor.ORIG_ROT + (Math.sin((position + drunkOffset) / 1387) * 25);
                    drunkOffset += 165;
                }
            }

            if (options.modEnabled("dizzy"))
            {
                var dizRotValue:Number = eclipsed * options.scalingDizzyMod;
                for each (receptor in receptorArray)
                {
                    receptor.rotation += dizRotValue;
                }
            }

            if (options.modEnabled("hide"))
            {
                for each (var recp:MovieClip in receptorArray)
                {
                    recp.alpha = (recp.currentFrame == 1) ? 0.0 : receptorAlpha;
                }
            }

            for each (var note:GameNote in notes)
            {
                updateNotePosition(note, position, engine_tick);
            }
            for each (var hold:GameNoteHold in holds)
            {
                updateHoldPosition(hold, position, engine_tick);
            }
            for each (var mine:GameNoteMine in mines)
            {
                updateMinePosition(mine, position, engine_tick);
            }

            lastGamePosition = position;
        }


        public function reset():void
        {
            for each (var note:GameNote in notes)
            {
                if (!options.DISABLE_NOTE_POOL)
                {
                    notePool[note.NOTESKIN][note.DIR][note.COLOR].unmarkObject(note);
                    note.visible = false;
                }
                else
                {
                    removeChild(note);
                }
            }
            for each (var hold:GameNoteHold in holds)
            {
                if (!options.DISABLE_NOTE_POOL)
                {
                    holdPool[hold.NOTESKIN][hold.DIR][hold.COLOR].unmarkObject(hold);
                    hold.visible = false;
                }
                else
                {
                    removeChild(hold);
                }
            }
            for each (var mine:GameNoteMine in mines)
            {
                if (!options.DISABLE_NOTE_POOL)
                {
                    minePool.unmarkObject(mine);
                    mine.visible = false;
                }
                else
                {
                    removeChild(mine);
                }
            }

            notes = [];
            noteCount = 0;
            holds = [];
            holdCount = 0;
            mines = [];
            mineCount = 0;
        }

        public function position():void
        {
            var data:Object = _noteskins.getInfo(options.noteskin);
            var hasRotation:Boolean = (data.rotation != 0);
            var gap:int = options.receptorSpacing;
            var noteScale:Number = options.noteScale;

            var splitGap:int = options.receptorSplitSpacing * (gap < 0 ? -1 : 1);

            var recp:MovieClip;
            var startPos:int;
            var i:int;

            //if (data.width > 64)
            //gap += data.width - 64;

            // User-defined note scale
            if (noteScale != 1)
            {
                if (noteScale < 0.1)
                    noteScale = 0.1; // min
                else if (noteScale > 2.0)
                    noteScale = 2.0; // max
                gap *= noteScale
            }
            else if (options.modEnabled("mini") && !options.modEnabled("mini_resize"))
                gap *= 0.75;

            if (columnCount > 4 && (gap >= 100 || gap <= -100))
                gap *= 0.8;

            switch (options.scrollDirection)
            {
                case "down":
                    startPos = -((gap * (columnCount - 1)) / 2) + 160;
                    for (i = 0; i < columnCount; i++)
                    {
                        recp = receptorArray[i];
                        recp.x = startPos + (gap * i);
                        recp.y = 400;

                        if (i < (columnCount / 2))
                            recp.x -= splitGap;
                        else
                            recp.x += splitGap;

                        if (hasRotation)
                            recp.rotation = receptorRotations[columnCount][i];

                        recp.VERTEX = "y";
                        recp.DIRECTION = 1;
                        recp.HOLD_ROTATION = 180;
                    }
                    positionOffsetMax = {"min_x": -150, "max_x": 150, "min_y": -150, "max_y": 50};
                    break;

                default:
                    startPos = -((gap * (columnCount - 1)) / 2) + 160;
                    for (i = 0; i < columnCount; i++)
                    {
                        recp = receptorArray[i];
                        recp.x = startPos + (gap * i);
                        recp.y = 90;

                        if (i < (columnCount / 2))
                            recp.x -= splitGap;
                        else
                            recp.x += splitGap;


                        if (hasRotation)
                            recp.rotation = receptorRotations[columnCount][i];

                        recp.VERTEX = "y";
                        recp.DIRECTION = -1;
                        recp.HOLD_ROTATION = 0;
                    }
                    positionOffsetMax = {"min_x": -150, "max_x": 150, "min_y": -50, "max_y": 150};
                    break;
            }

            for each (recp in receptorArray)
            {
                recp.ORIG_X = recp.x;
                recp.ORIG_Y = recp.y;
                recp.ORIG_ROT = recp.rotation;
            }

            if (options.modEnabled("rotate_cw"))
                for each (recp in receptorArray)
                    recp.rotation += 90;

            if (options.modEnabled("rotate_ccw"))
                for each (recp in receptorArray)
                    recp.rotation -= 90;

            if (options.noteScale != 1.0)
                for each (recp in receptorArray)
                    recp.scaleX = recp.scaleY = options.noteScale;

            if (options.modEnabled("mini") && !options.modEnabled("mini_resize") && options.noteScale == 1.0)
                for each (recp in receptorArray)
                    recp.scaleX = recp.scaleY = 0.75;

            if (options.modEnabled("mini_resize") && !options.modEnabled("mini") && options.noteScale == 1.0)
                for each (recp in receptorArray)
                    recp.scaleX = recp.scaleY = 0.5;

            if (options.modEnabled("dark"))
                receptorAlpha = 0.3;

            for each (recp in receptorArray)
                recp.alpha = receptorAlpha;

            if (!options.displayReceptor)
                for each (recp in receptorArray)
                    recp.visible = false;
        }
    }
}
