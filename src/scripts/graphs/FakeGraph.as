package scripts.graphs
{

    import flash.display.Bitmap;
    import game.graph.GraphCrossPoint;

    public class FakeGraph
    {
        [Embed(source = "SansGraph.png", mimeType = 'image/png')]
        private static const SANS_BMP:Class;
        private static var SANS_GRAPH_POINTS:Vector.<GraphCrossPoint>;

        [Embed(source = "NyanCatGraph.png", mimeType = 'image/png')]
        private static const NYAN_BMP:Class;
        private static var NYAN_GRAPH_POINTS:Vector.<GraphCrossPoint>;

        [Embed(source = "DarkMatterGraph.png", mimeType = 'image/png')]
        private static const MATTER_BMP:Class;

        public static function getSansPoints():Vector.<GraphCrossPoint>
        {
            if (SANS_GRAPH_POINTS == null)
            {
                SANS_GRAPH_POINTS = new <GraphCrossPoint>[];

                var index:int = 0;
                var image_data:Bitmap = (new SANS_BMP() as Bitmap);

                for (var x:int = 0; x < image_data.bitmapData.width; x++)
                {
                    for (var y:int = 0; y < image_data.bitmapData.height; y++)
                    {
                        var color:uint = image_data.bitmapData.getPixel(x, y);

                        if (color > 0)
                        {
                            SANS_GRAPH_POINTS[SANS_GRAPH_POINTS.length] = new GraphCrossPoint(index++, x + 42, y + 23, (y + 23 - 58) * 2, color, 50);
                        }
                    }
                }
            }
            return SANS_GRAPH_POINTS;
        }

        public static function getMatterBG():Bitmap
        {
            return (new MATTER_BMP() as Bitmap);
        }

        public static function getNyanPoints():Vector.<GraphCrossPoint>
        {
            if (NYAN_GRAPH_POINTS == null)
            {
                NYAN_GRAPH_POINTS = new <GraphCrossPoint>[];

                var index:int = 0;
                var image_data:Bitmap = (new NYAN_BMP() as Bitmap);

                for (var x:int = 0; x < image_data.bitmapData.width; x++)
                {
                    for (var y:int = 0; y < image_data.bitmapData.height; y++)
                    {
                        var color:uint = image_data.bitmapData.getPixel(x, y);

                        if (color > 0)
                        {
                            NYAN_GRAPH_POINTS[NYAN_GRAPH_POINTS.length] = new GraphCrossPoint(index++, x, y, (y - 58) * 2, color, 50);
                        }
                    }
                }
            }
            return NYAN_GRAPH_POINTS;
        }
    }
}
