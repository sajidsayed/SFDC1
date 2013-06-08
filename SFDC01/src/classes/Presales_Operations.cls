/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  11/09/2011     Shalabh Sharma           This class is used for populating fields on case object.     
 |  13/12/2011     Shalabh Sharma           Changed SuppliedEmail field value to lower case. 
 |  20/12/2011     Leonard Victor   4820    Changed presalesOperationsSetRoleName method to take value from custom setting
 |  21/12/2011     Shalabh Sharma   4818    Updated presalesOperationsOnInsert method to populate country from webform. 
 |  29/12/2011     Shalabh Sharma   4431    Update the code to populate synergy account number on case record.
 |  17/01/2012     Shalabh Sharma           Updated the code to handle Non selective query error
 |  06/02/2012     Shalabh Sharma           Added an else condition in checkIFRequestorUserOrContact method.
 |  02/15/2012     Leonard Victor   4686    De-dup emails sent to resources from a case.
 |  02/16/2012     Kaustav Debnath          Added a null validation in map for synergyaccount in updateSynergyAccountNumber method
 |                                          to prevent script exception
 |  28/02/2012     Leonard Victor           Added dynamic apex and dynamic SOQL to take out all the email related 
                                            fields from contact 
 |  05/15/2012     Srinivas Pinnamaneni     WR192193:Modifed code to validate case types
 |  06/21/2012     Shalabh Sharma           Updated code to incorporate active/inactive contacts logic
 |  07/05/2012     Leonard Victor           Updated code to incorporate partner account check box logic
 |  08/01/2012     Shalabh Sharma           Added a static flag in method presalesOperationsSetRoleName()
 |  09/03/2012     Srinivas Pinnamaneni     WR185920:Add Contact Mobile field to populate TC mobile information.
 |  11/22/2012     Ganesh Soma		        WR212488:Modified Code to close resolved parent cases when child cases closes.
 |  12/19/2012     Srinivas Pinnamaneni     WR215208: Add Opportunity Competitor and competitor product values in case object competotir and competotor products.
 |  01/01/2013     Srinivas Pinnamaneni     WR220748: Multiple Opportunities associated with one POC case.
 |  01/30/2013     Srinivas Pinnamaneni     WR185805: Make Contact Manger field as editable and autopoulate if user haven't enter in it.
 |  14March2013    Ganesh Soma         WR#247113    SOQL Optimization:Restricting unnecessary query execution
 +==================================================================================================================**/

