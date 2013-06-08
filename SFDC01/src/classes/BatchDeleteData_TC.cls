/*==================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  08/04/2011    Suman B                         Test Class for BatchDeleteData. 
 |  04/04/2013    Krishna Pydavula		241804    Increased code coverage.
 +=================================================================================*/
@isTest
private Class BatchDeleteData_TC {
 
 private static testmethod void batchDeleteDataSchedulerTest() {
    Test.StartTest();
    String sch = '0 0 0 4 9 ?  ' ;
    try{
    	 BatchDeleteData objtest = new BatchDeleteData();
    	  objtest.isTest = true;
    system.schedule('TEST CLEAN UP- BatchDeleteData', sch, new BatchDeleteData());
    } catch(Exception e) {
      system.debug('Exception Inside batchDeleteDataSchedulerTest()' + e );   
     } 
    Test.StopTest(); 
  }
  
  private static testmethod void batchDeleteDataTest() {
   try{
     EMC_Exception__c e = new EMC_Exception__c(Messages__c = 'TEST DeleteData', Process_Id__c = 'TEST DeleteData');
      insert e ;
    }catch(Exception e ){
     system.debug('######Exception in batchDeleteDataTest --'+ e);
   } 
  Test.StartTest();   
      DateTime delDate = system.now()- 70;
      String query  = 'Select Id FROM EMC_Exception__c where LastModifiedDate  > '+ new PRM_CommonUtils().getQueryFormattedDate(delDate)+ 'limit 1';
      database.executebatch( new BatchDeleteData(query,'EMC_Exception__c') );
   Test.StopTest();
    
  }
	private static testmethod void batchDeleteDataTestTASync() {
	   try{
	     EMC_Exception__c e = new EMC_Exception__c(Messages__c = 'TEST DeleteData1', Process_Id__c = 'TEST DeleteData1');
	      insert e ;
	    }catch(Exception e ){
	     system.debug('######Exception in batchDeleteDataTest --'+ e);
	   } 
	  
	    Test.StartTest();   
	      DateTime delDate = system.now()- 30;
	      String queryTASync  = 'Select Id FROM EMC_Exception__c where LastModifiedDate  > '+ new PRM_CommonUtils().getQueryFormattedDate(delDate) +'limit 1';
	      database.executebatch(new BatchDeleteData(queryTASync,'EMC_Exception__c'));	    
	    Test.StopTest();
	    
	  }
}