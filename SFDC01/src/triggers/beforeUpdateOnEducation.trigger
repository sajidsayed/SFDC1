/*=======================================================================================
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      ===========          
 |  20.12.2010      Anand Sharma                This trigger will be called on 
 |                                               updation of Opportunity 
 |   04.02.2011      Prasad Kothawade            Populate the field Batch job operation
 |   28 Nov 2012     Prasad Kothawade            Added condition to before calling populateCertId 
 |                                               to avoid errors and extra calls
=========================================================================================*/
trigger beforeUpdateOnEducation on Education__c (before update) {
    
    List<Education__c> EduToPopulateCertIds = new  List<Education__c>(); 
    for(Education__c edu :Trigger.new){
        if(edu.Education_Master__c != Trigger.oldMap.get(edu.Id).Education_Master__c) {
             edu.Batch_Job_Operation__c='Eduation Master Updated';    
        }
        if(edu.Cert_ID__c != Trigger.oldMap.get(edu.Id).Cert_ID__c || 
           edu.Contact__c!= Trigger.oldMap.get(edu.Id).Contact__c ||
           edu.Email__c != Trigger.oldMap.get(edu.Id).Email__c){
               EduToPopulateCertIds.add(edu);
        }
    }
    
    if(EduToPopulateCertIds.size()>0){
         //call method populateCertTrackerContactIDOnContact of PRM_EducationHelper class to
            // populate Certractcontactid on Contact record.
            PRM_EducationHelper.populateCertTrackerContactIDOnContact(EduToPopulateCertIds);
    }
}