@isTest(SeeAllData = true) 
private class AutomateMaskingBatch_TC {
/*===========================================================================+
|  HISTORY                                                                   
| 
|  DATE       DEVELOPER       WR       DESCRIPTION                                
|
   ====       =========       ==       ===========  
|  16-Apr-2013  Prachi                 Created 
+===========================================================================*/ 
        public Static String objectName='Account';
       
        public Static List<String> maskingFields= new List<String>();
        
        public Static String maskText=null;
        public Static String citeria='test';
static testMethod void AutomateMaskingBatch(){
    
    Test.StartTest();
    maskingFields.add('id');
    maskingFields.add('Name');
    AutomateMaskingBatch obj= new AutomateMaskingBatch(objectName,maskingFields,maskText,citeria);
    Database.BatchableContext bc;
    List<SObject> st=new List<SObject>(); 
    Opportunity opt= new Opportunity();
    st.Add(opt);   
    obj.execute(bc,st);
    obj.finish(bc);    
    Test.StopTest();
}
}