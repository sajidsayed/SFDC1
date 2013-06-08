/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  05.03.2011      Anand Sharma                This is used to do unit testing of Page manager
 +=========================================================================================================================*/
@isTest
private class PageManager_TC {

   
    static testMethod void testConstructors01() {
        PageManager pm0 = new PageManager();
        PageManager pm1 = new PageManager(5);
            
    }
    
    static testMethod void testProperties01() {
    	// Normal Case 1
        PageManager pm = new PageManager(10);
        pm.numberOfRows = 102;
        System.assertEquals(11, pm.pageList.size());
        System.assertEquals(1, pm.pageList[0]);
        System.assertEquals(11, pm.pageList[pm.pageList.size()-1]);
        pm.page = 0;
        System.assertEquals(0, pm.startIndex);
        System.assertEquals(10, pm.endIndex);
        pm.page = 10;
        System.assertEquals(100, pm.startIndex);
        System.assertEquals(102, pm.endIndex);
        List<SelectOption> options = pm.pageOptions;
    }    
    
}