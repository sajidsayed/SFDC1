/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  17th Jan, 2013    Vijo Joy                    A general class to provide information
                                                  as per the needs
 |====            =========       ======      =========== 
 List of methods available:
 1. getRecordTypesMap: returns a map of record types([string] keys), with the record type id ([id] values)
                       @Parameters: Object Name. 
  +====================================================================================================*/

Public class GenUtilMethods{
    //Variable declarations used by all the methods
      
      
    Public Map<String,id> getRecordTypesMap(String s){
    Try{
        Map<String,Id> mapRecordTypes = new Map<String,Id>();
        Schema.SObjectType ObjToken = Schema.getGlobalDescribe().get(s);
        Schema.DescribeSObjectResult Res = ObjToken.getDescribe();
        List<Schema.RecordTypeInfo> RecordTypes = Res.getRecordTypeInfos();
        for(Schema.RecordTypeInfo rInfo : RecordTypes)
            mapRecordTypes.put(rInfo.getName(),rInfo.getRecordTypeId());
        Return mapRecordTypes;
        }
    Catch(Exception e){
    System.debug('Illegal Sobject Type');
    Return null;
    }
    }
}