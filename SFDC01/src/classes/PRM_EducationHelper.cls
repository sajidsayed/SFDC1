/*================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 | 15/12/2010	  Anand Sharma						Populate education record from Staging Object 
 | 07/01/2011	  Anand Sharma						Change request:Match Education master on 
 													education with ESBI NAME in place of ESBI ID 
 | 18/03/2011	  Anand Sharma						Added Training Education Type and Education_Batch_Number__c functionality
 | 28/03/2011     Anand Sharma						Added Staging Id field into education record for error log
 | 17/04/2011	  Anirudh Singh                     Updated code to automate contact Creation for Authorised
 |                                              	Reseller Accounts.
 | 22/09/2011     Suman B							Updated the createEducationAndpopulateContact()method in setting up the 
                                                     Partner_Grouping__c to null for invalid groupingIds. 		
 | 07/10/2011	  Anand Sharma						Handled ignore case when we try to match on email, used toLowerCase for Email
   05/08/2011    Prasad								 VPP improvement
   15/11/2012     vivek kodi             197607     To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs.                                                    							
 +==========================================================================================================*/

 
public class PRM_EducationHelper {
	/* Mapping of Staging Data field and Education Field
		1) Cert_Tracker_Contact_ID__c			Text1__c
		2) Transaction_ID__c					Text2__c (FOR Training)
		3) Email__c								Text3__c
		4) Partner_Grouping_ID__c				Text4__c	
		5) Education_Id__c						Text5__c
		6) Expiration_Date__c					Date1__c
		7) Date_Achieved__c						Date2__c
		8) First_Name__c						Text6__c
		9) Last_Name__c							Text7__c 
		10)	ESBI_Name__c						Text8__c	 
		11)	Country__c							Text9__c
		12)	SABA_Contact_ID__c					Text10__c
		13)	Education_Type__c 					Text12__c
		
	*/  
	
	PUBLIC static boolean bypassTriggers= false;
	public static Map<String,CustomSettingDataValueMap__c> DataValueMap =  CustomSettingDataValueMap__c.getAll();
	
	/* @Method <This method is used to populate contact on Education record>.
	   @param <This is taking list of Staging records >
	   @return <void> - <List of education record>
	   @throws exception - <No Exception>
	*/
	
	/*public static void createEducationwithCertTrackerID(List<Staging_Data__c> lstStaging){
		
		List<Staging_Data__c> lstStagingMappedwithContact= new List<Staging_Data__c>();
		List<Staging_Data__c> lstStagingNOTMappedwithContact= new List<Staging_Data__c>();
		
		if(lstStaging.size() ==0){
			return;
		}	
			Map<String,Staging_Data__c> CertTrackerIdMap =new Map<String,Staging_Data__c> ();
			// Create set for ProfileID and Education Id from Staging object 
			for(Staging_Data__c objEduStage : lstStaging){
				if(objEduStage.Text1__c != null){
					CertTrackerIdMap.put(objEduStage.Text1__c,objEduStage);
				}					
			}	
			 List<contact> contacts=[select id,Cert_Tracker_Contact_ID__c from contact where Cert_Tracker_Contact_ID__c in :CertTrackerIdMap.keySet() ]	;
			 Map<String,Contact> certIdContactMap = new Map<String,Contact>();				
			 for(contact con  : contacts){
					certIdContactMap.put(con.Cert_Tracker_Contact_ID__c,con)	;
			}		
			if(certIdContactMap.keySet().containsAll(CertTrackerIdMap.keySet())){
					//create all educations
					lstStagingMappedwithContact=CertTrackerIdMap.values();	
			}else{
				Set <String>ExistingCertTrackerIDs =certIdContactMap.keySet();
				for( String CertTrackerId:CertTrackerIdMap.keySet()){
					if(ExistingCertTrackerIDs.contains(CertTrackerId)){
						lstStagingMappedwithContact.add(CertTrackerIdMap.get(CertTrackerId));
					}else{
						lstStagingNOTMappedwithContact.add(CertTrackerIdMap.get(CertTrackerId));
					}
				}
			}
	 }	
	 */
	  
