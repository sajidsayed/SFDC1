/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 | 30-July-09  Deepak Kapoor           InstallBaseWrapperClass will be used for any 
                                      delete operation on the install base object as a web service.               
 |                      
 |                                 
 +===========================================================================*/



global class InstallBase_Operations {
    
    
    
        /* deleteInstallBaseRecord will take installbase object as input. 
          This method will delete the records for the provided keycol__c values and returns the array 
          of IB_recordstatus*/

        
        //webservice  List <Delete_Record_Status> Statuslist = new List <Delete_Record_Status>();
        Webservice  static List<Delete_Record_Status> deleteInstallBaseRecord(Install_Base__c[] installBase ){
            List <Delete_Record_Status> Statuslist = new List <Delete_Record_Status>();
                      
            //List <Delete_Record_Status>Statuslist = new InstallBase_Operations().Statuslist;

            Map<String,String> IDnKeycols = new Map<String,String>();
            Set<String> Keycols = new Set<String>();
            String deletedKeyCols='';   

            for (Integer i= 0; i <installBase.size(); i++){
                Keycols.add(installBase[i].Keycol__c);
                
            }
            
            try{  
                // Get the IB records to delete
                for(Install_Base__c[] IBRecords:[Select id,Keycol__c,Family__c,USC_5__c from Install_Base__c where Keycol__c in:Keycols]) {
                        
                        IDnKeycols = new Map<String,String>();        
                        for(Install_Base__c IB:IBRecords){
                            IDnKeycols.put(IB.id,IB.Keycol__c);
                            deletedKeyCols=deletedKeyCols+IB.Keycol__c;
                        }
                                              
                    Database.DeleteResult[] DeletedIBs = Database.delete(IBRecords);
                    // System.debug('DeletedIBs'+DeletedIBs[0]);
                    // Populate the result to return variable 
                    for(Database.DeleteResult result: DeletedIBs ){
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
                                       
            }catch(Exception ex){
               //Add exception to return aaray 
               Delete_Record_Status ExceptionRecord = new Delete_Record_Status();    
               Exceptionrecord.id='';
               Exceptionrecord.issucess=false;
               Exceptionrecord.keycol='';
               Exceptionrecord.errorDescription=ex.getMessage();
               Statuslist.add(ExceptionRecord);
                
            }
            // check keycols are exist in deleted records if not add with false in deleted list
            if(Keycols.size()>IDnKeycols.size()){
                integer keyclos_to_found=Keycols.size()-IDnKeycols.size();
                for(String keycol:Keycols){
                    
                    if(deletedKeyCols.lastIndexOf(keycol)==-1){
                        Delete_Record_Status DeletedObject = new Delete_Record_Status();
                        DeletedObject.id='';
                        DeletedObject.keycol=keycol;
                        DeletedObject.issucess=false;     
                        DeletedObject.errorDescription=System.Label.KeyCol_doesnot_exist;
                        //Elements added into the list.
                        Statuslist.add(DeletedObject);   
                        keyclos_to_found--;

                    }
                    if(keyclos_to_found==0){
                        break;
                    }
                }
            }

           return Statuslist;
     }
    
    
    }