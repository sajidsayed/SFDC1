/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER   WR/DEFECT    DESCRIPTION                               
 |  ====       =========   =========    =========== 
 |    
 |  20-Apr-10  Karthik     Defect - 643 Updated newSearch() Method
 |  23-Apr-10  Prasad      WR134742     Added some more conditions in the filters.
 |  26-Apr-10  Prasad k    Change in Add sales team member design to support Repalce method added on extra paramter
 |  27-Apr-10  Karthik     Updated the function replaseSearch(), to catch the null pointer exception
 |  30-Apr-10  Karthik     Added new method getfieldType() and updated the method getNumberOperators() for Defect#671
 |  07-Jun-10  Shipra      WR#136419(Covered Pts 1,2,3)Worked for defect 720
 |  06-Jul-10  Shipra      Updated Code to Narrow down the search for 200 records.For defect 730.
 |  16-Jul-10  Shipra      Worked on 138244 updated query for adding source,stage, account country and account state field.
 |  10-Aug-10  Shipra      Worked On WR# 139401
                            #1. Updated User Search Functionality.
 |  08-Nov-10  Shipra      Worked on line # 394-397 for WR 146016.
 |  10-Jan-11  Srinivas    Worked on WR-151992
 |  16-Mar-11  Srinivas    Changed for WR-160725
    12-Apr-11  Srinivas    Modified methos Cancel for WR-162884
    08-Aug-11  Srinivas    WR-170870
    11-Jun-12  Avinash     Modified code to avoid a null pointer exception & to remove hardcoded limit value for the Opportunity
                           search query using the custom setting record 'MassReassignmentSearchResultQueryLimit'     
 +===========================================================================*/

public class MassSalesTeamOperation {
    
    public String selectedObject{get;set;}//Added Pratibh:17 Aug-2010 
    public String primaryObject, secondaryObject;//Added Pratibh:17 Aug-2010 
    //Added by Srinivas for new IIG Forecast Groups
    Map<String,Special_Forecast_Groups__c>  mapSpecial_Forecast_Groups = Special_Forecast_Groups__c.getAll();

    /* Here we are decalring the lists and maps. Where list will be containing the opportunities
    along with the wrapper class */

    List<OpportunityWrapper> oppWrap=new List<OpportunityWrapper>();
    List<OpportunityWrapper> oppWraplist=new List<OpportunityWrapper>();
    Map<Id,String> opportunityResult = new Map<Id,String>();
    List<String>columnHeader = new List<String>();
    String OpDate= '';

    Id newUserId;
    Id existingUserId;
    Id removeUserId;
    Id replaceUserId;
    Id userId;
    
    //////////////////////////////
    //Added by Srinivas for WR-160725. Limiting the number of search results to show on page and Showing the Total number of results
    public Integer totalSearchResults {get;set;}
    Map<String,CustomSettingDataValueMap__c>  mapDataValueMap = CustomSettingDataValueMap__c.getAll();
    integer resultSize = integer.valueOf(mapDataValueMap.get('MassReassignmentSearchResultSize').datavalue__c);
    integer resultPageSize = integer.valueOf(mapDataValueMap.get('MassReassignmentSearchResultPageSize').datavalue__c);
    public integer getresultPageSize(){
        return resultPageSize;
    }
    
    
    integer ProcessingLimit ;
        
        
    ///////// 
    /*
    Code Added-Pratibh: 17 Aug-2010, Lines 27-47
    Below code is for filters diplayed on the page in order to make them dynamic.
    */
    //Wrapper class for filters displayed.
    public class Filter{
        
        public String filterField{get;set;}//Varible corresponds to field Selected in filter
        public String filterOperator{get;set;}//Varible corresponds to operator Selected in filter
        public List<SelectOption> validOperators = new List<SelectOption>();//List Stores valid operators corresponding to the field selected
        public String filterFieldValue{get;set;}//Varible corresponds to value entered in filter
        public String filterIndex{get;set;}//Index displayed on filter
        public String filterSuffix{get;set;}
        
        //Setter and Getter
        public void setValidOperators(List<SelectOption> setterList){this.validOperators.addAll(setterList); } 
        public List<SelectOption> getValidOperators(){ return this.validOperators;}
    }
    
    Map<String, List<String>> field_ValidOperatorsMap = new Map<String, List<String>>();//Map stores data type and corresponding valid operators
    Map<String, String> field_FieldDataTypeMap = new Map<String, String>();//Map stores field type and corresponding data type
    public List<Filter> filters = new List<Filter>();//List for filters displayed on Page
    Map<String, String> operator_NameMap =  new Map<String, String>();//Map to store string name of a operator
    Map<String, String> altOperatorMap =  new Map<String, String>();//Map to store alernative operator for a operator such as 'in' can be alternative operator for '='
        
    //Setter and Getters
    public void setFilters(List<Filter> setterList){this.filters.addAll(setterList); } public List<Filter> getFilters(){ return this.filters;}
    
    //prasad
    public MassSalesTeamOperation() {
        
        if(mapDataValueMap.get('MassReassignmentProcessingLimit') != null && 
        mapDataValueMap.get('MassReassignmentProcessingLimit').datavalue__c != null)
            ProcessingLimit = integer.valueOf(mapDataValueMap.get('MassReassignmentProcessingLimit').datavalue__c);
        
        /*System.debug('check access');
        if(!checkAccess()){
            ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Insufficient_Previleges);
            ApexPages.addMessage(msg2);
        }*/
        
        //Code Added-Pratibh: 18 Aug-2010, Lines 56-58
        selectedObject = 'Opportunity;Account';
        createFieldMaps();   
        createFiters();  
        //pmOffering = new PageManager(75);
    }
    
