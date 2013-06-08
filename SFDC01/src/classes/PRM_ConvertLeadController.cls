/*=======================================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR          DESCRIPTION                               

 |  ====          =========                ==          =========== 

 |  8/7/2010     Ashwini Gowda          ReqtID 043     This class will be called by PRMDispositionLead VF Page.
                                                       Ability for Lead Owner (Partner) and designated EMC user (i.e. CAM)
 |                                                     to convert lead to an opportunity through status change or  
                                                       conversion button. Resulting opportunity should not be visible to 
 |                                                     Partner in portal. 
 
 |  30/7/2010   Ashwini Gowda                          If Related Account is not populated update the Lead status to 
                                                       Converted to Opportunity.
 |  29/9/2010   Prasad Kothawade        Defect 121     Added new picklist values in closed Reason. 
    25/10/2010  Ashwini Gowda           Req #1060      Updated Method dealRegistration() with try
                                                       Catch block to display any error messages 
                                                       if any during update of lead.
 |  27/10/2010  Karthik Shivprakash     Defect#148     Changed the getClosedList() method to fetch the picklist
                                                       values dynamically from schema.
 |  18/05/2011  Anand Sharma            Req # 2776     When the user clicks on â€œConvert to Deal Regâ€, the Lead Record type should be 
                                                       updated to â€œDeal Registrationâ€ Record type.
 |                                                     Updated method dealRegistration , add record type as deal Registration   
    04/08/2011  Prasad Kothawade                       Update on Deal Convert - Added address and record type as per account.       
 |  
    18 Aug 2011  Arif                    3657          Addition of calling validate() method in updateDealReg()
 |  18 Aug 2011  Arif                    3670          Added a line for populating Lead_Converted_to_DR_Date_Time__c field on DealRegistration method  
    30 Aug 2011  Shravanthi J           INC IM6994875  Assigned default values to Deal Reg Type and Submission Source fields.  
 |  27 June 2012 Ganesh                 194416         When the user clicks on Convert to Deal Reg, the Lead Record type should be 
                                                       updated to Deal Registration - Submitted Record type irrespective of value in Related Account. 
 |  31 May 2012  Anirudh Singh          194959         Updated controller to set showNonDealRegButton which will control the visibility of the
                                                       Non Deal Registration as  per the Theater of the logged in User.                                                    
 +=======================================================================================================================================*/

