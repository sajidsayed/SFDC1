/*
* Created By   :-  Sunil Arora
* Created Date :-  22nd Sep,2009
* Modified By  :-  Sunil Arora
* Modified Date:-  22nd Sep,2009
* Description  :-  This triggger is used to update TA_Assigment_Type__c field on Account and
                   will run on insert and update event.
* Modified By  :-  Karthik S
* WR:- 1077 and 10778  
* Modified Date:-  22nd Sep,2010
* Description  :-  This triggger is used to fetch the newly the created accounts
                   to create partner grouping or suggest grouping.
  Defect 104 : Added by Saravanan  
  Added/Modified by Saravanan on 3-Feb 2011 auto populating specality fields Req - 2030.
* Modified By : Shipra Misra on 20.01.11. Updated Partner Type Picklist field as per the value in Partner Type Multiselect Picklist on account.               
  17-10-2011    Srinivas Nalllapati     WR-178236   Create exemption for certain EMC Classifications for Top Offender
* Modified By : Arif on 15/11/2011 Updated Trigger to invoke setNonDistributorDirectResllerFlag if Partner Type is changed for Account     
* Modified By : Accenture on 12/23/2011 Updated Trigger to invoke populateClusterOnAccount based on Account's Billing Country.
* Modified By : Accenture on 22/01/2011 Updtaed Trigger to incorporate BYpass Logic.Write all the code after Bypass Logic. 
  Arif 197466 : Added part for cloud builder 
  Arif PAN    : Added a flag isPopulateVelocitySpecialty which will restrict the calculation of 'Velocity Specialty Achieved' field(DONOT MIGRATE THIS FILE 
  WITH THIS CHANGE AS THIS IS A PART OF OCTOBER 2012 RELEASE) 
  Arif PAN    : Added call of method 'syncPANAttributes' from PRM_PAN_VPP_Operations class(DONOT MIGRATE THIS FILE 
  WITH THIS CHANGE AS THIS IS A PART OF OCTOBER 2012 RELEASE) 
  Anirudh     : Updated trigger to invoke PRM and specialities deployed functionality for only Partner Accounts. 
  Anand 20-02-2013: Added Isilon logic 
 */


