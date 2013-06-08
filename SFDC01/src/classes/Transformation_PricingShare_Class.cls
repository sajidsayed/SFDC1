/*==================================================================================================================+

 |  HISTORY  |                                                                             

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  12/09/2012    Hemavathi N M   204033     This class is used for Pricing Requests Sharing for Accoount owner and parent child Sharing  
  
 |  05/11/2012    Hemavathi N M              DEC RELEASE :: Suppress approval /Rejection notification on escalation
 
 |  03/12/2012    Medhavi D.                 JAN RELEASE :: Updating divison field with Oppty account owner.      
 
 |  08/04/2013    Hemavathi N M              MAY RELEASE :: Created new method updateApprovalStatus to update approval status
                                                            field on update of fields on PAR/Oppty page.                
 +==================================================================================================================**/
global class Transformation_PricingShare_Class
{
 
 public List<Pricing_Requests__c> prLst = new List<Pricing_Requests__c>();
 public Static Boolean isApproved = false;
 public Static Boolean isOwnerApproved = false;
 public Static Boolean isProcessed = false;
 public Static Boolean isStatusFlipped = false;
 public Static Id tOwnerId;
//Method: to insert / update Records into Pricing Requests Share Object 
 public void insertShare(List<Pricing_Requests__c> prsLst ,Boolean isUpdateFlag , Boolean isReadOnly )
  {
    System.debug('isUpdateFlag--->'+isUpdateFlag +'<---->'+isReadOnly);
    List<Pricing_Requests__Share> priceList = new list<Pricing_Requests__Share>();
    List<Pricing_Requests__Share> priList = new List<Pricing_Requests__Share>();
    Map<Id,Id> mapPRLst = new Map<Id,Id>();
    prLst =[Select id,CreatedById,Recalled_Flag__c,ownerId,LastModifiedById, Opportunity_Name__r.Opportunity_Owner__c from Pricing_Requests__c where id IN: prsLst];
 
     if(prLst.size() >0){ 
        for(Pricing_Requests__c priceObj : prLst){
            if(priceObj.Opportunity_Name__r.Opportunity_Owner__c != UserInfo.getUserId() || priceObj.Opportunity_Name__r.Opportunity_Owner__c != priceObj.CreatedById ){
               mapPRLst.put(priceObj.id ,priceObj.Opportunity_Name__r.Opportunity_Owner__c);
              }//end of if
           
    }//End of For
       System.debug('mapPRLst--->'+mapPRLst);     
  //To delete records from share object to update with new user/groupId
    
    if(isUpdateFlag == true && mapPRLst.size()>0){
        priceList = [Select UserOrGroupId, ParentId, LastModifiedById,Id, AccessLevel,RowCause  From Pricing_Requests__Share where AccessLevel != 'All' and ParentId IN: mapPRLst.KeySet() and RowCause!='Rule'];
         System.debug('delete priceList--->'+priceList);
          if(priceList.size() > 0)
            {
                delete priceList;
            }
        }
  
  //To give Edit access to Oppty Owner 
   for(Id prObj : mapPRLst.KeySet() )
    {
      Pricing_Requests__Share pobj = new Pricing_Requests__Share();
    
      pobj.UserOrGroupId = mapPRLst.get(prObj) ;
      pobj.AccessLevel='Edit' ;
      pobj.ParentId = prObj;
      System.debug('Inside for loop----');
       // To insert the old Owner into Sharing
      priList.add(pobj);
    }
    System.debug('priList--->'+priList);
    if(priList.size()>0)
     insert priList;
     
     //To give access to the creator after approval of the record.As creator will be having Read access once submitted for approval. 
    if(isReadOnly){
   
    List<Pricing_Requests__Share> preqLst = new List<Pricing_Requests__Share>();
    for(Pricing_Requests__c pricObj : prLst )
     {
      Pricing_Requests__Share pobj = new Pricing_Requests__Share();
    
      pobj.UserOrGroupId = pricObj.CreatedById ;
      pobj.AccessLevel='Edit' ;
      pobj.ParentId = pricObj.Id;
     
       
      preqLst.add(pobj);
     }
     if(preqLst.size()>0)
     insert preqLst;

    }
    
   }//end of If Size
 }//end of method
  

//Method : to insert the owner of record
public void insertOwnerIDShare(List<Pricing_Requests__c> prsLst )
  {
    List<Pricing_Requests__Share> priList = new List<Pricing_Requests__Share>();
    List<Pricing_Requests__Share> priceList = new list<Pricing_Requests__Share>();
    List<Pricing_Requests__Share> preqLst = new List<Pricing_Requests__Share>();
    
    
   // prLst =[Select id,CreatedById,OwnerId,Opportunity_Name__r.Opportunity_Owner__c,Recalled_Flag__c from Pricing_Requests__c where id IN: prsLst];
   Map<ID,Pricing_Requests__c> priceMap = new Map<ID,Pricing_Requests__c>([Select id,Approval_Status__c,CreatedById,OwnerId,Opportunity_Name__r.Opportunity_Owner__c,Recalled_Flag__c from Pricing_Requests__c where id IN: prsLst]);
    System.debug('priceMap---->'+priceMap);
  
    priceList = [Select UserOrGroupId, ParentId, LastModifiedById,Id, AccessLevel,RowCause  From Pricing_Requests__Share where AccessLevel = 'All' and UserOrGroupId =: UserInfo.getUserId()];
 //  List<Pricing_Requests__Share>  priceList1 = [Select UserOrGroupId, ParentId, LastModifiedById,Id, AccessLevel,RowCause  From Pricing_Requests__Share where ParentId in: prLst];
   //System.debug('PriceList1-------->'+priceList1);
   
    // To give read access to Oppty owner after request is submitted for approval process.
  // if(priceList.size() == 0){
    Map<Id,Id> mapPR = new Map<Id,Id>();
    if(!priceMap.isEmpty()){ 
  /*   for(Pricing_Requests__c priceObj : prLst){
      
            if(priceObj.Opportunity_Name__r.Opportunity_Owner__c != UserInfo.getUserId() || priceObj.Opportunity_Name__r.Opportunity_Owner__c != priceObj.CreatedById ){
               if(priceObj.Recalled_Flag__c == false){
                    mapPR.put(priceObj.id ,priceObj.Opportunity_Name__r.Opportunity_Owner__c);
               }
              }//end of if
  
    
    }//End of For*/
  //     System.debug('mapPR in owenrId share-->'+mapPR);  
    //if(mapPR.size()>0){
    
    for(Pricing_Requests__c prObj : priceMap.values() )
    {
    
         //if(prObj.Opportunity_Name__r.Opportunity_Owner__c != UserInfo.getUserId() || prObj.Opportunity_Name__r.Opportunity_Owner__c != prObj.CreatedById ){//IF 1
          if(prObj.Opportunity_Name__r.Opportunity_Owner__c != prObj.CreatedById ){//IF 1
               if(prObj.Recalled_Flag__c == false){ //IF 2
      Pricing_Requests__Share pobj = new Pricing_Requests__Share();
    
      pobj.UserOrGroupId = prObj.Opportunity_Name__r.Opportunity_Owner__c ;
      if(prObj.Approval_Status__c=='New')
             pobj.AccessLevel='Edit' ;
      else
           pobj.AccessLevel='Read' ;


      pobj.ParentId = prObj.id;
    
       // To insert the old Owner into Sharing
      preqLst.add(pobj);
               }//End of IF1
         } //End of IF2

              
    } 
    
  //  } 
    if(preqLst.size()>0)     
     System.debug('preqLst--->'+preqLst);
     insert preqLst;    
     
  //To give read access to creator after request is submitted for approval process.
   for(Pricing_Requests__c pricObj : priceMap.values() )
    {
    if(pricObj.Recalled_Flag__c == false){
      Pricing_Requests__Share pobj = new Pricing_Requests__Share();
    if(pricObj.OwnerId != pricObj.CreatedById){
      pobj.UserOrGroupId = pricObj.CreatedById ;
      pobj.AccessLevel='Read' ;
      pobj.ParentId = pricObj.Id;
   
      priList.add(pobj);
    }
    }
    }
    insert priList;
    
    }     
  // }//end of If Size
  } // end of method

//Method : to update Pricing Requests share object when oppty owner is changed
  public void updateShare( list<Id> oldId , List<Opportunity> oppLst)
  {
    
    prLst =[Select id, Opportunity_Name__r.Opportunity_Owner__c,CreatedById from Pricing_Requests__c where Opportunity_Name__c IN: oppLst];
 
    List<Pricing_Requests__Share > pricList = new list<Pricing_Requests__Share >();
    List<Pricing_Requests__Share > newpricList = new list<Pricing_Requests__Share >();
    Map<Id,Id> mapOppLst = new Map<Id,Id>();
 
    for(Pricing_Requests__c priceObj : prLst){
      if(priceObj.Opportunity_Name__r.Opportunity_Owner__c != UserInfo.getUserId() || priceObj.Opportunity_Name__r.Opportunity_Owner__c != priceObj.CreatedById){
        mapOppLst.put(priceObj.id ,priceObj.Opportunity_Name__r.Opportunity_Owner__c);
        }//end of if
      }// end of for
      
   pricList = [Select UserOrGroupId, ParentId, LastModifiedById, Id, AccessLevel From Pricing_Requests__Share p where  AccessLevel != 'All' and UserOrGroupId IN: oldId  and RowCause!='Rule' ]  ;
   system.debug('sharing rule '+pricList);
   if(pricList.size() > 0)
       {
          delete pricList;
       }  
     if(prLst.size()>0){
      for(Id prObj : mapOppLst.KeySet())
        {
            system.debug('sharing rule ID'+prObj);
            Pricing_Requests__Share pobj = new Pricing_Requests__Share();
          pobj.UserOrGroupId = mapOppLst.get(prObj);
          pobj.AccessLevel='Edit' ;
          pobj.ParentId = prObj;
          newpricList.add(pobj);
        }//end of for
     try{
        system.debug('new pricelist '+newpricList);
         insert newpricList;}
         catch(DMLException e){System.debug('exception '+e);}
      }//end of prList.size
   }//end of method
  
//Method to  update theater when prising request record is created or updated
  public void updateTheaterField(List<Pricing_Requests__c> prsLst )
  {
        
        List<Id> oprId = new List<Id> ();
        for(Pricing_Requests__c pObj:prsLst){
        oprId.add(pObj.Opportunity_Name__c);
        }
     Map<Id,Opportunity> mapOpportunity = new Map<Id,Opportunity>([select Id,Opportunity_Owner__r.Theater__c,Opportunity_Owner__r.Division__c,Opportunity_Owner__r.Email,Sales_Channel__c,Quote_Cart__c  from Opportunity where Id in: oprId]); 
     
     
    for(Pricing_Requests__c pObj1:prsLst){
        //pObj1.PR_Account_Owner_Divison__c = mapOpportunity.get(pObj1.Opportunity_Name__c).Opportunity_Owner__r.Division__c;
       System.debug('pObj1.Recalled_Flag__c--->'+pObj1.Recalled_Flag__c);
      // if(mapOpportunity.get(pObj1.Opportunity_Name__c).Sales_Channel__c == 'Direct'){
      String str=mapOpportunity.get(pObj1.Opportunity_Name__c).Quote_Cart__c;
      if(str !=null && str.containsIgnoreCase('DxP')){
              pObj1.PR_Account_Owner_Divison__c = mapOpportunity.get(pObj1.Opportunity_Name__c).Opportunity_Owner__r.Division__c;
        }   
        
        if( str !=null && str.containsIgnoreCase('CxP')){
              pObj1.PR_Account_Owner_Divison__c = 'PSC';
        }
        if(pObj1.Recalled_Flag__c == true){
              pObj1.OwnerId = UserInfo.getUserId();
        }
        
        pObj1.PR_Account_Owner_Theater__c = mapOpportunity.get(pObj1.Opportunity_Name__c).Opportunity_Owner__r.Theater__c;
        pObj1.Oppty_Account_Owner_Email__c = mapOpportunity.get(pObj1.Opportunity_Name__c).Opportunity_Owner__r.Email;
        
      
  }
}//end of Method
     
    
//Method to update theater field on oppty owner change
  public void updateTheaterFieldOppty(Map<Id,Opportunity> optMap)
  {
    
                
     Map<Id,Pricing_Requests__c> mapPR = new Map<Id,Pricing_Requests__c>([select Id,PR_Account_Owner_Theater__c,Opportunity_Name__c,PR_Account_Owner_Divison__c from Pricing_Requests__c where Opportunity_Name__c in: optMap.Keyset()]);
     
     Map<Id,Opportunity> mapOpportunity = new Map<Id,Opportunity>([select Id,Opportunity_Owner__r.Theater__c,Opportunity_Owner__r.Email,Opportunity_Owner__r.Division__c,Sales_Channel__c,Quote_Cart__c  from Opportunity where Id in: optMap.Keyset()]); 
     
     for(Pricing_Requests__c pObj1:mapPR.values()){
        String str =mapOpportunity.get(pObj1.Opportunity_Name__c).Quote_Cart__c;
        pObj1.PR_Account_Owner_Theater__c = mapOpportunity.get(pObj1.Opportunity_Name__c).Opportunity_Owner__r.Theater__c; 
        
       // if(mapOpportunity.get(pObj1.Opportunity_Name__c).Sales_Channel__c == 'Direct'){
       if(str !=null && str.containsIgnoreCase('DxP')){
         System.debug('Sales_Channel__c----12344');
              pObj1.PR_Account_Owner_Divison__c = mapOpportunity.get(pObj1.Opportunity_Name__c).Opportunity_Owner__r.Division__c;
        }  
        
        
        if(str !=null && str.containsIgnoreCase('CxP')){
              pObj1.PR_Account_Owner_Divison__c = 'PSC';
              System.debug('PSU00000');
        }
       
         pObj1.Oppty_Account_Owner_Email__c = mapOpportunity.get(pObj1.Opportunity_Name__c).Opportunity_Owner__r.Email;
         pObj1.Expiration_Flag__c =true;
     }
     update mapPR.values();
          
  }//end of Method
  
 //Method To update comments and approval owner field on record being approved

      
public void updateCommentsApprovalField(List<Pricing_Requests__c> prsLst)
  {
  if(!isApproved){
    List<Pricing_Requests__c> LstPrice = new List<Pricing_Requests__c>();
    List<Id> prId = new List<Id>();
    List<Id> optId = new List<Id>();
     List<Pricing_Requests__c> pricingLst =[Select Id,comments__c,Approval_Owner_1__c,Opportunity_Name__c,CreatedById,Opportunity_Name__r.Opportunity_Owner__c from Pricing_Requests__c where id IN: prsLst];
     
        for(Pricing_Requests__c  pReq : pricingLst) { 
            prId.add(pReq.Id);
            optId.add(pReq.Opportunity_Name__c);
            
        }
    Map<Id,Opportunity> mapOpportunity = new Map<Id,Opportunity>([select Id,Opportunity_Number__c,Name,Account.Name from Opportunity where Id in: optId]); 
     
       system.debug('mapOpportunity--->'+mapOpportunity);
    ProcessInstance [] op = [SELECT Id,Status,(SELECT Id, StepStatus, Comments,ActorId FROM Steps order by createdDate desc limit 1)FROM ProcessInstance where TargetObjectId IN: prId limit 1 ];
    //ProcessInstance [] op = [SELECT Id,Status,(SELECT Id, StepStatus, Comments,ActorId FROM Steps order by createdDate )FROM ProcessInstance where TargetObjectId IN: prId  ];

    for(Pricing_Requests__c  pReq : prsLst) { 
        for (ProcessInstance pInstance : op) {
            
            for (ProcessInstanceStep pInstanceStep : pInstance.Steps) {
               
             if(pInstance.Status == 'Approved' || pInstance.Status == 'Rejected' || pReq.Approval_Status__c == 'In Process') {               
                pReq.comments__c = pInstanceStep.Comments;
                   
                String s = pInstanceStep.ActorId;
               if(s.substring(0,3)!='00G'){
                    pReq.Approval_Owner_1__c = pInstanceStep.ActorId;
                }
                system.debug('mapOpp-->'+mapOpportunity.get(pReq.Opportunity_Name__c).Opportunity_Number__c );
               if(mapOpportunity.get(pReq.Opportunity_Name__c).Opportunity_Number__c != null && mapOpportunity.get(pReq.Opportunity_Name__c).Opportunity_Number__c != ''){
                    pReq.Opportunity_Number_Email__c = mapOpportunity.get(pReq.Opportunity_Name__c).Opportunity_Number__c;
                }
                if(mapOpportunity.get(pReq.Opportunity_Name__c).Name != null){
                pReq.Opportunity_Name_Email__c = mapOpportunity.get(pReq.Opportunity_Name__c).Name;
                }
                pReq.Approved_date__c = DateTime.Now();
                
                 
                if(pReq.Approval_Status__c != 'In Process'){
                  pReq.Email_Approval_Rejection_status__c = pInstance.Status;
                 // isAssigned = true;
                 
                 }
                pReq.End_User_Name_Email__c = mapOpportunity.get(pReq.Opportunity_Name__c).Account.Name;
                LstPrice.add(pReq);
           }  
         }
       }
     }
   
   }
  }
   
   public void sendEmail(List<Pricing_Requests__c> prsLst){
    
    Id toRecallAdd ;
    List<String>  toEscaltedAdd = new List<String>();
    List<String>  toApprovedAdd = new List<String>();
    List<String> toAdd = new List<String>();
    List<String> ccAdd = new List<String>();
    List<Id> prId = new List<Id>();
    List<String> idList = new List<String>(); 
    Boolean sendFlag = false;
    Boolean sendFinalFlag = false;
    String template;
    String tier2;
    String tier1;
    Boolean expiredFlag;
    Boolean recalledFlag;
   
    List<String> mailToRecalledAddresses = new List<String>(); 
    List<string> emailList = New List<String>();
    List<Id> prCreatedId = new List<Id>();
    List<ProcessInstance> op = new List<ProcessInstance>();
    List<GroupMember> grpMr = new List<GroupMember>();
    string prTheater;
    string prDivison;
    string salesChannel;
    string quoteAmount='';
   List<Pricing_Requests__c> prsLst1;
   String pOwner;
   Boolean escaltedFlag;
   String Tier_1_ApproverId;
     String Tier_2_ApproverId;
        prsLst1 = [Select Opportunity_Name__r.Quote_Cart__c,Id,Tier_2_ApproverId__c,Opportunity_Name__r.Sales_Channel__c,PR_Account_Owner_Divison__c,PR_Account_Owner_Theater__c,Expired_Request__c,Recalled_Flag__c, Owner.Name,Approval_Status__c,APJ_Request_Escalation__c ,Oppty_Account_Owner_Email__c,Tier_1_ApproverId__c,Tier_2_Approver__c from Pricing_Requests__c where id in:prsLst];

     
    for(Pricing_Requests__c  pReq : prsLst) { 
            prCreatedId.add(pReq.CreatedById);
        }
        
    List<User> uMail=[select Email from User where Id IN : prCreatedId];
        
    for(Pricing_Requests__c  pReq : prsLst1) {

        prId.add(pReq.Id) ;
       if(pReq.Oppty_Account_Owner_Email__c != null){
                emailList.add(pReq.Oppty_Account_Owner_Email__c);
               }
              emailList.add(uMail[0].Email);
            System.debug('---pReq.Approval_Status__c--' + pReq.Approval_Status__c);
            //DEC RELEASE :: Suppress Approval/Rejection notifications from being sent to Requestor/Opportunity Account Owner upon request escalation
            
                      
            //if(pReq.Approval_Status__c  == 'In Process' && pReq.APJ_Request_Escalation__c == true){
                System.debug('pReq.Owner.Name--->'+pReq.Owner.Name);  
                pOwner=pReq.Owner.Name;
                escaltedFlag=pReq.APJ_Request_Escalation__c;
                Tier_1_ApproverId=pReq.Tier_1_ApproverId__c;
                Tier_2_ApproverId=pReq.Tier_2_ApproverId__c;
                System.debug('Tier_2_ApproverId------>'+Tier_2_ApproverId);
                System.debug('Tier_1_ApproverId------>'+Tier_1_ApproverId);
               if(pReq.Approval_Status__c  == 'In Process' && pReq.Owner.Name.contains('Tier2')){
                   sendFlag = true;
                   System.debug('---Testing Send Flag--');
                }
            //END : DEC RELEASE
                if((pReq.Approval_Status__c  == 'Approved' ||  pReq.Approval_Status__c =='Rejected') &&  pReq.APJ_Request_Escalation__c == true){
                   sendFinalFlag = true;
                }
                if((pReq.Approval_Status__c  == 'Approved' ||  pReq.Approval_Status__c =='Rejected') &&  pReq.APJ_Request_Escalation__c == false){
                   sendFinalFlag = true;
                }
                
                
                //expired flag chk
                if(pReq.Expired_Request__c == System.Label.Transformation_Valid){
                
                 expiredFlag= false;
                }
                else {
                    
                    expiredFlag =true;
                }
                
                //recalled flag chk
                if(pReq.Recalled_Flag__c){
                    recalledFlag= true;
                    //sendFlag = true;
                }
                else {
                    recalledFlag = false;
                }
                
                prTheater =  pReq.PR_Account_Owner_Theater__c;
                prDivison =  pReq.PR_Account_Owner_Divison__c;
                salesChannel = pReq.Opportunity_Name__r.Sales_Channel__c;
                quoteAmount =pReq.Opportunity_Name__r.Quote_Cart__c;
                tier2 = pReq.PR_Account_Owner_Theater__c + ' ' + System.Label.Transformation_Tier2;
                tier1 = pReq.PR_Account_Owner_Divison__c + ' ' + System.Label.Transformation_Tier1;
        }
    
        System.debug('recalledFlag------->'+recalledFlag);
        System.debug('sendFlag------->'+sendFlag);
        if(!recalledFlag && !sendFlag ){
           toAdd.addAll(emailList);
        }
        System.debug('toAdd--->'+toAdd);
        if(expiredFlag){
             System.debug('ExpiredFlag1------');

//             ccAdd.addAll(getEmailAddresses(tier2,'Expired'));
//             ccAdd.addAll(getEmailAddresses(tier1,'Expired'));
           //For Tier2
           if(escaltedFlag == true){
             List<Id> gId=new List<Id>();
             gId.add(Tier_1_ApproverId);
             gId.add(UserInfo.getUserID() );
                List<User> grpNewName = [select Id,Name,Email from User where Id IN :gId ];
                for(User u:grpNewName) {         
                ccAdd.add(u.Email);   
                
            }
                
            System.debug('ccAdd forTier2-->'+ccAdd);    
           }
           //For Tier1
           else{
                User grpNewName = [select Id,Name,Email from User where Id = : UserInfo.getUserID() ];
                ccAdd.add(grpNewName.Email);
                System.debug('ccAdd forTier1-->'+ccAdd);
           }
           
           template = 'Transformation PAR Expiration C3';
               if(toAdd.size() > 0){
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
                    //Message.setToAddresses(toAdd);   
                if(ccAdd.size() > 0){
                    Message.setCcAddresses(ccAdd);
                }
                Message.setTargetObjectId(prsLst[0].CreatedById); //The first Team Member ID found, this email address will not be in the emailList
        
                // ID of the FSA set from the trigger that called this function
                // Passes the ID to the Visualforce Email template which in turn uses it to set it again
                  
                Message.setWhatId(prsLst[0].Id); 
                Message.setTemplateId([select id from EmailTemplate where Name =: template].id); 
                Message.SaveAsActivity = false;
                Messaging.sendEmail(new Messaging.singleemailMessage[] {message}); 
             } //end of if
             
        }
    //    else if(recalledFlag){
            System.debug('recalledFlag------');
            if(recalledFlag){
             
            List<String> actorId = new List<String>();
            Map<string,string> grpName = new Map<string,string>();
            Boolean contains =false;
            //query
            
             op = [SELECT Id,Status,(SELECT Id, StepStatus, Comments,ActorId FROM Steps order by createdDate desc limit 1)FROM ProcessInstance where TargetObjectId IN: prId  limit 1 ];
             
             
             if(op.size() > 0){
                for(ProcessInstance pObj : op){
                    for (ProcessInstanceStep pInstanceStep : pObj.Steps) {
                        actorId.add(pInstanceStep.ActorId);
                    }
                }
             System.debug('actorId---------->'+actorId);
             if(actorId.size() > 0){
                  grpMr = [select Group.Name,GroupId,userOrGroupId from GroupMember where userOrGroupId IN:actorId];
                  System.debug('grpMr inside recall---------->'+grpMr);
                    if(grpMr.size() > 0){
                        
                    for (GroupMember gm : grpMr) {   
                        grpName.put(gm.Group.Name,gm.Group.Name);
                     }
                
                     if(grpName.size () > 0){
                     System.debug('grpName@@@@2---->'+grpName);
                   contains = grpName.containsKey('Tier 1');
                   //   contains = grpName.containsKey('Tier2');
                      System.debug('contains@@@@-->'+contains);
                     }//grpname size chk if
                     
                     if(escaltedFlag == true){
                        if(Tier_2_ApproverId != null){
                         List<Id> gId=new List<Id>();
                          gId.add(Tier_2_ApproverId);
                        //  gId.add(UserInfo.getUserID() );
                          List<User> grpNewName = [select Id,Name,Email from User where Id IN :gId ];
                          for(User u:grpNewName) {         
                            toRecallAdd =u.Id;   
                
                            }   
                        }
                        else{
                        tier2 = prTheater + ' ' + System.Label.Transformation_Tier2;
                     //   toRecallAdd.addAll(getEmailAddresses(tier2,'Recall'));
                        }
                        System.debug('REcall 1-------');
                        System.debug('toRecallAdd 1-------'+toRecallAdd);
                        
                     }//boolean chk if
                     else{
                     
                            if(salesChannel == System.Label.Transformation_SalesDirect){
                            
                                if(prTheater.contains('Americas')){
                                tier1 = prTheater + ' ' + System.Label.Transformation_Tier1;
                                }
                                else{
                            tier1 = prTheater + ' ' + prDivison + ' ' + System.Label.Transformation_Tier1;
                            }
                            System.debug('direct tier1------->'+ tier1);
                            }
                            if(quoteAmount != null){
                            if(prTheater.contains('Americas')){
                            tier1 = prTheater + ' ' + System.Label.Transformation_Tier1;
                            }
                            else{
                                tier1 = prTheater + ' ' + System.Label.Transformation_Pscqueue;
                                }
                                System.debug('tier1inside cxp--->' + tier1);
                            }
                            System.debug('Recall 2-------');
                            
                            if(Tier_1_ApproverId != null){
                                List<Id> gId=new List<Id>();
                                  gId.add(Tier_1_ApproverId);
                                   //gId.add(UserInfo.getUserID() );
                                  List<User> grpNewName = [select Id,Name,Email from User where Id IN :gId ];
                                  for(User u:grpNewName) {         
                                    toRecallAdd=u.Id; }
                                
                            }else{
                       //     toRecallAdd.addAll(getEmailAddresses(tier1,'Recall'));
                       }
                            
                     }//end of else
                    
                    }//size chk if
                }
     
             }//end of If
           template = 'Transformation PAR Recall C4';
           if(toRecallAdd != null){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
              //  Message.setToAddresses(toRecallAdd);   
              /*  if(ccAdd.size() > 0){
                    Message.setCcAddresses(ccAdd);
                }*/
                Message.setTargetObjectId(toRecallAdd); //The first Team Member ID found, this email address will not be in the emailList
        
                // ID of the FSA set from the trigger that called this function
                // Passes the ID to the Visualforce Email template which in turn uses it to set it again
                  
                Message.setWhatId(prsLst[0].Id); 
                Message.setTemplateId([select id from EmailTemplate where Name =: template].id); 
                Message.SaveAsActivity = false;
                Messaging.sendEmail(new Messaging.singleemailMessage[] {message}); 
                
                System.debug('toRecallAdd-->'+toRecallAdd);
             } 
          }
       // else if(sendFlag){
       //To send Escalted email
       if(sendFlag){
            
             System.debug('tier2---->'+tier2);
             
             toAdd.clear();
             System.debug('Escalted------'+toAdd);
             toEscaltedAdd.addAll(getEmailAddresses(tier2,'Escalte'));
            
             template = 'Transformation PAR Escalated C2';
              System.debug('Escalted after------'+toEscaltedAdd);
              if(toEscaltedAdd.size() > 0){
                 Messaging.SingleEmailMessage Escaltedmessage = new Messaging.SingleEmailMessage(); 
                Escaltedmessage.setToAddresses(toEscaltedAdd);   
              //  Escaltedmessage.setTargetObjectId(prsLst[0].CreatedById); //The first Team Member ID found, this email address will not be in the emailList
              System.debug('tOwnerId in ES-->'+tOwnerId);
                Escaltedmessage.setTargetObjectId(tOwnerId);
                // ID of the FSA set from the trigger that called this function
                // Passes the ID to the Visualforce Email template which in turn uses it to set it again
                Escaltedmessage.setWhatId(prsLst[0].Id); 
                Escaltedmessage.setTemplateId([select id from EmailTemplate where Name =: template].id); 
                Escaltedmessage.SaveAsActivity = false;
                Messaging.sendEmail(new Messaging.singleemailMessage[] {Escaltedmessage}); 
                System.debug('toEscaltedAdd-->'+toEscaltedAdd);
             } 
             
        }
       
        else if(sendFinalFlag){
           //  toApprovedAdd.addAll(getEmailAddresses(tier2,'Approve'));
            // toApprovedAdd.addAll(getEmailAddresses(tier1,'Approve'));
           
          //   toApprovedAdd.addAll(emailList);
           //For Tier2/Tier1 Approver
           
                User grpNewName = [select Id,Name,Email from User where Id = : UserInfo.getUserID() ];
                toApprovedAdd.add(grpNewName.Email);
                System.debug('ccAdd forTier1-->'+toApprovedAdd);
         
             template = 'Transformation PAR Approval/Rejection C9';
              if(toApprovedAdd.size() > 0){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
                Message.setCcAddresses(toApprovedAdd);   
                Message.setTargetObjectId(prsLst[0].CreatedById); //The first Team Member ID found, this email address will not be in the emailList
        
                // ID of the FSA set from the trigger that called this function
                // Passes the ID to the Visualforce Email template which in turn uses it to set it again
                  
                Message.setWhatId(prsLst[0].Id); 
                Message.setTemplateId([select id from EmailTemplate where Name =: template].id); 
                Message.SaveAsActivity = false;
                Messaging.sendEmail(new Messaging.singleemailMessage[] {message}); 
         } 
          System.debug('toApprovedAdd-->'+toApprovedAdd);
     }
    
       
   }
   
   
   
   //To fetch the group member email id
   
   private List<String> getEmailAddresses(String groupName,String type) {   
    System.debug('groupName----->'+groupName);
    List<String> idList = new List<String>(); 
    List<String> groupId = new List<String>();   
    List<String> mailToAddresses = new List<String>(); 
    List<Group> g = new List<Group>();
    List<GroupMember> grpMr = new List<GroupMember>();
    
     g = [SELECT Id FROM group WHERE name =: groupName]; 
     if(g != null){
        for(Group grpObj : g){
            groupId.add(grpObj.Id); 
        }
     }
     System.debug('groupId-->'+groupId);
     if(groupId.size() > 0){
    grpMr = [select userOrGroupId from GroupMember where GroupId IN:groupId];
     for (GroupMember gm : grpMr) {   
            idList.add(gm.userOrGroupId);    
        }
     }
     
     if(idList.size() > 0){
    User[] usr = [SELECT Id,email FROM user WHERE id IN :idList];    
    if(type != 'Escalte'){
      
        for(User u : usr) {         
            mailToAddresses.add(u.email);   
            
        
    }
    
    }//end of if
    else{
    for(Integer u=1; u < usr.size(); u++) {         
        mailToAddresses.add(usr[u].email);   
        
    }
        tOwnerId=usr[0].Id;
     System.debug('tOwnerId1-->'+tOwnerId +'<--->' +mailToAddresses);
    }
    
     }
   System.debug('tOwnerId-->'+tOwnerId +'<--->' +mailToAddresses);
    return mailToAddresses;   
}


   
   
   
 // To update the Owner field
public void updateOwnerField(List<Pricing_Requests__c> prsLst){

  if(!isOwnerApproved){
        List<Pricing_Requests__c> LstOwnerPrice = new List<Pricing_Requests__c>();
        List<Group> mapQueueTier = new List<Group>();
        List<Pricing_Requests__c> pricingLst =[Select Id,Recalled_Flag__c,Owner.Name,Tier2_Access__c,CreatedById,Opportunity_Name__r.Opportunity_Owner__c,Opportunity_Name__r.Account_Owner_Theater__c,Tier_1_Approver__c,Tier_1_Approver_1__c,Approval_Status__c,APJ_Request_Escalation__c,Opportunity_Name__r.Sales_Channel__c,Opportunity_Name__r.Account_Owner_Division__c,Opportunity_Name__r.Quote_Cart__c from Pricing_Requests__c where id IN: prsLst];
        List<String> optyTheater= new List<String>() ;
        Id loggedinUser;
        for(Pricing_Requests__c pObj:pricingLst ){
     if(pObj.Recalled_Flag__c == false){
      String str =pObj.Opportunity_Name__r.Quote_Cart__c;
             //Start : JAN RELEASE
             if(str != null && str.containsIgnoreCase('DxP') && pObj.Opportunity_Name__r.Account_Owner_Theater__c =='APJ'){
                
                if(pObj.Opportunity_Name__r.Account_Owner_Division__c =='ANZ' &&((pObj.Approval_Status__c =='New'|| pObj.Approval_Status__c=='In Process') && pObj.APJ_Request_Escalation__c == false)){
                        optyTheater.add('APJ ANZ Tier 1');
                    }
                else if(pObj.Opportunity_Name__r.Account_Owner_Division__c =='Greater China' &&((pObj.Approval_Status__c =='New'|| pObj.Approval_Status__c=='In Process') && pObj.APJ_Request_Escalation__c == false)){
                        optyTheater.add('APJ GC Tier 1');
                    }
                else if(pObj.Opportunity_Name__r.Account_Owner_Division__c =='India' &&((pObj.Approval_Status__c =='New'|| pObj.Approval_Status__c=='In Process') && pObj.APJ_Request_Escalation__c == false)){
                        optyTheater.add('APJ India Tier 1');
                    }
                else if(pObj.Opportunity_Name__r.Account_Owner_Division__c =='Japan' &&((pObj.Approval_Status__c =='New'|| pObj.Approval_Status__c=='In Process') && pObj.APJ_Request_Escalation__c == false)){
                        optyTheater.add('APJ Japan Tier 1');
                    }
                else if(pObj.Opportunity_Name__r.Account_Owner_Division__c =='Korea' &&((pObj.Approval_Status__c =='New'|| pObj.Approval_Status__c=='In Process') && pObj.APJ_Request_Escalation__c == false)){
                        optyTheater.add('APJ Korea Tier 1');
                    }
                else if(pObj.Opportunity_Name__r.Account_Owner_Division__c =='South East Asia' &&((pObj.Approval_Status__c =='New'|| pObj.Approval_Status__c=='In Process') && pObj.APJ_Request_Escalation__c == false)){
                        optyTheater.add('APJ SEA Tier 1');
                    }
                else if(((pObj.Approval_Status__c =='New'|| pObj.Approval_Status__c=='In Process') && pObj.APJ_Request_Escalation__c == false)){
                    optyTheater.add('APJ Uncategorized Tier 1');
              }
             }
             
            
             
             if(str !=null && str.containsIgnoreCase('CxP') && pObj.Opportunity_Name__r.Account_Owner_Theater__c =='APJ' && ((pObj.Approval_Status__c =='New'|| pObj.Approval_Status__c=='In Process') && pObj.APJ_Request_Escalation__c == false)){
                optyTheater.add('APJ PSC Queue');
             }
             // END : JAN RELEASE
            
           if(pObj.Owner.Name != 'APJ Tier2' && pObj.Tier2_Access__c == true  && pObj.Opportunity_Name__r.Account_Owner_Theater__c =='APJ' && pObj.APJ_Request_Escalation__c == true && pObj.Approval_Status__c=='In Process'){
                optyTheater.add('APJ Tier2');
            }
           
    
            if(pObj.Opportunity_Name__r.Account_Owner_Theater__c =='Americas' && pObj.Approval_Status__c=='New'){
            optyTheater.add('Americas Tier1');}
     

       //Start : JAN RELEASE
       String str1 =pObj.Opportunity_Name__r.Quote_Cart__c;
       if(str1 != null && str1.containsIgnoreCase('DxP') && pObj.Opportunity_Name__r.Account_Owner_Theater__c =='EMEA'){
            if(pObj.Opportunity_Name__r.Account_Owner_Division__c =='UKI' && ((pObj.Approval_Status__c =='New'|| pObj.Approval_Status__c=='In Process') && pObj.APJ_Request_Escalation__c == false)){
                    optyTheater.add('EMEA UKI Tier 1');
              }
             else if(pObj.Opportunity_Name__r.Account_Owner_Division__c =='Germany' && ((pObj.Approval_Status__c =='New'|| pObj.Approval_Status__c=='In Process') && pObj.APJ_Request_Escalation__c == false)){
                    optyTheater.add('EMEA Germany Tier 1');
              }
              else if(pObj.Opportunity_Name__r.Account_Owner_Division__c =='France' && ((pObj.Approval_Status__c =='New'|| pObj.Approval_Status__c=='In Process') && pObj.APJ_Request_Escalation__c == false)){
                    optyTheater.add('EMEA France Tier 1');
              }
              else if(pObj.Opportunity_Name__r.Account_Owner_Division__c =='Russia' && ((pObj.Approval_Status__c =='New'|| pObj.Approval_Status__c=='In Process') && pObj.APJ_Request_Escalation__c == false)){
                    optyTheater.add('EMEA Russia Tier 1');
              }
              else if(pObj.Opportunity_Name__r.Account_Owner_Division__c =='Eur North' && ((pObj.Approval_Status__c =='New'|| pObj.Approval_Status__c=='In Process') && pObj.APJ_Request_Escalation__c == false)){
                    optyTheater.add('EMEA North Tier 1');
              }
              else if(pObj.Opportunity_Name__r.Account_Owner_Division__c =='Europe South' && ((pObj.Approval_Status__c =='New'|| pObj.Approval_Status__c=='In Process') && pObj.APJ_Request_Escalation__c == false)){
                    optyTheater.add('EMEA South Tier 1');
              }
              else if(pObj.Opportunity_Name__r.Account_Owner_Division__c =='TEEAM' && ((pObj.Approval_Status__c =='New'|| pObj.Approval_Status__c=='In Process') && pObj.APJ_Request_Escalation__c == false)){
                    optyTheater.add('EMEA TEEAM Tier 1');
              }
              else if(((pObj.Approval_Status__c =='New'|| pObj.Approval_Status__c=='In Process') && pObj.APJ_Request_Escalation__c == false)){
                    optyTheater.add('EMEA Uncategorized Tier 1');
              }
       }
      
            
     
             if(str1 !=null && str1.Contains('CxP') && pObj.Opportunity_Name__r.Account_Owner_Theater__c =='EMEA' && ((pObj.Approval_Status__c =='New'|| pObj.Approval_Status__c=='In Process') && pObj.APJ_Request_Escalation__c == false)){
                optyTheater.add('EMEA PSC Queue');
             }
             
             
        if(pObj.Tier2_Access__c == true && pObj.Opportunity_Name__r.Account_Owner_Theater__c =='EMEA' && pObj.APJ_Request_Escalation__c == true && pObj.Approval_Status__c=='In Process'){
            optyTheater.add('EMEA Tier2');
           }
          
     
       }
       // END : JAN RELEASE
        }//End of For
        
      
         isOwnerApproved = true;
          mapQueueTier = [select Id from Group where Name IN: optyTheater and Type='Queue'];
             if(mapQueueTier.size()>0){  
                for(Pricing_Requests__c pObj1:pricingLst ){
                        
                        pObj1.OwnerId = mapQueueTier[0].id ;
                        LstOwnerPrice.add(pObj1);
                      }//End of for
             }
                System.debug('LstOwnerPrice-----'+LstOwnerPrice);
                  if(LstOwnerPrice.size()>0){
                    update LstOwnerPrice;}
              
            }
         
     //isOwnerApproved = true;
    }//End of method

@future(callout=true)
public static void deleteApprovalUser(List<Id> prsLst){

if(!isProcessed){

List<Id> optyOwnerId = new List<Id>();
List<Pricing_Requests__c> prsLstOwner =[Select Id,Opportunity_Name__r.Opportunity_Owner__c,Approval_Status__c from Pricing_Requests__c where id IN: prsLst];

for(Pricing_Requests__c pObj:prsLstOwner){
    optyOwnerId.add(pObj.Opportunity_Name__r.Opportunity_Owner__c);
  }
  List<Pricing_Requests__c> pricingLst =[Select Id from Pricing_Requests__c where Opportunity_Name__r.Opportunity_Owner__c IN: optyOwnerId and Approval_Status__c = 'New'  ];
  
   if(pricingLst.size() == 0){ 
       
//Delete the oppty owner from the Group to remove the approval process submission access.
    List<GroupMember>  grpName = [select Id from GroupMember where Group.Name ='PricingRequestOpptyOwner' and UserOrGroupId IN : optyOwnerId];
    if(grpName.size() > 0){
      delete grpName;
    }
   
} 
}
isProcessed = true;
 
}

@future(callout=true)
public  static void setOpptyOwner(List<Id> prsLst){
if(!isProcessed){
List<GroupMember> lstGrpMember = new List<GroupMember>();
Group  grpName = [select Id from Group where Name ='PricingRequestOpptyOwner' ];
 
List<Pricing_Requests__c> pricingLst =[Select Id,CreatedById,Opportunity_Name__r.Opportunity_Owner__c,Opportunity_Name__r.Account_Owner_Theater__c,Approval_Status__c,APJ_Request_Escalation__c from Pricing_Requests__c where id IN: prsLst];
       
       for(Pricing_Requests__c pObj:pricingLst ){
           GroupMember grpMember = new GroupMember();
            if(pObj.Opportunity_Name__r.Opportunity_Owner__c != pObj.CreatedById){
                grpMember.UserOrGroupId = pObj.Opportunity_Name__r.Opportunity_Owner__c;
                grpMember.GroupId =grpName.Id;
                lstGrpMember.add(grpMember);
            }
             
       }
       insert lstGrpMember;
     }
  }//end of method



public void updateAcceptanceOwner(List<Pricing_Requests__c> prsLst,Map<Id,Id> mapAccptOwner){
    Map<Id,String> mapOldGrp = new Map<Id,String>();
    Map<Id,String> mapNewGrp = new Map<Id,String>();
    Map<Id,Id> mapOldNewGrpId= new Map<Id,Id>();
    Map<String,Id> mapNewGrpId = new Map<String,Id> ();

    List<Group> grpOldName = [select Id,Name from Group where Id IN : mapAccptOwner.values() ];
    
    for(Group gObj : grpOldName){
        mapOldGrp.put(gObj.id,gObj.Name);
    }
    
    List<User> grpNewName = [select Id,Name from User where Id IN : mapAccptOwner.KeySet() ];
    

    for(User gObj1 : grpNewName){
        mapNewGrp.put(gObj1.id,gObj1.Name);
        mapNewGrpId.put(gObj1.Name,gObj1.Id);
    }
    
    for(Id grObj : mapAccptOwner.KeySet())
        {
        id gId=mapAccptOwner.get(grObj);
        mapOldNewGrpId.put(grObj,gId);
    }

    
    
 for(Pricing_Requests__c pObj:prsLst){
        
         Id oldGrpId = mapOldNewGrpId.get(pObj.OwnerId);
          string oldOwnerName = mapOldGrp.get(oldGrpId);
       if(oldOwnerName != null){
       System.debug('oldOwnerName1---->'+oldOwnerName);
         if(oldOwnerName.contains('Tier 1')){
              pObj.Tier_1_Approver__c = mapNewGrp.get(pObj.OwnerId);
              pObj.Tier_1_ApproverId__c = pObj.OwnerId;     
         }
         else if(oldOwnerName.contains('Tier1')){
         
         pObj.Tier_1_Approver__c = mapNewGrp.get(pObj.OwnerId);
          pObj.Tier_1_ApproverId__c = pObj.OwnerId;
         
             
         }
         
         if(oldOwnerName.contains('Tier2')){
            
              pObj.Tier_2_Approver__c = mapNewGrp.get(pObj.OwnerId);
               pObj.Tier_2_ApproverId__c = pObj.OwnerId;  
           
         }
         else If(oldOwnerName.contains('Tier 2') ){
             pObj.Tier_2_Approver__c = mapNewGrp.get(pObj.OwnerId);
              pObj.Tier_2_ApproverId__c = pObj.OwnerId;  
          }
        
       }
     }//end of for
   }


   
 //Method to  update Oppty Sales Channel Field 
  public void updateSalesChannel(List<Opportunity> optLst )
  {
    for(Opportunity optObj1:optLst){
        optObj1.Sales_Channel__c  = 'Indirect';
  }
}//end of Method

/*
Method : UpdateApprovalStatus 
Description : This method will be called, whenever user update certain fields on Oppty page or PAR page by Sales rep / Channel rep profile user.
Trigger : afterOpptyUpdate ,afterInsertUpdateOfPricingRequest 
*/

 public void UpdateApprovalStatus(List<Id> lstOppty ,List<Pricing_Requests__c> lstPAR  ){
 List<Pricing_Requests__c> lstPARRelatedToOppty = new List<Pricing_Requests__c>();
 List<Pricing_Requests__c> updatePARRelatedToOppty = new List<Pricing_Requests__c>(); 
 Map<String,Transformation_ProfileName__c> mapCustProfiles = Transformation_ProfileName__c.getall();
 List<String> setProfile = new List<String>();

    for(Transformation_ProfileName__c mapObj :mapCustProfiles.values()){
        setProfile.add(mapObj.ProfileName__c);
    }
        System.debug('SetProfiles-------->'+ setProfile);
              /*for(Transformation_ProfileName__c parProfile:mapCustProfiles.values()){
                setProfile.add(parProfile.ProfileName__c);
                } */
 Map<Id,Profile> mapProfile = new Map<Id,Profile>([Select Id,name from Profile where Name in:setProfile OR Name like 'System Admin%']);
 if(mapProfile.containsKey(UserInfo.getProfileId())){
    if(lstOppty.size()>0 && lstPAR.size()==0){
    lstPARRelatedToOppty =[select Id,PR_Account_Owner_Theater__c,EMC_Products__c,Approval_Expiration_Date__c,CreatedById,Opportunity_Name__c,PR_Account_Owner_Divison__c from Pricing_Requests__c where Opportunity_Name__c in: lstOppty and Approval_Status__c =: 'Approved'];
        for(Pricing_Requests__c objPAR : lstPARRelatedToOppty){
            objPAR.Approval_Status__c = 'New';
            objPAR.OwnerId = objPAR.CreatedById;
            
            updatePARRelatedToOppty.add(objPAR);
        }
        if(updatePARRelatedToOppty.size()>0){
        // try{
            System.debug('updatePARRelatedToOpptybug---->'+updatePARRelatedToOppty);
            update updatePARRelatedToOppty;
           // }
          /* catch(DMLException e){
           System.debug('Exception Handled'+e);
           }*/
           
        }
        
    }//End IF
    else if(lstPAR.size()>0 && lstOppty.size() ==0){
        lstPARRelatedToOppty.clear();
        lstPARRelatedToOppty =[select Id,Approval_Status__c,CreatedById,OwnerId from Pricing_Requests__c where Id in: lstPAR and Approval_Status__c =: 'Approved'];
        if(lstPARRelatedToOppty.size() > 0){
         for(Pricing_Requests__c objPAR : lstPARRelatedToOppty){
            objPAR.Approval_Status__c = 'New';
            objPAR.OwnerId = objPAR.CreatedById ;
            updatePARRelatedToOppty.add(objPAR);    
         }//End For 
         System.debug('updatePARRelatedToOppty----->'+ updatePARRelatedToOppty);
         if(updatePARRelatedToOppty.size()>0){
         try{
           update updatePARRelatedToOppty;}
           catch(DMLException e){
           System.debug('Exception Handled'+e);
           
           }
           updatePARRelatedToOppty.clear();
           
          }//End If
       }//End If null check
    } // End Else If
  }//End If null check
    
}
 
 /*
Method : sendEmailonStatusChange 
Description : This method will is used to send notification to assigned approver on status flip from approved to New.
Trigger : afterInsertUpdateOfPricingRequest 
*/

public void sendEmailonStatusChange(List<Pricing_Requests__c> prsLst ){
    
//List<String> toAdd = new List<String>();

//List<Id> prId = new List<Id>();
List<Pricing_Requests__c> parLst = new List<Pricing_Requests__c>();
Id Tier_1_ApproverId;
Id RequestorId;
String template;
Integer noOfPAR = 0;
Integer remainingPAR;
//List<string> emailList = New List<String>();
/*
for(Pricing_Requests__c  pReq : prsLst) { 
            prCreatedId.add(pReq.CreatedById);
        }
User uMail=[select Email from User where Id IN : prCreatedId limit 1]; */
parLst = [Select Id,Opportunity_Name__r.Sales_Channel__c,Owner.Name,Approval_Status__c,CreatedBy.Email,CreatedById,Oppty_Account_Owner_Email__c,Tier_1_ApproverId__c from Pricing_Requests__c where id in:prsLst];       
template = 'Transformation_PAR_Unlocked';   
Id templateId =[select id from EmailTemplate where DeveloperName =: template].id; 
List<Messaging.SingleEmailMessage> lstMsg = new List<Messaging.SingleEmailMessage>(); 

        if(parLst.size()>0){
            //noOfPAR = parLst.size();
            //if(noOfPAR <= 10){
              for(Pricing_Requests__c  pReq : parLst) {
              List<String> ccAdd = new List<String>();
              ccAdd.add(pReq.CreatedBy.Email);
              Tier_1_ApproverId=pReq.Tier_1_ApproverId__c ;
          if(Tier_1_ApproverId != null){
              Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
              Message.setTargetObjectId(Tier_1_ApproverId); //The requestor will be added cc
              Message.setCcAddresses(ccAdd);
              Message.setWhatId(pReq.Id); 
              Message.setTemplateId(templateId); 
              Message.SaveAsActivity = false;
              lstMsg.add(Message);

              }
              }//End For
             // }//End inner If
             System.debug('lstMsg----->'+lstMsg);
         if(lstMsg.size()>0){
           Messaging.sendEmail(lstMsg);}

         }//End If      
       } //End Method
 
 
 /*
Method : checkFieldChange 
Description : This method is used to check the field update on PAR page.
Trigger : afterInsertUpdateOfPricingRequest 
*/

 public void checkFieldChange(Map<Id,Pricing_Requests__c> mapTriggerNew, Map<Id,Pricing_Requests__c> mapTriggerOld){
 Boolean isFieldUpdate = false;
if(mapTriggerNew!=null && mapTriggerOld!=null){
    List<Id> idlst = new List<Id>(); // To set id null to pass the else part in UpdateApprovalStatus method
    List<Pricing_Requests__c> prsLst = new List<Pricing_Requests__c>();
    List<String> lstFieldName = new List<String>();
    Map<String,TransformationPARFieldsToCheckUpdate__c > mapFieldsName = TransformationPARFieldsToCheckUpdate__c.getAll(); 
    
    Pricing_Requests__c oldPARID;
    
    prsLst.addAll(mapTriggerNew.Values());
    System.debug('Id of Map Trigger------>'+mapTriggerNew.KeySet());
    
    
        
    if(mapFieldsName.size() >0){
        lstFieldName.addAll(mapFieldsName.KeySet());}
        System.debug('TransformationPARFieldsToCheckUpdate__c------>'+mapFieldsName);
        for(Pricing_Requests__c newPAR :mapTriggerNew.values()){
         oldPARID = mapTriggerOld.get(newPAR.id);
         for(TransformationPARFieldsToCheckUpdate__c parFields : mapFieldsName.values()){
         if(parFields.ObjectName__c =='Pricing_Requests__c' && parFields.FieldName__c != null && parFields.ObjectName__c != null){
            if(oldPARID.get(parFields.FieldName__c) != newPAR.get(parFields.FieldName__c)){
             isFieldUpdate = true;
            } //End if inside For
          }//End If
         }//End Inner For
       }//End Outer For
      if(isFieldUpdate){
        UpdateApprovalStatus(idlst,prsLst);
      }
   } //End If
}//End Method

}// end of class