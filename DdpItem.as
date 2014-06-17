package
{
	import flash.display.Sprite;
	import flash.events.Event;

	public class DdpItem extends Sprite
	{
		public var len:Number;
		public var c:uint;
		public var kinds:int;
		private var colors:Array = [0xffffff,0x0000ff,0x00ff00,0xff0000,0x00ffff,0xff00ff,0xffff00,0x000000];
		private var step:Number = Math.PI / 2;
		private var isShading = false;
		
		
		public function DdpItem(k:int,leng:int = 50)
		{
			this.kinds = k;
			this.len = leng;
			init();
		}
		
		
		public function init():void
		{
			this.graphics.clear();
			this.graphics.lineStyle(2,0x000000);
			this.graphics.beginFill(colors[kinds+1]);
			this.graphics.drawRect(0,0,len,len);
			this.graphics.endFill();
		}
		
		public function mark():void
		{
			this.step = Math.PI / 2;
			this.alpha = 1;
			this.addEventListener(Event.ENTER_FRAME, onEnter);
		}
		
		public function onEnter(e:Event):void
		{
			this.alpha = Math.abs(Math.sin(step));
			step += Math.PI / 40;
		}
		
		public function endMark():void
		{
			if(!this.hasEventListener(Event.ENTER_FRAME))
			   return;
			this.step = Math.PI / 2;
			this.removeEventListener(Event.ENTER_FRAME, onEnter);
			this.alpha = 1;
		}
		
		public function changeState():void
		{
			if(isShading)
			norm();
			else
			shad();
		}
		
		public function shad():void
		{
			this.alpha = 0.3;
			this.isShading = true;
		}
		
		public function norm():void
		{
			this.alpha = 1;
			this.isShading = false;
		}
	}
}