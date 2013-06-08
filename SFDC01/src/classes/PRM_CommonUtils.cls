/*===========================================================================+
 |  HISTORY      
 |                                                                           
 |  DATE       DEVELOPER     WR     DESCRIPTION                               
 |  ====       =========     ===    =========== 
 |  25-Jun-10  Saravanan C          Initial creation
 |  20-Jul-10  Saravanan C          Added three methods for PRM_PopulatePartnerOnLead. fromUser(),fromGroup() and userDetails() 
 |  02-Sep-10  Suman B              Modified query in userDetails method to include Forecast_Group__c field.   
 |  06-Oct-10  Anand Sharma         Removed try catch from code to handle exception 
 |  08-Oct-10  Ashwini Gowda        Removed the functionality check,in case when a Lead
 |                                  is assigned to Queue.Commented Method fromGroup().
 |  19-Oct-10  Ashwini Gowda 1318   Removed Commented part from Method fromGroup().Updated Method
 |                                  fromGroup() to query against QueueSobject. 
 |  27-Oct-10  Saravanan C          Defect - 147. updated recordtypeid filter from where condition on fromgroup method Soql Query.
 |  17-Sep-11  Anirudh              Updated fromUser method 
 |  5 June 2012 Arif                For Internal Server Error issue, if a standard user is changing the ownership of a lead to another standard user.                       
 +===========================================================================*/

