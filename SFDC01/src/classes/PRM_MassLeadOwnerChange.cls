/*=========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  11.10.2010      Anand Sharma    #1185       Controller for the PRM_MassLeadOwnerChange page. 
                                                This will used to chnage the owner of selected lead.
 |  21.11.2010      Anand Sharma                Update code to handle exception for permission on object record.
 |  24.11.2010      Anand Sharma                Fix the url issue after save, Added null check before create url
                                                Added error message, if more that 200 lead is selected.                                                 
 |  25.11.2010      Anand Sharma                Added Lead name when occur on change of lead owner   
 +========================================================================================================================*/

public with sharing class PRM_MassLeadOwnerChange {
    
    /* variable hold the selected leads */
    private List<Lead> selectedLeads_List;      
    private Set<Id> leadId_Set; 
    
    public String strLeadViewId {get; set;} 
    public Boolean isSuccess {get;set;}
    public SearchUserQueueController objSearchUserQueueCon {get; set;}
    
    
    /* constructor */
    public PRM_MassLeadOwnerChange(ApexPages.StandardSetController controller) {
        
        /* intialize local vairable */
        isSuccess = false;
        strLeadViewId='';
        leadId_Set = new Set<Id>();

        objSearchUserQueueCon = new SearchUserQueueController();
        
        /* Get Lead View id from url */
        String leadViewId = ApexPages.currentPage().getParameters().get('fcf'); 
            
        if(leadViewId !=null){
            strLeadViewId = leadViewId;
        } 

        /* Get List of all lead which are selected */
        selectedLeads_List =(List<Lead>) controller.getSelected();  
            
    }
        
    /* @Method <This Method is used to fetch lead record with owner.>.
        @param <It is not taking any parameters>
        @return <List<Lead> object>
        @throws exception - <No Exception>
    */
    public PageReference FetchLeadRecords(){
        
        /* add selected lead ids into set  */
        if(this.selectedLeads_List.size()>0 && this.selectedLeads_List.size() <= 200 ){         
            for(Lead objLead : this.selectedLeads_List){
                leadId_Set.add(objLead.Id);
            }                       
            /* fetch lead record with owner using set of leads id */
            this.selectedLeads_List = [Select Id,Name, Ownerid from Lead where id in:leadId_Set limit 10000];            
            System.debug('Selected lead from views with deatils :' + selectedLeads_List);            
            isSuccess = true;           
        }else if(this.selectedLeads_List.size() > 200){
            isSuccess = false;
            Apexpages.Message apexMsg = new Apexpages.Message(ApexPages.Severity.INFO, 
                                            System.Label.PRM_Lead_Owner_Change_MoreThan200_Selected_Lead);
            Apexpages.addMessage(apexMsg);
        }else{
            isSuccess = false;
            Apexpages.Message apexMsg = new Apexpages.Message(ApexPages.Severity.INFO, 
                                            System.Label.PRM_Lead_Owner_Change_No_Selected_Lead);
            Apexpages.addMessage(apexMsg);
        }
        
        return null;
    } 
    
    
    /* @Method <This Method is used to update lead owner.>.
        @param <It is not taking any parameters>
        @return <Pagereference>
        @throws exception - <No Exception>
    */
    public void ChangeOwner(){

        List<Lead> updateLead_List = new List<Lead>();
        String strOldLeadOwner =''; 
        Integer insuffCount =0;     
        strOldLeadOwner = objSearchUserQueueCon.selectedOwnerId;
        System.debug('Selected objSearchUserQueueCon.selectedOwnerId :' + objSearchUserQueueCon.selectedOwnerId);
        System.debug('Selected selectedLeads_List :' + selectedLeads_List);
        if(this.selectedLeads_List.size() >0){
            
            Set<String> leadOwnerIds_Set = new Set<String>();
            for(Lead objLead :this.selectedLeads_List){
                leadOwnerIds_Set.add(objLead.OwnerId);
            }
            leadOwnerIds_Set.add(UserInfo.getUserId());
            Map<Id,User> leadOwner_map = new Map<Id,User>([SELECT Id, Name , ContactId, AccountId, Contact.AccountId, 
                                                    UserRoleId, UserRole.Name 
                                            FROM User 
                                            WHERE Id in : leadOwnerIds_Set]);
                                            
            System.debug('Selected leadOwnerIds_Set :' + leadOwnerIds_Set);                                
            for(Lead objLeadRecord : selectedLeads_List){
                /* validate if old owner of lead new not same as new owner */               
                if(strOldLeadOwner !=null){
                    if(strOldLeadOwner.length() >=15){
                        strOldLeadOwner = strOldLeadOwner.substring(0,15);
                    }                   
                }
                if(strOldLeadOwner != objLeadRecord.OwnerId){                   
                    /* Validate role heriracy */
                    if(UserInfo.getUserType() =='PowerPartner'){
                        System.debug('objLeadRecord :' + objLeadRecord);
                        User objUserRecord =  leadOwner_map.get(objLeadRecord.OwnerId);
                        System.debug('objUserRecord :' + objUserRecord);
                        String strLeadOwnerid =objLeadRecord.OwnerId;
                        if(strLeadOwnerid.substring(0,3)=='00G'){
                            /* set new owner of lead */
                            objLeadRecord.OwnerId = objSearchUserQueueCon.selectedOwnerId;
                            /* add into list of update lead */
                            updateLead_List.add(objLeadRecord);
                        }else if(objUserRecord != null && ValidateLeadOwnerRole(objUserRecord, leadOwner_map)){
                            /* set new owner of lead */
                            objLeadRecord.OwnerId = objSearchUserQueueCon.selectedOwnerId;
                            /* add into list of update lead */
                            updateLead_List.add(objLeadRecord);
                        }else{
                            insuffCount ++;
                        }                       
                    }else{
                        /* set new owner of lead */
                        objLeadRecord.OwnerId = objSearchUserQueueCon.selectedOwnerId;
                        /* add into list of update lead */
                        updateLead_List.add(objLeadRecord);
                    }
                }           
            }
            
            System.debug('Selected Before update updateLead_List :' + updateLead_List); 
            
            // Create a savepoint because the data should not be committed to the database              
            Savepoint spUpdateLead = Database.setSavepoint();
            
            if(updateLead_List.size() >0 && insuffCount ==0){
                System.debug('inside update list:');
                Database.SaveResult[] arrLeadUpdateResult = Database.update(updateLead_List,false);
                Integer intCountfail = 0;
                String dataErrs = '';
                
                for (integer i = 0; i < arrLeadUpdateResult.size(); i++) {
                    Database.SaveResult objResult = arrLeadUpdateResult[i];
                    System.debug('+++ objResult--->'+ objResult);
                    if (!objResult.isSuccess()) {
                        // we log the data error                  
                        for (Database.Error err : objResult.getErrors()) {
                            if(err.getMessage().contains('insufficient access rights')){
                                intCountfail ++;
                                continue;
                            }else{
                                dataErrs += updateLead_List.get(i).Name  + ' : ('+ updateLead_List.get(i).Id + ') : ' + err.getMessage() + ' ';
                            }                        
                        }                                            
                    }
                }
                if(intCountfail >0 || dataErrs !=''){
                    isSuccess = false;
 
                    // Revert the database to the original state
                    Database.rollback(spUpdateLead);
                    
                    String error ='';
                    if(intCountfail >0){
                        
                        error = System.Label.PRM_Lead_Owner_Change_Privilege_Message_1 + ' ' + intCountfail + 
                        ' ' + System.Label.PRM_Lead_Owner_Change_Privilege_Message_2 + ' ' + selectedLeads_List.size() 
                        + ' ' + System.Label.PRM_Lead_Owner_Change_Privilege_Message_3 ;
                        
                    }else{
                        error = dataErrs; 
                    }
                    Apexpages.Message apexMsg = new Apexpages.Message(ApexPages.Severity.INFO, 
                                                    error);
                    Apexpages.addMessage(apexMsg);
                }else{              
                    isSuccess = true; 
                }
            }else if(insuffCount >0){
                isSuccess = false;              
                String error =System.Label.PRM_Lead_Owner_Change_Privilege_Message_1 + ' ' + insuffCount + 
                    ' ' + System.Label.PRM_Lead_Owner_Change_Privilege_Message_2 + ' ' + selectedLeads_List.size() 
                    + ' ' + System.Label.PRM_Lead_Owner_Change_Privilege_Message_3 ;
                Apexpages.Message apexMsg = new Apexpages.Message(ApexPages.Severity.INFO, 
                                            error);
                Apexpages.addMessage(apexMsg);             
            }
            else{
                isSuccess = true;               
            }               
            System.debug('isSuccess :' + isSuccess);    
        }           
    }
    
    /* @Method <This Method is used to redirect on lead view record.>.
        @param <It is not taking any parameters>
        @return <Pagereference>
        @throws exception - <No Exception>
    */
    public PageReference Cancel(){
        PageReference objLeadViewPage = new PageReference('/00Q?');
        if(strLeadViewId !=''){
            objLeadViewPage.getParameters().put('fcf',strLeadViewId);
        }       
        objLeadViewPage.setRedirect(true);
        return objLeadViewPage;
    }
    
    /* @Method <This Method is used to validate permission to change the owner of lead records.>.
        @param <It is not taking any parameters>
        @return <Pagereference>
        @throws exception - <No Exception>
    */
    public Boolean ValidateLeadOwnerRole(User objLeadOwnerRecord, Map<Id,User> leadOwner_map){
        Boolean bResult = false;
        
        User LeadOwnerRecord = objLeadOwnerRecord;
        System.Debug('++LeadOwnerRecord++ ' + LeadOwnerRecord);
        if(LeadOwnerRecord.UserRoleId != null){
            String LeadOwnerRoleName = LeadOwnerRecord.UserRole.Name;            
            User loginUser = leadOwner_map.get(Userinfo.getUserId());
            if(loginUser.UserRoleId != null){
                String loginUserRole = loginUser.UserRole.Name;         
                if(loginUser.Id == LeadOwnerRecord.Id){
                    bResult = true;
                }else{
                    if(loginUserRole.contains(System.Label.PRM_Lead_Owner_Change_Role_PartnerExecutive))    {
                        if(!LeadOwnerRoleName.contains(System.Label.PRM_Lead_Owner_Change_Role_PartnerExecutive) ){
                            bResult = true;
                        }           
                    }else if(loginUserRole.contains(System.Label.PRM_Lead_Owner_Change_Role_PartnerManager)){
                        if(!LeadOwnerRoleName.contains(System.Label.PRM_Lead_Owner_Change_Role_PartnerExecutive) ){
                            if(!LeadOwnerRoleName.contains(System.Label.PRM_Lead_Owner_Change_Role_PartnerManager)){
                                bResult = true;
                            }
                            
                        }
                    }else if(loginUserRole.contains(System.Label.PRM_Lead_Owner_Change_Role_PartnerUser )){
                        bResult = false;
                    }
                }
            }            
        }                              
                                
        return bResult;                                     
    }   
}