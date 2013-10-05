package com.edgington.view.huds.vo
{
	import com.edgington.util.localisation.gettext;

	public class AchievementVO
	{
		public var ID:int;
		public var name:String;
		public var description:String;
		public var secret:Boolean;
		public var progress:int;
		public var reward:String;
		public var credits:int;
		
		public var lastUpdated:Date;
		public var completed:Date;
		
		public function AchievementVO(id:int, progress:int, reward:String, credits:int, secret:Boolean = false){
			this.ID = id;
			this.name = gettext("achievements_title_"+id);
			this.description = gettext("achievements_description_"+id);
			this.secret = secret;
			this.progress = progress;
			this.reward = reward;
			this.credits = credits;
		}
	}
}