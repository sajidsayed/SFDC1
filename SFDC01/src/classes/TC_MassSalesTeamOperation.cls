/*
25-Mar-2011     Srinivas Nallapati      WR-160725 inserting a new record in Custom Setting DataValueMap if not present

*/
@isTest
public class TC_MassSalesTeamOperation {
    public static testMethod void massSalesTeamOp(){
        //Inserting Customsetting record 'MassReassignmentSearchResultSize' in DataValueMap custom settings if not found
        CustomSettingDataValueMap__c MassUserReassionSizeCSetting = CustomSettingDataValueMap__c.getInstance('MassReassignmentSearchResultSize');
        if(MassUserReassionSizeCSetting== null)
        {
            MassUserReassionSizeCSetting = new CustomSettingDataValueMap__c(name = 'MassReassignmentSearchResultSize', dataValue__c='1500');
            insert MassUserReassionSizeCSetting;
        }
        CustomSettingDataValueMap__c MassUserReassionPLimitCSetting = CustomSettingDataValueMap__c.getInstance('MassReassignmentProcessingLimit');
        if(MassUserReassionPLimitCSetting== null)
        {
            MassUserReassionPLimitCSetting = new CustomSettingDataValueMap__c(name = 'MassReassignmentProcessingLimit', dataValue__c='75');
            insert MassUserReassionPLimitCSetting;
        }
        CustomSettingDataValueMap__c MassUserReassionPageSizeCSetting = CustomSettingDataValueMap__c.getInstance('MassReassignmentSearchResultPageSize');
        if(MassUserReassionPageSizeCSetting== null)
        {
            MassUserReassionPageSizeCSetting = new CustomSettingDataValueMap__c(name = 'MassReassignmentSearchResultPageSize', dataValue__c='75');
            insert MassUserReassionPageSizeCSetting;
        }
        //End of inserting Custom Setting record
        
        MassSalesTeamOperation massSalesTeam = new MassSalesTeamOperation();
        
        Account accTest= new Account();
        accTest.Name='Test Account 111';
        accTest.CurrencyIsoCode='USD';
        insert accTest;
        
        Opportunity opp= new Opportunity();
        opp.name='Test Opportunity';
        opp.stageName='Pipeline';
        opp.CloseDate=System.today();
        opp.AccountId=accTest.id;
        opp.VMWare_Related__c='Not  related';
        opp.Sales_Channel__c='Direct';
        opp.Sales_Force__c='emc';
        insert opp;
        
        List<User> users = [select Id,name,Role__c,BU_Attribute__c,Forecast_Group__c from user where isactive=true limit 5];
        
        massSalesTeam.checkAccess();
        massSalesTeam.getDate1();
        massSalesTeam.massReassignmentHistory();
        Map<ID,String> mapOpptyResult = massSalesTeam.getOpportunityResult();
        massSalesTeam.populateResult(mapOpptyResult);
        massSalesTeam.previousStep2();
        massSalesTeam.nextStep2();
        massSalesTeam.previousStep4();
        massSalesTeam.previousStep3();
        massSalesTeam.getShowOkButton();
        
        String Operations1 = 'Add an opportunity team member';
        
        massSalesTeam.getOperations();
        massSalesTeam.setOperations(Operations1);
        
        
        massSalesTeam.nextStep1();
        //massSalesTeam.SearchOpportunity();
        massSalesTeam.selectedObject = 'Opportunity;Product2';
        System.debug('##########TEST#############'+massSalesTeam.getFieldTypeOptions()[2].getValue());
        massSalesTeam.filters[0].filterField = massSalesTeam.getFieldTypeOptions()[2].getValue();
        
        massSalesTeam.filterOperators();        
        massSalesTeam.filters[0].filterOperator = massSalesTeam.filters[0].validOperators[0].getValue();
        massSalesTeam.filters[0].filterFieldValue = 'abcd';
        
        massSalesTeam.createQuery();
        
        
        List<String> columnHeader = new String[6];
        columnHeader[0] = 'Account.Name';
        columnHeader[1] = 'Amount';
        columnHeader[2] = 'CloseDate';
        columnHeader[3] = 'Name';
        columnHeader[4] = 'Owner.Alias';
        columnHeader[5] = 'StageName';
        
        massSalesTeam.getcolumnHeader();
        massSalesTeam.setcolumnHeader(columnHeader);
        
        List<MassSalesTeamOperation.OpportunityWrapper> wrapList = massSalesTeam.getoppWraplist();
        massSalesTeam.getoppWrap();
        massSalesTeam.setoppWrap(wrapList);
        
        massSalesTeam.getSelectedOpportunties(wrapList);
        massSalesTeam.nextStep3();
        
        massSalesTeam.selectedCheck();
        
        String exstngUser='User';
        massSalesTeam.getExstingUser();
        massSalesTeam.setExstingUser(exstngUser);
        
        String newuser='User1';
        massSalesTeam.getnewuser();
        massSalesTeam.setnewuser(newuser);
        
        String RemoveUser='User2';
        massSalesTeam.getRemoveUser();
        massSalesTeam.setRemoveUser(RemoveUser);
        
        massSalesTeam.searchOption();
        massSalesTeam.validation();
       
        
        String ReplaceUser='replaceuser';
        massSalesTeam.getReplaceUser();
        massSalesTeam.setReplaceUser(ReplaceUser);
        
        //List<User> users = [select Id,name,Role__c,BU_Attribute__c,Forecast_Group__c from user where isactive=true limit 5];
        
        massSalesTeam.getUsers();
        massSalesTeam.setUsers(users);
        
        String Text='test';
        massSalesTeam.getSearchText();
        massSalesTeam.setSearchText(Text);
        massSalesTeam.SearchUsers();
        massSalesTeam.searchCancel();
        massSalesTeam.search();
        massSalesTeam.replace();
        massSalesTeam.cancel();
        massSalesTeam.remove();
        massSalesTeam.selectOpportunityId();
        massSalesTeam.getItems();
        massSalesTeam.getOperations();
        
        // My code
        
        massSalesTeam.setvalue1('test1');
        massSalesTeam.getvalue1();        
        
        massSalesTeam.setvalue2('test2');
        massSalesTeam.getvalue2();
        
        massSalesTeam.getvalue3();
        massSalesTeam.setvalue3('test3');        
        
        massSalesTeam.setvalue4('test4');
        massSalesTeam.getvalue4();
        
        massSalesTeam.getvalue5();
        massSalesTeam.setvalue5('test5');
        massSalesTeam.getValue();
        
        massSalesTeam.getOwner();
        List<string> Owner=new List<string>();
        Owner.add('test');
        massSalesTeam.setowner(Owner);
        
        massSalesTeam.titleOperation();
        massSalesTeam.getresultPageSize();
        
         
        // My code
        
        /*String Operations = 'startsWith';
        massSalesTeam.setOperations(Operations);
        
        massSalesTeam.getUsr();
        
        String Usr = 'test';
        massSalesTeam.setUsr(Usr);
        
        massSalesTeam.addSalesTeamMember();
        massSalesTeam.getValue();
        massSalesTeam.titleOperation();
        
        String[] Owner = new String[2];
        Owner[0] = 'Test';
        Owner[1] = 'test';
        
        massSalesTeam.getOwner();
        massSalesTeam.setowner(Owner);
        
        massSalesTeam.getNumberOperators('Date');        
        massSalesTeam.getDateOperator();
        
        
        
        String Operator1 = '=';
        String Operator2 = '<';
        String Operator3 = '>';
        String Operator4 = '!=';
        String Operator5 = 'startsWith';
        
        massSalesTeam.getOperator1();
        massSalesTeam.setOperator1(Operator1);
        
        massSalesTeam.getOperator2();
        massSalesTeam.setOperator2(Operator2);
        
        massSalesTeam.getOperator3();
        massSalesTeam.setOperator3(Operator3);
       
        massSalesTeam.getOperator4();
        massSalesTeam.setOperator4(Operator4);
        
        massSalesTeam.getOperator5();
        massSalesTeam.setOperator5(Operator5);
        
        massSalesTeam.settingDataType1();
        massSalesTeam.settingDataType2();
        massSalesTeam.settingDataType3();
        massSalesTeam.settingDataType4();
        massSalesTeam.settingDataType5();
                      
        massSalesTeam.getFieldTypeOptions();
        massSalesTeam.getSelectClauseOptions();
        
        String field = 'Opportunity.Name';
        massSalesTeam.getRelationshipName(field);
        
        String field1 = 'Opportunity.Name';
        massSalesTeam.getFieldDataType(field1);
        
        String fieldt = 'Account.Name';
        massSalesTeam.getRelationshipName(field);
        
        String field2 = 'Opportunity.CloseDate';
        massSalesTeam.getFieldDataType(field2);
        
        String fields = 'Opportunity.stageName';
        massSalesTeam.getRelationshipName(field);
        
        String field3 = 'Split.Id';
        massSalesTeam.getFieldDataType(field3);
        
        String value1='test1'; 
        String value2='test2';
        String value3='test3'; 
        String value4='test4';
        String value5='test5';
                
        massSalesTeam.setvalue1(value1);
        massSalesTeam.getvalue1();        
        
        massSalesTeam.setvalue2(value2);
        massSalesTeam.getvalue2();
        
        massSalesTeam.getvalue3();
        massSalesTeam.setvalue3(value3);        
        
        massSalesTeam.setvalue4(value4);
        massSalesTeam.getvalue4();
        
        massSalesTeam.getvalue5();
        massSalesTeam.setvalue5(value5);
        
        massSalesTeam.selectAll();
        massSalesTeam.deSelectAll();
        
        String Filter1 = 'Opportunity.Name';
        
        massSalesTeam.getfilter1();
        massSalesTeam.setfilter1(Filter1);
        
        massSalesTeam.getFilterList();
        
        massSalesTeam.newSearch();
        List <String> lst= new List <String>();
        lst.add('Test 1');
        MassSalesTeamOperation.OpportunityWrapper oppWrapper= new MassSalesTeamOperation.OpportunityWrapper(opp,true,lst);
        oppWrapper.getChecked();
        oppWrapper.setChecked(true);
        oppWrapper.getResult();
        oppWrapper.setResult('result');
        oppWrapper.getOpp();
        oppWrapper.setOpp(opp);
        masssalesteam.getFilterValue(field1, 'Equal', 'Test Opportunity');
        masssalesteam.getFilterValue(fieldt, 'contains', accTest.Id);
        masssalesteam.getFilterValue(fields, 'startsWith', 'Pipeline');
        masssalesteam.getFilterValue(field2, '>', '2010-03-03 00:00:00');
        masssalesteam.getFilterValue(field1, 'endsWith', 'nity');
        masssalesteam.getFilterValue(field1, 'not equal to', 'nity');
        masssalesteam.getFilterValue(field1, 'equals', 'nity');
        masssalesteam.getFilterValue(field1, '!=', 'nity');
        masssalesteam.getFilterValue(field2, '>', '2010-03-03 00:00:00');
        masssalesteam.getfieldType1();
        masssalesteam.getfieldType2();
        masssalesteam.getfieldType3();
        masssalesteam.getfieldType4();
        masssalesteam.getfieldType5();
        massSalesTeam.getNumberOperators('Test');
        
        massSalesTeam.AdvanceFilter = 'Opportunity.StageName like \'%Pipeline%\' ) AND (Opportunity.CloseDate>2010-03-03 ) AND (Opportunity.Name in (\'Test Opportunity 111\'))';
        massSalesTeam.getFilterList();
        massSalesTeam.addSalesTeamMember();*/
    }

