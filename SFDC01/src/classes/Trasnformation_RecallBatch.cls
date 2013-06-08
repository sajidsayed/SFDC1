global  class Trasnformation_RecallBatch implements Database.Batchable<sObject>, Schedulable { 
  
    global String Query;
    global List<Pricing_Requests__c> lstPAR;
    global List<Id>  lstId =new List<Id>();
     global List<String>  lstComments =new List<String>();
     

    global Database.QueryLocator start(Database.BatchableContext BC){
              return Database.getQueryLocator(query); 
                }          
    global Trasnformation_RecallBatch(String query){
           this.Query = query; 
           system.debug('RecallBatch----> :' + query );  
        }
        
    global void execute(Database.BatchableContext BC, SObject[] scope){ 
            recall(scope); 
        }
    global Trasnformation_RecallBatch (){
     }
    global void recall(sObject[] pWRId){ 
        System.debug('pWRId--->'+pWRId);
       for(SObject  sobj : pWRId){
            lstPAR = new List<Pricing_Requests__c>();
            Pricing_Requests__c cWObj = (Pricing_Requests__c)sobj;
         //   System.debug('cWObj--->'+cWObj); 
            lstPAR.add(cWObj);
            lstId.add(cWObj.Id);
            lstComments.add(cWObj.Recall_Comments__c);
           
           
          }
         System.debug('lstPAR--->'+lstPAR);
         System.debug('lstId-->'+lstId);
        //    List<ProcessInstanceWorkitem>  workitem = new List<ProcessInstanceWorkitem>([select Id, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = : lstPAR[0].id and  ProcessInstance.status= 'Pending']);
            List<ProcessInstanceWorkitem>  workitem = new List<ProcessInstanceWorkitem>([select Id, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in: lstId and  ProcessInstance.status= 'Pending']);
            system.debug('workitem--->'+workitem);
            System.debug('lstPAR--->'+lstPAR);
            List<Approval.ProcessWorkItemRequest> lstPwr = new  List<Approval.ProcessWorkItemRequest>();
           
    
                if (workitem.size()>0)
                   {
					for(Integer i=0;i < workitem.size() ; i++){
						 Approval.ProcessWorkItemRequest pwr = new Approval.ProcessWorkItemRequest();
                          pwr.setWorkitemId(workitem[i].id);
                          pwr.setComments(lstComments[i]);
                          pwr.setAction('Removed'); 
                          System.debug('pwr--->'+pwr);
                          lstPwr.add(pwr);
                         
                   }
                    List<Approval.ProcessResult>  pr = Approval.process(lstPwr);  
                   }    
          } 
          
          
 global void execute(SchedulableContext sc){
     system.debug('INSIDE BatchDeleteData - execute(schedulable)###'); 
    
       string schquery = 'select Name,Owner.Name,Recall_Comments__c from Pricing_Requests__c where Recalled_Flag__c=true' ;
        
       this.Query = schquery ;
       try{
   			  database.executebatch( new Trasnformation_RecallBatch(Query) );
   				 } catch(Exception e) {
   			   system.debug('Exception Inside Account Auditing()' + e );   
   			  }
   } //end of schedule job
          global void finish(Database.BatchableContext BC){   }   
             
}