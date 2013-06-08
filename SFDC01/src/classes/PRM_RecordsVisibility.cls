/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR       DESCRIPTION                               

 |  ====          =========                ==       =========== 

 | 19/7/2010      Karthik Shivprakash     141592    This class share the records on MTV package and creates the association.
 
 | 29/7/2010      Karthik Shivprakash     Defect#31 Update the deletion method in the class by preventing cross joins association to delete.
 
 | 06/09/2010	  Anand Sharma					  	Fixed duplicate record creation issue 
 
 | 09/09/2010	  Anand Sharma						Added two new method "createAssociationDistributorT2VAR" and "deleteAssociationDistributorT2VAR"
 													to create and delete association between distributor and Tier2 account
 +===========================================================================*/


public class PRM_RecordsVisibility{
 
	//hold the value of insert trigger executed, used to handle recursive insert trigger execution
	public static boolean isInsertEventExecuted = false;
	
	// This method is to create the association for the accounts.	
    public void createAccountAssociation(Map<Id,List<Id>> profiledIdWithSiteDuns){
        List<APPR_MTV__RecordAssociation__c> associationAccountList = new List<APPR_MTV__RecordAssociation__c>();
        List<Id> createSiteDunsId = new List<Id>();
        for(Id acct: profiledIdWithSiteDuns.keySet()){
            createSiteDunsId = profiledIdWithSiteDuns.get(acct);
            for(Id acctId: createSiteDunsId){
                associationAccountList.add(new APPR_MTV__RecordAssociation__c(APPR_MTV__Account__c=acctId,APPR_MTV__Associated_Account__c=acct,APPR_MTV__Account_Role__c='Profiled Account'));                
                System.debug('Association Record after adding'+associationAccountList);
            }
        }
        if(associationAccountList.size()> 0){
            insert associationAccountList;
        }
    }
    
    //This method is used to delete the association created for the accounts
    public void deleteAccountAssociation(Map<Id,List<Id>> profiledIdWithSiteDuns){
        List<APPR_MTV__RecordAssociation__c> deleteAssociationAccount = new List<APPR_MTV__RecordAssociation__c>();
        Map<String,Id> profileAccountWithSiteDunsId = new Map<String,Id>();
        List<Id> deleteSiteDunsId = new List<Id>();
        List<Id> siteDunsId = new List<Id>();
        List<Id> profiledAccountId = new List<Id>();
        for(Id acct: profiledIdWithSiteDuns.keySet()){
            deleteSiteDunsId = profiledIdWithSiteDuns.get(acct);
            for(Id acctId: deleteSiteDunsId){
                siteDunsId.add(acctId);
                profiledAccountId.add(acct);
                profileAccountWithSiteDunsId.put(acct+'_'+acctId,acctId);
                System.debug('Association account id of site duns'+siteDunsId);
                System.debug('Association account id of profiled'+profiledAccountId);
            }    
        }
        deleteAssociationAccount = [Select a.APPR_MTV__Account__c, a.APPR_MTV__Associated_Account__c, a.Id from APPR_MTV__RecordAssociation__c a where a.APPR_MTV__Account__c in :siteDunsId and a.APPR_MTV__Associated_Account__c in :profiledAccountId];
        List<APPR_MTV__RecordAssociation__c> finalDeleteList = new List<APPR_MTV__RecordAssociation__c>();
        //Defect#31 added this below code to check the cross join and to prevent it from deletion.
        for(APPR_MTV__RecordAssociation__c delObj: deleteAssociationAccount){
            if(delObj.APPR_MTV__Account__c == profileAccountWithSiteDunsId.get(delObj.APPR_MTV__Associated_Account__c+'_'+delObj.APPR_MTV__Account__c)){
                    finalDeleteList.add(delObj);
            }
        }
        System.debug('Delete List for Association'+finalDeleteList);
        if(finalDeleteList.size()> 0){
            delete finalDeleteList;
        }
    }
    
