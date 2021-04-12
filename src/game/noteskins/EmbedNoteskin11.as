package game.noteskins
{
    import flash.utils.ByteArray;

    public class EmbedNoteskin11 extends EmbedNoteskinBase
    {
        [Embed(source = "Noteskin11.swf", mimeType = 'application/octet-stream')]
        private static const EMBED_SWF:Class;

        private static const ID:int = 11;

        override public function getData():Object
        {
            return {"id": ID,
                    "name": "NyanCat",
                    "rotation": 0,
                    "width": 40,
                    "_hidden": true,
                    "height": 52}
        }

        override public function getBytes():ByteArray
        {
            return new EMBED_SWF();
        }

        override public function getID():int
        {
            return ID;
        }
    }
}
