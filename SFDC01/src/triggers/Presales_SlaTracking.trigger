/*Trigger to update the Case object with the required time to resolve the case
 Whenever the case status is updated new record will be created in child object
*/
trigger Presales_SlaTracking on Case (after insert, after update ) {
 Presales_SLA_Class obj = new Presales_SLA_Class();
 Presales_CheckRecordType objCheckRecordType = new Presales_CheckRecordType();
 List<Case> lstNewCases = objCheckRecordType.checkRecordType(trigger.new);
 List<ID> parentToDelete = new List<ID>();
 List<ID> parentId = new List<ID>();
 Map<id,id> requestorId = new Map<id,id>();
 List<CaseShare> childCaseShare = new List<CaseShare>();
 Map<id,id> mapChildCaseId= new Map<id,id>();
 Map<id,id> mapParentCaseId = new Map<id,id>(); 
 string mailId;
 static Boolean chkShare=false;
 string chkType;
 Boolean checkShare=false;
 public static Boolean ownerChange = false;
 public static Boolean caseOrigin = false;
  public static Boolean onlyCntChange = false;

 if(lstNewCases.size()>0){
   //if(!Presales_SLA_Class.hasAlreadyChanged()){
      // List<Case> caseLst= Trigger.new;
       List<Case> caseOldLst= Trigger.old;
       System.debug('caseLst--->'+lstNewCases.size());
        //if(Trigger.IsBefore){
        if(trigger.isUpdate){
            chkType='Update';
        }
        else if(trigger.isInsert){
            chkType='Insert';
            checkShare = true;
        }
        system.debug('lstNewCases in trigger--->'+ lstNewCases);
        if(!Presales_SLA_Class.hasAlreadyChanged()){
            //obj.presalesStdCaseTime(lstNewCases,chkType);
        }    
        //}
      
        System.debug('caseOldLst--->'+caseOldLst);
        boolean chkForChange=false;
      
         if(caseOldLst != null){
            for(Case CN : lstNewCases){
                if(CN.status != trigger.oldMap.get(CN.Id).status){
                   chkForChange = true;
                  }
                }    
          system.debug('chkForChange in if--->'+chkForChange );
         }
       else{
             system.debug('chkForChange in else--->'+chkForChange );
            chkForChange = true;
        }
        system.debug('chkForChange--->'+chkForChange );

if((trigger.IsAfter && trigger.isInsert)||(trigger.isAfter&& trigger.isUpdate)){
    system.debug('updated case'+trigger.new);
    system.debug('old case'+trigger.old);
        if(chkForChange == true  && !Presales_SLA_Class.slaChanged()){
             obj.populateChildData(lstNewCases,caseOldLst);
             
        }
}

        if(trigger.IsInsert){
               //updating case to auto assign to queue
               Presales_Operations objOp = new Presales_Operations();
               objOp.autoAssignmentToQueue(trigger.new);
       } 
     //  List<CaseShare> shrLstAfetrInsert1 = [Select CaseId,Id,UserOrGroupId from CaseShare where caseid =:lstNewCases[0].Id];
    //   System.debug('after queue-->'+shrLstAfetrInsert1);
//}



if(trigger.isafter){

//To sethe  case share access
Presales_CaseShare_Class shareObj = new Presales_CaseShare_Class();
List<Id> lstCaseToUpdate = new List<ID>();
List<Id> contUsr= new List<Id>();
String insertOrUpdate;
List<Case> oldCaseLst= Trigger.old;
Id oldUserid;



 /* if(trigger.isInsert){
      System.debug('after insert');
      List<Id> caseId= new List<Id>();
       for(Case C: lstNewCases){
            caseId.add(C.Id);
            mailId =trigger.newMap.get(c.Id).Contact_Email1__c;
                if(C.ParentId != null ){
                    parentId.add(C.ParentId);
                    mapParentCaseId.put(C.Id,C.ParentId);
                    requestorId.put(C.Id,C.Contact.Id);
                    mapChildCaseId.put(C.ParentId,C.Id);
               } 
        }//end of for
             insertOrUpdate= 'I';
           // shareObj.insertUpdateShare(caseId,insertOrUpdate,mailId);
          //  shareObj.SetParentChildAccess(caseId,parentId,requestorId,mapChildCaseId,mapParentCaseId); 
      }*/
       if (trigger.isUpdate && chkShare == false){
              
              System.debug('after update chkShare' + chkShare);
         for(Case caseLoop:lstNewCases){
            /*  if((caseLoop.RecordTypeId != trigger.oldMap.get(caseLoop.Id).RecordTypeId )|| 
                   (caseLoop.Contactid != trigger.oldMap.get(caseLoop.Id).Contactid ||
                    caseLoop.ParentId != trigger.oldMap.get(caseLoop.Id).ParentId)){
                       
            */
                
                System.debug('caseLoop.RecordTypeId -->'+caseLoop.RecordTypeId );
                                lstCaseToUpdate.add(caseLoop.Id);
                mailId =trigger.oldMap.get(caseLoop.Id).Contact_Email1__c;
                
                System.debug('mailId$%$%$%$%'+mailId);
              
        System.debug('--'+mailId+'---'+lstCaseToUpdate);
     // } 

        if(caseLoop.ParentId != null ){
                 parentId.add(caseLoop.ParentId);
                mapParentCaseId.put(caseLoop.Id,caseLoop.ParentId);
 
            
            requestorId.put(caseLoop.Id,caseLoop.Contact.Id);
            mapChildCaseId.put(caseLoop.ParentId,caseLoop.Id);
        }
        system.debug('parentId--->'+parentId);

        system.debug('caseLoop.Owner --->'+caseLoop.OwnerId);
        system.debug('trigger.oldmap.get(caseLoop.Id).Owner --->'+trigger.oldmap.get(caseLoop.Id).OwnerId);
        
         if(caseLoop.OwnerId!=trigger.oldmap.get(caseLoop.Id).OwnerId || caseLoop.Contact_Email1__c!=trigger.oldmap.get(caseLoop.Id).Contact_Email1__c){
             insertOrUpdate= 'U';
             system.debug('ownerChange --->'+ownerChange);
             ownerChange  = true;
             
             if(caseLoop.OwnerId!=trigger.oldmap.get(caseLoop.Id).OwnerId){
                
                  oldUserid = trigger.oldmap.get(caseLoop.Id).OwnerId;
                   system.debug('cntUseri11d--->'+oldUserid);
             }
             else if(caseLoop.Contact_Email1__c!=trigger.oldmap.get(caseLoop.Id).Contact_Email1__c){
                   system.debug('cntUser222id--->'+oldUserid);
                
                  oldUserid = trigger.oldmap.get(caseLoop.Id).Contact_Name_User__c;
                   onlyCntChange = true;

             }

             system.debug('cntUserid--->'+oldUserid);
        }

         system.debug('caseLoop.Origin--->'+caseLoop.Origin);

        if(caseLoop.Origin!='Email' ){
        
                caseOrigin = true;
        }

     
  }
  
 
    if(lstCaseToUpdate.size()>0){
        System.debug('lstCaseToUpdate-->'+lstCaseToUpdate);
        System.debug('checkShare111'+checkShare);
        
       
      
    shareObj.insertUpdateShare(lstCaseToUpdate,insertOrUpdate,mailId,oldCaseLst,parentId,checkShare,lstNewCases ,ownerChange ,oldUserid , onlyCntChange);
        if(!Presales_CaseShare_Class.hasAlreadyChangedShare()){
        shareObj.SetParentChildAccess(lstCaseToUpdate,parentId,requestorId,mapChildCaseId,mapParentCaseId,ownerChange,caseOrigin);  
      }

    }           
  }//End of if after
 }
}
}