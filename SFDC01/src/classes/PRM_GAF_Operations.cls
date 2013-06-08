/*=========================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER           WR      DESCRIPTION                               

 |  ====          =========           ==      ===========

 |  27/02/2012    Anirudh Singh      188157   This class is used to perform all the updates and validations on 
                                              GAF functionality.
 |  14/05/2012    Anirudh Singh      192924   GAF Sharing Logic has been updated to create sharing for Associated 
 											  Distributor Users after GAF approval.
 |  06/07/2012    Ganesh  Soma       194567   Added logic to set Owner of GAF by invoking setGAFOwner()
 |                                            method after the related account's owner has been updated. 			  											      
  +=========================================================================================================================*/ 
global class PRM_GAF_Operations {
  /* @Method <This method is used to validate GAF record to check if there
     exists already a GAF record for the account on which a new GAf is getting created>
  @param <This method takes List<GAF__c> as parameter>
  @return <void> - <The method is not returning anything>
  @throws exception - <No Exception>
  */
    public void validateGAF(List<GAF__c> lstGAFToValidate){
        Map<String,Id> MapAccountWithYear = new Map<String,Id>();
        Map<String,Id> MapExistingGAFAccountWithYear = new Map<String,Id>();
        List<GAF__c> gafRecords = new list<GAF__c>();
        for(GAF__c gafObj :lstGAFToValidate){
            MapAccountWithYear.put(gafObj.Year__c+gafObj.Partner_Name__c,gafObj.Partner_Name__c);
        }
        Map<id,Account> mapwithOwnerDetails = new Map<id,Account>([Select Id,OwnerId from Account where Id in :MapAccountWithYear.values()]);
        gafRecords = [Select Id,Year__c,Partner_Name__c,Partner_Name__r.OwnerId from GAF__c where Partner_Name__c in :MapAccountWithYear.values()];
        if(gafRecords.size()>0){
        	for(GAF__c existingGaf :gafRecords){
        		MapExistingGAFAccountWithYear.put(existingGaf.Year__c+existingGaf.Partner_Name__c,existingGaf.Partner_Name__c);
        	}
        }
        
        for (GAF__c newGaf :lstGAFToValidate){
        	 if(newGaf.Partner_Name__c!=null){
        		newGaf.OwnerId= mapwithOwnerDetails.get(newGaf.Partner_Name__c).Ownerid;
        	 }
        	 if(gafRecords.size()>0){                                 	                  	
                if(MapExistingGAFAccountWithYear.containsKey(newGaf.Year__c+newGaf.Partner_Name__c)){
                   newGaf.adderror(System.Label.You_can_not_create_a_new_GAF_for_the_same_year);
                } 
        	}                                                  
        }           
        
   }
  /* @Method <This method is used to populate values on GAF record>
  @param <This method takes List<GAF__c> as parameter>
  @return <void> - <The method is not returning anything>
  @throws exception - <No Exception>
  */
    public void setSubmittedByInfoOnGAF(List<GAF__c> lstGAFtoUpdate){
        for(GAF__c gafObj : lstGAFtoUpdate){
            gafObj.GAF_Submitted_By__c=userInfo.getUserId();
            gafObj.GAF_Submission_Date__c=Date.Today();
        }        
   }
  /* @Method <This method is used to reset values on GAF if the record is
   again in Draft Status>
  @param <This method takes List<GAF__c> as parameter>
  @return <void> - <The method is not returning anything>
  @throws exception - <No Exception>
  */
    public void updateGAFforResubmission(List<GAF__c> lstGAFtoUpdate){
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        for(GAF__c gafObj : lstGAFtoUpdate){
            gafObj.GAF_Submitted_By__c=null;
            gafObj.GAF_Submission_Date__c=null;  
  
        }
        deleteSharingforPartnerUsers(lstGAFtoUpdate);
   }
/* @Method <This method is used to set the record type values on GAF>
  @param <This method takes List<GAF__c> as parameter>
  @return <void> - <The method is not returning anything>
  @throws exception - <No Exception>
  */
    public void setrecordTypeOnGAf(List<GAF__c> lstGAFAfterInsert){
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        List<GAF__c> lstGafToUpdate = new list<GAF__c>([Select Id,Partner_Theater__c,Partner_Type__c,GAF_Status__c,RecordTypeId from GAF__c where id in :lstGAFAfterInsert]);
        for(GAF__c gafObj : lstGafToUpdate){            
            if(gafObj.Partner_Theater__c=='Americas' && gafObj.Partner_Type__c=='Distributor' && gafObj.GAF_Status__c !='Partner Approved'){                   
               gafObj.RecordTypeId=DataValueMap.get('GAFAmerDistributor').DataValue__c;                   
            }
            if(gafObj.Partner_Theater__c=='Americas' && gafObj.Partner_Type__c=='Distributor' && gafObj.GAF_Status__c =='Partner Approved'){                   
               gafObj.RecordTypeId=DataValueMap.get('GAFAmerDistiApproved').DataValue__c;                   
            }
            if(gafObj.Partner_Theater__c=='EMEA' && gafObj.Partner_Type__c=='Distributor'){                   
               gafObj.RecordTypeId=DataValueMap.get('GAFEMEADistributor').DataValue__c;                   
            }
            if(gafObj.Partner_Theater__c=='EMEA' && (gafObj.Partner_Type__c=='Direct Reseller' || gafObj.Partner_Type__c=='Distribution VAR')){                   
               gafObj.RecordTypeId=DataValueMap.get('GAFEMEADirectAndVAR').DataValue__c;                   
            }
             if(gafObj.Partner_Theater__c=='Americas' && (gafObj.Partner_Type__c=='Direct Reseller' || gafObj.Partner_Type__c=='Distribution VAR') && gafObj.GAF_Status__c !='Partner Approved'){                    
                gafObj.RecordTypeId=DataValueMap.get('GAFAmerDirectAndVAR').DataValue__c;                    
            } 
            if(gafObj.Partner_Theater__c=='Americas' && (gafObj.Partner_Type__c=='Direct Reseller' || gafObj.Partner_Type__c=='Distribution VAR') && gafObj.GAF_Status__c =='Partner Approved'){                    
                gafObj.RecordTypeId=DataValueMap.get('GAFAmerDirectDistiApproved').DataValue__c;                    
            }   
                     
        }
        Update lstGafToUpdate;        
   }   
 /* @Method <This method is used to create sharing for Partner
     Approver User when the GAF is in Submitted Status>
  @param <This method takes List<GAF__c> as parameter>
  @return <void> - <The method is not returning anything>
  @throws exception - <No Exception>
  */
    public void createSharingForPartnerApprover(List<GAF__c> lstGAFtoShare){
        Map<id,Id> mapGafWithPartnerApprover = new map<id,Id>();
        List<GAF__Share> gafShareToInsert = new list<GAF__Share>();
        for(GAF__c gafObj : lstGAFtoShare){
            mapGafWithPartnerApprover.put(gafObj.Id,gafObj.Partner_GAF_Approver__c);            
        }
        if(mapGafWithPartnerApprover!=null && mapGafWithPartnerApprover.size()>0){
            for(Id GafId :mapGafWithPartnerApprover.keyset()){
                GAF__Share share = new GAF__Share(UserOrGroupId=mapGafWithPartnerApprover.get(GafId),AccessLevel='Edit',parentid= gafid);
                gafShareToInsert.add(share);
            }
        }
        if(gafShareToInsert.size()>0){
           insert gafShareToInsert;
        }
   }   
 /* @Method <This method is used to delete sharing for Partner
    Users when the GAF is in Draft Status>
  @param <This method takes List<GAF__c> as parameter>
  @return <void> - <The method is not returning anything>
  @throws exception - <No Exception>
  */
    public void deleteSharingforPartnerUsers(List<GAF__c> lstGAFtoDeleteShare){        
        List<GAF__Share> gafShareToDelete = new list<GAF__Share>([Select id,Accesslevel,UserorGroupId,parentId from GAF__Share
                                                                 where parentId in :lstGAFtoDeleteShare and rowcause='Manual']);
        if(gafShareToDelete.size()>0){
           delete gafShareToDelete;
        }
   }
   
/* @Method <This method is called on click on Accept Deal Reg Button,used to update PSC User Field on lead record
            with the user who clicks that button.>
    @param <It is taking LeadId as parameter>
    @return String of Success/Exception>
    @throws exception - <No Exception>
*/
    webservice static string ApproveGAf(Id GafId) {     
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        string result;        
        if(userinfo.getuserType()=='PowerPartner'){
            GAF__c GAFToApprove = [select id,GAF_Status__c,Partner_Theater__c,Partner_Type__c,RecordTypeId,GAF_Approval_Date__c from GAF__c where id  =: GafId limit 1];
            try{
                if(GAFToApprove.Partner_Theater__c=='Americas' && GAFToApprove.Partner_Type__c=='Distributor'){
                   GAFToApprove.GAF_Status__c='Partner Approved';
                   GAFToApprove.RecordTypeId=DataValueMap.get('GAFAmerDistiApproved').DataValue__c;
                   GAFToApprove.GAF_Approval_Date__c=System.Today();
                }
                if(GAFToApprove.Partner_Theater__c=='EMEA' && GAFToApprove.Partner_Type__c=='Distributor'){
                   GAFToApprove.GAF_Status__c='Partner Approved';
                   GAFToApprove.RecordTypeId=DataValueMap.get('GAFEMEADistiApproved').DataValue__c;
                   GAFToApprove.GAF_Approval_Date__c=System.Today();
                }
                if(GAFToApprove.Partner_Theater__c=='EMEA' && (GAFToApprove.Partner_Type__c=='Direct Reseller' || GAFToApprove.Partner_Type__c=='Distribution VAR')){
                   GAFToApprove.GAF_Status__c='Partner Approved';
                   GAFToApprove.RecordTypeId=DataValueMap.get('GAFEMEADirectVARApproved').DataValue__c;
                   GAFToApprove.GAF_Approval_Date__c=System.Today();
                }
                 if(GAFToApprove.Partner_Theater__c=='Americas' && (GAFToApprove.Partner_Type__c=='Direct Reseller' || GAFToApprove.Partner_Type__c=='Distribution VAR')){
                    GAFToApprove.GAF_Status__c='Partner Approved';
                    GAFToApprove.RecordTypeId=DataValueMap.get('GAFAmerDirectDistiApproved').DataValue__c;
                    GAFToApprove.GAF_Approval_Date__c=System.Today();
                }
                
                update GAFToApprove;
                result = 'success';                   
            } 
            catch(Exception e){ 
                result = e.getMessage();
            }
        }
        return result;
    }
/* @Method <This method is called when GAF is Approved by Internal Users>
    @param <It is taking LeadId as parameter>
    @return String of Success/Exception>
    @throws exception - <No Exception>
*/
    public void  updateApprovedGAFInternally(List<GAF__c> lstGafAfterUpdate) {     
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();        
            List<GAF__c> ApprovedGaf = [select id,GAF_Status__c,Partner_Theater__c,Partner_Type__c,RecordTypeId,GAF_Approval_Date__c from GAF__c where id  in :lstGafAfterUpdate];
            try{
                 for(GAF__c gafObj :ApprovedGaf){
                    if(gafObj.Partner_Theater__c=='Americas' && gafObj.Partner_Type__c=='Distributor'){                   
                       gafObj.RecordTypeId=DataValueMap.get('GAFAmerDistiApproved').DataValue__c;
                       gafObj.GAF_Approval_Date__c= System.Today();
                    }
                    if(gafObj.Partner_Theater__c=='EMEA' && gafObj.Partner_Type__c=='Distributor'){                   
                       gafObj.RecordTypeId=DataValueMap.get('GAFEMEADistiApproved').DataValue__c;
                       gafObj.GAF_Approval_Date__c=System.Today();
                    }
                    if(gafObj.Partner_Theater__c=='EMEA' && (gafObj.Partner_Type__c=='Direct Reseller' || gafObj.Partner_Type__c=='Distribution VAR')){                   
                       gafObj.RecordTypeId=DataValueMap.get('GAFEMEADirectVARApproved').DataValue__c;
                       gafObj.GAF_Approval_Date__c=System.Today();
                    }
                     if(gafObj.Partner_Theater__c=='Americas' && (gafObj.Partner_Type__c=='Direct Reseller' || gafObj.Partner_Type__c=='Distribution VAR')){                    
                        gafObj.RecordTypeId=DataValueMap.get('GAFAmerDirectDistiApproved').DataValue__c;
                        gafObj.GAF_Approval_Date__c=System.Today();
                    }
                 }   
                
                update ApprovedGaf;
                                  
            } 
            catch(Exception e){                 
            }        
    }
/* @Method <This method is used to create GAF sharing for 
			Distributor Accounts when an Association is created on Distribution VAR Account>
  @param <This method takes Map<Id,Id> as parameter>
  @return <void> - <The method is not returning anything>
  @throws exception - <No Exception>
  */
    public void createSharingForDistributorPartnerUser(Map<Id,List<Id>> mapAccountWithAssocaitedAccount){
        Map<id,List<Id>> mapAccountWithUser = new map<id,List<Id>>();
        Map<id,List<Id>> mapAccountWithGAFId = new map<id,List<Id>>();
        List<Id> lstAllDistributorAccount = new List<Id>();
        List<GAF__Share> gafShareToInsert = new list<GAF__Share>();
        List<GAF__c> lstApprovedGAf = new list<GAF__c>([Select Id,Partner_Name__c,	GAF_Status__c from GAF__c where Partner_Name__c in :mapAccountWithAssocaitedAccount.keyset() and GAF_Status__c ='Approved']);
        if(lstApprovedGAf.size()>0){
	        for(GAF__c gafobj :lstApprovedGAf){
	        	list<Id> lstGAfid = mapAccountWithGAFId.get(gafobj.Partner_Name__c);
	        	if(lstGAfid== null){
	        		lstGAfid = new list<Id>();
	        	}
	        	lstGAfid.add(gafobj.id);
	        	mapAccountWithGAFId.put(gafobj.Partner_Name__c,lstGAfid);
	        }
        }
        for(id accid :mapAccountWithAssocaitedAccount.keyset()){
        	for(Id associatedAccId :mapAccountWithAssocaitedAccount.get(accid)){
        		lstAllDistributorAccount.add(associatedAccId);
        	}
        }
        List<User> lstDistributorPartnerUser = new list<User>([Select Id,AccountId,Isactive from user where accountid in:lstAllDistributorAccount and isActive=true]);
        for(user usrObj :lstDistributorPartnerUser){
        	list<Id> distributorUser = mapAccountWithUser.get(usrObj.accountId);
        	if(distributorUser == null){
        		distributorUser = new list<Id>();
        	}
        	distributorUser.add(usrObj.Id);
        	mapAccountWithUser.put(usrObj.accountId,distributorUser);
        }
        
        if(mapAccountWithUser.size()>0 & lstApprovedGAf.size()>0){
           for(Id accountId :mapAccountWithAssocaitedAccount.keyset()){
               for(id gafId :mapAccountWithGAFId.get(accountId)){
               		for(id distributoraccId :mapAccountWithAssocaitedAccount.get(accountId)){
               			for(id userid :mapAccountWithUser.get(distributoraccId)){
                   			GAF__Share share = new GAF__Share(UserOrGroupId=userid ,AccessLevel='Read',parentid= gafId);
                   			gafShareToInsert.add(share); 
               			} 
               		}
               }
           }
        }
        if(gafShareToInsert.size()>0){
           insert gafShareToInsert;
        }
   } 
/* @Method <This method is used to delete sharing for Partner
    Users when the Associations are deleted>
  @param <This method takes Set<Id> as parameter>
  @return <void> - <The method is not returning anything>
  @throws exception - <No Exception>
  */
    public void deleteSharingforDistributorPartnerUsers(set<Id> setAssociatedAccount){
    	Map<Id,User> mapUserTodelGAFShare = new Map<Id,User>([Select Id,Name,AccountId from user where AccountId in :setAssociatedAccount and userType='PowerPartner']);      
        List<GAF__Share> gafShareToDelete = new list<GAF__Share>([Select id,Accesslevel,UserorGroupId,parentId from GAF__Share
                                                                 where UserorGroupId in :mapUserTodelGAFShare.keyset() and rowcause='Manual']);
        if(gafShareToDelete.size()>0){
           delete gafShareToDelete;
        }
   }
/*@Method <This method is used to create sharing for Distributor Partner
			Users when the GAF is in Partner Approved Status>
  @param <This method takes List<GAF__c> as parameter >
  @return <void> - <The method is not returning anything>
  @throws exception - <No Exception>
 */
    public void createSharingForDistributorPartnerUsers(List<GAF__c> lstApprovedGaf){
        Map<Id,List<Id>> mapGafWithAccount = new map<id,List<Id>>();
		Map<Id,List<Id>> mapAccountWithAssociatedAccount = new map<id,List<Id>>();
		List<Id> lstAllAssociatedAccount = new list<Id>();        
        List<GAF__Share> gafShareToInsert = new list<GAF__Share>();
        List<User> lstPartnerUsers = new list<User>();
        List<APPR_MTV__RecordAssociation__c> associationAccountList = new List<APPR_MTV__RecordAssociation__c>();        
        map<id,list<Id>> mapAccountWithPartnerUser = new map<id,list<Id>>();
        for(GAF__c gafObj : lstApprovedGaf){
            List<Id> lstGaf = mapGafWithAccount.get(gafObj.Partner_Name__c);
			if(lstGaf== null){
				lstGaf = new List<Id>();
			}
			lstGaf.add(gafObj.id);
			mapGafWithAccount.put(gafObj.Partner_Name__c,lstGaf);                    
        }
        if(mapGafWithAccount.size()>0){
        	associationAccountList=[Select APPR_MTV__Account__c,APPR_MTV__Associated_Account__c,APPR_MTV__Account_Role__c
        							from APPR_MTV__RecordAssociation__c where APPR_MTV__Account__c in :mapGafWithAccount.keyset() and APPR_MTV__Account_Role__c='Distributor'];
        	if(associationAccountList.size()>0){        		
				for(APPR_MTV__RecordAssociation__c assObj :associationAccountList){
					List<Id> lstAssociatedAccount= mapAccountWithAssociatedAccount.get(assObj.APPR_MTV__Account__c);
					if(lstAssociatedAccount==null){
						lstAssociatedAccount = new List<Id>();
					}
					lstAssociatedAccount.add(assObj.APPR_MTV__Associated_Account__c);
        			lstAllAssociatedAccount.add(assObj.APPR_MTV__Associated_Account__c);
        			mapAccountWithAssociatedAccount.put(assObj.APPR_MTV__Account__c,lstAssociatedAccount);        			
        		}
        	}						
        }
        if(mapGafWithAccount.size()>0){
           lstPartnerUsers=[Select id,Accountid,UserType from user where UserType='PowerPartner' and  
							accountid in :lstAllAssociatedAccount and isActive=true];
        }
        for(user usrObj :lstPartnerUsers){
            list<Id> listPartnerUser;            
	        listPartnerUser=mapAccountWithPartnerUser.get(usrObj.AccountId);
			if(listPartnerUser==null){
			   listPartnerUser = new list<Id>(); 
			}
	        listPartnerUser.add(usrObj.id);           
            mapAccountWithPartnerUser.put(usrObj.AccountId,listPartnerUser);
        }
        if(mapGafWithAccount.size()>0){
           for(id accountId :mapGafWithAccount.keyset()){
           		for(Id gafId :mapGafWithAccount.get(accountId)){               
						if(mapAccountWithAssociatedAccount.get(accountId)!=null && mapAccountWithAssociatedAccount.get(accountId).size()>0){
							for(Id assAccountId :mapAccountWithAssociatedAccount.get(accountId)){
								if(mapAccountWithPartnerUser.get(assAccountId)!=null && mapAccountWithPartnerUser.get(assAccountId).size()>0){
									for(id distipartnerId :mapAccountWithPartnerUser.get(assAccountId)){
										GAF__Share share = new GAF__Share(UserOrGroupId=distipartnerId ,AccessLevel='Read',parentid= gafid);
										gafShareToInsert.add(share);
									}
								}
							}						
						}
           		}			   
           }
        }
        if(gafShareToInsert.size()>0){
           insert gafShareToInsert;
        }  
   }
 /* @Method <This method is used to change the GAF owner on the Account for which GAF owner has been changed>
  @param <This method takes Map<Id,Id> mapAccountIdWithOwnerId>
  @return <void> - <The method is not returning anything>
  @throws exception - <No Exception>
  */
    public void setGAFOwner(Map<Id,Id> mapAccountWithOwner, Map<ID,Account> mapAcctDetails){       
        List<GAF__c> gafRecords = new list<GAF__c>(); 
        List<GAF__c> gafRecordsToUpdate  = new list<GAF__c>();        
        gafRecords = [Select Id,Year__c,OwnerId,Partner_Name__c,Partner_Name__r.OwnerId from GAF__c where Partner_Name__c in :mapAccountWithOwner.keyset()];
        if(gafRecords.size()>0){            
             for(GAF__c GAFObj :gafRecords){
                   GAFObj.OwnerId=mapAccountWithOwner.get(GAFObj.Partner_Name__c);
                   gafRecordsToUpdate.add(GAFObj);
             }                      
        }
        if(gafRecordsToUpdate.size()>0){
                  try
                  {     
                 update gafRecordsToUpdate;
                  }
                  catch(Exception ex)
                  {
                         if(ex.getmessage().contains('TRANSFER_REQUIRES_READ'))
                         {                    
                             for(GAF__c GAFObj :gafRecords){
                              mapAcctDetails.get(GAFObj.Partner_Name__c).adderror(System.Label.Account_Owner_Does_Not_Have_Access_To_GAF);
                             }
                         }
                         else
                         throw ex;                    
                  }     
        }
   }
}