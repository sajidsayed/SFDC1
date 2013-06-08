/*================================================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                WR        DESCRIPTION                               

|  ====          =========                ==        =========== 

| 24/12/2011     Accenture                183061   This class is used to create Partner Queues 
                                                   automatically whenever first Partner User is created
|                                                  on Profiled Account.
| 23/01/2012	 Accenture                         Changed SubString Length     
| 29/06/2012     Ganesh                  IM7880845 Handling Duplicate Lead queues                                                  
+=====================================================================================================*/
public class QueueHelper{
    
    public static boolean QueueCreationExecuted=true;
    
    /* @Method <This method is used to invoke fetchRolesforQueueCreation()for QueueNames>.
       @param <This is method is taking set of AccountIds from UserAfterInsert trigger>
       @return - void
       @throws exception - <No Exception>
    */
    @ future
    public static void generateQueueNamesToCreateQueue(set<string> setFromTrigger){
        String QueueName='';
        String strCountryname='';
        String countrycode='';
        Map<String,Id> MapQueueNameWithAccId = New Map<String,Id>();
        Map<String,Id> MapQueueNameToCreateWithAccId = New Map<String,Id>();
        Map<String,CustomSettingCountryTheaterMapping__c> CountryClusterMapping = CustomSettingCountryTheaterMapping__c.getAll();
        Map<String,CustomSettingCountryTheaterMapping__c> LowerCaseCountryClusterMapping = new Map<String,CustomSettingCountryTheaterMapping__c>();
        for(string countryname : CountryClusterMapping.keyset()){
            string lowercaseCountry = countryname.toLowerCase();
            LowerCaseCountryClusterMapping.put(lowercaseCountry,CountryClusterMapping.get(countryname));
        }
        Map<Id,Account> MapProfiledAccount = New Map<Id,Account>([Select Id,Name,BillingCountry,Owner.Email from Account where id in :setFromTrigger and Profiled_Account_Flag__c =true]);      
        for(Id accId :MapProfiledAccount.keyset()){
            strCountryname = MapProfiledAccount.get(accId).BillingCountry.toLowerCase(); 
            if(LowerCaseCountryClusterMapping.get(strCountryname).CountryCode__c !=null){      
               countrycode = LowerCaseCountryClusterMapping.get(strCountryname).CountryCode__c;
               QueueName = 'Partner - '+countrycode+' - ' + MapProfiledAccount.get(accId).Name;
              
              //Added by Ganesh
              integer QueueNameLength = QueueName.length();
              if(QueueNameLength>40)
              QueueName= QueueName.substring(0,40).trim();  
              else
              QueueName= QueueName.substring(0,QueueNameLength).trim();
                
             }                    
             MapQueueNameWithAccId.put(QueueName,accId);
        }
        Map<Id,Group> PartnerQueue = New Map<Id,Group>([SELECT DoesIncludeBosses, RelatedId, OwnerId, Type, Name, Id FROM Group where type='Queue' and Name in :MapQueueNameWithAccId.keyset()]);
        set<String> setParnerQueueName = new set<string>();
        for(Group Queue :PartnerQueue.values()){
            setParnerQueueName.add(Queue.Name);
        }
        for(String QueueNameToCreate:MapQueueNameWithAccId.keyset()){
            if(!setParnerQueueName.contains(QueueNameToCreate)){
                MapQueueNameToCreateWithAccId.put(QueueNameToCreate,MapQueueNameWithAccId.get(QueueNameToCreate));
            }
        }
        if(MapQueueNameToCreateWithAccId.size()>0){
           fetchRolesforQueueCreation(MapQueueNameToCreateWithAccId);   
        }
        if(MapQueueNameToCreateWithAccId.size()>0 && MapProfiledAccount.size()>0){
           SendEmailToCAM(MapQueueNameToCreateWithAccId,MapProfiledAccount);
        }                                                     
    }    
    /* @Method <This method is used to invoke createQueue()for the Partner Profiled
       Account On which users are getting created>.
       @param <This is method is taking Map<String,Id> as Input Parameter>
       @return - void
       @throws exception - <No Exception>
    */    
     public static void fetchRolesforQueueCreation(Map<String,Id> MapQueueNameToCreateWithAccId){           
         List<Id> RelatedRoleId = new List<Id>(); 
         Map<String,Group> MapPartnerQueueCreated = new Map<string,Group>();                         
         Map<Id,UserRole> MapUserRole = New Map<Id,UserRole>([SELECT Id, PortalType, PortalRole, PortalAccountOwnerId, ForecastUserId, RollupDescription,
                                                              ParentRoleId, Name, PortalAccountId FROM UserRole where PortalAccountId in :MapQueueNameToCreateWithAccId.values()]); 
         Map<Id,List<Id>> MapAccountIdWithUserRole= New Map<Id,List<Id>>();         
         for(UserRole RoleObj :MapUserRole.values()){
             List<Id> LstUserRoleId = MapAccountIdWithUserRole.get(RoleObj.PortalAccountId);
             if(LstUserRoleId==null){
                LstUserRoleId = new List<Id>();
             }
             LstUserRoleId.add(RoleObj.Id);
             MapAccountIdWithUserRole.put(RoleObj.PortalAccountId,LstUserRoleId);
         } 
         System.Debug('MapAccountIdWithUserRole==>' +MapAccountIdWithUserRole);
         for(Id AccId :MapAccountIdWithUserRole.keyset()){
             for(Id RoleIdToAdd :MapAccountIdWithUserRole.get(AccId)){
                 RelatedRoleId.add(RoleIdToAdd);
             }
         }
         System.Debug('RelatedRoleId--->' +RelatedRoleId);
         Map<Id,Group> MapPortalRoleSubOrdntGroup = new Map<Id,Group>([SELECT DoesIncludeBosses, RelatedId, OwnerId, Type, Name, Id FROM Group where type='RoleAndSubordinates' and RelatedId in :RelatedRoleId]);                                               
         System.Debug('MapPortalRoleSubOrdntGroup-->' +MapPortalRoleSubOrdntGroup);
         Map<Id,Id> RoleWithGroupId = new Map<Id,Id>();
         for(Group grpObj :MapPortalRoleSubOrdntGroup.values()){             
             RoleWithGroupId.put(grpObj.RelatedId,grpObj.Id);
         }
         System.Debug('RoleWithGroupId--->' +RoleWithGroupId);
         Map<Id,Set<Id>> mapAccountIdWithGroupId = New Map<Id,Set<Id>>();          
         for(Id accid :MapAccountIdWithUserRole.keyset()){
            set<Id> setGroupId = new set<Id>();
             for(Id roleId :MapAccountIdWithUserRole.get(accid)){
                 setGroupId.add(RoleWithGroupId.get(roleId));
                                 
             }
              mapAccountIdWithGroupId.put(accid,setGroupId);
         }                    
         System.Debug('mapAccountIdWithGroupId===>' +mapAccountIdWithGroupId);
           
           
           if(MapQueueNameToCreateWithAccId.keyset().size()>0){
           	  
              MapPartnerQueueCreated = createQueue(MapQueueNameToCreateWithAccId.keyset()); 
           }
           Map<String,set<Id>> MapQueueWithMembers = new Map<String,set<Id>>();
           for(string CreatedQueueName :MapPartnerQueueCreated.keyset()){
               MapQueueWithMembers.put(CreatedQueueName,mapAccountIdWithGroupId.get(MapQueueNameToCreateWithAccId.get(CreatedQueueName)));
           }
           System.Debug('MapQueueWithMembers--->' +MapQueueWithMembers);
           if(MapQueueWithMembers.size()>0){
           System.Debug('InsideAddMembersMethod');
              addmember(MapQueueWithMembers,MapPartnerQueueCreated.values()); 
           }
     }
    

