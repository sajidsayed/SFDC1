/*=====================================================================================================================================

 |  HISTORY  |                                                                            

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 
   07/02/2012    Medhavi D.      213789    To check the recovery oppty is associated with PAR.If it is associated, throw an error.
======================================================================================================================================*/
public  class Transformation_recovery_oppty {


//Method : to check the association of new Recovery oppty with PAR. If the association found ,throw an error.
public void validateOpptyExistance(List<Recovery_Opportunity__c> lstRecvOppty){
    List<Id> opptyId = new List<Id>();
    List<Recovery_Opportunity__c> lstROppty = new List<Recovery_Opportunity__c>();
    if(lstRecvOppty.size()>0){
        for(Recovery_Opportunity__c rObj :lstRecvOppty){
           if(rObj.Opportunity_Name__c != null){
               opptyId.add(rObj.Opportunity_Name__c);
            }
          }//End of For
       }    
     
     if(opptyId.size()>0){
     lstROppty = [Select Id ,Opportunity_Name__c from Recovery_Opportunity__c where Opportunity_Name__c in: opptyId];
     }
    
     if(lstROppty.size()>0){
        lstRecvOppty[0].addError(System.Label.Transformation_OpptyAlreadyExists);
      }
    
    
    
    
    
}//end of method

//Method : To remove all Revovery oppty from PAR when Parent Oppty is closed 
public void removeRecoveryOppty(List<Opportunity> lstOppty){
    List<Id> lstId = new List<Id>();
    List<Recovery_Opportunity__c> lstROppty = new List<Recovery_Opportunity__c>();
    List<Pricing_Requests__c> priceReqLst = new List<Pricing_Requests__c>();
    if(lstOppty.size()>0){
        for(Opportunity opptyObj :lstOppty){
           if(opptyObj.StageName == 'Closed'){
               lstId.add(opptyObj.Id);
            }
          }//End of For
       }
     if(lstId.size()>0){
     priceReqLst = [Select Id,Opportunity_Name__c from Pricing_Requests__c where Opportunity_Name__c in:lstId];
     System.debug('priceReqLst----------->'+priceReqLst);
     }      
    
     
     if(priceReqLst.size()>0){
     lstROppty = [Select Id,Opportunity_Name__c,Pricing_Approval_ID__c from Recovery_Opportunity__c where Pricing_Approval_ID__c in: priceReqLst];
     System.debug('lstROppty!!------->'+lstROppty);
     }
     
     if(lstROppty.size()>0){
     	delete lstROppty;
     	System.debug('Deleted---->'+lstROppty);
     }
      
    
}//end of method


}//end of class