public class Presales_Operations{
public static Boolean isError = false;
public static Boolean isCaseUpdate = false;
public static Boolean isCaseTeamDelete = false;
public static Boolean isOpportunityPopulated = true;
public static Boolean isSetRoleName = true;

/* @Method <This method execute is used to populate user or contact fields on case record on insert>
@param <This method takes List<Case> as parameter>
@return void - <Not returning anything>
@throws exception - <No Exception>
*/  
    public void presalesOperationsOnInsert(List<Case> lstCase){
        system.debug('lstCase--->'+lstCase);
        Map<String,List<Case>> mapEmailCase = new Map<String,List<Case>>();
        Map<Id,Case> mapContactIdCase = new Map<Id,Case>();
        for(Case caseRecord:lstCase){
        /*Checking if Contact Email is populated*/
            if(caseRecord.Contact_Email1__c !=null){
                
                if(mapEmailCase.containsKey(caseRecord.Contact_Email1__c)){
                    (mapEmailCase.get(caseRecord.Contact_Email1__c)).add(caseRecord);
                }
                else{
                        List<Case> lstOFCase = new List<Case>();
                        lstOfCase.add(caseRecord);
                        mapEmailCase.put(caseRecord.Contact_Email1__c,lstOfCase);
                    }
               }
            else {
                
                    if(caseRecord.SuppliedEmail != null){
                        List<Case> lstOFCase = new List<Case>();
                        lstOfCase.add(caseRecord);
                            mapEmailCase.put(caseRecord.SuppliedEmail.toLowerCase(),lstOfCase);
                    }
            }
            /*Checking if Contact is populated*/
            if(caseRecord.ContactId!=null){
                mapContactIdCase.put(caseRecord.ContactId,caseRecord);
                system.debug('mapContactIdCase--->'+mapContactIdCase);
            }   
        }
        system.debug('mapEmailCase--->'+mapEmailCase); 
        /*Checking if contact exists*/ 
      //  Map<Id,Contact> mapIdContact = new Map<Id,Contact>([select Id,BU__c,Email,Asst_Email__c,Phone,Country_Local__c, AccountId,Account.Theater1__c from Contact where (Email in :mapEmailCase.keyset() and Email!=null)or Id in : mapContactIdCase.keyset()]);                           
             Set<String> lstEmail = mapEmailCase.keyset();
             Set<Id> lstContactId = mapContactIdCase.keyset();
             Map<Id,Contact> mapIdContact = new Map<Id,Contact>();
            String contactQry = 'select Id,BU__c,Phone,Country_Local__c,AccountId,Account.Theater1__c,Active__c';
            
        // Taking fields with email type
                    Schema.DescribeSObjectResult dsor = Contact.getSObjectType().getDescribe();

                    System.debug('dsor'+dsor);


                     Map<String,Schema.DisplayType> finalMap = new Map<String, Schema.DisplayType>();

                       Map<String, Schema.SObjectField> objectFields = dsor.fields.getMap();



                         for(String field : objectFields.keyset()){

                             Schema.DisplayType fieldType = objectFields.get(field).getDescribe().getType();


                            if (Schema.DisplayType.EMAIL == fieldType)
                        {
                                finalMap.put(field, fieldType); 

                        }
                             
                    }


                      System.debug('finalMap' +finalMap);

                      List<String> lstfld = new   List<String>();

                    /*
                    for(string dd : finalMap.keyset()){

                        if (Schema.DisplayType.EMAIL == finalMap.get(dd))
                        {
                            System.debug('In=----------------------' +dd);
                            lstfld.add(dd);
                        }

                    }*/

                    

                    Integer x = finalMap.keyset().size();

                    for(String s :finalMap.keyset()){

                     contactQry = contactQry+','+s;

                     x--;

                     if(x ==0)
                        {
                            contactQry = contactQry + ' from Contact where ((Email in :lstEmail and Email!=null) or Id in:lstContactId)';

                            
                        }

                    }


                    System.debug('QUERY' +contactQry);

                    List<Contact> cntLst = Database.query(contactQry);

                    for(Contact cnt : cntLst){

                        mapIdContact.put(cnt.id , cnt);

                    }




    //End of taking email field type
        Map<Id,Contact> mapActiveContacts = new Map<Id,Contact>();
        Map<Id,Contact> mapInActiveContacts = new Map<Id,Contact>();
        Map<Id,Contact> mapContactsToBeUsed = new Map<Id,Contact>();
        For(Contact con: mapIdContact.values()){
            if(con.Active__c == true){
                mapActiveContacts.put(con.Id,con);  
            }
            else{
                mapInActiveContacts.put(con.Id,con);
            }
        }
        system.debug('mapActiveContacts--->'+mapActiveContacts);
        system.debug('mapInActiveContacts--->'+mapInActiveContacts);
        if(mapActiveContacts.size()==0){
            mapContactsToBeUsed = mapInActiveContacts.clone();
        }
        else{
            mapContactsToBeUsed = mapActiveContacts.clone();
        }
        system.debug('mapContactsToBeUsed--->'+mapContactsToBeUsed);
        Map<Id,String> mapContactEmail = new Map<ID,String>();
        Map<String,Contact> mapEmailContact = new Map<String,Contact>();
        if(mapContactsToBeUsed.size()>0){
            for(Contact con: mapContactsToBeUsed.values()){
                mapContactEmail.put(con.Id,con.Email);
                system.debug('mapContactEmail--->'+mapContactEmail);
            
                //Iterating email type fields from emailFieldLst
                
                for(String field : finalMap.keyset()){
                        if(con.get(field)!= null)
                mapEmailContact.put(String.valueof(con.get(field)),con);
                }
            // End of email type iteration
        
           }
        }

          System.debug('mapEmailContact#$#$#$#$#' +mapEmailContact);
        for(Id contactId:mapContactEmail.keyset()){
            if(mapContactIdCase.get(contactId)!=null){
                if(mapEmailCase.containskey(mapContactEmail.get(contactId))){
                    (mapEmailCase.get(mapContactEmail.get(contactId))).add(mapContactIdCase.get(contactId));    
                }
                else{
                    List<Case> lstOfCase = new List<Case>();
                    mapEmailCase.put(mapContactEmail.get(contactId),lstOfCase);
                    system.debug('map email1 case--->'+mapEmailCase);
                    mapEmailCase.get(mapContactEmail.get(contactId)).add(mapContactIdCase.get(contactId));
                    system.debug('map email1 case--->'+mapEmailCase);
                }
            }   
        }
        system.debug('map email2 case--->'+mapEmailCase);
        /*Checking if user exists with same email*/
        //WR185920:Add user Mobile field to populate TC mobile information.
        //Add MobilePhone column  in the query
        string strMobileNumber = null;
	//WR185805: Add Manger field in the following query.
        Map<Id,User> mapIdUser = new Map<Id,User>([select Manager__c,MobilePhone,BU__c,PreSales_Case_Close_AutoReply__c,PreSales_Case_Pending_Engg__c,Division__c,Email,PreSales_Case_Resolved__c,PreSales_Case_Escalated__c,PreSales_Case_Created__c,PreSales_Case_Assigned__c,PreSales_Case_Closed__c,Theater__c,Country__c,District__c,Area__c,CompanyName,Phone from user where (Email in:mapEmailCase.keyset() or Email in: mapContactEmail.values()) and isActive=true AND UserType != 'PowerPartner' limit 1]);
         System.debug('SFDCDEV********mapIdUser********'+mapIdUser);
        Map<String,User> mapEmailUser = new Map<String,User>();
        if(mapIdUser.size()>0){
            for(User usr:mapIdUser.values()){
               system.debug('usr.MobilePhone =='+usr.MobilePhone);
                if(usr.MobilePhone != null)
                	strMobileNumber = usr.MobilePhone;
                system.debug('ustrMobileNumber =='+strMobileNumber);
                if(mapEmailUser.size() <= 0)
                	mapEmailUser.put(usr.Email,usr);        
            }
        }
        system.debug('map email user--->'+mapEmailUser);
         system.debug('map email case--->'+mapEmailCase);
          /*Populating case fields if user exists*/
          
        if(mapEmailUser.size()>0 && mapEmailUser != null && mapEmailCase.size()>0 && mapEmailCase != null){
        	System.debug('SFDCDEV********** if');
            System.debug('Inside User--->');
            for(String s :mapEmailCase.keyset()){
                for(Case caseRecord:mapEmailCase.get(s)){
                try{       	
                	
                    //Ganesh: Contact requestor fields - start
                	if(caseRecord.Division__c == null)
                    caseRecord.Division__c=mapEmailUser.get(s).Division__c;  
                    if(caseRecord.Country__c == null)    
                    {            
	                    if(mapEmailUser.get(s).Country__c!=null && mapEmailUser.get(s).Country__c!='N/A'){
	                        caseRecord.Country__c = mapEmailUser.get(s).Country__c;
	                    }
	                    else if(caseRecord.Country_Hidden__c!=null){
	                        caseRecord.Country__c = caseRecord.Country_Hidden__c;   
	                    }
                    }                    
                    if(caseRecord.Contactid == null) 
                    {
	                    if(mapEmailContact.size()>0){
	                        caseRecord.Contactid = mapEmailContact.get(s).id;
	                        caseRecord.AccountId = mapEmailContact.get(s).AccountId;
	                    }
                    }
                    if(caseRecord.Contact_Phone1__c == null) 
                    caseRecord.Contact_Phone1__c = mapEmailUser.get(s).Phone;
                    //WR185920:Add user Mobile field to populate TC mobile information.
                    //Check if user enters the mobile number if not populate it with the user inforamtion   
                    if(caseRecord.Contact_Mobile__c == null)                               
                    caseRecord.Contact_Mobile__c =  strMobileNumber; 
                    if(caseRecord.Contact_Email1__c == null) 
                    caseRecord.Contact_Email1__c = mapEmailUser.get(s).Email;
                    if(caseRecord.Area__c == null)
                    caseRecord.Area__c = mapEmailUser.get(s).Area__c;
                    if(caseRecord.District__c == null)
                    caseRecord.District__c = mapEmailUser.get(s).District__c;
                    if(caseRecord.Theatre__c == null)
                    caseRecord.Theatre__c = mapEmailUser.get(s).Theater__c;
                    if(caseRecord.Business_Unit__c == null)
                    caseRecord.Business_Unit__c = mapEmailUser.get(s).BU__c;
                    //WR185805: Auto Populate Contact Manager Field
                    if(caseRecord.ContactManager__c == null)
                    caseRecord.ContactManager__c = mapEmailUser.get(s).Manager__c;                        
                    //Ganesh: Contact requestor fields - ends
                    
                    
                    
                    caseRecord.PreSales_Case_Assigned__c = mapEmailUser.get(s).PreSales_Case_Assigned__c;
                    caseRecord.PreSales_Case_Closed__c = mapEmailUser.get(s).PreSales_Case_Closed__c;
                    caseRecord.PreSales_Case_Created__c = mapEmailUser.get(s).PreSales_Case_Created__c;
                    caseRecord.PreSales_Case_Escalated__c = mapEmailUser.get(s).PreSales_Case_Escalated__c;
                    caseRecord.PreSales_Case_Resolved__c = mapEmailUser.get(s).PreSales_Case_Resolved__c;
                    caseRecord.PreSales_Case_Pending_Engg__c = mapEmailUser.get(s).PreSales_Case_Pending_Engg__c;
                    caseRecord.PreSales_Case_Close_AutoReply__c = mapEmailUser.get(s).PreSales_Case_Close_AutoReply__c;
                    //caseLoop.Is_contact__c = false;
                    caseRecord.Contact_Name_User__c = mapEmailUser.get(s).Id;
		                
                    //caseRecord.Is_not_User_Contact__c = true;
                    caseRecord.Send_Mail_On_Update__c = true;
                    //caseRecord.Validation_check_for_TC__c =true;
                    //caseRecord.setOptions(dmo);
                    system.debug('caseRecord.Send_Mail_On_Update__c--->'+caseRecord.Send_Mail_On_Update__c);
                }
                catch(Exception e){
                    caseRecord.addError('Please clear Contact field and re-save');
                }
                }                 
            }
        }
        /*Populating case fields if contact exists*/
        else if(mapEmailContact!=null && mapEmailContact.size()>0 ){
        	System.debug('SFDCDEV**********else if');
            for(String s :mapEmailCase.keyset()){
            system.debug('mapEmailCase.get(s)--->'+mapEmailCase.get(s));
                for(Case caseRecord:mapEmailCase.get(s)){
              try{
              	   //Ganesh: Contact requestor fields - start
                    if(caseRecord.ContactId == null)
                    {
                    	 caseRecord.ContactId=mapEmailContact.get(s).Id;
                    	 caseRecord.AccountId=mapEmailContact.get(s).AccountId;
                    }                  
                    
                    if(caseRecord.Contact_Email1__c == null)
                    caseRecord.Contact_Email1__c=mapEmailContact.get(s).Email;
                    if(caseRecord.Contact_Phone1__c == null)
                    caseRecord.Contact_Phone1__c=mapEmailContact.get(s).Phone;
                    if(caseRecord.Theatre__c == null)
                    caseRecord.Theatre__c=null;
                    if(caseRecord.Division__c == null)
                    caseRecord.Division__c = null;
                    if(caseRecord.Area__c == null)
                    caseRecord.Area__c = null;
                    if(caseRecord.District__c == null)
                    caseRecord.District__c = null;
                    if(caseRecord.Business_Unit__c == null)
                    caseRecord.Business_Unit__c = mapEmailContact.get(s).BU__c;
                    if(caseRecord.Country__c == null)
                    {
	                    if(caseRecord.Country_Hidden__c!=null){
	                        caseRecord.Country__c = caseRecord.Country_Hidden__c;   
	                    }
                    }
                    
                    //WR185805: Auto Populate Contact Manager Field
                    if(caseRecord.ContactManager__c == null)
                    caseRecord.ContactManager__c = null;
                    //Ganesh: Contact requestor fields - ends
                    
                    
                    //caseRecord.Country__c = null;
                    //caseRecord.Is_not_User_Contact__c = true;
                    caseRecord.Send_Mail_On_Update__c = true;
                    caseRecord.Is_contact__c=true; 
		          
                    //caseRecord.Validation_check_for_TC__c =true;
                    //mapContactIdCase.get(conId).setOptions(dmo);
                    
                }
                catch(Exception e){
                    caseRecord.addError('Please clear Contact field and re-save');
                }
                }
            }   
        }
        
         isError = true;       
        /*AssignmentRule assignRule = new AssignmentRule();
        assignRule=[Select Id from AssignmentRule where SobjectType = 'Case' and Active = true];
        //QueryResult qr = connection.query("SELECT Id FROM AssignmentRule where SobjectType = 'Case'");
            if(assignRule!=null){
                connection.setAssignmentRuleHeader(null,useDefaultRule.TRUE);
            }   */  
        
    }
/* @Method <This method execute is used to populate case owner's name 
@param <This method takes List<Case> as parameter>
@return void - <Not returning anything>
@throws exception - <No Exception>
*/    
        public void populateCaseOwnerName(List<Case> lstCase){
        Map<Id,List<Case>> mapOwnerCase = new Map<Id,List<Case>>();
        String name;
        for(Case caseRecord:lstCase){
             if(mapOwnerCase.containsKey(caseRecord.OwnerId)){
                    (mapOwnerCase.get(caseRecord.OwnerId)).add(caseRecord);
             }
             else{
                    List<Case> lstOFCase = new List<Case>();
                    lstOfCase.add(caseRecord);
                    mapOwnerCase.put(caseRecord.OwnerId,lstOfCase);
             }    
        }
        /*
        // ganesh commneted on 12thmarch2013
        Map<Id,User> mapOwner = new Map<Id,User>([select id,Name from User where id in:mapOwnerCase.keyset() AND UserType != 'PowerPartner']);
        Map<Id,Group> mapQueue = new Map<Id,Group>([select id,Name from Group where id in:mapOwnerCase.keyset()]);
        */
        
        Map<ID,List<Case>> ownerMap = new Map<ID,List<Case>>();
        Map<ID,List<Case>> queueMap = new Map<ID,List<Case>>();
        
         
        /*Checking if owner is a user or queue*/
        for(String s:mapOwnerCase.keyset()){
            if(s.substring(0,3)=='005'){
                ownerMap.put(s,mapOwnerCase.get(s));          
            }
            else if(s.substring(0,3)=='00G'){
                queueMap.put(s,mapOwnerCase.get(s)); 
                //system.debug('lst q'+lstCaseOwnerQueue);
        }
            }   
        if(ownerMap.size()>0){
        	Map<Id,User> mapOwner = new Map<Id,User>([select id,Name from User where id in:mapOwnerCase.keyset() AND UserType != 'PowerPartner']);// ganesh added on 12thmarch 2013
            for(Id ownerId:ownerMap.keyset()){                
                for(Case caseRecord:ownerMap.get(ownerId)){
                    caseRecord.Case_UserName__c = mapOwner.get(ownerId).Name; 
                    name =  mapOwner.get(ownerId).Name; 
                }              
            }
        }
        if(queueMap.size()>0){
        	Map<Id,Group> mapQueue = new Map<Id,Group>([select id,Name from Group where id in:mapOwnerCase.keyset()]);// ganesh added on 12thmarch 2013
            for(Id ownerId:queueMap.keyset()){                
                for(Case caseRecord:queueMap.get(ownerId)){
                    caseRecord.Case_UserName__c = mapQueue.get(ownerId).Name;        
                     name =  mapQueue.get(ownerId).Name;        
                }
            }
        } 
        System.debug('PopoulateCaseOwnerName#$%' + name);
    }
/* @Method <This method execute is used to populate account if opportunity is populated on case record>
@param <This method takes List<Case> as parameter>
@return void - <Not returning anything>
@throws exception - <No Exception>
*/    
    public void updateAccountDetails(List<Case> lstCase){
        if(isOpportunityPopulated){
        //List<Opportunity> lstOpportunity = [select Id,AccountId,]
        List<Case> lstCaseToUpdate = [select ID,Opportunity_Name__r.AccountId,Opportunity_Name__r.Opportunity_Number__c,
        								Opportunity_Name__r.Competitor__c,Opportunity_Name__r.Product_Model__c from case where id in:lstCase];
        system.debug('lst od case--->'+lstCase);
        for(Case caseLoop: lstCaseToUpdate){
            system.debug('oppty details--->'+caseLoop.Opportunity_Name__r.AccountId);
            system.debug('oppty details--->'+caseLoop.Opportunity_Name__c);
            system.debug('oppty details--->'+caseLoop.Opportunity_Name__r.AccountId);
            //185944 Added the branch conditon for not delete the customer details when opp name and opp number are deleted and saved
            if(caseLoop.Opportunity_Name__c != null)
            {
                caseLoop.Customer_Account_Name__c = caseLoop.Opportunity_Name__r.AccountId;
                //WR 185944 Add opportunity Number here if user selects the ooportunity name in case
                caseLoop.Opp_Number__c = caseLoop.Opportunity_Name__r.Opportunity_Number__c;
                //WR215208 Add Opportunity Competitor and competitor product values in case object competotir and competotor products
                caseLoop.Competitor__c = caseLoop.Opportunity_Name__r.Competitor__c;
                caseLoop.Competitor_Products_New__c = caseLoop.Opportunity_Name__r.Product_Model__c;
                
            }
        }
        update lstCaseToUpdate;
        }
        isOpportunityPopulated = false;
    }
/* @Method <This method execute is used to populate synergy account number of the selected account on case record>
@param <This method takes List<Case> as parameter>
@return void - <Not returning anything>
@throws exception - <No Exception>
*/    
    public void updateSynergyAccountNumber(List<Case> lstCase){
         
        List<String> lstCaseToUpdate = new List<String>();
        Map<Id,Presales_Account__c> mapPresalesAccount = new Map<Id,Presales_Account__c>();
        Map<String,Presales_Account__c> mapPresalesAccountToUpdate = new Map<String,Presales_Account__c>();
        Map<Id,Case> mapCase =  new Map<Id,Case>();
        if(isCaseUpdate==false){
            mapCase =  new Map<Id,Case>([select ID,Customer_Account_Name__c,Customer_Account_Name__r.Synergy_Account_Number__c,Customer_Account_Name__r.isPartner,Partner_Account__c from case where id in:lstCase]);
            system.debug('lst od case--->'+lstCase);
            for(Case caseLoop:mapCase.values()){
                lstCaseToUpdate.add(caseLoop.Customer_Account_Name__c);   

        
        

            }
            if(lstCaseToUpdate.size()>0){
                mapPresalesAccount = new Map<Id,Presales_Account__c>([select Id,Name,Accountid__c from Presales_Account__c where Accountid__c in :lstCaseToUpdate]);
            }
            if(mapPresalesAccount.size()>0){
                for(Presales_Account__c presalesAccountLoop: mapPresalesAccount.values()){
                    mapPresalesAccountToUpdate.put(presalesAccountLoop.Name,presalesAccountLoop);   
                }
            }
            if(mapPresalesAccountToUpdate.size()>0){
                for(Case caseLoop: mapCase.values()){
		    //Check the symnergy account number for the current updated record and if null return here
                    //Null validation added to remove script exception
	            if(mapPresalesAccountToUpdate.containsKey(caseLoop.Customer_Account_Name__r.Synergy_Account_Number__c))
	            {
	            	caseLoop.Presales_Synergy_Account_Number__c = mapPresalesAccountToUpdate.get(caseLoop.Customer_Account_Name__r.Synergy_Account_Number__c).Id;
	            }
	            else
	            {
	              caseLoop.Presales_Synergy_Account_Number__c = null;
	            }	
                    //Added for populating partner account check box
                    if(caseLoop.Customer_Account_Name__r.isPartner ==true)
                    caseLoop.Partner_Account__c = true;
                    else
                    caseLoop.Partner_Account__c = false;
                
                }
            }
        }
            isCaseUpdate = true;
            if(mapCase.values().size()>0){
                update mapCase.values();   
            } 
    }
/* @Method <This method execute is used to populate Customer account from Synergy account number on case record>
@param <This method takes List<Case> as parameter>
@return void - <Not returning anything>
@throws exception - <No Exception>
*/    
    public void updateCustomerAccount(List<Case> lstCase){
        
            List<String> lstCaseToUpdate = new List<String>();
            Map<Id,Account> mapPresalesAccount = new Map<Id,Account>();
            Map<String,Account> mapPresalesAccountToUpdate = new Map<String,Account>();
            Map<Id,Case> mapCase =  new Map<Id,Case>();
            if(isCaseUpdate==false){
                mapCase =  new Map<Id,Case>([select ID,Presales_Synergy_Account_Number__r.Accountid__c from case where id in:lstCase]);
                system.debug('lst od case--->'+lstCase);
                /*for(Case caseLoop:mapCase.values()){
                    lstCaseToUpdate.add(caseLoop.Presales_Synergy_Account_Number__r.Name);  
                }
                if(lstCaseToUpdate.size()>0){
                    mapPresalesAccount = new Map<Id,Account>([select Id,Synergy_Account_Number__c from Account where Synergy_Account_Number__c in :lstCaseToUpdate]);
                }
                
                for(Account presalesAccountLoop: mapPresalesAccount.values()){
                    mapPresalesAccountToUpdate.put(presalesAccountLoop.Synergy_Account_Number__c,presalesAccountLoop);  
                }*/
                if(mapCase.size()>0){
                    for(Case caseLoop: mapCase.values()){
                        caseLoop.Customer_Account_Name__c = caseLoop.Presales_Synergy_Account_Number__r.Accountid__c;
                    }
                }
             }
            isCaseUpdate = true;
            update mapCase.values();
        
    }
/* @Method <This method execute is used to check the first ownership change from queue to user>
@param <This method takes Map<Id,Case> as parameter>
@return void - <Not returning anything>
@throws exception - <No Exception>
*/    
    public void checkFirstAllocation(Map<Id,Case> mapNewCase, Map<Id,Case> mapOldCase){
        String newCaseId;
        String oldCaseId;
        system.debug('case map--->'+mapNewCase);
        if(mapNewCase.values().size()>0){
            for(Case caseLoop:mapNewCase.values()){
                newCaseId = caseLoop.OwnerId;
                system.debug('case id'+newCaseId);
                oldCaseId = mapOldCase.get(caseLoop.Id).OwnerId ;
                //caseLoop.Case_UserName__c = caseLoop.owner.Name;
                if((newCaseId.substring(0,3))=='005' && (oldCaseId.substring(0,3))=='00G'){
                    caseLoop.IsFirstUsrAllocation__c = true;    
                }
            }
        }
        //update mapNewCase.values();
   } 
/* @Method <This method execute is used to populate user or contact fields on case record on update>
@param <This method takes Map<Id,Case> as parameter>
@return void - <Not returning anything>
@throws exception - <No Exception>
*/    
   public void presalesOperationsOnUpdate(Map<Id,Case> mapCase, Map<Id,Case> mapOldCase){
        Map<String,User> mapEmailUser = new Map<String,User>();
        Map<Id,String> mapIdEmail = new Map<Id,String>();
        Map<Id,Id> mapIdContact = new Map<Id,ID>();
        Map<Id,String> mapIdOwner = new Map<Id,String>();
    
        
        for(Case caseLoop: mapCase.values()){
            if(caseLoop.ContactId!=null){
                mapIdContact.put(caseLoop.Id,caseLoop.ContactId);
            }
            system.debug('mapId contact--->'+mapIdContact);
            if(caseLoop.Contact_Email1__c!=null && 
                caseLoop.Contact_Email1__c != mapOldCase.get(caseLoop.Id).Contact_Email1__c){
                mapIdEmail.put(caseLoop.Id,caseLoop.Contact_Email1__c);
                system.debug('mapId email--->'+mapIdEmail);
            }

        
     }   //End of For






            if(mapIdEmail.values().size() >0 || mapIdContact.values().size() >0){
                //lstContact = [select Id, Email,Phone, AccountId from Contact where (Email =:caseLoop.Contact_Email1__c and Email!=null) or id=:caseloop.Contact.Id];    
                Map<Id,Contact> mapContact = new Map<Id,Contact>([select Id, BU__c,Email,Phone,Country_Local__c, AccountId,Account.Theater1__c,Active__c from Contact where ((Email in:mapIdEmail.values()and Email !=null) or id in:mapIdContact.values())] );
                system.debug('lst of Contact--->'+mapContact);

        Map<Id,Contact> mapActiveContacts = new Map<Id,Contact>();
        Map<Id,Contact> mapInActiveContacts = new Map<Id,Contact>();
        Map<Id,Contact> mapContactsToBeUsed = new Map<Id,Contact>();
        For(Contact con: mapContact.values()){
            if(con.Active__c == true){
                mapActiveContacts.put(con.Id,con);  
            }
            else{
                mapInActiveContacts.put(con.Id,con);
            }
        }
        if(mapActiveContacts.size()==0){
            mapContactsToBeUsed = mapInActiveContacts.clone();
        }
        else{
            mapContactsToBeUsed = mapActiveContacts.clone();
                
        }

                for(Case caseLoop:mapCase.values()){
                    //Ganesh-03may20132: Added null pointer condition
                    if(caseLoop.ContactId!=null && mapContactsToBeUsed.get(mapIdContact.get(caseLoop.Id))!=null){
                        mapIdEmail.put(caseLoop.Id,mapContactsToBeUsed.get(mapIdContact.get(caseLoop.Id)).Email);
                        system.debug('mapId email--->'+mapIdEmail);
                    }
                }
                
                Map<Id,String> mapContactEmail = new Map<ID,String>();
                Map<String,Id> mapEmailContactId = new Map<String,Id>();
                

                for(Contact con: mapContactsToBeUsed.values()){
                    mapContactEmail.put(con.Id,con.Email);
                    mapEmailContactId.put(con.Email,con.Id);
                }
                for(Case caseRecord:mapCase.values()){
                system.debug('caseRecord.Contact_Email1__c--->'+caseRecord.Contact_Email1__c);
                    if(caseRecord.Contact_Email1__c!=null && caseRecord.Contact_Email1__c!=mapOldCase.get(caseRecord.Id).Contact_Email1__c&& mapEmailContactId.get(caseRecord.Contact_Email1__c)!=null){
                        mapIdContact.put(caseRecord.Id,mapEmailContactId.get(caseRecord.Contact_Email1__c));
                    }
                }
                system.debug('mapIdContactfinal--->'+mapIdContact);
				//WR185920:Add user Mobile field to populate TC mobile information.
            	//Add MobilePhone column  in the query
				//Declare a string to store mobile value
            	String strMobileNumber = null;  
		//WR185805: Add Manger field in the following query.
                Map<Id,User> mapUser = new Map<Id,User>([select Manager__c,MobilePhone,BU__c,PreSales_Case_Close_AutoReply__c,Division__c,Email,PreSales_Case_Pending_Engg__c ,PreSales_Case_Resolved__c,PreSales_Case_Escalated__c,PreSales_Case_Created__c,PreSales_Case_Assigned__c,PreSales_Case_Closed__c,Theater__c,Country__c,District__c,Area__c,CompanyName,Phone from user where (Email in:mapIdEmail.values() or Email in: mapContactEmail.values()) and isActive=true AND UserType != 'PowerPartner' limit 1]); 
                system.debug('lst of user--->'+mapUser);
                if(mapUser.values().size()>0){
                    for(User usr:mapUser.values()){
                        system.debug('usr.MobilePhone =='+usr.MobilePhone);
                    	if(usr.MobilePhone != null)
                    		strMobileNumber = usr.MobilePhone;
                    	system.debug('ustrMobileNumber =='+strMobileNumber);
                    	if(mapEmailUser.size() <= 0)
                        	mapEmailUser.put(usr.Email,usr);    
                    }
                }
                if(mapEmailUser.values().size()>0 && mapIdEmail.values().size()>0){
                    
                        for(Id caseId:mapIdEmail.keyset()){
                        try{
                            (mapCase.get(caseId)).Division__c = mapEmailUser.get(mapIdEmail.get(caseId)).Division__c;
                            (mapCase.get(caseId)).Country__c = mapEmailUser.get(mapIdEmail.get(caseId)).Country__c;
                            system.debug('mapIdContact.values().size()--->'+mapIdContact.values().size());
                            if(mapIdContact.get(caseId)!=null && mapContactsToBeUsed.size()>0){
                                (mapCase.get(caseId)).ContactId = mapIdContact.get(caseId);
                                (mapCase.get(caseId)).AccountId = mapContactsToBeUsed.get(mapIdContact.get(caseId)).AccountId;
                            }
                            //(mapCase.get(caseId)).AccountId = mapEmailUser.get(mapIdEmail.get(caseId)).CompanyName;
                            (mapCase.get(caseId)).Contact_Phone1__c = mapEmailUser.get(mapIdEmail.get(caseId)).Phone;
			                //WR185920:Add user Mobile field to populate TC mobile information.
		                   //Check if user enters the mobile number if not populate it with the user inforamtion
		                  // if((mapCase.get(caseId)).Contact_Mobile__c == null || 
					      // ((mapCase.get(caseId)).Contact_Mobile__c != null && mapEmailUser.get(mapIdEmail.get(caseId)).MobilePhone != null))
		                  (mapCase.get(caseId)).Contact_Mobile__c =  strMobileNumber;
                            (mapCase.get(caseId)).Contact_Email1__c = mapEmailUser.get(mapIdEmail.get(caseId)).Email;
                            (mapCase.get(caseId)).Area__c = mapEmailUser.get(mapIdEmail.get(caseId)).Area__c;
                            (mapCase.get(caseId)).District__c = mapEmailUser.get(mapIdEmail.get(caseId)).District__c;
                            (mapCase.get(caseId)).Theatre__c = mapEmailUser.get(mapIdEmail.get(caseId)).Theater__c;                            
                            (mapCase.get(caseId)).PreSales_Case_Assigned__c = mapEmailUser.get(mapIdEmail.get(caseId)).PreSales_Case_Assigned__c;
                            (mapCase.get(caseId)).PreSales_Case_Closed__c = mapEmailUser.get(mapIdEmail.get(caseId)).PreSales_Case_Closed__c;
                            (mapCase.get(caseId)).PreSales_Case_Created__c = mapEmailUser.get(mapIdEmail.get(caseId)).PreSales_Case_Created__c;
                            (mapCase.get(caseId)).PreSales_Case_Escalated__c = mapEmailUser.get(mapIdEmail.get(caseId)).PreSales_Case_Escalated__c;
                            (mapCase.get(caseId)).PreSales_Case_Resolved__c = mapEmailUser.get(mapIdEmail.get(caseId)).PreSales_Case_Resolved__c;
                            (mapCase.get(caseId)).PreSales_Case_Pending_Engg__c = mapEmailUser.get(mapIdEmail.get(caseId)).PreSales_Case_Pending_Engg__c;
                            (mapCase.get(caseId)).PreSales_Case_Close_AutoReply__c = mapEmailUser.get(mapIdEmail.get(caseId)).PreSales_Case_Close_AutoReply__c;
                            //caseLoop.Is_contact__c = false;
                            (mapCase.get(caseId)).Contact_Name_User__c = mapEmailUser.get(mapIdEmail.get(caseId)).Id;
			    //WR185805: Auto Populate Contact Manager Field
			    (mapCase.get(caseId)).ContactManager__c = mapEmailUser.get(mapIdEmail.get(caseId)).Manager__c;
                            (mapCase.get(caseId)).Business_Unit__c = mapEmailUser.get(mapIdEmail.get(caseId)).BU__c;
                            (mapCase.get(caseId)).Send_Mail_On_Update__c = true;

                            
                        }
                        catch(Exception e){
                            mapCase.get(caseId).addError('Please clear Contact field and re-save');
                        }
                        }                    
                }
                else if(mapContactsToBeUsed.values().size()>0 && mapIdContact.values().size()>0){
                   
                        for(Id caseId: mapIdContact.keyset()){
                        try{
                              (mapCase.get(caseId)).ContactId =mapIdContact.get(caseId);
                              (mapCase.get(caseId)).Contact_Email1__c = mapContactsToBeUsed.get(mapIdContact.get(caseId)).Email;
                              (mapCase.get(caseId)).Contact_Phone1__c = mapContactsToBeUsed.get(mapIdContact.get(caseId)).Phone;
                              (mapCase.get(caseId)).AccountId = mapContactsToBeUsed.get(mapIdContact.get(caseId)).AccountId;
			      			  //WR185920:Add user Mobile field to populate TC mobile information with null as no record found in user object.
			      			  (mapCase.get(caseId)).Contact_Mobile__c =  null;
                              (mapCase.get(caseId)).Theatre__c = null;
                              (mapCase.get(caseId)).Is_contact__c = true;
                              (mapCase.get(caseId)).Area__c = null;
                              (mapCase.get(caseId)).District__c = null;
                              (mapCase.get(caseId)).Country__c = null;
                              (mapCase.get(caseId)).Division__c = null;
                              (mapCase.get(caseId)).Contact_Name_User__c = null;
                              (mapCase.get(caseId)).Business_Unit__c = mapContactsToBeUsed.get(mapIdContact.get(caseId)).BU__c;
                              (mapCase.get(caseId)).Send_Mail_On_Update__c = true;
			      //WR185805: Auto Populate Contact Manager Field
                    	      (mapCase.get(caseId)).ContactManager__c = null;

                        }
                        catch(Exception e){
                            mapCase.get(caseId).addError('Please clear Contact field and re-save');
                        }
                        }         
                }
        }                       
   }
/* @Method <This method execute is used to populate login user details on case record>
@param <This method takes List<Case> as parameter>
@return void - <Not returning anything>
@throws exception - <No Exception>
*/
    public void populateLoginUserDetails(List<Case> lstCase){
        
        try{
            /*Quering user object for login user*/
	    //WR185920:Add user Mobile field to populate TC mobile information.
            //Add MobilePhone column  in the query 
	    //WR185805: Add Manger field in the following query.
            User loginUser=[select Manager__c,MobilePhone,BU__c,PreSales_Case_Close_AutoReply__c,Division__c,Email,PreSales_Case_Pending_Engg__c ,PreSales_Case_Resolved__c,PreSales_Case_Escalated__c,PreSales_Case_Created__c,PreSales_Case_Assigned__c,PreSales_Case_Closed__c,Theater__c,Country__c,District__c,Area__c,CompanyName,Phone from User where Id=:UserInfo.getUserId() AND UserType != 'PowerPartner' limit 1];
            system.debug('loginUser--->'+loginUser);
            /*Map<Id,String> mapUserIdEmail = new Map<Id,String>();
            for(User userRecord:mapIdUser.values()){
                mapUserIdEmail.put(userRecord.Id,userRecord.Email); 
            }*/
            List<Contact> contactRecord = new List<Contact>();
            contactRecord = [select Id,BU__c,AccountId,Active__c from Contact where (Email =:loginUser.Email and Email!=null) order by Active__c desc limit 1];
            if(loginUser!=null && lstCase!=null){
                for(Case caseRecord: lstCase){
                    if(contactRecord!=null && contactRecord.size()>0){
                        caseRecord.ContactId = contactRecord[0].Id;
                        caseRecord.AccountId = contactRecord[0].AccountId;
                    }
                    caseRecord.Contact_Phone1__c = loginUser.Phone;
		    //WR185920:Add user Mobile field to populate TC mobile information.
                    //Check if user enters the mobile number if not populate it with the user inforamtion
                    if(caseRecord.Contact_Mobile__c == null) caseRecord.Contact_Mobile__c =  loginUser.MobilePhone;
                    caseRecord.Division__c = loginUser.Division__c;
                     System.debug('SFDCDEV********caseRecord.Division__c********'+caseRecord.Division__c);
                     System.debug('SFDCDEV********loginUser.Division__c********'+loginUser.Division__c);
                     System.debug('SFDCDEV********caseRecord.Area__c********'+caseRecord.Area__c);
                     System.debug('SFDCDEV********loginUser.Area__c********'+loginUser.Area__c);
                     System.debug('SFDCDEV******** caseRecord.District__c********'+ caseRecord.District__c);
                     System.debug('SFDCDEV********loginUser.District__c********'+loginUser.District__c);
                    caseRecord.Contact_Email1__c = loginUser.Email;
                    caseRecord.Area__c = loginUser.Area__c;
                    caseRecord.District__c = loginUser.District__c;
                    caseRecord.Theatre__c = loginUser.Theater__c;      
                    
                                  
                    caseRecord.PreSales_Case_Assigned__c = loginUser.PreSales_Case_Assigned__c;
                    caseRecord.PreSales_Case_Closed__c = loginUser.PreSales_Case_Closed__c;
                    caseRecord.PreSales_Case_Created__c = loginUser.PreSales_Case_Created__c;
                    caseRecord.PreSales_Case_Escalated__c = loginUser.PreSales_Case_Escalated__c;
                    caseRecord.PreSales_Case_Resolved__c =loginUser.PreSales_Case_Resolved__c;
                    caseRecord.PreSales_Case_Pending_Engg__c = loginUser.PreSales_Case_Pending_Engg__c;
                    caseRecord.PreSales_Case_Close_AutoReply__c = loginUser.PreSales_Case_Close_AutoReply__c;
                    caseRecord.Contact_Name_User__c = loginUser.Id;
		    //WR185805: Auto Populate Contact Manager Field
                    caseRecord.ContactManager__c = loginUser.Manager__c;
                    caseRecord.Business_Unit__c = loginUser.BU__c;
                    caseRecord.Country__c = loginUser.Country__c;
                    caseRecord.Send_Mail_On_Update__c = true;
                    //caseRecord.Validation_check_for_TC__c= true;
                    //caseRecord.setOptions(dmo);
                }
            }
        }   
        catch(Exception e){
            system.debug('Exception on case inserton'+e);
        }
        isError = true;
    }
/* @Method <This method execute is used to auto assign a case to a queue according to the assignment rule.>
@param <This method takes List<Case> as parameter>
@return void - <Not returning anything>
@throws exception - <No Exception>
*/
    public void autoAssignmentToQueue(List<Case> lstCase){
        List<Case> lstToUpdate = [select Id,OwnerId from Case where Id in:lstCase];
        List<CaseShare> cs = new List<CaseShare>();
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= true;
        if(lstToUpdate.size()>0){
            for(Case caseRecord:lstToUpdate){
                caseRecord.setOptions(dmo);
                //caseRecord.Validation_check_for_TC__c = true;
            }
            
        }
        //insert cs;
        update lstToUpdate; 
        system.debug('lstToUpdate--->'+lstToUpdate);    
    }
/* @Method <This method execute is used to check if the requestor is not a user or contact.>
@param <This method takes List<Case> as parameter>
@return void - <Not returning anything>
@throws exception - <No Exception>
*/ 
    public void checkIFRequestorUserOrContact(List<Case> lstCase){
        Map<String,Case> mapEmailCase = new Map<String,Case>();
        Map<String,Contact> mapEmailContact = new Map<String,Contact>();
        Map<String,User> mapEmailUser = new Map<String,User>();
        for(Case caseRecord:lstCase){
            mapEmailCase.put(caseRecord.Contact_Email1__c,caseRecord);
        }
        Map<Id,Contact> mapIdContact = new Map<Id,Contact>([select id,Email,Name from Contact where Email in:mapEmailCase.keyset() and Email!=null]);
        
        Map<Id,User> mapIdUser = new Map<Id,User>([select Id,Email, Name from User where Email in:mapEmailCase.keyset() AND UserType != 'PowerPartner']);
        for(Contact contactRecord:mapIdContact.values()){
            mapEmailContact.put(contactRecord.Email,contactRecord);    
        }
        for(User userRecord:mapIdUser.values()){
            mapEmailUser.put(userRecord.Email,userRecord);    
        }
        for(Case caseRecord:lstCase){
            if(!(mapEmailContact.containsKey(caseRecord.Contact_Email1__c)) && !(mapEmailUser.containsKey(caseRecord.Contact_Email1__c))){
                caseRecord.Is_not_User_Contact__c = true;
            }
            else{
                caseRecord.Is_not_User_Contact__c = false;
            }
        }
    }
/* @Method <This method execute is used to check the validation on Case for TC.>
@param <This method takes Map<ID,Case> as parameter>
@return void - <Not returning anything>
@throws exception - <No Exception>
*/
    public void checkValidationOnCaseUpdate(Map<Id,Case> mapNewCase, Map<Id,Case> mapOldCase){
        try{
        if(mapNewCase!=null && isError==false)
        {
            Profile userProfile = [select Id,Name from Profile where Id=:UserInfo.getProfileId()];
            if(userProfile!=null)
            {            
                //Divya-5/2/2013: Added 'Presales Solutions Support Manager' profile to the 'if' condition      
                if(userProfile.Name!='EMC Presales Case Creation Profile' && userProfile.Name!='Presales Service Manager' && userProfile.Name!='Presales Solutions Support Manager' && userProfile.Name!='Presales Service Rep' &&!(userProfile.Name.contains('Administrator'))){
		//if(userProfile.Name!='EMC Presales Case Creation Profile' && userProfile.Name!='Presales Service Manager' && userProfile.Name!='Presales Service Rep' &&!(userProfile.Name.contains('Administrator'))){
                    for(Case caseLoop:mapNewCase.values()){
                    system.debug('caseLoop.Validation_check_for_TC__c---->'+caseLoop.Validation_check_for_TC__c);
                        if(caseLoop.Validation_check_for_TC__c == false){
                            caseLoop.addError(System.Label.Presales_TCUpdateError);
                        }  
                        else{
                            caseLoop.Validation_check_for_TC__c = false;
                        }  
                    }
                }
            
            }
        }
        //isError = True;
        }
        catch(Exception e){
            system.debug('exception handled'+e);
        }
    }          
 
/* @Method <This method execute is used to set owner's role name.>
@param <This method takes Map<ID,Case> as parameter>
@return void - <Not returning anything>
@throws exception - <No Exception>
*/
public void presalesOperationsSetRoleName(Map<Id,Case> mapCase){
    if(isSetRoleName){    
        Map<Id,List<Case>> mapOwnerCase = new Map<Id,List<Case>>();
        Map<String ,String> mapUsrGrp    = new Map<String , String>();
        for(Case caseRecord:mapCase.values()){
             if(mapOwnerCase.containsKey(caseRecord.OwnerId)){
                    (mapOwnerCase.get(caseRecord.OwnerId)).add(caseRecord);
             }
             else{
                    List<Case> lstOFCase = new List<Case>();
                    lstOfCase.add(caseRecord);
                    mapOwnerCase.put(caseRecord.OwnerId,lstOfCase);
             }    
        }
        /* ganesh commented on 12thmarch 2013
        Map<Id,User> mapOwner = new Map<Id,User>([select id,Name,UserRole.Name from User where id in:mapOwnerCase.keyset() AND UserType != 'PowerPartner']);
        Map<Id,Group> mapQueue = new Map<Id,Group>([select id,Name from Group where id in:mapOwnerCase.keyset()]);
        */
        Map<String,PresalesAssignedServiceGroup__c> mapUserGroup = PresalesAssignedServiceGroup__c.getall();
        
        for(PresalesAssignedServiceGroup__c assGrp :mapUserGroup.values()){
            mapUsrGrp.put(assGrp.QueueorRole__c , assGrp.Value__c);
        }
        
        System.debug('mapUsrGrp------>'+mapUsrGrp);
        
        
        Map<ID,List<Case>> ownerMap = new Map<ID,List<Case>>();
        Map<ID,List<Case>> queueMap = new Map<ID,List<Case>>();
         List<String> lstService = new List<String>();
         
        
         
        /*Checking if owner is a user or queue*/
        for(String s:mapOwnerCase.keyset()){
            if(s.substring(0,3)=='005'){
                ownerMap.put(s,mapOwnerCase.get(s));          
            }
            else if(s.substring(0,3)=='00G'){
                queueMap.put(s,mapOwnerCase.get(s)); 
                //system.debug('lst q'+lstCaseOwnerQueue);
        }
            }  
         
        if(ownerMap.size()>0){
        	Map<Id,User> mapOwner = new Map<Id,User>([select id,Name,UserRole.Name from User where id in:mapOwnerCase.keyset() AND UserType != 'PowerPartner']);// ganesh added on 12thmarch2013
            for(Id ownerId:ownerMap.keyset()){                
                for(Case caseRecord:ownerMap.get(ownerId)){
                    if(mapOwner.get(ownerId).UserRole.Name != null && 
                        mapOwner.get(ownerId).UserRole.Name.contains('Presales')){
                    if(mapUserGroup.size()>0){
                    lstService = (mapOwner.get(ownerId).UserRole.Name).split(' ');
                    //caseRecord.Assigned_Service_Group_Name__c = lstService[1];
                    
                  
                     
                     System.debug('Assigned_Service_Group_Name__c owner------>'
                                    +mapUsrGrp.get((mapOwner.get(ownerId).UserRole.Name)));
                     caseRecord.Assigned_Service_Group_Name__c = mapUsrGrp.get((mapOwner.get(ownerId).UserRole.Name));
                    }
                     }
                     else if(mapOwner.get(ownerId).UserRole.Name == null || !mapOwner.get(ownerId).UserRole.Name.contains('Presales'))
                    {
                         caseRecord.Assigned_Service_Group_Name__c = '';
                    }

                    
                }              
            }
        }
        if(queueMap.size()>0){
        	Map<Id,Group> mapQueue = new Map<Id,Group>([select id,Name from Group where id in:mapOwnerCase.keyset()]);
            System.debug('SFDCDEV**********mapQueue***'+mapQueue);
            for(Id ownerId:queueMap.keyset()){                
                for(Case caseRecord:queueMap.get(ownerId)){
                    if(mapUserGroup.size()>0){
                         System.debug('Assigned_Service_Group_Name__c Queq------>'+mapUsrGrp.get(mapQueue.get(ownerId).Name));
                         // caseRecord.Assigned_Service_Group_Name__c = mapQueue.get(ownerId).Name;                
                          caseRecord.Assigned_Service_Group_Name__c = mapUsrGrp.get(mapQueue.get(ownerId).Name);
                        }

                     
                }
            }
        }
     }
     isSetRoleName = false;    
}
/* @Method <This method execute is used to delete requestor from case team.>
@param <This method takes List<String> and List<Id> as parameters>
@return void - <Not returning anything>
@throws exception - <No Exception>
*/ 
    public void deleteCaseTeam(List<String> maiList , List<Id> lstCaseId , List<Id> cntUsrIDList){

        List<CaseTeamMember> chkTeam= new List<CaseTeamMember>();
        chkTeam = [Select ParentId,MemberId from CaseTeamMember where ParentId in :lstCaseId];

        if(chkTeam.size()>0){
        
        if(!isCaseTeamDelete){
        try{
        List<CaseTeamMember> teamList = new List<CaseTeamMember>();
        List<Contact> cntList = new List<Contact>();
        
        if(maiList.size()>0){
        cntList = [Select id from contact where email in: maiList and email != null];
        }
        
        System.debug('cntListASASASAS' +cntList);
        System.debug('lstNewCasessdfsdfsdf' +lstCaseId);
        System.debug('cntUsrIDListvbfghfgh' +cntUsrIDList);

        if(cntList.size()>0 || cntUsrIDList.size()>0){
        teamList = [Select ParentId,MemberId from CaseTeamMember where ParentId in :lstCaseId and (MemberId in :cntList or MemberId in :cntUsrIDList)];
        }
        
        System.debug('teamList%^&%^&' +teamList);
        
        if(teamList.size()>0){
            delete teamList;
        }
        }
        catch(DmlException e){
            system.debug('DML exception'+e);
        }
        }

        isCaseTeamDelete = true;

        }
        
    }

