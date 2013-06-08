/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  09/11/2011     Shalabh Sharma          Trigger for any operation related to case creation and routing
 |  12/02/2011     Leoanrd Victor          Updated the Code to include Case Comment Updation By TC 
 |  12/20/2011     Shalabh Sharma  4822    Updated the code to throw error on parent case closure if child case is not
                                           Closed/Resolved/Rejected. 
 |  01/18/2012     Shalabh Sharma          Added a static flag to restrict the multiple execution of Presales_CheckRecordType(). 
 |  02/06/2012     Shalabh Sharma          Updated the order of execution of method checkIFRequestorUserOrContact.
 |  02/15/2012     Leonard Victor  4686    De-dup emails sent to resources from a case.
 |  05/14/2012     Leonard Victor          Added TC Validation for Partner Fields
 |  05/15/2012     Srinivas Pinnamaneni    WR192193:Modifed code to validate case types
 |  05/21/2012     Shalabh Sharma          Added TC validation for New Chatter field
 |  06/15/2012     Shalabh Sharma          Updated code to execute populateVLabRequestor method.
 |  06/20/2012     Srinivas Pinnamaneni    WR185944:Modified Code to allow search based on opportunity number.
 |  11/15/2012     Ganes Soma          WR212488:Modified Code to close resolved parent cases when child cases closes.
 |  01/01/2013     Srinivas Pinnamaneni    WR220748: Multiple Opportunities associated with one POC case.
 |  14March2013    Ganesh Soma         WR#247113    SOQL Optimization:Restricting recursive execution of the code
 +==================================================================================================================**/

