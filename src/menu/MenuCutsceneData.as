package menu
{
    import af.assets.PACosmoVibe;
    import af.assets.PAGoldstinger;
    import af.assets.PAHalogen;
    import af.assets.PARobinHoot;
    import af.assets.PATemmie;
    import af.assets.PAVelocity;
    import af.assets.PAhi19hi19;
    import af.assets.PNCosmoVibe;
    import af.assets.PNGoldstinger;
    import af.assets.PNHalogen;
    import af.assets.PNRobinHoot;
    import af.assets.PNTemmie;
    import af.assets.PNVelocity;
    import af.assets.PNhi19hi19;
    import af.assets.Chapter12Overlay;

    public class MenuCutsceneData
    {
        // Import Assets
        PARobinHoot; // 0x22FC8C
        PAVelocity; // 0x8E0200
        PAGoldstinger; // 0x580784
        PAHalogen; // 0x254D64
        PAhi19hi19; // 0xFEFD05
        PACosmoVibe; // 0x8522FC
        PATemmie; // 0xFFFFFF

        PNRobinHoot;
        PNVelocity;
        PNGoldstinger;
        PNHalogen;
        PNhi19hi19;
        PNCosmoVibe;
        PNTemmie;

        Chapter12Overlay;

        public static function getLevel(level:int):Array
        {
            if (level == -3)
            {
                return LEVEL_SPLASH;
            }

            if (level == 1)
            {
                if (!Flags.canPlayLevel1())
                    return LEVEL_CELEBRATION_NOT_READY;
            }

            if (level >= 13 && level <= 16)
            {
                if (!Flags.SEEN_SOLO_CUTSCENE)
                {
                    Flags.SEEN_SOLO_CUTSCENE = true;
                    LocalStore.setVariable("af2021_seen_solo_cutscene", true);
                    return LEVEL_SOLO_INTRO;
                }
                else if (!Flags.SETUP_KEYS)
                {
                    return LEVEL_KEYS_REMIND;
                }
            }

            return MenuCutsceneData["LEVEL_" + level];
        }

        public static var LEVEL_0:Array = [[0, "Play"]];
        //public static var LEVEL_1:Array = [[0, "Play"]];
        //public static var LEVEL_2:Array = [[0, "Play"]];
        //public static var LEVEL_3:Array = [[0, "Play"]];
        //public static var LEVEL_4:Array = [[0, "Play"]];
        //public static var LEVEL_5:Array = [[0, "Play"]];
        //public static var LEVEL_6:Array = [[0, "Play"]];
        //public static var LEVEL_7:Array = [[0, "Play"]];
        //public static var LEVEL_8:Array = [[0, "Play"]];
        //public static var LEVEL_9:Array = [[0, "Play"]];
        //public static var LEVEL_10:Array = [[0, "Play"]];
        //public static var LEVEL_11:Array = [[0, "Play"]];
        //public static var LEVEL_12:Array = [[0, "Play"]];
        //public static var LEVEL_13:Array = [[0, "Play"]];
        //public static var LEVEL_14:Array = [[0, "Play"]];
        //public static var LEVEL_15:Array = [[0, "Play"]];
        //public static var LEVEL_16:Array = [[0, "Play"]];
        public static var LEVEL_17:Array = [[0, "Play"]];

        public static var LEVEL_SPLASH:Array = [[0, "SetSprites", "RobinHoot", "Velocity"],
            [0, "SetAnimation", 0, "default"],
            [0, "SetAnimation", 1, "default"],
            [3, "FadeIn", 0, 1],
            [1, "Chat", 0, "Ahh.. My head."],
            [0, "Chat", 0, "Where am I?"],
            [0, "ChatHide"],
            [0, "FadeIn", 1, 1],
            [1, "Chat", 1, "Hey, you, you're finally awake."],
            [1, "Chat", 1, "You were trying to fly over the island right?"],
            [1, "SetAnimation", 0, "shock"],
            [0, "Chat", 1, "And walked right into my ambush.", 0.5],
            [0, "SetAnimation", 0, "default"],
            [0, "ChatHide"],
            [1, "Chat", 1, "So here's the deal."],
            [1, "Chat", 1, "You clear the challenges I present you."],
            [1, "Chat", 1, "And maybe I'll think about letting you leave."],
            [1, "Chat", 1, "Does that sound good to you?"],
            [1, "Chat", 0, "Doesn't sound like I have much of a choice here."],
            [1, "Chat", 1, "Well, you could just close the game and play the normal version."],
            [1, "Chat", 1, "Wouldn't be much of an April Fools event if you did though."],
            [1, "Chat", 0, "Yeah I guess you're right."],
            [0, "ChatHide"],
            [1, "Chat", 1, "Side note, I might have left some secrets around,\nif you could find them for me that would be great."],
            [1, "Chat", 1, "Thank you, bye."],
            [0, "ChatHide"],
            [0, "FadeOut", 1, 1],
            [0, "SetAnimation", 0, "closed"],
            [1, "Chat", 0, "Hopefully I can get out of here soon..."],
            [0, "Bail"]];

        public static var LEVEL_CELEBRATION_NOT_READY:Array = [[0, "SetSprites", "RobinHoot", "Goldstinger"],
            [0, "SetAnimation", 0, "default"],
            [0, "SetAnimation", 1, "default"],
            [1, "FadeIn", 0, 1],
            [0, "FadeIn", 1, 1],
            [1, "Chat", 1, "This level isn't ready yet."],
            [1, "Chat", 1, "I know it's weird that it starts here but isn't playable right away."],
            [1, "Chat", 1, "But come back once you've played the rest."],
            [1, "Chat", 1, "You don't even need to pass them."],
            [1, "Chat", 1, "You can navigate with using the left and right buttons\nor using the Left and Right Keys."],
            [1, "Chat", 1, "Play button or the Enter Key can be used to start the level."],
            [1, "Chat", 1, "I'd recommend starting at \"Matter\" and working your way right."],
            [1, "Chat", 0, "Okay thanks."],
            [1, "Chat", 1, "Also a word of warning, once you leave the initial island..."],
            [1, "Chat", 1, "...It gets exceptionally hard in some places."],
            [1, "Chat", 0, "Noted. Good Bye."],
            [0, "Bail"]];

        public static var LEVEL_SOLO_INTRO:Array = [[0, "SetSprites", "RobinHoot", "CosmoVibe"],
            [0, "SetAnimation", 0, "default"],
            [0, "SetAnimation", 1, "default"],
            [1, "FadeIn", 0, 1],
            [0, "FadeIn", 1, 1],
            [1, "Chat", 1, "I see you would like to play this level."],
            [1, "Chat", 1, "As it stands, you aren't equipped to do that at the moment."],
            [1, "Chat", 1, "I'd recommend heading into the game\noptions and viewing the Input tab."],
            [1, "Chat", 1, "It will have everything you need there."],
            [1, "Chat", 0, "Okay, thanks."],
            [0, "Bail"]];

        public static var LEVEL_KEYS_REMIND:Array = [[0, "SetSprites", "RobinHoot", "CosmoVibe"],
            [0, "SetAnimation", 0, "default"],
            [0, "SetAnimation", 1, "default"],
            [1, "FadeIn", 0, 1],
            [0, "FadeIn", 1, 1],
            [0, "SetAnimation", 1, "look_top_right"],
            [1, "Chat", 1, "If you can't find the options, it's in the top right corner."],
            [0, "SetAnimation", 1, "default"],
            [1, "Chat", 0, "Sorry, thanks."],
            [0, "Bail"]];

        // EXTREME MEGAMIX V
        public static var LEVEL_1:Array = [[0, "SetSprites", "RobinHoot", "Goldstinger"],
            [0, "SetAnimation", 0, "default"],
            [0, "SetAnimation", 1, "default"],
            [1, "FadeIn", 0, 1],
            [0, "FadeIn", 1, 1],
            [1, "Chat", 0, "So one final song?"],
            [0, "Chat", 1, "One final song."],
            [0, "Chat", 0, "Let me guess, it's really short and easy like the rest?"],
            [0, "Chat", 1, "If by short you mean not short, then yes."],
            [0, "Chat", 1, "It's the longest file in the entire event,\nand did have the most notes until last minute."],
            [0, "Chat", 1, "But I do believe Velocity has something to say to you."],
            [0, "FadeOut", 1],
            [1, "SetSprite", 1, "Velocity"],
            [0, "FadeIn", 1, 1],
            [1, "Chat", 1, "This is the last time I'll have an opportunity to talk to you."],
            [1, "Chat", 1, "If you've made it this far, I hope you've had a good time doing so."],
            [1, "Chat", 1, "I've spent the last 2 months working on this fun side project."],
            [1, "Chat", 1, "I wanted to do something different after 2020s event."],
            [0, "ChatHide"],
            [2, "Chat", 1, "So again, thanks."],
            [1, "Chat", 1, "And enjoy the final song that acted as the catalyst\nfor the creation of the whole thing."],
            [0, "Play"]];

        // Dark Matter
        public static var LEVEL_2:Array = [[0, "SetSprites", "RobinHoot", "Velocity"],
            [0, "SetAnimation", 0, "default"],
            [0, "SetAnimation", 1, "default"],
            [1, "FadeIn", 0, 1],
            [0, "FadeIn", 1, 1],
            [1, "Chat", 1, "So... this file was supposed to be something else..."],
            [0, "Chat", 1, "Quite awhile ago I watched a player go through some ITG charts."],
            [0, "Chat", 1, "It was pretty cool to see what could be done over there."],
            [0, "Chat", 1, "I put some thought into it to see if it was possible."],
            [0, "ChatHide"],
            [2, "Chat", 1, "It wasn't."],
            [0, "Chat", 0, "So what happened?"],
            [0, "Chat", 1, "I just gave up on the concept, but I still really liked the song."],
            [0, "Chat", 1, "It's an easy chart to introduce some new stuff at least."],
            [0, "Chat", 0, "New stuff?"],
            [0, "Chat", 1, "New stuff."],
            [0, "Play"]];

        // Nyan Cat
        public static var LEVEL_3:Array = [[0, "SetSprites", "RobinHoot", "Velocity"],
            [0, "SetAnimation", 0, "default"],
            [0, "SetAnimation", 1, "default"],
            [1, "FadeIn", 0, 1],
            [0, "FadeIn", 1, 1],
            [1, "Chat", 0, "Good day Velocity"],
            [0, "Chat", 1, "Pleasant meeting you here."],
            [0, "Chat", 1, "I'm looking for my cat..."],
            [0, "Chat", 1, "I lost her many years ago, but I believe I've finally found her again."],
            [0, "Chat", 1, "If you could assist me in tracking her, that would be of great help."],
            [0, "Chat", 0, "Sure, what do I need to do then?"],
            [0, "Chat", 1, "Just follow the meows to the end, I'm sure you will find her there."],
            [0, "Chat", 0, "Sounds easy enough, see you soon."],
            [0, "Play"]];

        // Megalovania
        public static var LEVEL_4:Array = [[0, "SetSprites", "RobinHoot", "Temmie"],
            [0, "SetAnimation", 0, "default"],
            [0, "SetAnimation", 1, "default"],
            [1, "FadeIn", 0, 1],
            [0, "FadeIn", 1, 1],
            [1, "Chat", 1, "hOI!!! i'm tEMMIE!!"],
            [1, "Chat", 1, "welcom to...", 0.7, 1],
            [1, "SetAnimation", 0, "shock"],
            [0, "Chat", 1, "da TEM SHOP!!!", 2],
            [1, "SetAnimation", 0, "default"],
            [0, "Chat", 0, "Hello Temmie"],
            [0, "Chat", 0, "I feel like I should get some supplies going\ninto this next level, what do you have?"],
            [0, "Chat", 1, "da best FOOB!"],
            [0, "Chat", 1, "3G - tem flake\n1G - tem flake (ON SALE,)"],
            [0, "Chat", 1, "20G - tem flake (expensiv)\n1000G - tem flake (premiem)"],
            [0, "Chat", 0, "Well hmm...\nI'll take a tem flake (premiem)"],
            [0, "ChatHide"],
            [0, "SetAnimation", 1, "shock"],
            [0.75, "ChatOther", "You pay 1000 credits."],
            [0, "ChatHide"],
            [0.75, "SetAnimation", 1, "default"],
            [0, "Chat", 1, "thanks PURCHASE!"],
            [0, "Chat", 0, "Thanks Temmie"],
            [0, "Chat", 1, "bOi"],
            [0, "Play"]];

        // Sound Chimera
        public static var LEVEL_5:Array = [[0, "SetSprite", 1, "Velocity"],
            [0, "SetAnimation", 1, "default"],
            [1, "FadeIn", 1, 1],
            [1, "Chat", 1, "So this is a callback to a song in a different game."],
            [0, "Chat", 1, "It was also the primary reason I went through\nthe effort of getting this type of map working."],
            [0, "Chat", 1, "Personally I enjoy the song but have issues passing it over there."],
            [0, "Chat", 1, "So I decided to just put it into FFR so I could play through it."],
            [0, "ChatHide"],
            [2, "Chat", 1, "Also I asked Halogen two months ago to select a difficulty."],
            [0, "Chat", 1, "I didn't mention what the reason was, but just gave the three options."],
            [0, "Chat", 1, "He just said Manticore, but after so deciding I ended up chosing\nthe easier one, as the majority of songs are already hard."],
            [0, "Chat", 1, "Either way, enjoy. It's basically the only normal file in this world."],
            [0, "Play"]];

        // Voyage 1970
        public static var LEVEL_6:Array = [[0, "SetSprites", "Velocity", "Goldstinger"],
            [0, "SetAnimation", 0, "default"],
            [0, "SetAnimation", 1, "default"],
            [1, "FadeIn", 0, 1],
            [0, "FadeIn", 1, 1],
            [1, "Chat", 0, "So there's been recent talk about some FFR\nplayers that really struggle with this sort of map."],
            [1, "Chat", 0, "It got me thinking that maybe there should\nbe a good practice file so they can improve."],
            [1, "Chat", 1, "So what did you choose?"],
            [1, "Chat", 0, "Nothing yet, I still need to ask."],
            [1, "Chat", 0, "Be right back."],
            [0, "ChatHide"],
            [0, "FadeOut", 0, 1],
            [0.3, "FadeOut", 1, 1],
            [3, "FadeIn", 0, 1],
            [1.2, "Chat", 0, "Hey Halogen"],
            [0, "ChatHide"],
            [2, "SetSprite", 1, "Halogen"],
            [0, "FadeIn", 1, 1],
            [1, "Chat", 1, "Hello"],
            [0, "Chat", 0, "Just curious, do you have anything in\nyour sim folder that looks like this?"],
            [0, "ChatOther", "Velocity passes a hastily written note with vague details."],
            [1, "Chat", 1, "uhhhhhh...."],
            [0, "Chat", 1, "Is this even allowed?"],
            [0, "Chat", 0, "Sure why not."],
            [0, "Chat", 1, "Well then, try this."],
            [0, "Play"]];

        // Speed Of Link
        public static var LEVEL_7:Array = [[0, "SetSprite", 0, "RobinHoot"],
            [0, "SetAnimation", 0, "default"],
            [1, "FadeIn", 0, 1],
            [1, "Chat", 0, "Hmmmmmmm...", 0.8],
            [1, "Chat", 0, "A quiet grove...", 0.8],
            [1, "Chat", 0, "A link to the past...", 0.8],
            [1, "Chat", 0, "And a sense of speed...", 0.8],
            [0, "ChatHide"],
            [2, "Chat", 0, "Whatever could this be referring to...", 0.8],
            [0, "Chat", 0, "I suppose I should catch my breath before it gets any harder.", 0.8],
            [1, "ChatHide"],
            [0, "FadeOut", 0, 1],
            [5, "SetSprite", 0, "Velocity"],
            [1, "FadeIn", 0, 1],
            [1, "Chat", 0, "Where did he go?"],
            [0, "Chat", 0, "I need to stop him before he touches anything..."],
            [0, "Chat", 0, "He's going to wake the guardian if he does."],
            [0, "ChatHide"],
            [2, "SetSprite", 1, "RobinHoot"],
            [0, "FadeIn", 1, 1],
            [1, "Chat", 0, "Finally"],
            [0, "Chat", 0, "Hey... Don't touch that.", 3],
            [0, "ChatHide"],
            [2, "Chat", 1, "Touch what?"],
            [0, "Chat", 0, "The thing you're touching...", 0.35],
            [0, "Chat", 1, "Okay"],
            [0, "Chat", 1, "Say that was already too late?"],
            [0, "ChatHide"],
            [0, "Chat", 0, "Get ready then...", 0.6],
            [0, "Play"]];

        // PEACE BREAKER
        public static var LEVEL_8:Array = [[0, "SetSprites", "Velocity", "Halogen"],
            [0, "SetAnimation", 0, "default"],
            [0, "SetAnimation", 1, "default"],
            [1, "ChatOther", "In a distant past... Say 2015...", 0.35],
            [0, "ChatHide"],
            [0, "FadeIn", 0, 1],
            [0, "FadeIn", 1, 1],
            [1, "Chat", 0, "Congratulations on your perfect run through the tournament."],
            [1, "Chat", 1, "Thank You"],
            [1, "Chat", 0, "I'll cut this bit short for now, as I'm sure you're\ngetting pretty exhausted after todays games."],
            [1, "Chat", 0, "So as one final thing before then...", 0.75],
            [1, "Chat", 0, "I do believe it's time we get to see the obligatory tie breaker."],
            [1, "Chat", 0, "For fun of course.", 0.35],
            [0, "Chat", 1, "(loud exhale)", 3, 0],
            [0, "Play"]];

        // Revenge
        public static var LEVEL_9:Array = [[0, "SetSprite", 1, "Velocity"],
            [0, "SetAnimation", 1, "default"],
            [1, "FadeIn", 1, 1],
            [1, "Chat", 1, "There isn't much to say about this one."],
            [1, "Chat", 1, "Originally this file was created to be exceptionally hard."],
            [1, "Chat", 1, "Acting as the final song for 13th OT, and even buffed in difficulty."],
            [1, "Chat", 1, "The sad part is the final result in-game and\nwhat was originally created differ so much."],
            [1, "Chat", 1, "Because of those reasons..."],
            [1, "Chat", 1, "(and it not being annoying to listen to for days on end)", 3],
            [1, "Chat", 1, "This chart was the first song I got working without framers."],
            [1, "Chat", 1, "So enjoy."],
            [0, "Play"]];

        // Unreal SuperHero 2
        public static var LEVEL_10:Array = [[0, "SetSprites", "Velocity", "hi19hi19"],
            [0, "SetAnimation", 0, "default"],
            [0, "SetAnimation", 1, "default"],
            [1, "FadeIn", 0, 1],
            [1, "Chat", 0, "It wouldn't be an April Fools release if the legendary\n*Whimper Wall* didn't make a return in some way."],
            [1, "Chat", 0, "Of course, well, this isn't the same version we normally make public."],
            [1, "Chat", 0, "And instead was submitted in hope of being an offical file."],
            [1, "Chat", 0, "Submitted, of course, by the cornman himself."],
            [1, "FadeIn", 1, 1],
            [0, "Chat", 0, "hi19hi19"],
            [1, "Chat", 1, "From a design perspective, there hasn't been a high D8 stream\nbenchmark file and I think this file would fit well."],
            [1, "Chat", 1, "Though it's relatively short and lacks pattern variation."],
            [1, "Chat", 1, "But, that hasn't stopped me from trying to\nget Whimper Wall into FFR properly."],
            [0, "Play"]];

        // GIGAHERTZ
        public static var LEVEL_11:Array = [[0, "SetSprites", "Velocity", "Goldstinger"],
            [0, "SetAnimation", 0, "default"],
            [0, "SetAnimation", 1, "default"],
            [1, "FadeIn", 0, 1],
            [0, "FadeIn", 1, 1],
            [1, "Chat", 0, "Hey Gold, I hear this file got rejected."],
            [1, "Chat", 1, "Ya, it's a shame. Something about it being \"too hard\"."],
            [1, "Chat", 1, "And it not converting correctly."],
            [1, "Chat", 0, "Well that's not much of an issue here is it?"],
            [1, "Chat", 1, "I mean, it's still hard."],
            [1, "Chat", 0, "But it converted correctly :D"],
            [0, "ChatHide"],
            [3, "Chat", 1, "Are you just trying to kill Hoot?"],
            [1, "Chat", 0, "What made you think that?"],
            [1, "Chat", 1, "This level and the one after it."],
            [1, "Chat", 0, "No, this one only kills 99% of players."],
            [1, "Chat", 0, "The one after this kills everyone.", 0.7],
            [1, "Chat", 0, "(and possibly the game)", 3],
            [0, "FadeOut", 1, 0.5],
            [1, "SetSprite", 1, "RobinHoot"],
            [0, "FadeIn", 1, 0.5],
            [0.5, "Chat", 1, "Someone mention my name?"],
            [1, "Chat", 1, "Oh it's you."],
            [1, "Chat", 1, "Do I really have to do this?"],
            [1, "Chat", 0, "Yes"],
            [0, "Play"]];

        // Hello 
        public static var LEVEL_12:Array = [[0, "SetSprites", "RobinHoot", "Velocity"],
            [0, "SetAnimation", 0, "default"],
            [0, "SetAnimation", 1, "default"],
            [1, "FadeIn", 0, 1],
            [1, "Chat", 0, "Oh great, this is the part where they kill me."],
            [0, "FadeIn", 1, 1],
            [1, "Rage", 1, 0x8E0200],
            [0, "Chat", 1, "Hello, this is the part where we kill you."],
            [0, "SetOverlay", "Chapter12Overlay"],
            [0, "OverlayPlay", "start"],
            [0, "OverlayWait", "end"],
            [0, "Play"]];

        // Pop Culture
        public static var LEVEL_13:Array = [[0, "SetSprites", "RobinHoot", "CosmoVibe"],
            [0, "SetAnimation", 0, "default"],
            [0, "SetAnimation", 1, "default"],
            [1, "FadeIn", 0, 1],
            [0, "FadeIn", 1, 1],
            [1, "Chat", 1, "For a lot of you, this will be something new."],
            [1, "Chat", 1, "So I hope it showcases the best of this format."],
            [1, "Chat", 1, "With a catchy song...", 1, 1],
            [1, "Chat", 1, "...simple themes...", 1, 1],
            [1, "Chat", 1, "...and mild difficulty..."],
            [1, "Chat", 1, "This should be a crowdpleaser!"],
            [0, "Play"]];

        // Magnolia
        public static var LEVEL_14:Array = [[0, "SetSprites", "RobinHoot", "CosmoVibe"],
            [0, "SetAnimation", 0, "default"],
            [0, "SetAnimation", 1, "default"],
            [1, "FadeIn", 0, 1],
            [0, "FadeIn", 1, 1],
            [1, "Chat", 1, "This is the first of the three boss songs from the game Deemo."],
            [1, "Chat", 1, "The easiest of the three, with a heavy focus on control."],
            [1, "Chat", 1, "Avoid the mines and you might make it out alive."],
            [1, "Chat", 1, "Enjoy!"],
            [0, "Play"]];

        // Myosotis
        public static var LEVEL_15:Array = [[0, "SetSprites", "RobinHoot", "CosmoVibe"],
            [0, "SetAnimation", 0, "default"],
            [0, "SetAnimation", 1, "default"],
            [1, "FadeIn", 0, 1],
            [0, "FadeIn", 1, 1],
            [1, "Chat", 1, "This is the second of the three boss songs from the game Deemo."],
            [1, "Chat", 1, "The middle ground in difficulty of the three songs."],
            [1, "Chat", 1, "This one features more unique patterns throughout."],
            [1, "Chat", 1, "All while sharing common themes with the other two."],
            [1, "Chat", 1, "Have fun!"],
            [0, "Play"]];

        // Marigold
        public static var LEVEL_16:Array = [[0, "SetSprites", "RobinHoot", "CosmoVibe"],
            [0, "SetAnimation", 0, "default"],
            [0, "SetAnimation", 1, "default"],
            [1, "FadeIn", 0, 1],
            [0, "FadeIn", 1, 1],
            [1, "Chat", 1, "This is the last of the three boss songs from the game Deemo."],
            [1, "Chat", 1, "By far the hardest in difficulty and significantly\nmore challenging than the others."],
            [1, "Chat", 1, "This should be extremely enjoyable for those who can read this."],
            [1, "Chat", 1, "But few players in the FFR community will have the ability to pass this."],
            [1, "Chat", 1, "Good luck."],
            [0, "Play"]];
    }
}

/* [delay, command, ...params] */
