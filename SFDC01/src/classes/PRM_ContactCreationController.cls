/*=================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 | 16/04/2011	  Anirudh Singh            2515		This class is used for the Manual creation of Contacts
 |												    for the education records that are assigned to Fall Out Queue.			 
+==================================================================================================*/
Public class PRM_ContactCreationController {                          
                      
       
     Education__c education;
     string result;
     string errormsg;                      
     string successmg;
     List<Id> lstAccountIds = New List<Id>();
     Account ProfiledAccount = new Account();
     Id Accountowner;
     List<User> ActiveAccountOwner = New List<User>();
     List<Account> lstGroupingAccount = New List<Account>();
     List<Contact> lstContact = New List<Contact>();
     PageReference returnPage = null; 
     Contact newcontact = new Contact();
  
  public PRM_ContactCreationController(ApexPages.StandardController controller) { 
    
         education = [select id, First_Name__c,OwnerId,Last_Name__c,Email__c,Cert_ID__c,Partner_Grouping__c from Education__c where id =
                      :ApexPages.currentPage().getParameters().get('id')];
         System.Debug('Education Id -->' +education);     
  
         //processEducation(education);
      
  }
  
    
          
    public pagereference processEducation(){
        result= validateEducation();
        if(result=='Success'){
            createContactAndUpdateEducation();
        }
        if(errormsg!=null){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,errormsg);
           ApexPages.addMessage(msg);   
        }
        if(successmg!=null){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info,successmg);
           ApexPages.addMessage(msg);   
        }
        return null;
    }
    public string validateEducation(){
         if(!((String)education.OwnerId).StartsWith('00G')){              
                errormsg=System.Label.Education_Not_Owned_By_Queue;                
                return errormsg;          
         }
         if(education.Partner_Grouping__c==Null){              
                errormsg=System.Label.Can_not_create_Contact_With_No_Grouping;                
                return errormsg;          
         }
         if(education.Partner_Grouping__c!=Null){
              lstGroupingAccount = [Select Id,Profiled_Account__c,Partner_Programs__c,Profiled_Account_Flag__c,OwnerId from Account where Grouping__c=:education.Partner_Grouping__c limit 500];
         }
              if(lstGroupingAccount.size()>0){
              for(Account acc :lstGroupingAccount){
              	     lstAccountIds.add(acc.Id);
                  if(acc.Profiled_Account_Flag__c==True){
                     ProfiledAccount=acc;
                     Accountowner= acc.OwnerId;
                  }
                }
              }
            
            if(Accountowner!=Null){
               ActiveAccountOwner=[Select Id,IsActive from User where Id =:Accountowner and isActive=True];
            }
              
                
                if(lstGroupingAccount.size()>0){
                	if(Education.Email__c !=null && Education.Cert_ID__c==null){
                	   lstContact = [Select Id,Cert_Tracker_Contact_ID__c,Email from Contact where 
								   AccountId in :lstAccountIds and  Email=:Education.Email__c];
                	}
                	if(Education.Email__c ==null && Education.Cert_ID__c!=null){
                	   lstContact = [Select Id,Cert_Tracker_Contact_ID__c,Email from Contact where 
								   AccountId in :lstAccountIds and  Cert_Tracker_Contact_ID__c=:Education.Cert_ID__c ];
                	}
                	 
                	if(Education.Email__c !=null && Education.Cert_ID__c!=null){
                	   lstContact = [Select Id,Cert_Tracker_Contact_ID__c,Email from Contact where 
								   AccountId in :lstAccountIds and  (Cert_Tracker_Contact_ID__c=:Education.Cert_ID__c or Email=:Education.Email__c) ];
                	}  	
                 	if(lstContact.size()>0){
                 		System.Debug('lstContact-->' +lstContact[0].Cert_Tracker_Contact_ID__c);
                	 	System.Debug('lstContact-->' +lstContact[0].Id);
                     	errormsg=System.Label.Create_Contact_Error_Message1;                     
                     	return errormsg;                      
                	}
                }
        if(errormsg!=Null){
            result='error';
        }
            
        System.Debug('ListofDuplicateConatcts' +lstContact);
        result='success';
        return result;   
    }       

    public string createContactAndUpdateEducation(){
         newcontact.FirstName = education.First_Name__c;
         newcontact.LastName = education.Last_Name__c;
         newcontact.AccountId = ProfiledAccount.Id;
         newcontact.email = education.Email__c;
         newContact.Cert_Tracker_Contact_ID__c=education.Cert_ID__c;
         newContact.Active__c=True;
         Insert newContact;
         System.debug('InsertedConatct' +newContact);
         Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
         CustomSettingDataValueMap__c EducationOwnerId = DataValueMap.get('EMCAdmin'); 
            
            if(newContact!=Null && education!=null){
                education.Contact__c=newcontact.Id;
                
                        education.OwnerId=EducationOwnerId.DataValue__c;
                
     
               
            } 
            //education.OwnerId=EducationOwnerId.DataValue__c;
            System.debug('++++++++education++++++++'+ education );
            try{
            	
            	Update education;  
            } catch(Exception e){
            	
            }
         
         successmg = System.Label.Contact_Create_Success_Message;         
         return successmg;
         
    }
    
}