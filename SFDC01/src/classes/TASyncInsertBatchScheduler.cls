/*=====================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  23.11.2012      Avinash K       212738      Initial Creation.  TA Sync Batch job Scheduler to insert TA Sync records.
 +=====================================================================================================================*/

global class TASyncInsertBatchScheduler implements Schedulable
{
  global void execute(SchedulableContext sc) 
    {

        String strBatchQuery = buildBatchQuery();

        if(strBatchQuery != null && strBatchQuery != '')
        {
            TA_Sync_Log_Insert batch = new TA_Sync_Log_Insert(strBatchQuery) ;
            Map<String,CustomSettingDataValueMap__c> mapDataValueMap = CustomSettingDataValueMap__c.getAll();
            Integer intNoOfRecordsPerBatch;

            
            if(mapDataValueMap!= null &&
                        mapDataValueMap.get('Number Of Records per TA Sync Batch') != null &&
                        mapDataValueMap.get('Number Of Records per TA Sync Batch').DataValue__c != null &&
                        Integer.valueOf(mapDataValueMap.get('Number Of Records per TA Sync Batch').DataValue__c) != null &&
                        Integer.valueOf(mapDataValueMap.get('Number Of Records per TA Sync Batch').DataValue__c) <= 200)
            {
                system.debug('#### Entered batch calling area');
                intNoOfRecordsPerBatch = Integer.valueOf(mapDataValueMap.get('Number Of Records per TA Sync Batch').DataValue__c);
                Database.executeBatch(batch, intNoOfRecordsPerBatch);
            }
        }
    }
 
  global String buildBatchQuery()
  {
    Map<String,CustomSettingDataValueMap__c> mapDataValueMap = CustomSettingDataValueMap__c.getAll();
    Integer intLimit;
    Integer InsertLimit;
    Date dteThirtyDaysBack = System.Today() - 30;
    String strQuery;
    string strIds = '';
    set<Id> userIdtobeIgnored = new set<Id>();
    set<Id> userInOpenStatus = new set<id>();
    Map<Id,TA_Sync_Log__c> mapWorkingTA= NEW map<Id,TA_Sync_Log__c>([Select id,name,status__c,Sales_Resource__c from TA_Sync_Log__c where status__c=:'Open' OR Status__c =:'EIS Insertions Complete' OR Status__c=:'Rowcount Validated' limit 100]);
    //userIdtobeIgnored=mapWorkingTA.keyset();
    if(mapDataValueMap!= null &&
                    mapDataValueMap.get('Number of Users Per TA Sync Request') != null &&
                    mapDataValueMap.get('Number of Users Per TA Sync Request').DataValue__c != null &&
                    Integer.valueOf(mapDataValueMap.get('Number of Users Per TA Sync Request').DataValue__c) != null &&
                    Integer.valueOf(mapDataValueMap.get('Number of Users Per TA Sync Request').DataValue__c) <= 50000)
      intLimit = Integer.valueOf(mapDataValueMap.get('Number of Users Per TA Sync Request').DataValue__c);
    else
      intLimit = 0;
          ////////////////////////////// 
         
    for(TA_Sync_Log__c ta:mapWorkingTA.values())
    {
      userIdtobeIgnored.add(ta.Sales_Resource__c);
      if(ta.status__c=='Open')
      {
        userInOpenStatus.add(ta.Sales_Resource__c);
      }
    }
    strIds = fn_getStringIds(userIdtobeIgnored);     
    
    if(intLimit>0)
    {
      InsertLimit= intLimit-userInOpenStatus.size();
      if(Util.isTestCoverage==true)
      {
        InsertLimit=1;
      }
    }
    
//////////////////////////////////////////////Logic to count number of request to be inserted per batch.//////////////////////////////////


   if(InsertLimit>0)   
   {  
    // fo String strQuery = 'select name, id, Profile_Name__c, Last_TA_Synch_Date__c from User where isActive = true AND id = \'00570000001LDv8AAG\'';
    // \'00570000001djXQ\',\'00570000001fvfX\',\'00570000001LCzr\'
    strQuery = 'select name, id, Profile_Name__c, Last_TA_Synch_Date__c, ProfileId, UserRoleId from User where isActive = true AND'+
       '(NOT Profile_Name__c  like \'%VAR%\') AND (NOT Profile_Name__c  like \'%Distributor%\') AND (NOT Profile_Name__c  like \'%Reseller%\') AND (Last_TA_Synch_Date__c = null OR Last_TA_Synch_Date__c < :dteThirtyDaysBack) AND UserType <> \'CSNOnly\' AND UserType  <> \'Guest\' ';
       
system.debug('#### strIds :: '+strIds);
    if(strIds != null && strIds.trim() != '')
      strQuery += ' AND id not in  '+strIds ;
    strQuery +=' ORDER BY Last_TA_Synch_Date__c asc limit '+InsertLimit;
    System.debug('strQuery==>'+strQuery);
   }
system.debug('####  strQuery ::'+strQuery);

    return strQuery;
  }
   public static string fn_getStringIds(Set<id> IdsToConcatenate_List){
    string strReturnedIds;
system.debug('#### IdsToConcatenate_List :: '+IdsToConcatenate_List);
    if(IdsToConcatenate_List != null && IdsToConcatenate_List.size() > 0)
      strReturnedIds = '(';
    for(id idItem : IdsToConcatenate_List)
    {
     if(strReturnedIds.length() > 1) //If strReturnedIds is not empty, adds a comma as separator before adding new values.
      strReturnedIds += ','; 
     strReturnedIds += '\'' + idItem + '\'';
    }
    if(IdsToConcatenate_List != null && IdsToConcatenate_List.size() > 0)
      strReturnedIds += ')';
    return strReturnedIds;
 }
}