    //Code Added-Pratibh: 18 Aug-2010, Methods: createFieldMaps(), createFiters(), filterOperators(), createQuery()
    /*
    Method that populate field_ValidOperatorsMap & field_FieldDataTypeMap. These maps determine primitive data type 
    corresponding to a field type and valid operator corresponding to a field type. 
    */
    public void createFieldMaps(){
        //Creating FieldTypeMap
        field_FieldDataTypeMap.put('STRING','String');
        field_FieldDataTypeMap.put('PICKLIST','String');
        field_FieldDataTypeMap.put('ID','String');
        field_FieldDataTypeMap.put('TEXTAREA','String');
        field_FieldDataTypeMap.put('MULTIPICKLIST','String');
        field_FieldDataTypeMap.put('EMAIL','String');
        field_FieldDataTypeMap.put('URL','String');    
        field_FieldDataTypeMap.put('PHONE','String'); 
        
        field_FieldDataTypeMap.put('DATETIME','Number');
        field_FieldDataTypeMap.put('DATE','Number');
        field_FieldDataTypeMap.put('PERCENT','Number');   
        field_FieldDataTypeMap.put('DOUBLE','Number');   
        field_FieldDataTypeMap.put('CURRENCY','Number');     
        
        field_FieldDataTypeMap.put('REFERENCE','Id'); 
        field_FieldDataTypeMap.put('ID','Id'); 
        
        field_FieldDataTypeMap.put('BOOLEAN','Boolean'); 
        field_FieldDataTypeMap.put('BOOLEAN','Boolean'); 
         
        //Creating Operator Map 
        field_ValidOperatorsMap.put('Id', new List<String>());
        field_ValidOperatorsMap.get('Id').add('=');
        field_ValidOperatorsMap.get('Id').add('!=');
        
        field_ValidOperatorsMap.put('Boolean', new List<String>());
        field_ValidOperatorsMap.get('Boolean').add('=');
        field_ValidOperatorsMap.get('Boolean').add('!=');
        
        field_ValidOperatorsMap.put('String', new List<String>());
        field_ValidOperatorsMap.get('String').add('=');
        field_ValidOperatorsMap.get('String').add('!=');
        field_ValidOperatorsMap.get('String').add('_%');
        field_ValidOperatorsMap.get('String').add('%_');
        field_ValidOperatorsMap.get('String').add('%_%');
        
        field_ValidOperatorsMap.put('Number', new List<String>());
        field_ValidOperatorsMap.get('Number').add('=');
        field_ValidOperatorsMap.get('Number').add('!=');
        field_ValidOperatorsMap.get('Number').add('<');
        field_ValidOperatorsMap.get('Number').add('>');
        
        //Creating operator and name map
        operator_NameMap.put('=','Equals');
        operator_NameMap.put('!=','not equal to');
        operator_NameMap.put('<','LessThan');
        operator_NameMap.put('>','GreaterThan');
        operator_NameMap.put('_%','startsWith');
        operator_NameMap.put('%_','endsWith');
        operator_NameMap.put('%_%','contains');
        
        //Creating alernative operator map
        altOperatorMap.put('=','IN');
        altOperatorMap.put('!=','NOT IN');
        
    }
    /*
    Method creates filter list corresponding to filter displayed on page.
    */
    public void createFiters(){
        filters.clear();
        for(Integer i=0; i<5; i++){
            Filter tempFilter = new Filter();
            tempFilter.filterField='None:None:None';
            tempFilter.validOperators.add(new SelectOption('None','-- None --'));
            tempFilter.filterIndex = String.valueOf(i+1);
            if(i!=4){
                tempFilter.filterSuffix = 'AND';
            }
            filters.add(tempFilter);
        }
    }
    /*
    Method filters operator corresponding to the field selected
    */
    public void filterOperators(){
        String fieldType, fieldDataType;
        for(Integer i=0; i<5; i++){
            System.debug('######################'+filters[i].filterField);
            fieldType = filters[i].filterField.split(':')[2];
            if(fieldType!='None'){
                fieldDataType = field_FieldDataTypeMap.get(fieldType);
                filters[i].validOperators.clear();
                filters[i].validOperators.add(new SelectOption('None','-- None --'));
                for(String operator: field_ValidOperatorsMap.get(fieldDataType)){
                    filters[i].validOperators.add(new SelectOption(operator,operator_NameMap.get(operator)));
                }
            }
            else{
                filters[i].validOperators.clear();
                filters[i].validOperators.add(new SelectOption('None','-- None --'));
            }
        }
    }
    
    /*
    Method to create Query from filters
    */
    public String createQuery(){
        
        Set<String> objectsSelected = new Set<String>();
        String query='';
        String condition = '';
        List<Filter> validFilters = new List<Filter>();
        
        for(Integer i=0; i<5; i++){
            if(filters[i].filterField.split(':')[1] != 'None' && filters[i].filterOperator!='None' && (filters[i].filterFieldValue!=null && (filters[i].filterFieldValue.trim()).length()>0)){
                objectsSelected.add(filters[i].filterField.split(':')[0]);
                validFilters.add(filters[i]);
            }
        }
        if(objectsSelected.size()==0){//Error: filter criteria not specified properly
            query = 'ERROR';
            return query;
        }
        else if(objectsSelected.size()==1){//When fields of only one object is selected
            for(String tempObj: objectsSelected){
                primaryObject = tempObj;
            }
            if(primaryObject=='Product2'){
                primaryObject= 'OpportunityLineItem';
            }
        }
        else{//When fields of both object are selected
            if(objectsSelected.contains('Account')){
                primaryObject= 'Opportunity';
                secondaryObject = 'Account';
            }
            else if(objectsSelected.contains('Product2')){
                primaryObject= 'OpportunityLineItem';
                secondaryObject = 'Opportunity';
            }
            else{
                secondaryObject = 'Opportunity';
                for(String tempObj: objectsSelected){
                    if(tempObj!=secondaryObject){
                        primaryObject = tempObj;
                    }
                }
            }
        }
        //WR-170870
        if(primaryObject == 'Opportunity'){
            query += 'Select Id,Opportunity_Number__c, Account.Name, Amount, CloseDate, Name, Owner.Alias, CurrencyIsoCode,'+
                    ' StageName, Owner.Name, Owner.isActive, Sales_Force__c, LeadSource,'+ 
                    ' Account.BillingState, Account.BillingCountry from '+primaryObject+' where IsClosed=false and';
        }
        /*else if(primaryObject == 'OpportunityLineItem'){
            query += ' OpportunityId, Opportunity.Account.Name, Opportunity.Amount, Opportunity.CloseDate, Opportunity.Name, Opportunity.Owner.Alias, Opportunity.CurrencyIsoCode,'+
                    ' Opportunity.StageName, Opportunity.Owner.Name, Opportunity.Owner.isActive, Opportunity.Sales_Force__c, Opportunity.LeadSource,'+ 
                    ' Opportunity.Account.BillingState, Opportunity.Account.BillingCountry from '+primaryObject+' where Opportunity.IsClosed=false and';
        }*/
        else if(primaryObject == 'OpportunitySplit'){
            String strSplitType='Overlay';
            query += ' Select OpportunityId from '+primaryObject+' where splittype.developername =: strSplitType ';
        }
        else{
            query += ' Select OpportunityId from '+primaryObject+' where Opportunity.IsClosed=false and';
        }
        
        String fieldObject, fieldName, fieldType, operator, value;
        System.debug('-----------VALID FILTERS:'+validFilters.size());
        System.debug('--------Primary Object:'+primaryObject);
        for(Integer i=0; i<validFilters.size(); i++){
            System.debug('-----------ITERATION:'+i);
            fieldObject = validFilters[i].filterField.split(':')[0];
            fieldName = validFilters[i].filterField.split(':')[1];
            fieldType = validFilters[i].filterField.split(':')[2];
            operator = validFilters[i].filterOperator;
            value = validFilters[i].filterFieldValue;
            value = value.replace('\'','\\\'');
            String bigValue='(';
            for(String val: value.split(',')){
                val = val.trim();
                bigValue +='\''+val+'\','; 
            }
            //Processing field name
            System.debug('------Field Object:'+fieldObject+'-----Field Name:'+fieldName+'-----Field Type:'+fieldType);
            if(primaryObject != 'OpportunityLineItem'){//Field of Primary Object fetch directly
                System.debug('-----1-----');
                if(fieldObject == primaryObject){//Field of Primary Object fetch directly
                    System.debug('-----2-----');
                    condition += ' '+fieldName;
                }
                else{//Field of Primary Object fetch using relationship
                    System.debug('-----3-----');
                    condition += ' '+secondaryObject+'.'+fieldName;
                }
            }
            else{
                System.debug('-----4-----');
                if(fieldObject == 'Product2'){//Field of Product fetch using OpportunityLineItem relationship with Product
                    System.debug('-----5-----');
                    condition += ' '+primaryObject+'.PriceBookEntry.Product2.'+fieldName;
                }
                else{//Field of Opportunity fetch using OpportunityLineItem relationship with Opportunity
                    System.debug('-----6-----');
                    condition += ' '+secondaryObject+'.'+fieldName;
                }
            }
            
            //Processing operator and value.
            if(field_FieldDataTypeMap.get(fieldType)=='String' || field_FieldDataTypeMap.get(fieldType)=='Id'){//Field of type String processed with quotes
                System.debug('-----7-----');
                if(operator.contains('%')){//like operator to be used
                    System.debug('-----8-----');
                    condition += ' like'+' \''+operator.replace('_',value)+'\'';
                }   
                else{
                    System.debug('-----9-----');
                    if(bigValue.length()>1){
                        bigValue = bigValue.substring(0,bigValue.length()-1);
                        System.debug('-----9.5-----');
                        operator = altOperatorMap.get(operator);
                        condition += ' '+operator+' '+bigValue+')';
                    }
                    else{
                        condition += ' '+operator+' \''+value+'\'';
                    }
                }
            }
            else{//Non-String type field processed without quotes
                System.debug('-----10-----');
                condition += ' '+operator+''+value+'';
            }
            
            if(i!=(validFilters.size()-1)){//Appending "and" in query
                System.debug('-----11-----');
                condition += ' and';
            }
        }
        if(primaryObject== 'Opportunity'){
            condition += ' order by Name';
        }
        else if(primaryObject!= 'OpportunitySplit'){
            condition += ' order by Opportunity.Name';
        }
        System.debug('-----------Condition:'+condition);
        query +=condition;
        return query;
    }
    
    
    public boolean showOkButton=false;
    public boolean getShowOkButton(){
        return showOkButton;
    }
    public void checkAccess(){
       user current_user= [select id, Allow_Mass_Reassignment__c from user where id=:UserInfo.getUserId() ];
       //return (current_user.Allow_Mass_Reassignment__c) ;
       if(!current_user.Allow_Mass_Reassignment__c){
            ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Insufficient_Previleges);
            ApexPages.addMessage(msg2);
            showOkButton=true;
        }
    }
    boolean date1=false; 
    public boolean getDate1() {
        System.debug('Date1*********'+date1);
        return date1;
    }


    public PageReference massReassignmentHistory() {
        return Page.mass_reassignment_result_log;
    }


