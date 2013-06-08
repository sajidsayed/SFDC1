/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER          WR       DESCRIPTION                               
 |  ====       =========          ==       =========== 
 | 14-12-2012   Smitha Thomas   213868    Created.To stamp TA Attributes on Account.
 | 18-03-2013   Avinash Kaltari 239205    Added a new global boolean variable so that the Account Before Update trigger can check for its 
                       value.
 | 10-05-2013   Avinash Kaltari 248321    Added code for Enhancement releted to the CQR field update on Account and re-structured most 
                                          part of the code 
 +===========================================================================*/
 global class AP_AssignCQRtoAccount implements Database.Batchable<sObject> 
 {
    
    private final static String EXC_PROCID = 'AP_AssignCQRtoAccount';    
    global String Query;    
    public Job_Scheduler__c js;
    global static boolean blnBatchInvocation = false;

    
    global AP_AssignCQRtoAccount(Job_Scheduler__c js,String query)
    {
        this.js = js;
        this.Query = query ;
        system.debug('QUERY ### :' + query );
        System.debug('js is---->'+js);
    }
        
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(Query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<SObject> scope)
    {
        List<CQR_Delta_Log__c> lstCQRlog = (CQR_Delta_Log__c[]) scope;
        Set<Id> setAccIds = new Set<Id>();
        
        for(CQR_Delta_Log__c CQRlog : lstCQRlog)
        {
            setAccIds.add(CQRlog.Account__c);
        } 
        updateAccforCQR(setAccIds);
    }
    
    global void updateAccforCQR(Set<Id> setAccIds)
    {
        List<Core_Quota_Rep__c> lstCQR = new List<Core_Quota_Rep__c>();
        List<Account> lstAcc = new List<Account>();
        List<Account> lstAcctoUpdate = new List<Account>();
        Map<String, District_Lookup__c> mapDistrictIdDLookup = new Map<String,District_Lookup__c>();
        List<District_Lookup__c> lstDLookup = new List<District_Lookup__c>();
        Set<string> setOracleDistrictIds = new Set<String>(); 
        
        Id idHouseAccUser;
        idHouseAccUser = null;

        Map<String,CustomSettingDataValueMap__c> mapData = CustomSettingDataValueMap__c.getAll();
         if(mapData != null && mapData.get('House Account') != null && 
              mapData.get('House Account').Datavalue__c != null)
            idHouseAccUser = mapData.get('House Account').Datavalue__c;

        lstCQR = [select id,name, Account_ID__c,Badge_ID__c,Batch_ID__c,District_Name__c,External_ID__c,Oracle_District_ID__c,Role_Name__c,SFDC_User_ID__c from Core_Quota_Rep__c where Account_ID__c in:setAccIds order by Badge_ID__c ASC];
        

        // The following variable mapAccIdCQRList added by Avinash for WR# 248321
        Map<Id,List<Core_Quota_Rep__c>> mapAccIdCQRList = new Map<Id,List<Core_Quota_Rep__c>>();

        //Contructing a MAP of Account ID and List of related CQR records
        for (Core_Quota_Rep__c cqr : lstCQR) 
        {            
            if(mapAccIdCQRList.containsKey(cqr.Account_ID__c))
                mapAccIdCQRList.get(cqr.Account_ID__c).add(cqr);
            else
            {
                List<Core_Quota_Rep__c> temp = new List<Core_Quota_Rep__c>();
                temp.add(cqr);
                mapAccIdCQRList.put(cqr.Account_ID__c, temp);
            }
            setOracleDistrictIds.add(CQR.Oracle_District_ID__c);
        }

        lstAcc = [select id,name,Core_Quota_House_Name__c,District_Lookup__c,Core_Quota_Rep__c,Core_Quota_Rep_Updated__c from Account where id in:setAccIds];
        
        lstDLookup = [select id,Oracle_District_ID__c, name from District_Lookup__c where Oracle_District_ID__c IN :setOracleDistrictIds limit 50000];
        
        for (District_Lookup__c dl : lstDLookup) 
            mapDistrictIdDLookup.put(dl.Oracle_District_ID__c, dl);
               
        //Looping over all the accounts for which the Core Quota Rep field needs to be updated
        for(Account acc: lstAcc)
        {

            //If the Account has no related CQR, null out the Acct Presentation fields
            if((mapAccIdCQRList == null || mapAccIdCQRList.size() == 0) || (mapAccIdCQRList != null && !mapAccIdCQRList.containsKey(acc.id)))
            {
                Account acctoupdate = new Account (id = acc.id);
                acctoupdate.Core_Quota_Rep__c = null;
                acctoupdate.District_Lookup__c = null;
                acctoupdate.Core_Quota_House_Name__c = null;
                lstAcctoUpdate.add(acctoupdate);
            }

            /* If the Account has exactly one related CQR, set the AP fields to appropriate values i.e. with respect to 
             an House Account Rep or an non-House Account Rep */
            else if (mapAccIdCQRList != null && (mapAccIdCQRList.get(acc.id).size() == 1 || acc.Core_Quota_Rep__c == null)) 
            {
                
                Account acctoupdate = new Account (id = acc.id);

                //Set Core Quota Rep field's value to the House Account user's id in case a House Account Rep
                if(mapAccIdCQRList.get(acc.id).get(0).Badge_ID__c.startsWith('D'))
                {
                    acctoupdate.Core_Quota_Rep__c = idHouseAccUser;
                    acctoupdate.Core_Quota_House_Name__c = mapAccIdCQRList.get(acc.id).get(0).Name;
                }

                //Set Core Quota Rep field's value to the value of SFDC_USER_ID field on Rep else set it to null in case of non-House Account user
                else
                {
                    if(mapAccIdCQRList.get(acc.id).get(0).SFDC_User_ID__c != '' && mapAccIdCQRList.get(acc.id).get(0).SFDC_User_ID__c != null)
                      acctoupdate.Core_Quota_Rep__c = mapAccIdCQRList.get(acc.id).get(0).SFDC_User_ID__c;
                    else
                      acctoupdate.Core_Quota_Rep__c = null;

                    acctoupdate.Core_Quota_House_Name__c = null;
                }

                //Set the District Lookup values looking up to the releted District Lookup records on the CQR record                
                if(mapAccIdCQRList.get(acc.id).get(0).Oracle_District_ID__c != null)
                {
                    String strNewDistrictId;
                    strNewDistrictId = mapAccIdCQRList.get(acc.id).get(0).Oracle_District_ID__c;
                    if(mapDistrictIdDLookup.get(strNewDistrictId).id != null)
                    {
                        acctoupdate.District_Lookup__c = mapDistrictIdDLookup.get(strNewDistrictId).id;
                    }
                }
                lstAcctoUpdate.add(acctoupdate);
            }

            /* If the Account has more than one related CQR's, set the Core Quota Rep field to an appropriate value only if the current value refers to a House Account OR if the referred CQR record is deleted in Oracle */ 
            else if (mapAccIdCQRList != null && mapAccIdCQRList.get(acc.id).size() > 1 && acc.Core_Quota_Rep__c != null) 
            {

                //If Core Quota Rep field refers to a House Account and a new non-House Account Rep is added
                if(acc.Core_Quota_Rep__c == idHouseAccUser && !mapAccIdCQRList.get(acc.id).get(0).Badge_ID__c.startsWith('D'))
                {
                    Account acctoupdate = new Account (id = acc.id);
                    if(mapAccIdCQRList.get(acc.id).get(0).SFDC_User_ID__c != '' && mapAccIdCQRList.get(acc.id).get(0).SFDC_User_ID__c != null)
                      acctoupdate.Core_Quota_Rep__c = mapAccIdCQRList.get(acc.id).get(0).SFDC_User_ID__c;
                    else
                      acctoupdate.Core_Quota_Rep__c = null;

                    acctoupdate.Core_Quota_House_Name__c = null;
                    if(mapAccIdCQRList.get(acc.id).get(0).Oracle_District_ID__c != null)
                    {
                        String strDistrictId;
                        strDistrictId = mapAccIdCQRList.get(acc.id).get(0).Oracle_District_ID__c;
                        if(mapDistrictIdDLookup != null && mapDistrictIdDLookup.get(strDistrictId) != null &&
                              mapDistrictIdDLookup.get(strDistrictId).id != null)
                        {
                          acctoupdate.District_Lookup__c = mapDistrictIdDLookup.get(strDistrictId).id;
                        }
                    }
                    lstAcctoUpdate.add(acctoupdate);
                }

                else if(acc.Core_Quota_Rep__c == idHouseAccUser && mapAccIdCQRList.get(acc.id).get(0).Badge_ID__c.startsWith('D'))
                {
                    Boolean blnCQRExists = false;

                    for (Core_Quota_Rep__c cqr : mapAccIdCQRList.get(acc.id)) 
                    {
                        String strId = mapDistrictIdDLookup.get(cqr.Oracle_District_ID__c).Id;
                        if(cqr.Name == acc.Core_Quota_House_Name__c && acc.District_Lookup__c == strId)
                        {
                          blnCQRExists = true;
                          break;
                        }
                    }

                    if(blnCQRExists == false)
                    {
                        Account acctoupdate = new Account (id = acc.id);
                    
                        acctoupdate.Core_Quota_House_Name__c = mapAccIdCQRList.get(acc.id).get(0).Name;
                        if(mapAccIdCQRList.get(acc.id).get(0).Oracle_District_ID__c != null)
                        {
                            String strDistrictId;
                            strDistrictId = mapAccIdCQRList.get(acc.id).get(0).Oracle_District_ID__c;
                            if(mapDistrictIdDLookup != null && mapDistrictIdDLookup.get(strDistrictId) != null &&
                                  mapDistrictIdDLookup.get(strDistrictId).id != null)
                            {
                              acctoupdate.District_Lookup__c = mapDistrictIdDLookup.get(strDistrictId).id;
                            }
                        }
                        lstAcctoUpdate.add(acctoupdate);
                    }
                }
                
                //If the Core Quota Rep field refers to a non House Account Rep
                else if(acc.Core_Quota_Rep__c != idHouseAccUser)
                {
                    Boolean blnCQRExists = false;
                    for (Core_Quota_Rep__c cqr : mapAccIdCQRList.get(acc.id)) 
                    {
                        String strId = mapDistrictIdDLookup.get(cqr.Oracle_District_ID__c).Id;
                        if(cqr.SFDC_User_ID__c == acc.Core_Quota_Rep__c && acc.District_Lookup__c == strId)
                        {
                          blnCQRExists = true;
                          break;
                        }
                    }

                    /* If the CQR being referred to is deleted from Oracle, set it to appropriate values with respect to the newly 
                    added CQR i.e. depending on whether it is a House Account Rep or a non-House Account Rep */
                    if(blnCQRExists == false)
                    {
                        Account acctoupdate = new Account (id = acc.id);
                        if(mapAccIdCQRList.get(acc.id).get(0).Badge_ID__c.startsWith('D'))
                        {
                            acctoupdate.Core_Quota_Rep__c = idHouseAccUser;
                            acctoupdate.Core_Quota_House_Name__c = mapAccIdCQRList.get(acc.id).get(0).Name;
                        }
                        else
                        {
                            if(mapAccIdCQRList.get(acc.id).get(0).SFDC_User_ID__c != '' && mapAccIdCQRList.get(acc.id).get(0).SFDC_User_ID__c != null)
                              acctoupdate.Core_Quota_Rep__c = mapAccIdCQRList.get(acc.id).get(0).SFDC_User_ID__c;
                            else
                              acctoupdate.Core_Quota_Rep__c = null;
                            acctoupdate.Core_Quota_House_Name__c = null;
                        }

                        if(mapAccIdCQRList.get(acc.id).get(0).Oracle_District_ID__c != null)
                        {
                            String strNewDistrictId;
                            strNewDistrictId = mapAccIdCQRList.get(acc.id).get(0).Oracle_District_ID__c;
                            if(mapDistrictIdDLookup.get(strNewDistrictId).id != null)
                            {
                                acctoupdate.District_Lookup__c = mapDistrictIdDLookup.get(strNewDistrictId).id;
                            }
                        }
                        lstAcctoUpdate.add(acctoupdate);
                    }
                }
            }
        }    
        
system.debug('Accounts to be updated'+lstAcctoUpdate+'Size of list'+lstAcctoUpdate.size());
        
        if(lstAcctoUpdate!=null && lstAcctoUpdate.size()>0)
        {
            blnBatchInvocation = true;

            Database.Saveresult[] resultUpdAcc = database.update(lstAcctoUpdate, false) ;
                          
            List <EMCException> errors = new List <EMCException>();
            for (integer i = 0; i < resultUpdAcc.size(); i++) 
            {
                Database.Saveresult sr = resultUpdAcc[i];
                String dataErrs = '';
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) 
                    {
                        dataErrs += err.getMessage();
                    }
                    System.debug('An exception occurred while attempting an update on ' + sr.getId());
                    System.debug('ERROR: ' + dataErrs);
                    errors.add(new EMCException(dataErrs, EXC_PROCID + ':UpdateAccountWithCQR', new String [] {lstAcctoUpdate[i].Id}));
                }
            }  
            // log any errors that occurred
            if (errors.size() > 0) 
            { 
                EMC_UTILITY.logErrors(errors);  
            }
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        if(js!=null)
        {
            js.Status__c='Complete';
            try
            {
              System.debug('js--d-->'+js);
              Database.SaveResult SR = Database.Update(js);
              System.debug('SR------>'+ SR);
            }
            catch(Exception e){
              System.debug('Exception ---->'+ e);
            }
        }
        System.debug('------------------Run BatchDeleteData--------------------');
        
        //To Schedule batchDeleteDate on same day
        DateTime n = datetime.now().addMinutes(2);
        String cron = '';
        cron += n.second();
        cron += ' ' + n.minute();
        cron += ' ' + n.hour();
        cron += ' ' + n.day();
        cron += ' ' + n.month();
        cron += ' ' + '?';
        cron += ' ' + n.year();

        String jobName = 'Batch Job To Delete CQRdeltaLog - ' + n.format('MM-dd-yyyy-hh:');
        
        // To schedule batchDeleteDate
        system.debug('####cron####'+cron);
        AP_BatchDeleteDataScheduler batchSch = new AP_BatchDeleteDataScheduler();
        String jobId = System.schedule(jobName,cron,batchSch);
    }
}