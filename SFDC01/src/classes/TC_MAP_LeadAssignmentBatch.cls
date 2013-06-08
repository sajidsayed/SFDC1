@istest   

Private class TC_MAP_LeadAssignmentBatch{
    static testmethod void test() {
        
    Test.startTest();
   
   //Leads test data for the test class  ##########
       
    LeadHeader leadrec = new LeadHeader();
    List<LeadHeader> leadlist = new List<LeadHeader>();
    LeadIntegrationResult resultrec = new LeadIntegrationResult();
    List<LeadIntegrationResult> results = new List<LeadIntegrationResult>();
   // Set<String> leadIds = new Set<String>();
   // List<Lead> resultLeads = new List<Lead>();

    QueueSobject queue1 = [Select q.QueueId, q.Queue.Name from QueueSobject q where SobjectType = 'Lead' limit 1];

    Account account1 = [Select Id, Name, Party_Id__c from Account where Account_Status__c = 'Active'
                               and isDeleted != true limit 1];


    //Accounts Created
    List <Account> accounts = new List <Account>();
    accounts.add (new Account(name = 'TestAccount1', 
                                     Site_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8)),
                                     Parent_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8)),
                                     Global_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8)),
                                     party_id__c = '110001', billingstreet='141 SMITH HALL 207 PLEASANT ST SE' , 
                                     billingcity='MINNEAPOLIS', 
                                     billingstate ='MN',
                                     billingpostalcode='55455',
                                     billingcountry='United States',
                                     emc_classification__c ='',
                                     Status__c = 'A'
                                     ));
    accounts.add (new Account(name = 'TestAccount2', 
                                     Site_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8)),
                                     Parent_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8)),
                                     Global_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8)),
                                     party_id__c = '110002', billingstreet='141 SMITH HALL 207 PLEASANT ST SE' , 
                                     billingcity='MINNEAPOLIS', 
                                     billingstate ='MN',
                                     billingpostalcode='55455',
                                     billingcountry='United States',
                                     emc_classification__c ='COMMERCIAL',
                                     Status__c = 'A'
                                     ));
    accounts.add (new Account(name = 'TestAccount3', 
                                     Site_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8)),
                                     Parent_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8)),
                                     Global_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8)),
                                     party_id__c = '110003', billingstreet='141 SMITH HALL 207 PLEASANT ST SE' , 
                                     billingcity='MINNEAPOLIS', 
                                     billingstate ='MN',
                                     billingpostalcode='55455',
                                     billingcountry='United States',
                                     Status__c = 'A'
                                     ));
    insert accounts;

    //Query to get some users
    List<User> users = [SELECT ID FROM user where isActive = true and BU_for_Lead_Routing__c in ('IIG')LIMIT 6];
    //List<User> users1 = [SELECT ID FROM user where isActive = true and BU_for_Lead_Routing__c in ('BRS')LIMIT 1];
    //Create Account Team Records
    List <AccountTeamMember> members = new List<AccountTeamMember>();
    for (Integer x=0; x<3;x++) {
        
        if(x==0){
            
            members.add (new AccountTeamMember(accountId=accounts[x].Id,
                                                userId=users[0].Id,
                                                teammemberrole='Sales-Sales Rep'));
            members.add (new AccountTeamMember(accountId=accounts[x].Id,
                                                userId=users[1].Id,
                                                teammemberrole='Sales-Sales Rep'));
            members.add (new AccountTeamMember(accountId=accounts[x].Id,
                                                userId=users[2].Id,
                                                teammemberrole='Sales-Sales Rep')); 
         }                                       
        if(x==1){
            members.add (new AccountTeamMember(accountId=accounts[x].Id,
                                                userId=users[1].Id,
                                                teammemberrole='Sales-Sales Rep'));
           members.add (new AccountTeamMember(accountId=accounts[x].Id,
                                                userId=users[2].Id,
                                                teammemberrole='Sales-Sales Rep'));                                    
         members.add (new AccountTeamMember(accountId=accounts[x].Id,
                                                userId=users[5].Id,
                                                teammemberrole='Sales-Sales Rep'));
         }
          if(x==2){
            members.add (new AccountTeamMember(accountId=accounts[x].Id,
                                                userId=users[1].Id,
                                                teammemberrole='Sales-Sales Rep'));
           members.add (new AccountTeamMember(accountId=accounts[x].Id,
                                                userId=users[2].Id,
                                                teammemberrole='Sales-Sales Rep')); 
           members.add (new AccountTeamMember(accountId=accounts[x].Id,
                                                userId=users[3].Id,
                                                teammemberrole='Sales-Sales Rep'));                                                                        
         }
       
    }
    insert members;      