	 public static void verifyExistingEducationStagingData(List<Staging_Data__c> lstStaging,string batchid,List<EMCException> emailerrors){
	 		
	 		bypassTriggers= true;
	 		
	 		Map<String,Staging_Data__c> StagingDataMap= new Map<String,Staging_Data__c>();
	 		Map<String,Education__c> EducationMap= new Map<String,Education__c>();
	 		List<Staging_Data__c> lstStagingForNotMatchedProcess=new List<Staging_Data__c>();
	 		List<Education__c> lstEducation= new List<Education__c>();
	 		
	 		
	 		for(Staging_Data__c objEduStage : lstStaging){	
	 			if(objEduStage.Text12__c == DataValueMap.get('EducationTypeTraining').DataValue__c ){
					StagingDataMap.put(objEduStage.Text2__c,objEduStage);
				}else if(objEduStage.Text12__c == DataValueMap.get('EducationTypeCertAccred').DataValue__c){
					StagingDataMap.put(objEduStage.Text1__c + objEduStage.Text5__c,objEduStage);
				}
	 		}	
			for(Education__c objEdu : ([select id,Cert_ID__c,Transaction_ID__c,CONTACT__r.Account.Grouping__c,ESBI_Name__c,CONTACT__r.email,CONTACT__r.CERT_TRACKER_CONTACT_ID__C,CONTACT__r.Active__c from Education__c where TRANSACTION_ID__C in :StagingDataMap.keySet()])){
				EducationMap.put(objEdu.TRANSACTION_ID__C,objEdu);
			}
			for(String TransactionId : StagingDataMap.keySet()){
				Education__c objEdu=EducationMap.get(TransactionId);
				Staging_Data__c objStagingData =StagingDataMap.get(TransactionId);
				
				
				if(objStagingData!=null && objEdu!=null && compare(objEdu,objStagingData)){
					lstEducation.add(updateEducation(objEdu,objStagingData));
				}else{
					lstStagingForNotMatchedProcess.add(objStagingData);
				}
			}
			
			//upsertEducation(lstEducation,false);
			upsertEducationwithbatchid(lstEducation,false,batchid,emailerrors);
			
	 		if(lstStagingForNotMatchedProcess.size()>0){
	 			createEducationAndpopulateContact(lstStagingForNotMatchedProcess);
	 		}
	 }
	
		public static Education__c updateEducation(Education__c objTempEducation,Staging_Data__c objEduStage){
				
				//assign CertTracContact id from Staging data record to education record				
				objTempEducation.Cert_ID__c = objEduStage.Text1__c;
				
				//Added on Change request for Training 
				//assign trascation id from Staging data record to education record	
				if(objEduStage.Text12__c == DataValueMap.get('EducationTypeTraining').DataValue__c ){
					objTempEducation.Transaction_ID__c = objEduStage.Text2__c;
				}else if(objEduStage.Text12__c == DataValueMap.get('EducationTypeCertAccred').DataValue__c){
					objTempEducation.Transaction_ID__c = objEduStage.Text1__c + objEduStage.Text5__c;
				}		
				
				//assign Email from Staging data record to education record	
				if((objEduStage.Text3__c).indexOf('@')!=-1){			
					objTempEducation.Email__c = objEduStage.Text3__c;
				}
				//assign Education Id from Staging data record to education record				
				objTempEducation.Partner_Grouping_ID__c = objEduStage.Text4__c;
				//assign Education Id from Staging data record to education record				
				objTempEducation.Education_ID__c = objEduStage.Text5__c;
				//assign First name from Staging data record to education record				
				objTempEducation.First_Name__c = objEduStage.Text6__c;
				//assign last name from Staging data record to education record
				objTempEducation.Last_Name__c = objEduStage.Text7__c;  
				//assign ESBI name from Staging data record to education record 
				objTempEducation.ESBI_Name__c = objEduStage.Text8__c;
				//assign country from Staging data record to education record				
				objTempEducation.Country__c = objEduStage.Text9__c;
				//assign SABA Contact ID from Staging data record to education record
				objTempEducation.SABA_Contact_ID__c = objEduStage.Text10__c;
				//assign Education Type from Staging data record to education record
				objTempEducation.Education_Type__c = objEduStage.Text12__c;
				//assign Education Batch Numer from Staging data record to education record
				objTempEducation.Education_Batch_Number__c = objEduStage.Batch_Id__c;
				//assign Education Staging Id from Staging data record to education record
				objTempEducation.Staging_ID__c = objEduStage.Id; 
				return objTempEducation;
				
		}
		public static boolean compare(Education__c objEdu,Staging_Data__c objStagingData){
				boolean flag;
				flag=false;
				if(objEdu.CONTACT__c!=null && objEdu.CONTACT__r.Account !=null &&
						objEdu.CONTACT__r.Account.Grouping__c == objStagingData.Text4__c &&
					    objEdu.CONTACT__r.email == objStagingData.Text3__c &&
					    objEdu.CONTACT__r.CERT_TRACKER_CONTACT_ID__C == objStagingData.Text1__c &&
					   	objEdu.CONTACT__r.Active__c ==true &&
					   	objEdu.ESBI_Name__c == objStagingData.Text8__c){
					
					flag=true;
						
				}
				return flag;
		}
		
