package com.edgington.net.helpers
{
	import com.edgington.types.ServerObjectTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.valueobjects.net.ServerAchievementVO;
	import com.edgington.valueobjects.net.ServerGiftVO;
	import com.edgington.valueobjects.net.ServerProductsVO;
	import com.edgington.valueobjects.net.ServerScoreVO;
	import com.edgington.valueobjects.net.ServerTournamentDataVO;
	import com.edgington.valueobjects.net.ServerTrackVO;
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
					
					//-------------------------------------------------------------------   SCORE
					if(ServerScoreVO.checkObject(responceObj[0])){
						return ServerObjectTypes.SCORE;
					}
					
					//-------------------------------------------------------------------   TRACK
					if(ServerTrackVO.checkObject(responceObj[0])){
						return ServerObjectTypes.TRACK;
					}
					
					//-------------------------------------------------------------------   TOURNAMENTS
					if(ServerTournamentDataVO.checkObject(responceObj[0])){
						return ServerObjectTypes.TOURNAMENTS;
					}
					
					//-------------------------------------------------------------------   GIFTS
					if(ServerGiftVO.checkObject(responceObj[0])){
						return ServerObjectTypes.GIFTS;
					}
					
					//-------------------------------------------------------------------   ACHIEVEMENTS
					if(ServerAchievementVO.checkObject(responceObj[0])){
						return ServerObjectTypes.ACHIEVEMENTS;
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
				//-------------------------------------------------------------------   SCORE
				else if(ServerScoreVO.checkObject(responceObj)){
					return ServerObjectTypes.SCORE;
				}
				//-------------------------------------------------------------------   TRACK
				else if(ServerTrackVO.checkObject(responceObj)){
					return ServerObjectTypes.TRACK;
				}
				//-------------------------------------------------------------------   TOURNAMENT
				else if(ServerTournamentDataVO.checkObject(responceObj)){
					return ServerObjectTypes.TOURNAMENT;
				}
				//-------------------------------------------------------------------   GIFT
				else if(ServerGiftVO.checkObject(responceObj)){
					return ServerObjectTypes.GIFT;
				}
				//-------------------------------------------------------------------   ACHIEVEMENT
				else if(ServerAchievementVO.checkObject(responceObj)){
					return ServerObjectTypes.ACHIEVEMENT;
				}
			}
			
			return ServerObjectTypes.UNKNOWN;
		}
	}
}