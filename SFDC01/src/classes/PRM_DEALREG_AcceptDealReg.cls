/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  26.04.2011      Ashwini Gowda              This Class would be invoked from "Accept Deal Reg" button on the Deal Reg
 |                                             to allow the PSC User to Accept Deal Reg.
 |  23.05.2011      Ashwini Gowda   Def397     Changed Mapping from PSC User to DealReg_PSC_Owner__c
 |  26.05.2011      Ashwini Gowda              Introduced functionality for Approving and Rejecting a DR.  
 |  13.05.2011      Anirudh Singh   4133       Updated logic to Allow PSC Users to Reject/Approve Deal Regs if
 |                                             PSC Owner field is populated.      
    16 Nov 2011     Arif            181055     Only PSC Can approve/reject a DR.
    26 Apr 2012     Anirudh         185302     Updated ApproveDealReg to remove two step Approval Process of EMEA.
    30 Apr 2012     Arif            Defect 815 Added a code to change the comment if DR get approved after rejection. 
    25 Mar 2013     Uday Annapareddy  246616   Splitting the Context to reduce the SOQL queries on Approving rejected DR                      
 +=========================================================================================================================*/
global class PRM_DEALREG_AcceptDealReg{ 
    
/* @Method <This method is called on click on Accept Deal Reg Button,used to update PSC User Field on lead record
            with the user who clicks that button.>
    @param <It is taking LeadId as parameter>
    @return String of Success/Exception>
    @throws exception - <No Exception>
*/
    webservice static string AcceptDealReg(Id leadId) { 
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c siteUserId = DataValueMap.get('PSC User');
        String userProfile = Userinfo.getProfileId();
        String pscUser = siteUserId.DataValue__c;
        CustomSettingDataValueMap__c UserError = DataValueMap.get('PSC User Error MSG');
        
        if(userProfile != null && userProfile.length() >15){
            userProfile = userProfile.substring(0, 15);
        }
        string result;
        System.debug('System_Admin_API_Only__c-->'+Profiles__c.getInstance().System_Administrator__c);
        if(UserInfo.getProfileId().contains(Profiles__c.getInstance().System_Administrator__c)){
            Lead dealReg = [select id,DealReg_PSC_Owner__c,DealReg_Theater__c from lead where id  =: leadId limit 1];
            try{
                dealReg.DealReg_PSC_Owner__c = UserInfo.getUserId();  
                update dealReg;
                result = 'success';                   
            } 
            catch(Exception e){ 
                result = e.getMessage();
            }
        }
        else if(pscUser.contains(userProfile)){
            Lead dealReg = [select id,DealReg_PSC_Owner__c,DealReg_Theater__c from lead where id  =: leadId limit 1];           
            if(DataValueMap.ContainsKey(dealReg.DealReg_Theater__c)){
                System.debug('DealReg_Theater__c'+dealReg.DealReg_Theater__c);
                System.debug('DataValueMap'+DataValueMap.get(dealReg.DealReg_Theater__c).DataValue__c);
                if((DataValueMap.get(dealReg.DealReg_Theater__c) != null) && (DataValueMap.get(dealReg.DealReg_Theater__c).DataValue__c != null)){
                    if(DataValueMap.get(dealReg.DealReg_Theater__c).DataValue__c.contains(userProfile)){
                        try{
                            dealReg.DealReg_PSC_Owner__c = UserInfo.getUserId();  
                            update dealReg;
                            result = 'success';                   
                        } 
                        catch(Exception e){ 
                            result = e.getMessage();
                        }
                    }
                    else{
                        result = UserError.DataValue__c;
                    } 
                }
            }
            else{
                result = UserError.DataValue__c;
            } 
        }
        else{           
            result = UserError.DataValue__c;
        }
            
        return result;
    }
    
  
 
 /* @Method <This method is called on click on Approve Button,used to Approve a DR by PSC User on Internal DR Layout.>
    @param <It is taking Extension_Request__c id as parameter>
    @return String of Success/Exception>
    @throws exception - <No Exception>
*/
    
   webservice static string ApproveDealReg(Id approveDealRegId) {
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c customSetting = DataValueMap.get('PSC User');
        String userProfile = Userinfo.getProfileId();
        String pscUser = customSetting.DataValue__c;
         String message;
        Lead approveDealReg = [select id,DealReg_PSC_Owner__c,DealReg_Theater__c,DealReg_Deal_Registration_Status__c,DealReg_Comments__c 
                              from lead 
                              where id  =: approveDealRegId limit 1];
          if(approveDealReg.DealReg_Deal_Registration_Status__c=='Approved'){
            message = System.Label.Deal_Reg_is_already_Approved;
        }
        else if(approveDealReg.DealReg_Deal_Registration_Status__c!='PSC Declined'){
      	 message = System.Label.You_cannot_accept_or_reject ;
        }
        else if(approveDealReg.DealReg_PSC_Owner__c == null){
            message = System.Label.Accept_Deal_Reg_Button_before_Approving_or_Rejecting;
        }
        //Added By Arif WR 181055
        else if(!pscUser.contains(userProfile)){
       	 message = System.Label.You_cannot_accept_or_reject;
        }
        else{
            Savepoint sp;
            try{
                sp = database.setSavepoint();
                //Defect 815
                approveDealReg.DealReg_Comments__c = '';
                update approveDealReg;
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval.');
                req1.setObjectId(approveDealReg.id);
                Approval.ProcessResult result = Approval.process(req1);
                List<Id> newWorkItemIds = result.getNewWorkitemIds();
                // Instantiate the new ProcessWorkitemRequest object and populate it
                Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                req2.setComments('Approving Request.');
                req2.setAction('Approve');
                req2.setWorkitemId(newWorkItemIds.get(0));
                // Submit the request for approval
                Approval.ProcessResult result2 = Approval.process(req2);            
                message = 'success';
            }
            Catch(Exception ex){ 
                Database.rollback(sp);
                String strErrorMessage = 'Error : '+ ex.getMessage();               
                if(strErrorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                    strErrorMessage = strErrorMessage.substring(strErrorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 35);
                }              
                if(strErrorMessage.endsWith(': []')){
                    strErrorMessage = strErrorMessage.substring(0, strErrorMessage.length() -4);
                }
                message = strErrorMessage;
            }
        }   
        return message;
    } 
 // WR 246616 Start    
 /* @Method <This method is called on click on Approve Button,used to Approve a DR by PSC User on Internal DR Layout.>
    @param <It is taking Extension_Request__c id as parameter>
    @return String of submissionsuccess and id of approvalsubmission/Exception>
    @throws exception - <No Exception>
*/
    
    webservice static string ApproveDealRegbutton(Id approveDealRegId) {
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c customSetting = DataValueMap.get('PSC User');
        String userProfile = Userinfo.getProfileId();
        String pscUser = customSetting.DataValue__c;
         String message;
        Lead approveDealReg = [select id,DealReg_PSC_Owner__c,DealReg_Theater__c,DealReg_Deal_Registration_Status__c,DealReg_Comments__c 
                              from lead 
                              where id  =: approveDealRegId limit 1];
        if(approveDealReg.DealReg_Deal_Registration_Status__c=='Approved'){
            message = System.Label.Deal_Reg_is_already_Approved;
        }
        else if(approveDealReg.DealReg_Deal_Registration_Status__c!='PSC Declined'){
         message = System.Label.You_cannot_accept_or_reject ;
        }
        else if(approveDealReg.DealReg_PSC_Owner__c == null){
            message = System.Label.Accept_Deal_Reg_Button_before_Approving_or_Rejecting;
        }
        //Added By Arif WR 181055
        else if(!pscUser.contains(userProfile)){
         message = System.Label.You_cannot_accept_or_reject;
        }
        else{
            Savepoint sp;
            try{
                sp = database.setSavepoint();
                //Defect 815
                approveDealReg.DealReg_Comments__c = '';
                update approveDealReg;
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval.');
                req1.setObjectId(approveDealReg.id);
                Approval.ProcessResult result = Approval.process(req1);
                List<Id> newWorkItemIds = result.getNewWorkitemIds();
              // Splitting this approval process into submission and then approval or rejected                
                message = 'submissionsuccess,'+newWorkItemIds.get(0);
             
            }
            Catch(Exception ex){ 
                Database.rollback(sp);
                String strErrorMessage = 'Error : '+ ex.getMessage();               
                if(strErrorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                    strErrorMessage = strErrorMessage.substring(strErrorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 35);
                }              
                if(strErrorMessage.endsWith(': []')){
                    strErrorMessage = strErrorMessage.substring(0, strErrorMessage.length() -4);
                }
                message = strErrorMessage;
            }
        }   
        return message;
    } 
    
    /* @Method <This method is called on from javascript once the submission is success>
    @param <It is taking id of approval process as parameter>
    @return String of Success/Exception>
    @throws exception - <No Exception>
*/

    
    webservice static string approve(string approveprocessDealRegId) {
        String message;
        Savepoint sp;
        try{
             //convert the string we got as attribute into id
             id id1 = Id.valueOf(approveprocessDealRegId);
             sp = database.setSavepoint();
                // Instantiate the new ProcessWorkitemRequest object and populate it
                Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                req2.setComments('Approving Request.');
                req2.setAction('Approve');
                req2.setWorkitemId(id1);
                // Submit the request for approval
                Approval.ProcessResult result2 = Approval.process(req2);            
                message = 'success';
            }
            Catch(Exception ex){ 
                system.debug('exception'+ex);
                Database.rollback(sp);
                String strErrorMessage = 'Error : '+ ex.getMessage();               
                if(strErrorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                    strErrorMessage = strErrorMessage.substring(strErrorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 35);
                }              
                if(strErrorMessage.endsWith(': []')){
                    strErrorMessage = strErrorMessage.substring(0, strErrorMessage.length() -4);
                }
                message = strErrorMessage;
            }
          
        return message;
    }
 // WR 246616 Start    
    //Added by Krishna
 webservice static string FieldApprovalNotification(Id leadid){
 	Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
    CustomSettingDataValueMap__c customSetting = DataValueMap.get('PSC User');
 	String userProfile = Userinfo.getProfileId();
 	String pscUser = customSetting.DataValue__c;
 	String message;
 	if(pscUser.contains(userProfile)){
         message = System.Label.DR_Conversion_Error;
     }
    return message; 
     
 }  
}