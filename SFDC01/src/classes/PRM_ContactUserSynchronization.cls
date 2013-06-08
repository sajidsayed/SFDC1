/*=======================================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER         WR               DESCRIPTION                               

|  ====          =========         ==               =========== 
| 
| 16/09/2010    Anirudh Singh      1061             This Code is added to sync up the
|                                                   Active Flag on User and Partner User
|                                                   Flag on the contact  
| 27/09/2010    Anirudh Singh      Defect#115,125   Updated updateContact and 
|                                                   updatePartnerUserActiveFlag method 
| 5/10/2010     Ashwini Gowda      Defect #125      created methods populatePartnerContactOnUser()
|                                                   and disablingPartnerContactsBatch() to Uncheck 
|                                                   'Partner User' checkbox once partner user is disabled.
| 09/10/2010    Prasad             --               Commented else part in the method
|                                                   updateContact() and disablePartnerUserFlag()

| 26/10/2010    Arif               1436             Created methods 'updateContactLanguage' and 
                                                    'languagesUsed' which is used to update the contact
|                                                   language preference field when language field will 
                                                    updated on User.  
|                                                   Logic is added in 'updatecontact' method to call
                                                    'updateContactLanguage' future method. 
| 12/12/2011  Anirudh Singh        3816             Updated logic in updateContact Method to set 
                                                    Partner Suepr User Flag if the new or Updated Partner User 
|                                                   is a Super User.     

|16/01/2012  Anil Sure            182579            Created method 'populateInactivatedByValueOnContact'
                                                    which is used to populate the context user who 
|                                                    deactivates the contact.    

|04/15/2012	Prasad                                   Added logic to capture the Disabled contact from contact record
|18/05/2012 Anirudh				  192375			 Added Logic to flip record type based on PartnerType=DistiVAR  
|17/08/2012 Ganesh                201028             Created new method  'flipContactRecordTypeToPartner' for updating the 
                                                     'Partner_Contact2__c' and 'RecordTypeId' fields  after deactivating the Workflow Rule 'Update Partner Contact Checkbox'                                                                  
+===========================================================================================*/

public class PRM_ContactUserSynchronization{

/*    
@Method <This method takes the new and old user Map, creates a Boolean and
contact Id's List which needs to be updated and pass the same list to the
Future Call method updatePartnerUserActiveFlag>.
@param <Map of Old User Records and Map of New User Records>
@return <void> - <Not Returning anything>
@throws exception - <No Exception>
*/

