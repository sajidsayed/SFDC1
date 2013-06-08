/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  16/12/2010    Anand Sharma                      Unit Test for PRM_BatchCreateEducationFromStaging class 
 |  28/03/2011	  Anand Sharma						Created custom setting value through test class 
 |  06/12/2011	  Anand Sharma						Update test class according to new theater 
 +=======================================================================================================*/
@isTest
private class PRM_BatchCreateEducationFromStaging_TC {

    static testMethod void PRM_BatchCreateEducationFromStaging_Test() {
    	
    	// Creation of Account Grouping record.
	    Account_Groupings__c grouping = new Account_Groupings__c (Name = 'UNITTESTGrp');
	    Insert grouping;
	      
	    // Creation of Account record.  
	    Account objAccount =  new Account (Name = 'UNITTESTAcc', Country_Local__c = 'Japan',cluster__C = 'APJ', Grouping__c = grouping.Id, Batch_Job_Operation__c = 'Clustor/Theather Updated', profiled_Account_flag__c=true);
	    Insert objAccount;
        // TO DO: implement unit test
        //Account objAccount = [Select Id, Name, Grouping__c From Account where Grouping__c != null limit 1];
        
        //Create Contact Records
        List<Contact> contactList = new List<Contact>();
        Contact objContact = new Contact();
        objContact.LastName ='TestEducationContact1';
        objContact.Email ='anand.sharma5@emc.com';
        objContact.AccountId = objAccount.Id;
        objContact.Active__c = true;
        objContact.Cert_Tracker_Contact_ID__c ='A100003';
        contactList.add(objContact);
        
        Contact objContact1 = new Contact();
        objContact1.LastName ='TestEducationContact1';
        objContact1.Email ='anand.sharma8@emc.com';
        objContact1.AccountId = objAccount.Id;
        objContact1.Active__c = true;
        objContact1.Cert_Tracker_Contact_ID__c ='A100004';
        contactList.add(objContact1);
        insert contactList;
        
        //Create Education Master Records
        Education_Master__c objEduMaster = new Education_Master__c();
        objEduMaster.ESBI_ID__c ='123456';
        insert objEduMaster;
        
        //Create Staging Data Records
        List<Staging_Data__c> stagingDataList = new List<Staging_Data__c>();
        Staging_Data__c objStagedata = new Staging_Data__c();
        objStagedata.Text1__c = 'A100003';
        objStagedata.Text2__c ='A1111111';
        objStagedata.Text3__c ='anand.sharma5@emc.com';
        objStagedata.Text4__c ='a0F70000004CljX';
        objStagedata.Text5__c ='123456';
        objStagedata.Date1__c = System.today();
        objStagedata.Date2__c = System.today();
        stagingDataList.add(objStagedata);
        
        Staging_Data__c objStagedata1 = new Staging_Data__c();
        objStagedata1.Text1__c = 'A100004';
        objStagedata1.Text2__c ='A1111112';
        objStagedata1.Text3__c ='anand.sharma8@emc.com';
        objStagedata1.Text4__c =objAccount.Grouping__c;
        objStagedata1.Text5__c ='123456';
        objStagedata1.Date1__c = System.today();
        objStagedata1.Date2__c = System.today();
        stagingDataList.add(objStagedata1);
        insert stagingDataList;
        
        List<CustomSettingDataValueMap__c> lstDataValue = new List<CustomSettingDataValueMap__c>();
    	CustomSettingDataValueMap__c dataValueControlFlag = new CustomSettingDataValueMap__c();
    	dataValueControlFlag.Name ='ESBI_Int_Control_Flag_Sequence';
    	dataValueControlFlag.DataValue__c ='2';
    	lstDataValue.add(dataValueControlFlag);
    	try
        {
           Database.insert(lstDataValue, false);
        }catch(Exception e){
           System.debug('Check Obj Access'+e); 
        } 
        
        Test.StartTest();           
        // run batch 
      	String stagingQuery = 'Select Id, Text1__c, Text2__c, Text3__c , Text4__c, Text5__c, Text6__c, Text7__c,'
                            + ' Text8__c, text9__c, Text10__c,Text12__c, Text11__c, Date1__c , Date2__c, Batch_Id__c from Staging_Data__c ' 
                            +  'where is_Header__c != true AND Object_Name__c =\'Education\' Limit 10';        
 
        Id batchProcessId = Database.executeBatch(new PRM_BatchCreateEducationFromStaging(stagingQuery));   
        Test.StopTest();
    }
    