   /* @Method <This method execute is used to valdiate the case type
    if service rep doesn't change it from default case type(Created from Email to Case). (WR 192193)>
    @param <This method takes NewCase,OldCase and map of recordtypes,mapEMCDefaultOwner and Current user profile as parameters>
    @return void 
    */ 
    /*public void ValidateCaseType(Case objCase,Case objOldCase,Map<Id,RecordType> mapEmailtoCaseRecordTypes,
                                    Map<Id,User> mapDefaultOwner,Profile objProfile){
                                        
        String strEMCDefaultOwnerName = 'EMC Default Owner';                                    
        //Srinvias: If the Case is updated by TC then this method should not be executed.
        if(objProfile != null && (objProfile.Name == 'EMC Presales Case Creation Profile' || objProfile.Name == 'Presales Service Manager' || 
                    objProfile.Name == 'Presales Service Rep' || objProfile.Name.contains('Administrator')))
                    {
                        //Srinivas: Declare and Assign string variable to store the owner id
                        String strOwnerId = objCase.OwnerId;
                        String strCaseType = objCase.Record_Type_Name__c;
                        String strCaseOwnerName = objCase.Case_UserName__c; 
                        system.debug('objCase.RecordTypeId == '+objCase.RecordTypeId);
                        //system.debug('strCaseType == '+mapEmailtoCaseRecordTypes);
                        system.debug('strOwnerId== '+strOwnerId);
                        system.debug('strEMCDefaultOwnerName == '+strEMCDefaultOwnerName);
                        system.debug('objOldCase == '+objOldCase);
                        system.debug('strCaseType == '+strCaseType);
                        system.debug('strCaseOwnerName == '+strCaseOwnerName);
                        //Srinivas: Check the Case type and if it is not updated from Email to Case
                        //record types to other then we have to show message to user to select the valid case type.
                        if((strCaseType != null && strCaseType.indexOf('Email') >= 0)
                                &&  (strOwnerId != null && strCaseOwnerName != strEMCDefaultOwnerName && strOwnerId.substring(0,3) == '005')
                                  && objOldCase.OwnerId == objCase.OwnerId)
                        {
                            objCase.addError('Please select a valid case type.');
                            
                        }
                    
                    }
                    
    }*/
    