    public void updateContact(Map <Id,User>NewUserMap,Map<Id,User>OldUserMap){
        List<Id>  ContactList = new List<Id>();
        List<Id>  UserList = new List<Id>();
        List <Boolean> PartnerUserActiveFlag = new List <Boolean>();
        List <Boolean> SuperUserActiveFlag = new List <Boolean>();
        Set<Id> NewUserId = NewUserMap.keySet();
        Map<Id,String> mapOfUserLanguage = new Map<Id,String>();
        
        System.debug('NewUserMap '+NewUserMap);
        System.debug('OldUserMap '+OldUserMap);
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getall();
        String superUserProfiles = DataValueMap.get('Super User').DataValue__c + DataValueMap.get('Super User1').DataValue__c;
               
        //This case is executed in case of User Active Flag is Updated
        if (OldUserMap!=null){
            for (Id newUserIdtoUpdate:newUserId){
                 User NewUser = NewUserMap.get(NewUserIdtoUpdate);
                 User OldUser = OldUserMap.get(NewUserIdtoUpdate);
                 if (NewUser.ProfileId !=OldUser.ProfileId ) {
                     PartnerUserActiveFlag.add(NewUser.Isactive);
                     ContactList.add(NewUser.ContactId);
                     if(superUserProfiles.contains(NewUser.ProfileId)){
                        SuperUserActiveFlag.add(NewUser.Isactive);
                     }
                     if(!superUserProfiles.contains(NewUser.ProfileId)){
                            SuperUserActiveFlag.add(!NewUser.Isactive);
                     }
                 }        
                  If( NewUser.IsActive  != OldUser.IsActive ||  NewUser.ISPORTALENABLED != OldUser.ISPORTALENABLED){
                         
                        if(NewUser.IsActive==false || NewUser.IsPortalEnabled==false ){
                           PartnerUserActiveFlag.add(false); 
                           SuperUserActiveFlag.add(false); 
                        }else{
                            PartnerUserActiveFlag.add(true); 
                            SuperUserActiveFlag.add(true); 
                        } 
                         ContactList.add(OldUser.ContactId); // changed to old user as it will have contact id always -- prasad
                         
                 }
                 // added by Arif for sinking any updates from user to contact(update)- WR 1436
                 if(NewUserMap.get(newUserIdtoUpdate).LanguageLocaleKey!= OldUserMap.get(newUserIdtoUpdate).LanguageLocaleKey){
                     mapOfUserLanguage.put(NewUserMap.get(newUserIdtoUpdate).ContactId,
                                           NewUserMap.get(newUserIdtoUpdate).LanguageLocaleKey); 
                }   
             }
             if(mapOfUserLanguage.size()>0){
                 updateContactLanguage(mapOfUserLanguage);
             }    
           //till this part  
         }else {// This case will be executed in case of a New Partner User
                //is created on Partner Contact - Enable Partner User on contact
                 for (Id NewUserIdtoUpdate:NewUserMap.keySet()){
                      User NewUser = NewUserMap.get(NewUserIdtoUpdate);    
                      if(NewUser.contactId!=null){
                         PartnerUserActiveFlag.add(NewUser.Isactive);
                         ContactList.add(NewUser.ContactId);
                         if(superUserProfiles.contains(NewUser.ProfileId)){
                            SuperUserActiveFlag.add(NewUser.Isactive);
                         }
                         if(!superUserProfiles.contains(NewUser.ProfileId)){
                            SuperUserActiveFlag.add(!NewUser.Isactive);
                         }
                         // added by Arif for sinking any updates from user to contact(insert)- WR 1436
                         mapOfUserLanguage.put(NewUser.ContactId,NewUser.LanguageLocaleKey);
                      }                    
                 }
                 if(mapOfUserLanguage.size()>0){
                     updateContactLanguage(mapOfUserLanguage);
                 }  
         //till this part          
        }
        if(PartnerUserActiveFlag.size()>0){
            updatePartnerUserActiveFlag(SuperUserActiveFlag,PartnerUserActiveFlag,ContactList);
        }
               
         
        /*else{//This case will be executed when Partner User is disabled from the
             //Contact Record Itself.
            UserList.clear();
            ContactList.clear();
            for(User user:NewUserMap.values()){
                if(user.contactId!=null){
                    UserList.add(user.Id);
                    ContactList.add(user.contactId);
                }
            }
            disablePartnerUserFlag(UserList,ContactList);
        }*/
    }

/* 
@Method <This method is used to sync up the Partner User Flag on contact with 
Active Flag on the User.This method is a future call method which will 
be called asynchronously>
@param <These are two Lists 1.)partnerUserActiveFlag which contains Value of
Active Flag on User 2.)contactList which contains Id's of contacts to be
updated>
@return <void> - <Not Returning anything>
@throws exception - <No Exception>
*/