//Lead Routing Priority

    List<Lead_routing_rule_priority__c> leadRoutingPriorityList = new List<Lead_routing_rule_priority__c>();
    Lead_routing_rule_priority__c leadRoutingPriorityRecord;
    For(integer i=0;i<4;i++){
        leadRoutingPriorityRecord = new Lead_routing_rule_priority__c();
        
        if(i==0){
            //Queue Rule
            leadRoutingPriorityRecord.name ='QR-BU-COUNTRY-CLASSIFICATION';
            leadRoutingPriorityRecord.rule_type__c = 'Queue Rule';
            leadRoutingPriorityRecord.rule_fields__c ='BU__c;Country__c;emc_classification__c';
            leadRoutingPriorityRecord.Rule_Priority_Number__c =1;
        }
        if(i==1){
            //Account rule
            leadRoutingPriorityRecord.name ='ATR-BU-COUNTRY';
            leadRoutingPriorityRecord.rule_type__c = 'Account Team Rule';
            leadRoutingPriorityRecord.rule_fields__c ='BU__c;country__c';
            leadRoutingPriorityRecord.Rule_Priority_Number__c =1;
         }
        if(i==2){
            //Account rule
            leadRoutingPriorityRecord.name ='ATR-BU-COUNTRY-Classification';
            leadRoutingPriorityRecord.rule_type__c = 'Account Team Rule';
            leadRoutingPriorityRecord.rule_fields__c ='BU__c;emc_classification__c;country__c';
            leadRoutingPriorityRecord.Rule_Priority_Number__c =1;
         } 
        if(i==3){
            //Account rule
            leadRoutingPriorityRecord.name ='ATR-BU-COUNTRY-Originator';
            leadRoutingPriorityRecord.rule_type__c = 'Account Team Rule';
            leadRoutingPriorityRecord.rule_fields__c ='BU__c;country__c;originator_detail__c';
            leadRoutingPriorityRecord.Rule_Priority_Number__c =1;
         }
          
    leadRoutingPriorityList.add(leadRoutingPriorityRecord);    
    } 
    insert leadRoutingPriorityList;