		//vivek written
	public static void upsertEducationwithbatchid(List <Education__c> lstEducation, boolean createSharing,String Batchid,List<EMCException> emailerrors){
			
			 List <EMCException> errors = new List <EMCException>(); 
			if(lstEducation!=null && lstEducation.size() ==0 ){
				return;
			}
			Schema.SObjectField fieldTransaction = Education__c.Fields.Transaction_ID__c;
			//update list of lstEducation
			Database.Upsertresult[] resultEducation = Database.upsert(lstEducation, fieldTransaction,false);
			
			
			//vivek
			 /* HANDLING EXCEPTION LOG*/
		        for (Database.Upsertresult sr : resultEducation) {
		            String dataErrs = '';
		            if (!sr.isSuccess()) {
		                // if the particular record did not get updated, we log the data error 
		                for (Database.Error err : sr.getErrors()) {
		                    dataErrs += err.getMessage();
		                }
		                System.debug('An exception occurred while attempting an update on ' + sr.getId());
		                System.debug('ERROR: ' + dataErrs);
		                errors.add(new EMCException(dataErrs, Batchid, new String [] {sr.getId()}));
		            }
		        }		        
		      // log any errors that occurred
		       if (errors.size() > 0) { 
		            EMC_UTILITY.logErrors(errors);  
		            emailerrors.addall(errors);
		        }		
			
			//log error into error object for fail record
			PRM_EducationHelper.logFailedRecords(resultEducation, 'ERROR_ON_EDUCATION_RECORD_CREATION', lstEducation);
			
			if(!createSharing){
				return ;
			}
			List<Education__Share> lstEducationShare = new List<Education__Share>();
			System.debug('resultEducation --->' + resultEducation);
			for (integer i = 0; i < resultEducation.size(); i++) {
				if (!resultEducation[i].isSuccess()) {
					Education__c objEduSuccess = lstEducation.get(i);
					if(objEduSuccess.ownerId ==DataValueMap.get('EducationQueueId').DataValue__c){
						Education__Share objEduShare = new Education__Share(AccessLevel='Edit', ParentId=objEduSuccess.Id, UserOrGroupId =DataValueMap.get('EducationQueueId').DataValue__c);
						lstEducationShare.add(objEduShare);
					}									
				}				
			}
			System.debug('lstEducationShare --->' + lstEducationShare);
			if(lstEducationShare.size() >0)	{
				Database.SaveResult[] results =  Database.insert(lstEducationShare, false);
				System.debug('arrEduShareSave --->' + results);	
				
				 /* HANDLING EXCEPTION LOG*/
		        for (Database.Saveresult sr : results) {
		            String dataErrs = '';
		            if (!sr.isSuccess()) {
		                // if the particular record did not get updated, we log the data error 
		                for (Database.Error err : sr.getErrors()) {
		                    dataErrs += err.getMessage();
		                }
		                System.debug('An exception occurred while attempting an update on ' + sr.getId());
		                System.debug('ERROR: ' + dataErrs);
		                errors.add(new EMCException(dataErrs, Batchid, new String [] {sr.getId()}));
		            }
		        }
		       // log any errors that occurred
		       if (errors.size() > 0) { 
		            EMC_UTILITY.logErrors(errors); 
		            emailerrors.addall(errors); 
		        }		   
			}
			
	}
		
	/* @Method <This method is used to populate contact on Education record>.
	   @param <This is taking list of Staging records >
	   @return <void> - <List of education record>
	   @throws exception - <No Exception>
	*/
	
