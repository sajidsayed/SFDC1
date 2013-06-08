/*=========================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER       WR        DESCRIPTION                               

 |  ====          =========       ==        =========== 

 | 25/04/2011     Suman B                   This trigger is to create a corresponding Deleted Account Association  
                                            record for AccountAssociation record before delete
 | 09/06/2011     Anand Sharma              Update code to pass id in place of name of Account association record to 
                                            outbound message.                                                                  
 +=================================================================================================*/

trigger PRM_DealReg_AccountAssociation on APPR_MTV__RecordAssociation__c (Before Delete,After Insert,After Update) {    
    Map<String,Outbound_Message_Log__c> mapDelAccAssociation = new Map<String,Outbound_Message_Log__c>() ;       
 if (Trigger.isBefore && Trigger.isDelete) {
    system.debug('Inside AccountAssociation Delete event #####');  
   for (APPR_MTV__RecordAssociation__c accAsscn : Trigger.old ){
     if(accAsscn.APPR_MTV__Account_Role__c == 'Distributor'){
       Outbound_Message_Log__c delaccASSON = new Outbound_Message_Log__c();            
       // update by anand on 09/06/2011
       delaccASSON.RecordId__c = accAsscn.Id ;
       //delaccASSON.RecordId__c = accAsscn.Name ;
       delaccASSON.Integration_Operation__c = 'Delete Account Association';
       mapDelAccAssociation.put(delaccASSON.RecordId__c, delaccASSON);
     } 
    }
   } //isDelete
 if(Trigger.isAfter) {
   if(Trigger.isInsert){
     system.debug('Inside AccountAssociation Insert event #####');
     for (APPR_MTV__RecordAssociation__c accAsscn : Trigger.new ){
       if(accAsscn.APPR_MTV__Account_Role__c == 'Distributor'){
         Outbound_Message_Log__c delaccASSON = new Outbound_Message_Log__c();
         // update by anand on 09/06/2011
         delaccASSON.RecordId__c = accAsscn.Id ;
         //delaccASSON.RecordId__c = accAsscn.Name ;
         delaccASSON.Integration_Operation__c = 'Upsert Account Association';
         mapDelAccAssociation.put(delaccASSON.RecordId__c, delaccASSON);
       } // End of if -condition.
     } //End of for -loop.
    }  // if isinsert.
   else{
    for (APPR_MTV__RecordAssociation__c accAsscn : Trigger.newMap.values() ){
      if(accAsscn.APPR_MTV__Account_Role__c == 'Distributor'){
        if((Trigger.newMap.get(accAsscn.id).APPR_MTV__Account__c != Trigger.oldMap.get(accAsscn.id).APPR_MTV__Account__c)
         ||(Trigger.newMap.get(accAsscn.id).APPR_MTV__Primary__c != Trigger.oldMap.get(accAsscn.id).APPR_MTV__Primary__c )
         ||(Trigger.newMap.get(accAsscn.id).APPR_MTV__Associated_Account__c != Trigger.oldMap.get(accAsscn.id).APPR_MTV__Associated_Account__c)
         ||(Trigger.newMap.get(accAsscn.id).APPR_MTV__Account_Role__c != Trigger.oldMap.get(accAsscn.id).APPR_MTV__Account_Role__c)){ 
            Outbound_Message_Log__c delaccASSON = new Outbound_Message_Log__c();
            // update by anand on 09/06/2011
            delaccASSON.RecordId__c = accAsscn.Id ;
            //delaccASSON.RecordId__c = accAsscn.Name ;
            delaccASSON.Integration_Operation__c = 'Upsert Account Association';
            mapDelAccAssociation.put(delaccASSON.RecordId__c, delaccASSON);
        } 
      } // End of if -condition.
      else if( (Trigger.oldMap.get(accAsscn.id).APPR_MTV__Account_Role__c == 'Distributor') &&
               (Trigger.newMap.get(accAsscn.id).APPR_MTV__Account_Role__c != 'Distribution VAR')){
            Outbound_Message_Log__c delaccASSON = new Outbound_Message_Log__c();
            // update by anand on 09/06/2011
            delaccASSON.RecordId__c = accAsscn.Id ;
            //delaccASSON.RecordId__c = accAsscn.Name ;
            delaccASSON.Integration_Operation__c = 'Delete Account Association';
            mapDelAccAssociation.put(delaccASSON.RecordId__c, delaccASSON);
      }   
     } //End of for -loop.
   } // if update-condition. 
  } // isafter condition. 
  if(mapDelAccAssociation.size()>0){
    upsert mapDelAccAssociation.values() RecordId__c;
    }     
}