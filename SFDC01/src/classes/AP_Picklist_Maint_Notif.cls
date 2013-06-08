/*=====================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  23.11.2012      Avinash K       213868      Initial Creation. Batch Class to compare the picklist values for District Lookup object' fields.
 +=====================================================================================================================*/

global class AP_Picklist_Maint_Notif implements Database.Batchable<sObject>, Database.Stateful
{
    global String query;
    global Map<String,Set<String>> mapExistingFieldValues = new Map<String,Set<String>>();
    global Map<String,Set<String>> mapNewFieldValues = new Map<String,Set<String>>();

    global AP_Picklist_Maint_Notif(String q, Map<String, Set<String>> mapExitingValues)
    {
        this.query = q;
        this.mapExistingFieldValues = mapExitingValues;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query); //May return up to 50 Million records
    }
  
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        for (District_Lookup__c dl : (List<District_Lookup__c>)scope) 
        {
            if(mapExistingFieldValues != null && mapExistingFieldValues.get('Area__c') != null && 
                !mapExistingFieldValues.get('Area__c').contains(dl.Area__c))
            {
                Set<String> setTemp = new Set<String>();                
                if (mapNewFieldValues.get('Area__c') != null && mapNewFieldValues.get('Area__c').size() > 0) 
                {
                    setTemp = mapNewFieldValues.get('Area__c');                    
                }
								
                if(dl.Area__c != null&&dl.Area__c!=''&&dl.Area__c!='null')
                {
                    setTemp.add(dl.Area__c);
                    mapNewFieldValues.put('Area__c', setTemp);
                }
            }
            if(mapExistingFieldValues != null && mapExistingFieldValues.get('BRM_Area__c') != null && 
                !mapExistingFieldValues.get('BRM_Area__c').contains(dl.BRM_Area__c))
            {
                Set<String> setTemp = new Set<String>();
                
                if (mapNewFieldValues.get('BRM_Area__c') != null && mapNewFieldValues.get('BRM_Area__c').size() > 0) 
                {
                    setTemp = mapNewFieldValues.get('BRM_Area__c');
                }

                if(dl.BRM_Area__c != null&&dl.BRM_Area__c!=''&&dl.BRM_Area__c!='null')
                {
                    setTemp.add(dl.BRM_Area__c);
                    mapNewFieldValues.put('BRM_Area__c', setTemp);
                }
            }

            if(mapExistingFieldValues != null && mapExistingFieldValues.get('Division__c') != null && 
                !mapExistingFieldValues.get('Division__c').contains(dl.Division__c))
            {
                Set<String> setTemp = new Set<String>();
                
                if (mapNewFieldValues.get('Division__c') != null && mapNewFieldValues.get('Division__c').size() > 0) 
                {
                    setTemp = mapNewFieldValues.get('Division__c');
                }

                if(dl.Division__c != null&&dl.Division__c!=''&&dl.Division__c!='null')
                {
                    setTemp.add(dl.Division__c);
                    mapNewFieldValues.put('Division__c', setTemp);
                }
            }

            if(mapExistingFieldValues != null && mapExistingFieldValues.get('International_Domestic__c') != null && 
                !mapExistingFieldValues.get('International_Domestic__c').contains(dl.International_Domestic__c))
            {
                Set<String> setTemp = new Set<String>();
                
                if (mapNewFieldValues.get('International_Domestic__c') != null && mapNewFieldValues.get('International_Domestic__c').size() > 0) 
                {
                    setTemp = mapNewFieldValues.get('International_Domestic__c');
                }

                if(dl.International_Domestic__c != null&&dl.International_Domestic__c!=''&&dl.International_Domestic__c!='null')
                {
                    setTemp.add(dl.International_Domestic__c);
                    mapNewFieldValues.put('International_Domestic__c', setTemp);
                }
            }

            if(mapExistingFieldValues != null && mapExistingFieldValues.get('Region__c') != null && 
                !mapExistingFieldValues.get('Region__c').contains(dl.Region__c))
            {
                Set<String> setTemp = new Set<String>();
                
                if (mapNewFieldValues.get('Region__c') != null && mapNewFieldValues.get('Region__c').size() > 0) 
                {
                    setTemp = mapNewFieldValues.get('Region__c');
                }

                if(dl.Region__c != null&&dl.Region__c!=''&&dl.Region__c!='null')
                {
                    setTemp.add(dl.Region__c);
                    mapNewFieldValues.put('Region__c', setTemp);
                }
            }

            if(mapExistingFieldValues != null && mapExistingFieldValues.get('Reporting_Level__c') != null && 
                !mapExistingFieldValues.get('Reporting_Level__c').contains(dl.Reporting_Level__c))
            {
                Set<String> setTemp = new Set<String>();
                
                if (mapNewFieldValues.get('Reporting_Level__c') != null && mapNewFieldValues.get('Reporting_Level__c').size() > 0) 
                {
                    setTemp = mapNewFieldValues.get('Reporting_Level__c');
                }

                if(dl.Reporting_Level__c != null&&dl.Reporting_Level__c!=''&&dl.Reporting_Level__c!='null')
                {
                    setTemp.add(dl.Reporting_Level__c);
                    mapNewFieldValues.put('Reporting_Level__c', setTemp);
                }
            }

            if(mapExistingFieldValues != null && mapExistingFieldValues.get('Super_Area__c') != null && 
                !mapExistingFieldValues.get('Super_Area__c').contains(dl.Super_Area__c))
            {
                Set<String> setTemp = new Set<String>();
                
                if (mapNewFieldValues.get('Super_Area__c') != null && mapNewFieldValues.get('Super_Area__c').size() > 0) 
                {
                    setTemp = mapNewFieldValues.get('Super_Area__c');
                }

                if(dl.Super_Area__c != null&&dl.Super_Area__c!=''&&dl.Super_Area__c!='null')
                {
                    setTemp.add(dl.Super_Area__c);
                    mapNewFieldValues.put('Super_Area__c', setTemp);
                }
            }

            if(mapExistingFieldValues != null && mapExistingFieldValues.get('Super_Region__c') != null && 
                !mapExistingFieldValues.get('Super_Region__c').contains(dl.Super_Region__c))
            {
                Set<String> setTemp = new Set<String>();
                
                if (mapNewFieldValues.get('Super_Region__c') != null && mapNewFieldValues.get('Super_Region__c').size() > 0) 
                {
                    setTemp = mapNewFieldValues.get('Super_Region__c');
                }

                if(dl.Super_Region__c != null&&dl.Super_Region__c!=''&&dl.Super_Region__c!='null')
                {
                    setTemp.add(dl.Super_Region__c);
                    mapNewFieldValues.put('Super_Region__c', setTemp);
                }
            }

            if(mapExistingFieldValues != null && mapExistingFieldValues.get('Super_Reporting_Level__c') != null && 
                !mapExistingFieldValues.get('Super_Reporting_Level__c').contains(dl.Super_Reporting_Level__c))
            {
                Set<String> setTemp = new Set<String>();
                
                if (mapNewFieldValues.get('Super_Reporting_Level__c') != null && mapNewFieldValues.get('Super_Reporting_Level__c').size() > 0) 
                {
                    setTemp = mapNewFieldValues.get('Super_Reporting_Level__c');
                }

                if(dl.Super_Reporting_Level__c != null&&dl.Super_Reporting_Level__c!=''&&dl.Super_Reporting_Level__c!='null')
                {
                    setTemp.add(dl.Super_Reporting_Level__c);
                    mapNewFieldValues.put('Super_Reporting_Level__c', setTemp);
                }
            }
        }        
    }
   
    global void finish(Database.BatchableContext BC)
    {
        

// Send an email to the Email ID in Custom Setting "Email ID for TA Sync Batch Results" notifying of job completion.
        Map<String,CustomSettingDataValueMap__c> mapDataValueMap = CustomSettingDataValueMap__c.getAll();
        List<String> toAddresses = new List<String>();

        if(mapDataValueMap!= null &&
                    mapDataValueMap.get('Email ID for Picklist Batch') != null &&
                    mapDataValueMap.get('Email ID for Picklist Batch').DataValue__c != null &&
                    mapDataValueMap.get('Email ID for Picklist Batch').DataValue__c != '')
        {
            toAddresses = mapDataValueMap.get('Email ID for Picklist Batch').DataValue__c.split(',',0);

            for (String str : toAddresses) 
            {
                str = str.trim();
            }

            AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :BC.getJobId()];

            string message = 'The Picklist Maintenance batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.';

            
            message += '\n\n\n----------------------------------------------------------------------------------------------------\n\n';
            message += 'Picklist Values for Area field:\n\n';
            message += 'New Values Found: \n';
            if(mapNewFieldValues.get('Area__c') != null && mapNewFieldValues.get('Area__c').size() > 0)
            {
            		system.debug('outside for'+mapNewFieldValues.get('Area__c'));
                    for (String str : mapNewFieldValues.get('Area__c')) 
                                            
                        {	
                        	system.debug('inside for'+mapNewFieldValues.get('Area__c'));
                        	
                        	if(str!=null&&str!=''&&str!='null')
                        	{
                        		message += str + '\n';
                        		system.debug('11111111str'+str);
                        	}
                        	system.debug('@@@@@@str'+str);
                        }
            }
            else 
                message += ' -- None -- ';


            

            message += '\n\n\n----------------------------------------------------------------------------------------------------\n\n';
            message += 'Picklist Values for BRM Area field:\n\n';          
            message += 'New Values Found: \n';
            if(mapNewFieldValues.get('BRM_Area__c') != null && mapNewFieldValues.get('BRM_Area__c').size() > 0)
            {
                    for (String str : mapNewFieldValues.get('BRM_Area__c')) 
                    {
                        message += str + '\n';
                        system.debug('!!!!!str'+str);
                    }
            }
            else 
                message += ' -- None -- ';


            

            message += '\n\n\n----------------------------------------------------------------------------------------------------\n\n';
            message += 'Picklist Values for Division field:\n\n';
            message += 'New Values Found: \n';
            if(mapNewFieldValues.get('Division__c') != null && mapNewFieldValues.get('Division__c').size() > 0)
                    for (String str : mapNewFieldValues.get('Division__c')) 
                        message += str + '\n';
            else 
                message += ' -- None -- ';

            

            message += '\n\n\n----------------------------------------------------------------------------------------------------\n\n';
            message += 'Picklist Values for International/Domestic field:\n\n';
            message += 'New Values Found: \n';
            if(mapNewFieldValues.get('International_Domestic__c') != null && mapNewFieldValues.get('International_Domestic__c').size() > 0)
                    for (String str : mapNewFieldValues.get('International_Domestic__c')) 
                        message += str + '\n';
            else 
                message += ' -- None -- ';

            

            message += '\n\n\n----------------------------------------------------------------------------------------------------\n\n';
            message += 'Picklist Values for Region field:\n\n';
            message += 'New Values Found: \n';
            if(mapNewFieldValues.get('Region__c') != null && mapNewFieldValues.get('Region__c').size() > 0)
                    for (String str : mapNewFieldValues.get('Region__c')) 
                        message += str + '\n';
            else 
                message += ' -- None -- ';

            

            message += '\n\n\n----------------------------------------------------------------------------------------------------\n\n';
            message += 'Picklist Values for Reporting Level field:\n\n';
            message += 'New Values Found: \n';
            if(mapNewFieldValues.get('Reporting_Level__c') != null && mapNewFieldValues.get('Reporting_Level__c').size() > 0)
                    for (String str : mapNewFieldValues.get('Reporting_Level__c')) 
                        message += str + '\n';
            else 
                message += ' -- None -- ';

            

            message += '\n\n\n----------------------------------------------------------------------------------------------------\n\n';
            message += 'Picklist Values for Super Area field:\n\n';
            message += 'New Values Found: \n';
            if(mapNewFieldValues.get('Super_Area__c') != null && mapNewFieldValues.get('Super_Area__c').size() > 0)
                    for (String str : mapNewFieldValues.get('Super_Area__c')) 
                        message += str + '\n';
            else 
                message += ' -- None -- ';

            

            message += '\n\n\n----------------------------------------------------------------------------------------------------\n\n';
            message += 'Picklist Values for Super Region field:\n\n';
            message += 'New Values Found: \n';
            if(mapNewFieldValues.get('Super_Region__c') != null && mapNewFieldValues.get('Super_Region__c').size() > 0)
                    for (String str : mapNewFieldValues.get('Super_Region__c')) 
                        message += str + '\n';
            else 
                message += ' -- None -- ';

            

            message += '\n\n\n----------------------------------------------------------------------------------------------------\n\n';
            message += 'Picklist Values for Super Reporting Level field:\n\n';
            message += 'New Values Found: \n';
            if(mapNewFieldValues.get('Super_Reporting_Level__c') != null && mapNewFieldValues.get('Super_Reporting_Level__c').size() > 0)
                    for (String str : mapNewFieldValues.get('Super_Reporting_Level__c')) 
                        message += str + '\n';
            else 
                message += ' -- None -- ';



            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setToAddresses(toAddresses);

            mail.setSubject('Salesforce District lookup Picklist Maintenance Notification ' + a.Status);

            mail.setPlainTextBody(message);
            


            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}