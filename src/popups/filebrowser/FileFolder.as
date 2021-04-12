package popups.filebrowser
{

    public class FileFolder
    {
        public var folder:String;
        public var file:String;
        public var data:Vector.<FileFolderItem>;

        public var author:String;
        public var name:String;
        public var banner:String;

        public function FileFolder(folder:String, file:String, item:FileFolderItem)
        {
            this.folder = folder;
            this.file = file;
            this.data = new <FileFolderItem>[item];
        }
    }
}