/* Getter method for the Map Opportunity result */

    public Map<ID,String> getOpportunityResult() {
        return opportunityResult;
    }

/*This method is used to populate the result and print it on the opportunity result screen, which is been
selected in opportunity page and display the success or failure in the result field*/
    
    public void populateResult(Map<Id,String> opportunityResult){
        for(OpportunityWrapper oppty:oppWraplist){
                String errorMessage = opportunityResult.get(oppty.opp.Id);
                oppty.result = errorMessage;
                
        }
    }
    
    
/* This is previous method in the search filter page, where search for opportunities is done,
onclick of this takes to main page MassReassign */

    public PageReference previousStep2() {
        title1=false;
        title2=false;
        title3=false;
        return Page.MassReassign;
    }


    public String fieldValue { get; set; }

/* This is next method in the search for opportunities page, on click takes to next page*/

    public PageReference nextStep2() {
        try{
            oppWraplist.clear();
            oppWrap.clear();
            searchOpportunity();
        }catch(Exception e){
            return null;
        }
        return new PageReference('/'+'apex/OpportunitySearchResult');
    }

/* This is the previous method in add a new resource page, onclick takes back to previous screen */
    
    public PageReference previousStep4() {
        //Updated For WR 146016//
        selectedCheck();
        oppWraplist.clear();
        //End of Code Updated for WR 146016//
        return new PageReference('/'+'apex/OpportunitySearchResult');
    }

/* This is the previous method in select Opportunities page, onclick takes back to previous screen */

    public PageReference previousStep3() {
        //WR-163052
        ProcessedOpptyIds.clear();
        oppWraplist.clear();
        selectedCheck();
        return new PageReference('/'+'apex/Mass_Reassign_SearchFilter');
    }

