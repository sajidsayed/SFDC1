/*==================================================================================================================+

 |  HISTORY  |                                                                            

 |  DATE          DEVELOPER                WR       DESCRIPTION                               
   
 |  ====          =========                ==       =========== 

 | 2/7/2010       Ashwini Gowda                  This class will be called by LeadBeforeUpdate Trigger on Lead.
                                                 Rejected Leads which were sent from EMC to Partner/Distributor 
                                                 or directly to T2s will be routed to a Rejection Queue 
                                                 appropriately. If the lead was touched by an EMC Employee, 
                                                 the lead would be routed to the Last Owner. 
                                                 
 | 21/7/2010      Saravanan C                    Added update upon lead rejection in default partnering  
 | 22/7/2010      Rajeev C                       Fixed the Null pointer exception.
 | 28/7/2010      Ashwini Gowda                  If Previous Owner is Distributor and Current Owner Tier2 
                                                 Partner User, If lead is not Accepted and trying to reject.
                                                 Display error message.
   2/8/2010       Ashwini Gowda                  New CR to Include Tier1 Partner User as well for Scenario 1               
   9/8/2010       Ashwini Gowda                  Included CR#368: Ability to Reject a Lead from a Partner Queue.
   15/9/2010      Ashwini Gowda       Req# 1067  Need to give partner super user profiles the ability to reject a 
                                                 lead without clicking the 'accept lead' button. 
   
   23/9/2010      Suman B             Req# 1117  Changed the Account Field PartnerType value. Accordingly modifying 
                                                 the condition check for partnerType using Custom settings value.
   29/9/2010     Ashwini Gowda        Def#130    Fix for Defect #130.when a lead is owned by a partner user and is
                                                 passed to another partner user within the same organization.If Partner 
                                                 User rejects the Lead then assign the Lead to the Previous Owner.                                                   
                                                 Commented validation for Defect #130: Partner User cannot acccept 
                                                 and reject a Lead simultaneously.Will be taken care in Nov Release.
   8/10/2010    Ashwini Gowda                    Removed the functionality check,in case when a Lead
                                                 is assigned to Queue.Defaulting partner functionality is commented. 
                                                 Commented Line 103,269 to 291
   19/10/2010   Ashwini Gowda         1318       UnCommented Defaulting partner functionality
   
   19/10/2010   Karthik Shivprakash   Req#1177   Update the method ownerAssignment for the functionality when 
                                                 Distribution VAR user reject lead that has been flagged as 
                                                 passed from Distributor and is still owned by a Distributor.
   1/12/2010    Ashwini Gowda         Def162     Placed the Scenario 5 check above Req1177 approach.  
   5/09/2011    Prasad Kothawade                 Bypass deal regs                   
   29/6/2011	Ashwini Gowda		  Def647	 Updated the method userType() has new profiles have been added for partners.
   18/01/2013   vivek                 WR220442	 updated the Lead Owner.	         
   25/02/2013   vivek                 WR220442	 updated the Lead Owner.              
 +==================================================================================================================**/

