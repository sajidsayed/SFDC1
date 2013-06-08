@isTest(SeeAllData=true)
private class MassOppReassignmentlog_TC {
     public static string orderby='opportunity_name__r.name asc';     
static testMethod void MassOppReassignmentlog(){
    
    Test.StartTest();   
    MassOppReassignmentlog obj1=new MassOppReassignmentlog();
    obj1.query(orderby);
    obj1.querylist(orderby);
    obj1.back();
    obj1.getresults();

    Test.StopTest();
}
}