/*This method is used to dynamically change the title of the Search Opportunities screen, where if user is selected
to add,remove or replace opportunity resource, the title is displayed accordingly*/

    public Boolean title1 {get; set;}
    public Boolean title2 {get; set;}
    public Boolean title3 {get; set;}
    
    public PageReference nextStep1() {
        
        if(operations=='Add an opportunity team member'){
            title2=true;
            //String Message =System.Label.Warning_On_Search;
            //ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.Warning,System.Label.Warning_On_Search+"<br>'+System.Label.Insufficient_Previleges);
            //ApexPages.addMessage(msg1);
            if(opportunityResult!=null){
            opportunityResult.clear();
            }
            if(oppWraplist!=null){
                oppWraplist.clear();
            }
            
            if(users!=null){
                users.clear();
            }
            return Page.Mass_Reassign_SearchFilter;
         }
         else if(operations=='Remove an opportunity team member'){
            title3=true;
            return Page.Mass_Reassign_SearchFilter;
         }
         else if(operations=='Replace an existing opportunity team member with same or previous forecast group') {
            title1=true;
            return new PageReference('/'+'apex/Mass_Reassign_SearchFilter');
        
         }
         return null;
    }  


  

    
    public void SearchOpportunity() 
    {
        List<Opportunity> Listopp=new List<Opportunity>();    
        //List corresponding to various object on which query can be fired
        List<OpportunityLineItem> oppLineItems=new List<OpportunityLineItem>();
        List<OpportunitySplit> oppSplits=new List<OpportunitySplit>();
        List<OpportunityTeamMember> oppTeamMembers=new List<OpportunityTeamMember>();
        Set<Id> oppIds = new Set<Id>(); 
        oppIds.clear();
        Listopp.clear();
        try{ 
        
            columnHeader.add('Account.Name');
            columnHeader.add('Amount');
            //columnHeader.add('CloseDate');
            columnHeader.add('OpDate');
            columnHeader.add('Name');
            columnHeader.add('Owner.Alias');
            columnHeader.add('StageName');  
            String Query  = createQuery();
            //String Query = 'Select id,Account.Name,Amount,CloseDate,Name, Owner.Alias,CurrencyIsoCode , StageName,Owner.Name,Owner.isActive, Sales_Force__c, LeadSource, Account.BillingState, Account.BillingCountry from Opportunity where IsClosed=false and ( '+ createWhereClause(AdvanceFilter)+' ) order by Name limit 1000';      
            System.debug('Query  '+Query);
            /*
            Code Added-Pratibh: 18-Aug-2010, Code for processing dyanamic queries that could be on different objects.
            Lines: 450-474
            */
            
//Code added by Avinash begins...
                        
            Map<String,CustomSettingDataValueMap__c>  mapDataValueMap = CustomSettingDataValueMap__c.getAll();
            integer queryLimit;
            if(mapDataValueMap != null && mapDataValueMap.get('MassReassignmentSearchResultQueryLimit') != null &&
                    mapDataValueMap.get('MassReassignmentSearchResultQueryLimit').datavalue__c != null )
                queryLimit = integer.valueOf(mapDataValueMap.get('MassReassignmentSearchResultQueryLimit').datavalue__c);
            
//Code by Avinash ends.
            
            
            
            if(primaryObject =='Opportunity'){
                Query +=' limit '+queryLimit;
                for(List<Opportunity> olist :Database.query(Query))
                    Listopp.addall(olist);
            }
            else if(primaryObject == 'OpportunityLineItem'){
                Query +=' limit '+queryLimit;
                oppLineItems = Database.query(Query);
                for(Integer i=0; i<oppLineItems.size(); i++){
                    oppIds.add(oppLineItems[i].OpportunityId);
                }
                
            }
            else if(primaryObject == 'OpportunitySplit'){
                Query +=' limit '+queryLimit;
                oppSplits = Database.query(Query);
                for(Integer i=0; i<oppSplits.size(); i++){
                    oppIds.add(oppSplits[i].OpportunityId);
                }
            }
            else{
                Query +=' limit '+queryLimit;
                oppTeamMembers = Database.query(Query);
                for(Integer i=0; i<oppTeamMembers.size(); i++){
                    oppIds.add(oppTeamMembers[i].OpportunityId);
                }
            }
            if(oppIds.size()>0){
                //WR-170870 
                if(primaryObject == 'OpportunitySplit'){
                   for(list<Opportunity> olist : [Select Id,Account.Name,Amount,CloseDate,Name, Owner.Alias,CurrencyIsoCode , StageName,
                                        Owner.Name,Owner.isActive, Sales_Force__c, LeadSource, 
                                        Account.BillingState, Account.BillingCountry, Opportunity_Number__c 
                                        from Opportunity 
                                        where Id in: oppIds and IsClosed = false order by Name])
                          Listopp.addall(olist);                
                }
                else{
                    for(list<Opportunity> olist :[Select Id,Account.Name,Amount,CloseDate,Name, Owner.Alias,CurrencyIsoCode , StageName,
                                        Owner.Name,Owner.isActive, Sales_Force__c, LeadSource, 
                                        Account.BillingState, Account.BillingCountry, Opportunity_Number__c 
                                        from Opportunity 
                                        where Id in: oppIds])
                          Listopp.addall(olist);              
                }
                
                
            }
            
            
            
            //Listopp = Database.query(Query);
            //Added for WR-160725
            totalSearchResults = Listopp.size();///
            for(Integer i=0;i < resultSize && i<Listopp.size(); i++){
                    Opportunity op1 = Listopp[i];
                    OpDate=String.valueOf(Date.valueOf(op1.CloseDate));
                    System.debug('OpDate'+OpDate+' and the value of columnHeader is '+columnHeader);
                    oppWrap.add(new OpportunityWrapper(op1,false,columnHeader));

            }
            
            pmOffering.numberOfRows = oppWrap.size();
            pmOffering.page = 0;
        }catch(QueryException e){
            String errMsg = e.getMessage();
            System.debug('----------IN EXCEPTION------'+errMsg+'----'+errMsg.contains('invalid ID field:'));
            if(errMsg.contains('invalid ID field:')){
                errMsg = errMsg.replace('invalid ID field:','Please enter salesforce Id rather than'); 
                System.debug('-----------'+errMsg.replace('invalid ID field:','Please enter salesforce Id rather than'));
            }
            ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.Error,'Please check the filter criteria and advance criteria :- '+ errMsg);
            ApexPages.addMessage(msg2);
            throw e;
        }
    }
    public integer SelectedCount{get;set;}{SelectedCount=0;}
    public PageManager pmOffering {get; set;}{pmOffering = new PageManager(resultPageSize);}
    public list<OpportunityWrapper> oppts {get;set;}
    
    public list<OpportunityWrapper> getops(){
        List<OpportunityWrapper> data = new List<OpportunityWrapper>();
        for(integer i=pmOffering.startIndex;i<pmOffering.endIndex&&i<oppWrap.size();i++){
            data.add(oppWrap.get(i));
        }
        return data;
    }
    
    public Map<id,id> ProcessedOpptyIds = new Map<id,id>();
    public PageReference ContinueReassign()
    {
        if(oppwraplist!= null)
        {
           for(OpportunityWrapper opw : oppwraplist)
               ProcessedOpptyIds.put(opw.opp.id, opw.opp.id);
           oppwraplist.clear();
        }
        List<OpportunityWrapper> RemainingOppWrap = new List<OpportunityWrapper>();
        for(OpportunityWrapper opw : oppWrap){
            if(!ProcessedOpptyIds.containsKey(opw.opp.id))
               RemainingOppWrap.add(opw);
        }
        
        oppWrap.clear();
        oppWrap = RemainingOppWrap;
        
        pmOffering.numberOfRows = oppWrap.size();
        pmOffering.page = 0;
        
        return Page.OpportunitySearchResult;   
        //return nextStep2();
    }
    
    
        public void setoppWrap(List<OpportunityWrapper> ow){
            this.oppWrap=ow;
        }
        public List<OpportunityWrapper> getoppWrap(){
            System.debug('the value of oppWrap is '+oppWrap  );
            return oppWrap;
        }
        public List<OpportunityWrapper> getoppWraplist(){
            return oppWraplist;
        }
        
        public List<Opportunity>getSelectedOpportunties(List<OpportunityWrapper> SelectedWrappedOpps){
            List<Opportunity> OppList = new List<Opportunity>();
            for(OpportunityWrapper wrappedOpp:SelectedWrappedOpps){
                OppList.add(wrappedOpp.opp);
            }
            return OppList;
        }
        
