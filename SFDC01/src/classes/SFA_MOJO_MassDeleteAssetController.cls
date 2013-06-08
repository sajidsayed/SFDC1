/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  21.09.2012      Avinash K       MOJO        Initial Creation.Creating this class to Mass Delete the selected Asset
                                                object records and pass the appropriate error message wrt the result
+========================================================================================================================*/


public class SFA_MOJO_MassDeleteAssetController 
{
    //lstSelectedAssets: List of Assets that are selected from Asset List before clicking on "Delete"
    public List<Asset__c> lstSelectedAssets = new List<Asset__c>();
    
    // lstErroneousAssets: List of Assets that could not be deleted either due to DML Exception or they being 
    // linked to an Opportunity
    public List<Asset__c> lstErroneousAssets {get;set;} {lstErroneousAssets = new List<Asset__c>();}
    
    // lstDeletionAssets: List of Assets that are to be deleted (the ones that are not linked to any Opportunity)
    public List<Asset__c> lstDeletionAssets = new List<Asset__c>();

    // mapIdAsset: Map of Asset Ids and records that are being deleted
    public Map<Id, Asset__c> mapIdAsset = new Map<Id, Asset__c>();

    // 3 integer variables to hold the no. of records deleted successfully & not deleted
    public Integer intSuccessCount {get;set;} {intSuccessCount = 0 ;}
    public Integer intFailureCountDeletionCriteria {get;set;} {intFailureCountDeletionCriteria = 0;}
    public Integer intFailureCountDMLError {get;set;} {intFailureCountDMLError = 0;}

    // lstDeletedAssetNames: String List to contain the names of the deleted Assets
    public List<String> lstDeletedAssetNames {get;set;} {lstDeletedAssetNames = new List<String>();}

    public List<String> lstDeletedAssetCustomName {get;set;} {lstDeletedAssetCustomName = new List<String>();} 

    public Database.DeleteResult[] results;
    public Set<Id> setAssetIds = new Set<Id>();

    public Map<Id, List<Database.Error>> mapAssetError = new Map<Id, List<Database.Error>>();

    public SFA_MOJO_MassDeleteAssetController(ApexPages.StandardSetController controller)
    {
//system.debug('#### Inside controller');
        lstSelectedAssets = controller.getSelected();
        
        for (Asset__c a : lstSelectedAssets) 
        {
//system.debug('#### Inside first for loop... Asset ID :: '+a.id);
            setAssetIds.add(a.id);
        }


//system.debug('#### Limits.getHeapSize() BEFORE nested Query :: '+Limits.getHeapSize());
//system.debug('#### Limits.getLimitHeapSize() BEFORE nested Query :: '+Limits.getLimitHeapSize());

        // Querying the list of Asset records that are selected by the user (to get values of fields like Disposition Status
        // & Related Opportunity)
        lstSelectedAssets = [Select id, name, Custom_Asset_Name__c, Disposition_Status__c,
                            (select name from Opportunity_Asset_Junction__r where Opportunity_Forecast_Status__c <> 'Closed' limit 50000)
            From Asset__c
            Where id in :setAssetIds
            Order By Name ASC
            Limit 50000];


//system.debug('#### Limits.getHeapSize() AFTER nested Query :: '+Limits.getHeapSize());
//system.debug('#### Limits.getLimitHeapSize() AFTER nested Query :: '+Limits.getLimitHeapSize());


        // Populating the Lists of Assets that to be deleted and that are erroneous
        if (lstSelectedAssets != null && lstSelectedAssets.size() > 0) 
        {
            for (Asset__c a : lstSelectedAssets) 
            {
//system.debug('#### Inside the second FOR loop');

                if((a.Opportunity_Asset_Junction__r.size() != 0 && a.Disposition_Status__c == 'Installed') ||
                    (a.Opportunity_Asset_Junction__r == null || a.Opportunity_Asset_Junction__r.size() == 0))
                {
                    mapIdAsset.put(a.id,a);
                    lstDeletionAssets.add(a);
                }
                else
                {
                    lstErroneousAssets.add(a);
                    intFailureCountDMLError++;
                }
            }
        }

        // Adding page message in case there are any Assets that linked to an Opportunity and are not in "Installed" Status
        if(intFailureCountDMLError != 0)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Mass_Asset_Delete_Error_Message);
            ApexPages.addMessage(msg);
        }

    }

        
    

/*
DeleteAssets() method does the delete operation on Seleted assets and does a partial rollback in case of DML Exceptions on
any Asset records
*/
    public void DeleteAssets()
    {
//system.debug('#### Inside delete assets method');

        if (lstDeletionAssets != null && lstDeletionAssets.size() > 0) 
        {
            results = Database.Delete(lstDeletionAssets, false);
        }

        // Counting the successfully deleted Assets
        if (results != null && results.size() > 0)
        {
            for (Database.DeleteResult sr: results) 
            {
                if(!sr.isSuccess())
                {
                    mapAssetError.put(sr.getId(),sr.getErrors());
                    intFailureCountDeletionCriteria++;
                    lstErroneousAssets.add(mapIdAsset.get(sr.getId()));
                }
                else
                {
                    intSuccessCount++;
                    lstDeletedAssetNames.add(mapIdAsset.get(sr.getId()).Name);
                    lstDeletedAssetCustomName.add(mapIdAsset.get(sr.getId()).Custom_Asset_Name__c);
                }
            }
                
        }

        //Adding a page message if there are any DML Exceptions while deleting Assets
        if(intFailureCountDeletionCriteria != 0)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Mass_Asset_Delete_DML_Error_Message);
            ApexPages.addMessage(msg);
        }
    }
}