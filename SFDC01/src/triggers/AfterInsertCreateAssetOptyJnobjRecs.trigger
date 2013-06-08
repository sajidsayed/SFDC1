/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER           WR          DESCRIPTION                               
 |  ====            =========           ==          =========== 
 |  06.10.2012      Smitha             MOJO        Initial Creation.Trigger for inserting records in Opportunity Asset Junction Object.
 |  27.dec.2012     Krishna Pydavula   212171      To post the Feed items on Opportunity. 
+========================================================================================================================*/

trigger AfterInsertCreateAssetOptyJnobjRecs on Opportunity (after insert) {
    
     //Trigger BYPASS Logic
    if(CustomSettingBypassLogic__c.getInstance()!=null)
    {
      if(CustomSettingBypassLogic__c.getInstance().By_Pass_Opportunity_Triggers__c)
      {
            return;
      }
    }
 
    List<Id> AssetIDs= new List<Id>();
    String strAssetIds;    
    String dataErrs = '';
    Database.Saveresult[] results;
    List<Opportunity_Asset_Junction__c> lstInsertJnObj = new List<Opportunity_Asset_Junction__c>();
    
    for(Opportunity o: Trigger.New)
    {        
        if(o.Asset_Ids__c!=null)
        {
               //Population Value in Asset Id field in opty to a string
               strAssetIds= o.Asset_Ids__c;        
        }     
        if(strAssetIds!=null)
        {
            //Getting comma separated value from string to List of ID.
            AssetIDs= strAssetIds.Split(',');        
        }
        
        for(Id aid :AssetIDs)
        {
            //Creating record in Junciton Object
            Opportunity_Asset_Junction__c jnObj = new Opportunity_Asset_Junction__c();
            jnObj.Related_Asset__c = aid;
            jnObj.Related_Opportunity__c = o.id; 
            jnObj.Related_Account__c=o.accountId;
            lstInsertJnObj.add(jnObj);      
        }        
        system.debug('lstInsertJnObj'+lstInsertJnObj);
        if((lstInsertJnObj!=null)&&(lstInsertJnObj.size() > 0))
        {
            //Inserting records in junction object.             
            results = Database.Insert(lstInsertJnObj, false);   
            SFA_MOJO_OptyLinkDelinkController.Feedpost(o.id);            
        }
        if(results != null && results.size() >0)
        {
            for(Database.SaveResult sr : results)
            {
                if(!sr.isSuccess())
                {   
                    //Looking for errors if any.                
                    for (Database.Error err : sr.getErrors()) {
                        dataErrs += err.getMessage();
                    }
                    System.debug('An exception occurred while attempting an update on ' + sr.getId());
                    System.debug('ERROR: ' + dataErrs);
                }
            }
        }                                              
    }
}