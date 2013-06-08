/*==============================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 | 5 May 2013   Prachi Bhasin           246408      Creation
 +==============================================================================================================*/
@IsTest (SeeAllData=true)
private class LeadReportingFieldChange_TC {
        static testmethod void test() {       
                List <String> profileNames = new List <String> {'AMER Inside Sales/SMB User','APJ Core TC'};
                List <Profile> p =[Select id from Profile where Profile.Name IN :profileNames ];
                User usr = new User();
                usr.Username = 'username@xyz.com';
                usr.Email = 'emai@xyz.com';
                usr.CommunityNickname = 'communityNickname';
                usr.Emailencodingkey='UTF-8';
                usr.Languagelocalekey='en_US';
                usr.Localesidkey='en_US';
                usr.Timezonesidkey='America/Los_Angeles';
                usr.LastName='lastname1';
                usr.Alias='alias1';
                usr.ProfileId =p[0].id;
                insert usr;
                 
                User usr1 = new User();
                usr1.Username = 'username1@xyz.com';
                usr1.Email = 'emai1@xyz.com';
                usr1.CommunityNickname = 'communityNickname1';
                usr1.Emailencodingkey='UTF-8';
                usr1.Languagelocalekey='en_US';
                usr1.Localesidkey='en_US';
                usr1.Timezonesidkey='America/Los_Angeles';
                usr1.LastName='lastname11';
                usr1.Alias='alias11';
                usr1.ProfileId =p[1].id; 
                insert usr1;
               
                System.RunAs(usr){
                Test.startTest();
                Lead objLead = new Lead();
                objLead.Company = 'Company 1';
                objLead.LastName= 'Name 1';
                objLead.Sales_Force__c = 'EMC';
                objLead.Lead_Rank__c = 'NPQ';
                objLead.Lead_Originator__c = 'Program';
                objLead.OwnerId = usr.Id;
                objLead.Originator_Details__c='details1';
                insert objLead;
                
                Map<Id,Lead> leadNewRecordsMap = new Map<Id,Lead>();
                Map<Id,Lead> leadOldRecordsMap = new Map<Id,Lead>(); 
                List<Id> newOwnerId = new List<Id>();
                List<Id> oldOwnerId = new List<Id>();
                
                leadOldRecordsMap.put(objLead.id,objLead);
                oldOwnerId.add(usr.Id);
                                
                objLead.OwnerId = usr1.Id;
                update objLead;
                newOwnerId.add(usr1.Id);
                leadNewRecordsMap.put(objLead.id,objLead); 
                Test.stopTest();              
                           }      
        
        }             
}