/*================================================================================================================================================+
 |  HISTORY  |
 |  DATE          DEVELOPER               WR                        DESCRIPTION 
 |  ====          =========               ==                        =========== 
 | 24 Jan 2013    Anirudh Singh          219168                     This Test Class is used to unit Test EMC_Consulting Classes          
 +===========================================================================================================================================================*/
 
@isTest(SeeAllData=true)
private class EMC_Consulting_TC {
/*@Method <This method will be used to unite Test EMC consulting functionality>
@param <This method is not taking any input parameters>
@return <void> - <Not Returning anything>
@throws exception - <No Exception>
*/
    Private static testMethod void EMC_Consulting_Operations(){
        user EMCConsultingUser = [Select id from User where Profile.Name = 'EMC Consulting User' and IsActive=True limit 1];
        Opportunity Opp= new Opportunity();
        System.runas(EMCConsultingUser){
            opp = [Select Id from opportunity limit 1];
        }
        
        
        
        Detailed_Product__c detailProdObj = new Detailed_Product__c();
        decimal affinityPartner = 50;
        detailProdObj.Percent_Delivered_Affinity__c = 50;
        detailProdObj.Affinity_Partners__c = 'None';
        detailProdObj.Sub_Practice_1__c = 'AADD-Appl Devel & Integration';
        detailProdObj.Sub_Practice_1_Dollar__c = 100.00;
        detailProdObj.Sub_Practice_2__c = 'AADD-Appl Devel & Integration';
        detailProdObj.Sub_Practice_2_Dollar__c = 100.00;
        detailProdObj.Sub_Practice_3__c = 'AADD-Appl Devel & Integration';
        detailProdObj.Sub_Practice_3_Dollar__c = 100.00;
        detailProdObj.Sub_Practice_4__c = 'AADD-Appl Devel & Integration';
        detailProdObj.Sub_Practice_4_Dollar__c = 100.00;
        detailProdObj.Sub_Practice_5__c = 'AADD-Appl Devel & Integration';
        detailProdObj.Sub_Practice_5_Dollar__c = 100.00;
        detailProdObj.Identified_Oppty__c ='EMC';
        detailProdObj.Opportunity__c = opp.Id;
        detailProdObj.Start_Date__c = System.Now().Date();
        System.runas(EMCConsultingUser){
         Insert detailProdObj;
         }      
        PageReference pageRef = Page.EMCC_Total_Competency_Alert;
        pageRef.getParameters().put('Id', detailProdObj.id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(detailProdObj);
        System.runAs(EMCConsultingUser){
          EMCC_Total_Competency_Alert_Controller emcConsultingController = new EMCC_Total_Competency_Alert_Controller(stdCon);
        }
        detailProdObj.Sub_Practice_1_Dollar__c =200;
        Update detailProdObj;
        ApexPages.StandardController stdCon1 = new ApexPages.StandardController(detailProdObj);
        System.runAs(EMCConsultingUser){
            EMCC_Total_Competency_Alert_Controller emcConsultingController = new EMCC_Total_Competency_Alert_Controller(stdCon1);
        }         
    }   
}