/*


Modified by		:	Avinash K
Modified Date	:	30 May 2012
Purpose			:	To increase coverage for "CreateAccountTeam" & "populateJobNo" triggers

*/

@isTest
Private Class CreateAccountTeam_TC{
    Private static testMethod void startTest(){
        Lead mylead= new Lead();
        Account acc =[select id, name,Party_ID__c from Account where party_id__c <> null limit 1 ];
        mylead.Related_Account__c=acc.id;
        //mylead.Synergy_Lead_ID__c='12345678';
        mylead.Synergy_Lead_ID__c='12345678000000';
        mylead.Party_ID__c=acc.Party_ID__c;
        mylead.Integration_Error_Message__c='';
        mylead.Status = 'Qualified' ;
        mylead.Company = 'DeployTest' ;
        mylead.Channel__c = 'DIRECT' ;
        mylead.City = 'DIRECT' ;
        mylead.Street = 'DIRECT' ;
        mylead.Country = 'DIRECT' ;
        mylead.Sales_Force__c = 'EMC' ;
        mylead.LastName = 'EMC' ;
        insert mylead;

        Lead[] leads = new Lead[]{[select ownerid,Status,id,Related_Account__c,Synergy_Lead_ID__c,Integration_Error_Message__c from lead where id=:mylead.id]};
                
        CreateAccountTeam cat =new CreateAccountTeam();
        cat.createAccountTeam(leads);

        update leads[0];
        
//Avinash's code begins for CreateAccountTeam trigger

		List<User> lstUser = [select name from user where name = 'System Integration' limit 1];
		if(lstUser != null && lstUser.size() > 0)
		{
			User u = lstUser.get(0);
			
			System.runAs(u)
			{
				update leads[0];
			}			
		}

//Avinash's code ends.

//Avinash's code begins for populateJobNo trigger
		Mass_Opp_Reassignment_log__c m = new Mass_Opp_Reassignment_log__c ();
		try
		{
			insert m;
		}
		catch(Exception e)
		{
			
		}
//Avinash's code ends.
		
    }
}