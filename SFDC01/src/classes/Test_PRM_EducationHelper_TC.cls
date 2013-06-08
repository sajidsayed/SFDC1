/*


Modified By     :   Avinash K
Modified Date   :   30 May 2012
Purpose         :   To increase the coverage for "beforeUpdateOnEducation" trigger.

*/


@isTest
private class Test_PRM_EducationHelper_TC {
   
   
    static testMethod void unitTestContactIDOnContact() { 
         User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];    
         System.runAs(insertUser){
           PRM_VPP_JobDataHelper.createVPPCustomSettingData();
         }      
        List<Education__c> lstEdu = new List<Education__c>();        
        Education__c objEdu = new Education__c();
        objEdu.Cert_ID__c ='1111111A123'; 
        lstEdu.add(objEdu);        
        insert lstEdu;      
            
        lstEdu.get(0).Cert_ID__c = 'A12345123';
        
//Avinash's code begins..
        Education_Master__c em = new Education_Master__c();
        insert em;
        
        lstEdu.get(0).Education_Master__c = em.id;
        
//Avinash's code ends.
                
        update lstEdu;      
        
    }
}