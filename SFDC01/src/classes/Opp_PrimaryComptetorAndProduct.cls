/*======================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR        DESCRIPTION                               
 |  ====          =========                ==        =========== 
 | 27/03/2012    Anand Sharma                        This is used to display Competitive Summary 
 +=====================================================================================================*/
public class Opp_PrimaryComptetorAndProduct {
    public String strDocumentUrl {get;set;}
    public Boolean isUpdated {get;set;}
   
    public Opportunity objOpportunity ;
    
    public Opp_PrimaryComptetorAndProduct(ApexPages.StandardController controller) {
        ID OppId=controller.getRecord().Id;
       
        isUpdated = false;
        strDocumentUrl='';
        objOpportunity = [select id, Competitor__c,Product_Model__c, LastModifiedDate, Competitive_Summary_Mapping__c, Competitive_Summary_Mapping__r.Name, 
                                Competitive_Summary_Mapping__r.Competitive_Summary_URL__c from Opportunity where id =:OppId];
 
        DateTime lastModifiedTime = objOpportunity.LastModifiedDate; 
        if(objOpportunity.Competitor__c != null && objOpportunity.Product_Model__c != null){
            isUpdated = true;                
            // strDocumentUrl ='/servlet/servlet.FileDownload?file='+ objOpportunity.Competitive_Summary_Mapping__r.Competitive_Summary_URL__c;
            if(objOpportunity.Competitive_Summary_Mapping__c != null){
                if(objOpportunity.Competitive_Summary_Mapping__r.Competitive_Summary_URL__c != null && objOpportunity.Competitive_Summary_Mapping__r.Competitive_Summary_URL__c != ''){ 
                    strDocumentUrl = objOpportunity.Competitive_Summary_Mapping__r.Competitive_Summary_URL__c; 
                }
            }                       
        } 
    }    
}