/* This is a next method in select opportunities page, where if no opportunity is select it throws an error, and if
user selects more than 200 then also it throws an error. If these 2 validations is passed then based on the selected
option in the MassReassing page, the next page will be called */

        public PageReference nextStep3() {
         selectedCheck();
         if(oppWraplist.size()==0){
             ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Field_validation1);
             ApexPages.addMessage(msg1);
             return null;
         }
         else if(oppWraplist.size()>ProcessingLimit){
             System.debug('Size'+oppWraplist.size());
             ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Field_validation2);
             ApexPages.addMessage(msg2);
             oppWraplist.clear();
             return null;
        }
         
        if(operations=='Add an opportunity team member'){
            return Page.MassReassign_AddNewTeamMember;
         }
         else if(operations=='Remove an opportunity team member'){
            return Page.RemoveTeamMember;
         }
         else if(operations=='Replace an existing opportunity team member with same or previous forecast group') {
            return Page.ReplaceTeamMember;
         }
         return null;  
    }
           
   
/*This method is used to put the selected opportunities in oppWraplist */

        public void selectedCheck(){
        for(OpportunityWrapper oppw:oppWrap){
            if(oppw.checked==true){
                oppWraplist.add(oppw);
            }      
            }
        }

/*This is wrapper class for the opportunity */

    public class OpportunityWrapper{
    
        public boolean checked;
        public Opportunity opp;
        public String result;
        public List<String>ColumnValues=new List<String>(); 
        public OpportunityWrapper(Opportunity opp1,Boolean checked1,List<String>columnHeader){
            this.opp=opp1;
            this.checked=checked1;
           /* for(string Column: columnHeader){
               ColumnValues.add(''+opp.get(Column));
            }*/
        }
        public String getResult(){
            return result;
        }
        
        public void setResult(String result){
            this.result=result;
        }
        
        public void setChecked(boolean c){
        this.checked=c;
        }
        public boolean getChecked(){
        return this.checked;
        }
        
        public Opportunity getOpp(){
        return this.opp;
        }
        public void setOpp(Opportunity op){
        this.opp=op;
        }
     }
 
 
   

/* These are the getter and setter methods for existing, replacing and new resource */

     String ExstingUser;
     String ReplaceUser;
     String NewUser;
     String fieldLabel;
     String str;
     String RemoveUser='';
     String fieldName='';
     
     public String getExstingUser(){
            return exstinguser;
    }

    public void setExstingUser(String exstinguser){
        this.exstinguser=exstinguser;
    }
    
    public String getnewuser(){
        return newuser;
    }
    
    public void setnewuser(String newuser){
        this.newuser=newuser;
    }
    
    public String getRemoveUser(){
        return Removeuser;
    }
    
    public void setRemoveUser(String RemoveUser){
        this.RemoveUser=RemoveUser;
    }

/* This is a search option method based on which the corresponding search method will be called and
the result will displayed in the search screen */

    public PageReference searchOption() {
        String userName = ApexPages.currentPage().getParameters().get('userName');
        userId = ApexPages.currentPage().getParameters().get('uid');       
        if(fieldName=='existing')
        {
             ExstingUser=userName;
             existingUserId = userId;
             return Page.ReplaceTeamMember;
        }
        else if(fieldName=='replace'){
             ReplaceUser=userName;
             replaceUserId = userId;
             validation();
             return Page.ReplaceTeamMember;
        }
        else if(fieldName=='remove') {
             RemoveUser=userName;
             removeUserId = userId;
             return new PageReference ('/apex/RemoveTeamMember');
        }
        else if(fieldName=='newuser'){
           //Code for User search.//
            searchText=userName;
            //Code for User search.//
            //NewUser=userName;
            newUserId = userId;
            System.debug('The value of newUserId is '+newUserId);
            return new PageReference ('/apex/MassReassign_AddNewTeamMember');
        }
        return null;
    }
    
/* This method is used for the field validation, if existing and replace resource both field contains the same 
resource */

    public PageReference validation(){
        if(ExstingUser==ReplaceUser){
            ApexPages.Message msg5 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Field_validation3);
            ApexPages.addMessage(msg5);
            return Page.ReplaceTeamMember;
        }
        else{
            return null;
        }
    }

/* This is search method called from the replace resource button, where we are passing the parameters and calling 
user search page to perform the search operation */
    boolean replaceUserSearch=false;
    public PageReference replaceSearch() {
        fieldName = 'replace';
        str='active';
        if(users!=null)
        {
        users.clear();
        }
        replaceUserSearch=true;
        existingUser=false;
        SearchUsers();
        System.debug('The value of user searched is '+users);
        System.debug('The value of RelaceText searched is '+replaceUserSearch);
        if(users.size()>1)
        {
            return new PageReference ('/apex/UserSearch');
        }
        else if(users.size()==1)
        {
            ReplaceUser=users[0].Name;
            replaceUserId=users[0].Id;
            
            return null;
        }
        return null;
        //return new PageReference ('/apex/UserSearch');
        
    }

/* This is search method called from the existing resource button, where we are passing the parameters and calling 
user search page to perform the search operation */
    boolean existingUser=false;
    public PageReference existingSearch() {
        fieldName = 'existing';
        str='all';
        existingUser=true;
        replaceUserSearch=false;
        SearchUsers();
        System.debug('The value of user searched is '+users);
        System.debug('The value of ExtsearchText searched is '+ExstingUser);
        if(users.size()>1)
        {
            return new PageReference ('/apex/UserSearch');
        }
        else if(users.size()==1)
        {
            ExstingUser=users[0].Name;
            existingUserId=users[0].Id;
            return null;
        }
        return null;
        
    }
    
/* This is search method called from the new resource button in add new resource page, where we are passing the 
parameters and calling user search page to perform the search operation */
        boolean newUserExist=false;
        public PageReference newSearch() {
        System.debug('i am here');
        fieldName = 'newuser';
        str = 'active';
        newUserExist=true;
        //Code By Shipra to enable user search//
        SearchUsers();
        System.debug('The value of user searched is '+users);
        System.debug('The value of NewsearchText searched is '+searchText);
        if(users.size()>1)
        {
            return new PageReference ('/apex/UserSearch');
        }
        else if(users.size()==1)
        {
            searchText=users[0].Name;
            newUserId=users[0].Id;
            return null;
        }
        return null;
        //End of code By Shipra For user search//
    }

/* This is search method called from the remove resource button in remove existing resource page, where we are passing 
the parameters and calling user search page to perform the search operation */
    boolean removeuserSearch=false;
    public PageReference removeUserSearch() {
        System.debug('Is it coming here');
        fieldName = 'remove';
        str = 'all';
        removeuserSearch=true;
        SearchUsers();
        System.debug('The value of user searched is '+users);
        System.debug('The value of RemovesearchText searched is '+RemoveUser);
        if(users.size()>1)
        {
            return new PageReference ('/apex/UserSearch');
        }
        else if(users.size()==1)
        {
            RemoveUser=users[0].Name;
            RemoveUserId=users[0].Id;
            System.debug('RemoveUserId------> '+RemoveUserId);
            return null;
        }
        return null;
        //return new PageReference ('/apex/UserSearch');
    }
    