    /* @Method <This method is used to create a Queue for the given QueueName>.
       @param <This is method is taking Set of String queueName as Parameter>
       @return Map<String, Group> - <Returning Map of Queue Name and Queue >
       @throws exception - <No Exception>
    */
        public static Map<String, Group> createQueue(Set<String> queueNames){
                    LIst<Group> lstGroup = new List<Group>();
                    List<String> lstGroupName = new List<String>();
                    LIst<QueueSobject> lstQueueSobject = new List<QueueSobject>();
                    Map<String, Group> mapGroup = new Map<String, Group>(); 
                    Integer start = System.Now().millisecond();
                   		  	                          
            for(String strQueue: queueNames){
                            Group grp = new Group(); 
                            if(strQueue.length()>0 && strQueue !=null){
	                            grp.name = strQueue;
	                            grp.Type = 'Queue' ;
	                            lstGroup.add(grp);
	                            lstGroupName.add(grp.name);
                            }
            }
            insert lstGroup;                             
                                    //createQueueForGroup(lstGroupName);
                                    for(Group objGroup: lstGroup){
                            QueueSobject queue =  new QueueSobject();
                            queue.QueueId = objGroup.id; 
                            queue.SobjectType = 'Lead';
                            lstQueueSobject.add(queue) ;
                            mapGroup.put(objGroup.name, objGroup);
            }
            insert lstQueueSobject;     
            return mapGroup;
        } 
     
    
    /* @Method <This method is used to delete a Queue for the given Queue Id>
       @param <This is method is taking String queueId as Parameter>
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
    */  
        public void deleteQueue(String queueId){
            QueueSobject delQueue = [Select q.QueueId, q.SobjectType from QueueSobject q where QueueId=:queueId];
            delete delQueue;
        }
     
