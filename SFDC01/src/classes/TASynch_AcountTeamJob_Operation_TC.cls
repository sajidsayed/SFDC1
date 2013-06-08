/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  01.03.2011      Anand Sharma                This is Test class for  TASynch_AcountTeamJob and TA_Sync_IntegrationOperation 
 +=========================================================================================================================*/

@istest
private class TASynch_AcountTeamJob_Operation_TC {
    
    static testMethod void getERRORControlFlagWithBatchId_Test() {
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        
            List<CustomSettingDataValueMap__c> lstDataValue = new List<CustomSettingDataValueMap__c>();
            CustomSettingDataValueMap__c dataValueControlFlag = new CustomSettingDataValueMap__c();
            dataValueControlFlag.Name ='TASync_Int_Control_Flag_Sequence';
            dataValueControlFlag.DataValue__c ='1';
            lstDataValue.add(dataValueControlFlag);
            
            CustomSettingDataValueMap__c dataValueControlFlag1 = new CustomSettingDataValueMap__c();
            dataValueControlFlag1.Name ='TASync_Int_Control_Flag';
            dataValueControlFlag1.DataValue__c ='ERROR';
            lstDataValue.add(dataValueControlFlag1);
            
            CustomSettingDataValueMap__c DeleteAccountTeamMemberTimeInterval = new CustomSettingDataValueMap__c();
            dataValueControlFlag1.Name ='DeleteAccountTeamMemberTimeInterval';
            dataValueControlFlag1.DataValue__c ='1';
            lstDataValue.add(DeleteAccountTeamMemberTimeInterval); 
    
            try
            {
               Database.insert(lstDataValue, false);
            }catch(Exception e){
               System.debug('Check Obj Access'+e); 
            }
        
            Integer IntbnatchId= TA_Sync_IntegrationOperation.getBatchId();
            
            TA_Sync_IntegrationOperation.setControlFlagWithBatchId('ERROR', IntbnatchId);
        }
    }
  
    static testMethod void getCOMPLETEControlFlagWithBatchId_Test() {
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        
            List<CustomSettingDataValueMap__c> lstDataValue = new List<CustomSettingDataValueMap__c>();
            CustomSettingDataValueMap__c dataValueControlFlag = new CustomSettingDataValueMap__c();
            dataValueControlFlag.Name ='TASync_Int_Control_Flag_Sequence';
            dataValueControlFlag.DataValue__c ='1';
            lstDataValue.add(dataValueControlFlag);
            
            CustomSettingDataValueMap__c dataValueControlFlag1 = new CustomSettingDataValueMap__c();
            dataValueControlFlag1.Name ='TASync_Int_Control_Flag';
            dataValueControlFlag1.DataValue__c ='COMPLETE';
            lstDataValue.add(dataValueControlFlag1); 
            
            CustomSettingDataValueMap__c DeleteAccountTeamMemberTimeInterval = new CustomSettingDataValueMap__c();
            dataValueControlFlag1.Name ='DeleteAccountTeamMemberTimeInterval';
            dataValueControlFlag1.DataValue__c ='1';
            lstDataValue.add(DeleteAccountTeamMemberTimeInterval);
    
            try
            {
               Database.insert(lstDataValue, false);
            }catch(Exception e){
               System.debug('Check Obj Access'+e); 
            }
        
            Integer IntbnatchId= TA_Sync_IntegrationOperation.getBatchId();
            
            TA_Sync_IntegrationOperation.setControlFlagWithBatchId('COMPLETE', IntbnatchId);
        }
    }
    
    static testMethod void getSTARTControlFlagWithBatchId_Test() {
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        
            List<CustomSettingDataValueMap__c> lstDataValue = new List<CustomSettingDataValueMap__c>();
            CustomSettingDataValueMap__c dataValueControlFlag = new CustomSettingDataValueMap__c();
            dataValueControlFlag.Name ='TASync_Int_Control_Flag_Sequence';
            dataValueControlFlag.DataValue__c ='1';
            lstDataValue.add(dataValueControlFlag);
            
            CustomSettingDataValueMap__c dataValueControlFlag1 = new CustomSettingDataValueMap__c();
            dataValueControlFlag1.Name ='TASync_Int_Control_Flag';
            dataValueControlFlag1.DataValue__c ='START';
            lstDataValue.add(dataValueControlFlag1);
            
            CustomSettingDataValueMap__c DeleteAccountTeamMemberTimeInterval = new CustomSettingDataValueMap__c();
            dataValueControlFlag1.Name ='DeleteAccountTeamMemberTimeInterval';
            dataValueControlFlag1.DataValue__c ='1';
            lstDataValue.add(DeleteAccountTeamMemberTimeInterval); 
        
            try
            {
               Database.insert(lstDataValue, false);
            }catch(Exception e){
               System.debug('Check Obj Access'+e); 
            }
        
            Integer IntbnatchId= TA_Sync_IntegrationOperation.getBatchId();
            
            TA_Sync_IntegrationOperation.setControlFlagWithBatchId('START', IntbnatchId);
        }
    }
    
    static testMethod void TASynchAccountTeamMember_Test() {
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
            
            List<CustomSettingDataValueMap__c> lstDataValue = new List<CustomSettingDataValueMap__c>();
            CustomSettingDataValueMap__c dataValueControlFlag = new CustomSettingDataValueMap__c();
            dataValueControlFlag.Name ='TASync_Int_Control_Flag_Sequence';
            dataValueControlFlag.DataValue__c ='1';
            lstDataValue.add(dataValueControlFlag);
            
            CustomSettingDataValueMap__c dataValueControlFlag1 = new CustomSettingDataValueMap__c();
            dataValueControlFlag1.Name ='TASync_Int_Control_Flag';
            dataValueControlFlag1.DataValue__c ='START';
            lstDataValue.add(dataValueControlFlag1); 
            
            CustomSettingDataValueMap__c DeleteAccountTeamMemberTimeInterval = new CustomSettingDataValueMap__c();
            dataValueControlFlag1.Name ='DeleteAccountTeamMemberTimeInterval';
            dataValueControlFlag1.DataValue__c ='1';
            lstDataValue.add(DeleteAccountTeamMemberTimeInterval);
        
            try
            {
               Database.insert(lstDataValue, false);
            }catch(Exception e){
               System.debug('Check Obj Access'+e); 
            }
        
            Account_Groupings__c grouping = new Account_Groupings__c (Name = 'UNITTESTGrp');
            insert grouping;
                      
            
            // Creation of Account record.  
            Account objAccount =  new Account (Name = 'UNITTESTAcc', Country_Local__c = 'Japan',cluster__C = 'APJ', Grouping__c = grouping.Id, Batch_Job_Operation__c = 'Clustor/Theather Updated', profiled_Account_flag__c=true);
            insert objAccount;
            
            List<Staging_Data__c> stagingDataList = new List<Staging_Data__c>();
            Staging_Data__c objStagedata = new Staging_Data__c();
            objStagedata.Text1__c = objAccount.Id;
            objStagedata.Text2__c ='Sales-Sales Rep';
            objStagedata.Text3__c = insertUser.Id;
            objStagedata.Text4__c ='Edit';
            objStagedata.Text5__c ='Edit';
            objStagedata.Object_Name__c ='TASync';
            objStagedata.Batch_Id__c = Integer.valueOf(lstDataValue.get(0).DataValue__c);
            stagingDataList.add(objStagedata);          
            insert stagingDataList;
            
            TASynch_AccountTeamJob objATM = new TASynch_AccountTeamJob();
            
            
            
            Test.StartTest();    
            
            String accountShareQuery =  'Select Text5__c, Text4__c, Text3__c, Text2__c, Text1__c, Object_Name__c, Batch_Id__c From Staging_Data__c '
                                  + 'WHERE Batch_Id__c = '+ objStagedata.Batch_Id__c + ' AND Object_Name__c = \'TASync\' limit 10' ;             
            Id batchProcessId = Database.executeBatch(new TASynch_AccountTeamJob(accountShareQuery)); 
            
            // My code
            
             Datetime dt = Datetime.now().addMinutes(1);
             String sch = '0 '+dt.minute()+' * '+dt.day()+' '+dt.month()+' '+' ? '+dt.year();
             System.Schedule('schedule',sch,objATM);
             
            // My code
            Test.StopTest();
        }
    }
}