    //This method is used to create the association for the lead
    public void createLeadAssociation(Map<Id,List<Id>> creaeLeadWithAccount){
        List<APPR_MTV__Object_Association__c> associationLeadList = new List<APPR_MTV__Object_Association__c>();
        List<Id> createAssociationId = new List<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Map<String, APPR_MTV__Object_Association__c> associationLeadAccountMap = new Map<String, APPR_MTV__Object_Association__c>();
        String strKeyValue = '';
        
        for(Id leadId: creaeLeadWithAccount.keySet()){
            createAssociationId = creaeLeadWithAccount.get(leadId);
            if(createAssociationId != null){
            	accountIdSet.addAll(createAssociationId);
            }                        
        }
        List<APPR_MTV__Object_Association__c> existingAssociatedList = [Select Id, APPR_MTV__LeadId__c, APPR_MTV__Associated_Account__c from APPR_MTV__Object_Association__c
        																where  APPR_MTV__LeadId__c in:creaeLeadWithAccount.keySet() AND APPR_MTV__Associated_Account__c in:accountIdSet];
		
		if(existingAssociatedList.size()> 0){
			for(APPR_MTV__Object_Association__c objOARecord :existingAssociatedList){
				if(objOARecord.APPR_MTV__LeadId__c != null && objOARecord.APPR_MTV__Associated_Account__c!= null){
					strKeyValue = objOARecord.APPR_MTV__LeadId__c + '|'+ objOARecord.APPR_MTV__Associated_Account__c;
                    if(!associationLeadAccountMap.containsKey(strKeyValue)){
                        associationLeadAccountMap.put(strKeyValue, objOARecord);
                    }                   
				}
			}
		}
		        																
        for(Id leadId: creaeLeadWithAccount.keySet()){
            createAssociationId = creaeLeadWithAccount.get(leadId);
            for(Id accountId: createAssociationId){
            	if(!associationLeadAccountMap.containsKey(leadId + '|' + accountId)){
            		associationLeadList.add(new APPR_MTV__Object_Association__c(APPR_MTV__LeadId__c=leadId,APPR_MTV__Associated_Account__c=accountId));
                	System.debug('Lead Association after adding'+associationLeadList);	
            	}                
            }
        }
        if(associationLeadList.size()> 0){
            insert associationLeadList;
        }
    }

    
    //This method is used to delete the association created for the lead
    public void removeLeadAssociation(Map<Id,List<Id>> deleteLeadWithAccount){
        List<APPR_MTV__Object_Association__c> deleteAssociationOfLead = new List<APPR_MTV__Object_Association__c>();
        List<Id> deleteAssociationId = new List<Id>();
        Map<String,Id> leadIdWithAccountId =  new Map<String,Id>();
        List<APPR_MTV__Object_Association__c> finalLeadDelete = new List<APPR_MTV__Object_Association__c>();
        List<Id> deleteAccountId = new List<Id>();
        List<Id> deletLeadId = new List<Id>();
        for(Id leadId: deleteLeadWithAccount.keySet()){
            deleteAssociationId = deleteLeadWithAccount.get(leadId);
            for(Id acctId: deleteAssociationId){
                deleteAccountId.add(acctId);
                deletLeadId.add(leadId);
                leadIdWithAccountId.put(leadId+'_'+acctId,acctId);
                System.debug('Association account id for deletion'+deleteAccountId);
                System.debug('Association lead id for deletion'+deletLeadId);
            }    
        }
        deleteAssociationOfLead = [Select a.APPR_MTV__Associated_Account__c, a.APPR_MTV__LeadId__c from APPR_MTV__Object_Association__c a where a.APPR_MTV__LeadId__c in :deletLeadId and a.APPR_MTV__Associated_Account__c in :deleteAccountId];
        System.debug('Delete List for Association'+deleteAssociationOfLead);
         //Defect#31 added this below code to check the cross join and to prevent it from deletion.
        for(APPR_MTV__Object_Association__c leadObj: deleteAssociationOfLead){
            if(leadObj.APPR_MTV__Associated_Account__c == leadIdWithAccountId.get(leadObj.APPR_MTV__LeadId__c+'_'+leadObj.APPR_MTV__Associated_Account__c)){
                    finalLeadDelete.add(leadObj);
            }
        }
        if(finalLeadDelete.size()> 0){
            delete finalLeadDelete;
        }
    }
    