    /* @Method <This method is used to add Group Member for a Queue or Group>.
       @param <This is method is taking Map of  queueId and List<Id> userIdList as Parameter>
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
    */  
        public static void addmember(Map<String,Set<Id>> mapQueueAndMembers, List<Group> lstQueue){
            List<GroupMember> groupmembers = new List<GroupMember>();
            Map<String, Group> mapQueue = new Map<String, Group>();
            for(Group objQueue: lstQueue){
                    mapQueue.put(objQueue.Name, objQueue);
            }
            for(String strQueue: mapQueueAndMembers.keySet()){
                                                    for(Id userId: mapQueueAndMembers.get(strQueue)){
                                                                    GroupMember groupmember = new GroupMember();
                    groupmember.UserOrGroupId = userId;
                    groupmember.GroupId = mapQueue.get(strQueue).Id;
                    groupmembers.add(groupmember);   
                                                    }
    
            } 
            insert groupmembers;
        }  
        
		 /*@Method <Method to send notifications to ChanneLAccountManagers Once Queue is created.>
	    @param <Map<string,Id> QueueNameWithAccId,Map<Id,Account> MapProfiledAccountWithCAM>
	    @return <void> - <Not returning anything>
	    @throws exception - <No Exception>
	*/ 
	    
	    public static void SendEmailToCAM(Map<String,Id> MapQueNameWithAccId, Map<Id,Account> MapProfiledAccount){
	        User user = [select Id,contact.accountId,contact.account.Party_Number__c,Name,contactId,Email,Phone from User where id = :UserInfo.getUserId()];
	        String subject = 'Deletion of Lead List View on Lead';
	        List<String> emailIdToSendMail = new List<String>();
	        Map<Id,string> MapAccIdWithCamEmail = new Map<Id,string>();	                 
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        for(Account accObj: MapProfiledAccount.values()){
	        	MapAccIdWithCamEmail.put(accObj.Id,accObj.Owner.Email);
	        }	
	        
	        for(string QueCreated : MapQueNameWithAccId.keyset()){
	        	emailIdToSendMail.add(user.Email);
	            System.Debug('emailIdToSendMail--->' +emailIdToSendMail);
	                
	         	 String QueueMailtoSend = 'Please login into Salesforce.com and delete Lead List View following below steps:'+'<br/>'+'<br/>'+
	         	 							'1.'+ '&nbsp;&nbsp;&nbsp;&nbsp'+ ' Click on the Leads Tab ' +'<br/>' +'2.'  +'&nbsp;&nbsp;&nbsp;&nbsp'+' Choose the Lead Queue name from the View Dropdown: '+QueCreated + '<br/>'
	         	                           +'3.'+'&nbsp;&nbsp;&nbsp;&nbsp'+ ' Click Go!' +  '<br/>' +  '4.' +'&nbsp;&nbsp;&nbsp;&nbsp'+    ' Click Delete' +'<br/>' 
	         	                           +'5.'+'&nbsp;&nbsp;&nbsp;&nbsp'+   ' There will be a pop up confirming you would like to delete the List View.'   + '<br/>'  + 
	         	                           '&nbsp;&nbsp;&nbsp;&nbsp'+'&nbsp;&nbsp;&nbsp;&nbsp'+'a.'+' Click OK to confirm.' +'<br/>'+
	         	                           '6.'+'&nbsp;&nbsp;&nbsp;&nbsp'+'Navigate to the profiled account.'+ '<br/>'+
	         	                           '7.'+'&nbsp;&nbsp;&nbsp;&nbsp'+'Populate the â€˜Lead Queueâ€™ field with:' +' ' +QueCreated+'<br/>'+'<br/>'+
	         	                           'For more detailed instructions please click:'+'&nbsp;&nbsp;'+'<a href ="https://c.na5.content.force.com/servlet/servlet.FileDownload?file=01570000001UAng" target="_blank">Help & Training Job Aid</a>';
	                          
	                  mail.setToAddresses(emailIdToSendMail); 
	                  mail.setSaveAsActivity(false);
	                  mail.setHtmlBody(QueueMailtoSend);
	                  mail.setSubject(subject);
	                  mail.setBccSender(true);
	                  Messaging.SendEmailResult [] res = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	        }          
	          
	     }
        
}