trigger Presales_afterBeforeInsertUpdateOfCase on Case (before insert,before Update,after insert,after Update) {
    public static Boolean isRun = false;
    public static List<Case> lstNewCases = new List<Case>();
    if(isRun==false){
        Presales_CheckRecordType objCheckRecordType = new Presales_CheckRecordType();
        lstNewCases = objCheckRecordType.checkRecordType(trigger.new);
        System.debug('trigger.new in trigger--->'+trigger.new);
    }
    isRun=true;
    if(lstNewCases!=null && lstNewCases.size()>0){
        Presales_Operations obj = new Presales_Operations();
        Presales_VLabContactOperations objVlab = new Presales_VLabContactOperations();      
        if(trigger.isBefore && trigger.isInsert){
            List<Case> lstCase = new List<Case>();
            List<Case> lstCaseRecords = new List<Case>();
            
            system.debug('case inserted--->'+trigger.newMap);
            system.debug('case inserted--->'+trigger.new);
            objVlab.populateVLabRequestor(lstNewCases);
            obj.presalesOperationsOnInsert(lstNewCases);
            obj.populateCaseOwnerName(lstNewCases);
            
            //WR 185944 Declare Set coolelction to store Enterd Opportunity numbers in case record
            Set<String> setOppNumbers = new Set<String>();
            //WR 185944 Declare List collection to store the case records for which the Opp Number has entered
            List<Case> lstUpdateOppNameCases = new List<Case>();
            for(Case caseRecord:lstNewCases){
            system.debug('before insert case--->'+caseRecord.Send_Mail_On_Update__c);
                if(caseRecord.ContactId==null && caseRecord.Contact_Email1__c == null && caseRecord.SuppliedEmail == null){
                    lstCase.add(caseRecord);
                }
                if(caseRecord.Contact_Email1__c!=null){
                    lstCaseRecords.add(caseRecord);    
                }
                
                //WR 185944 Check if the case record opp number is not null add it to the list and also if opportunity name is selected then 
                //ignore adding it here
                if(caseRecord.Opp_Number__c != null && caseRecord.Opportunity_Name__c == null)
                {
                  //Add this to set to get the opportunity details
                  setOppNumbers.add(caseRecord.Opp_Number__c);
                  //Add this to list to update the opportunity name based on this Opportunity number
                  lstUpdateOppNameCases.add(caseRecord);
                }
                                 
            }
            if(lstCaseRecords!=null && lstCaseRecords.size()>0){
                obj.checkIFRequestorUserOrContact(lstCaseRecords);
            }
            if(lstCase.size()>0){
                obj.populateLoginUserDetails(lstCase);
            }   
            
            //WR 18599 Check If the  SetOppNumber contains records then get and uopdate the Opportunity details for the case records
            if(setOppNumbers.size() > 0)
            {
              obj.GetOpportunityDetails(lstUpdateOppNameCases,setOppNumbers);
            }
        }    
        if(trigger.isBefore && trigger.isUpdate){
            Map<Id,Case> mapTriggeredNewCases = new Map<Id,Case>(lstNewCases);
            Map<Id,Case> mapNewCase = new Map<Id,Case>();
            Map<Id,Case> mapOldCase = new Map<Id,Case>();
            List<Case> lstOfCaseOwner = new List<Case>(); 
            Map<Id,Case> mapOfCase = new Map<Id,Case>(); 
            Map<Id,Case> mapEscalatedCase = new Map<Id,Case>(); 
            Map<Id,Case> mapRoleCase = new Map<Id,Case>(); 
            Map<Id,Case> mapClosedCase = new Map<Id,Case>();
            Map<Id,Case> mapTechDrawingClosedCase = new Map<Id,Case>();
            List<Case> lstCase = new List<Case>();
            List<Case> mapSetOwnerRole = new List<Case>();//Ganesh: SOQL Optimization- 28Mar2013
            List<Id> lstCaseId = new List<Id>();
             List<String> maiList = new List<String>();   
            List<Id> cntUsrIDList = new List<Id>();
            
            //WR 185944 Declare Set coolelction to store Enterd Opportunity numbers in case record
            Set<String> setOppNumbers = new Set<String>();
            //WR 185944 Declare List collection to store the case records for which the Opp Number has entered
            List<Case> lstUpdateOppNameCases = new List<Case>();
            //WR WR220748 collection to store the case and opportunity selected.
            Map<Id,Case> mapCaseWithOpp = new Map<Id,Case>();
            
            //Srinivas: Create a case object here to store the old values (pre modified)
            Case objPreModifiedCase = new Case(); 
            //Srinvias: Get record types which used for Email to Case functionality 
            //Map<Id,RecordType> mapEmailtoCaseRecordTypes = obj.GetE2CRecordTypes();
            //Srinvias: Get "EMC Default Owner" record in to map
            //Map<Id,User> mapDefaultOwner = new Map<Id,User>([select id,name from user where name like '%EMC Default Owner%']);
            //Srinvias: Get the current user profile who is editing/updating the case
            //Profile objProfile = [select Id,Name from Profile where Id=:UserInfo.getProfileId()];
	        for(Case caseLoop: mapTriggeredNewCases.values()){	                
	                
	                //Srinivas: Get the old value of the record
	                objPreModifiedCase = Trigger.oldMap.get(caseLoop.ID);
	                
	                //Srinivas: WR192193 if case type isn't changed then show message to the user.
	                //obj.ValidateCaseType(caseLoop,objPreModifiedCase,null,
	                                        //null,objProfile);
	                    
	                //Srinivas: WR185977 To Control the dependent pick list field(previous value) from save,if  
	                //record type is changed.
	                //Srinivas:Check if the old record type and new record type are different 
	                //and the case sub type value is not different.In this case we should throw 
	                //message to user to select correct sub type
	                if((objPreModifiedCase.RecordTypeId != caseLoop.RecordTypeId) 
	                    && (objPreModifiedCase.Type == caseLoop.Type))
	                    {
	                      caseLoop.addError('The selected case sub type is not matching with the'+ 
	                                        +' selected record type');
	                      return;
	                    
	                    }
	              
	                  
	        
	            system.debug('before update case--->'+caseLoop.Send_Mail_On_Update__c);
	            system.debug('case owner--->'+caseLoop.OwnerId);
	            /*Checking if case owner is changed and is not null*/
	                if(caseLoop.OwnerId != null && caseLoop.OwnerId!= trigger.oldMap.get(caseLoop.id).OwnerId){
	                    mapNewCase.put(caseLoop.id,caseLoop);
	                    system.debug('case records--->'+mapNewCase);
	                    lstOfCaseOwner.add(caseLoop);
	                }
	
	             // Added for deleting case requestor record from Case team
	                 
	                 if(caseLoop.Status !=trigger.oldMap.get(caseLoop.Id).Status || caseLoop.IsEscalated == true){
	            
	                    lstCaseId.add(caseLoop.id);             
	                    if(caseLoop.Contact_Name_User__c != null){
	                        cntUsrIDList.add(caseLoop.Contact_Name_User__c);
	                        System.debug('cntUsrIDListinsideif'+cntUsrIDList);
	                    }
	                    else{
	                    maiList.add(caseLoop.Contact_Email1__c);
	                    System.debug('maiListinsideelse'+maiList);
	                    }
	                 }  
	                
	
	            /*Checking if the case is closed*/   
	             if(caseLoop.Status == 'Closed' && caseLoop.Status !=trigger.oldMap.get(caseLoop.Id).Status && caseLoop.Presales_Case_to_oppty_attachment__c ==false && caseLoop.Opportunity_Name__c!=null){
	                    mapClosedCase.put(caseLoop.Id,caseLoop);
	             }
	             if(caseLoop.Status == 'Closed' && caseLoop.Status !=trigger.oldMap.get(caseLoop.Id).Status && caseLoop.Case_to_Account__c==false){
	                    mapTechDrawingClosedCase.put(caseLoop.Id,caseLoop);
	             }  
	            /*Checking if case is escalated or not*/
	            if(caseLoop.isEscalated==true && caseLoop.isEscalated!=trigger.oldMap.get(caseLoop.Id).isEscalated){
	                mapEscalatedCase.put(caseLoop.Id,caseLoop);    
	            }     
	            /*Checking if contact or contact email is changed*/
	                if(caseLoop.ContactId!=trigger.oldMap.get(caseLoop.Id).ContactId || 
	                    caseLoop.Contact_Email1__c!=trigger.oldMap.get(caseLoop.Id).Contact_Email1__c){
	                    mapOfCase.put(caseLoop.Id,caseLoop);  
	                }
	                if(caseLoop.Contact_Email1__c!=null && caseLoop.Contact_Email1__c!=trigger.oldMap.get(caseLoop.Id).Contact_Email1__c
	                   || caseLoop.ContactId!=trigger.oldMap.get(caseLoop.Id).ContactId){
	                    lstCase.add(caseLoop);
	                }                
	              
	            //Ganesh: SOQL Optimization- 28Mar2013
		        if(caseLoop.OwnerId != null && caseLoop.OwnerId!= trigger.oldMap.get(caseLoop.id).OwnerId)
		        {
		        	mapRoleCase.put(caseLoop.Id,caseLoop);
		        } 
	                
	            //WR 185944 Check if the case record Opportunity Name and Opportunity Numebr are changed then only need to add 
	            //these details to set and list collections
	            if((caseLoop.Opp_Number__c != null) && 
	                ((caseLoop.Opp_Number__c != trigger.oldMap.get(caseLoop.Id).Opp_Number__c) || 
	                (caseLoop.Opportunity_Name__c != trigger.oldMap.get(caseLoop.Id).Opportunity_Name__c)))
	            {
	                //Add this to set to get the opportunity details
	                setOppNumbers.add(caseLoop.Opp_Number__c);
	                //Add this to list to update the opportunity name based on this Opportunity number
	                lstUpdateOppNameCases.add(caseLoop);
	            }
	
	        //Contact Mobile: Make contact mobile value as null if contact email or contact has changed.
	        if(caseLoop.Contact_Email1__c != trigger.oldMap.get(caseLoop.Id).Contact_Email1__c || caseLoop.ContactId != trigger.oldMap.get(caseLoop.Id).ContactId)
	            {
	                caseLoop.Contact_Mobile__c = null;
	            }
	
	        //WR220748 : Multiple Opportunities for single case.Show user if he/she selects same opportunity on case which is already selected in the related 
	            //opportunity for this case record.
	            if(caseLoop.Opportunity_Name__c != null && caseLoop.Opportunity_Name__c != trigger.oldMap.get(caseLoop.Id).Opportunity_Name__c)
	            {
	                mapCaseWithOpp.put(caseLoop.Id,caseLoop);
	            }
	            	    
	            //Ganesh: SOQL Optimization- 28Mar2013  
	            if(caseLoop.OwnerId != null && caseLoop.OwnerId!= trigger.oldMap.get(caseLoop.id).OwnerId)
	            {
	            	mapSetOwnerRole.add(caseLoop);
	            }     
	                
	        }

          if(maiList.size()>0 || cntUsrIDList.size()>0){
                
                obj.deleteCaseTeam(maiList,lstCaseId,cntUsrIDList);
            }

            if(mapOfCase.size()>0){
                obj.presalesOperationsOnUpdate(mapOfCase,trigger.oldMap);
            }
            if(mapNewCase.size()>0){
                obj.checkFirstAllocation(mapNewCase,trigger.oldMap);
            }
            
            //Ganesh: SOQL Optimization- 28Mar2013
            if(mapRoleCase.size() > 0){               
                obj.presalesOperationsSetRoleName(mapRoleCase);
            }

            //Ganesh: SOQL Optimization- 28Mar2013  
            //Added by Ganesh on Oct18,2012 -- to popualte case owner role  
            if(mapSetOwnerRole.size() > 0)
            {
            	obj.presalesOperationsSetOwnerRole(mapSetOwnerRole);
            }         
            

            if(lstOfCaseOwner.size()>0){
                obj.populateCaseOwnerName(lstOfCaseOwner);
            }
            if(lstCase.size()>0){
                obj.checkIFRequestorUserOrContact(lstCase);
            }
            if(mapEscalatedCase.size()>0){
                Presales_SendMailToManager objSendMail = new Presales_SendMailToManager();
                objSendMail.findManagerOfOwner(mapEscalatedCase);
            }
            
            //WR 185944 Check If the  SetOppNumber contains records then get and uopdate the Opportunity details for the case records
            if(setOppNumbers.size() > 0)
            {
              obj.GetOpportunityDetails(lstUpdateOppNameCases,setOppNumbers); 
            }
            
    /*If child case is not closed or resolved and user tries to close or resolve a parent case then throw an error*/        
            Map<Id,Case> mapCase = new Map<Id,Case>();
            Map<Id,Case> mapCaseUpdatedByTc = new Map<Id,Case>();
                for(Case caseLoop: mapTriggeredNewCases.values()){
                /*Checking if parent case is closed or resolved*/
                    if((caseLoop.Status == 'Closed'|| caseLoop.Status == 'Resolved'|| caseLoop.Status == 'Rejected') && caseLoop.Status != trigger.oldMap.get(caseLoop.Id).Status){
                        mapCase.put(caseLoop.Id,caseLoop);
                        
                    }
                    system.debug('caseLoop.Detailed_Product_Roll_Up_Summary__c--->'+caseLoop.Detailed_Product_Roll_Up_Summary__c);
                    //system.debug('caseLoop.Number_of_Configurations_Roll_Up_Summa__c--->'+caseLoop.Number_of_Configurations_Roll_Up_Summa__c);
                    system.debug('caseLoop.Quote_Count_Roll_Up_Summary__c--->'+caseLoop.Quote_Count_Roll_Up_Summary__c);
                    
                    //Added condition for TC Case Comment Updation
                    //14/05/2012 Added Partner Case Fields for TC validation
                    if((caseLoop.Detailed_Product_Roll_Up_Summary__c==trigger.oldMap.get(caseLoop.Id).Detailed_Product_Roll_Up_Summary__c
                     //&& caseLoop.Number_of_Configurations_Roll_Up_Summa__c
                      //  ==trigger.oldMap.get(caseLoop.Id).Number_of_Configurations_Roll_Up_Summa__c 
                      &&caseLoop.Quote_Count_Roll_Up_Summary__c==trigger.oldMap.get(caseLoop.Id).Quote_Count_Roll_Up_Summary__c)
                          &&(caseLoop.IsEscalated==trigger.oldMap.get(caseLoop.Id).IsEscalated 
                          && caseLoop.Escalation__c==trigger.oldMap.get(caseLoop.Id).Escalation__c)
                          &&(caseLoop.Count_of_Presales_Case_Comment_Rollup__c == trigger.oldMap.get(caseLoop.Id).Count_of_Presales_Case_Comment_Rollup__c)
                          &&(caseLoop.Customer_Account_Name__c == trigger.oldMap.get(caseLoop.Id).Customer_Account_Name__c)
                          &&(caseLoop.Presales_Synergy_Account_Number__c == trigger.oldMap.get(caseLoop.Id).Presales_Synergy_Account_Number__c)
                          &&(caseLoop.Partner_Case__c == trigger.oldMap.get(caseLoop.Id).Partner_Case__c)
                          &&(caseLoop.Partner_Grouping_Name__c == trigger.oldMap.get(caseLoop.Id).Partner_Grouping_Name__c)
                          &&(caseLoop.New_Chatter__c == trigger.oldMap.get(caseLoop.Id).New_Chatter__c)
                          &&(caseLoop.Environment__c == trigger.oldMap.get(caseLoop.Id).Environment__c)
                          &&(caseLoop.OS__c == trigger.oldMap.get(caseLoop.Id).OS__c)
                          &&(caseLoop.Database__c == trigger.oldMap.get(caseLoop.Id).Database__c)
                          &&(caseLoop.Current_storage__c == trigger.oldMap.get(caseLoop.Id).Current_storage__c)
                          &&(caseLoop.Application__c == trigger.oldMap.get(caseLoop.Id).Application__c)
                          &&(caseLoop.Application_Version__c == trigger.oldMap.get(caseLoop.Id).Application_Version__c)
                          &&(caseLoop.Proposed_storage__c == trigger.oldMap.get(caseLoop.Id).Proposed_storage__c)
                          &&(caseLoop.Used_Virtual_Provider__c == trigger.oldMap.get(caseLoop.Id).Used_Virtual_Provider__c)
                          &&(caseLoop.Current_Model__c == trigger.oldMap.get(caseLoop.Id).Current_Model__c)            
                          && (caseLoop!=trigger.oldMap.get(caseLoop.Id))
              ){
                            //WR199905:Add the following fields for givinig acces to requestors to change the 
                            //opportunity number and opportunity name for Vlab cases 
                            if(caseLoop.Record_Type_Name__c != 'vLab Demo' && (caseLoop.Opportunity_Name__c == trigger.oldMap.get(caseLoop.Id).Opportunity_Name__c || 
                                    caseLoop.opp_name_number__c == trigger.oldMap.get(caseLoop.Id).opp_name_number__c)) 
                            {
                              mapCaseUpdatedByTc.put(caseLoop.Id,caseLoop);
                            }
                          }
                }
                system.debug('mapCase--->'+mapCaseUpdatedByTc);
            List<Case> childCase = [select Id,Status,ParentId from Case where ParentId in :mapCase.keyset()];    
            system.debug('childCase--->'+childCase);
            if(childCase != null && childCase.size()>0){
                for(Case caseVariable : childCase){
                    if(caseVariable.Status!= 'Closed'&& caseVariable.Status!= 'Resolved' && caseVariable.Status!= 'Rejected'){                                     
                        (mapCase.get(caseVariable.ParentId)).addError(System.Label.Presales_Case_Closed);                    
                    }
                    
                }
        }
        if(mapCaseUpdatedByTc!=null && mapCaseUpdatedByTc.size()>0){
            obj.checkValidationOnCaseUpdate(mapCaseUpdatedByTc,trigger.oldMap);
        }
        Presales_Calculate_Closure_Time obj1 = new Presales_Calculate_Closure_Time();
        Map<Id,Case> mapResolvedCase = new Map<Id,Case>();
        for(Case caseRecord:mapTriggeredNewCases.values()){
            if(caseRecord.Status == 'Resolved' && caseRecord.Status != trigger.oldMap.get(caseRecord.id).Status){
                mapResolvedCase.put(caseRecord.Id,caseRecord);
            }
            else if(trigger.oldMap.get(caseRecord.id).Status== 'Resolved'&& caseRecord.Status != trigger.oldMap.get(caseRecord.id).Status){
                caseRecord.SLA_Completed__c = null;
            }
        }
        if(mapResolvedCase!=null){
            obj1.calculateClosureTime(mapResolvedCase,trigger.oldMap);         
        }
        Presales_CaseToOpportunityAttachment objAttach = new Presales_CaseToOpportunityAttachment();
           if(mapClosedCase!=null && mapClosedCase.size()>0){
                objAttach.caseAttachmentToOpportunity(mapClosedCase);
           }
           if(mapTechDrawingClosedCase.size()>0){
               objAttach.techDrawingDocsToAccount(mapTechDrawingClosedCase);
           }

       //WR WR220748    
       if(mapCaseWithOpp.size() > 0)
           {
             obj.CheckUniqueOpportunity(mapCaseWithOpp);
           }
                               
                      
        }
        /*for(Case caseRecord:lstNewCases){
            caseRecord.Validation_check_for_TC__c = false;
        }*/
        if(trigger.isInsert&& trigger.isAfter){
            List<Case> lstCaseToUpdate = new List<Case>();
            List<Case> lstCaseToUpdateAccount = new List<Case>();
            List<Case> lstCustomerAccountOnCase = new List<Case>();
            List<Case> lstContactMobile = new List<Case>();//Ganesh: SOQL Optimization- 28Mar2013
            Map<Id,Case> mapCaseFollower = new Map<Id,Case>();
            for(Case caseLoop: lstNewCases){
           
                if(caseLoop.Opportunity_Name__c != null){
                    lstCaseToUpdate.add(caseLoop);
                }
                if(caseLoop.Customer_Account_Name__c != null){
                    lstCaseToUpdateAccount.add(caseLoop);
                }
                if(caseLoop.Presales_Synergy_Account_Number__c != null){
                    lstCustomerAccountOnCase.add(caseLoop);
                }
                if(caseLoop.Contact_Email1__c != null){
                    mapCaseFollower.put(caseLoop.Id,caseLoop);
                }
                
                //Ganesh: SOQL Optimization- 28Mar2013  
                //Contact Mobile:Populate contact mobile field value here
		        if(caseLoop.Contact_Email1__c != null)
		        {
		        	lstContactMobile.add(caseLoop);
		        }
            }
            if(lstCaseToUpdate.size()>0){
                obj.updateAccountDetails(lstCaseToUpdate);
            }
            if(lstCaseToUpdateAccount.size()>0){
                obj.updateSynergyAccountNumber(lstCaseToUpdateAccount);
            }
            if(lstCustomerAccountOnCase.size()>0){
                obj.updateCustomerAccount(lstCustomerAccountOnCase);
            }
            if(mapCaseFollower.size()>0){
                Presales_SendMailToManager obj1 = new Presales_SendMailToManager();
                obj1.addOwnerToFollower(mapCaseFollower,true);
            }

            //Ganesh: SOQL Optimization- 28Mar2013  
	        //Contact Mobile:Populate contact mobile field value here
	        if(lstContactMobile.size() > 0)
	        {
	        	obj.presalesOperationsSetMobile(lstContactMobile);
	        }

            //obj.autoAssignmentToQueue(lstNewCases);
            /*Presales_Escalate_Case classObj = new Presales_Escalate_Case();
            classObj.testSendEmail(trigger.new);*/
            
            //  List<CaseShare> shrLstAfetrInsert2 = [Select CaseId,Id,UserOrGroupId from CaseShare where caseid =:lstNewCases[0].Id];
      // System.debug('after after-->'+shrLstAfetrInsert2);
        }
        if(trigger.isUpdate && trigger.isAfter){
            Presales_SendMailToManager obj1 = new Presales_SendMailToManager();
            List<Case> lstCaseToUpdate = new List<Case>();
            List<Case> lstCaseToUpdateAccount = new List<Case>();
            Map<Id,Case> mapClosedCase = new Map<Id,Case>();
            List<Case> lstAccountOnCase = new List<Case>();
            Map<Id,Case> mapNewCase = new Map<Id,Case>();
            Map<Id,Case> mapChangeOwnerEntity = new Map<Id,Case>();//Ganesh: SOQL Optimization- 28Mar2013
            Map<Id,Case> mapChangeContactEntity = new Map<Id,Case>();//Ganesh: SOQL Optimization- 28Mar2013
        //Contact Mobile: Create a list to store cases to update mobile field
            List<Case> lstCasesToUpdateContactMobile = new List<Case>();
            Map<Id,Case> mapTriggeredNewCases = new Map<Id,Case>(lstNewCases);
            Map<Id,Case> mapOwnerChange = new Map<Id,Case>();
            Map<Id,Case> mapCloseCase = new Map<Id,Case>();
        //Ganesh
            Map<Id,Case> mapParentCases = new Map<Id,Case>();
            for(Case caseLoop: mapTriggeredNewCases.values()){
            system.debug('sla completed date--->'+caseLoop.SLA_Completed__c);
                if((caseLoop.Opportunity_Name__c != null && caseLoop.Opportunity_Name__c != trigger.oldMap.get(caseLoop.Id).Opportunity_Name__c)
                    ||caseLoop.Opportunity_Name__c != null && caseLoop.Customer_Account_Name__c != trigger.oldMap.get(caseLoop.Id).Customer_Account_Name__c ){
                    lstCaseToUpdate.add(caseLoop);
                }
                system.debug('caseLoop.Opp_Number__c '+caseLoop.Opp_Number__c);
                system.debug('caseLoop.Opp_Number__c old '+trigger.oldMap.get(caseLoop.Id).Opp_Number__c);
                //WR185944 Add the list of cases to update if the Opportunity number has modified
                if((caseLoop.Opp_Number__c != null && caseLoop.Opp_Number__c != trigger.oldMap.get(caseLoop.Id).Opp_Number__c)
                    ||caseLoop.Opp_Number__c != null && caseLoop.Customer_Account_Name__c != trigger.oldMap.get(caseLoop.Id).Customer_Account_Name__c 
                    || caseLoop.Opp_Number__c != trigger.oldMap.get(caseLoop.Id).Opp_Number__c){
                    lstCaseToUpdate.add(caseLoop);
                }
                if(caseLoop.Customer_Account_Name__c != null && caseLoop.Customer_Account_Name__c != trigger.oldMap.get(caseLoop.Id).Customer_Account_Name__c){
                    lstCaseToUpdateAccount.add(caseLoop);
                }
                if(caseLoop.Presales_Synergy_Account_Number__c != null && caseLoop.Presales_Synergy_Account_Number__c != trigger.oldMap.get(caseLoop.Id).Presales_Synergy_Account_Number__c){
                    lstAccountOnCase.add(caseLoop);
                }
                if(caseLoop.Contact_Email1__c!= null && caseLoop.Contact_Email1__c!= trigger.oldMap.get(caseLoop.Id).Contact_Email1__c){
                    mapNewCase.put(caseLoop.Id,caseLoop);
                    //Ganesh: SOQL Optimization- 28Mar2013
                    mapChangeOwnerEntity.put(caseLoop.Id,trigger.oldMap.get(caseLoop.Id));
                    //obj1.removeOldOwnerRequestor(trigger.oldMap,false);
                }
                if(caseLoop.OwnerId!= null && caseLoop.OwnerId!= trigger.oldMap.get(caseLoop.Id).OwnerId){
                    mapOwnerChange.put(caseLoop.Id,caseLoop);
                    //Ganesh: SOQL Optimization- 28Mar2013
                    mapChangeContactEntity.put(caseLoop.Id,trigger.oldMap.get(caseLoop.Id));
                    //obj1.removeOldOwnerRequestor(trigger.oldMap,true);
                }
                if(caseLoop.Status == 'Closed' && caseLoop.Status != trigger.oldMap.get(caseLoop.Id).Status){
                    mapCloseCase.put(caseLoop.Id,caseLoop);
                }

        //Contact Mobile:Check if contact email is changed then only we have to update the contact mobiel value
        if(caseLoop.Contact_Email1__c != trigger.oldMap.get(caseLoop.Id).Contact_Email1__c || caseLoop.Contact_Mobile__c == null)
                {
                  lstCasesToUpdateContactMobile.add(caseLoop);
                }

         //Ganesh - Prepare map with parentId and corresponding child cases             
                if(caseLoop.ParentId!=null &&  ( (caseLoop.Status == 'Closed' && caseLoop.Status != trigger.oldMap.get(caseLoop.Id).Status) || (caseLoop.Status == 'Rejected' && caseLoop.Status != trigger.oldMap.get(caseLoop.Id).Status) ) ){
                    mapParentCases.put(caseLoop.ParentId,caseLoop);
                }
            }

         //Ganesh
            if(mapParentCases.size()>0){                
                obj.CloseParentCaseIfSLACompleted(mapParentCases);               
            }

            if(lstCaseToUpdate.size()>0){
                obj.updateAccountDetails(lstCaseToUpdate);
            }
            if(lstCaseToUpdateAccount.size()>0){
                obj.updateSynergyAccountNumber(lstCaseToUpdateAccount);
            }
            if(lstAccountOnCase.size()>0){
                obj.updateCustomerAccount(lstAccountOnCase);
            }
            if(mapNewCase.size()>0){
                
                obj1.addOwnerToFollower(mapNewCase,true);
            }
            if(mapOwnerChange.size()>0){               
                obj1.addOwnerToFollower(mapOwnerChange,false);
            }
            if(mapCloseCase.size()>0){               
                obj1.removeFollowersOnClosure(mapCloseCase);
            }
        
        //Contact Mobile:Populate contact mobile field value here
            if(lstCasesToUpdateContactMobile.size() > 0)
            {
                obj.presalesOperationsSetMobile(lstCasesToUpdateContactMobile);
            }
            
            //Ganesh: SOQL Optimization- 28Mar2013
            if(mapChangeOwnerEntity.size() > 0)
            {
              obj1.removeOldOwnerRequestor(mapChangeOwnerEntity,false);
            }
            //Ganesh: SOQL Optimization- 28Mar2013
            if(mapChangeContactEntity.size() > 0)
            {
              obj1.removeOldOwnerRequestor(mapChangeContactEntity,true);
            }
            
            

            //Presales_CaseToOpportunityAttachment objAttach = new Presales_CaseToOpportunityAttachment();
            //if(mapClosedCase!=null && mapClosedCase.size()>0){
                //objAttach.caseAttachmentToOpportunity(mapClosedCase);
            //}
            // List<CaseShare> shrLstAfetrInsert1 = [Select CaseId,Id,UserOrGroupId from CaseShare where caseid =:lstNewCases[0].Id];
            //System.debug('after update -->'+shrLstAfetrInsert1);
        }
        if((trigger.IsAfter && trigger.isInsert)||(trigger.isBefore&& trigger.isUpdate)){
            string chkType;
            if(trigger.isUpdate){
                chkType='Update';
            }
            else if(trigger.isInsert){
                chkType='Insert';
                //checkShare = true;
            }
            system.debug('lstNewCases in trigger--->'+ lstNewCases);
            Presales_SLA_Class objSLA = new Presales_SLA_Class();
            if(!Presales_SLA_Class.hasAlreadyChanged()){
                objSLA.presalesStdCaseTime(lstNewCases,chkType);
            } 
        }    
    }
    
 }