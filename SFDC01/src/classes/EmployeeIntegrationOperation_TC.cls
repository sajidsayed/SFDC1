/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |                                              Initial Creation.
 |  Aug-2011        Saravanan C                 Test Class cleanup
 |  
 +===========================================================================*/
@isTest
private class EmployeeIntegrationOperation_TC{

public static testMethod void Test_EmployeeIntegrationOperation(){
    
    String recordTypeId = testclassUtils.getRecordTypeId('Contact','EMC Internal Contact');
    List<Contact> empList = new List<Contact>();
    List<EmpIntegrationResult> results = new List<EmpIntegrationResult>();
    
    Contact  testManager = testclassUtils.getContact();
 
    // Create and insert a contact that will be a manager
 
        testManager.RecordTypeId =  recordTypeId ;//recordTypeID.Id;
        testManager.PowerlinkID_Badge__c = 'TEST-0';
        testManager.FirstName = 'Test';
        testManager.LastName = 'Manager';
        testManager.Country_Local__c = 'Japan';
        testManager.Email = 'test.manager@emc.com.sfdc';
        testManager.Cost_Center__c = 'cost05678';
        testManager.Title = 'Manager';
        testManager.Phone = '617-555-0555';
        testManager.Fax = null;
        testManager.Department__c = 'IT';
        testManager.Start_Date__c = date.today();
        insert testManager;

    // set up test data that will be passed to method
    for (Integer i=1 ; i<10 ; i++) {
        Contact tempEmployee = new Contact();
            tempEmployee.AccountId = '0017000000OmdVa';
            tempEmployee.RecordTypeId = recordTypeId ;
            tempEmployee.PowerlinkID_Badge__c = 'TEST-'+i;
            tempEmployee.FirstName = 'Test';
            tempEmployee.LastName = 'Rep-'+i;
            tempEmployee.Country_Local__c = 'Japan';
            tempEmployee.Email = 'test.rep'+i+'@emc.com.sfdc';
            tempEmployee.Cost_Center__c = 'cost05678';
            tempEmployee.Title = 'Individual Contributor';
            tempEmployee.Phone = '617-555-0555';
            tempEmployee.Fax = null;
            tempEmployee.Department__c = 'IT';
            tempEmployee.Start_Date__c = date.today();
 

            if (i == 1) {
                // no manager id provided 
                tempEmployee.Direct_Manager_Badge__c = null;
            } else if (i < 5) {
                // reports to manager we created earlier
                tempEmployee.Direct_Manager_Badge__c = 'TEST-0';
            } else if (i == 5) {
                // reports to a manager that is not yet inserted
                tempEmployee.Direct_Manager_Badge__c = 'TEST-3';
            } else if (i < 8) {
                // reports to non-existent manager id
                tempEmployee.Direct_Manager_Badge__c = 'TEST-zz';
            } else {
                // duplicate employee badges
                tempEmployee.PowerlinkID_Badge__c = 'TEST-8';
                tempEmployee.Direct_Manager_Badge__c = 'TEST-0';
            } 
 
        empList.add(tempEmployee);
    }

    results = EmployeeOperation.synchEmployees(empList);

    for (Integer i=0 ; i < results.size() ; i++) {
        System.debug('test results = ' + results[i].EmployeeBadgeId + ' '
                        + results[i].IsSuccess + ' '
                        + results[i].ErrorMessage);
    }

    EmpIntegrationResult empIntResult = new EmpIntegrationResult();
    empIntResult.setEmployeeBadgeId( results[0].getEmployeeBadgeId() );
    empIntResult.setIsSuccess( results[0].getIsSuccess() );
    empIntResult.setErrorMessage( results[0].getErrorMessage() );
    
}
}