    static testMethod void PRM_BatchCreateEducationFromStagingSchedular_Test() {
    	
    	// Creation of Account Grouping record.
	    Account_Groupings__c grouping = new Account_Groupings__c (Name = 'UNITTESTGrp');
	    Insert grouping;
	      
	    // Creation of Account record.  
	    Account objAccount =  new Account (Name = 'UNITTESTAcc', Country_Local__c = 'Japan',cluster__C = 'APJ', Grouping__c = grouping.Id, Batch_Job_Operation__c = 'Clustor/Theather Updated', profiled_Account_flag__c=true);
	    Insert objAccount;
	    
        // TO DO: implement unit test
        //Account objAccount = [Select Id, Name, Grouping__c From Account where Grouping__c != null limit 1];
        
        //Create Contact Records
        List<Contact> contactList = new List<Contact>();
        Contact objContact = new Contact();
        objContact.LastName ='TestEducationContact1';
        objContact.Email ='anand.sharma5@emc.com';
        objContact.AccountId = objAccount.Id;
        objContact.Active__c = true;
        objContact.Cert_Tracker_Contact_ID__c ='A100003';
        contactList.add(objContact);
        
        Contact objContact1 = new Contact();
        objContact1.LastName ='TestEducationContact1';
        objContact1.Email ='anand.sharma8@emc.com';
        objContact1.AccountId = objAccount.Id;
        objContact1.Active__c = true;
        objContact1.Cert_Tracker_Contact_ID__c ='A100004';
        contactList.add(objContact1);
        insert contactList;
        
        //Create Education Master Records
        Education_Master__c objEduMaster = new Education_Master__c();
        objEduMaster.ESBI_ID__c ='123456';
        insert objEduMaster;
        
        //Create Staging Data Records
        List<Staging_Data__c> stagingDataList = new List<Staging_Data__c>();
        Staging_Data__c objStagedata = new Staging_Data__c();
        objStagedata.Text1__c = 'A100003';
        objStagedata.Text2__c ='A1111111';
        objStagedata.Text3__c ='anand.sharma5@emc.com';
        objStagedata.Text4__c ='a0F70000004CljX';
        objStagedata.Text5__c ='123456';
        objStagedata.Date1__c = System.today();
        objStagedata.Date2__c = System.today();
        stagingDataList.add(objStagedata);
        
        Staging_Data__c objStagedata1 = new Staging_Data__c();
        objStagedata1.Text1__c = 'A100004';
        objStagedata1.Text2__c ='A1111112';
        objStagedata1.Text3__c ='anand.sharma8@emc.com';
        objStagedata1.Text4__c =objAccount.Grouping__c;
        objStagedata1.Text5__c ='123456';
        objStagedata1.Date1__c = System.today();
        objStagedata1.Date2__c = System.today();
        stagingDataList.add(objStagedata1);
        insert stagingDataList;
        
        List<CustomSettingDataValueMap__c> lstDataValue = new List<CustomSettingDataValueMap__c>();
    	CustomSettingDataValueMap__c dataValueControlFlag = new CustomSettingDataValueMap__c();
    	dataValueControlFlag.Name ='ESBI_Int_Control_Flag_Sequence';
    	dataValueControlFlag.DataValue__c ='2';
    	lstDataValue.add(dataValueControlFlag);
    	try
        {
           Database.insert(lstDataValue, false);
        }catch(Exception e){ 
           System.debug('Check Obj Access'+e); 
        } 
        
        Test.StartTest();           
        // run batch 
        String strScheduleTime ='0 0 0 3 9 ? ';
        strScheduleTime = strScheduleTime + Datetime.now().addYears(1).year();
       	String stagingQuery = 'Select Id, Text1__c, Text2__c, Text3__c , Text4__c, Text5__c, Text6__c, Text7__c,'
                            + ' Text8__c, text9__c, Text10__c,Text12__c, Text11__c, Date1__c , Date2__c, Batch_Id__c from Staging_Data__c ' 
                            +  'where is_Header__c != true AND Object_Name__c =\'Education\' Limit 10';        
        //String jobId = System.schedule('testBasicScheduledApex',strScheduleTime, new PRM_BatchCreateEducationFromStaging(stagingQuery));
        
        List<SequencialBatchJob>LstSeqJobs = new List<SequencialBatchJob>(); 
        PRM_BatchCreateEducationFromStaging  job1= new PRM_BatchCreateEducationFromStaging(stagingQuery);        
        PRM_BatchCreateEducationFromStaging  job2= new PRM_BatchCreateEducationFromStaging();
        LstSeqJobs.add(new SequencialBatchJob('PRM_BatchCreateEducationFromStaging' ,job1,20)); 
        LstSeqJobs.add(new SequencialBatchJob('PRM_BatchCreateEducationFromStaging' ,job2,20));        
        SequencialBatchJobScheduler.executeSequence(LstSeqJobs);
            
        Test.StopTest();
    }
}