Public Class PRM_LeadRejection {    
    
/* @Method <ownerAssignment(List<Lead> Leads): This Method would assign the values for Lead
                                     based on Current Owner and Previous Owner of the Lead.>
   @param <(List<Lead> Leads>
   <Leads -- Contains List of Leads>
   @return Map<Id,String> - <If any error occured while updating the Lead returns the 
                                corresponding error message across the Lead Id>
   @throws exception - <No Exception>
*/
    public Map<Id,String> ownerAssignment(List<Lead> Leads){ 
        
        List<String> OwnersList = new List<String>();
        //Holds the list of Current Owners and Previous Owners of Leads
        List<String> QueueNames = new List<String>();
        //Holds the List of Queue Names if the Previous Owner of Lead was a Queue
        
        Map<Id,String> OwnerType = new Map<Id,String>();
        Map<Id,String> currentOwnerType = new Map<Id,String>();
        Map<String,Id> QueueId = new Map<String,Id>();        
        
        Map<Id,String> errorMap = new Map<Id,String>();
        // Added update upon lead rejection in default partnering
        Map<Id,Account> ptnrFrmGrp = new Map<Id,Account>();
        Set<Id> usrIds = new Set<Id>();
        string distiorEMCuser;
        Map<Id,User> isPartner = new Map<Id,User>();
        list<Id> isPartnerId = new list<Id>();
        isPartnerId.add(UserInfo.getUserId());
        
        //Using the custom settings for checking the current user profile for WR#1177
        Profiles__c profilesId = Profiles__c.getInstance();
        
        final String QueueName = 'Global Assignment Queue';
                
        for(Lead lead:Leads){        	
        	//bypass for deal reg
        	if(lead.DealReg_Deal_Registration__c ){
        		continue;
        	}
        	        	
            //Check if the Lead was Rejected and Rejection Reason is populated
            if(lead.Reject_Lead__c==true && lead.Rejection_Reason__c!=null && lead.OwnerId==UserInfo.getUserId()){                
	            //If Previous Owner was not null then add the Current Owner and Previous Owner to a list
	                if(lead.Previous_Owner__c!=null){
	                    OwnersList.add(lead.Previous_Owner__c);
	                    OwnersList.add(lead.OwnerId);                     
	                } 
	            //If Previous Owner was a Queue then add the Current Owner and Queue Name to a list
	               if(lead.Last_Assigned_Q__c!=null){
	                    QueueNames.add(lead.Last_Assigned_Q__c); 
	                    OwnersList.add(lead.OwnerId);                   
	                }   
	             // Added update upon lead rejection in default partnering   
	               if(((string)lead.OwnerId).startswith('005')){
	                 usrIds.add(lead.ownerId);     
	               }            
            }
            //If lead Owner is not the logged In user and trying to reject a lead then add those leads to a Map.
            //Changes done here for WR#1177 by karthik
            //Added the condition to bypass the Distribution VAR user for WR#1177
            if(lead.Reject_Lead__c==true){
                if((UserInfo.getProfileId()!=profilesId.Tier2_Partner_User__c && UserInfo.getProfileId()!=profilesId.Tier2_Super_User__c)
                    && (lead.OwnerId!=UserInfo.getUserId() && !((string)lead.OwnerId).startswith('00G'))){
                    errorMap.put(lead.id,System.Label.Cannot_reject);
                }
            }
            
            //Changes done here for WR#1177 by Karthik
            //Added the condition to blank the Distribution VAR field for the Distribution VAR users for WR#1177
            if(lead.Reject_Lead__c==true){
                if(profilesId.Tier2_Partner_User__c==UserInfo.getProfileId() || profilesId.Tier2_Super_User__c==UserInfo.getProfileId()){
                    lead.Tier_2_Partner__c=null;
                    //Added to remove the owner from list as no need to further processing in this scenario
                    //for WR#1177 by Karthik
                    usrIds.remove(lead.ownerId);
                }
            }
        }//for Leads
        
        if(usrIds.size()>0){           
            PRM_CommonUtils utils = new PRM_CommonUtils();
            //Commented this part 
            //ptnrFrmGrp = utils.fromGroup(usrIds);
            isPartner = utils.userDetails(isPartnerId);
            System.debug('Inside usrId');
            if(isPartner.get(UserInfo.getUserId()).UserType != 'PowerPartner'){
                distiorEMCuser = 'EMCuser';
                System.debug('Inside usrId if');
            }    
        }
        
        //Pass the list of owners to get to know the usertype.
        if(OwnersList.size()>0){
            System.debug('Inside ownerList');
            OwnerType = userType(OwnersList );
        } 
         //Pass the list of QueueNames to get to know the Queue Id for the appropriate QueueName.
        if(QueueNames.size()>0){
            System.debug('Inside Queuenames');
            QueueId = queueIdentification(QueueNames);
            System.debug('QueueId  '+QueueId  );
        } 
        
        for(Lead lead: Leads){
        	decimal TimesRejected = 0;
        //bypass for deal reg
        	if(lead.DealReg_Deal_Registration__c ){
        		continue;
        	}          
        
        //Check if the Lead was Rejected and Rejection Reason is populated            
            if(lead.Reject_Lead__c==true && lead.Rejection_Reason__c!=null){                    
                System.debug('TimesRejected2 --->'+TimesRejected );
                if(lead.No_of_Times_Rejected__c>0){
                    TimesRejected=lead.No_of_Times_Rejected__c; 
                }
                
                System.debug('Number of times--->'+lead.No_of_Times_Rejected__c);
                TimesRejected=TimesRejected+1; 
                lead.No_of_Times_Rejected__c=TimesRejected;
                System.debug('TimesRejected3 --->'+TimesRejected );                
                System.debug('TimesRejected4 --->'+lead.No_of_Times_Rejected__c);
                Map<String,LeadRejectionQueue__c> RejectedQueue = LeadRejectionQueue__c.getall();            
                Map<String,IIGLeadRejectionQueue__c> IIGRejectedQueue = IIGLeadRejectionQueue__c.getall();
                String PreviousUserType = OwnerType.get(lead.Previous_Owner__c);
                String CurrentUserType = OwnerType.get(lead.OwnerId);
                    
                System.debug('Current Owner Id '+lead.OwnerId);
                System.debug('Previous Owner Id '+lead.Previous_Owner__c);
                
                //Added Scenario 5 over here for fix of Def162
                /*Scenario 5: Ability to Reject a Lead from a Partner Queue.
                  Need to allow a partner user to reject a lead directly from a partner queue 
                  to route it back to EMC or the Last Owner.*/
                if(UserInfo.getUserType() == 'PowerPartner' && ((string)lead.OwnerId).startswith('00G')){
                    System.debug('entered here-->');
                    lead.OwnerId = lead.Previous_Owner__c;
                    updateLead(lead);
                }
                 
                // Req #1177
                //assuming that lead rejection will not happen if lead owner is queue
                // except ownership chnage No. of Times Rejected 1 EMC Lead Rejected  
                // EMC Rejection Reason should all get populated and 'reject lead' should be blank
                // added by Prasad               
                
                if(!usrIds.contains(lead.ownerId)){
                    //updateLead(Lead);
                    continue;
                }
                // done Req #1177  
                
                /* rajeev-changes-22-07-2010------------ */
                Boolean isQueueExist = false ;
                if(lead.Last_Assigned_Q__c !=null){
                    if(lead.Last_Assigned_Q__c.contains(QueueName))
                        isQueueExist = true ;
                    }
                    System.debug(' PreviousUserType ==>'+PreviousUserType);
                    System.debug(' CurrentUserType ==>'+CurrentUserType);
                    System.debug(' Previous_Owner__r.UserType ==>'+lead.Previous_Owner__r.UserType);
                    System.debug(' lead.Accept_Lead__c ==>'+lead.Accept_Lead__c);
    
                    //Scenario 1: EMC User assigns a Lead to a Distributor or T2 Partner User, 
                                //and Distributor or T2 Partner User rejects the Lead
                                //Check if the Previous Owner was EMC User and Current User 
                                //who rejected is Distributor or T2 Partner User
                    //
                    if(PreviousUserType=='EMC User' &&(CurrentUserType=='Distributor Partner User'||
                        CurrentUserType=='Tier2 Partner User'||CurrentUserType=='Tier1 Partner User'||
                        CurrentUserType=='Tier1 Super User'||CurrentUserType=='Tier2 Super User'||
                        CurrentUserType=='Distributor Super User')){     
                                               
                        lead.OwnerId = lead.Previous_Owner__c;
                        lead.Partner__c = null;
                        lead.Tier_2_Partner__c = null;
                        updateLead(lead);
                    }
                    
                    //Scenario 2: Distributor assigns a Lead to a T2 Partner User, and T2 rejects a Lead
                    //If Previous Owner is Distributor and Current Owner Tier2 Partner User, If current user
                    // trying to reject without Accepting lead, Display error message.
                    //Commented this validation for Defect #130 Partner User cannot acccept and reject a 
                    //Lead simultaneously
                    /*else if(PreviousUserType=='Distributor Partner User' && CurrentUserType=='Tier2 Partner User' 
                            && lead.Reject_Lead__c==true && lead.Accept_Lead__c!=true){
                        errorMap.put(lead.id,System.Label.Accept_Before_Rejecting);
                    }*/
                    
                    //Check if the Previous Owner was Distributor User and 
                    //Current User who rejected is T2 Partner User
                    else if(PreviousUserType=='Distributor Partner User' && CurrentUserType=='Tier2 Partner User'){
                        lead.OwnerId = lead.Previous_Owner__c;
                        lead.Tier_2_Partner__c = null;
                        updateLead(lead);
                    }  
                    
                    //Scenario 3:Automated assignment rules assign a Lead to a Distributor,
                    // Tier 1 or Tier 2 Partner User, and Distributor, T1 or T2 Partner User rejects the Lead
                    //Check if the Previous Owner of the Lead was Global Assignment Queue and Current User 
                    //who rejected is Distributor, Tier 1 or Tier 2 Partner User
                     
                    else if(isQueueExist== true && (CurrentUserType=='Distributor Partner User'|| 
                            CurrentUserType=='Tier1 Partner User' || CurrentUserType=='Tier2 Partner User'||
                            CurrentUserType=='Tier1 Super User'||CurrentUserType=='Tier2 Super User'||
                            CurrentUserType=='Distributor Super User') && lead.Sales_Force__c=='EMC'){
                       	LeadRejectionQueue__c owner =(RejectedQueue.get(Lead.Country));
                       	if(owner!=null){
                           lead.OwnerId = owner.Country_Queue_Name__c;
                           lead.Partner__c = null;
                           lead.Tier_2_Partner__c = null;
                           updateLead(lead);
                       	}
                       	else{
                           //lead.addError('You can\'t reject this Lead!');
                           lead.addError(System.Label.GeoSpecific_Queue);
    
                       	}
                       	System.debug('lead.OwnerId'+lead.OwnerId);
                   	 } 
                    //Added for ESG
                	else if(isQueueExist== true && (CurrentUserType=='Distributor Partner User'|| 
                            CurrentUserType=='Tier1 Partner User' || CurrentUserType=='Tier2 Partner User'||
                            CurrentUserType=='Tier1 Super User'||CurrentUserType=='Tier2 Super User'||
                            CurrentUserType=='Distributor Super User')&& lead.Sales_Force__c=='ESG'){
                       IIGLeadRejectionQueue__c owner =(IIGRejectedQueue.get(Lead.Country));
                       if(owner!=null){
                           lead.OwnerId = owner.Country_Queue_Name__c;
                           lead.Partner__c = null;
                           lead.Tier_2_Partner__c = null;
                           updateLead(lead);
                       }
                       else{
                           //lead.addError('You can\'t reject this Lead!');
                           lead.addError(System.Label.GeoSpecific_Queue);
    
                       }
                       System.debug('lead.OwnerId'+lead.OwnerId);
                    }
                    //Moved this approach above 1177 check.
                    //Scenario 5: Ability to Reject a Lead from a Partner Queue.
                    //Need to allow a partner user to reject a lead directly from a partner queue 
                    //to route it back to EMC or the Last Owner.
                    /*else if(UserInfo.getUserType() == 'PowerPartner' && (lead.OwnerId == (partnerQueue[0].Partner_Queue__c))){
                        lead.OwnerId = lead.Previous_Owner__c;
                        updateLead(lead);
                    } */                    
                    /*else if(UserInfo.getUserType() == 'PowerPartner' && ((string)lead.OwnerId).startswith('00G')){
                        System.debug('lentered here-->');
                        lead.OwnerId = lead.Previous_Owner__c;
                        updateLead(lead);
                    } */
                    
                    //Fix for Defect #130
                    //Assumption: Here we assume both the Previous and the current Lead Owners 
                    //will fall under same organization as they will not have visibility to other Accounts.
                    else if((PreviousUserType=='Distributor Partner User'||PreviousUserType=='Tier1 Partner User'
                            ||PreviousUserType=='Distributor Super User'||PreviousUserType=='Tier2 Partner User' 
                            ||PreviousUserType=='Tier1 Super User'||PreviousUserType=='Tier2 Super User')&&(
                             CurrentUserType=='Distributor Partner User'||CurrentUserType=='Tier1 Partner User'
                            ||CurrentUserType=='Distributor Super User'||CurrentUserType=='Tier2 Partner User' 
                            ||CurrentUserType=='Tier1 Super User'||CurrentUserType=='Tier2 Super User' )){               
                        lead.OwnerId = lead.Previous_Owner__c;
                        System.debug('lead.OwnerId for def130'+lead.OwnerId);
                        updateLead(lead);
                    }  
                    //Scenario 4:Lead is directly reassigned from a queue by an EMC or Partner User 
                    //to a Partner User, and Partner User rejects the Lead
                    //Check if the previous owner of the Lead was a queue and Current User who rejected is Partner User
                    else if(lead.Last_Assigned_Q__c!=null ){
                    // Added update upon lead rejection in default partnering
                    string partnerType ;
                    
                /** Added as per Req#1117. **/
                    Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
                    String distributionVAR = data.get('Tier2 Partner Type').DataValue__c ;
               /** Changes End. **/
                    //Commented to remove Defaulting Partner Functionality
                        if(((string)lead.OwnerId).startswith('00G')){
                           if(ptnrFrmGrp.get(lead.ownerid).Partner_Type__c == null ){
                                if(ptnrFrmGrp.get(lead.ownerid).Profiled_Account__c != null ){
                                    partnerType = ptnrFrmGrp.get(lead.ownerid).Profiled_Account__r.Partner_Type__c;
                                }else{
                                   partnerType = 'update tier 1/ distributor';
                                    }
                                }else{
                                    partnerType = ptnrFrmGrp.get(lead.ownerid).Partner_Type__c;
                                }
                                
                           if(partnerType.contains(distributionVAR)  && ptnrFrmGrp.get(lead.ownerid).Lead_Oppty_Enabled__c == True && (partnerType.indexOf(';') == -1)){
                                lead.Tier_2_Partner__c = ptnrFrmGrp.get(lead.ownerid).id;
                                lead.Partner__c = null;
                            }
                            else{                               
                              if(distiorEMCuser == 'EMCuser'){
                                lead.Partner__c = ptnrFrmGrp.get(lead.ownerid).id;
                                lead.Tier_2_Partner__c =null;
                              } 
                            }     
                        }                        
                        System.debug('QueueId-->  '+ QueueId.get(lead.Last_Assigned_Q__c));
                        lead.OwnerId = QueueId.get(lead.Last_Assigned_Q__c);
                        System.debug('lead.OwnerId'+lead.OwnerId);
                        System.debug('TimesRejected'+lead.Last_Assigned_Q__c);                   
                        
                        updateLead(lead);
                    }                                            
	        }
	    }
    	return errorMap ;
    }
    
/* @Method <userType(List<String> userIds): This Method returns the Id and user Type ie, type of user if its EMC User or Partner User or Distributor for the List of Users Passed>
   @param <userType(List<String> userIds)>
   <userIds -- Contains all Owner Ids of Leads>
   @return <Map<Id,String>> - <Returns the Type of the Profile across UserId>
   @throws exception - <No Exception>
*/     
    public Map<Id,String> userType(List<String> userIds){
        Map<Id,String> userType = new Map<Id,String>();
        //List<Opportunity__c> profileId = Opportunity__c.getall().Values();
        
        Map<String,DealRegistration_CustomSetting__c>  data =  DealRegistration_CustomSetting__c.getall();
        String DistributorPartnerUser = data.get('Distributor Partner User').ParnterProfileID__c;
        String Tier1PartnerUser = data.get('Tier1 Partner User').ParnterProfileID__c;
        String Tier2PartnerUser = data.get('Tier2 Partner User').ParnterProfileID__c;
        String Tier1SuperUser = data.get('Tier1 Super User').ParnterProfileID__c;
        String Tier2SuperUser = data.get('Tier2 Super User').ParnterProfileID__c;
        String DistributorSuperUser = data.get('Distributor Super User').ParnterProfileID__c;  
        
        
        Profiles__c profileId = Profiles__c.getInstance(); 
            for(User[] users: [Select u.ContactId, u.ProfileId,u.UserType from User u  where u.Id in :userIds]){
            for(User user:users){
            	System.debug('user.UserType '+ user.UserType);
            	System.debug('user.ProfileId '+ user.ProfileId);
            	
            	String UserProfile = user.ProfileId;
		        if(UserProfile != null && UserProfile.length() >15){
		            UserProfile = UserProfile.substring(0, 15);
		        }
		        
                if(user.UserType != 'PowerPartner'){
                    userType.put(user.id,'EMC User');
                }
                //else if( user.ProfileId==profileId.Distributor_Partner_User__c){
                //else if( user.ProfileId==profileId.Distributor_Partner_User__c){
                else if(DistributorPartnerUser.contains(UserProfile)){
                    userType.put(user.id,'Distributor Partner User');
                }
                //else if( UserProfile == profileId.Tier1_Partner_User__c){
                else if(Tier1PartnerUser.contains(UserProfile)){
                    userType.put(user.id,'Tier1 Partner User');
                }
                //else if( UserProfile == profileId.Tier2_Partner_User__c){
                else if(Tier2PartnerUser.contains(UserProfile)){
                    userType.put(user.id,'Tier2 Partner User');
                }
                //Added check for Tier1 and Tier2 Super Users for WR# 1067
                //else if( UserProfile == profileId.Tier1_Super_User__c){
                else if(Tier1SuperUser.contains(UserProfile)){
                    userType.put(user.id,'Tier1 Super User');
                }
                //else if(UserProfile == profileId.Tier2_Super_User__c){
                else if(Tier2SuperUser.contains(UserProfile)){
                    userType.put(user.id,'Tier2 Super User');
                }
                //else if( UserProfile == profileId.Distributor_Super_User__c){
                else if(DistributorSuperUser.contains(UserProfile)){
                    userType.put(user.id,'Distributor Super User');
                }
                else{
                    userType.put(user.id,'PowerPartner');
                }
            }
        }  
        System.debug('userType Map value'+userType);       
        return userType; 
            
    }
        
/* @Method <queueIdentification(List<String> QueueOwners): This method returns the Queue Id 
                along with the Queue Name in a Map for list of Queues passed>
   @param <userType(List<String> userIds)>
   <userIds -- Contains all Queue Names>
   @return <Map<String,Id> - <Returns the Queue Id along with the Queue Name>
   @throws exception - <No Exception>
*/ 
    public Map<String,Id> queueIdentification(List<String> QueueOwners){
    System.debug('Inside queue method ');
    Map<String,Id> QueueDetails = new Map<String,Id>();
        for(QueueSobject[] Queues: [Select q.Queue.Name,Queue.Id, q.SobjectType 
                                    from QueueSobject q  
                                    where Queue.Name in :QueueOwners]){
            for(QueueSobject Queue:Queues){
            System.debug('Queue'+Queue.Queue.Id);
            if(Queue.Queue.Name!=null){
                QueueDetails.put(Queue.Queue.Name,Queue.Queue.Id);
            }
            }
        }
        System.debug('QueueDetails '+QueueDetails);
        return QueueDetails;
    }
/* @Method <updateLead(Lead lead: Updates the Lead with appropriate values>
   @param <Lead lead> Lead passed>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/    
    public void updateLead(Lead lead){
        lead.EMC_Lead_Rejected__c = true;
        lead.EMC_Rejection_Reason__c = lead.Rejection_Reason__c;
        lead.Reject_Lead__c=false;
        lead.Rejection_Reason__c='';
    }
    
      //WR #220442
    Public void partnerRejection (List<Lead> updatedLeads, List<Lead> existingLeads) {
		for(Integer i=0;i<updatedLeads.size();i++)    {
			Lead updatedLead = updatedLeads[i];
			Lead existingLead = existingLeads[i];
			System.debug('updatedLead'+updatedLead+'existingLead'+existingLead);
			if  ( (((string)updatedLead.OwnerId).startswith('005')) &&
			      (updatedLead.Accept_Lead__c != updatedLead.EMC_Lead_Rejected__c) &&
			      (updatedLead.EMC_Lead_Rejected__c != existingLead.EMC_Lead_Rejected__c) &&
			      (updatedLead.EMC_Lead_Rejected__c == true) &&
			      (updatedLead.Last_EMC_Owner__c != null)) {
			      updatedLead.OwnerId = updatedLead.Last_EMC_Owner__c ;
			}
		}
    }
    //End

}