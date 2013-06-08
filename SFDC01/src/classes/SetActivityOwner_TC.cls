/*   Date               Initial Creation              Updated By        Req no           Reason
     3 March 2010       Prasad Kothawade            Prasad Kothawade    125264      Updated test method to change synergy lead id.    
     31 May 2012        Modified                    Avinash Kaltari     195446      Updated to add code for increasing coverage of 
                                                                                    PopulateRelatedToFieldOnEvent trigger
*/                                                                                  
@isTest
private Class SetActivityOwner_TC{

    public static testmethod void deploySetActivityOwner(){
            Lead mylead= new Lead();
            Account acc =[select id, name,Party_ID__c from Account where party_id__c <> null limit 1 ];
            User myUser =[Select Id from User where isactive=true limit 1];
            mylead.Related_Account__c=acc.id;
            mylead.Synergy_Lead_ID__c='12345678022222';
            mylead.Party_ID__c=acc.Party_ID__c;
            mylead.Integration_Error_Message__c='';
            mylead.Status = 'Qualified' ;
            mylead.Company = 'DeployTest' ;
            mylead.Channel__c = 'DIRECT' ;
            mylead.City = 'DIRECT' ;
            mylead.Street = 'DIRECT' ;
            mylead.Country = 'DIRECT';
            mylead.Sales_Force__c = 'EMC';
            mylead.LastName = 'EMC';
            mylead.Previous_Owner__c =myUser.Id;
            insert mylead;
           
            Util.isFeatureCalledonAcitivity=false;
    
            Event myEvent= new Event();
            myEvent.whoid=mylead.Id;
            myEvent.EndDateTime=System.now().addDays(2);
            myEvent.StartDateTime=System.now().addHours(2);
            myEvent.Type='Appointment Set (SA)';
            myEvent.Subject='Call';
            insert myEvent;
    
            List <String> leads=new List <String>() ;
            leads.add(mylead.id);
            SetActivityOwner.updateOwner(leads);
            
//Avinash's code begins...

         /*   myEvent.WhoId = null;
            update myEvent;
            
            Contact con = testclassUtils.getContact();
            insert con;
            myEvent.WhatId = null;
            myEvent.WhoId = con.id;
            
            update myEvent;
*/
//Avinash's code ends.
            
        }  
    }