/*==================================================================================================================+

 |  HISTORY  |                                                                            

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 | 12/09/2012    Hemavathi N M   204033       Trigger for creating /updating record on Pricing Request Share object on creation/updation of Pricing Request record
       
 | 05/11/2012     Hemavathi N M               DEC RELEASE :: Suppress approval /Rejection notification on escalation                                                                               
 +==================================================================================================================**/

trigger afterInsertUpdateOfPricingRequest on Pricing_Requests__c (after insert, after update,before update , before insert) {

Transformation_PricingShare_Class pricObj = new Transformation_PricingShare_Class();
Pricing_Requests__c priceObj = new Pricing_Requests__c();
list<Pricing_Requests__c> priceLst = new list<Pricing_Requests__c>();
List<Pricing_Requests__c> lstPrc = new List<Pricing_Requests__c>();
List<Pricing_Requests__c> lstPrcOwner = new List<Pricing_Requests__c>();
list<Pricing_Requests__c> pricingLst = new list<Pricing_Requests__c>();
Map<Pricing_Requests__c,String> mapPrcAcceptanceOwner = new Map<Pricing_Requests__c,String> ();
List<Pricing_Requests__c> lstPrcAcceptanceOwner = new List<Pricing_Requests__c>();
list<Pricing_Requests__c> lstPAR = new list<Pricing_Requests__c>();
list<Id> opptyId = new list<Id>();
Map<Id,Id> oldAcceptanceOwner = new Map<Id,Id>();


Boolean isUpdateFlag;
Boolean isReadOnly = false;
Boolean recalledByTier=false;
 string pID;
 String status;

if(trigger.isBefore && trigger.isInsert){
     
    pricObj.updateTheaterField(trigger.new);
  //  pricObj.updateOwnerField(trigger.new);
}

else if(trigger.isBefore && trigger.isUpdate){
    //pricObj.sendForApproval(trigger.new);
    List<Id> lstPrl = new List<Id>();
    for(Pricing_Requests__c prObj : Trigger.new){
      system.debug('trigger.new-->'+prObj.Opportunity_Name__r.Opportunity_Owner__c +'<---->'+prObj.Recalled_Flag__c);
     if((prObj.Opportunity_Name__c!=null && (prObj.Opportunity_Name__c != trigger.oldMap.get(prObj.id).Opportunity_Name__c)) || (prObj.PR_Account_Owner_Theater__c == 'Americas') || (prObj.Recalled_Flag__c == true  && (prObj.Recalled_Flag__c != trigger.oldMap.get(prObj.id).Recalled_Flag__c))){
        lstPrc.add(prObj);
      }
       
      /* if(((prObj.Approval_Status__c =='Approved' || prObj.Approval_Status__c =='Rejected') && prObj.Approval_Status__c != trigger.oldMap.get(prObj.id).Approval_Status__c) || ( prObj.Approval_Status__c =='In Process'&& prObj.APJ_Request_Escalation__c != trigger.oldMap.get(prObj.id).APJ_Request_Escalation__c)) {
      pricingLst.add(prObj);
      }
      */
      
      if(((prObj.Approval_Status__c =='Approved' || prObj.Approval_Status__c =='Rejected') && prObj.Approval_Status__c != trigger.oldMap.get(prObj.id).Approval_Status__c) || ( (prObj.OwnerId == trigger.oldMap.get(prObj.id).OwnerId) && prObj.Approval_Status__c =='In Process' && prObj.APJ_Request_Escalation__c == true)) {
          pricingLst.add(prObj);
          System.debug('Inside owner changed');
      }
    
    //To set the Tier1/Tier2 approver name on PAR acceptance.
     if((prObj.Approval_Status__c == trigger.oldMap.get(prObj.id).Approval_Status__c) && (prObj.OwnerId != trigger.oldMap.get(prObj.id).OwnerId) ) {
            //mapPrcAcceptanceOwner.put(prObj,trigger.oldMap.get(prObj.id).OwnerId);
            lstPrcAcceptanceOwner.add(prObj);
            oldAcceptanceOwner.put(prObj.OwnerId,trigger.oldMap.get(prObj.id).OwnerId);
            System.debug('Tier1/Tier acceptance' + prObj.OwnerId +'<--->'+trigger.oldMap.get(prObj.id).OwnerID);
      }
         
    
    //To get approved data
     
     
      if((prObj.Opportunity_Name__c!=null && (prObj.Opportunity_Name__c != trigger.oldMap.get(prObj.id).Opportunity_Name__c)) ){
        System.debug('Before update be');   
            lstPrl.add(prObj.Id);}
           }
           
           System.debug('update theater lstPrc-->'+lstPrc);
            if(lstPrc.size()>0)
            {
                pricObj.updateTheaterField(lstPrc);
            }
            
            if(pricingLst.size()>0){
                pricObj.updateCommentsApprovalField(pricingLst);}
            if(lstPrl.size()>0){
               Transformation_PricingShare_Class.deleteApprovalUser(lstPrl);
            }
            
            if(lstPrcAcceptanceOwner.size()>0){
                System.debug('lstPrcAcceptanceOwner-->'+lstPrcAcceptanceOwner);
                pricObj.updateAcceptanceOwner(lstPrcAcceptanceOwner,oldAcceptanceOwner);
            }
} // end Else If

if(trigger.isAfter ){
     
    if(trigger.isInsert){
        isUpdateFlag = false;
        List<Id> lstPrl = new List<Id>();
        for(Pricing_Requests__c prObj : Trigger.new){
            //if(prObj.Opportunity_Name__c!=null && (prObj.Opportunity_Name__c != trigger.oldMap.get(prObj.id).Opportunity_Name__c) ){
            lstPrl.add(prObj.Id);//}
        }
        if(lstPrl.size() > 0){
             Transformation_PricingShare_Class.setOpptyOwner(lstPrl);
         }
        pricObj.insertShare(trigger.new,isUpdateFlag,isReadOnly);
        
     }

else if(trigger.isUpdate){
    
   isUpdateFlag = true;
   Map<Id,String> pOwnerName = new Map<Id,String>();
   List<Pricing_Requests__c>  prsLst1 = [Select Id,Owner.Name from Pricing_Requests__c where id in:Trigger.new];
   for(Pricing_Requests__c pObj:prsLst1){
    pOwnerName.put(pObj.Id,pObj.Owner.Name);
   }
   
   for(Pricing_Requests__c prObj : Trigger.new){
      
     String pName=pOwnerName.get(prObj.Id);
     System.debug('pName-->'+pName);
     /*  Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
         req1.setComments('Submitting request for approval.');
         req1.setObjectId(prObj.id);
         Approval.ProcessResult result = Approval.process(req1); 
         System.debug('result-->' +result.isSuccess()) ;
      */
     
     if(prObj.Opportunity_Name__c!=null && (prObj.Opportunity_Name__c != trigger.oldMap.get(prObj.id).Opportunity_Name__c) ){     
      lstPrc.add(prObj);
      }
    
     
       system.debug('prObj.Approval_Status__c-->' + prObj.Tier2_Access__c +'<--->'+ trigger.oldMap.get(prObj.id).Tier2_Access__c);
       System.debug('status--->'+prObj.Approval_Status__c != trigger.oldMap.get(prObj.id).Approval_Status__c );
   
      if((prObj.Approval_Status__c != trigger.oldMap.get(prObj.id).Approval_Status__c && trigger.oldMap.get(prObj.id).Approval_Status__c!='Approved') || prObj.APJ_Request_Escalation__c != trigger.oldMap.get(prObj.id).APJ_Request_Escalation__c ||(prObj.APJ_Request_Escalation__c == true && prObj.Tier2_Access__c == true && prObj.Approval_Status__c =='In Process' && prObj.Tier2_Access__c !=  trigger.oldMap.get(prObj.id).Tier2_Access__c)){
      lstPrcOwner.add(prObj);
      System.debug('Im inside If------------>');
      }
  
   //if(((prObj.Approval_Status__c =='Approved' || prObj.Approval_Status__c =='Rejected') && prObj.Approval_Status__c != trigger.oldMap.get(prObj.id).Approval_Status__c) || (  prObj.Approval_Status__c =='In Process' && trigger.oldMap.get(prObj.id).APJ_Request_Escalation__c == true)) {
    
    System.debug('status--->' + prObj.Approval_Status__c +'<--Old status-->'+trigger.oldMap.get(prObj.id).Approval_Status__c);
   
    if((prObj.Expired_Request__c != null && prObj.Expired_Request__c != trigger.oldMap.get(prObj.id).Expired_Request__c) ||(prObj.Recalled_Flag__c && prObj.Recalled_Flag__c != trigger.oldMap.get(prObj.id).Recalled_Flag__c)||(prObj.APJ_Request_Escalation__c == true && (prObj.APJ_Request_Escalation__c != trigger.oldMap.get(prObj.id).APJ_Request_Escalation__c || pName.contains('Tier2') )) || ((prObj.Approval_Status__c =='Approved' || prObj.Approval_Status__c =='Rejected') && prObj.Approval_Status__c != trigger.oldMap.get(prObj.id).Approval_Status__c)){
          pricingLst.add(prObj);
          recalledByTier=true;
          pID='\'' + prObj.Id + '\'';
          System.debug('Inside owner changed sendEmail for Recall');
      }
     
    }
    if(lstPrc.size()>0){
         System.debug('inside if constion for share');
        pricObj.insertShare(lstPrc,isUpdateFlag,isReadOnly);
    }
    
    if(pricingLst.size()>0){
                System.debug('--- sendEmail----');
                pricObj.sendEmail(pricingLst);
            }
    
    
     if(lstPrcOwner.size()>0)
            {
                pricObj.updateOwnerField(lstPrcOwner);
            }
            
    //To find the owner of the record of PR
    for(Pricing_Requests__c prObj : Trigger.new){
     if((trigger.oldMap.get(prObj.id).OwnerId != prObj.OwnerId && trigger.oldMap.get(prObj.id).OwnerId == trigger.oldMap.get(prObj.id).CreatedById )|| trigger.oldMap.get(prObj.id).OwnerId != prObj.OwnerId )
      {
      //  if(trigger.oldMap.get(prObj.id).Approval_Status__c!='Approved'){   
       priceLst.add(prObj);
     //   }
      }
     }
    if(priceLst.size()>0){
     pricObj.insertOwnerIDShare(priceLst);} 
     
     
     // To Give Edit access
     List<Pricing_Requests__c> pricingList = new List<Pricing_Requests__c>();
     for(Pricing_Requests__c prObj : Trigger.new){
     if((prObj.Approval_Status__c =='Approved' || prObj.Approval_Status__c =='Rejected') && prObj.Approval_Status__c != trigger.oldMap.get(prObj.id).Approval_Status__c) { 
     
     pricingList.add(prObj);
     
     if(prObj.Opportunity_Name__c!=null && (prObj.Opportunity_Name__c == trigger.oldMap.get(prObj.id).Opportunity_Name__c) ){
      lstPrc.add(prObj);
      }
     } 
     }
    if(lstPrc.size()>0){
    pricObj.insertShare(lstPrc,isUpdateFlag,isReadOnly);}
    
    if(pricingList.size()>0){
    isReadOnly = true;
    pricObj.insertShare(pricingList,isUpdateFlag,isReadOnly);}
    }
   
}// end of Isafter
 
  if(trigger.isBefore){
  if(trigger.isUpdate)
    {

     /* Profile profileObj =[Select Id,Name from Profile where id =: UserInfo.getProfileId()];
    if(ProfileObj.Name == System.Label.Transformation_Pricing_User){
       System.debug('Inside the if of priicng user');
       if(Trigger.New[0].Approval_Status__c =='Approved' ){
            if(Trigger.New[0].Approval_FM__c  == null ||  Trigger.New[0].Approved_Deal_Value__c == null || Trigger.New[0].High_Level_Deal_Background__c == null  || Trigger.New[0].Theatre_Pricing_Rationale__c  == null ||  Trigger.New[0].Due_Diligence_Summary__c == null){    
           Trigger.New[0].addError(System.Label.Transformation_Approval_Expiration_Date);
           
        } 
         
      }
       
        if(Trigger.New[0].Approval_Status__c =='Rejected'){
            if(Trigger.New[0].Theatre_Pricing_Rationale__c  == null ||  Trigger.New[0].Due_Diligence_Summary__c == null){    
           Trigger.New[0].addError(System.Label.Transformation_Approval_Status);
           
        } 
         
      }   
     }*/
       
 if((Trigger.New[0].Comparison_to_RFP__c =='Exceeded' || Trigger.New[0].Comparison_to_RFP__c =='Under') && Trigger.New[0].Reasons_for_RFP_deviations_if_any__c == null){
           Trigger.New[0].addError(System.Label.Transformation_Comparison_to_RFP);
          
      } 

List<Id> lstPrl = new List<Id>();
        for(Pricing_Requests__c prObj : Trigger.new){
         if(prObj.Opportunity_Name__c!=null && (prObj.Opportunity_Name__c != trigger.oldMap.get(prObj.id).Opportunity_Name__c) ){
            lstPrl.add(prObj.Id);}
        }
        if(lstPrl.size() > 0){
             Transformation_PricingShare_Class.setOpptyOwner(lstPrl);
         }
         
    }//End isUpdated
   
  }// end is Before
  
    if(trigger.isAfter && trigger.isUpdate){
    Map<Id,Pricing_Requests__c> mapOldPAR = new Map<Id,Pricing_Requests__c>();
    Map<Id,Pricing_Requests__c> mapNewPAR = new Map<Id,Pricing_Requests__c>();
    List<Pricing_Requests__c> parLst =  new List<Pricing_Requests__c>();
    for(Pricing_Requests__c prObj : Trigger.new){
        if(prObj.Approval_Status__c == trigger.oldMap.get(prObj.id).Approval_Status__c && prObj.Approval_Status__c == 'Approved' ){
            mapOldPAR =trigger.oldMap;
            mapNewPAR =trigger.newMap;
            
        }
        if(prObj.Approval_Status__c != trigger.oldMap.get(prObj.id).Approval_Status__c && prObj.Approval_Status__c == 'New' && trigger.oldMap.get(prObj.id).Approval_Status__c == 'Approved' ){
            System.debug('sendemailonstatus--------->');
            parLst.add(prObj);
        }
    }
    if(mapNewPAR.size()>0 && mapOldPAR.size()>0){
    pricObj.checkFieldChange(mapNewPAR , mapOldPAR);
    }
    if(parLst.size()>0)
    pricObj.sendEmailonStatusChange(parLst);
    
  }
  
}// End of Class