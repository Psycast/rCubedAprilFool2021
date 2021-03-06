package com.flashfla.utils
{
    import game.controls.GameNote;

    public class ObjectPool
    {
        public var pool:Vector.<Object>;

        public function ObjectPool()
        {
            pool = new Vector.<Object>();
        }

        public function addObject(object:GameNote, mark:Boolean = true):GameNote
        {
            pool.push({mark: mark, value: object});
            return object;
        }

        public function unmarkObject(object:GameNote, mark:Boolean = false):void
        {
            for each (var item:Object in pool)
            {
                if (item.value == object)
                {
                    item.mark = mark;
                }
            }
        }

        public function unmarkAll(mark:Boolean = false):void
        {
            for each (var item:Object in pool)
                item.mark = mark;
        }

        public function getObject():*
        {
            for each (var item:Object in pool)
            {
                if (!item.mark)
                {
                    item.mark = true;
                    return item.value;
                }
            }
            return null;
        }
    }
}
