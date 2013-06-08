/*===========================================================================+
|  HISTORY                                                                   
| 
|  DATE       DEVELOPER       WR       DESCRIPTION                                
|
   ====       =========       ==       ===========  
|  03-Apr-2013  Prachi                 Created 
+===========================================================================*/ 
@isTest(SeeAllData = true) 
private class MassUpdateSimpleController_TC {

         public static List <Lead> leadLst= new List <Lead> ();
         public static List <Lead> leadObj1= new List <Lead> ();
        
static testMethod void MassUpdateSimpleController(){
    
    Test.StartTest(); 
    leadLst=[Select id from Lead limit 10];
    ApexPages.StandardSetController sc = new ApexPages.StandardSetController(leadLst);
    sc.setSelected(leadLst);
    MassUpdateSimpleController objC = new MassUpdateSimpleController(sc);
    
    objC.restrictPermission();
    objC.getStep();
    objC.getsType();
    objC.getRecordSize();
    objC.setFlag (false);
    objC.cancel();
    objC.getFlag();
    objC.getFlag1();
    objC.setFlag1(false);
    objC.getFieldInfoToDisplay();
    objC.step1();
    objC.step2();
    objC.step3();
    objC.getFieldTypeOptions();
    objC.fieldName='Name';
    objC.step4();
    objC.step5();
    
    objC.gettitle();
    objC.showOk();
    objC.getpreviousFlag();
    objC.getcancelFlag();
    objC.getokFlag();
    objC.settitle('title');
    objC.getNow(true);  
    ApexPages.StandardSetController sc1 = new ApexPages.StandardSetController(leadObj1);
    MassUpdateSimpleController objC1 = new MassUpdateSimpleController(sc1);
    objC1.getRecordSize();
    objC1.getNow(false);
    Test.StopTest();
}
}