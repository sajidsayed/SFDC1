/*=====================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  23.11.2012      Avinash K       213868      Initial Creation. Scheduler Class for AP_Picklist_Maint_Notif batch class.
 +=====================================================================================================================*/

global class AP_Picklist_Maint_Notif_Scheduler implements Schedulable
{
	//public Boolean isRunTest=false;
    global void execute(SchedulableContext sc) 
    {
        Map<String,Set<String>> mapExistingFieldValues = new Map<String,Set<String>>();

        District_Lookup__c objDL = new District_Lookup__c();
        
        Set<String> setTemp = new Set<String>();
        

// Get the object type of the SObject.
        Schema.sObjectType objType = objDL.getSObjectType(); 

// Describe the SObject using District_Lookup__c type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       

// Get a map of fields for District_Lookup__c
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 

// Get the list of picklist values for all District Lookup Picklist fields.
        list<Schema.PicklistEntry> lstAreaValues = fieldMap.get('Area__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : lstAreaValues)
        { 
            setTemp.add(a.getValue()); 
        }
        mapExistingFieldValues.put('Area__c',setTemp);
        setTemp = new Set<String>();


        list<Schema.PicklistEntry> lstBRMAreaValues = fieldMap.get('BRM_Area__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : lstBRMAreaValues)
        { 
            setTemp.add(a.getValue()); 
        }
        mapExistingFieldValues.put('BRM_Area__c',setTemp);
        setTemp = new Set<String>();
        

        list<Schema.PicklistEntry> lstDivisionValues = fieldMap.get('Division__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : lstDivisionValues)
        { 
            setTemp.add(a.getValue()); 
        }
        mapExistingFieldValues.put('Division__c',setTemp);
        setTemp = new Set<String>();


        list<Schema.PicklistEntry> lstIntDomesticValues = fieldMap.get('International_Domestic__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : lstIntDomesticValues)
        { 
            setTemp.add(a.getValue()); 
        }
        mapExistingFieldValues.put('International_Domestic__c',setTemp);
        setTemp = new Set<String>();


        list<Schema.PicklistEntry> lstRegionValues = fieldMap.get('Region__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : lstRegionValues)
        { 
            setTemp.add(a.getValue()); 
        }
        mapExistingFieldValues.put('Region__c',setTemp);
        setTemp = new Set<String>();


        list<Schema.PicklistEntry> lstReportingLevelValues = fieldMap.get('Reporting_Level__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : lstReportingLevelValues)
        { 
            setTemp.add(a.getValue()); 
        }
        mapExistingFieldValues.put('Reporting_Level__c',setTemp);
        setTemp = new Set<String>();


        list<Schema.PicklistEntry> lstSuperAreaValues = fieldMap.get('Super_Area__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : lstSuperAreaValues)
        { 
            setTemp.add(a.getValue()); 
        }
        mapExistingFieldValues.put('Super_Area__c',setTemp);
        setTemp = new Set<String>();


        list<Schema.PicklistEntry> lstSuperRegionValues = fieldMap.get('Super_Region__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : lstSuperRegionValues)
        { 
            setTemp.add(a.getValue()); 
        }
        mapExistingFieldValues.put('Super_Region__c',setTemp);
        setTemp = new Set<String>();


        list<Schema.PicklistEntry> lstSuperReportingLevelValues = fieldMap.get('Super_Reporting_Level__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : lstSuperReportingLevelValues)
        { 
            setTemp.add(a.getValue()); 
        }
        mapExistingFieldValues.put('Super_Reporting_Level__c',setTemp);
        setTemp = new Set<String>();

        
//Send the MAp of Existing Picklist Values to the Batch Class
        AP_Picklist_Maint_Notif batch = new AP_Picklist_Maint_Notif(buildBatchQuery(), mapExistingFieldValues) ;
        
        Map<String,CustomSettingDataValueMap__c> mapDataValueMap = CustomSettingDataValueMap__c.getAll();
        Integer intNoOfRecordsPerBatch = 200;

        
        if(mapDataValueMap!= null &&
                    mapDataValueMap.get('Picklist Notification Batch Size') != null &&
                    mapDataValueMap.get('Picklist Notification Batch Size').DataValue__c != null &&
                    Integer.valueOf(mapDataValueMap.get('Picklist Notification Batch Size').DataValue__c) != null &&
                    Integer.valueOf(mapDataValueMap.get('Picklist Notification Batch Size').DataValue__c) <= 200)
        {
            intNoOfRecordsPerBatch = Integer.valueOf(mapDataValueMap.get('Picklist Notification Batch Size').DataValue__c);
            Database.executeBatch(batch, intNoOfRecordsPerBatch);
        }
    }

    global String buildBatchQuery()
    {
        
        String strQuery = 'SELECT Name, Area__c, BRM_Area__c, Division__c, International_Domestic__c, Oracle_District_ID__c, Region__c, Reporting_Level__c, Super_Area__c, Super_Region__c, Super_Reporting_Level__c FROM District_Lookup__c';
         if(Test.isRunningTest())
         {
         	strQuery ='SELECT Name, Area__c, BRM_Area__c, Division__c, International_Domestic__c, Oracle_District_ID__c, Region__c, Reporting_Level__c, Super_Area__c, Super_Region__c, Super_Reporting_Level__c FROM District_Lookup__c limit 50';
         }
        
        return strQuery;
    }
}