package com.edgington.valueobjects.net
{
	import com.edgington.util.DateFormatter;
	import com.edgington.util.debug.LOG;
	
	public class ServerGiftVO
	{
		private var created:String;
		
		public var _id:String;
		
		public var to:ServerUserVO;
		public var from:ServerUserVO;

		public var sent:Date;
		public var expires:Date;
		
		public var credits:Number;
		
		public var productID:String;
		public var productQuantity:Number;
		
		public var toIdSTRING:String;
		public var fromIdSTRING:String;
		
		public function ServerGiftVO(rawObject:Object = null)
		{
			for(var key:String in rawObject){
				if(key.charAt(0) != "_" || key == "_id"){
					if(key == "to" || key == "from"){
						if(key == "to" && ServerUserVO.checkObject(rawObject[key])){
							to = new ServerUserVO(rawObject[key]);
						}	
						else if(key == "from" && ServerUserVO.checkObject(rawObject[key])){
							from = new ServerUserVO(rawObject[key]);
						}	
					}
					else{
						
						if(key == "sent" || key == "expires"){
							if(key == "sent"){
								sent = DateFormatter.RFC3339toDate(rawObject[key]);
							}
							else{
								expires = DateFormatter.RFC3339toDate(rawObject[key]);
							}
						}
						else{
							try{
								this[key] = rawObject[key];
							}
							catch(e:Error){
								if(key == "to"){
									toIdSTRING = rawObject[key];
								}
								else if(key == "from"){
									fromIdSTRING = rawObject[key];
								}
								else{
									LOG.fatal("There was a type failure when attempting to add a key to the gifts object");
								}
							}
						}
					}
				}
			}
		}
		
		public static function checkObject(obj:Object):Boolean{
			var isUserObject:Boolean = true;
			var serverObject:ServerGiftVO = new ServerGiftVO();
			
			for(var key:String in obj){
				if(key.charAt(0) != "_" || key == "_id"){
					//We must filter out the mongoDB defaults as we do not use these (they start with a _ )
					if(!serverObject.hasOwnProperty(key)){
						LOG.debug("Key that doesn't exist in client but is in the server responce is: " + key);
						return false;
					}
				}
			}
			
			return isUserObject;
		}
	}
}