Public class PRM_ConvertLeadController{
    
    Public Lead lead;
    boolean showClosedReason = false;
    boolean showOkButton = false;
    boolean showErrorMessage = false;
    boolean showCancelButton = false; 
    public Boolean isDealReg {get; set;}
    boolean showNonDealRegButton = true;  
    
    //Extending the standard controller for Lead.
    public PRM_ConvertLeadController(ApexPages.StandardController controller){ 
        Map<String,CustomSettingDataValueMap__c> dataValueMap = CustomSettingDataValueMap__c.getall();
        string APJPartnerProfiles = dataValueMap.get('APJPartnerUsers').DataValue__c;
        isDealReg = false; 
        String strDealReg = ApexPages.currentPage().getParameters().get('DealReg'); 
        if(strDealReg != null || strDealReg != '' && strDealReg=='true'){
            isDealReg = true;
        }       
        if(APJPartnerProfiles.contains(userInfo.getProfileId())){
           showNonDealRegButton=false; 
        }      
        String leadId =ApexPages.currentPage().getParameters().get('Id');    
        lead = [Select l.Accept_Lead__c,l.OwnerId,l.Closed_Reason__c, l.Status,l.Country, l.Country__c, l.Related_Account__c, 
                    l.RecordTypeId, l.DealReg_Deal_Registration__c , l.Partner__c, l.Tier_2_Partner__c, l.DealReg_Theater__c, Theater__c
                from Lead l  where l.Id=:leadId];         
    }
    
    /**
        * Method <validate()is for validating certain fields on Lead>
        *   @param <This method is not taking any arguments.> 
        *   @return <void> - <Not Returning anything>
        *   @throws exception-<No exception >
     */
    public void validate(){
    //Get the current Lead Id
        Map<String,OpportunityIntegration__c> customSettingValue = OpportunityIntegration__c.getAll();
        if(UserInfo.getUserId() != customSettingValue.get('Admin Conversion').Admin_Conversion__c){
        //Check if the status of the lead is closed.If so then throw error message.
            if(lead.Status == 'Closed'){
                displayErrorMessage(System.Label.Status_of_Lead);
            }
            //Check if the Accept Lead is not checked.If so then throw error message.
            if(lead.Accept_Lead__c==false){
                 displayErrorMessage(System.Label.AcceptLead);
            }
            //Check if the User Performing Operation on Lead is not the owner of the Lead.If so then throw error message.
            if(lead.OwnerId!=UserInfo.getUserId()){
                displayErrorMessage(System.Label.NotOwner);
            }
             //Check if the status of Lead is Converted to Opportunity.If so then throw error message.
            if(lead.Status == 'Converted to Opportunity'){
                displayErrorMessage(System.Label.Converted_Lead);
            }
        }     
    }
    
    /**
        * Method <displayErrorMessage(String ErrorMessage)is for displaying appropirate error message>
        *   @param <This method is taking String as a argument.> 
        *   @return <void> - <Not Returning anything>
        *   @throws exception-<No exception >
     */
    public void displayErrorMessage(String ErrorMessage){
        ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.ERROR,ErrorMessage);
        ApexPages.addMessage(msg1);
        showErrorMessage =  true;
        showCancelButton = true;
    }
    
    /**
        * Method <dealRegistration():This method would be called on 
            click of Deal Registration Button.Updates the Status to 
            Closed with Closed Reason Pending Deal Registration. >
        *   @param <This method is not taking any arguments.> 
        *   @return <void> - <Not Returning anything>
        *   @throws exception-<No exception >
     */
    public pageReference dealRegistration(){        
        PageReference returnPage;
        Boolean success = true;
        isDealReg = true;
    returnPage = updateDealReg();     
        return returnPage;
    }
    
    /**
        * Method <nonDealRegistration():This method would be called 
            on click of Non Deal Registration Button.Converts the 
            Lead to Opportunity.>
        *   @param <This method is not taking any arguments.> 
        *   @return <void> - <Not Returning anything>
        *   @throws exception-<No exception >
     */
    public pageReference nonDealRegistration(){
        /*String convertLead = EMC_ConvertLead.convertLead(lead.id);
        System.debug('convertLead ------>'+convertLead );*/
        PageReference returnPage = null;
      try{
        if(lead.Related_Account__c!=null){
        String convertLead = EMC_ConvertLead.convertLead(lead.id);
        System.debug('convertLead ------>'+convertLead );
            if(convertLead.startsWith('006')){
               returnPage = new PageReference('/'+lead.id);
                returnPage.setredirect(true);
            }
           else{           
                if(convertLead.indexof('[]')!=-1 || convertLead.indexof('[')==-1  ){   
                    Integer start_index=convertLead.indexof(',');
                    Integer end_index=convertLead.lastIndexof('.');
                    //Integer end_index=convertLead.length();
                    System.debug('end_index   '+end_index);
                    String Message= convertLead.substring(start_index+1,end_index);
                    System.debug('Message----->'+Message);
                    displayErrorMessage(Message);
                }
                    showErrorMessage = true;
                    showCancelButton = true;
                }   
        }
        else{
            lead.Status='Converted to Opportunity';
            lead.S_Control_Converted__c=true;
            update lead;
            returnPage = new PageReference('/'+lead.id);
            returnPage.setredirect(true);
        }
     
    }
    Catch(Exception ex){
       showErrorMessage = true;
       showCancelButton = true;
       
       ApexPages.addMessages(ex);
    }          
        return returnPage;     
    }
    
    /**
        * Method <closeLead():This method would be called on click of Close Lead Button.
            Will show the Closed Reason to select setting the status to Closed.>
        *   @param <This method is not taking any arguments.> 
        *   @return <void> - <Not Returning anything>
        *   @throws exception-<No exception >
     */
    public pageReference closeLead(){
        showClosedReason = true;
        showOkButton = true;
        return null;
    }
    
    /**
        * Method <getshowClosedReason():Method to get the Selected Closed Reason>
        *   @param <This method is not taking any arguments.> 
        *   @return <void> - <Not Returning anything>
        *   @throws exception-<No exception >
     */
    public boolean getshowClosedReason(){
        return showClosedReason;
    }
    
    /**
        * Method <ok():Method called on click of Ok button.>
        *   @param <This method is not taking any arguments.> 
        *   @return <void> - <Not Returning anything>
        *   @throws exception-<No exception >
     */
    public pageReference ok(){
        lead.Status = 'Closed';
        lead.Closed_Reason__c = Lead.Closed_Reason__c;       
        System.debug('lead.Closed_Reason__c--->'+lead.Closed_Reason__c);  
        PageReference returnPage = null;       
        //If Closed Reason is not populated throw error message
        if(lead.Closed_Reason__c == null){
            System.debug('Inside the check--->'+lead.Closed_Reason__c); 
            displayErrorMessage(System.Label.Closed_Reason_Required);
        }  
        //Else update the Lead with status set closed and with appropriate closed Reason user selected.
        else{
            try{
                System.debug('Trying to update__________>'); 
                update lead;
            }
            Catch(Exception ex){
               showErrorMessage = true;
               showCancelButton = true;            
               ApexPages.addMessages(ex);
            } 
            //returnPage = new PageReference('/00Q/o');
            returnPage = new PageReference('/'+lead.id);
            returnPage.setredirect(true);
        }  
        return returnPage;      
    }
    
    /**
        * Method <getshowOkButton():Method called to display Ok Button>
        *   @param <This method is not taking any arguments.> 
        *   @return <void> - <Not Returning anything>
        *   @throws exception-<No exception >
     */
    public boolean getshowOkButton(){
        return showOkButton;
    }
    
    /**
        * Method <getLead():Method called to get details of Lead>
        *   @param <This method is not taking any arguments.> 
        *   @return <void> - <Not Returning anything>
        *   @throws exception-<No exception >
     */
    public Lead getLead(){
        return lead;
   }
    
    /**
        * Method <getshowErrorMessage(): Method called to display Error Message>
        *   @param <This method is not taking any arguments.> 
        *   @return <void> - <Not Returning anything>
        *   @throws exception-<No exception >
     */
    public boolean getshowErrorMessage(){
        return showErrorMessage;
    }
    
    /**
        * Method <getshowCancelButton():Method called to display Cancel Button>
        *   @param <This method is not taking any arguments.> 
        *   @return <void> - <Not Returning anything>
        *   @throws exception-<No exception >
     */
     public boolean getshowCancelButton(){
        return showCancelButton;
    } 
    /**
        * Method <getshowNonDealRegButton ():Method called to display Non-Deal Registration Button>
        *   @param <This method is not taking any arguments.> 
        *   @return <void> - <Not Returning anything>
        *   @throws exception-<No exception >
     */
     public boolean getshowNonDealRegButton(){
        return showNonDealRegButton;
    } 
    /**
        * Method <getClosedList():Method called to display Closed Reason LOV>
        *   @param <This method is not taking any arguments.> 
        *   @return <List<SelectOption>> - <List<SelectOption>>
        *   @throws exception-<No exception >
     */
     List<SelectOption> closedList;
     public List<SelectOption> getClosedList(){
        if(closedList==null){
            closedList = new List<SelectOption>();
            Schema.DescribeFieldResult pickListValues = Schema.sObjectType.Lead.fields.Closed_Reason__c;
            for(Schema.PickListEntry nextPickVal : pickListValues.getPicklistValues()){
                closedList.add(new SelectOption(nextPickVal.getValue(),nextPickVal.getLabel()));
            }
        }
        return closedList;

     } 
     
    public pageReference updateDealReg(){
        PageReference returnPage;
        Boolean success = true;
        //Added try catch block to display error messages if any during update of Lead.
        try{
            if(isDealReg){     
                
                
                /* Added By Arif for Req - 3657   */
                validate();   
                returnPage= null;       
                //added by anand on 18/05/2011 for deal reg 
                //fetch record type id for Deal Reg Approved
                if(showErrorMessage == false || showCancelButton == false){
   
                
                    Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
                    CustomSettingDataValueMap__c recordTypes;
                   // Commented for WR 194416 
                   if(lead.related_account__c==null){
                        recordTypes = DataValueMap.get('DealRegistrationSubmittedRecordType');
                    }else{  
                         Account selectedAccount= [select id,name,type,Owner.alias,BillingState,BillingPostalCode,BillingCity ,
                                       BillingStreet,BillingCountry,Party_Number__c, City_Local__c, Country_Local__c,State_Province_Local__c,
                                       Child_Record_Count_Contact__c,Address__c,Address_Local__c, NameLocal, Street_Local__c,Zip_Postal_Code_Local__c
                                    FROM ACCOUNT WHERE id =: lead.related_account__c] ;
                                    
                        recordTypes = DataValueMap.get('DealRegistrationSubmittedRecordType');
                        lead.Country__c=selectedAccount.BillingCountry;
                        lead.Country=selectedAccount.BillingCountry;
                        lead.Street=selectedAccount.BillingStreet;
                        lead.City=selectedAccount.BillingCity;
                        lead.PostalCode=selectedAccount.BillingPostalCode;
                        lead.State=selectedAccount.BillingState;
                        //DealReg.Name=selectedAccount.name ;
                        if(selectedAccount.Country_Local__c!=null ){
                            lead.Country_Local__c=selectedAccount.Country_Local__c;
                        }
                        if(selectedAccount.Street_Local__c!=null ){
                          lead.Street_Local__c=selectedAccount.Street_Local__c;
                        }
                        if(selectedAccount.City_Local__c!=null ){
                          lead.City_Local__c=selectedAccount.City_Local__c;
                        }
                        if(selectedAccount.Zip_Postal_Code_Local__c!=null ){
                          lead.Zip_Postal_Code_Local__c=selectedAccount.Zip_Postal_Code_Local__c;
                        }
                        if(selectedAccount.State_Province_Local__c!=null ){
                          lead.State_Province_Local__c=selectedAccount.State_Province_Local__c ;
                        }
                    }
                    System.debug('recordTypes ----> '+ recordTypes);
                    Id dealRegRecordtypeId = recordTypes.DataValue__c;
                    lead.RecordTypeId = dealRegRecordtypeId;
                    lead.DealReg_Deal_Registration__c = true;
                    lead.Lead_Converted_to_DR_Date_Time__c = SYSTEM.NOW();
            lead.OwnerId = UserInfo.getUserId();
            lead.DealReg_Deal_Registration_Status__c = 'New';
            // Added by Shravanthi: Assigned default Values to Deal Reg Type and Submission Source fields as per Inc IM6994875 
                lead.DealReg_Submission_Source__c = 'Partner Central';
                lead.DealReg_Deal_Registration_Type__c = 'Base';
                
                    Map<String,CustomSettingCountryTheaterMapping__c> mapCountry = CustomSettingCountryTheaterMapping__c.getall();
                    if(mapCountry.ContainsKey(lead.Country__c)){
                        lead.DealReg_Theater__c=mapCountry.get(lead.Country__c).theater__c;
                    }
                    System.debug('lead ----> '+ lead);
                    
                    if(lead.Partner__c != null){
                        // get profiled account Id from partner user contact                    
                        User currentUser = [Select u.ContactId, u.Contact.AccountId,contact.Account.PROFILED_ACCOUNT_FLAG__c,
                                                contact.Account.Profiled_Account__c,u.Velocity_Access__c, u.Co_Op_Access__c 
                                            from User u 
                                            where id=:userinfo.getUserId()]; 
                                                      
                        System.debug('currentUser Account Id-->'+currentUser.Contact.AccountId);           
                       //if account is profiled account then get that account id else take its profiled account Id
                        Id profileAccountId;
                        if(currentUser.contact.Account.PROFILED_ACCOUNT_FLAG__c==true){  
                            profileAccountId = currentUser.Contact.AccountId ;
                        }                   
                        else{ 
                            profileAccountId = currentUser.Contact.Account.Profiled_Account__c;
                        } 
                        if(profileAccountId != null){
                            Account objAccount = [Select Id, Partner_Type__c, Theater1__c From Account where id =: profileAccountId];
                            if(objAccount.Theater1__c =='EMEA' && lead.Tier_2_Partner__c == null && objAccount.Partner_Type__c =='Distributor'){
                                showErrorMessage = true;
                                showCancelButton = true; 
                                success = false; 
                                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, System.Label.DistributorVarRequiredForDistributor);
                                ApexPages.addMessage(errorMessage);
                                     
                            }
                        }                   
                    }
                    if(success){
                      update lead;                    
                        returnPage = new PageReference('/'+lead.id+'/e?retURL=%2F'+lead.id);
                        returnPage.setredirect(true);  
                    }else{
                        returnPage= null;
                    } 
                }              
                //End
                                
            }else{
                validate();                         
                returnPage= null;                                  
            }                   
        }
        Catch(Exception ex){
           showErrorMessage = true;
           showCancelButton = true;       
           ApexPages.addMessages(ex);
        }
        return returnPage;
    }  

    
}