/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER              WR               DESCRIPTION                               
 |  ====       =========              ==               =========== 
 |  19-JUL-11  Srinivas Nallapati    169801         Initial Creation - for prevention of duplicate contacts(Same email id) During the Update
 |  20-OCT-11  Arif                  177285         Only sending active contacts to trigger.
 |  16-JAN-12  Anil                  182579         Update InactivatedBy field with user who is inactivating the contact
 |  22/01/2011 Accenture                            Updated trigger to incorporate ByPass Logic
 |                                                  NOTE: Please write all the code after BYPASS Logic
 |  18/05/2012 Anirudh				 192375	   		Added Logic to flip record type based on PartnerType=DistiVAR
 |  17/08/2012 Ganesh                201028         Invoking new method  'flipContactRecordTypeToPartner' of class 'PRM_ContactUserSynchronization' for updating the 
                                                    ‘Partner_Contact2__c’ and ‘RecordTypeId’ fields  after deactivating the Workflow Rule 'Update Partner Contact Checkbox'   
 +===========================================================================*/

trigger ContactBeforeUpdate on Contact (Before Update) {
   //Trigger BYPASS Logic
   if(CustomSettingBypassLogic__c.getInstance()!=null){
         if(CustomSettingBypassLogic__c.getInstance().By_Pass_Contact_Triggers__c){
                return;
         }
    }
      //  Modified Audit : Srinivas Nallapati 17/Jul/2011
      //  Reason         : WR 169801 - Prevent duplicate Contacts on update. 
      list<Contact> lstContact = new list<Contact>();
      list<Contact> lstInActiveContacts = new list<Contact>();
      list<Contact> lstActivatedContacts = new list<Contact>();
      boolean activeStatus = false;
      List<Contact> lstContactToFlipRecordType = new List<Contact>();  
      Map<Id,Id> mapPartnerAccountWithContact = new Map<Id,Id>(); 
        for(Contact con:trigger.new){
            if(con.active__c){
                lstContact.add(con);
            }
            if(!con.active__c && trigger.oldMap.get(con.Id).active__c!=con.active__c){
                lstInActiveContacts.add(con);
            }
            if(con.active__c && trigger.oldMap.get(con.Id).active__c!=con.active__c){
                lstActivatedContacts.add(con);
                activeStatus = true;
            }
            if(con.AccountId!=null && con.AccountId!=trigger.oldMap.get(con.Id).AccountId && con.Active__c && con.Partner_Contact2__c){
               lstContactToFlipRecordType.add(con); 
            }
            if(con.AccountId!=null && (con.Partner_SE__c!=trigger.oldMap.get(con.Id).Partner_SE__c || con.Inside_Partner_SE__c != trigger.oldMap.get(con.Id).Inside_Partner_SE__c )
                && con.Active__c && con.Partner_Contact2__c){
               lstContactToFlipRecordType.add(con); 
            }
            if(con.AccountId==null && con.Partner_Contact2__c){
               con.Partner_Contact2__c=false;
            }
            //Added by Ganesh
            mapPartnerAccountWithContact.put(con.Id,con.AccountId);
        }
        
        //Added by Ganesh, after deactivating the workflow rule 'Update Record to Partner Contact'
        if(mapPartnerAccountWithContact.size()>0)
        {
	        PRM_ContactUserSynchronization syncObj = new PRM_ContactUserSynchronization();
	        syncObj.flipContactRecordTypetopartner(mapPartnerAccountWithContact,trigger.newMap);
        }
        if(lstContact.size()>0){
            CTCT_PreventDuplicates.ProcessContactUpdates(lstContact);
        }   
        if(lstInActiveContacts.size()>0){
           PRM_ContactUserSynchronization conOperation = new PRM_ContactUserSynchronization();
           conOperation.populateInactivatedByValueOnContact(lstInActiveContacts,activeStatus);
        }
         if(lstActivatedContacts.size()>0){
           PRM_ContactUserSynchronization conOperation = new PRM_ContactUserSynchronization();
           conOperation.populateInactivatedByValueOnContact(lstActivatedContacts,activeStatus);
        }
        
        PRM_ContactUserSynchronization syncObj = new PRM_ContactUserSynchronization();
        syncObj.flipContactRecordTypetoDistiVar(lstContactToFlipRecordType);
   }