// Lead Routing Rule
    List<Lead_routing_rule__c> leadRoutingList = new List<Lead_routing_rule__c>();
    Lead_routing_rule__c leadRoutingRecord;
    For(integer i=0;i<4;i++){
        leadRoutingRecord = new Lead_routing_rule__c();
        leadRoutingRecord.name ='Test'+i;
        
        if(i==0){
        //Queue Rule
        leadRoutingRecord.BU__c = 'CORE';
        //leadRoutingRecord.queue_name__c ='CORE Poland Queue';
        leadRoutingRecord.queue_name__c =queue1.queue.name;
        //leadRoutingRecord.recordtypeid ='012S00000000O6Z';
         leadRoutingRecord.recordtypeid =MAP_LeadAssignmentUtils.getProfileOptionValue('Queue_Rule_Record_Type');
        leadRoutingRecord.emc_classification__c = 'COMMERCIAL';
        leadRoutingRecord.country__c = 'United states';
        }
        if(i==1){
        //Account rule
        //leadRoutingRecord.emc_classification__c = 'COMMERCIAL';
        leadRoutingRecord.BU__c = 'IIG';
        leadRoutingRecord.primary_role__c ='Sales-Sales Rep';
        //leadRoutingRecord.recordtypeid ='012S00000000O6s';
        leadRoutingRecord.recordtypeid =MAP_LeadAssignmentUtils.getProfileOptionValue('Account_Rule_Record_Type');
        leadRoutingRecord.country__c = 'United states';
        }
        if(i==2){
        //Account rule
        leadRoutingRecord.emc_classification__c = 'COMMERCIAL';
        leadRoutingRecord.BU__c = 'IIG';
        leadRoutingRecord.primary_role__c ='PRODUCT-SALES REP';
        leadRoutingRecord.secondary_role__c ='CHANNEL-EXECUTION SALES REP';
        leadRoutingRecord.tertiary_role__c ='Sales-Sales Rep';
        //leadRoutingRecord.recordtypeid ='012S00000000O6s';
        leadRoutingRecord.recordtypeid =MAP_LeadAssignmentUtils.getProfileOptionValue('Account_Rule_Record_Type');
        leadRoutingRecord.country__c = 'United states';
        }
        if(i==3){
        //Account rule
        //leadRoutingRecord.emc_classification__c = 'COMMERCIAL';
        leadRoutingRecord.BU__c = 'IIG';
        leadRoutingRecord.primary_role__c ='CHANNEL-EXECUTION SALES REP';
        //leadRoutingRecord.recordtypeid ='012S00000000O6s';
        leadRoutingRecord.recordtypeid =MAP_LeadAssignmentUtils.getProfileOptionValue('Account_Rule_Record_Type');
        leadRoutingRecord.country__c = 'United states';
        leadRoutingRecord.originator_detail__c  ='Maintenance Tech Refresh Alert';
        }
       
    leadRoutingList.add(leadRoutingRecord);    
    } 
    insert leadRoutingList;
   
        
    // set up test Lead data that will be passed to batch method
    String batchname = 'batch_test_' + System.now();
    for (Integer i=1 ; i<7; i++) {
        leadrec = new LeadHeader();
        leadrec.company_orig = 'Accenture'+i;
        leadrec.firstname = 'test'+i;
        leadrec.lastname = 'test'+i;
        leadrec.sfdc_routing_queue='Lead Routing Batch Queue';
        leadrec.campaign_event_name = batchname;
        if (i==1 )
        {
            //Global Exception Queue
            leadrec.business_unit = 'BRS';
            leadrec.originator_details  ='Maintenance Tech Refresh Alert';
            leadrec.country_orig = 'United States';
        } 
        if(i==2)
        {
            // Queue Rule
            leadrec.business_unit = 'CORE';
            leadrec.country_orig = 'United States';
            leadrec.segment='COMMERCIAL';
        } 
        if(i==3)     
        {
             //Account Rule but no account team member
             leadrec.Party_ID =account1.party_id__C;
             leadrec.business_unit = 'BRS';
             leadrec.originator_details  ='Maintenance Tech Refresh Alert';
        }
        if(i==4)     
        {
              //Account Rule(BU,Country), lead assigned to account team member 
             leadrec.Party_ID =accounts[0].party_id__c;
             leadrec.business_unit = 'IIG';
        }
        if(i==5)     
        {
              //Account Rule(BU,Country,classification), lead assigned to account team member (tertiary role)
             leadrec.Party_ID =accounts[1].party_id__c;
             leadrec.business_unit = 'IIG';
        }
        if(i==6)     
        {
             //Account Rule(BU,Country,classification,originator), lead assigned to account team member (primary)
             leadrec.Party_ID =accounts[2].party_id__c;
             leadrec.business_unit = 'IIG';
             leadrec.originator_details  ='Maintenance Tech Refresh Alert';
        }
          
         leadlist.add(leadrec);
    }

    results =LeadOperation.LeadIntegration(leadlist);
  
   //Executing Batch Class
   
    MAP_LeadAssignmentBatch LeadAssignment = new MAP_LeadAssignmentBatch ();
    LeadAssignment.batchQuery = 'SELECT Name, Related_Account__c, ownerid, Routing_Exception_Code__c, '; 

    List<string> leadAttributes = MAP_LeadAssignmentUtils.getLeadAttributes();
    Iterator<string> iter = leadAttributes.iterator();
    String attrName = null;

    do{
        attrName = iter.next();            
        LeadAssignment.batchQuery += attrName;            
        if(iter.hasNext()){                
            LeadAssignment.batchQuery += ',';            
        }
    }
    while(iter.hasNext());
    
    LeadAssignment.batchQuery += ' FROM Lead WHERE ownerid = \'' + MAP_LeadAssignmentUtils.getProfileOptionValue('Routing_Batch_Queue_Id') + '\'';        
    LeadAssignment.batchQuery += ' AND Campaign_Event_Name__c = \'' + batchname + '\'';
    System.debug('##############'+LeadAssignment.batchQuery);

    LeadAssignment.ruleFieldToLeadFieldMap = MAP_LeadAssignmentUtils.getRuleFieldToLeadFieldMappings();
    LeadAssignment.ruleFieldToOperatorMap = MAP_LeadAssignmentUtils.getRuleFieldToOperatorMappings();
    ID batchprocessid = Database.executeBatch(LeadAssignment);
                
     
    Test.stopTest();

    }
}