	public static void createEducationAndpopulateContact(List<Staging_Data__c> lstStaging){
		//hold local variables
		Map<Id,Id> mapGroupidAndAuthorisedResellerAccounts = new Map<Id,Id>() ;
		Set<String> setStagePartnerGroupingID = new Set<String>();
		Set<String> setEducationName = new Set<String>();				
		List<Education__c> lstEducation = new List<Education__c>();
		
		Map<String, Education_Master__c> mapEducationNameAndEduMaster = new Map<String, Education_Master__c>();		
		Map<String, List<Account>> mapGroupidAndAccounts = new Map<String, List<Account>>();
		Map<String, Map<String, List<Contact>>> mapGroupidAndEmailContact = new Map<String, Map<String, List<Contact>>>();
		Map<String, Map<String, List<Contact>>> mapGroupidAndCerttrackidContact = new Map<String, Map<String, List<Contact>>>();
		Map<String, List<Contact>> mapAcountidAndContacts = new Map<String, List<Contact>>();
		Map<Id, Account> mapAcountGrouping = new  Map<Id, Account>();
		Map<String, User> mapContactAndPartnerUser = new Map<String, User>();
		Map<Id, Education_Master__c> educationMasterMap = new Map<Id, Education_Master__c>();
		
		Education__c objTempEducation =null;
		Education__Share objEduShare = null;
		
		Map<Id, Contact> mapAccountContact = new Map<Id, Contact>();
		Map<String, List<Contact>> mapTempEmailAndContact = null;
		Map<String, List<Contact>> mapTempCertraccontactAndContact = null;
		Set<Id> setAccountOwnerId = new Set<Id>();
		Map<Id, User> mapPartnerUser = new Map<Id, User>();
		Set<string>emailSet = new Set<string>();
		Set<string>CerTrackerIdSetSet = new Set<string>();
		
		if(lstStaging.size() >0){
			
			// Create set for ProfileID and Education Id from Staging object 
			for(Staging_Data__c objEduStage : lstStaging){
				if(objEduStage.Text4__c != null){
					if((objEduStage.Text4__c.length() >= 15)){
						try{
							Id partnerGroupingID = objEduStage.Text4__c;
							setStagePartnerGroupingID.add(objEduStage.Text4__c);
						}catch(Exception ex){
							//No need to add
							System.Debug('Invaild PartnerGroupingID --->' + objEduStage.Text4__c);
						}						
					}
				}
				if(objEduStage.Text8__c != null){
					setEducationName.add(objEduStage.Text8__c );
				}
				if(objEduStage.Text1__c != null || objEduStage.Text1__c !=''){
					CerTrackerIdSetSet.add(objEduStage.Text1__c );
				}
				if(objEduStage.Text3__c != null || objEduStage.Text3__c !=''){
					emailSet.add(objEduStage.Text3__c );
				}				
			}			
			System.Debug('setStagePartnerGroupingID --->' + setStagePartnerGroupingID);
			System.Debug('setEducationName --->' + setEducationName);
			
			// Fetch contact record using Partner Grouping and Email address.
			if(setStagePartnerGroupingID.size() >0){
				//fetch account record using account grouping id
				mapAcountGrouping = new  Map<Id, Account>(
																[Select ID, Name , Grouping__c,PROFILED_ACCOUNT_FLAG__c,Partner_Programs__c
																 from  Account 
																 WHERE Grouping__c in: setStagePartnerGroupingID limit 10000]);
				System.Debug('mapGrouping --->' + mapAcountGrouping);												 
				for(Account objAGrecord :mapAcountGrouping.values()){									
					String strKeyValue = objAGrecord.Grouping__c;						
					if(mapGroupidAndAccounts.containsKey(strKeyValue)){
						mapGroupidAndAccounts.get(strKeyValue).add(objAGrecord);
					}else{
						mapGroupidAndAccounts.put(strKeyValue, new List<Account>());
						mapGroupidAndAccounts.get(strKeyValue).add(objAGrecord);
					}
					if(objAGrecord.PROFILED_ACCOUNT_FLAG__c==True && objAGrecord.Partner_Programs__c!=Null){
						if(objAGrecord.Partner_Programs__c.contains('Authorized Reseller')){
						mapGroupidAndAuthorisedResellerAccounts.put(strKeyValue,objAGrecord.Id );
						}
					}
					
				}															 
				System.Debug('Set of AccountIDs --->' + mapAcountGrouping.keySet());	
				System.Debug('mapGroupidAndAccounts --->' + mapGroupidAndAccounts);
				
				//fetch contact using account ids
				mapAccountContact = new Map<Id, Contact>(
														[Select Id, Name, Cert_Tracker_Contact_ID__c , Email, Partner_User2__c, AccountId, Account.OwnerId
														 FROM Contact 
														 WHERE accountid in :mapAcountGrouping.keySet() and Active__c= true and (Email in :emailSet or Cert_Tracker_Contact_ID__c in :CerTrackerIdSetSet)														 
														 limit: Limits.getLimitQueryRows()]);
				System.Debug('mapAccountContact --->' + mapAccountContact);
				//				
				for(Contact objContactrecord :mapAccountContact.values()){
					String strKeyValue = objContactrecord.AccountId;						
					if(mapAcountidAndContacts.containsKey(strKeyValue)){
						mapAcountidAndContacts.get(strKeyValue).add(objContactrecord);
					}else{
						mapAcountidAndContacts.put(strKeyValue, new List<Contact>());
						mapAcountidAndContacts.get(strKeyValue).add(objContactrecord);
					}
					if(objContactrecord.Account!= null && objContactrecord.Account.OwnerId != null){
						setAccountOwnerId.add(objContactrecord.Account.OwnerId);
					}
				}				
				System.Debug('mapAcountidAndContacts --->' + mapAcountidAndContacts);
				
				//create map where key as group id and value is list of contact
				for(String strGroupId : mapGroupidAndAccounts.keySet()){
					mapTempEmailAndContact = new Map<String, List<Contact>>();
					mapTempCertraccontactAndContact = new Map<String, List<Contact>>();

					//fetch accounts for group
					Map<Id, Account> mapTempAccount = new Map<Id, Account>(mapGroupidAndAccounts.get(strGroupId));
					if(mapTempAccount != null){					
						for(String strAccountId  : mapTempAccount.keySet()){						
							if(mapAcountidAndContacts.containsKey(strAccountId)){
								//fetch contacts fron account
								Map<Id, Contact> mapTempContact = new Map<Id, Contact>(mapAcountidAndContacts.get(strAccountId));								
								if(mapTempContact != null){								
									for(Contact objContact: mapTempContact.values()){
										if(objContact.Email != null){
											if(mapTempEmailAndContact.containsKey(objContact.Email.toLowerCase())){
												mapTempEmailAndContact.get(objContact.Email.toLowerCase()).add(objContact);
											}else{
												mapTempEmailAndContact.put(objContact.Email.toLowerCase(), new List<Contact>());
												mapTempEmailAndContact.get(objContact.Email.toLowerCase()).add(objContact);
											}											
										}
										if(objContact.Cert_Tracker_Contact_ID__c != null){											
											if(mapTempCertraccontactAndContact.containsKey(objContact.Cert_Tracker_Contact_ID__c)){
												mapTempCertraccontactAndContact.get(objContact.Cert_Tracker_Contact_ID__c).add(objContact);
											}else{
												mapTempCertraccontactAndContact.put(objContact.Cert_Tracker_Contact_ID__c, new List<Contact>());
												mapTempCertraccontactAndContact.get(objContact.Cert_Tracker_Contact_ID__c).add(objContact);
											}
										}										
									}
								}	
							}						
						}
						if(mapTempEmailAndContact.size() >0){
							mapGroupidAndEmailContact.put(strGroupId, mapTempEmailAndContact);
							
						}
						if(mapTempCertraccontactAndContact.size() >0){
							mapGroupidAndCerttrackidContact.put(strGroupId, mapTempCertraccontactAndContact);
						}
					}	
				}
			}
			System.Debug('mapGroupidAndEmailContact --->' + mapGroupidAndEmailContact);	
			
			//fetch User using contact id for owner	
			if(mapAccountContact.size() >0){
				mapPartnerUser = new Map<Id, User>([Select Id, Name, ContactId FROM user 
													WHERE (ContactId in: mapAccountContact.keySet() OR Id in: setAccountOwnerId)  AND isActive =true]);
				if(mapPartnerUser != null && mapPartnerUser.size() >0){
					for(User objUser : mapPartnerUser.values()){
						mapContactAndPartnerUser.put(objUser.ContactId, objUser);
					} 
				}
			}
			System.Debug('mapContactAndPartnerUser --->' + mapContactAndPartnerUser);
			
			if(setEducationName.size() >0){
				//Fetch Education Master records using Education Ids
				educationMasterMap = new Map<Id, Education_Master__c>([
																Select Id, Modified_Category__c, Modified_Level__c, Modified_Name__c, 
																		Modified_Type__c,Modified_Version__c, ESBI_ID__c, ESBI_Name__c
																FROM   Education_Master__c
																WHERE  	ESBI_Name__c in:setEducationName limit 10000]);
				for(Education_Master__c objEduMaster: educationMasterMap.values()){
					if(objEduMaster.ESBI_Name__c != null){
						mapEducationNameAndEduMaster.put(objEduMaster.ESBI_Name__c , objEduMaster);
					}				
				}
			}
			System.Debug('mapEducationNameAndEduMaster --->' + mapEducationNameAndEduMaster);	
			
			//Used to store the data mapping using the custom setting.
			DataValueMap = CustomSettingDataValueMap__c.getAll();
															
			// create education record and add into list
			for(Staging_Data__c objEduStage : lstStaging){
				objTempEducation = new Education__c();
				Boolean checkForMailContact = true;
				System.debug('Inside grouping --->'+ objEduStage);
				//assign contact to education record
				//check grouping fields	
				if((objEduStage.Text4__c != null) && (objEduStage.Text4__c.length() >= 15)){
					try{
						Id partnerGroupingId = objEduStage.Text4__c;
					
						System.debug('Inside grouping mapGroupid--->'+ mapGroupidAndCerttrackidContact.containsKey(partnerGroupingId));	
						if(mapGroupidAndCerttrackidContact.containsKey(partnerGroupingId)){
							// get all contact within grouping using certTrackContactid
							Map<String, List<Contact>> mapTempCertTracContactAndContact = mapGroupidAndCerttrackidContact.get(partnerGroupingId);
							System.debug('Inside grouping --->'+ mapTempCertTracContactAndContact.size());						
							if(mapTempCertTracContactAndContact != null){
								if(objEduStage.Text1__c != null){
									//check for the certTrackContact record exist
									if(mapTempCertTracContactAndContact.containsKey(objEduStage.Text1__c)){
										
										//fetch all contact into list for CertTrackContactId of 
										List<Contact> lstContact = mapTempCertTracContactAndContact.get(objEduStage.Text1__c);
										System.debug('Inside grouping Contact--->'+ lstContact.size());
										if(lstContact != null) {
											//check if more that one contact found, fall into queue
											if(lstContact.size() >1){
												objTempEducation.OwnerId = DataValueMap.get('EducationQueueId').DataValue__c;
												objTempEducation.Contact__c = null;
												objTempEducation.Fall_Out_Reason__c='Duplicate Contacts';
												checkForMailContact = false;
												
												System.debug('Inside grouping Contact fall in queue--->');
											}else{
												// if only one record, assign owner as well as contact on education record
												Contact objContact = lstContact.get(0);
												//check that caontact is partner or not.											
												User tempPartnerUser = mapContactAndPartnerUser.get(objContact.Id);
												if(tempPartnerUser != null){
													objTempEducation.OwnerId = tempPartnerUser.Id;
													objTempEducation.Contact__c = objContact.Id;
													checkForMailContact = false;
													System.debug('Inside grouping Owner set Partner--->');
												}else{
													//if(mapAccountContact.containsKey(objContact.Account.OwnerId)) 
													if(mapAccountContact.containsKey(objContact.Id)){
														if(objContact.AccountId != null){
															if(mapPartnerUser.containsKey(objContact.Account.OwnerId)){
																objTempEducation.OwnerId = objContact.Account.OwnerId;
																objTempEducation.Contact__c = objContact.Id;
																checkForMailContact = false;
																System.debug('Inside grouping Owner set Account--->');	
															}
														}														
													}else{
														objTempEducation.OwnerId = DataValueMap.get('EducationQueueId').DataValue__c;
														objTempEducation.Contact__c = null;
														objTempEducation.Fall_Out_Reason__c='Inactive Owner';
														checkForMailContact = false;
														System.debug('Inactive account owner--->'+ objContact.Account.OwnerId );
													}													
												}																					
											}
										}
									}
								}							
							}						
						}	
						if(checkForMailContact){
							// get all contact within grouping using email id
							if(mapGroupidAndEmailContact.containsKey(partnerGroupingId)){
								Map<String, List<Contact>> mapTempEmailAndContactList = mapGroupidAndEmailContact.get(partnerGroupingId);
								System.debug('Inside grouping for email--->' + objEduStage.Text3__c + ' :::: ' +  mapTempEmailAndContactList);
								if(mapTempEmailAndContactList != null){
									System.debug('Inside grouping for email--->'+ mapTempEmailAndContactList.size());
									if(objEduStage.Text3__c != null){
										//check for the email record exist
										if(mapTempEmailAndContactList.containsKey(objEduStage.Text3__c.toLowerCase())){
											//fetch all contact into list for CertTrackContactId of 
											List<Contact> lstContact = mapTempEmailAndContactList.get(objEduStage.Text3__c.toLowerCase());
											System.debug('Inside grouping for email lstContact--->'+ lstContact.size());
											if(lstContact != null) {
												//check if more that one contact found, fall into queue
												if(lstContact.size() >1){
													objTempEducation.OwnerId = DataValueMap.get('EducationQueueId').DataValue__c;
													objTempEducation.Contact__c = null;
													objTempEducation.Fall_Out_Reason__c='Duplicate Contacts';
													System.debug('Inside grouping from Email Contact fall in queue--->');
												}else{
													// if only one record, assign owner as well as contact on education record
													Contact objContact = lstContact.get(0);
													//check that caontact is partner or not.											
													User tempPartnerUser = mapContactAndPartnerUser.get(objContact.Id);
													if(tempPartnerUser != null){
														objTempEducation.OwnerId = tempPartnerUser.Id;
														objTempEducation.Contact__c = objContact.Id;
													}else{
														if(objTempEducation.OwnerId == null){
															if(mapAccountContact.containsKey(objContact.Id)){
																if(objContact.AccountId != null){
																	if(mapPartnerUser.containsKey(objContact.Account.OwnerId)){
																		objTempEducation.OwnerId = objContact.Account.OwnerId;
																		objTempEducation.Contact__c = objContact.Id;
																		System.debug('Inside grouping Owner set Account--->');	
																	}
																}														
															}else{
																objTempEducation.OwnerId = DataValueMap.get('EducationQueueId').DataValue__c;
																objTempEducation.Contact__c = null;
																objTempEducation.Fall_Out_Reason__c='Inactive Owner';
																System.debug('Inactive account owner--->'+ objContact.Account.OwnerId );
															}	
														}																											
													}																					
												}
											}
										}
									}							
								}
							}	
						}
					}catch(Exception e){
						System.debug('No valid grouping Id--->'+ objEduStage.Text4__c);
					}					
				}
				//if no record found for contact, fall in queue
				if(objTempEducation.OwnerId == null){
					Contact NewContact = new Contact();
					if(mapGroupidAndAuthorisedResellerAccounts.get(objEduStage.Text4__c)!=Null){
						NewContact.FirstName = objEduStage.Text6__c;
						NewContact.LastName = objEduStage.Text7__c;
						NewContact.Email = objEduStage.Text3__c;
						NewContact.AccountId = mapGroupidAndAuthorisedResellerAccounts.get(objEduStage.Text4__c);
						NewContact.Cert_Tracker_Contact_ID__c = objEduStage.Text1__c;
						NewContact.Active__c = True;
						try{
						insert NewContact;
						}
						catch(exception e){
							  objTempEducation.OwnerId = DataValueMap.get('EducationQueueId').DataValue__c;
							  objTempEducation.Contact__c = null;
							  objTempEducation.Fall_Out_Reason__c='Unauthorised Reseller';
						      System.debug('No record found: fall in queue--->');
						}
					}
					System.Debug('NewContact--->' +NewContact.Id);
					
					
					if(NewContact.Id!=Null){
						if(mapPartnerUser.containsKey(NewContact.Account.OwnerId)){
							objTempEducation.OwnerId = NewContact.Account.OwnerId;
				        	objTempEducation.Contact__c = NewContact.Id;
					    	System.debug('Contact Created: fall in queue--->');	
						}
					    else{
					    	 Map<String,CustomSettingDataValueMap__c> CustomDaTaValueMap = CustomSettingDataValueMap__c.getAll();
         					 CustomSettingDataValueMap__c EducationOwnerId = CustomDaTaValueMap.get('EMCAdmin'); 	
					    	 objTempEducation.OwnerId = EducationOwnerId.DataValue__c;
				        	 objTempEducation.Contact__c = NewContact.Id;
					    }	
					}
					else {
						  	  objTempEducation.OwnerId = DataValueMap.get('EducationQueueId').DataValue__c;
							  objTempEducation.Contact__c = null;
							  objTempEducation.Fall_Out_Reason__c='Unauthorised Reseller';
						      System.debug('No record found: fall in queue--->');
					}
				}
				
				//assign Date Achived from Staging data record to education record
				if (objEduStage.Date2__c != null)objTempEducation.Date_Achieved__c = objEduStage.Date2__c;
				//assign Expiration Date from Staging data record to education record
				if (objEduStage.Date1__c != null) objTempEducation.Expiration_Date__c = objEduStage.Date1__c;
				//assign Partner Grouping to education record
				if(objEduStage.Text4__c != null){
					if(objEduStage.Text4__c.length() >=15 ){
						try{
							Id strProfileGroupId = objEduStage.Text4__c;
						//	if(mapGroupidAndAccounts.containsKey(strProfileGroupId)){							
								objTempEducation.Partner_Grouping__c = strProfileGroupId;
						//	}
						}catch(Exception ex){
							//No action required
							System.Debug('Invaild PartnerGroupingID --->' + objEduStage.Text4__c);
						    objTempEducation.Partner_Grouping__c = null ; 
						}						
					}
				}
				
				//assign Master Record field values to education record
				if(mapEducationNameAndEduMaster.containsKey(objEduStage.Text8__c)){
					objTempEducation.Name_Detail__c = mapEducationNameAndEduMaster.get(objEduStage.Text8__c).Modified_Name__c;
					objTempEducation.Type__c = mapEducationNameAndEduMaster.get(objEduStage.Text8__c).Modified_Type__c;
					objTempEducation.Category__c = mapEducationNameAndEduMaster.get(objEduStage.Text8__c).Modified_Category__c;
					objTempEducation.Level__c = mapEducationNameAndEduMaster.get(objEduStage.Text8__c).Modified_Level__c;
					objTempEducation.Education_Master__c =mapEducationNameAndEduMaster.get(objEduStage.Text8__c).Id; 
					//objTempEducation.Name =mapEducationNameAndEduMaster.get(objEduStage.Text8__c).Modified_Name__c;
				}
								
				//added to list of education
				lstEducation.add(updateEducation(objTempEducation,objEduStage)); 
								
			}
			
			System.debug('lstEducation --->' + lstEducation);
			System.debug('lstEducation size --->' + lstEducation.size());
		}
				
			upsertEducation(lstEducation,true);				
				
	} 
	
	
	public static void upsertEducation (List <Education__c>lstEducation, boolean createSharing){
			
			
			if(lstEducation!=null && lstEducation.size() ==0 ){
				return;
			}
			Schema.SObjectField fieldTransaction = Education__c.Fields.Transaction_ID__c;
			//update list of lstEducation
			Database.Upsertresult[] resultEducation = Database.upsert(lstEducation, fieldTransaction,false);
			
			//log error into error object for fail record
			PRM_EducationHelper.logFailedRecords(resultEducation, 'ERROR_ON_EDUCATION_RECORD_CREATION', lstEducation);
			
			if(!createSharing){
				return ;
			}
			List<Education__Share> lstEducationShare = new List<Education__Share>();
			System.debug('resultEducation --->' + resultEducation);
			for (integer i = 0; i < resultEducation.size(); i++) {
				if (!resultEducation[i].isSuccess()) {
					Education__c objEduSuccess = lstEducation.get(i);
					if(objEduSuccess.ownerId ==DataValueMap.get('EducationQueueId').DataValue__c){
						Education__Share objEduShare = new Education__Share(AccessLevel='Edit', ParentId=objEduSuccess.Id, UserOrGroupId =DataValueMap.get('EducationQueueId').DataValue__c);
						lstEducationShare.add(objEduShare);
					}									
				}				
			}
			System.debug('lstEducationShare --->' + lstEducationShare);
			if(lstEducationShare.size() >0)	{
				Database.SaveResult[] arrEduShareSave =  Database.insert(lstEducationShare, false);
				System.debug('arrEduShareSave --->' + arrEduShareSave);	
			}
			
	}

