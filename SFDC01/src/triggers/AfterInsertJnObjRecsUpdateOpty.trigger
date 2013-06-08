/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  17.10.2012      Smitha       MOJO        Initial Creation. To update Assetid field in Opportunity.
+========================================================================================================================*/

trigger AfterInsertJnObjRecsUpdateOpty on Opportunity_Asset_Junction__c (after insert) {        
    
    if(!Util.blnUpdateAssetId)
    {       
        Util.blnUpdateAssetId = true;
        Set<Id> optyToUpdate = new Set<Id>();
        List<Opportunity> lstQueryOpty = new List<Opportunity>();
        List<Opportunity> lstUpdateOpty = new List<Opportunity>();
        String dataErrs = '';
        Database.Saveresult[] results;   
        
        for(Opportunity_Asset_Junction__c jnObj : Trigger.New)
        {
            if(jnObj.Related_Opportunity__c!=null)
            {
                optyToUpdate.add(jnObj.Related_Opportunity__c);
            }
        }
                        
        if((optyToUpdate!=null)&&(optyToUpdate.size() > 0))
        {
            lstQueryOpty = [Select name,id,accountId,RecordTypeId,Asset_Ids__c from opportunity where id in :optyToUpdate];             
            for(Opportunity opty : lstQueryOpty)
            {
                if(opty.Asset_Ids__c!=null)
                {
                    opty.Asset_Ids__c = null;
                    lstUpdateOpty.add(opty);
                }
            }
                                            
            if((lstUpdateOpty!=null)&&(lstUpdateOpty.size() > 0))
            {
                results = Database.Update(lstUpdateOpty, false);
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

}