/* =======================================================================================================================
 |  HISTORY 
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION 
 |  22/01/2013      Anirudh Singh   219167      This controller will be used to display the alert on the detailed Product 
 |                                              Page when the Total Competency ($) is updated. 
  =========================================================================================================================  */
 public class EMCC_Total_Competency_Alert_Controller {
     public boolean showCompetencyAlert{get;set;} 
     Detailed_Product__c detailedProdRecord = new Detailed_Product__c();
     public EMCC_Total_Competency_Alert_Controller(ApexPages.StandardController controller){
         showCompetencyAlert = false;
         Id detailProdId = ApexPages.currentPage().getParameters().get('Id');
         System.Debug('DetailProId--->' +detailProdId );
         detailedProdRecord = [Select Id,CreatedDate,LastModifiedDate,Opportunity__r.Consulting_Forecast__c,Total_Competency__c,Is_Total_Competency_Updated__c from Detailed_Product__c
                                                   where id =: detailProdId];
         System.Debug('detailedProdRecord --->' +detailedProdRecord);                                          
         Id userCurrentUserId = userInfo.getUserId(); 
         User userObj = [Select Id,Profile.Name from user where id =: userCurrentUserId];
         if(detailedProdRecord.CreatedDate.addseconds(15) > System.Now().addseconds(10) && detailedProdRecord.Is_Total_Competency_Updated__c
           && detailedProdRecord.Total_Competency__c != detailedProdRecord.Opportunity__r.Consulting_Forecast__c && userObj.Profile.Name =='EMC Consulting User'){
            showCompetencyAlert = true; 
         } 
         if(detailedProdRecord.LastModifiedDate.addseconds(15) > System.Now().addseconds(10)  && detailedProdRecord.Is_Total_Competency_Updated__c
            && detailedProdRecord.Total_Competency__c != detailedProdRecord.Opportunity__r.Consulting_Forecast__c && userObj.Profile.Name =='EMC Consulting User'){
            showCompetencyAlert = true; 
         }                                        
     }
 
 }