Public Class PRM_CommonUtils {

      public static boolean isOpportunityAfterUpdateExecuted=false;
     
     Public Boolean isPartnerUser(Id userID){
      Boolean Flag = False;
     try{
           user userinfo = [select id,UserType,ContactId from user where id =: userID];
           system.debug('**** userinfo.UserType ****'+userinfo.UserType);
           if(userinfo.UserType == 'PowerPartner'){
           system.debug('**** isPartnerUser ? **** Yes ****');
            Flag = true;
           }
       }catch (exception e){
           
       }
       return flag;
     }

  
    /**
        * Method <userType()is to check with user is a Partner User or not >
        *   @param <This method is taking UserIds as argument.> 
        *   @return <Set<String> - < Returning Set Users.>
        *   @throws exception-<No exception >
     */
    public Set<String> userType(List<String> userIds){
    Set<String> PartnerUsers = new Set<String>();
    for(User[] users: [Select u.ContactId, u.ProfileId,u.UserType,u.Id from User u  where u.Id in :userIds]){
        for(User user:users){
        //Check if the user is a PowerPartner
            if(user.UserType == 'PowerPartner'){
                PartnerUsers.add(user.id);
            }
        }
    }
    return PartnerUsers;
    }
    
     /**
        * Method <fromUser()is to fetch the contact details if the user is partner from user object>
        *   @param <This method is taking UserIds as argument.> 
        *   @return Map<Id,Contact> 
        *   @throws exception-<Null Pointer exception if the user is not partner type>
     */
      Public Map<Id,Contact> fromUser(List<Id> userIds){
      Map<Id,Contact> retDetail = new Map<Id,Contact>();
      list<id> ProfiledcontId = new list<Id>();
      list<id> NonPfAcContId= new list<Id>();
      Contact[] contsList; 
      try{          
          User[] userList = [Select ContactId,Contact.Account.Profiled_Account_Flag__c,UserType,Id from User   where Id in :userIds];
          for(user u: userList){
              if(u.contactId != null){
                  if(u.Contact.Account.Profiled_Account_Flag__c==true){
                     ProfiledcontId.add(u.ContactId);
                  }
                  else{                  
                       system.debug('----------------->I m non profiled');
                       NonPfAcContId.add(u.ContactId);
                  }
              }     
          }
          if(ProfiledcontId.size()>0){
              contsList = [select id,account.id,account.Preferred_Distributor__c,account.Lead_Oppty_Enabled__c,account.Profiled_Account__c,account.owner.Email,account.Partner_Type__c,account.name from contact where id in : ProfiledcontId];
          }
          if(NonPfAcContId.size()>0){
              system.debug('----------------->NonPfAcContId' +NonPfAcContId);
              contsList = [select id,account.id,account.Preferred_Distributor__c,account.Profiled_Account__r.Preferred_Distributor__c,account.Lead_Oppty_Enabled__c,account.Profiled_Account__c,account.owner.Email,account.Partner_Type__c,account.name from contact where id in : NonPfAcContId];
          }
          for(user u: userList){
           for(Contact c: contsList){
             
              if(u.ContactId == c.id){
                  retDetail.put(u.id,c);
              }
           }
          }
        }catch (exception e){
            
        }   
      return retDetail;
     }
  
   /**
        * Method <fromGroup()is to fetch the Account details if the user is partner from Group>
        *   @param <This method is taking UserIds as argument.> 
        *   @return Map<Id,Account> 
        *   @throws exception-<Null Pointer exception if the Queue_Name__c is null on account record>
     */
     /* removed try catch block from this to display exception to user
        for Lead Inbox issue.
     */
     
    Public Map<Id,Account> fromGroup(list<Id> userIds){
     Map<Id,Account> retDetail = new Map<Id,Account>();
     
     //try{
      //User[] users = [Select ContactId,UserType,Id from User where Id in :userIds];      
      Map<String,Id> QueueMap = new Map<String,Id>();
      //Query against QueueSobject for the Queue Ids returned.
      for(QueueSobject obj: [Select q.Queue.Name, q.SobjectType,q.Queue.Id 
                             from QueueSobject q  
                             where Queue.Id in :userIds]){
        QueueMap.put(Obj.Queue.Name,Obj.Queue.Id);
      }
       System.debug('QueueMap---->'+QueueMap);        
       /*** Defect - 147 Starts ***/
      //Using CustomSettingDataValueMap__c Custom Setting 
   /*   Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
      String partnerAccountRecordTypeId = data.get('Partner Account Record Type').DataValue__c ;       
    */  
      //Check all the partner accounts with the Queue_Name__c field populated,
      //and find the account associated with the queue 
          list<String> prtrRcdTypeIds = new list<string>();
          string rcdTypeId;
        Schema.DescribeSObjectResult accountSchema = Schema.SObjectType.Account;
        Map<String,Schema.RecordTypeInfo> rtMapByName = accountSchema.getRecordTypeInfosByName();
        
        for ( string s : rtMapByName.keyset()) {
            System.debug('s ---->'+s);
            if (s != 'Standard Account Record Type'  ){
            Schema.RecordTypeInfo accountRT = rtMapByName.get(s);
            rcdTypeId = accountRT.getRecordTypeId();
             rcdTypeId = rcdTypeId.substring(0,15);
                 prtrRcdTypeIds.add(rcdTypeId);
            }
        }
   
        
           System.debug('prtrRcdTypeIds ---->'+prtrRcdTypeIds );
      Account[] Accs = [select Queue_Name__c,id,Partner_Type__c,Profiled_Account__c,
                        Profiled_Account__r.Partner_Type__c,Lead_Oppty_Enabled__c,name,IsPartner 
                        from Account 
                        where recordtypeid in: prtrRcdTypeIds
                        and Queue_Name__c !=null and IsPartner=true ];      
      
       /*** Defect - 147 Ends***/
      
       System.debug('Accs ---->'+Accs );
      if(Accs.size()>0){
          for(String queueName:QueueMap.KeySet()){
            for(Account a: Accs){
              if(queueName == a.Queue_Name__c){
                 retDetail.put(QueueMap.get(queueName),a);             
              }
           }
          }
      }
      System.debug('retDetail---->'+retDetail);
       
    //}catch (exception e){
   // }
    
      return retDetail;
   }
    
  /**
        * Method <userDetails()is to fetch the user details if the user is partner >
        *   @param <This method is taking UserIds as argument.> 
        *   @return Map<Id,User> 
        *   @throws exception-<Null Pointer exception if the userIds is null>
     */ 
  public Map<Id,User> userDetails(List<String> userIds){
    Map<Id,User> retDetail = new Map<Id,User>();
        try{
            for(User[] users: [Select ContactId, ProfileId,UserType,Forecast_Group__c,Id from User  where Id in :userIds]){
                for(User u:users){
                  retDetail.put(u.id,u);
                }
            }
        }catch (exception e){
        }
    return retDetail;
    }
    
  public String getQueryFormattedDate(DateTime dt){
        String strDate=dt.format('yyyy-MM-dd HH:mm:ssZ').substring(0,10)+'T'+ dt.format('HH:mm:ssZ');
         //strDate=  strDate+strDate.substring(0,strDate.length()-2)+':' +strDate.substring(strDate.length()-2);
         strDate= strDate.substring(0,strDate.length()-2)+':' +strDate.substring(strDate.length()-2);
         return strDate;
  }
  
}