    /* @Method <This method is used to create assocition between distributor and T2 VAR partners.>
   	@param <this method is taking List of RecordAssociation(New values of RecordAssociation) as arguments>
   	@return <void> - <returning nothing>
   	@throws exception - <No Exception>
	*/
    public void createAssociationDistributorT2VAR(List<APPR_MTV__RecordAssociation__c> recordAssociationList){
    	 System.debug('in recordAssociationList..' + recordAssociationList); 
    	//hold list of Record Association to create 
    	List<APPR_MTV__RecordAssociation__c> associationAccountList = new List<APPR_MTV__RecordAssociation__c>();
    	//hold value of account role for Distributor
    	String strAccountRoleDistributor = System.Label.Account_Role_Distributor;
		//hold value of account role for T2 VAR
		String strAccountRoleT2VAR = System.Label.Account_Role_T2_VAR; 
		//Hold Account Role value
		String strAccountRole ='';
    	//Loop on list of Association record
    	for(APPR_MTV__RecordAssociation__c objRecordAss :recordAssociationList){
    		//check Account role is Distributor or T2 VAR 
        	if(objRecordAss.APPR_MTV__Account_Role__c == strAccountRoleDistributor || objRecordAss.APPR_MTV__Account_Role__c==strAccountRoleT2VAR) {
        		
        		//check Account Role value, If Account role is Distributor, then create new record with T2 VAR Account Role
        		if(objRecordAss.APPR_MTV__Account_Role__c == strAccountRoleDistributor){
        			strAccountRole = strAccountRoleT2VAR;
        		}else{
        			strAccountRole = strAccountRoleDistributor;
        		}	
        		// create Record Association record        		    	
	        	associationAccountList.add(new APPR_MTV__RecordAssociation__c(APPR_MTV__Account__c=objRecordAss.APPR_MTV__Associated_Account__c,	        	
	        		APPR_MTV__Associated_Account__c=objRecordAss.APPR_MTV__Account__c ,
	        		APPR_MTV__Account_Role__c = strAccountRole ));
        	}
        }
        if(associationAccountList.size() >0){
        	System.debug('in associationAccountList..' + associationAccountList);
        	insert associationAccountList;
        }        
    }
    
    /* @Method <This method is used to delete assocition between distributor and T2 VAR partners.>
   	@param <this method is taking List of RecordAssociation(Old values of RecordAssociation) as arguments>
   	@return <void> - <returning nothing>
   	@throws exception - <No Exception>
	*/
    public void deleteAssociationDistributorT2VAR(List<APPR_MTV__RecordAssociation__c> recordAssociationList){		
		//hold value of account role for Distributor
    	String strAccountRoleDistributor = System.Label.Account_Role_Distributor;		
		//hold value of account role for T2 VAR
		String strAccountRoleT2VAR = System.Label.Account_Role_T2_VAR;         
        //hold set of account id
        Set<Id> setMTVAccount = new Set<Id>();
        //hold set of associated account id
	    Set<Id> setMTVAssociatedAccount = new Set<Id>();        
        //Loop on list of Association record
        for(APPR_MTV__RecordAssociation__c objRecordAss :recordAssociationList){ 
        	//check Account role is Distributor or T2 VAR 
    		if(objRecordAss.APPR_MTV__Account_Role__c == strAccountRoleDistributor || objRecordAss.APPR_MTV__Account_Role__c==strAccountRoleT2VAR) {
    			//add values into sets
    			setMTVAccount.add(objRecordAss.APPR_MTV__Account__c);
        		setMTVAssociatedAccount.add(objRecordAss.APPR_MTV__Associated_Account__c);
    		}        	
        } 
        // fetch the record using Accountids and associated account id's	        
        Map<Id, APPR_MTV__RecordAssociation__c> updateRecordAsso = new Map<Id,APPR_MTV__RecordAssociation__c>(
        										[Select Id, APPR_MTV__Account__c, APPR_MTV__Associated_Account__c, 
        												APPR_MTV__Account_Role__c, APPR_MTV__Primary__c from  APPR_MTV__RecordAssociation__c 
        										 where APPR_MTV__Account__c in:setMTVAssociatedAccount AND APPR_MTV__Associated_Account__c in:setMTVAccount limit 1000]);
		if(updateRecordAsso.size()>0){
			delete updateRecordAsso.values();
		}		
    }    
}