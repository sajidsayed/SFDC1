public class DetailPageAsset {

   // public DetailPageAsset(ApexPages.StandardController controller) {
   set<Id> assetId= new set<Id>();
private List<Asset__c> oppz;
    private Opportunity oppty; 
    public DetailPageAsset(ApexPages.StandardController controller) {
        this.oppty= (Opportunity)controller.getRecord();
    }
    public List<Asset__c> getOppz()
    {
        List<Opportunity_Asset_Junction__c> oppAstJunc= [Select id, Related_Opportunity__c,Related_Asset__c,Related_Account__c FROM Opportunity_Asset_Junction__c where Related_Opportunity__c= :oppty.id];
        if (oppAstJunc == null)
        {
         return null;
         }
         else if(oppAstJunc!=null && oppAstJunc.size()>0)
         {
             for(Opportunity_Asset_Junction__c opAsJt:oppAstJunc)
             {
                 assetId.add(opAsJt.Related_Asset__c);
             }
         }
        oppz = [Select Total_Raw_Capacity_GB__c, Swap_Value__c, Product_Name_Vendor__c, Name, Id, Configuration_Details__c From Asset__c where id in :assetId];
        return oppz;
    }
 }