    /* @Method <This method execute is used to get the record types of E2C (WR 192193)
    @param <This method takes no parameters>
    @returns Map<Id,RecordType>
    */ 
    public Map<Id,RecordType> GetE2CRecordTypes(){
        
        //Srinivas: Get all the record types which belong to EMail to Case functionlaity and return here
         return new Map<Id,RecordType> ([select id,Name
                                        from RecordType 
                                        where sObjectType='Case' 
                                        and DeveloperName like 'Presales%' 
                                        and Name like '%Email']);
                                                          
                    
    }
    
    /* @Method <This method gets the opportunity details based on opportunity number (WR 185944)
    @param <This method takes List of case records to update and set of opportunity numbers to get the details of opportunity>
    @returns void
    */ 
    public void GetOpportunityDetails(List<Case> lstCaseRecords,Set<String> setOppNumbers){
        system.debug('setOppNumbers == '+setOppNumbers);
        //Declare a Map collection to store the records which are identified by Opp Number
        Map<String,Opportunity> mapOppDetails = new Map<String,Opportunity>();
        //Srinivas: Get Opportunity detaails based on entered Opportunity Number in case record
        for(Opportunity objOpp : [select ID,Name,Opportunity_Number__c,AccountId from Opportunity where Opportunity_Number__c in : setOppNumbers])
        {
          //Add key as Opp Number and value as Opportunity record to map
          mapOppDetails.put(objOpp.Opportunity_Number__c,objOpp);
        } 
      
       //Invoke the method to update the Opportunity Name
       UpdateOpportunityName(lstCaseRecords,mapOppDetails);
    }
    
    
    /* @Method <This method gets the opportunity details based on opportunity number (WR 185944)
    @param <This method takes List of case records to update and set of opportunity numbers to get the details of opportunity>
    @returns void
    */ 
    public void UpdateOpportunityName(List<Case> lstCaseRecords,Map<String,Opportunity> mapOppDetails){
       //Iterate the case records to update the Opportunity Name
       for(Case objCase : lstCaseRecords)
       {
          system.debug('mapOppDetails == '+mapOppDetails);
         //Get the opportunity details from map cillection using case record opportunity number
         if(! mapOppDetails.containsKey(objCase.Opp_Number__c)) 
         {
            objCase.addError('No matching Opportunity number found.Please try with the other.');
         }
         else
         {
            objCase.Opportunity_Name__c = mapOppDetails.get(objCase.Opp_Number__c).ID;
         }
         
       }
               
    }

