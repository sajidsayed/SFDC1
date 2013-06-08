/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  02/01/2012    Shalabh Sharma           Trigger to map chatter post on Opportunity to Opportunity Reporting                                             
 +==================================================================================================================**/

trigger Presales_afterInsertBeforeDeleteOfFeedItem on FeedItem (after Insert, before delete) {
	Presales_OpportunityReporting objAttmt= new Presales_OpportunityReporting();
	if(trigger.isInsert){
		Map<Id,FeedItem> mapFeed = new Map<Id,FeedItem>();
		objAttmt.mapChatterPost(trigger.newMap,false);
		for(FeedItem feed:trigger.new){
			String s = feed.ParentId;
			if(s.substring(0,3)=='500'){
				mapFeed.put(feed.Id,feed);	
			}	
		}
		objAttmt.isFirstPost(mapFeed);	
	}
	if(trigger.isDelete){
		objAttmt.mapChatterPost(trigger.oldMap,true);
	}
}