trigger TO_AccountInsertOrUpdate on Account (before insert, before update) 
{
   //Trigger BYPASS Logic
    if(CustomSettingBypassLogic__c.getInstance()!=null){
       System.Debug('1111--->');
       if(CustomSettingBypassLogic__c.getInstance().By_Pass_Account_Triggers__c){
                return;
       }
    }
   //For WR-178236
   Map<String, TO_EMC_Classification_To_Be_Skipped__c>  mapTO_EMC_Classification_To_Be_Skipped = TO_EMC_Classification_To_Be_Skipped__c.getAll();
   PRM_DealReg_Operations PRMDealRegObj = new PRM_DealReg_Operations();
   List<Account> lstAccountsToUpdate = new List<Account>();
   List<Account> lstAccountsToSetCluster = new List<Account>();
   
   PRM_AccountGrouping accountObject = new PRM_AccountGrouping();
   if(trigger.isInsert){
    for(Account acc:trigger.new){
        if(!mapTO_EMC_Classification_To_Be_Skipped.containsKey(Acc.EMC_Classification__c))
            acc.TA_Assignment_Type__c='Create';
        else
            acc.TA_Assignment_Type__c='Exempt'; 
    
        if(acc.Partner_Type__c != null && acc.Partner_Type__c != '' ){
           lstAccountsToUpdate.add(acc); 
        }
         if(acc.BillingCountry != null && acc.BillingCountry != '' ){
           lstAccountsToSetCluster.add(acc); 
        }
    }
    //Added for the WR1077 and 1078 by karthik
    accountObject.processAccountForGrouping(trigger.new);
   }
   else{
    //It will update TA_Assigment_Type__c only when BillingState,BillingCountry or EMC_Classification__c gets updated.
    for(Id newAccountId: Trigger.newMap.keySet())
    {
        Account newAccount = Trigger.newMap.get(newAccountId);
        Account oldAccount = Trigger.oldMap.get(newAccountId);
        if(newAccount.BillingState!=oldAccount.BillingState || 
           newAccount.BillingCountry!=oldAccount.BillingCountry || 
           newAccount.EMC_Classification__c != oldAccount.EMC_Classification__c){
            if(!mapTO_EMC_Classification_To_Be_Skipped.containsKey(newAccount.EMC_Classification__c))
                newAccount.TA_Assignment_Type__c='Update';
            else
                newAccount.TA_Assignment_Type__c='Exempt'; 
           }
    }
   }   
   
   // Fix for defect 104
   for ( Account a : Trigger.new ) {
       a.Reporting_Owner__c = a.OwnerId;
       //Added by Shipra on 20.01.11 just updated Partner Type Text from Partner Type. 
       //a.Partner_Type_Text__c = a.Partner_Type__c;
       a.Partner_Type_Picklist__c = a.Partner_Type__c;
       
       // Added by Saravanan on 3-Feb 2011 auto populating specality fields Req - 2030.       
     if(a.Account_Level__c != '' || a.Account_Level__c !=null && a.IsPartner== true){  
         a.Velocity_Specialties_Achieved__c = '';
         String tmp_velocityAchived = '';
         System.debug('a.Velocity_Specialties_Achieved__c tmp_velocityAchived===>' +tmp_velocityAchived);
         tmp_velocityAchived = tmp_velocityAchived + a.Velocity_Specialties_Achieved__c;
         
         If ( a.Consolidate_Specialty__c == 'Deployed'){
              if (( a.Velocity_Specialties_Achieved__c != 'Consolidate' 
                  && a.Velocity_Specialties_Achieved__c == 'Advanced Consolidate' ) ||
                  (a.Velocity_Specialties_Achieved__c != '' )) {
                    a.Velocity_Specialties_Achieved__c = 'Consolidate;' ;
               } 
           }else If ( a.Consolidate_Specialty__c == 'Not Deployed'){
              if ( a.Velocity_Specialties_Achieved__c == 'Consolidate' 
                  && a.Velocity_Specialties_Achieved__c != 'Advanced Consolidate' ) {
                       a.Velocity_Specialties_Achieved__c = (tmp_velocityAchived.replace('Consolidate', ''));
              }   
           }
       
           If ( a.Advanced_Consolidate_Specialty__c == 'Deployed'){
              if (( a.Velocity_Specialties_Achieved__c == 'Consolidate' 
                  && a.Velocity_Specialties_Achieved__c != 'Advanced Consolidate' ) ||
                  (a.Velocity_Specialties_Achieved__c != '' )) {
                    a.Velocity_Specialties_Achieved__c = a.Velocity_Specialties_Achieved__c+'Advanced Consolidate;' ;
               } 
           }else If ( a.Advanced_Consolidate_Specialty__c == 'Not Deployed'){
              if ( a.Velocity_Specialties_Achieved__c != 'Consolidate' 
                  && a.Velocity_Specialties_Achieved__c == 'Advanced Consolidate' ) {
                       a.Velocity_Specialties_Achieved__c = (tmp_velocityAchived.replace('Advanced Consolidate', ''));
              }   
           }
           
            If ( a.Backup_and_Recovery_Speciality__c == 'Deployed'){
              if ( a.Velocity_Specialties_Achieved__c == 'Backup and Recovery' 
                  || a.Velocity_Specialties_Achieved__c != '' ) {
                    a.Velocity_Specialties_Achieved__c = a.Velocity_Specialties_Achieved__c+'Backup and Recovery;' ;
               } 
           }else If ( a.Backup_and_Recovery_Speciality__c == 'Not Deployed'){
              if ( a.Velocity_Specialties_Achieved__c == 'Backup and Recovery' ) {
                       a.Velocity_Specialties_Achieved__c = (tmp_velocityAchived.replace('Backup and Recovery', ''));
              }   
           }
           
            If ( a.Governance_and_Archive_Specialty__c == 'Deployed'){
              if ( a.Velocity_Specialties_Achieved__c == 'Governance and Archive' 
                  || a.Velocity_Specialties_Achieved__c != '' ) {
                    a.Velocity_Specialties_Achieved__c = a.Velocity_Specialties_Achieved__c+'Governance and Archive;' ;
               } 
           }else If ( a.Governance_and_Archive_Specialty__c == 'Not Deployed'){
              if ( a.Velocity_Specialties_Achieved__c == 'Governance and Archive' ) {
                       a.Velocity_Specialties_Achieved__c = (tmp_velocityAchived.replace('Governance and Archive', ''));
              }   
           }
           /******************Added logic for Isilon Speciality *******************************************/
           If ( a.Isilon_Track_Specialty__c == 'Deployed'){
              if ( a.Velocity_Specialties_Achieved__c == 'Isilon' 
                  || a.Velocity_Specialties_Achieved__c != '' ) {
                    a.Velocity_Specialties_Achieved__c = a.Velocity_Specialties_Achieved__c+'Isilon;' ;
               } 
           }else If ( a.Isilon_Track_Specialty__c == 'Not Deployed'){
              if ( a.Velocity_Specialties_Achieved__c == 'Isilon' ) {
                       a.Velocity_Specialties_Achieved__c = (tmp_velocityAchived.replace('Isilon', ''));
              }   
           }
           /******************End Added logic for Isilon Speciality *******************************************/
           
           If ( a.Cloud_Builder_Practice__c == 'Deployed'){
              if ( a.Velocity_Specialties_Achieved__c == 'Cloud Builder' 
                  || a.Velocity_Specialties_Achieved__c != '' ) {
                    a.Velocity_Specialties_Achieved__c = a.Velocity_Specialties_Achieved__c+'Cloud Builder;' ;
               } 
           }else If ( a.Cloud_Builder_Practice__c == 'Not Deployed'){
              if ( a.Velocity_Specialties_Achieved__c == 'Cloud Builder' ) {
                       a.Velocity_Specialties_Achieved__c = (tmp_velocityAchived.replace('Cloud Builder', ''));
              }   
           }
           
            If ( a.Cloud_Provider_Practice__c == 'Deployed'){
              if ( a.Velocity_Specialties_Achieved__c == 'Cloud Provider' 
                  || a.Velocity_Specialties_Achieved__c != '' ) {
                    a.Velocity_Specialties_Achieved__c = a.Velocity_Specialties_Achieved__c+'Cloud Provider;' ;
               } 
           }else If ( a.Cloud_Provider_Practice__c == 'Not Deployed'){
              if ( a.Velocity_Specialties_Achieved__c == 'Cloud Provider' ) {
                       a.Velocity_Specialties_Achieved__c = (tmp_velocityAchived.replace('Cloud Provider', ''));
              }   
           }
           
           if (a.Velocity_Specialties_Achieved__c != null){
               a.Velocity_Specialties_Achieved__c = ((string)a.Velocity_Specialties_Achieved__c).replace('null', '');
           }
       }
       
       System.debug('a.Velocity_Specialties_Achieved__c===>' +a.Velocity_Specialties_Achieved__c);
      // End Req 2030

       if(trigger.isUpdate && a.IsPartner==true){
         /* if(a.Partner_Type__c != null && a.Partner_Type__c != '' &&
             a.Partner_Type__c != trigger.oldmap.get(a.Id).Partner_Type__c){
             lstAccountsToUpdate.add(a);
          }  */
          Map<Id,Account> TriggerOldMap = new Map<Id,Account>();
          Map<Id,Account> TriggerNewMap = new Map<Id,Account>();
          TriggerOldMap.put(a.Id,Trigger.OldMap.get(a.Id));
          TriggerNewMap.put(a.Id,Trigger.NewMap.get(a.Id));
          if(a.Partner_Type__c != trigger.oldmap.get(a.Id).Partner_Type__c){
             lstAccountsToUpdate.add(a);    
          }
           if(a.BillingCountry !=trigger.oldmap.get(a.Id).BillingCountry){
               lstAccountsToSetCluster.add(a); 
           }
           PRM_PAN_VPP_Operations PANOperations = new PRM_PAN_VPP_Operations();
           PANOperations.syncPANAttributes(TriggerOldMap,TriggerNewMap);
      }    
   }
   if(lstAccountsToUpdate.size()>0){      
      PRMDealRegObj.setNonDistributorDirectResllerFlag(lstAccountsToUpdate);
   }
   if(lstAccountsToSetCluster.size()>0){      
      PRMDealRegObj.populateClusterOnAccount(lstAccountsToSetCluster);
   }
}