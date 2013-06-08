/*======================================================================================================+
 
 |  DATE 			DEVELOPER				WR/Req			DESCRIPTION 
 |  10-08-2012		Avinash Kaltari			201030			This is used to display Alliance Engagement Mapping Document URL 
 
 +=====================================================================================================*/
public class Opp_AllianceEngagementMapping {
    public String strDocumentUrl {get;set;}
    public Boolean isUpdated {get;set;}
   
    public Opportunity objOpportunity ;
    
    public Opp_AllianceEngagementMapping(ApexPages.StandardController controller) {
        ID OppId=controller.getRecord().Id;
       
        isUpdated = false;
        strDocumentUrl='';
        objOpportunity = [select id, Primary_Alliance_Partner__c, LastModifiedDate, Alliance_Engagement_Document__c, Alliance_Engagement_Document__r.Name, 
                                Alliance_Engagement_Document__r.Alliance_Engagement_URL__c from Opportunity where id =:OppId];
 
        DateTime lastModifiedTime = objOpportunity.LastModifiedDate; 
        
        if(objOpportunity.Primary_Alliance_Partner__c != null)
        {
            isUpdated = true;                
            if(objOpportunity.Alliance_Engagement_Document__c != null)
            {
                if(objOpportunity.Alliance_Engagement_Document__r.Alliance_Engagement_URL__c != null && objOpportunity.Alliance_Engagement_Document__r.Alliance_Engagement_URL__c != '')
                { 
                    strDocumentUrl = objOpportunity.Alliance_Engagement_Document__r.Alliance_Engagement_URL__c; 
                }
            }                       
        } 
    }    
}