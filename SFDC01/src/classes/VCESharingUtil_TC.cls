/*===========================================================================+
|  HISTORY                                                                   
| 
|  DATE       DEVELOPER       WR       DESCRIPTION                                
|
   ====       =========       ==       ===========  
|  10-Apr-2013  Prachi                 Created 
+===========================================================================*/ 
@isTest(SeeAllData = true) 
private class VCESharingUtil_TC {         
static testMethod void VCESharingUtil(){
    
    Test.StartTest();
    String recordType ='Quoting';
    Case obj = new Case();
    obj.Origin = 'Web';
    //obj.RecordType = Quoting;
    insert obj;
    List <Id> objID = new List <Id>();
    objID.add(obj.id);
    VCESharingUtil.getCaseMap(objID,recordType);
    Id conId= objID[0];
    Id recId= objID[0];
    Id parId= objID[0];
    
    VCESharingUtil.newPNRC(conId,recId);
    VCESharingUtil.newPNRC(conId,recId,parId);
    
    Test.StopTest();
}
}