/*This is the getter setter method for the Replace resource */
 
    
    public String getReplaceUser(){
        return replaceuser;
    }
    
    public void setReplaceUser(String replaceuser){
        this.replaceuser=replaceuser;
    }

/* This is list which contains the users along with getter and setter methods */

    public String searchText;


    public List<User> users;
    
    public List<User> getUsers() {
        return users;
    }

        public void setUsers(List<user> users){
        this.users=users;
        }

        public String getSearchText(){
        return searchText;
        }
        public void setSearchText(String searchText){
        this.searchText=searchText;
        }

/* This is search method which perform the search based on the parameter passed, if it is existing resource all users 
will be displayed, if it is replace resource only active users will be displayed */
//*** Updated Code as per comments from Mike for defect 730 to narrow down the search***//   
    public PageReference SearchUsers() {
        try{
              System.debug('str='+str+'---'+searchText);
               if(existingUser==true){
                searchText=ExstingUser; 
                System.debug('The Value of ExstingUser is '+searchText);
                }
                if(replaceUserSearch==true){
                    searchText=ReplaceUser;
                    System.debug('The Value of removeuser is '+searchText);
                }
                if(removeuserSearch==true){
                    searchText=RemoveUser;
                    System.debug('The Value of removeuser is '+searchText);
                }
              if(searchText=='' || searchText.length()<=1){
               searchText = 'a%';
              }
             
              if(str=='active'){
               
                users = [select Id,name,Role__c,BU_Attribute__c,Forecast_Group__c from user where (FirstName like: (searchText+'%')or LastName like: (searchText+'%')or Name like: (searchText+'%')) and isactive=true limit 1000]; 
              }
              else if(str=='all'){
                
                users = [select Id,name,Role__c,BU_Attribute__c,Forecast_Group__c from user where (FirstName like: (searchText+'%') or LastName like: (searchText+'%')or Name like: (searchText+'%'))limit 1000];
              }
              
              if(users.size()>200)
              {
                ApexPages.Message error1 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Narrow_To_Fewer_Records);
                ApexPages.addMessage(error1);
                users.clear();
              }
              
        }catch(Exception e){
            
            ApexPages.Message error1 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Unexpeted_Error);
            ApexPages.addMessage(error1);
        }
         return null;
    } 
//*** end of update***//    
/* This is cancel method in the user search page, where the cancel option is performed based on the user input */

    public PageReference searchCancel() {
        if(operations=='Add an opportunity team member'){
            return Page.MassReassign_AddNewTeamMember;
         }
         else if(operations=='Remove an opportunity team member'){
            return Page.RemoveTeamMember;
         }
         else if(operations=='Replace an existing opportunity team member with same or previous forecast group') {
            return Page.ReplaceTeamMember;
         }
         return Page.MassReassign;
    }
    

//For Search button in ReplaceTeamMember

    public PageReference search() {
           return new PageReference('/'+'apex/UserSearch');

    }

/* This is replace method where if no user is selected will throw an error, does the field validation, and on selecting
the resource it show the selected opportunities in a opportunity result page */

    public PageReference replace() {
        try{
        System.debug('Is it coming');
        // 11 Aug 10 Shipra Misra Changing user interface.
        existingSearch();
       
        System.debug('The value of existing id is '+existingUserId+'The value of New user id is '+replaceUserId);
        // 11 Aug 10 Shipra Misra Changing user interface.
        if(ExstingUser==''){
            ApexPages.Message msg4 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.ReplaceTeam_Error);
            ApexPages.addMessage(msg4);
            return null;
        }
        else if(existingUserId==null ){
             ApexPages.Message msg3 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Select_ExistingUser);
             ApexPages.addMessage(msg3);
             return null;               
        }
         replaceSearch();
         if(ReplaceUser=='' ){
            ApexPages.Message msg4 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.ReplaceTeam_Error);
            ApexPages.addMessage(msg4);
            return null;
        }
        else if(replaceUserId==null){
             ApexPages.Message msg3 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Select_NewUser);
             ApexPages.addMessage(msg3);
             return null;               
        }
        else{
            /*for(OpportunityWrapper opplst:oppWraplist){
             ID i = opplst.opp.Id;
             opportunityResult.put(i,'Success');
              }*/
              List<ID> opportunityID =selectOpportunityId();
              System.debug('OpportunityID1'+opportunityID);
              System.debug('New user'+replaceUserId);
              System.debug('Existing User'+existingUserId); 
              Opp_MassUserReassignment replaceObj = new Opp_MassUserReassignment();
              opportunityResult=replaceObj.replace(opportunityID,replaceUserId,existingUserId);              
              System.debug('Opportunity Result'+opportunityResult);
              populateResult(opportunityResult);
              return Page.OperationResult;
            }
    }catch(Exception e){
        ApexPages.Message error1 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Unexpeted_Error);
        ApexPages.addMessage(error1);
        system.debug('Unxpected Exception on replace '+e);
        return null;           
    }
    }
    

/*This is common cancel method called from all the page, on click of which it returns to main page */

    public PageReference cancel() {
        title1=false;
        title2=false;
        title3=false;
        System.debug('the value of opportunityResult is'+opportunityResult+'The value of oppWraplist is'+oppWraplist+'The value of user'+users);
        ReplaceUser=null;
        NewUser=null;
        fieldLabel=null;
        str=null;
        RemoveUser=null;
        fieldName=null;
        Value1=null;
        ExstingUser=null;
        primaryObject=null;
        for(Integer i=0; i<5; i++){
        filters[i].filterFieldValue=null;
        filters[i].filterField = 'None';
        filters[i].filterOperator='None'; 
        filters[i].validOperators.clear();
        filters[i].validOperators.add(new SelectOption('None','-- None --'));
        }
        fieldName=null;
        if(opportunityResult!=null){
            opportunityResult.clear();
        }
        if(oppWraplist!=null){
            oppWraplist.clear();
        }
        if(users!=null){
            users.clear();
        }
         System.debug('the value of opportunityResult is'+opportunityResult+'The value of oppWraplist is'+oppWraplist+'The value of user'+users);
        //Srinivas Nallapati WR-162884
        Pagereference pge = Page.MassReassign;
        pge.setRedirect(true);
        return pge;
        //*****//
    }
    
    
