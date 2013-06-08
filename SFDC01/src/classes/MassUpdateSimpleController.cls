/**
 * This is the controller for the mass update app
 * @author cchen
 *  Date           Developer       WR/DEFECT         Description
 *  
 *  21 April 2010   Arif            649            API name of BRS fields are added in 'not_req_fields' string variable.
    21 April 2010   Arif            653            Extra break line is removed from the method Step4().
    22 April 2010   Arif            655            Written a new function restrictPermission() to validate the user.  
    23 April 2010   Arif            655,652,653    Written the new funtion title() for the dynamic display of the title.
    29 April 2010   Arif            659            New fields are added which should not be displayed in update picklist.
    09 Sep   2010   Shipra          137405         Grant Mass Update permissions to Biz Ops & possibly modify the way it is granted. comented line 39 -59 (Not required)
                                                   Going forward we would just update   ProfileId__c custom setting for Profile's to be provided the access. 
 */


public with sharing class MassUpdateSimpleController {
    
   private final ApexPages.StandardSetController cntr;
   private final PageReference fromPage;
   private final List<SObject> objs;
   private Map<String, Schema.SObjectField> fieldMap;
   private transient ApexPages.Message currentMsg;
   private transient ApexPages.Message currentMsg_new;
   private final String newLine ='<br></br>';
   private final String newline1 = '<br>';
   private Schema.SObjectField field;
   private String sType;
   private Object convertedFieldData;
   private List<SelectOption> picklistValues;
   private String currentStep;
   public Boolean Flag=true;  
   public Boolean Flag1=true;  
   Boolean InsufficientAccess=false;
   private String titleName;
   private Boolean okFlag=false;
   private Boolean previousFlag=true;
   private Boolean cancelFlag=true;
   
        public Boolean restrictPermission(){
        /*
        List<Opportunity__c> id = Opportunity__c.getall().Values();
                   
        if((UserInfo.getProfileId()!= id[0].System_Admin__c) && (UserInfo.getProfileId()!= id[0].System_Admin_API__c) && (UserInfo.getProfileId()!= id[0].System_Admin_SFDC__c) && (UserInfo.getProfileId()!= id[0].Business_Admin__c)){
        
        */
        /*
        List<ProfileId__c> PrfId = ProfileId__c.getall().Values();
        Set <String> ProfileIds=new Set <String>();
        System.debug('The value PrfId'+PrfId+' & PrfId.size() '+PrfId.size()+' UserInfo.getProfileId() is '+UserInfo.getProfileId());
        for(Integer i=0;i<PrfId.size();i++){
            If( UserInfo.getProfileId()!= PrfId[i].ProfileIds__c)
            {
            InsufficientAccess= true;  
            System.debug('This is the culprit'); 
            System.debug('Here is the ID :' + UserInfo.getProfileId());
            flag1 = false;                
            }
            
        }
        */
        //Code Updated on 9/9/2010 by Shipra to include ProfileId__c custom setting//
         String user = UserInfo.getProfileId();
         Map<String,ProfileId__c> mapProfileId = ProfileId__c.getall();
         ProfileId__c Prfl =(mapProfileId.get(user));
         if(Prfl ==null)
         {
            InsufficientAccess= true;  
            System.debug('This is the culprit'); 
            flag1 = false;      
         }
         return InsufficientAccess;
         //End Of code Update By Shipra.
        
      }
      
   public MassUpdateSimpleController(ApexPages.StandardSetController controller) {
       currentStep = '1';
       title();
       controller.setPageSize(1000);
       cntr = (ApexPages.StandardSetController)controller;
       fromPage = cntr.cancel();
      Boolean InvalidAccess = restrictPermission();
       if(InvalidAccess){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,Label.Insufficient_Privileges_Mass_Update);
            ApexPages.addMessage(msg);
           System.debug('Hey I am First');
           okFlag=true;
           previousFlag=false;
           cancelFlag=false;
      } 
       else{  
        if (this.objs == null) {
            this.objs = (List<SObject>)cntr.getSelected();
       }
           
        if (getRecordSize()<1) {
            String msg = Label.No_Record_Selected_Mass_Update;
        //  String msg = 'No record was selected on the list view.  Please click Previous button and select records for mass update.'; 
            currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, msg);
            OkFlag=true;
            previousFlag=false;
            cancelFlag=false;
       } else {
            sType= discoverSObjectType(objs.get(0)).getName(); 
            String msg = Label.Records_Selected_Mass_Update + getRecordSize();  
   //       String msg = 'Number of records selected for update: ' + getRecordSize(); 
            currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
       }
       ApexPages.addMessage(currentMsg);
    }
       
       
   }
   
   
   /* public MassUpdateSimpleController() {
       System.debug('ids: ' + ApexPages.currentPage().getParameters().get('ids'));
       selected = ApexPages.currentPage().getParameters().get('id0');
       return; 
       cntr = new ApexPages.StandardSetController(objs);
       fromPage = cntr.cancel();
       if (this.objs == null) {
            this.objs = (List<SObject>)cntr.getSelected();
       }
       if (getRecordSize()<1) {
            String msg = 'No record was selected on the list view.  Please click Previous button and select records for mass update.'; 
            currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, msg);
       } else {
            sType= discoverSObjectType(objs.get(0)).getName(); 
            String msg = 'Number of records selected for update: ' + getRecordSize(); 
            currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
       }
       ApexPages.addMessage(currentMsg);
   } */
   

    public String getStep() {
        title();
        return currentStep;
    }
    
    public String getsType() {
        return sType;
    }      
   
    public integer getRecordSize() {
     if (objs!=null) {
        return objs.size();
     } else {
        return 0;
     }
    }
    
    public String filterId {
        get;
        set;    
    }
     
  public Boolean getFlag(){
        return flag;
   }     
    public void setFlag(Boolean flag){
        this.flag=flag;
    }
   
    public Boolean getFlag1(){
        return flag1;
   }     
    public void setFlag1(Boolean flag1){
        this.flag1=flag1;
    }
    
    public String getNow(Boolean bShowTime) {
        DateTime now = DateTime.now();
        if (bShowTime)
            return  now.year() + '-' + now.month()+ '-' + now.day()+' '+now.hour()+ ':' +now.minute() + ':' + now.second();
        else
            return  now.year() + '-' + now.month()+ '-' + now.day();
    }
   
    public List<SObject> objsToUpdate {
        get {
            return (List<SObject>) cntr.getSelected();
        }
        set;
    }
  
    public String valueToUpdate {
        get;
        set;    
    }
    
    public Sobject valueToUpdate_object {
        get;
        set;    
    }

    public String fieldName {
        get;
        set {
            //fieldName=value;
            field = fieldMap.get(value);
            fieldType = field.getDescribe().getType().name();
            value = field.getDescribe().getLabel();
            fieldName=value;
            System.debug('Field:'+ field);
            /* if(fieldName==null){
             currentMsg_new = new ApexPages.Message(ApexPages.severity.Error,'Please Enter the value in the below field.');
             ApexPages.addMessage(currentMsg_new);
            } */
            
        }   
    }
    
    public String fieldType{
        get;
        set;    
    }
    
    private Object convertUserInputToFieldData(){
        if (field==null) return null;
        DisplayType t = field.getDescribe().getType();
        Object s = null;
        
        try {       
                if (t==DisplayType.Double||t==DisplayType.Currency || t==DisplayType.Integer || t==DisplayType.Percent){
                    s = decimal.valueOf((String)valueToupdate);         
                } else if (t==DisplayType.Boolean){                 
                    if (valueToUpdate=='true'){
                        s = true;               
                    } else if (valueToUpdate=='false'){
                        s = false;              
                    } else {
                        s = Boolean.valueOf(valueToUpdate);
                    }
                } else if (t==DisplayType.Date) {
                    s = Date.valueOf(valueToUpdate);
                } else if (t==DisplayType.DateTime) {
                    s = DateTime.valueOf(valueToUpdate);
                } else if ((t==DisplayType.PickList || t==DisplayType.PickList) && valueToUpdate==null) {
                    s = '';
                }else {
                    s = valueToupdate;
                }
        } catch (System.TypeException e){
            System.debug('Type exception: ' + e.getMessage());
            currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage());
            System.debug('Message : ' + currentMsg );
            }  
        
        return s;
    }
    
    
    public String getFieldInfoToDisplay() {
        if (field==null) return '';
           String msg = Label.Field_Type_Mass_Update + fieldType + '<br/>';
    //     String msg = 'Field type of selected field: ' + fieldType + newline;
         //String msg = 'Field type of selected field: ' + fieldType + newline1;
        Schema.DescribeFieldResult d = field.getDescribe();
        
        if (d.getType()==DisplayType.TextArea || d.getType()==(DisplayType.String)||d.getType()==(DisplayType.URL)) {
            msg += Label.Max_Length + d.getLength();
  //        msg += 'Max lengh: ' + d.getLength();
            valueToUpdate='';
        } else if (d.getType()==DisplayType.DateTime ){
            msg += Label.Date_Time_Format;
     //     msg += 'Format: yyyy-MM-dd HH:mm:ss';
            valueToUpdate=getNow(true);
        } else if (d.getType()==DisplayType.Date){
            msg += Label.Date_Format;
  //        msg += 'Format: yyyy-MM-dd';
            valueToUpdate=getNow(false);
        } else if (d.getType()==DisplayType.Picklist){
            
            picklistValues = new List<SelectOption>();      
            if (d.isNillable()) {
                picklistValues.add(new SelectOption('', '--None--'));
            }
            for (Schema.PicklistEntry p : d.getPickListValues()) {
                picklistValues.add(new SelectOption(p.getValue(), p.getLabel()));
            }
             msg += ' ' + Label.Select_Picklist_Value;
          // msg += ' Please select a picklist value';
          // msg += newline + 'Please select a picklist value';
        } else if (d.getType()==DisplayType.MultiPicklist){
            
             msg += Label.Valid_Picklist;
          // msg += 'Valid Picklist Values: ';
            String combined ='';
            
            for (Schema.PicklistEntry p : d.getPickListValues()) {
                msg += newLine + '&nbsp;&nbsp;&nbsp;&nbsp;<b>' +p.getValue()+'</b>';
                combined += p.getValue()+';';
            }
             msg += newline + Label.Separate_Picklist_Values;
             msg += newline + Label.Select_Picklist_Value1  + combined + Label.Select_Picklist_Value2;
         //  msg += newline + 'Use ; to seperate each picklist value you want to select';
         //  msg += newline + 'For example, to select all the picklist values, enter <b>' + combined + '</b> in the textbox below to select all picklist values';
        } else if (d.getType()==DisplayType.Integer){
             msg += Label.Max_Digits + d.getDigits();
         //  msg += 'Max digits: ' + d.getDigits();
        } else if (d.getType()==DisplayType.String){
             msg += Label.Max_Length + d.getLength();
         //  msg += 'Max length: ' + d.getLength();
        } else if (d.getType()==DisplayType.Double || d.getType()==DisplayType.Currency || d.getType()==DisplayType.Percent){
            msg += Label.Format + (d.getPrecision()-d.getScale()) + ','+d.getScale() +')';
        //  msg += 'Format: (' + (d.getPrecision()-d.getScale()) + ','+d.getScale() +')';
        } else if (d.getType()==DisplayType.Reference){
            msg += Label.Selected_Records + newLine;
        //  msg += 'Use this to change selected records to reference a different record, or even dereference records if the field is left blank.' + newLine;
            msg += Label.Please_enter + d.getName() + Label.Selected_Records_Reference;
        //  msg += 'Please enter ' + d.getName() + ' that the selected records should reference to.';
        }
        
        return msg;
    }
    
       
    public PageReference cancel() {
        return fromPage;
    }
         
    public PageReference step1() { 
      /*  Boolean InvalidAccess = restrictPermission();
        if(InvalidAccess){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,Label.Insufficient_Privilege);
            ApexPages.addMessage(msg);
            return null;
      }
      else{ */         
       currentStep='Step 1 of 5 : Confirm records to be updated';         
       return ApexPages.currentPage();
   //  }
    }
    
    public PageReference step2() {
        if(getRecordSize()<1) return fromPage;
        System.debug('Step 2 Error Message :' + fromPage);     
        currentStep='2';    
        System.debug('Step 2- Current Page : ' +ApexPages.currentPage());
        title();
        valueToUpdate='';    
        return ApexPages.currentPage();
    }
    
    public PageReference step3() {
         System.debug('Field:'+ fieldName);
        /* if(fieldName==null){
        currentMsg_new = new ApexPages.Message(ApexPages.severity.Error,'Please Enter the value in the below field.');
        ApexPages.addMessage(currentMsg_new);
        } */ 
        currentMsg = new ApexPages.Message(ApexPages.severity.INFO, getFieldInfoToDisplay());
        ApexPages.addMessage(currentMsg);
        currentStep='3'; 
        title();        
        return ApexPages.currentPage();
    } 
  
    public PageReference step4() {
        convertedFieldData = convertUserInputToFieldData();
        
        // data type validation
        if (currentMsg!=null) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.INFO, getFieldInfoToDisplay());
            ApexPages.addMessage(msg);
            ApexPages.addMessage(currentMsg);
            return ApexPages.currentPage();
        }
        
        String msg = Label.Review_Selections;
     // String msg = 'Please review your selections before confirm:<br>'; 
       // msg = msg + '<br><b>Records Selected:</b>    ' + getRecordSize() +'</br>';
          msg = msg + Label.Records_Selected + getRecordSize();
      //  msg = msg + '<br><b>Records Selected:</b>    ' + getRecordSize();
        //msg = msg + '<br><b>Field To Be Updated:</b> ' + fieldName + '</br>';
          msg = msg + Label.Field_To_Be_Updated + fieldName;
       // msg = msg + '<br><b>  Field To Be Updated:</b> ' + fieldName;
       // msg = msg + '<br><b>New Value:</b>           ' + convertedFieldData + '</br>';
          msg = msg + Label.New_Value            + convertedFieldData;
       // msg = msg + '<br><b>  New Value:</b>           ' + convertedFieldData;
        currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
        ApexPages.addMessage(currentMsg);
        currentStep='4';  
        title();       
        return ApexPages.currentPage();
    } 
      
    public PageReference step5() {
        String Expected_Success_Messsage= Label.Updated + ' ' + objs.size() + ' ' + Label.Records_Mass_Update;
     // String Expected_Success_Messsage= 'Updated '+objs.size()+' Records';
        currentMsg = (new MassUpdater(objs, field, convertedFieldData)).massUpdate();
        String strResult=''+currentMsg;
        
        if((strResult.indexOf(Expected_Success_Messsage)==-1)){
            Flag = False;
            System.debug('I am wrong-------------->');
            System.debug('STRRESULT-------------->' + strResult );
            //ApexPages.addMessage(currentMsg_New);
        }
        else{  
            Flag = True;
            ApexPages.addMessage(currentMsg);
            System.Debug('MSG'+currentMsg);
            System.debug('I am correct-------------->');
        } 
        currentStep='5';  
        title();    
        return ApexPages.currentPage();
        
    }
   
    public DescribeSObjectResult discoverSObjectType(SObject s) {
        Map<String, Schema.SObjectType> des = Schema.getGlobalDescribe();
        
        for(Schema.SObjectType o:des.values()) {
            if( s.getSObjectType()==o) {
                return o.getDescribe();
            }     
        }
        return null;
    }
   
    public List<SelectOption> getFieldTypeOptions() {
        // prevent url hacking
        if (objs.size()<1) return null;
        
        List<SelectOption> options = new List<SelectOption>();      
        //options.add(new SelectOption('None','-None-'));
                
        Schema.DescribeSObjectResult sObj = discoverSObjectType(objs.get(0));
        
        fieldMap = sObj.fields.getMap();
        
        List<String> keys = sortByFieldLabel(fieldMap);
        
        for(String key:keys) {
            Schema.DescribeFieldResult d = fieldMap.get(key).getDescribe();

            if(d.isAccessible() && d.isUpdateable()) {
                if (isSupportedFieldType(d)) {
                    String label = d.getLabel();
                   // String api_name = d.getApi();
                  //  if(d.isCustom()) label += ' (' + key +  ')';
                    //  if(d.isCustom()) label +=key; 
                    // This string not_req_fields starts and end with ','.Kindly take care of this.
                    // String not_req_fields = ',Account Address,Final EMC Negotiated Deal Price (Legacy),Total Solution Price (Legacy),Account Flag,Account Name,Account Number,Account Owner,All-In Amount,Amount,BURA Database ID,bypass_validation,Competitor Logic,Competitor Logic - Product Questions,Competitor Logic - Services Questions,Count Of Products,Count Of Professional Services,Created By,Description,Education Forecast,Expected Revenue,Field Amount,Forecast Category,Group Deal,Hardware Forecast,Inside Amount,Last Modified By,LATAM Forecast Estimate,Maintenance Forecast,MCSD,Needs Competitive Information,Next Step,Next Steps Last Updated By,Next Steps Last Updated Date,Next Steps Updated,Opportunity Name,Opportunity Number,Opportunity Owner,Opportunity Owner,Opportunity Record Type,Party Number,PAS Number (Oracle PAS#),Please Describe,Primary Campaign Source,Private,Product Count,Product SO Number,Product SO Number 2,Product SO Number 3,Product SO Number 4,Product SO Number 5,Product SO Number 6,Product SO Number 7,Product SO Number 8,Professional Services Forecast,PS SO Number,Quantity,Quote Amount,Quote Operating Unit,Quote Type,Quote Version,Quote/Cart,Quote/Cart Number,Rolled-Up Field Amount,SO Number,Software Forecast,Stage at Booked,Synergy Opp #,Title,'; 
                    //   String not_req_fields = ',BRS_Account_Address__c,BRS_Account_Name__c,BRS_Close_Date__c,BRS_Forecast_Amount__c,BRS_Forecast_Status__c,BRS_Opportunity_Nbr__c,BRS_Order_Nbr__c,BRS_Partner_Name__c,BRS_Quote_Amount__c,BRS_Quote_Nbr__c,BRS_Rep_Name__c,Opportunity_Nbr__c,Opportunity_Linked__c,EMC_Tier_2_Partner__c,BRS_Date_Last_Modified__c,BRS_Reseller_Company__c,Account_Address__c,Account_Flag__c,Account,Account_Number__c,Opportunity_Owner__c,All_In_Amount__c,Amount,BURA_Database_ID__c,bypass_validation__c,Competitor_Logic__c,Competitor_Logic_Product_Questions__c,Competitor_Logic_Services_Questions__c,Count_Of_Products__c,Count_Of_Professional_Services__c,CreatedBy,Description,Education_Forecast__c,ExpectedRevenue,Field_Amount__c,ForecastCategoryName,Group_Deal__c,Hardware_Forecast__c,Inside_Amount__c,LastModifiedBy,LATAM_Forecast_Estimate__c,Maintenance_Forecast__c,MCSD__c,Needs_Competitive_Information__c,NextStep,Next_Steps_2__c,Next_Steps_Last_Updated_Date__c,Next_Steps_Updated__c,Name,Opportunity_Number__c,Owner,Deal_Lead__c,RecordType,Party_Number__c,PAS_Number_Oracle_PAS__c,Please_Describe__c,Campaign,IsPrivate,Product_Count__c,Product_SO_Number__c,Product_SO_Number_2__c,Product_So_Number_3__c,Product_So_Number_4__c,Product_So_Number_5__c,Product_SO_Number_6__c,Product_So_Number_7__c,Product_So_Number_8__c,Professional_Services_Forecast__c,PS_SO_Number__c,TotalOpportunityQuantity,Quote_Amount__c,Quote_Operating_Unit__c,Quote_Type__c,Quote_Version__c,Quote_Cart_Link__c,Quote_Cart_Number__c,Rolled_Up_Field_Amount__c,SO_Number__c,Software_Forecast__c,Stage_at_Booked__c,Synergy_Opportunity_Number__c,Title__c,Total_Solution_Price__c,Final_EMC_Negotiated_Deal_Price__c,OwnerId,';
                       String not_req_fields = ',AccountId,AddressInformation__c,CampaignId,Pricebook2Id,RecordTypeId,OwnerId,Account_Address__c,Account_Flag__c,Account_Number__c,Account_Oppty__c,Opportunity_Owner__c,All_In_Amount__c,Area_Manager__c,BRS_Account_Address__c,BRS_Account_Name__c,BRS_Close_Date__c,BRS_Date_Last_Modified__c,BRS_Partner_Name__c,BRS_Forecast_Amount__c,BRS_Forecast_Status__c,BRS_Opportunity_Nbr__c,BRS_Quote_Amount__c,BRS_Quote_Nbr__c,BRS_Rep_Name__c,BRS_Reseller_Company__c,BRS_Order_Nbr__c,BURA_Database_ID__c,bypass_validation__c,Commit_Tracker__c,Competitive_information_Entered__c,Competitor_Logic__c,Competitor_Logic_Product_Questions__c,Competitor_Logic_Services_Questions__c,Count_Of_Products__c,Count_Of_Professional_Services__c,Country__c,CSD__c,District_Manager__c,Education_Forecast__c,Field_Amount__c,Final_EMC_Negotiated_Deal_Price__c,Group_Deal__c,Hardware_Forecast__c,Inside_Amount__c,LATAM_Forecast_Estimate__c,Maintenance_Forecast__c,MCSD__c,MCSD_1__c,Needs_Competitive_Information__c,Next_Steps_2__c,Next_Steps_Last_Updated_Date__c,Next_Steps_Updated__c,Opportunity__c,Opportunity_Number__c,Deal_Lead__c,Party_Number__c,PAS_Number_Oracle_PAS__c,Please_Describe__c,Product_Count__c,Product_SO_Number__c,Product_SO_Number_2__c,Product_So_Number_3__c,Product_So_Number_4__c,Product_So_Number_5__c,Product_SO_Number_6__c,Product_So_Number_7__c,Product_So_Number_8__c,Professional_Services_Forecast__c,PS_SO_Number__c,Quote_Cart_Link__c,Quote_Cart__c,Quote_Cart_Number__c,Quote_Cart_Number1__c,Quote_Amount__c,Quote_Operating_Unit__c,Quote_Type__c,Quote_Version__c,Related_Opportunity__c,Rolled_Up_Field_Amount__c,Software_Forecast__c,SO_Number__c,Stage_at_Booked__c,State__c,Synergy_Opportunity_Number__c,Partner__c,Tier_2_Partner__c,Title__c,Total_Solution_Price__c,Account,Amount,CreatedBy,Description,ExpectedRevenue,ForecastCategoryName,LastModifiedBy,NextStep,Name,Owner,RecordType,Campaign,IsPrivate,TotalOpportunityQuantity,'; 
                        if(not_req_fields.indexOf(','+key+',')==-1){
                        System.debug('API:'+ key); 
                        options.add(new SelectOption(key, label));                                  
                     }
                }
            }
        }
        System.debug('test----->'+options);
        return options;
        
    }
   
    private List<String> sortByFieldLabel(Map<String, Schema.SObjectField> gd) {
        List<String> keys = new List<String>();
        
        Map<String, List<String>> labelMap = new Map<String, List<String>>();
        
        for(Schema.SObjectField s:gd.values()) {
            String label = s.getDescribe().getLabel();
            if(labelMap.get(label) == null) {
                labelMap.put(label, new List<String>());
            }
            
            labelMap.get(label).add(s.getDescribe().getName());        
        }
        
        List<String> labels = new List<String>(labelMap.keySet());
        labels.sort();
        
        for(String label:labels){
            keys.addAll(labelMap.get(label));
        }
        
        return keys;
    }
    
    public List<SelectOption> getPicklistValues() {
        return picklistValues;
    }
    
    private boolean isSupportedFieldType(DescribeFieldResult d) {
        // always return true for now, but in future some fields might not be supported
        return true;
    }
    
    public String title(){
        if(currentStep=='1')
            titleName = Label.MassUpdate_Title1;
        else if(currentStep=='2'){
            titleName =Label.MassUpdate_Title2;
        }
        else if(currentStep=='3'){
            titleName = Label.MassUpdate_Title3+fieldName;
        }
        else if(currentStep=='4'){
            titleName = Label.MassUpdate_Title4;
        }
        else{
            titleName = Label.MassUpdate_Title5;
        }
        return titleName;
        }
        
    public String gettitle(){
        return titleName;
    }
    public void settitle(String titleName){
        this.titleName = titleName;
    }
    
    public pageReference showOk(){
        return fromPage;
    }
    
    public Boolean getpreviousFlag(){
        return previousFlag;
    }
    
    public Boolean getcancelFlag(){
        return cancelFlag;
    }
    public Boolean getokFlag(){
        return okFlag;
    }
}