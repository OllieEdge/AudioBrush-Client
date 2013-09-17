package com.edgington.net.helpers
{
	import com.edgington.types.ServerObjectTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.valueobjects.net.ServerProductsVO;
	import com.edgington.valueobjects.net.ServerUserVO;

	public class NetResponceTypeIdentifier
	{
		public static function GET_RESPONCE_TYPE(responceObj:Object):String{
			
			if(responceObj is Array){
				if(responceObj.length > 0){
					
					//-------------------------------------------------------------------   USER
					if(responceObj.length == 1 && ServerUserVO.checkObject(responceObj[0])){
						return ServerObjectTypes.USER;
					}
					else if(ServerUserVO.checkObject(responceObj[0])){
						return ServerObjectTypes.USERS;
					}
					
					//-------------------------------------------------------------------   PRODUCT
					if(ServerProductsVO.checkObject(responceObj[0])){
						return ServerObjectTypes.PRODUCT;
					}
					
				}
				else{
					LOG.warning("Server response contains no data");
				}
			}
			else{
				//-------------------------------------------------------------------   USER
				if(ServerUserVO.checkObject(responceObj)){
					return ServerObjectTypes.USER;
				}
				//-------------------------------------------------------------------   PRODUCT
				else if(ServerProductsVO.checkObject(responceObj)){
					return ServerObjectTypes.PRODUCT;
				}
			}
			
			return ServerObjectTypes.UNKNOWN;
		}
	}
}