/* This is remove method where if no user is selected will throw an error, does the field validation, and on selecting
the resource it shows the selected opportunities in a opportunity result page */

    public PageReference remove() {
      try{ 
       // 11 Aug 10 Shipra Misra Changing user interface.
       removeUserSearch();
       // 11 Aug 10 Shipra Misra Changing user interfa
       if(RemoveUser==''){
            ApexPages.Message msg3 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.RemoveTeam_Error);
            ApexPages.addMessage(msg3);
            return null;
        }
        else if(removeUserId==null){
             ApexPages.Message msg3 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Select_User);
             ApexPages.addMessage(msg3);
             return null;               
        }
        else{
            /*for(OpportunityWrapper opplst:oppWraplist){
                 ID i = opplst.opp.Id;
                 opportunityResult.put(i,'Success');
            }*/
            List<ID> opportunityID =selectOpportunityId(); 
             System.debug('opportunity ID'+opportunityID);
             System.debug('remove User'+removeUserId);
             Opp_MassUserReassignment removeObj = new Opp_MassUserReassignment();
             System.debug('opportunity ID'+opportunityID);
             opportunityResult=removeObj.remove(opportunityID,removeUserId);
             populateResult(opportunityResult);
             System.debug('opportunity ID'+opportunityID);
             return Page.OperationResult;
        }
       }catch(Exception e ){
            ApexPages.Message error1 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Unexpeted_Error);
        ApexPages.addMessage(error1);
        system.debug('Unxpected Exception on remove '+e);
                return null;               
       }
       
    }
    
 
   public List<ID> selectOpportunityId(){
       List<ID> opportunityID = new List<ID>();
       for(OpportunityWrapper opplst:oppWraplist){
            ID i = opplst.opp.Id;
            System.debug('opportunity ID'+i);
            opportunityID.add(i);
       }
        return opportunityID;
    }
        
/* This List is used to display the radio buttons along with the description to add, remove or replace 
a resource */

    String operations = null;

    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Add an opportunity team member',System.Label.Add_Team));
        options.add(new SelectOption('Remove an opportunity team member',System.Label.Remove_Opp)); 
        options.add(new SelectOption('Replace an existing opportunity team member with same or previous forecast group',System.Label.Replace_Existing));
     //       options.add(new SelectOption('Change Role of an existing team member',System.Label.Change_Role));
        return options; 
        }
                   
    public String getOperations() {
        return operations;
    }
                    
    public void setOperations(String operations) { 
        this.operations = operations;
    }
     
/* This is getter and setter method for the drop down list in the user search page */

    String usr = null;
 
    public String getUsr() {
        return usr;
    }
                        
    public void setUsr(String usr) {
        this.usr = usr;
    }

/* This is add method where if no user is selected will throw an error, does the field validation, and on selecting
the resource it shows the selected opportunities in a opportunity result page */
    
    public PageReference addSalesTeamMember() {
        // if(NewUser==''){
         // 11 Aug 10 Shipra Misra Changing user interface.
         newSearch();
         // 11 Aug 10 Shipra Misra Changing user interface.l
         if(searchText==''){
             ApexPages.Message msg3 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.NewTeam_Error);
             ApexPages.addMessage(msg3);
             return null;
        }else if(newUserId==null){
             ApexPages.Message msg3 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Select_User);
             ApexPages.addMessage(msg3);
             return null;               
        }
        else{
             /*for(OpportunityWrapper opplst:oppWraplist){
                  ID i = opplst.opp.Id;
                  opportunityResult.put(i,'Failure');
                }
             */
             User rep=[Select id,Name, Forecast_Group__c from user where id=:newUserId];
             //if(owner.size()>0 && owner[0]=='Set as Owner' && Rep.Forecast_Group__c!='Direct'&& Rep.Forecast_Group__c!='Maintenance Renewals' ) {
            //Change for WR-151992
             if(owner.size()>0 && owner[0]=='Set as Owner' && !(mapSpecial_Forecast_Groups.containskey(Rep.Forecast_Group__c) && mapSpecial_Forecast_Groups.get(Rep.Forecast_Group__c).Ownership_Allowed__c) )
             {
                 ApexPages.Message msg3 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Direct_Rep_As_Owner);
                 ApexPages.addMessage(msg3);
                 return null;
             }
             Opp_MassUserReassignment replaceObj = new Opp_MassUserReassignment();
             List<Opportunity>OppsToProcess= getSelectedOpportunties(OppWrapList);
             Set<Id>SetOwnerOpps = new set<Id>();
             if((owner.size()!=0 && owner[0]=='Set as Owner')){
                for(Opportunity opp:OppsToProcess){
                    SetOwnerOpps.add(opp.id);
                }
             }
             opportunityResult = replaceObj.addSalesTeamMember(rep,OppsToProcess,'Edit',SetOwnerOpps,null);               

             //opportunityResult =new MassAddSalesTeam_Prasad().addSalesTeamMember(rep,getSelectedOpportunties(OppWrapList),'Edit','other',(owner.size()!=0 && owner[0]=='Set as Owner')); 
             populateResult(opportunityResult);  
             return Page.OperationResult;
            }
    }  

/* This list method is used to show the check box while adding the new resource */
    
    String[] owner = new String[]{};
    public List<SelectOption> getValue() {
        List<SelectOption> val = new List<SelectOption>();
        val.add(new SelectOption('Set as Owner',System.Label.Set_Owner));
        return val; 
    }

    public String[] getOwner() {
        return owner;
    }
                        
    public void setowner(String[] owner) {
        this.owner = owner;
    }
    
    public void titleOperation(){
    
    }
    

