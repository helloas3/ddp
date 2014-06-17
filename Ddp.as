package
{
	import flash.display.Sprite;
	import fl.controls.Button;
	import flash.events.MouseEvent;
	import flash.display.Graphics;
	import com.greensock.TweenLite;
	import flash.geom.Rectangle;
	import flash.events.Event;
	
	public class Ddp extends Sprite
	{
		private var size:int = 8;
		private var kinds:int = 6;
		private var grids:Array;
		private var erases:Array;
		private var colors:Array = [0xffffff,0x0000ff,0x00ff00,0xff0000,0x00ffff,0xff00ff,0xffff00,0x000000];
		private var g:Graphics;
		private var rubs:Array;
		private var blocks:Array;
		private var main:Sprite;
		private var stuff:int = 0;
		private var btn1:Button;
		private var btn2:Button;
		private var btn3:Button;
		private var mainMask:Sprite;
		private var duration:Number = 1;
		private var animation:Boolean = false;
		private var firsti:int = -1;
		private var firstj:int = -1;
		private var secondi:int = -1;
		private var secondj:int = -1;
		
		public function Ddp()
		{
			init();
			//checkAll();
			//update();
		}
		
		public function init()
		{  
			//initilize the data array
			mainMask = new Sprite();
			mainMask.graphics.beginFill(0x0000ff);
			mainMask.graphics.drawRect(0,0,400,400);
			mainMask.x = 50;
			mainMask.y = 50;
			addChild(mainMask);
			
			main = new Sprite();
			addChild(main);
			main.mask = mainMask
			g = this.graphics;
			
			rubs = new Array();
			grids = new Array();
			
			blocks = new Array();
			
			for(var i:int = 0; i < size; ++i)
				grids[i] = new Array();
			
			for(i = 0; i < size; ++i)
				blocks[i] = new Array();
				
			erases = new Array();
			for(i = 0; i < size; ++i)
				erases[i] = new Array();
			
			for(i = 0; i < size; ++i)
			{
				for(var j:int = 0; j < size; ++j)
				{
					grids[i][j] = int(Math.random() * kinds);
					erases[i][j] = -1;
				}
			}
			
			update();
			
			
			
			//help check the correction
			btn1 = new Button();
			btn1.label = "check";
			addChild(btn1);
			btn1.x = 10;
			btn1.y = 0;
			btn1.addEventListener(MouseEvent.CLICK, onBtn1Click);
			
			btn2 = new Button();
			btn2.label = "erase";
			addChild(btn2);
			btn2.x = 120;
			btn2.y = 0;
			btn2.addEventListener(MouseEvent.CLICK, onBtn2Click);
			
			btn3 = new Button();
			btn3.label = "fill";
			addChild(btn3);
			btn3.x = 230;
			btn3.y = 0;
			btn3.addEventListener(MouseEvent.CLICK, onBtn3Click);
			
			stage.addEventListener(MouseEvent.CLICK,onClick);
			
			//stage.addEventListener(Event.ENTER_FRAME, onGaming);
			firstCheck();
			animation = false;
			
		}
		
		public function firstCheck():void
		{
			while(!checkAll())
			{
				erase();
				clearErases();
				fill();
			}
			//printGrids();
			update();
		}
		
		public function check():void
		{
			checkAll();
			erase();
			update();
			clearErases();
			fill();
		}
		
		/*public onGraming():void
		{
			
		}*/
		
		
		public function onClick(e:MouseEvent):void
		{
			if(stuff != 0)
			return;
			
			if(mouseX < 50 || mouseX > 50*size + 50 || mouseY < 50 || mouseY > 50*size + 50)
			return;
			var c:int = (mouseX - 50) / 50;
			var r:int = (mouseY - 50) / 50;
			
			if(firsti == -1)
			{
				firsti = r;
				firstj = c;
				blocks[r][c].changeState();
			}
			else if(r == firsti && c == firstj)
			{
				firsti = firstj = -1;
				blocks[r][c].changeState();
			}
			else if(Math.abs(firsti - r) + Math.abs(firstj - c) <= 1)
			{
				/*trace("first");
				trace(firsti,firstj,grids[firsti][firstj],blocks[firsti][firstj].kinds);
				trace("second");
				trace(r,c,grids[r][c],blocks[r][c].kinds);
				*/
				blocks[firsti][firstj].changeState();
				var tKind:int = grids[firsti][firstj];
				grids[firsti][firstj] = grids[r][c];
				grids[r][c] = tKind;
				TweenLite.to(blocks[firsti][firstj],0.5,{x:50 + c*50, y:50 + r*50});
				TweenLite.to(blocks[r][c],0.5,{x: 50 + firstj*50, y:50 + firsti* 50,onComplete:changeFinish});
				secondi = r;
				secondj = c;
			}
			else
			{
				trace("4");
				blocks[firsti][firstj].changeState();
				firsti = firstj = -1;
			}
		}
		
		public function changeFinish():void
		{
			main.mouseChildren = false;
			animation = true;
			if(checkAll())
			{
				TweenLite.to(blocks[firsti][firstj],0.5,{x:50 + firstj*50, y:50 + firsti*50});
				stuff++;
				TweenLite.to(blocks[secondi][secondj],0.5,{x: 50 + secondj*50, y:50 + secondi*50,onComplete:finishMove});
				var tKind:int =grids[firsti][firstj];
				grids[firsti][firstj] = grids[secondi][secondj];
				grids[secondi][secondj] = tKind;
				/*trace("first");
				trace(firsti,firstj,grids[firsti][firstj],blocks[firsti][firstj].kinds);
				trace("second");
				trace(secondi,secondj,grids[secondi][secondj],blocks[secondi][secondj].kinds);*/
				firsti = firstj = secondi = secondj = -1;
				return;
			}
		    firsti = firstj = secondi = secondj = -1;
			check();
		}
		
		public function onBtn1Click(e:MouseEvent):void
		{
			update();
			checkAll();
			mark();
		}
		
		public function onBtn2Click(e:MouseEvent):void
		{
			unMark();
			erase();
			update();
			clearErases();
		}
		
		public function onBtn3Click(e:MouseEvent):void
		{
			fill();
			//update();
		}
		
		public function clearErases():void
		{
			for(var i:int = 0; i < size; ++i)
			{
				for(var j:int = 0; j < size; ++j)
				{
					erases[i][j] = -1;
				}
			}
		}
		
		public function checkAll():Boolean
		{
			checkH();
			checkV();
			checkLL();
			checkLR();
			for(var i:int = 0; i < size; ++i)
			{
				for(var j:int = 0; j < size; ++j)
				{
					if(erases[i][j] != -1)
					return false;
				}
			}
			return true;
		}
		
		public function erase():void
		{
			for(var i = 0; i < size; ++i)
			{
				for(var j = 0; j < size; ++j)
				{
					if(erases[i][j] != -1)
					{
						grids[i][j] = -1;
						main.removeChild(blocks[i][j]);
						blocks[i][j] = null;
					}
					
				}
			}
		}
		
		
		public function fill():void
		{
			btn1.enabled = false;
			btn2.enabled = false;
			btn3.enabled = false;
			
			for(var i:int = size - 1;i >= 0; --i)
			{
				for(var j:int = 0; j < size; ++j)
				{
					if(grids[i][j] == -1)
					{
						var found:Boolean = false;
						for(var k:int = i - 1; k >= 0; --k)
						{
							if(grids[k][j] != -1)
							{

								grids[i][j] = grids[k][j];
								blocks[i][j] = blocks[k][j];
								if(animation)
								{
									stuff++;
									TweenLite.to(blocks[k][j],duration,{y:50 + i * 50, onComplete:finishMove});
								}
								else
								{
									blocks[k][j].y = 50 + i * 50;
								}
								grids[k][j] = -1;
								found = true;
								break;
							}
						}
						if(found)
						continue;
						else
						{
							grids[i][j] = int(Math.random() * kinds);
							blocks[i][j] = new DdpItem(grids[i][j]);
							blocks[i][j].x = 50 * j + 50;
							blocks[i][j].y = 0;
							main.addChild(blocks[i][j]);
							if(animation)
							{
								stuff++;
								TweenLite.to(blocks[i][j],duration,{y:50 + i * 50, onComplete:finishMove});
							}
							else
							{
								blocks[i][j].y = 50 + i * 50;
							}
						}
					}
				}
			}
			if(stuff == 0)
			{
				btn1.enabled = true;
				btn2.enabled = true;
				btn3.enabled = true;
				main.mouseChildren = true;
			}
		}
		
		public function finishMove():void
		{
			stuff--;
			if(stuff == 0)
			{
				update();
				btn1.enabled = true;
				btn2.enabled = true;
				btn3.enabled = true;
				main.mouseChildren = true;
				check();			
			}
		}
		
		public function printGrids():void
		{
			for(var i:int = 0; i < size; ++i)
			{
				trace(grids[i]);
			}
		}
		
		//check horizental
		public function checkH():void
		{
			for(var i = 0; i < size; ++i)
			{
				for(var j = 0; j < size - 2; ++j)
				{
					if(grids[i][j]!=grids[i][j+1] || grids[i][j+1] != grids[i][j+2])
					continue;
					else
					erases[i][j] = erases[i][j+1] = erases[i][j+2] = 1;
				}
			}
		}
		
		
		//check vertical
		public function checkV():void
		{
			for(var i = 0; i < size - 2; ++i)
			{
				for(var j = 0; j < size; ++j)
				{
					if(grids[i][j]!=grids[i+1][j] || grids[i+1][j] != grids[i+2][j])
					continue;
					else
					erases[i][j] = erases[i+1][j] = erases[i+2][j] = 1;
				}
			}
		}
		
		//check lower left
		public function checkLL():void
		{
			for(var i = 0; i < size - 2; ++i)
			{
				for(var j = 2; j < size; ++j)
				{
					if(grids[i][j]!=grids[i+1][j-1] || grids[i+1][j-1] != grids[i+2][j-2])
					continue;
					else
					erases[i][j] = erases[i+1][j-1] = erases[i+2][j-2] = 1;
				}
			}
		}
		
		//check lower right
		public function checkLR():void
		{
			for(var i = 0; i < size - 2; ++i)
			{
				for(var j = 0; j < size - 2; ++j)
				{
					if(grids[i][j]!=grids[i+1][j+1] || grids[i+1][j+1] != grids[i+2][j+2])
					continue;
					else
					erases[i][j] = erases[i+1][j+1] = erases[i+2][j+2] = 1;
				}
			}
		}
		
		public function checkRelative(i1:int,j1:int,i2:int,j2:int):void
		{
			;
		}
		
		public function update():void
		{
			for(var i:int = 0; i < size; ++i)
			{
				for(var j:int = 0; j < size; ++j)
				{
					if(grids[i][j] != -1 && blocks[i][j] == null) 
					{
						blocks[i][j] = new DdpItem(grids[i][j]);
						blocks[i][j].x = j*50 + 50;
						blocks[i][j].y = i*50 + 50;
						main.addChild(blocks[i][j]);
					}
					else if(grids[i][j] != - 1 && blocks[i][j] != null)
					{
						blocks[i][j].x = j * 50 + 50;
						blocks[i][j].y = i * 50 + 50;
						if(blocks[i][j].kinds != grids[i][j])
						{
							blocks[i][j].kinds = grids[i][j];
							blocks[i][j].init();
						}
					}
					else if(grids[i][j] == -1 && blocks[i][j] != null)
					{
						main.removeChild(blocks[i][j]);
						blocks[i][j] = null;
					}

				}
			}
			
		}
		
		public function mark():void
		{
			for(var i:int= 0; i < size; ++i)
			{
				for(var j:int =0; j < size; ++j)
				{
					if(erases[i][j] != -1)
					{
						blocks[i][j].mark();
					}
				}
			}
		}
		
		public function unMark():void
		{
			for(var i:int= 0; i < size; ++i)
			{
				for(var j:int =0; j < size; ++j)
				{
					if(erases[i][j] != -1)
					{
						blocks[i][j].endMark();
					}
				}
			}
		}
	}
}