	/* @Method <This method is used to delete Education record>.
	   @param <This is taking list of Education records >
	   @return <void> 
	   @throws exception - <No Exception>
	*/
	public static void deleteEducation(List<Education__c> lstEducation)
	{
		if(lstEducation.size() >0){
			delete lstEducation;
		}		
	}
	
	
		
	/* @Method <This method is used to populate Cert Id on contact from Education record>.
	   @param <This is taking list of Education records >
	   @return <void> 
	   @throws exception - <No Exception>
	*/
	public static void populateCertTrackerContactIDOnContact(List<Education__c> lstEducation)
	{			
		Map<String, Education__c> mapCertTracContactidAndEducation = new Map<String, Education__c>();
		Map<Id,Contact> mapContactWithoutCertId = new map<Id,Contact>();
		List<Contact> lstContactWithCertId = new List<Contact>();
		Contact objTempContact = null; 
		if(lstEducation.size() >0){			
			for(Education__c objEdu : lstEducation){
				if(objEdu.Contact__c != null){					
					mapCertTracContactidAndEducation.put(objEdu.Contact__c, objEdu);
				}
			}
			//fetch contact where certTracContactid is null 
			if(mapCertTracContactidAndEducation.size() >0){
				mapContactWithoutCertId = new Map<Id,Contact>([Select Id, Cert_Tracker_Contact_ID__c, Partner_User2__c, Account.OwnerId, AccountId 
													 FROM   Contact 
													 WHERE  Id in: mapCertTracContactidAndEducation.keySet() 
													 			AND Active__c= true]); 
			}
			
			
			//fetch User using contact id for owner
			Map<String, User> mapContactAndPartnerUser = new Map<String, User>();
			Map<Id, User> mapPartnerUser = new Map<Id, User>([Select Id, Name, ContactId FROM user 
															  where  ContactId in: mapCertTracContactidAndEducation.keySet() and IsActive=true]);
			if(mapPartnerUser.size() >0){
				for(User objUser : mapPartnerUser.values()){
					mapContactAndPartnerUser.put(objUser.ContactId, objUser);
				} 
			}
			
			//assign certTracContactid from Education record to contact record
			for(Education__c objEdu : lstEducation){
				if(objEdu.Contact__c != null) {	
					if(objEdu.Cert_ID__c != null){				
						if(mapContactWithoutCertId.containsKey(objEdu.Contact__c)){
							objTempContact = mapContactWithoutCertId.get(objEdu.Contact__c);
							if(objTempContact.Cert_Tracker_Contact_ID__c == null){
								objTempContact.Cert_Tracker_Contact_ID__c = objEdu.Cert_ID__c;
								lstContactWithCertId.add(objTempContact);
							}											
						}
					}
					//update owner of education
					if(mapContactAndPartnerUser.containsKey(objEdu.Contact__c)){
						objEdu.OwnerId = mapContactAndPartnerUser.get(objEdu.Contact__c).Id;
					}else{
						if(mapContactWithoutCertId.ContainsKey(objEdu.Contact__c)){
							Contact objContact = mapContactWithoutCertId.get(objEdu.Contact__c);
							if(objContact.AccountId != null){
								objEdu.OwnerId = mapContactWithoutCertId.get(objEdu.Contact__c).Account.OwnerId;
							}							
						}						
					}
				}					
			}
			
			//update contact with certTracContactid
			if(lstContactWithCertId.size() >0){
				Database.update(lstContactWithCertId, false);
			}
		}		
	}
	
	/* @Method <This method is used to handle fail records>.
	   @param <This is taking list of error records >
	   @return <void> 
	   @throws exception - <No Exception>
	*/
	public static void logFailedRecords(Database.Upsertresult[] resultrecords , String errorDetails, List<Education__c> lstEducation){
 	    List <EMCException> errors = new List <EMCException>();
         for (integer i = 0; i < resultrecords.size(); i++) {
         	String dataErrs = '';
			if (!resultrecords[i].isSuccess()) {
                // if the particular record did not get updated, we log the data error 
                for (Database.Error err : resultrecords[i].getErrors()) {
                    dataErrs += err.getMessage();
                }
                
                Education__c objEduSuccess = lstEducation.get(i);
                if(objEduSuccess != null){
                	dataErrs +=  ' Staging Id : ' + objEduSuccess.Staging_ID__c;
                }
                System.debug('An exception occurred while attempting an update on ' + resultrecords[i].getId());
                System.debug('ERROR: ' + dataErrs);
                errors.add(new EMCException(dataErrs, errorDetails, new String [] {resultrecords[i].getId()}));
            }
          }  
      // log any errors that occurred
       if (errors.size() > 0) { 
            EMC_UTILITY.logErrors(errors);  
       } 
   } 	
}