    @future
    public static void updatePartnerUserActiveFlag(List<Boolean>PartnerSuperUserFlag,List<Boolean>PartnerUserActiveFlag,List<Id>ContactList){
        integer IntIndex=0;
        // This map stores the contact records to be updated
        System.debug('PartnerUserActiveFlag '+PartnerUserActiveFlag);
        System.debug('ContactList '+ContactList);
        Map<Id,Contact> UpdateContactMap= new Map<Id,Contact>([Select Id,Partner_User2__c,Inactive_Reason__c from contact
         where Id in :ContactList]);
                 
        for(Id ContactId :ContactList){
            Contact con=UpdateContactMap.get(ContactId);     
            con.Partner_User2__c=partnerUserActiveFlag[intIndex];
            con.Partner_Super_User__c = PartnerSuperUserFlag[intIndex];
            IntIndex++;
        }    
        update UpdateContactMap.values();
    }
    
    
    
    
/* 
@Method <This method is used to sync up the Partner User Flag on contact with 
Active Flag on the User when user is deactivated from Contact Record.
This method is a future call method which will be called asynchronously>
@param <These are two Lists 1.)UserIds which contains Value of Id of updated users.
2.)ContactIds which contains Id's of contacts to be updated.>
@return <void> - <Not Returning anything>
@throws exception - <No Exception>
*/    
/*    @future
    public static void disablePartnerUserFlag(List<Id>UserIds,List<Id>contactIds){
        // This List contains Id of contacts to be updated.
        List<ID> ContactsToUpdate = new List<ID>();
        // This List contains user records which has been disabled.
        List<User> Users = [select id,name,isactive,UserName,contactId from user where id in :UserIds and contactId=null ];
        // This Loop is created until User record is fetched as its taking time to update.
        if(Users.size()==0){
            for(integer QueryMore=0;QueryMore<98;QueryMore++){
                 System.debug('Attempt  '+QueryMore);
                 Users = [select id,name,isactive,UserName,contactId from user where id in :UserIds and contactId=null ];
                 if(Users.size()!=0){
                    break;
                 }
                 
            }       
        }
        // This loop will add contact Ids to be updated in ContactsToUpdate List.
        for(User user: Users){
                System.debug('USer--'+user.name);
                System.Debug('USerName--' + user.UserName);
                System.debug('USer active--'+user.isactive);
                System.debug('USer contactId--'+user.contactId);
                boolean found=false;            
                integer IntIndex=0;        
                for(Id userid:UserIds){
                    if(userid==user.id){
                        found=true;
                        break;                          
                    }
                    IntIndex++;
                }
                if(found){
                    ContactsToUpdate.add(contactIds[IntIndex]);
                }
        }
        System.debug('ContactsToUpdate '+ContactsToUpdate);
        // This code is updating the contact records whose Ids are fetched above.
        if(ContactsToUpdate.size()>0){
             List<Contact> UpdateContacts= [Select Id,Partner_User2__c,Inactive_Reason__c 
                                                from contact
                                                where Id in :ContactsToUpdate];
                 
            for(Contact con :UpdateContacts){
                con.Partner_User2__c=false;
            }    
            update UpdateContacts;
        }
    }
   */ 
   
    /* @Method <populatePartnerContactOnUser(): Method used to Populate the Contact
                                              associated to Partner User in custom field>.                                                  
   @param <PartnerUsers>
   <PartnerUsers -- Contains List Of Active Partner Users>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
   Method called in beforeInsertOnUser Trigger
*/
    public void populatePartnerContactOnUser(List<User> PartnerUsers){
        for(User PartnerUser: PartnerUsers){
            if(PartnerUser.ContactId!=null){
                PartnerUser.Partner_Contact__c = PartnerUser.ContactId;
            }
        }
    }
    