    public static testMethod void massSalesTeamOp1(){
        //Inserting Customsetting record 'MassReassignmentSearchResultSize' in DataValueMap custom settings if not found
        CustomSettingDataValueMap__c MassUserReassionSizeCSetting = CustomSettingDataValueMap__c.getInstance('MassReassignmentSearchResultSize');
        if(MassUserReassionSizeCSetting== null)
        {
            MassUserReassionSizeCSetting = new CustomSettingDataValueMap__c(name = 'MassReassignmentSearchResultSize', dataValue__c='1500');
            insert MassUserReassionSizeCSetting;
        }
        CustomSettingDataValueMap__c MassUserReassionPLimitCSetting = CustomSettingDataValueMap__c.getInstance('MassReassignmentProcessingLimit');
        if(MassUserReassionPLimitCSetting== null)
        {
            MassUserReassionPLimitCSetting = new CustomSettingDataValueMap__c(name = 'MassReassignmentProcessingLimit', dataValue__c='75');
            insert MassUserReassionPLimitCSetting;
        }
        CustomSettingDataValueMap__c MassUserReassionPageSizeCSetting = CustomSettingDataValueMap__c.getInstance('MassReassignmentSearchResultPageSize');
        if(MassUserReassionPageSizeCSetting== null)
        {
            MassUserReassionPageSizeCSetting = new CustomSettingDataValueMap__c(name = 'MassReassignmentSearchResultPageSize', dataValue__c='75');
            insert MassUserReassionPageSizeCSetting;
        }
        //End of inserting Custom Setting record
        MassSalesTeamOperation massSalesTeam = new MassSalesTeamOperation();
        massSalesTeam.checkAccess();
        massSalesTeam.getDate1();
        String Operations1 = 'Remove an opportunity team member';
        
        massSalesTeam.getOperations();
        massSalesTeam.setOperations(Operations1);
        
        massSalesTeam.getItems();
        
        String Filter1 = 'Account.Name';
        massSalesTeam.getfilter1();
        massSalesTeam.setfilter1(Filter1);
        
        massSalesTeam.filter2 = 'Opportunity.Name';
        
        //String Operator1 = 'startsWith';
        //String Operator2 = 'startsWith';
        
        //massSalesTeam.getOperator1();
        //massSalesTeam.setOperator1(Operator1);
        
        //massSalesTeam.getOperator2();
        //massSalesTeam.setOperator2(Operator2);
        
        massSalesTeam.AdvanceFilter = 'or';
        String value1='test'; 
        String value2='test1';
        
        massSalesTeam.getvalue1();
        massSalesTeam.setvalue1(value1);
        
        massSalesTeam.getvalue2();
        massSalesTeam.setvalue2(value2);
        
        massSalesTeam.nextStep1();
        massSalesTeam.selectAll();
        massSalesTeam.nextStep3();
        
        List<MassSalesTeamOperation.OpportunityWrapper> wrapList = massSalesTeam.getoppWraplist();
        massSalesTeam.getoppWrap();
        massSalesTeam.setoppWrap(wrapList);
        
        String RemoveUser = 'dan';
        massSalesTeam.getRemoveUser();
        massSalesTeam.setRemoveUser(RemoveUser);
        massSalesTeam.removeUserSearch();
        
        String userVal = 'dan';
        massSalesTeam.getUsr();
        massSalesTeam.setUsr(userVal);
        
        String searchText = 'dan';
        massSalesTeam.getSearchText();
        massSalesTeam.setSearchText(searchText);
        
        massSalesTeam.SearchUsers();
        List<User> users = [Select Id from User where IsActive = true and name like 'Dan' limit 1];
        massSalesTeam.getUsers();
        massSalesTeam.setUsers(users);
        massSalesTeam.searchOption();
         
        massSalesTeam.remove();
        massSalesTeam.searchCancel();
        massSalesTeam.search();
        
        massSalesTeam.getoppWraplist();
        massSalesTeam.cancel();
        massSalesTeam.removeUserSearch();

    }
    
