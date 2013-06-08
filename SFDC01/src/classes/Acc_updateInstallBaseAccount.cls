/*==========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  06.12.2010      Shipra Misra    151285      Initial Creation.  Updating Install Base Account Field on Lead.  
 |  21.11.2011      Suman B		    IM7312572   Updating the Lead when Related Account Address and Name are changed.
 |  02.12.2011	 	Suman B			IM7312572   Modified Update statement to Database.Saveresult[] to log ther error records.  	
 |  22.12.2011		Suman B			WR-181921 	Modified the method signature of updateInstallBaseAccount(set<id> setAccIds) 
 |												and not calling in future call - asynchUpdateInstallBaseAccount().
 |												updateInstallBaseAccount() method is now directly called from 
 |												UpdateLeadAfterAccountUpdate.Trigger not through the future call, to bypass the 
 |												future call parameter limitations.
 | 28.12.2011		Suman B			WR-181921 	Modified the query in updateInstallBaseAccount() method to fetch only DR's with
 |												 with Status - 'Approved' or 'Submitted'.	
 +==========================================================================================================================*/




public class Acc_updateInstallBaseAccount {
    
//Furute methid for updateInstallBaseAccount
    @future
    public static void asynchUpdateInstallBaseAccount(Set<Id> setAccId)
    {
        //updateInstallBaseAccount(setAccId);
    }


/* Method to select Lead's Related to Account and update them with Install Base Account field in sync with Account and
    to updated DR's -DealReg_Channel_Account_Manager__c field with Account associated to the Account's Partner Contacts 
	who owns the DR's if the Account Owner is changed. **/
    public static void updateInstallBaseAccount(Map<String,Set<Id>> map_fieldsetAccId)
    {
    	system.debug('Entered in to updateInstallBaseAccount method');
    	//WR-181921
    	set<Id> relatedAccountIds = new set<Id>();
    	set<Id> accountIds = new set<Id>(); 
    	List<Lead> listUpdateLeads = new List<Lead>();
		set<Id> DROwnerIds = new set<Id>(); 
		Map<Id,User> mapUser ;
		
    	if(map_fieldsetAccId.containskey('Owner_change')){
		   accountIds = map_fieldsetAccId.get('Owner_change'); 	    	
           mapUser = new Map<Id,User>([Select u.ContactId, u.Contact.AccountId, u.Email, u.Id, u.Contact.Account.Owner.Email 
                                        from User u 
                                        where AccountId  IN:accountIds  and Contact.AccountId!=null ]);
           if(mapUser != Null && mapUser.size() >0){
              DROwnerIds = mapUser.keyset() ;
              
              system.debug('DROwner Ids====='+DROwnerIds);
           }
        }

    	if(map_fieldsetAccId.containskey('Address_InstallBase')){
		   relatedAccountIds = map_fieldsetAccId.get('Address_InstallBase'); 	    	
        }

        //Query Lead for Related Account & Install Base Account field.
        //Holds List of Lead which have accounts in setAccId.
        List<Lead> lstLeadInstallBAcc = new List<Lead>([SELECT id,Install_Base_Account__c,Related_Account__c,Related_Account__r.Install_Base_Account__c,
        											           DealReg_Deal_Registration__c,Street,City,State,PostalCode, Country, CompanyLocal, company,
        											           State_Province_Local__c,City_Local__c,Street_Local__c, Country_Local__c,
        											           Zip_Postal_Code_Local__c,DealReg_Account_Category__c ,DealReg_Channel_Account_Manager__c,ownerId,
															   Related_Account__r.Street_Local__c, Related_Account__r.Zip_Postal_Code_Local__c, 
															   Related_Account__r.State_Province_Local__c,Related_Account__r.Country_Local__c, 
															   Related_Account__r.City_Local__c, Related_Account__r.NameLocal, Related_Account__r.BillingCountry, 
															   Related_Account__r.BillingPostalCode,Related_Account__r.BillingState,Related_Account__r.BillingCity,
															   Related_Account__r.BillingStreet,Related_Account__r.Name ,Related_Account__r.EMC_Classification__c    
         												  FROM Lead 
                                                          WHERE Related_Account__c in:relatedAccountIds OR 
                                                           ( (DealReg_Deal_Registration__c = true AND DealReg_Deal_Registration_Status__c IN ('Approved','Submitted'))
                                                             AND OwnerId IN :DROwnerIds )  
                                                          limit : Limits.getLimitQueryRows()]);
        //Check for size of list.
        if(lstLeadInstallBAcc.size()>0)
        {
            //Looping on All the records found to update the install base field.
            for(Integer i=0; i<lstLeadInstallBAcc.size(); i++)
            {
            	system.debug('Entered in to for 1 loop====');
            	Boolean updateRequired = false;
                //Check if Install Base Account (Lead) is not equal Install Base Account(Account).
                if(lstLeadInstallBAcc[i].Install_Base_Account__c!=lstLeadInstallBAcc[i].Related_Account__r.Install_Base_Account__c  
                	&& lstLeadInstallBAcc[i].DealReg_Deal_Registration__c == false)
                {
                	system.debug('Entered in to for 2 loop====');
                    //Assigning the Value of Install Base Account from Related Account to Install Base on Lead.
                    lstLeadInstallBAcc[i].Install_Base_Account__c=lstLeadInstallBAcc[i].Related_Account__r.Install_Base_Account__c;
                    updateRequired  = true;
                    system.debug('InstallBaseAccount --Lead #### '+ lstLeadInstallBAcc[i]);
                }
		        
		        // Added condtion  to check for Address field change -- IM7312572                
                // Updating the local Address fields.
                if(lstLeadInstallBAcc[i].State_Province_Local__c != lstLeadInstallBAcc[i].Related_Account__r.State_Province_Local__c ||
                   lstLeadInstallBAcc[i].CompanyLocal != lstLeadInstallBAcc[i].Related_Account__r.NameLocal ||
				   lstLeadInstallBAcc[i].City_Local__c != lstLeadInstallBAcc[i].Related_Account__r.City_Local__c ||
				   lstLeadInstallBAcc[i].Street_Local__c != lstLeadInstallBAcc[i].Related_Account__r.Street_Local__c ||
				   lstLeadInstallBAcc[i].Country_Local__c != lstLeadInstallBAcc[i].Related_Account__r.Country_Local__c ||
				   lstLeadInstallBAcc[i].Zip_Postal_Code_Local__c != lstLeadInstallBAcc[i].Related_Account__r.Zip_Postal_Code_Local__c ||
				   lstLeadInstallBAcc[i].DealReg_Account_Category__c != lstLeadInstallBAcc[i].Related_Account__r.EMC_Classification__c ||
				   lstLeadInstallBAcc[i].Street != lstLeadInstallBAcc[i].Related_Account__r.BillingStreet ||
				   lstLeadInstallBAcc[i].City != lstLeadInstallBAcc[i].Related_Account__r.BillingCity ||
				   lstLeadInstallBAcc[i].State != lstLeadInstallBAcc[i].Related_Account__r.BillingState ||
				   lstLeadInstallBAcc[i].PostalCode != lstLeadInstallBAcc[i].Related_Account__r.BillingPostalCode ||
				   lstLeadInstallBAcc[i].Country != lstLeadInstallBAcc[i].Related_Account__r.BillingCountry ||
				   //lstLeadInstallBAcc[i].DealReg_Channel_Account_Manager__c !=mapUser.get(lstLeadInstallBAcc[i].OwnerId).Contact.Account.Owner.Email ||
				   //lstLeadInstallBAcc[i].DealReg_Channel_Manager__c != lstLeadInstallBAcc[i].Related_Account__r.OwnerId ||
				   //lstLeadInstallBAcc[i].DealReg_Channel_Manager__c !=  mapUser.get(lstLeadInstallBAcc[i].Related_Account__r.OwnerId).email ||				   
				   lstLeadInstallBAcc[i].company != lstLeadInstallBAcc[i].Related_Account__r.Name ) {
					// updating Address fields.
					updateRequired = true ;
					system.debug('Leadid #### '+ lstLeadInstallBAcc[i].id);					
					lstLeadInstallBAcc[i].State_Province_Local__c = lstLeadInstallBAcc[i].Related_Account__r.State_Province_Local__c ;
                	lstLeadInstallBAcc[i].CompanyLocal = lstLeadInstallBAcc[i].Related_Account__r.NameLocal;
					lstLeadInstallBAcc[i].City_Local__c = lstLeadInstallBAcc[i].Related_Account__r.City_Local__c;
                    lstLeadInstallBAcc[i].Street_Local__c = lstLeadInstallBAcc[i].Related_Account__r.Street_Local__c;
					lstLeadInstallBAcc[i].Country_Local__c = lstLeadInstallBAcc[i].Related_Account__r.Country_Local__c;
                	lstLeadInstallBAcc[i].Zip_Postal_Code_Local__c = lstLeadInstallBAcc[i].Related_Account__r.Zip_Postal_Code_Local__c;
                	lstLeadInstallBAcc[i].DealReg_Account_Category__c = lstLeadInstallBAcc[i].Related_Account__r.EMC_Classification__c;
                	lstLeadInstallBAcc[i].Street = lstLeadInstallBAcc[i].Related_Account__r.BillingStreet ;
                	lstLeadInstallBAcc[i].City = lstLeadInstallBAcc[i].Related_Account__r.BillingCity ;
                	//lstLeadInstallBAcc[i].City = 'test';
                	lstLeadInstallBAcc[i].State = lstLeadInstallBAcc[i].Related_Account__r.BillingState ;
                	lstLeadInstallBAcc[i].PostalCode = lstLeadInstallBAcc[i].Related_Account__r.BillingPostalCode ;
	                lstLeadInstallBAcc[i].Country = lstLeadInstallBAcc[i].Related_Account__r.BillingCountry ;
	               //lstLeadInstallBAcc[i].Country = 'testcontry';
	                //lstLeadInstallBAcc[i].DealReg_Channel_Manager__c =  mapUser.get(lstLeadInstallBAcc[i].Related_Account__r.OwnerId).email;
	                //lstLeadInstallBAcc[i].DealReg_Channel_Manager__c = 'test@emc.com';
                	lstLeadInstallBAcc[i].company = lstLeadInstallBAcc[i].Related_Account__r.Name ;
                }

                // Added for DR's DealReg_Channel_Account_Manager__c field update. 
                system.debug('lstLeadInstallBAcc[i].OwnerId===='+lstLeadInstallBAcc[i].OwnerId+'==='+lstLeadInstallBAcc[i].DealReg_Deal_Registration__c+'==='+mapUser);
                if(lstLeadInstallBAcc[i].DealReg_Deal_Registration__c && mapUser!= Null && 
                   mapUser.ContainsKey(lstLeadInstallBAcc[i].OwnerId) ){
                   	system.debug('Account_Manager -Email ## '+ mapUser.get(lstLeadInstallBAcc[i].OwnerId).Contact.Account.Owner.Email);
                    lstLeadInstallBAcc[i].DealReg_Channel_Account_Manager__c =mapUser.get(lstLeadInstallBAcc[i].OwnerId).Contact.Account.Owner.Email ; 	
                    system.debug(' lstLeadInstallBAcc[i].DealReg_Channel_Account_Manager__c===='+ lstLeadInstallBAcc[i].DealReg_Channel_Account_Manager__c);
                	updateRequired = true ;
                }      
                // lstLeadInstallBAcc[i].DealReg_Channel_Manager__c = 'test@emc.com';         
                if(updateRequired){
                  listUpdateLeads.add(lstLeadInstallBAcc[i]) ;  
                  //update listUpdateLeads;
                 // lstLeadInstallBAcc[i].DealReg_Channel_Manager__c = 'test@emc.com'; 
                }  
            } // End of for loop.
            
            // DML execution.
            if(listUpdateLeads.size()>0){
            	Database.Saveresult[] resultLeadRecords = database.update(listUpdateLeads, false) ;
            	//upsert listUpdateLeads;
            	 //lstLeadInstallBAcc[1].DealReg_Channel_Manager__c = 'test@emc.com';            	 
				List <EMCException> errors = new List <EMCException>();
        		for (integer i = 0; i < resultLeadRecords.size(); i++) {
 		            Database.Saveresult sr = resultLeadRecords[i];
		            String dataErrs = '';
		            if (!sr.isSuccess()) {
		               // if the particular record did not get updated, we log the data error 
		                for (Database.Error err : sr.getErrors()) {
		                    dataErrs += err.getMessage();
		                }
		                System.debug('An exception occurred while attempting an update on ' + sr.getId());
		                System.debug('ERROR: ' + dataErrs);
		                errors.add(new EMCException(dataErrs, 'ERROR_UPDATION_LEAD__AFTER_ACCOUNT_UPDATE', new String [] {resultLeadRecords[i].id}));
		            }
		        }  
			      // log any errors that occurred
			       if (errors.size() > 0) { 
			            EMC_UTILITY.logErrors(errors);  
			       }
             				            	
            }//update listUpdateLeads;
        }
        system.debug('End the class method');
    } // End of updateInstallBaseAccount()method.

//method to update lead.
   public static void updateInstallBaseAccountFromLeadCallFuture(Set<Id> setLeadId)
    {
        updateInstallBaseAccountFromLead(setLeadId);
    }
    public static void updateInstallBaseAccountFromLead(Set<Id> setLeadId)
    {
        //Query Lead for Related Account & Install Base Account field.
        //Holds List of Lead which have Leads in setLeadId.
        List<Lead> lstLeadInstBAccnt = new List<Lead>([Select id,Install_Base_Account__c,Related_Account__c,Related_Account__r.Install_Base_Account__c from Lead 
                                                        where id in:setLeadId and DealReg_Deal_Registration__c=false limit 10000 ]);
        //Check for size of list.
        if(lstLeadInstBAccnt.size()>0)
        {
            //Looping on All the records found to update the install base field.
            for(Integer j=0;j<lstLeadInstBAccnt.size();j++)
            {
                //Check if Install Base Account (Lead) is not equal Install Base Account(Account).
                if(lstLeadInstBAccnt[j].Install_Base_Account__c!=lstLeadInstBAccnt[j].Related_Account__r.Install_Base_Account__c)
                {
                    //Assigning the Value of Install Base Account from Related Account to Install Base on Lead.
                    lstLeadInstBAccnt[j].Install_Base_Account__c=lstLeadInstBAccnt[j].Related_Account__r.Install_Base_Account__c;
                }
            }
            // DML execution.
            update lstLeadInstBAccnt;
         }
    }
}