    /* @Method <disablingPartnerContactsBatch(): Method used to Uncheck 'Partner User'
                                                checkbox once partner user is disabled>.                                                    
   @param <>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
   Method called in PRM_AccountAssociationBatch Class
*/
    public void disablingPartnerContactsBatch(){
        //Query Inactive Partner Users where ContactId is null and Partner_Contact__c!=null
        List<User> InactivePartnerUsers = [Select u.ContactId, u.Partner_Contact__c 
                                           from User u  
                                           where u.ContactId=null and u.Partner_Contact__c!=null];
        List<String> ContactIds = new List<String>();
        //Add the Contact Ids to a List
        for(User inactiveUser: InactivePartnerUsers){
            ContactIds.add(inactiveUser.Partner_Contact__c);
        }
        //Query on Contact to fetch records where Partner User Flag is not disabled
        // and Partner Contact is disabled.
        List<Contact> DisabledPartnerContacts = [Select c.Partner_User2__c,c.Id,c.Partner_Super_User__c
                                                 from Contact c  
                                                 where c.Partner_User2__c=true and c.Id in:ContactIds];
        //If any records returned where Partner User Flag is not diabled, loop through 
        //to disable the Partner User Flag.
        if(DisabledPartnerContacts.size()>0){
            for(Contact partnerContact: DisabledPartnerContacts){
                partnerContact.Partner_User2__c = false;
                partnerContact.Partner_Super_User__c = false;
            }
            update DisabledPartnerContacts;
        }
        
    }
//WR 1436    
/* @Method <languagesUsed(): Method used to create a map of languages>.                                                  
   @param <no parameter>
   <languageMap -- Contains map of Languages used>
   @return <languageMap> - <Map of languages>
   @throws exception - <No Exception>
   Method called in updateContactLanguage method
*/
    public static Map<String,String> languagesUsed(){
        Map<String,String> languageMap = new Map<String,String>(); 
        languageMap.put('bg','Bulgarian');
        languageMap.put('zh_CN','Chinese(Simplified)');
        languageMap.put('zh_TW','Chinese(Traditional)');
        languageMap.put('cs','Czech');
        languageMap.put('da','Danish');
        languageMap.put('nl_NL','Dutch');
        languageMap.put('en_US','English');
        languageMap.put('fi','Finnish');
        languageMap.put('fr','French');
        languageMap.put('de','German');
        languageMap.put('el','Greek');
        languageMap.put('hu','Hungarian');
        languageMap.put('in','Indonesian');
        languageMap.put('it','Italian');
        languageMap.put('ja','Japanese');
        languageMap.put('ko','Korean');
        languageMap.put('pl','Polish');
        languageMap.put('pt_BR','Portuguese(Brazilian)');
        languageMap.put('ro','Romanian');
        languageMap.put('ru','Russian');
        languageMap.put('es','Spanish');
        languageMap.put('es_MX','Spanish(Mexican)');
        languageMap.put('sv','Swedish');
        languageMap.put('th','Thai');
        languageMap.put('tr','Turkish');
        languageMap.put('uk','Ukrainian');
        languageMap.put('vi','Vietnamese');
        return languageMap;
    }
//WR 1436 
/* @Method <updateContactLanguage(): Method used to sink language update from 
            user to contact>.                                                  
   @param <mapOfUserLanguage : Map of Contact id and updated language>
   <mapOfLanguages -- map of Languages used to keep the value of returned map 
    languageMap>
   <lstContactLanguage  -- list of all the contacts whose language field will get 
   updated>
   @return <void> - <Not returning any thing>
   @throws exception - <No Exception>
   Method called in updateContact method
*/
   @future
    public static void updateContactLanguage(Map<Id,String> mapOfUserLanguage){
        Map<String,String> mapOfLanguages = new Map<String,String>();
        mapOfLanguages = languagesUsed();
        List<Contact> lstContactLanguage = new List<Contact>();
        if(mapOfUserLanguage.size()>0){
            for(Contact contact:[Select Id,Language_Preference__c from Contact 
                                where Id in:mapOfUserLanguage.keyset()]){
                contact.Language_Preference__c = mapOfLanguages.get(mapOfUserLanguage.get(contact.Id));
                lstContactLanguage.add(contact); 
                }    
            Update lstContactLanguage;
        }    
    }      
/* @Method <populateInactivatedByValueOnContact(): Method is used to populate the name of 
            context user who inactivates the contact>.                                                  
   @param <List<Contact> lstContact,Boolean activestatus>
   <lstContact-- Contains list of contacts to be updated>
   <activestatus-- Contact status value>   
   @throws exception - <No Exception>
   Method is getting invoked from ContactBeforeUpdate trigger
*/      
      public void populateInactivatedByValueOnContact(List<Contact> lstContact,Boolean activeStatus){        
         
                for(Contact con:lstContact){
                    if(!activeStatus){
                       con.Inactivated_By__c= UserInfo.getName(); 
                    }
                    else {
                        con.Inactivated_By__c='';
                        con.Inactive_Reason__c=null;
                    }
                }               
      }