    //Contact Mobile :Added by Ganesh 
    public void presalesOperationsSetMobile(List<Case> lstCases)
    { 
	//Declare map to store case contact email ids as values
	Map<Id,String> mapCaseIdEmail = new Map<Id,String>();
	//Iterate case list to get the contact email from cases
	for(Case objCase : lstCases)
	{
		//Add the contact email to map here
	        mapCaseIdEmail.put(objCase.ID,objCase.Contact_Email1__c);
	}
	system.debug('mapCaseIdEmail == '+mapCaseIdEmail.values());
	/* ganesh commented below querey 
	List<User> lst = [select MobilePhone,Email from user where Email in:mapCaseIdEmail.values() and isActive=true];
	*/
	//Declare a string variable
	String strMobileNumber = null;
	//Declare map to store contact mobile value from user records
	Map<String,String> mapEmailDetails = new Map<String,String>();
	//Iterate the user records based on case contact email and iterate them to add to map
	for(User objUser : [select MobilePhone,Email from user where Email in:mapCaseIdEmail.values() and isActive=true])
	{ 
		if(objUser.MobilePhone != null) mapEmailDetails.put(objUser.Email,objUser.MobilePhone);
	}
	//If the mapEmailDetails is empty then return here no need to execute code
	if(mapEmailDetails.size() <= 0) return;
	//Get the records form case object as the operation is after event and we cant directly update the field
	List<Case> lstCaseRecordsToUpdate = new List<Case>([select id,Contact_Email1__c,Contact_Mobile__c from case where id in :lstCases]);
	//Iterate the case records and assign the mobile value here
	for(Case obj : lstCaseRecordsToUpdate)
	{
		obj.Contact_Mobile__c = mapEmailDetails.get(obj.Contact_Email1__c);
		  
	}
	//Update the list here
	update lstCaseRecordsToUpdate;

     } 