//Assignment

    Schema.SObjectField Opptyfield;
    Schema.SObjectField Acctfield;
    Schema.SObjectField Splitfield;
    Map<String, Schema.SObjectField> Object1Fields;
    Map<String, Schema.SObjectField> Object2Fields;
    Map<String, Schema.SObjectField> UserFields;
    Integer startingIndex = 0;
    Integer endingIndex;
    String retObject;
    String retField;
    public String AdvanceFilter {get ;set ; }

     
    String Filtervalue1;
    String Filtervalue2;
    String Filtervalue3;
    String Filtervalue4;
    String Filtervalue5;
    List<String> FiltersList;

    public List<SelectOption> getFieldTypeOptions() {                
            List<SelectOption> options = new List<SelectOption>();      
            options.add(new SelectOption('None:None:None',System.Label.EMC_None));  
            
            Set<String> userFieldsVisible = new Set<String>();
            userFieldsVisible.add('Alias');
            userFieldsVisible.add('FirstName');
            userFieldsVisible.add('LastName');
            userFieldsVisible.add('Name');
            userFieldsVisible.add('District__c');
            userFieldsVisible.add('Area__c');
            userFieldsVisible.add('Division__c');
            userFieldsVisible.add('Forecast_Group__c');
            userFieldsVisible.add('BU_Attribute__c');
                        
            //createFiters();  
            String object1 = selectedObject.split(';')[0];
            String object2 = selectedObject.split(';')[1];
            
            if(object2=='OpportunityTeamMember'){
                object2 = 'User';
            }
            System.debug('-------------Object 2 Name-----------'+object2);
            
            Object1Fields = ((Schema.getGlobalDescribe()).get(object1).getDescribe()).fields.getMap();
            Object2Fields = ((Schema.getGlobalDescribe()).get(object2).getDescribe()).fields.getMap();
                        
            String object1Label = ((Schema.getGlobalDescribe()).get(selectedObject.split(';')[0]).getDescribe()).getLabel();
            String object2Label = ((Schema.getGlobalDescribe()).get(selectedObject.split(';')[1]).getDescribe()).getLabel();
            
            System.debug('--------------OBJECT 1 LABEL:'+object1Label);
            //Object1Fields = Schema.SObjectType.Opportunity.fields.getMap();
            //Object2Fields = Schema.SObjectType.Account.fields.getMap();
            //SplitFields = Schema.SObjectType.OpportunitySplit.fields.getMap();
                        
            System.debug('fieldMapOpportunity'+Object1Fields);
            System.debug('fieldMapOpportunity size'+Object1Fields.size() );
            
            System.debug('fieldMapAccount'+Object2Fields);
            System.debug('fieldMapAccount size'+Object2Fields.size() );
            
            //System.debug('fieldMapOpptySplit Fields'+SplitFields);
            //System.debug('fieldMapOpptySplit size'+SplitFields.size() );
            
            List<String> Opptykeys = sortByFieldLabel(Object1Fields);
            List<String> Acctkeys = sortByFieldLabel(Object2Fields);
            //List<String> Userkeys = sortByFieldLabel(UserFields);
            
            System.debug('opptyFields'+Opptykeys );
            System.debug('opptyFields size'+Opptykeys.size() );
            
            System.debug('Acct Fields'+Acctkeys);
            System.debug('Acct Fields size'+Acctkeys.size() );
            
            //System.debug('oppty split Fields'+OpptySplitkeys);
            //System.debug('oppty split Fields size'+OpptySplitkeys.size() );           
            
            if(selectedObject.split(';')[1]!='OpportunitySplit'){           
                for(String key:Opptykeys) {
                    Schema.DescribeFieldResult d = Object1Fields.get(key).getDescribe();
        
                    if(d.isAccessible() ) {
                        if (isSupportedFieldType(d)) {
                            String label = d.getLabel();
                            label = object1Label+': '+label ;
                            String fieldType = (d.getType()).name();
                            if(key=='OwnerId'){
                                continue;
                            }
                            if(label=='Opportunity: Account Owner'){
                                System.debug('----------Relationship Name----->'+d.getRelationshipName());
                                label = 'Opportunity: Account Owner Name';
                                key = d.getRelationshipName()+'.Name';
                                fieldType = 'STRING';
                            }
                            if(fieldType=='Reference'){
                                key = d.getRelationshipName()+'.Name';
                                fieldType = 'STRING';
                            }
                            options.add(new SelectOption(selectedObject.split(';')[0]+':'+key+':'+fieldType, label));
                        }
                    }
                }
            }
            for(String key:Acctkeys) {
                Schema.DescribeFieldResult d = Object2Fields.get(key).getDescribe();
                if(d.isAccessible() ) {
                    if (isSupportedFieldType(d)) {
                        String label = d.getLabel();
                        label = object2Label+': '+label ;
                        String fieldType = (d.getType()).name();
                        System.debug('---------in Options------'+object2+'-------------'+key+'----------'+userFieldsVisible.contains(key));
                        if(object2 == 'User' && (!userFieldsVisible.contains(key))){
                            continue;
                        }
                        if(object2 == 'User' && (userFieldsVisible.contains(key))){
                            key = 'User.'+key;
                        }
                        if(fieldType=='Reference'){
                            key = d.getRelationshipName()+'.Name';
                            fieldType = 'STRING';
                        }
                        options.add(new SelectOption(selectedObject.split(';')[1]+':'+key+':'+fieldType, label));
                    }
                }
            }
            if(object2 == 'User'){
                options.add(new SelectOption(selectedObject.split(';')[1]+':'+'TeamMemberRole'+':'+'PICKLIST', 'Opportunity Team Member: Team Role'));
            }
            /*for(String key:OpptySplitkeys) {
                Schema.DescribeFieldResult d = SplitFields.get(key).getDescribe();
    
                if(d.isAccessible() ) {
                    if (isSupportedFieldType(d)) {
                        String label = d.getLabel();
                        label = 'Split'+': '+label ;
                        System.debug('Split labels----->'+label);
                        options.add(new SelectOption('Split.'+key, label));
                    }
                }
                
            }*/
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
        
          private boolean isSupportedFieldType(DescribeFieldResult d) {
            
            // always return true for now, but in future some fields might not be supported
            return true;
        }        
        
        public String select1 {
            get;
            set ;
        }
        public String select2 {
            get;
            set ;
        }
        public String select3 {
            get;
            set ;
        }
        public String select4 {
            get;
            set ;
        }
        public String select5 {
            get;
            set ;
        }
        public String select6 {
            get;
            set ;
        }
        public String select7 {
            get;
            set ;
        }
        public String select8 {
            get;
            set ;
        }
        public String select9 {
            get;
            set ;
        }
        
      
        String filter1;
        public String getfilter1() {
            return filter1;
        }
        public void setfilter1(String filter1) {
        
            this.filter1 = filter1;
            System.debug('filter1---->'+filter1);
        }        
        
        public String filter2 {
            get;
            set ;
        }
        
        public String filter3 {
            get;
            set ;
        }
        public String filter4 {
            get;
            set;
        }
        public String filter5 {
            get;
            set;
        }
        
       
                     
        String fieldType; 
        String value1; 
        String value2;
        String value3; 
        String value4;
        String value5;      
        public String getvalue1(){
            return value1;
        }        
        public void setvalue1(String value1){
            this.value1 = value1;
        } 
               
        public String getvalue2(){
            return value2;
        }        
        public void setvalue2(String value2){
            this.value2 = value2;
        } 
              
        public String getvalue3(){
            return value3;
        }        
        public void setvalue3(String value3){
            this.value3 = value3;
        }  
        public String getvalue4(){
            return value4;
        }        
        public void setvalue4(String value4){
            this.value4 = value4;
        }
        public String getvalue5(){
            return value5;
        }        
        public void setvalue5(String value5){
            this.value5 = value5;
        }   
        
        
        
        public List<String> getcolumnHeader() {
            return columnHeader;
        }

        public void setcolumnHeader(List<String> columnHeader){
            this.columnHeader=columnHeader;
        }
       
        
        public PageReference selectAll(){
            for(OpportunityWrapper oppw:oppWrap){
                oppw.checked=true;
            }    
            return null;
        }   
        public PageReference deSelectAll(){
            for(OpportunityWrapper oppw:oppWrap){
                oppw.checked=false;
            }    
            return null;
        }     
  }