    public static testMethod void massSalesTeamOp2(){
        //Inserting Customsetting record 'MassReassignmentSearchResultSize' in DataValueMap custom settings if not found
        CustomSettingDataValueMap__c MassUserReassionSizeCSetting = CustomSettingDataValueMap__c.getInstance('MassReassignmentSearchResultSize');
        if(MassUserReassionSizeCSetting== null)
        {
            MassUserReassionSizeCSetting = new CustomSettingDataValueMap__c(name = 'MassReassignmentSearchResultSize', dataValue__c='1500');
            insert MassUserReassionSizeCSetting;
        }
        CustomSettingDataValueMap__c MassUserReassionPLimitCSetting = CustomSettingDataValueMap__c.getInstance('MassReassignmentProcessingLimit');
        if(MassUserReassionPLimitCSetting== null)
        {
            MassUserReassionPLimitCSetting = new CustomSettingDataValueMap__c(name = 'MassReassignmentProcessingLimit', dataValue__c='75');
            insert MassUserReassionPLimitCSetting;
        }
        CustomSettingDataValueMap__c MassUserReassionPageSizeCSetting = CustomSettingDataValueMap__c.getInstance('MassReassignmentSearchResultPageSize');
        if(MassUserReassionPageSizeCSetting== null)
        {
            MassUserReassionPageSizeCSetting = new CustomSettingDataValueMap__c(name = 'MassReassignmentSearchResultPageSize', dataValue__c='75');
            insert MassUserReassionPageSizeCSetting;
        }
        //End of inserting Custom Setting record
        MassSalesTeamOperation massSalesTeam = new MassSalesTeamOperation();
        massSalesTeam.checkAccess();
        massSalesTeam.getDate1();
        String Operations1 = 'Replace an existing opportunity team member with same or previous forecast group';
        
        massSalesTeam.getOperations();
        massSalesTeam.setOperations(Operations1);
        
        massSalesTeam.getShowOkButton();        
        massSalesTeam.getItems();
        
        String Filter1 = 'Account.Name';
        massSalesTeam.getfilter1();
        massSalesTeam.setfilter1(Filter1);
        
        //String Operator1 = 'equals';        
        //massSalesTeam.getOperator1();
        //massSalesTeam.setOperator1(Operator1);
        
        String value1='TEST,Test 2';        
        massSalesTeam.getvalue1();
        massSalesTeam.setvalue1(value1);
        massSalesTeam.nextStep1();
        
        massSalesTeam.massReassignmentHistory();
        
        massSalesTeam.nextStep2();
        massSalesTeam.previousStep2();
        massSalesTeam.cancel();
        
        massSalesTeam.selectAll();
        massSalesTeam.deSelectAll();
        
        List<MassSalesTeamOperation.OpportunityWrapper> wrapList = massSalesTeam.getoppWraplist();
        massSalesTeam.getoppWrap();
        massSalesTeam.setoppWrap(wrapList);        
        
        massSalesTeam.previousStep3();
        massSalesTeam.cancel();
        massSalesTeam.nextStep3();
        
        String exstngUser='dan';
        massSalesTeam.getExstingUser();
        massSalesTeam.setExstingUser(exstngUser);
        
        massSalesTeam.existingSearch();
        String userVal = 'dan';
        massSalesTeam.getUsr();
        massSalesTeam.setUsr(userVal);
        
        String searchText = 'dan';
        massSalesTeam.getSearchText();
        massSalesTeam.setSearchText(searchText);
        
        massSalesTeam.SearchUsers();
        List<User> users = [Select Id from User where IsActive = true and name like 'Dan' limit 1];
        massSalesTeam.getUsers();
        massSalesTeam.setUsers(users);
        massSalesTeam.searchOption();
        
        String ReplaceUser='prasad';
        massSalesTeam.getReplaceUser();
        massSalesTeam.setReplaceUser(ReplaceUser); 
        massSalesTeam.replaceSearch();
        
        String userVal1 = 'prasad';
        massSalesTeam.getUsr();
        massSalesTeam.setUsr(userVal1);
        massSalesTeam.addSalesTeamMember();
        String searchText1 = 'prasad';
        massSalesTeam.getSearchText();
        massSalesTeam.setSearchText(searchText1);        
        
        massSalesTeam.SearchUsers();
        List<User> users1 = [Select Id from User where IsActive = true and name like 'prasad' limit 1];
        massSalesTeam.getUsers();
        massSalesTeam.setUsers(users1);
        massSalesTeam.searchOption(); 
        
        massSalesTeam.previousStep4();
       
        massSalesTeam.replace();
       
        massSalesTeam.searchCancel();
        massSalesTeam.search();      
        
    }
    public static testMethod void massSalesTeamOp3(){
        //Inserting Customsetting record 'MassReassignmentSearchResultSize' in DataValueMap custom settings if not found
        CustomSettingDataValueMap__c MassUserReassionSizeCSetting = CustomSettingDataValueMap__c.getInstance('MassReassignmentSearchResultSize');
        if(MassUserReassionSizeCSetting== null)
        {
            MassUserReassionSizeCSetting = new CustomSettingDataValueMap__c(name = 'MassReassignmentSearchResultSize', dataValue__c='1500');
            insert MassUserReassionSizeCSetting;
        }
        CustomSettingDataValueMap__c MassUserReassionPLimitCSetting = CustomSettingDataValueMap__c.getInstance('MassReassignmentProcessingLimit');
        if(MassUserReassionPLimitCSetting== null)
        {
            MassUserReassionPLimitCSetting = new CustomSettingDataValueMap__c(name = 'MassReassignmentProcessingLimit', dataValue__c='75');
            insert MassUserReassionPLimitCSetting;
        }
        CustomSettingDataValueMap__c MassUserReassionPageSizeCSetting = CustomSettingDataValueMap__c.getInstance('MassReassignmentSearchResultPageSize');
        if(MassUserReassionPageSizeCSetting== null)
        {
            MassUserReassionPageSizeCSetting = new CustomSettingDataValueMap__c(name = 'MassReassignmentSearchResultPageSize', dataValue__c='75');
            insert MassUserReassionPageSizeCSetting;
        }
        //End of inserting Custom Setting record
        List<String> colHeaders = new List<String>();
        colHeaders.add('Header 1');
        colHeaders.add('Header 2');
        colHeaders.add('Header 3');
        colHeaders.add('Header 4');
        colHeaders.add('Header 5');
        Account accTest= new Account();
        accTest.Name='Test Account 111';
        accTest.CurrencyIsoCode='USD';
        insert accTest;
        
        Opportunity testOpp= new Opportunity();
        testOpp.name='Test Opportunity';
        testOpp.stageName='Pipeline';
        testOpp.CloseDate=System.today();
        testOpp.AccountId=accTest.id;
        testOpp.VMWare_Related__c='Not  related';
        testOpp.Sales_Channel__c='Direct';
        testOpp.Sales_Force__c='emc';
        insert testOpp;
        
        MassSalesTeamOperation.OpportunityWrapper oppWrpObj = new MassSalesTeamOperation.OpportunityWrapper(testOpp,true,colHeaders);
        oppWrpObj.setOpp(testOpp);
        oppWrpObj.setResult('result');
        oppWrpObj.setChecked(true);
        testOpp = oppWrpObj.getOpp();
        String result = oppWrpObj.getResult();
        Boolean checked= oppWrpObj.getChecked();
        
        
        
        MassSalesTeamOperation salesTeamObj = new MassSalesTeamOperation();
        salesTeamObj.selectedObject='Opportunity;Product2';
        List<SelectOption> fields = new List<SelectOption>();
        fields = salesTeamObj.getFieldTypeOptions();
        List<MassSalesTeamOperation.Filter> filters = new List<MassSalesTeamOperation.Filter>();
        filters = salesTeamObj.getFilters();
        filters[0].filterField = 'Opporunity:Name:STRING';
        filters[1].filterField = 'Product2:Name:STRING';
        salesTeamObj.setFilters(filters);
        salesTeamObj.filterOperators();
        //filters.clear();
        filters = salesTeamObj.getFilters();
        System.debug('@@@@@@@@@@@@@@@@@@@@@@'+filters[0].getValidOperators());
        filters[0].filterOperator = filters[0].getValidOperators()[2].getValue();
        filters[0].filterFieldValue = 'XYZ';
        filters[1].filterOperator = filters[1].getValidOperators()[2].getValue();
        filters[1].filterFieldValue = 'ABC';
        salesTeamObj.setFilters(filters);
        salesTeamObj.SearchOpportunity();
        
        Test.startTest();
        salesTeamObj.selectedObject='Opportunity;Account';
        fields = salesTeamObj.getFieldTypeOptions();
        filters = salesTeamObj.getFilters();
        filters[0].filterField = 'Opporunity:Name:STRING';
        filters[1].filterField = 'Account:Name:STRING';
        salesTeamObj.setFilters(filters);
        salesTeamObj.filterOperators();
        //filters.clear();
        filters = salesTeamObj.getFilters();
        System.debug('@@@@@@@@@@@@@@@@@@@@@@'+filters[0].getValidOperators());
        filters[0].filterOperator = filters[0].getValidOperators()[2].getValue();
        filters[0].filterFieldValue = 'XYZ';
        filters[1].filterOperator = filters[1].getValidOperators()[2].getValue();
        filters[1].filterFieldValue = 'ABC';
        salesTeamObj.setFilters(filters);
        salesTeamObj.SearchOpportunity();
        
        Test.stopTest();

        
        
                
    }
    