     public void presalesOperationsSetOwnerRole(List<Case> mapCase){   	     
	   
       Map<Id,List<Case>> mapOwnerCase = new Map<Id,List<Case>>();          
        for(Case caseRecord:mapCase){
             if(mapOwnerCase.containsKey(caseRecord.OwnerId)){
                    (mapOwnerCase.get(caseRecord.OwnerId)).add(caseRecord);
             }
             else{
                    List<Case> lstOFCase = new List<Case>();
                    lstOfCase.add(caseRecord);
                    mapOwnerCase.put(caseRecord.OwnerId,lstOfCase);
             }    
        }
        
        System.debug('SFDCDEV*****mapOwnerCase******'+mapOwnerCase);
        Map<Id,User> mapOwner = new Map<Id,User>([select id,Name,UserRole.Name from User where id in:mapOwnerCase.Keyset()]);
        User objUserRecord =  null;
        for(Case obj : mapCase)
        {
           objUserRecord = mapOwner.get(obj.OwnerId);
           if(objUserRecord == null)
           {
           	obj.Case_Owner_Role__c = ''; 
           	break;
           }
           obj.Case_Owner_Role__c = objUserRecord.UserRole.Name;
        }
      
        /*if(mapOwnerCase.size()>0){ 
        	 for(Id ownerId:mapOwnerCase.keyset()){                
                for(Case caseRecord:mapOwnerCase.get(ownerId)){               
                     System.debug('SFDCDEV*****mapOwner.get(caseRecord.ownerId)******'+mapOwner.get(caseRecord.ownerId)+'****mapOwner.get(caseRecord.ownerId).UserRole.Name******'+mapOwner.get(caseRecord.ownerId).UserRole.Name+'*** caseRecord.ownerId.substring(0,3)******'+ string.valueof(caseRecord.ownerId).substring(0,3));
                     if(mapOwner.get(caseRecord.ownerId) != null && mapOwner.get(caseRecord.ownerId).UserRole.Name != null  &&  string.valueof(caseRecord.ownerId).substring(0,3)=='005'){                        	
                         caseRecord.Case_Owner_Role__c = mapOwner.get(caseRecord.ownerId).UserRole.Name;                   
                     }
                     else
                    {
                         caseRecord.Case_Owner_Role__c = '';
                    }                    
                }   
        	  }           
            } */     
     }

  
    //Ganesh
    public void CloseParentCaseIfSLACompleted(Map<Id,Case> mapParentCaseIdChildCase)
    {
    	Map<Id,Case> mapParentCases = new Map<Id,Case>([select id,status,SLA_Completed__c from case where id in:mapParentCaseIdChildCase.keyset()]); 
    	//Commented by Ganesh and moved under If condition 15Mar2013
    	//Map<Id,Case> mapChildCases = new Map<Id,Case>([select Id,Status,ParentId from Case where ParentId in:mapParentCaseIdChildCase.keyset()]);
    	    	
    	List<Case> lstCloseParentCases = new List<Case>();
    	List<Case> lstChildCasesCheck = new  List<Case>(); 
    	
    	if(mapParentCases!=null && mapParentCases.size()>0)
    	{
    		//Added by Ganesh 15Mar2013
    		Map<Id,Case> mapChildCases = new Map<Id,Case>([select Id,Status,ParentId from Case where ParentId in:mapParentCaseIdChildCase.keyset()]);
	    	for(Case objParentCase: mapParentCases.values())
	    	{
	    		boolean CanWeCloseParent = true;
	    		if(objParentCase.SLA_Completed__c!=null &&  objParentCase.Status == 'Resolved') 
	    		{
	    			if(System.now() >= objParentCase.SLA_Completed__c)
	    			{   
	    				if(mapChildCases!=null && mapChildCases.size()>0)
	    				{
		    				for(case childcase:mapChildCases.values())
		    				{
		    					if(childcase.ParentId == objParentCase.Id)
		    					{
		    						lstChildCasesCheck.add(childcase);
		    					}
		    				}
	    				}   	
			    		
			    		if(lstChildCasesCheck.size()>0)
			    		{
				    		//Check before closing the parent case whether any child cases are not having Closed/Resolved/Rejected status
				    		for(Case objChildCase:lstChildCasesCheck)
				    		{
				    			if(objChildCase.Status!= 'Closed'&& objChildCase.Status!= 'Resolved' && objChildCase.Status!= 'Rejected')
				    			{
				    				CanWeCloseParent = false;
				    				break;
				    			}
				    		}
			    		}
			    		
			    		if(CanWeCloseParent)
	    		        {
		    			  objParentCase.status = 'Closed';    			
		    			  lstCloseParentCases.add(objParentCase);
	    		       }    		
	    			}
	    		} 
	    	}
    	}
    	   	
    	if(lstCloseParentCases.size()>0)
    	  update lstCloseParentCases;
    }

        
 //4686 - IM7343671 De-dup emails sent to resources from a case   
 
