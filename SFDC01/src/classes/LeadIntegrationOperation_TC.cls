/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |                                              Initial Creation.
 |  Aug-2011        Saravanan C         		Test Class cleanup
 |  
 |	Apr-2012		Shipra Misra				Updating test class as per 
 |												Aprimo/Marketing Q & A integration.
 +===========================================================================*/
@isTest
private class LeadIntegrationOperation_TC
{
	public static testMethod void Test_LeadIntegrationOperation()
	{
	
	    LeadHeader leadrec = new LeadHeader();
	    List<LeadHeader> leadlist = new List<LeadHeader>();
	    LeadIntegrationResult resultrec = new LeadIntegrationResult();
	    List<LeadIntegrationResult> results = new List<LeadIntegrationResult>();
	    Set<String> leadIds = new Set<String>();
	    List<Lead> resultLeads = new List<Lead>();
	
	    User user1 = [Select u.id, u.email from User u where IsActive = true limit 1];
	    User user2 = [Select u.id, u.email from User u where IsActive = false limit 1];
	    QueueSobject queue1 = [Select q.QueueId, q.Queue.Name from QueueSobject q where SobjectType = 'Lead' limit 1];
	    
	    Account account1 = testclassUtils.getAccount();
	    account1.Status__c = 'A';
	    insert account1 ;
	    
	    Account account2 = testclassUtils.getAccount();
	    account2.Status__c = 'I';
	    insert account2 ;
	    
	    List<Lead> dupelist = new List<Lead> ();
	    
	    for (Integer x = 0; x < 3; x++) 
	    {
	      Lead l = testclassUtils.getLeadrec();
	      l.Org_System_Reference__c  = '123456'; 
	      dupelist.add(l);  
	    }
	    insert dupelist ;
	    
	    Lead dupelead = testclassUtils.getLeadrec();
	    dupelead.Org_System_Reference__c  = '123456'; 
	    insert dupelead ;
	       
	    // set up test data that will be passed to method
	    for (Integer i=1 ; i<7 ; i++) 
	    {
	        leadrec = new LeadHeader();
	        leadrec.orig_sys_reference = 'orig_sys_testref' + i;
	        leadrec.company_orig = 'company_orig';
	        leadrec.address1_orig = 'address1_orig';
	        leadrec.city_orig = 'city_orig';
	        leadrec.state_orig = 'state_orig';
	        leadrec.postalcode_orig = 'postalcode_orig';
	        leadrec.country_orig = 'country_orig';
	        leadrec.firstname = 'firstname';
	        leadrec.lastname = 'lastname';
	        leadrec.global_url = 'global_url';
	        leadrec.salutation = 'salutation';
	        leadrec.email = 'email@emc.com.sfdc';
	        leadrec.contact_mobile_phone = 'contact_mobile_phone';
	        leadrec.title = 'title';
	        leadrec.description = 'description';
	        leadrec.sales_force = 'sales_force';
	        leadrec.business_unit = 'business_unit';
	        leadrec.segment = 'segment';
	        leadrec.originator_details = 'originator_details';
	        leadrec.original_synergy_status = 'original_synergy_status';
	        leadrec.campaign_event_name = 'campaign_event_name';
	        leadrec.channel = 'channel';
	        leadrec.gmdb_customer_id = 'gmdb_customer_id';
	        leadrec.lead_originator = 'lead_originator';
	        leadrec.lead_rank = 'lead_rank';
	        leadrec.leadsource = 'leadsource';
	        leadrec.partner = 'partner';
	        leadrec.solution_interest = 'solution_interest';
	        leadrec.product_interest = 'product_interest';
	        leadrec.audit_data = 'audit_data';
	        leadrec.matchservice_standardization_status = 'matchservice_standardization_status';
	        leadrec.matchservice_cleanse_status = 'matchservice_cleanse_status';
	        leadrec.matchservice_postal_status = 'matchservice_postal_status';
	
	        if (i == 1) 
	        {
	            leadrec.owner_email = 'xxxxxxxx@emc.com.sfdc';
	            leadrec.party_id = 'xxxxxxxx';
	            leadrec.contact_phone = 'contact_phone';
	            leadrec.address1_cleansed = 'address1_cleansed';
	            leadrec.address2_cleansed = 'address2_cleansed';
	            leadrec.address3_cleansed = 'address3_cleansed';
	            leadrec.address4_cleansed = 'address4_cleansed';
	            leadrec.city_cleansed = 'city_cleansed';
	            leadrec.state_cleansed = 'state_cleansed';
	            leadrec.postalcode_cleansed = 'postalcode_cleansed';
	            leadrec.country_cleansed = 'country_cleansed';
	            leadrec.company_cleansed = 'company_cleansed';
	            leadrec.unicode_flag_companyname = 'N';
	            leadrec.unicode_flag_lastname = 'N';
	            leadrec.unicode_flag_firstname = 'N';
	            leadrec.unicode_flag_address = 'N';
	            leadrec.gmdb_activity_id = 'gmdb_activity_id';
	        } else if (i == 2) 
	        {
	            leadrec.sfdc_routing_queue = 'xxxxxxxx';
	            leadrec.company_phone_cleansed = 'company_phone_cleansed';
	            leadrec.address1_cleansed = 'address1_cleansed';
	            leadrec.address2_cleansed = 'address2_cleansed';
	            leadrec.address3_cleansed = 'address3_cleansed';
	            leadrec.address4_cleansed = 'address4_cleansed';
	            leadrec.city_cleansed = 'city_cleansed';
	            leadrec.state_cleansed = 'state_cleansed';
	            leadrec.postalcode_cleansed = 'postalcode_cleansed';
	            leadrec.country_cleansed = 'country_cleansed';
	            leadrec.company_cleansed = 'company_cleansed';
	            leadrec.unicode_flag_companyname = 'Y';
	            leadrec.unicode_flag_lastname = 'Y';
	            leadrec.unicode_flag_firstname = 'Y';
	            leadrec.unicode_flag_address = 'Y';
	        } else if (i == 3) 
	        {
	            leadrec.owner_email = user1.email;
	            leadrec.party_id = account1.Party_Id__c;
	            leadrec.company_phone_orig = 'company_phone_orig';
	            leadrec.unicode_flag_companyname = 'N';
	            leadrec.unicode_flag_lastname = 'N';
	            leadrec.unicode_flag_firstname = 'N';
	            leadrec.unicode_flag_address = 'N';
	        } else if (i == 4) 
	        {
	            leadrec.sfdc_routing_queue = queue1.Queue.Name;
	            leadrec.party_id = account2.Party_Id__c;
	            leadrec.unicode_flag_companyname = 'Y';
	            leadrec.unicode_flag_lastname = 'Y';
	            leadrec.unicode_flag_firstname = 'Y';
	            leadrec.unicode_flag_address = 'Y';
	        } else if (i == 5) 
	        {
	            leadrec.orig_sys_reference = dupelead.Org_System_Reference__c;
	        } else if (i == 6) 
	        {
	            leadrec.owner_email = user2.email;
	            leadrec.company_orig = null;
	        }
	
	        leadlist.add(leadrec);
	    }
	
	    results = LeadOperation.LeadIntegration(leadlist);
	
	    for (Integer i=0; i < results.size(); i++)
	    {
	        if ( results[i].SFDCLeadId != null && results[i].SFDCLeadId != null ) 
	    	{
	            leadIds.add(results[i].SFDCLeadId);
	        }
	    }
	
	    resultLeads = [Select id, OwnerId, Org_System_Reference__c, Related_Account__c, Phone, 
	                       Lastname, City, Company, Company_Local__c, Country from Lead
	                       where id in :leadIds];
	    for (Integer i=0; i < resultLeads.size(); i++)
	    {
	        if ( resultLeads[i].Org_System_Reference__c == dupelead.Org_System_Reference__c )
	        {
	            if (dupelist.size() > 1) 
	            {
	                Boolean dupematch = false;
	                for (Lead duperec :dupelist) 
	                {
	                    if (resultLeads[i].id == duperec.id) 
	                    {
	                        dupematch = true;
	                    }
	                }
	                System.assertEquals(dupematch, false);
	            } else 
	            {
	                System.assertEquals(resultLeads[i].id, dupelead.id);
	            }
	        } else if ( resultLeads[i].Org_System_Reference__c == 'orig_sys_testref1') 
	        {
	            System.assertEquals(resultLeads[i].phone, 'contact_phone');
	            System.assertEquals(resultLeads[i].Related_Account__c, null);
	            System.assertEquals(resultLeads[i].country, 'country_cleansed');
	            System.assertEquals(resultLeads[i].company, 'company_cleansed');
	        } else if ( resultLeads[i].Org_System_Reference__c == 'orig_sys_testref2') 
	        {
	            System.assertEquals(resultLeads[i].phone, 'company_phone_cleansed');
	            System.assertEquals(resultLeads[i].Related_Account__c, null);
	            System.assertEquals(resultLeads[i].city, 'city_cleansed');
	        } else if ( resultLeads[i].Org_System_Reference__c == 'orig_sys_testref3') 
	        {
	            System.assertEquals(resultLeads[i].phone, 'company_phone_orig');
	            resultLeads[i].Related_Account__c=account1.id;
	            resultLeads[i].company=account1.name;
	            System.assertEquals(resultLeads[i].Related_Account__c, account1.id);
	            System.assertEquals(resultLeads[i].company, account1.name);
	            System.assertEquals(resultLeads[i].lastname, 'lastname');
	        } else if ( resultLeads[i].Org_System_Reference__c == 'orig_sys_testref4') 
	        {
	            System.assertEquals(resultLeads[i].Related_Account__c, null);
	            System.assertEquals(resultLeads[i].company_local__c, 'company_orig');
	            System.assertEquals(resultLeads[i].city, null);
	            System.assertEquals(resultLeads[i].country, 'country_orig');
	        }
	    }
	}
	static testMethod void Test_LeadIntegrationOperationWithAprimo()
	{
		List<LeadHeader> leadlist = new List<LeadHeader>();
	    LeadHeader leadrec = new LeadHeader();
	    Set<String> leadIds = new Set<String>();
	    List<Lead> resultLeads = new List<Lead>();
	    List<Marketing_Q_A__c> resultMarketingQA = new List<Marketing_Q_A__c>();
	    List<LeadIntegrationResult> results = new List<LeadIntegrationResult>();
		Account account1 = testclassUtils.getAccount();
	    account1.Status__c = 'A';
	    insert account1 ;
	    QueueSobject queue1 = [Select q.QueueId, q.Queue.Name from QueueSobject q where SobjectType = 'Lead' limit 1];
	    Account account2 = testclassUtils.getAccount();
	    account2.Status__c = 'I';
	    insert account2 ;
		for (Integer i=1 ; i<6 ; i++) 
	    {
	        leadrec = new LeadHeader();
	        //leadrec.orig_sys_reference = 'orig_sys_testref' + i;
	        leadrec.company_orig = 'company_orig';
	        leadrec.address1_orig = 'address1_orig';
	        leadrec.city_orig = 'city_orig';
	        leadrec.state_orig = 'state_orig';
	        leadrec.postalcode_orig = 'postalcode_orig';
	        leadrec.country_orig = 'country_orig';
	        leadrec.firstname = 'firstname';
	        leadrec.lastname = 'lastname';
	        leadrec.global_url = 'global_url';
	        leadrec.salutation = 'salutation';
	        leadrec.email = 'email@emc.com.sfdc';
	        leadrec.contact_mobile_phone = 'contact_mobile_phone';
	        leadrec.title = 'title';
	        leadrec.description = 'description';
	        leadrec.sales_force = 'sales_force';
	        leadrec.business_unit = 'business_unit';
	        leadrec.segment = 'segment';
	        leadrec.originator_details = 'originator_details';
	        leadrec.original_synergy_status = 'original_synergy_status';
	        leadrec.campaign_event_name = 'campaign_event_name';
	        leadrec.channel = 'channel';
	        leadrec.text_field02 = 'aprimo_lead_id'+string.valueof(i);
	        leadrec.lead_originator = 'lead_originator';
	        leadrec.lead_rank = 'lead_rank';
	        leadrec.leadsource = 'leadsource';
	        leadrec.partner = 'partner';
	        leadrec.solution_interest = 'solution_interest';
	        leadrec.product_interest = 'product_interest';
	        leadrec.audit_data = 'audit_data';
	        leadrec.matchservice_standardization_status = 'matchservice_standardization_status';
	        leadrec.matchservice_cleanse_status = 'matchservice_cleanse_status';
	        leadrec.matchservice_postal_status = 'matchservice_postal_status';
			leadrec.text_field06='Q1 How are you||Q2 WHAT is your organization name||Q3 1 Organisation type ||Q4 Do you have a mobile phone||Q5 No. of employees ||Q6 Max leads that can be updated ||Q7 Ð¥ÑÑÑÐ°Ð½ ÑÐ½ÑÐÐµÑÑÑÑÑÑÐ°||Q8 ||Q9 ||Q10 ';
			leadrec.text_field07='A1 I M good||A2 EMC||A3 EDUCATION ||A4 YES||A5 3000||A6 200||A7 Ð¥ÑÑÑÐ°Ð½ ÑÐ½ÑÐ²ÐµÑÑÑÑÑÑÐ°.||A8 ||A9 I do require some assistance||A10 Data is not corrupt';
		
	        if (i == 1) 
	        {
	            leadrec.owner_email = 'xxxxxxxx@emc.com.sfdc';
	            leadrec.party_id = 'xxxxxxxx';
	            leadrec.contact_phone = 'contact_phone';
	            leadrec.address1_cleansed = 'address1_cleansed';
	            leadrec.address2_cleansed = 'address2_cleansed';
	            leadrec.address3_cleansed = 'address3_cleansed';
	            leadrec.address4_cleansed = 'address4_cleansed';
	            leadrec.city_cleansed = 'city_cleansed';
	            leadrec.state_cleansed = 'state_cleansed';
	            leadrec.postalcode_cleansed = 'postalcode_cleansed';
	            leadrec.country_cleansed = 'country_cleansed';
	            leadrec.company_cleansed = 'company_cleansed';
	            leadrec.unicode_flag_companyname = 'N';
	            leadrec.unicode_flag_lastname = 'N';
	            leadrec.unicode_flag_firstname = 'N';
	            leadrec.unicode_flag_address = 'N';
	            leadrec.text_field01 = 'Aprimo_audmem_id'+string.valueof(i);
	        } else if (i == 2) 
	        {
	            leadrec.sfdc_routing_queue = 'xxxxxxxx';
	            leadrec.company_phone_cleansed = 'company_phone_cleansed';
	            leadrec.address1_cleansed = 'address1_cleansed';
	            leadrec.address2_cleansed = 'address2_cleansed';
	            leadrec.address3_cleansed = 'address3_cleansed';
	            leadrec.address4_cleansed = 'address4_cleansed';
	            leadrec.city_cleansed = 'city_cleansed';
	            leadrec.state_cleansed = 'state_cleansed';
	            leadrec.postalcode_cleansed = 'postalcode_cleansed';
	            leadrec.country_cleansed = 'country_cleansed';
	            leadrec.company_cleansed = 'company_cleansed';
	            leadrec.unicode_flag_companyname = 'Y';
	            leadrec.unicode_flag_lastname = 'Y';
	            leadrec.unicode_flag_firstname = 'Y';
	            leadrec.unicode_flag_address = 'Y';
	        } else if (i == 3) 
	        {
	            leadrec.owner_email = 's.m@emc.com';
	            leadrec.party_id = account1.Party_Id__c;
	            leadrec.company_phone_orig = 'company_phone_orig';
	            leadrec.unicode_flag_companyname = 'N';
	            leadrec.unicode_flag_lastname = 'N';
	            leadrec.unicode_flag_firstname = 'N';
	            leadrec.unicode_flag_address = 'N';
	        } else if (i == 4) 
	        {
	            leadrec.sfdc_routing_queue = queue1.Queue.Name;
	            leadrec.party_id = account2.Party_Id__c;
	            leadrec.unicode_flag_companyname = 'Y';
	            leadrec.unicode_flag_lastname = 'Y';
	            leadrec.unicode_flag_firstname = 'Y';
	            leadrec.unicode_flag_address = 'Y';
	        }  else if (i == 5) 
	        {
	            leadrec.owner_email ='xxx.xxx@emc.com.sfdc';
	            leadrec.company_orig = null;
	        }
	
	        leadlist.add(leadrec);
	    }
		results = LeadOperation.LeadIntegration(leadlist);
	
		for (Integer i=0; i < results.size(); i++)
	    {
	        if ( results[i].SFDCLeadId != null && results[i].SFDCLeadId != null ) 
	    	{
	            leadIds.add(results[i].SFDCLeadId);
	        }
	    }
	
	    resultLeads = [Select id, OwnerId, Aprimo_Lead_Id__c, Related_Account__c, Phone, 
	                       Lastname, City, Company, Company_Local__c, Country from Lead
	                       where id in :leadIds];
	    resultMarketingQA= [Select Question__c,Answer__c,Aprimo_Lead_Id__c,Lead_look_up__c 
	    					from Marketing_Q_A__c where id in: leadIds];
	    					
	    for (Integer i=0; i < resultLeads.size(); i++)
	    {                   
           	if ( resultLeads[i].Aprimo_Lead_Id__c == 'aprimo_lead_id1') 
	        {
	            System.assertEquals(resultLeads[i].phone, 'contact_phone');
	            System.assertEquals(resultLeads[i].Related_Account__c, null);
	            System.assertEquals(resultLeads[i].country, 'country_cleansed');
	            System.assertEquals(resultLeads[i].company, 'company_cleansed');
	        } 
	    }
	    for(Integer j=0;j<1;j++)
	    {
	    	if ( resultMarketingQA[j].Aprimo_Lead_Id__c == 'aprimo_lead_id1') 
	        {
	            System.assertEquals(resultMarketingQA[j].Question__c, 'How are you');
	            System.assertEquals(resultMarketingQA[j].Answer__c, 'I M good');
	        } 
	    }
	}
}