    public static testMethod void massSalesTeamOp4(){
        //Inserting Customsetting record 'MassReassignmentSearchResultSize' in DataValueMap custom settings if not found
        CustomSettingDataValueMap__c MassUserReassionSizeCSetting = CustomSettingDataValueMap__c.getInstance('MassReassignmentSearchResultSize');
        if(MassUserReassionSizeCSetting== null)
        {
            MassUserReassionSizeCSetting = new CustomSettingDataValueMap__c(name = 'MassReassignmentSearchResultSize', dataValue__c='1500');
            insert MassUserReassionSizeCSetting;
        }
        CustomSettingDataValueMap__c MassUserReassionPLimitCSetting = CustomSettingDataValueMap__c.getInstance('MassReassignmentProcessingLimit');
        if(MassUserReassionPLimitCSetting== null)
        {
            MassUserReassionPLimitCSetting = new CustomSettingDataValueMap__c(name = 'MassReassignmentProcessingLimit', dataValue__c='75');
            insert MassUserReassionPLimitCSetting;
        }
        CustomSettingDataValueMap__c MassUserReassionPageSizeCSetting = CustomSettingDataValueMap__c.getInstance('MassReassignmentSearchResultPageSize');
        if(MassUserReassionPageSizeCSetting== null)
        {
            MassUserReassionPageSizeCSetting = new CustomSettingDataValueMap__c(name = 'MassReassignmentSearchResultPageSize', dataValue__c='75');
            insert MassUserReassionPageSizeCSetting;
        }
        //End of inserting Custom Setting record
        List<String> colHeaders = new List<String>();
        colHeaders.add('Header 1');
        colHeaders.add('Header 2');
        colHeaders.add('Header 3');
        colHeaders.add('Header 4');
        colHeaders.add('Header 5');
        Account accTest= new Account();
        accTest.Name='Test Account 111';
        accTest.CurrencyIsoCode='USD';
        insert accTest;
        
        Opportunity testOpp= new Opportunity();
        testOpp.name='Test Opportunity';
        testOpp.stageName='Pipeline';
        testOpp.CloseDate=System.today();
        testOpp.AccountId=accTest.id;
        testOpp.VMWare_Related__c='Not  related';
        testOpp.Sales_Channel__c='Direct';
        testOpp.Sales_Force__c='emc';
        insert testOpp;
        
        MassSalesTeamOperation.OpportunityWrapper oppWrpObj = new MassSalesTeamOperation.OpportunityWrapper(testOpp,true,colHeaders);
        oppWrpObj.setOpp(testOpp);
        oppWrpObj.setResult('result');
        oppWrpObj.setChecked(true);
        testOpp = oppWrpObj.getOpp();
        String result = oppWrpObj.getResult();
        Boolean checked= oppWrpObj.getChecked();
        
        Test.startTest();
        
        MassSalesTeamOperation salesTeamObj = new MassSalesTeamOperation();
        salesTeamObj.selectedObject='Opportunity;OpportunityTeamMember';
        List<SelectOption> fields = new List<SelectOption>();
        fields = salesTeamObj.getFieldTypeOptions();
        List<MassSalesTeamOperation.Filter> filters = new List<MassSalesTeamOperation.Filter>();
                
        
        
        fields = salesTeamObj.getFieldTypeOptions();
        filters = salesTeamObj.getFilters();
        filters[0].filterField = 'Opportunity:Name:STRING';
        filters[1].filterField = 'OpportunityTeamMember:TeamMemberRole:PICKLIST';
        salesTeamObj.setFilters(filters);
        salesTeamObj.filterOperators();
        //filters.clear();
        filters = salesTeamObj.getFilters();
        System.debug('@@@@@@@@@@@@@@@@@@@@@@'+filters[0].getValidOperators());
        filters[0].filterOperator = filters[0].getValidOperators()[2].getValue();
        filters[0].filterFieldValue = 'XYZ';
        filters[1].filterOperator = filters[1].getValidOperators()[2].getValue();
        filters[1].filterFieldValue = 'ABC';
        salesTeamObj.setFilters(filters);
        salesTeamObj.SearchOpportunity();
        salesTeamObj.getops();
        salesteamObj.ContinueReassign();
        
        Test.stopTest();
                
    }

}