 /* @Method <flipContactRecordTypetopartner(): Method is used to update the Record type 
			based on the Partner Type on the Related Account> 
            @param <List<Contact> lstContact>
   <lstContact-- Contains list of contacts to be updated>
   @throws exception - <No Exception>
   Method is getting invoked from ContactBeforeUpdate  Trigger
 */
    //Added by Ganesh, after deactivating the workflow rule 'Update Record to Partner Contact'
     public void flipContactRecordTypeToPartner(Map<Id,Id> mapPartnerAccountWithContact,Map<ID,Contact> mapContactDetails)
     {     	
        Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall();          
        CustomSettingDataValueMap__c DistiVarContactRecordType = (mapCustomSettingDataValueMap.get('Distribution VAR Contact Record Type'));
     	Map<Id,Account> lstAcc = new  Map<Id,Account> ([Select id,IsPartner from Account where id in:mapPartnerAccountWithContact.values()]);     
     	for(Id conId:mapPartnerAccountWithContact.keySet())
     	{     		
     	   Contact con = mapContactDetails.get(conId);
     	   System.debug('SFDCDEV********con******'+con);
     	   Account acc =  lstAcc.get(mapPartnerAccountWithContact.get(conId));     
     	   System.debug('SFDCDEV********acc******'+acc);	
     	   if(con!=null && acc!=null){   
	            System.debug('SFDCDEV****'+acc.IsPartner+'*********'+con.Partner_SE__c+'*****'+con.RecordTypeId+'********DistiVarContactRecordType*******'+DistiVarContactRecordType);
	            if(acc.IsPartner == true && con.Partner_SE__c==false && con.RecordTypeId!=DistiVarContactRecordType.DataValue__c)
				{				
				   con.Partner_Contact2__c=true;			
				   CustomSettingDataValueMap__c PartnerContactRecordType = (mapCustomSettingDataValueMap.get('Partner Contact Record Type'));
				   con.RecordTypeId= PartnerContactRecordType.DataValue__c;			  
				}
     	   }
     	}
     }
      

/* @Method <flipContactRecordTypetoDistiVar(): Method is used to update the Record type 
			based on the Partner Type on the Related Account> 
            @param <List<Contact> lstContact>
   <lstContact-- Contains list of contacts to be updated>
   @throws exception - <No Exception>
   Method is getting invoked from ContactBeforeUpdate and ContactBeforeInsert Trigger
 */
      public void flipContactRecordTypetoDistiVar(List<Contact> lstContact)
      {	      
	  Map<Id,Account> mapDistributionVarAccount = new map<Id, Account>();
	  Map<Id,Account> mapNonDistributionVarAccount = new map<Id, Account>();
	  Map<Id,Account> mapStandardAccount = new map<Id, Account>();
	  Map<Id,List<Contact>> mapAccountWithContact = new Map<Id,List<Contact>>();
	  Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall(); 
      CustomSettingDataValueMap__c ContctRecordType = (mapCustomSettingDataValueMap.get('Distribution VAR Contact Record Type'));
      	for(Contact conObj :lstContact){
			List<Contact> listContact = mapAccountWithContact.get(conObj.AccountId);
			if(listContact==null){
				listContact = new list<Contact>();
			}
			listContact.add(conObj);
			mapAccountWithContact.put(conObj.AccountId,listContact);
		}
		
		if(mapAccountWithContact.size()>0){
			List<Account> varAccounts = new list<Account>();
			varAccounts = [Select Id,Partner_Type__c, isPArtner from Account where id in:mapAccountWithContact.keyset()];
			System.debug('@@@@@@@@@@@@@@ varAccounts.size()'+ varAccounts.size());
			if(varAccounts.size() > 0){
	            for(Account eachAccount :varAccounts){
	            	System.debug('************** eachAccount.Partner_Type__c'+ eachAccount.Partner_Type__c);
	            	if(eachAccount.Partner_Type__c != null){
	                    if(eachAccount.Partner_Type__c.contains('Distribution VAR') && eachAccount.isPArtner == true){
	                        mapDistributionVarAccount.put(eachAccount.Id, eachAccount);
	                    }
	                    if(!eachAccount.Partner_Type__c.contains('Distribution VAR') && eachAccount.isPArtner== true){
	                        mapNonDistributionVarAccount.put(eachAccount.Id, eachAccount);
	                    }
	            	}
	                if(eachAccount.isPArtner == false){
	                    mapStandardAccount.put(eachAccount.Id, eachAccount);
	                }
	            }
				
			}
		}
		/*if(mapAccountWithContact.size()>0){
			mapDistributionVarAccount = new map<Id,Account>([Select Id,Partner_Type__c from Account where id in:mapAccountWithContact.keyset() and Partner_Type__c includes ('Distribution VAR') and isPArtner=True]);
		}
		if(mapAccountWithContact.size()>0){
			mapNonDistributionVarAccount = new map<Id,Account>([Select Id,Partner_Type__c from Account  where id in:mapAccountWithContact.keyset() and Partner_Type__c excludes ('Distribution VAR') and isPArtner=True]);
		}
		if(mapAccountWithContact.size()>0){
			mapStandardAccount = new map<Id,Account>([Select Id,Partner_Type__c from Account  where id in:mapAccountWithContact.keyset() and isPArtner=false]);
		}*/
		for(Id AccountId :mapAccountWithContact.keyset()){
			if(mapDistributionVarAccount.containskey(AccountId)){
				for(contact conObjToUpdate :mapAccountWithContact.get(AccountId)){
					if(conObjToUpdate.RecordTypeId!=ContctRecordType.DataValue__c && !(conObjToUpdate.Partner_SE__c || conObjToUpdate.Inside_Partner_SE__c)){
						conObjToUpdate.RecordTypeId=ContctRecordType.DataValue__c;
						conObjToUpdate.Partner_Contact2__c=true;
					}
					if((conObjToUpdate.Partner_SE__c || conObjToUpdate.Inside_Partner_SE__c) && conObjToUpdate.recordTypeId !=mapCustomSettingDataValueMap.get('Partner SE VAR Record Type').DataValue__c)
					{
						conObjToUpdate.RecordTypeId=mapCustomSettingDataValueMap.get('Partner SE VAR Record Type').DataValue__c;
						conObjToUpdate.Partner_Contact2__c=true;
					}	
				}
			}
		}
		for(Id AccountId :mapAccountWithContact.keyset()){
			if(mapNonDistributionVarAccount.containskey(AccountId)){
				for(contact conObjToUpdate :mapAccountWithContact.get(AccountId)){
					if(conObjToUpdate.recordTypeId !=mapCustomSettingDataValueMap.get('Partner Contact Record Type').DataValue__c && !(conObjToUpdate.Partner_SE__c || conObjToUpdate.Inside_Partner_SE__c)){
						conObjToUpdate.RecordTypeId=mapCustomSettingDataValueMap.get('Partner Contact Record Type').DataValue__c;
						conObjToUpdate.Partner_Contact2__c=true;
					}
					if(conObjToUpdate.recordTypeId !=mapCustomSettingDataValueMap.get('Partner SE Disti/Dir Resell Rec Type').DataValue__c && (conObjToUpdate.Partner_SE__c || conObjToUpdate.Inside_Partner_SE__c)){
						conObjToUpdate.RecordTypeId=mapCustomSettingDataValueMap.get('Partner SE Disti/Dir Resell Rec Type').DataValue__c;
						conObjToUpdate.Partner_Contact2__c=true;
					}
				}
			}
		}
		for(Id AccountId :mapAccountWithContact.keyset()){
			if(mapStandardAccount.containskey(AccountId)){
				for(contact conObjToUpdate :mapAccountWithContact.get(AccountId)){
					if(conObjToUpdate.RecordTypeId != mapCustomSettingDataValueMap.get('Standard Contact Record Type').DataValue__c)
						conObjToUpdate.RecordTypeId=mapCustomSettingDataValueMap.get('Standard Contact Record Type').DataValue__c;
						conObjToUpdate.Partner_Contact2__c=false;
				}
			}
		}
      }
 /* @Method <flipContactRecordTypetoDistiVarOnUpdateofAccount(): Method is used to update the Record type 
			 of Contact based on the Partner Type on the Related Account> 
            @param <List<Account> lstAccount>
   <lstAccount-- Contains list of accounts whose contacts are to be updated>
   @throws exception - <No Exception>
   Method is  getting invoked from AfterUpdateOfAccountGrouping Trigger
 */   @future	
      public static void flipContactRecordTypetoDistiVarOnUpdateofAccount(set<Id> PartnerAccountUpdated)
      {	      	
		Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall(); 
		List<Contact> lstContactRelatedToAccount = new list<Contact>();
		List<Contact> lstContactToUpdate = new list<Contact>();
		lstContactRelatedToAccount = [Select Id,name,RecordTypeId,Partner_SE__c,Account.Partner_Type__c,Inside_Partner_SE__c,Active__c from contact
							          where Accountid in:PartnerAccountUpdated or Account.Profiled_Account__c in :PartnerAccountUpdated];
							  	
						  	
	    for(contact conObj :lstContactRelatedToAccount){
			if((conObj.Partner_SE__c || conObj.Inside_Partner_SE__c) && conObj.Account.Partner_Type__c.contains('Distribution VAR') && 
				conObj.RecordTypeId !=mapCustomSettingDataValueMap.get('Partner SE VAR Record Type').DataValue__c){
				conObj.RecordTypeId =mapCustomSettingDataValueMap.get('Partner SE VAR Record Type').DataValue__c;
			}
			if((conObj.Partner_SE__c || conObj.Inside_Partner_SE__c) && !conObj.Account.Partner_Type__c.contains('Distribution VAR') && 
				conObj.RecordTypeId !=mapCustomSettingDataValueMap.get('Partner SE Disti/Dir Resell Rec Type').DataValue__c){
				conObj.RecordTypeId =mapCustomSettingDataValueMap.get('Partner SE Disti/Dir Resell Rec Type').DataValue__c;
			}
			if(!(conObj.Partner_SE__c || conObj.Inside_Partner_SE__c) && conObj.Account.Partner_Type__c.contains('Distribution VAR') && 
				conObj.RecordTypeId !=mapCustomSettingDataValueMap.get('Distribution VAR Contact Record Type').DataValue__c){
				conObj.RecordTypeId =mapCustomSettingDataValueMap.get('Distribution VAR Contact Record Type').DataValue__c;
			}
			if(!(conObj.Partner_SE__c || conObj.Inside_Partner_SE__c) && !conObj.Account.Partner_Type__c.contains('Distribution VAR') && 
				conObj.RecordTypeId !=mapCustomSettingDataValueMap.get('Partner Contact Record Type').DataValue__c){
				conObj.RecordTypeId =mapCustomSettingDataValueMap.get('Partner Contact Record Type').DataValue__c;
			}
			lstContactToUpdate.add(conObj);
		}
		System.Debug('lstContactToUpdate');
		Database.update(lstContactToUpdate,false);
		
							  
      }
   
 }