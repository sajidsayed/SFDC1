/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER          WR        DESCRIPTION                               

 |  ====          =========          ==        =========== 

 |  30/12/2011    Shalabh Sharma               This class is used to map the details of attachments on Opportunity and Account
                                               to Chatter Reporting 
 |  8/3/2012      Shalabh Sharma               Added method mapStatusUpdates to include status updates and group posts.
 |  10/4/2012     Shalabh Sharma               Changed mapStatusUpdates() to a future method.
 |  03/05/2012    Shalabh Sharma               Updated method mapChatterPost() to include chatter posts on Case.
 |  14/05/2012    Shalabh Sharma               Added method isFirstPost() to track the first post on case.    
 |  08April2013   Ganesh Soma    WR#257222     Handling prodcution bug, while inserting more then one feeditem record using dataloader operation                                                                          
 +==================================================================================================================**/
public class Presales_OpportunityReporting {
/* @Method <This method execute is used to map the details of inserted attachments on Opportunity or Account to Chatter Reporting>
@param <This method takes Map<Id,Attachment> as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/  
    public void mapAttachmentDetailsOnInsert(Map<Id,Attachment> mapAttachment){
        Map<String,List<Attachment>> mapParentIdAttachment = new Map<String,List<Attachment>>();
        List<Opportunity_Reporting__c> lstOpptyReporting = new List<Opportunity_Reporting__c>();
        for(Attachment attmt:mapAttachment.values()){
            if(mapParentIdAttachment.containsKey(attmt.ParentId)){
                (mapParentIdAttachment.get(attmt.ParentId)).add(attmt); 
            }
            else {
                List<Attachment> lstAttachment = new List<Attachment>();
                lstAttachment.add(attmt);
                mapParentIdAttachment.put(attmt.ParentId,lstAttachment);
            }
        }
        for(String s:mapParentIdAttachment.keyset()){
            if(s.substring(0,3)=='006'){
                Opportunity_Reporting__c opptyReporting = new Opportunity_Reporting__c(); 
                for(Attachment attmt:mapParentIdAttachment.get(s)){
                     
                    opptyReporting.Opportunity__c = s;
                    opptyReporting.Attachment_Owner__c = attmt.OwnerId;
                    opptyReporting.Attachment__c = attmt.Name;
                    opptyReporting.AttachmentId__c = attmt.Id;
                    opptyReporting.Description__c = attmt.Description;
                    opptyReporting.IsPrivate__c = attmt.IsPrivate;
                    opptyReporting.Size__c = attmt.BodyLength;
                    opptyReporting.IsOpportunity__c = true;
                    lstOpptyReporting.add(opptyReporting);
                }   
            }
        else if(s.substring(0,3)=='001'){
                Opportunity_Reporting__c opptyReporting = new Opportunity_Reporting__c();      
                for(Attachment attmt:mapParentIdAttachment.get(s)){
                    
                    opptyReporting.Account__c = s;
                    opptyReporting.Attachment_Owner__c = attmt.OwnerId;
                    opptyReporting.Attachment__c = attmt.Name;
                    opptyReporting.AttachmentId__c = attmt.Id;
                    opptyReporting.Description__c = attmt.Description;
                    opptyReporting.IsPrivate__c = attmt.IsPrivate;
                    opptyReporting.Size__c = attmt.BodyLength;
                    opptyReporting.IsAccount__c = true;
                    lstOpptyReporting.add(opptyReporting);
                }   
            }
        }
        insert lstOpptyReporting;
    }
/* @Method <This method execute is used to map the details of updated attachments on Opportunity or Account to Chatter Reporting>
@param <This method takes Map<Id,Attachment> and Boolean as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/  
    public void mapAttachmentDetailsOnUpdate(Map<Id,Attachment> mapAttachment,Boolean isDelete){
        Map<String,List<Attachment>> mapParentIdAttachment = new Map<String,List<Attachment>>();
        List<Opportunity_Reporting__c> lstOpptyReporting = new List<Opportunity_Reporting__c>();
        if(isDelete == false){
            Map<Id,Opportunity_Reporting__c> mapOpptyReporting = new Map<Id,Opportunity_Reporting__c>([Select IsPrivate__c,Description__c,Attachment__c,AttachmentId__c from Opportunity_Reporting__c where AttachmentId__c in :mapAttachment.keyset()]);
            for(Opportunity_Reporting__c opptyReporting:mapOpptyReporting.values()){
                opptyReporting.Attachment__c = mapAttachment.get(opptyReporting.AttachmentId__c).Name;
                opptyReporting.Description__c = mapAttachment.get(opptyReporting.AttachmentId__c).Description;
                opptyReporting.IsPrivate__c = mapAttachment.get(opptyReporting.AttachmentId__c).IsPrivate;
            }
            if(mapOpptyReporting.size()>0){
                update mapOpptyReporting.values();
            }
        }
        if(isDelete==true){
            system.debug('mapAttachment--->'+mapAttachment);
            List<Opportunity_Reporting__c> lstOpptyReportingDelete = [Select Id,AttachmentId__c from Opportunity_Reporting__c where AttachmentId__c in :mapAttachment.keyset()];
            if(lstOpptyReportingDelete.size()>0){
                delete lstOpptyReportingDelete;
            }   
        }    
    }
/* @Method <This method execute is used to map chatter post on Opportunity to Opportunity Reporting>
@param <This method takes Map<Id,Attachment> as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/
    public void mapChatterPost(Map<Id,FeedItem> mapChatterPost,Boolean isDelete){

        Map<String,List<FeedItem>> mapParentIdFeedItem = new Map<String,List<FeedItem>>();
        List<Opportunity_Reporting__c> lstOpptyReporting = new List<Opportunity_Reporting__c>();
        if(isDelete == false){
            for(FeedItem feed:mapChatterPost.values()){
          
    //Srinivas: Get the user profile and if the user profile is "Chatter Free User" 
              //then return from this method.
              if(! isChatterFreeUser(feed)) return;
    
                system.debug('feed--->'+feed);
                if(mapParentIdFeedItem.containsKey(feed.ParentId)){
                    (mapParentIdFeedItem.get(feed.ParentId)).add(feed); 
                }
                else {
                    
                    List<FeedItem> lstFeedItem = new List<FeedItem>();
                    
                    lstFeedItem.add(feed);
                    system.debug('lstFeedItem--->'+lstFeedItem);    
                    mapParentIdFeedItem.put(feed.ParentId,lstFeedItem);
                }
            }
            system.debug('mapParentIdFeedItem--->'+mapParentIdFeedItem);
            
            for(String s:mapParentIdFeedItem.keyset()){
                if(s.substring(0,3)=='006'){
                   
                    for(FeedItem feed:mapParentIdFeedItem.get(s)){
                        Opportunity_Reporting__c opptyReporting = new Opportunity_Reporting__c();
                        if(feed.Type=='TextPost'){
                            opptyReporting.Post_Information__c = feed.Body;
                        }
                        if(feed.Type=='ContentPost'){
                            opptyReporting.Post_Information__c = feed.ContentFileName+'\n'+feed.Body;
                            opptyReporting.Size__c = feed.ContentSize;  
                            opptyReporting.Attachment__c = feed.ContentFileName;
                            system.debug('feed.ContentFileName--->'+feed.ContentFileName);
                        }   
                        if(feed.Type=='LinkPost'){
                            opptyReporting.Post_Information__c = feed.LinkUrl+'\n'+feed.Body;   
                        }
                        opptyReporting.Opportunity__c = s;
                        opptyReporting.Posted_On__c = 'Opportunity';
                        opptyReporting.Chatter_Post_Id__c = feed.Id;
                        opptyReporting.Post_Creator__c = feed.CreatedById;
                        opptyReporting.Date_Time_Posted__c = feed.CreatedDate;
                        opptyReporting.Chatter_Post_Type__c = feed.Type; 
                        opptyReporting.IsOpportunity__c = true;
                        lstOpptyReporting.add(opptyReporting);
                    }    
                }  
                else if(s.substring(0,3)=='001'){
                    
                    for(FeedItem feed:mapParentIdFeedItem.get(s)){
                        Opportunity_Reporting__c opptyReporting = new Opportunity_Reporting__c();
                        if(feed.Type=='TextPost'){
                            opptyReporting.Post_Information__c = feed.Body;
                        }
                        if(feed.Type=='ContentPost'){
                            opptyReporting.Post_Information__c = feed.ContentFileName+'\n'+feed.Body;
                            opptyReporting.Size__c = feed.ContentSize;  
                            opptyReporting.Attachment__c = feed.ContentFileName;
                        }   
                        if(feed.Type=='LinkPost'){
                            opptyReporting.Post_Information__c = feed.LinkUrl+'\n'+feed.Body;   
                        }
                        opptyReporting.Account__c = s;
                        opptyReporting.Posted_On__c = 'Account';
                       opptyReporting.Chatter_Post_Id__c = feed.Id;
                        opptyReporting.Post_Creator__c = feed.CreatedById;
                        opptyReporting.Date_Time_Posted__c = feed.CreatedDate;
                        opptyReporting.Chatter_Post_Type__c = feed.Type; 
                        opptyReporting.IsAccount__c = true;
                        lstOpptyReporting.add(opptyReporting);
                    }    
                }
                else if(s.substring(0,3)=='0F9'){
                    CollaborationGroup grp = [Select Name from CollaborationGroup where Id=:s];
                    for(FeedItem feed:mapParentIdFeedItem.get(s)){
                        Opportunity_Reporting__c opptyReporting = new Opportunity_Reporting__c();
                        if(feed.Type=='TextPost'){
                            opptyReporting.Post_Information__c = feed.Body;
                        }
                        if(feed.Type=='ContentPost'){
                            opptyReporting.Post_Information__c = feed.ContentFileName+'\n'+feed.Body;
                            opptyReporting.Size__c = feed.ContentSize;  
                            opptyReporting.Attachment__c = feed.ContentFileName;
                        }   
                        if(feed.Type=='LinkPost'){
                            opptyReporting.Post_Information__c = feed.LinkUrl+'\n'+feed.Body;   
                        }
                        opptyReporting.Group__c = grp.Name;
                        opptyReporting.Posted_On__c = 'Group';
                        opptyReporting.Chatter_Post_Id__c = feed.Id;
                        opptyReporting.Post_Creator__c = feed.CreatedById;
                        opptyReporting.Date_Time_Posted__c = feed.CreatedDate;
                        opptyReporting.Chatter_Post_Type__c = feed.Type; 
                        //opptyReporting.IsAccount__c = true;
                        lstOpptyReporting.add(opptyReporting);
                    }    
                }
                else if(s.substring(0,3)=='500'){
                    for(FeedItem feed:mapParentIdFeedItem.get(s)){
                        Opportunity_Reporting__c opptyReporting = new Opportunity_Reporting__c();
                        if(feed.Type=='TextPost'){
                            opptyReporting.Post_Information__c = feed.Body;
                        }
                        if(feed.Type=='ContentPost'){
                            opptyReporting.Post_Information__c = feed.ContentFileName+'\n'+feed.Body;
                            opptyReporting.Size__c = feed.ContentSize;  
                            opptyReporting.Attachment__c = feed.ContentFileName;
                        }   
                        if(feed.Type=='LinkPost'){
                            opptyReporting.Post_Information__c = feed.LinkUrl+'\n'+feed.Body;   
                        }
                        opptyReporting.Case__c = s;
                        opptyReporting.Posted_On__c = 'Case';
                        opptyReporting.Chatter_Post_Id__c = feed.Id;
                        opptyReporting.Post_Creator__c = feed.CreatedById;
                        opptyReporting.Date_Time_Posted__c = feed.CreatedDate;
                        opptyReporting.Chatter_Post_Type__c = feed.Type; 
                        //opptyReporting.IsAccount__c = true;
                        lstOpptyReporting.add(opptyReporting);
                    }    
                }
               else {
                    for(FeedItem feed:mapParentIdFeedItem.get(s)){
                        Opportunity_Reporting__c opptyReporting = new Opportunity_Reporting__c();
                        if(feed.Type=='TextPost'){
                            opptyReporting.Post_Information__c = feed.Body;
                        }
                        if(feed.Type=='ContentPost'){
                            opptyReporting.Post_Information__c = feed.ContentFileName+'\n'+feed.Body;
                            opptyReporting.Size__c = feed.ContentSize;  
                            opptyReporting.Attachment__c = feed.ContentFileName;
                        }   
                        if(feed.Type=='LinkPost'){
                            opptyReporting.Post_Information__c = feed.LinkUrl+'\n'+feed.Body;   
                        }
                        //opptyReporting.Account__c = s;
                        opptyReporting.Chatter_Post_Id__c = feed.Id;
                        opptyReporting.Post_Creator__c = feed.CreatedById;
                        opptyReporting.Date_Time_Posted__c = feed.CreatedDate;
                        opptyReporting.Chatter_Post_Type__c = feed.Type; 
                        //opptyReporting.IsAccount__c = true;
                        lstOpptyReporting.add(opptyReporting);  
                    }     
            }
            system.debug('-lstOpptyReporting--->'+lstOpptyReporting);
            //Commneted by Ganesh on 08April2013
            //insert lstOpptyReporting;
            
        }      
            //Added by Ganesh on 08April2013
	        if(lstOpptyReporting.size() >0)
	        {
	           insert lstOpptyReporting;
	        }
	       
        }
        if(isDelete==true){
            List<Opportunity_Reporting__c> lstOpptyReportingToDelete = [select Id from Opportunity_Reporting__c where Chatter_Post_Id__c in :mapChatterPost.keyset()];      
            if(lstOpptyReportingToDelete.size()>0){
                delete lstOpptyReportingToDelete;
            }
        } 
    
      
    }
/* @Method <This method execute is used to map chatter post comments on Opportunity to Opportunity Reporting>
@param <This method takes Map<Id,Attachment> as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/ 
    public void mapChatterPostComments(Map<Id,FeedComment> mapChatterComment,Boolean isDelete){
    Map<String,FeedComment> mapParentIdFeedComment = new Map<String,FeedComment>(); 
    String oldComments;
        if(isDelete==false){
            for(FeedComment comment:mapChatterComment.values()){               
                mapParentIdFeedComment.put(comment.FeedItemId,comment);             
            }
            system.debug('mapParentIdFeedComment--->'+mapParentIdFeedComment);
            Map<Id,Opportunity_Reporting__c> mapOpptyReporting = new Map<Id,Opportunity_Reporting__c>([Select Id,Related_To_Post__c,Chatter_Post_Id__c,Post_Comment__c from Opportunity_Reporting__c
                                                                                                        where Chatter_Post_Id__c in : mapParentIdFeedComment.keyset()]);
            if(mapOpptyReporting.size()>0){
                for(Opportunity_Reporting__c opptyReporting:mapOpptyReporting.values()){
                    if(opptyReporting.Post_Comment__c==null){
                        opptyReporting.Post_Comment__c = mapParentIdFeedComment.get(opptyReporting.Chatter_Post_Id__c).CommentBody;
                    }
                    else{
                        oldComments = opptyReporting.Post_Comment__c;
                        opptyReporting.Post_Comment__c = oldComments+';'+(mapParentIdFeedComment.get(opptyReporting.Chatter_Post_Id__c).CommentBody);
                    }
                    opptyReporting.Related_To_Post__c = opptyReporting.Chatter_Post_Id__c;
                }
            }   
            update mapOpptyReporting.values();                                                                                                  
        }
    }
/* @Method <This method execute is used to map chatter post comments on Opportunity to Opportunity Reporting>
@param <This method takes Map<Id,Attachment> as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/
@future
    public static void mapStatusUpdates(Set<Id> setId, Boolean isDelete){
        List<Opportunity_Reporting__c> lstOpptyReporting = new List<Opportunity_Reporting__c>();
        Map<Id,User> mapUser = new Map<Id,User>([Select Id,LastModifiedDate,CreatedById,CurrentStatus from User where Id in :setId]);
        Map<DateTime,User> mapLastModifiedDate = new Map<Datetime,User>();
        Map<Id,Id> mapUserFeed = new Map<Id,Id>();
        for(User usr : mapUser.values()){
            mapLastModifiedDate.put(usr.LastModifiedDate,usr);  
        }
        if(!isDelete){
            List<FeedItem> lstFeed = [Select Id,Body,ParentId from FeedItem where CreatedDate=:mapLastModifiedDate.keyset() AND CreatedById=:mapUser.keyset()];
            for(FeedItem feed:lstFeed){
                mapUserFeed.put(feed.ParentId,feed.Id); 
            }
            for(User usr:mapUser.values()){
                Opportunity_Reporting__c opptyReporting = new Opportunity_Reporting__c();
                
                opptyReporting.Post_Information__c = usr.CurrentStatus;
                opptyReporting.User__c = usr.Id;
                opptyReporting.Posted_On__c = 'User Profile';
                opptyReporting.Date_Time_Posted__c = usr.LastModifiedDate;
                opptyReporting.Chatter_Post_Id__c = mapUserFeed.get(usr.Id);
                lstOpptyReporting.add(opptyReporting);
                
                system.debug('lstFeed--->'+lstFeed);
            }
        }
        insert  lstOpptyReporting;
        /*if(isDelete){
            List<Opportunity_Reporting__c> lstOpptyReportingToDelete = [select Id from Opportunity_Reporting__c where Chatter_Post_Id__c in :mapChatterPost.keyset()];      
            if(lstOpptyReportingToDelete.size()>0){
                delete lstOpptyReportingToDelete;
            }   
        }*/
    }  
 /* @Method <This method checks whether the posted user belongs to chatter free suer profile or not.>
@param <This method takes Map<Id,FeedItem> as parameter: this contains the data of the feed item and the suer details>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
 */
    public boolean isChatterFreeUser(FeedItem objFeedItem)
    {
     //Srinivas : Declare a string variable to hold the profile name
     String strProfileName = 'Chatter Free User';
     //Srinivas: get the user details based on the user id from feed item record
     User objUser = [select id,Profile_Name__c from User where id =: objFeedItem.CreatedById];
     system.debug('objUser == '+objUser);
     //Srinivas: If the current user belongs to "Chatter free user" then return false else return true.
     if(objUser.Profile_Name__c == strProfileName)
        return false;
    
      return true; 
    }
/* @Method <This method execute is used to track first post on Case feed>
@param <This method takes Map<Id,FeedItem> as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/
	public void isFirstPost (Map<Id,FeedItem> mapFeed){
	try{
		Map<Id,Id> mapCaseIdOwnerId = new Map<Id,Id>();
		for(FeedItem feed:mapFeed.values()){
			mapCaseIdOwnerId.put(feed.ParentId,feed.CreatedById);	
		}
		system.debug('mapCaseIdOwnerId--->'+mapCaseIdOwnerId);
		Map<Id,Case> mapCase = new Map<Id,Case>([Select Id,OwnerId,New_Chatter__c from Case where Id in: mapCaseIdOwnerId.keyset()]);
		if(mapCase.size()>0){
			for(Case caseRecord:mapCase.values()){
				if(caseRecord.OwnerId!= mapCaseIdOwnerId.get(caseRecord.Id) && caseRecord.New_Chatter__c==false){
					caseRecord.New_Chatter__c = true;	
				}	
			}
			update mapCase.values();
		}
	}
	catch(Exception e){
		system.debug('Exception--->'+e);	
	}	
	} 
}