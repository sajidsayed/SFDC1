/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 | 20-Aug-09  Ashwini Gowda           EMCContracts_Operations Class will be used for any 
                                      delete operation on the EMC Contracts object as a web service.               
 | 4 June 10  Arif                    Adding this class in new package.                    
 |                                 
 +===========================================================================*/

global class EMCContracts_Operations
{  
    /* deleteEMCContractsRecord will take installbase object as input. 
      This method will delete the records for the provided keycol__c values and returns the array 
      of Delete_Record_Status*/
      
    Webservice  static List<Delete_Record_Status> deleteEMCContractsRecord(EMC_Contracts__c[] emcContracts)
    {
        List <Delete_Record_Status> Statuslist = new List <Delete_Record_Status>();                      
        Map<String,String> IDnKeycols = new Map<String,String>();
        Set<String> Keycols = new Set<String>();
        String deletedKeyCols='';   
        for (Integer i= 0; i <emcContracts.size(); i++)
        {
            Keycols.add(emcContracts[i].Keycol__c);            
        }
            
        try
        {         
            // Get the EMC Contracts records to delete
            for(EMC_Contracts__c[] EMCContractsRecords:[Select id,KeyCol__c from EMC_Contracts__c where Keycol__c in:Keycols])
            {            
                IDnKeycols = new Map<String,String>();        
                for(EMC_Contracts__c EMC:EMCContractsRecords)
                {
                    IDnKeycols.put(EMC.id,EMC.Keycol__c);
                    deletedKeyCols=deletedKeyCols+EMC.Keycol__c;
                }
                                              
                Database.DeleteResult[] DeletedEMCContracts = Database.delete(EMCContractsRecords);
                    
                // Populate the result to return variable 
                for(Database.DeleteResult result: DeletedEMCContracts )
                {
                    System.debug('DR_Dels.getID()'+result.getID());
                    System.debug('DR_Dels.getID(ReturnResultCounter)'+result.isSuccess());                
                    Delete_Record_Status DeletedObject = new Delete_Record_Status();
                    DeletedObject.id=result.getID();
                    DeletedObject.keycol=IDnKeycols.get(result.getID());
                    DeletedObject.issucess=result.isSuccess();   
                    List<Database.Error> errors=result.getErrors();
                        if(!DeletedObject.issucess && errors.size()>0){   
                           DeletedObject.errorDescription=(result.getErrors().get(0)).getMessage();
                        }  
                    
                    //Elements added into the list.
                    Statuslist.add(DeletedObject); 
                   }                  
                    
                }
                                       
            }
            catch(Exception ex)
            {
              //Add exception to return aaray 
               Delete_Record_Status ExceptionRecord = new Delete_Record_Status();    
               Exceptionrecord.id='';
               Exceptionrecord.issucess=false;
               Exceptionrecord.keycol='';
               Exceptionrecord.errorDescription=ex.getMessage();
               Statuslist.add(ExceptionRecord);      
            }
            // check keycols are exist in deleted records if not add with false in deleted list
            if(Keycols.size()>IDnKeycols.size())
            {
                integer keycols_to_found=Keycols.size()-IDnKeycols.size();
                for(String keycol:Keycols)
                {                    
                    if(deletedKeyCols.lastIndexOf(keycol)==-1)
                    {
                        Delete_Record_Status DeletedObject = new Delete_Record_Status();
                        DeletedObject.id='';
                        DeletedObject.keycol=keycol;
                        DeletedObject.issucess=false;     
                        DeletedObject.errorDescription='KeyCol does not exist in SFDC';
                        //Elements added into the list.
                        Statuslist.add(DeletedObject);   
                        keycols_to_found--;

                    }
                    if(keycols_to_found==0)
                    {
                        break;
                    }
                }
            }

           return Statuslist;
     }
  
}