 //WR220748
    public void CheckUniqueOpportunity(Map<Id,Case> mapCases) 
    {
		
		Map<ID,String> mapCaseOppIds = GetSelectedOppsforCase(mapCases.keyset());
      	
      	if(mapCaseOppIds == null || mapCaseOppIds.size() <= 0) return;
      	
      	String strOpportunities = '';
      	
      	//Iterate list and get the mathcing opportunity for the case record
      	for(Case objCase : mapCases.values())
      	{
      		strOpportunities = mapCaseOppIds.get(objCase.Id);
      		
      		if(strOpportunities.indexOf(objCase.Opportunity_Name__c) >= 0)
      		{
      			objCase.addError('This Opportunity is already linked to the Case record. Please select another Opportunity.');
      		}
      	
      	}											
		
    }
    
    public Map<ID,String> GetSelectedOppsforCase(Set<Id> setCaseIDs)
    {
    	Map<ID,String> mapCaseOppIds = new Map<ID,String>();
    	String strOppId = '';
    	ID caseID = null;
    	String strTemp = '';  
    	for(Related_Opportunity__c objRelatedOpp : [select id,Opportunity_Name__c,Case__r.Opportunity_Name__c from Related_Opportunity__c where Case__c in: setCaseIDs])
		{
    		//Type cast Opp ID in to string here         
        	strOppId = String.valueOF(objRelatedOpp.Opportunity_Name__c);
        	caseID = objRelatedOpp.Case__c;
        	if(! mapCaseOppIds.containsKey(caseID))
        	{
        		//Add Case ID as key and OPP ID as Value            
            	mapCaseOppIds.put(caseID,strOppId);
        	}
        	else
        	{
        		//Get opp id value and put it in variable
            	strTemp = mapCaseOppIds.get(caseID);
            	//Add opportunity id as comma seperated here 
            	strTemp = strTemp + ',' + strOppId;
            	//Add Case ID as key and comma seperated OPP ID as Value  
            	mapCaseOppIds.put(caseID,strTemp);
        	}
                
		}
		
		return mapCaseOppIds;
    
    }

    //WR220748
    public void CheckUniqueRelatedOpportunities(Related_Opportunity__c objRelatedOpp,Map<ID,String> mapCaseOppIds) 
    {
    	String caseID = objRelatedOpp.Case__c;
    	String strOppId = String.valueOf(objRelatedOpp.Opportunity_Name__c);
    	String strTemp = '';
		//Gets the opportunity ids based on current case record from map
	    strTemp = mapCaseOppIds.get(caseID);
        system.debug('strTemp == '+strTemp); 
        system.debug('strTemp == '+strOppId);  
        if(strTemp != null && strTemp.indexOf(strOppId) >= 0)
        {
        	system.debug('strTemp 1== '+strTemp.indexOf(strOppId));
        	objRelatedOpp.addError('This Opportunity is already linked to the Case record. Please select another Opportunity.');
        }
		
    }

}//end of class