/*===========================================================================================================================+

|  HISTORY  |                       

|  DATE          DEVELOPER               WR         DESCRIPTION                            

 
    ====          =========               ==         =========== 

|  25/04/2011    Ashwini Gowda                      This class is used initiate the approval process when
                                                     deal reg is submitted. 
|   22/07/2011    Ashwini Gowda                      Updated Method updateSLAFieldRepExpirationDateForER() 
|   28/07/2011   Anand Sharma                       Updated Custom setting Datavalue name "DealRegEMEA_DRSLA_BatchSize" 
                                                    and "DealRegEMEA_ERSLA_BatchSize" from DealRegEMEABatchSize 
|   1/08/2011    Ashwini Gowda          3347        Modify EMEA Field Routing for TA reps. Ensure all the following
                                                    reps are emailed with deal reg approval required mail.Updated Methods 
                                                    getRelatedAccountMembersForUsers(),getRelatedAccountMembersForExtensionForUsers(),
                                                    populateFieldRepsForUsers,populateFieldRepsForExtensionRequestForUsers,
                                                    getLimitedUserFromFieldAndDirectRep().          
                                                    
|   05/09/2011  Anand Sharma            3743        Added active check for users for reassignment of approver.
                                                    Updated getRelatedAccountMembersForUsers and getRelatedAccountMembersForExtensionForUsers method
                                                    and added User.IsActive = true check in query. 
                                                    Updated getEmeaDRRoutingMappingForUsers and getEmeaRoutingMappingForExtensionRequestForUsers method
                                                    and added Field_Rep__r.isActive = true and AND Master_Grouping__r.Active__c = true 
                                                    AND Master_Grouping__r.Master__c = false check in query. 
|   27/09/2011  Anand Sharma                        Added Variable dealUpdated and used in trigger LeadAfterUpdate instead of extensionUpdate vairable 
                                                    to handle recursive call
|   29/09/2011  Anand Sharma                        Created a method updateApprovedDeal to asynchronously update Approved DRs for which the Opportunity has been
                                                    linked manually.       
|   12/10/2011  Anirudh Singh           3999        Commented conditional checks in populateFieldRepsForUsers Method in order to populate field reps based on only
                                                    Distributor/Direct Reseller and grouping not based on Distribution VAR.   
                                                
    14/10/2011      Arif                177266      Added a line to populate Original Submission Time  
    14/10/2011      Arif                177387      Changed the 'calculateQuaterDate' method      
|   14/10/2011      Anand Sharma        177295      When a PSC rejects a Deal Registration, they cannot use the standard comments field as 
|                                                    we are asking them to use the custom link to select the rejection Reason
|    25/10/2011     Arif                177387      created flag IsExpDateChange for restricting in change of expiration date in same transaction.  
|    2 Nov 2011     Arif                Defect       Rejection comment is not getting populated if rejected by 'Reject' button   
|    14 Nov 2011    Arif                178752      To Calculate the difference in first Approval/Rej and First Submission of DR in hours  
|    16 Nov 2011    Arif                181055      Only PSC Can approve/reject a lead.       
|    29 Nov 2011    Arif                178752      Changed the 'populateDiffOfOriginalAppRejAndSub' method to take ceiling values.  
|    16 Dec 2011    Arif                            Updated 'updateApprovedDeal' method                                                                                                                                                                                                                                                                                        
|    03 Jan 2012    Suman B             WR-182932   IM7358588- Updated autoApproveEmeaDealReg(),autoApproveEMEAExtensionRequest
|                                                    and autoApproveExtensionForAPjEMEA()methods to check for WorkitemId not Null for Approval Process.
|    13 Jan 2012    Suman B             WR-182932   Added else conditon in the above methods to log the unprocessed DR's and ER's in exception table 
|                                                     for tracking.      
|    25 Jan 2012    Prasad              WR-186430   Code fix for # Extention Requests     
|    14 Feb 2012    Arif                IM7560008   Commented calculation of different b/w app/rej and sub.(Using Formula Field Now)   
|    17 Feb 2012    Arif                            Added try, catch block in 'calculateNOOfExtensions' method.                                                                                                          
|    21 Feb 2012    Kaustav Debnath                 Added list size check to remove exceptions for process steps of DRs
|    21 Feb 2012    Anil Sure                       Fixed FIELD_FILTER_VALIDATION_EXCEPTION 
     24 April 2012  Arif                            Commented Codes for EMEA Decommision
     27 April 2012 Arif                             Deleted Codes for EMEA Decommission
     10 Nov 2012 Suresh D				WR205624	Modified the code to handle Deal Regs Approved before and after 1 Jan 2013.
     
     ## Test Classes: PRM_DEALREG_ApprovalRouting_TC
 +====================================================================================================================================*/
public class PRM_DEALREG_ApprovalRouting {    
    public static boolean IsExpDateChange = true;
     public PRM_DEALREG_ApprovalRouting(){
     }    
    //added to handle recurrsive call 
    public static Boolean extensionUpdated = false;
    public static Boolean dealUpdated = false;
    public static Boolean isExecuted = false; 

/* @Method <This method is used to create the sharing access on Lead for Queues based on Theater>.
   @param <This is method is taking List of Lead as Parameter>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/

    public void createLeadShareForQueues(List<Lead> dealRegList){ 
        Map<String,Set<Id>> pscdRQueueMap = new Map<String,Set<Id>>();
        Map<String,DealRegistration_CustomSetting__c>  data =  DealRegistration_CustomSetting__c.getall();
        String AmerPSCDRQueue = data.get('AmerPSCDRQueue').PSC_QueueId__c;
        String ApjPSCDRQueue = data.get('ApjPSCDRQueue').PSC_QueueId__c;
        String EmeaPSCDRQueue = data.get('EmeaPSCDRQueue').PSC_QueueId__c; 

        for(Lead dealReg: dealRegList){
            if(dealReg.DealReg_Deal_Registration_Status__c !='New'){
                if(dealReg.DealReg_Deal_Registration_Status__c =='Submitted'){
                // Added by Arif on 14/10/2011(177266)
                    if(dealReg.Original_Submission_Time__c == null){
                        dealReg.Original_Submission_Time__c = System.now();
                    }
                    dealReg.DealReg_Submission_Date__c = System.now();
                }
                if(dealReg.DealReg_Theater__c == 'Americas'){
                  if(pscdRQueueMap.containsKey(AmerPSCDRQueue)){
                        pscdRQueueMap.get(AmerPSCDRQueue).add(dealReg.id);
                  }else{
                        pscdRQueueMap.put(AmerPSCDRQueue,new Set<Id>());
                        pscdRQueueMap.get(AmerPSCDRQueue).add(dealReg.id);
                  }
                }

                else if(dealReg.DealReg_Theater__c == 'APJ'){
                  if(pscdRQueueMap.containsKey(ApjPSCDRQueue)){
                        pscdRQueueMap.get(ApjPSCDRQueue).add(dealReg.id);
                  }else{
                        pscdRQueueMap.put(ApjPSCDRQueue,new Set<Id>());
                        pscdRQueueMap.get(ApjPSCDRQueue).add(dealReg.id);
                  }

                }

                else if(dealReg.DealReg_Theater__c == 'EMEA'){
                    if(pscdRQueueMap.containsKey(EmeaPSCDRQueue)){
                        pscdRQueueMap.get(EmeaPSCDRQueue).add(dealReg.id);
                  }else{
                        pscdRQueueMap.put(EmeaPSCDRQueue,new Set<Id>());
                        pscdRQueueMap.get(EmeaPSCDRQueue).add(dealReg.id);
                  }               

                }
            }
        }      
        if(pscdRQueueMap.size()>0){
            createLeadShare(pscdRQueueMap);
        }       

    } 

/* @Method <This method is used to create the sharing access on Lead for Queues>.
   @param <This is method is taking QueueId and set of Lead Id as Parameter from Map>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    public void createLeadShare(Map<String,Set<Id>> queueAndLeadInfoMap){
        List<LeadShare> leadShareList = new List<LeadShare>();
        try{ 
            for(String queueId :queueAndLeadInfoMap.keySet()){
                  if(queueAndLeadInfoMap.containsKey(queueId)){
                        for(String objLeadId :queueAndLeadInfoMap.get(queueId)){
                              leadShareList.add(new LeadShare(UserOrGroupId=queueId,LeadAccessLevel='Edit',LeadId=objLeadId));         
                        }
                  }              
           }
           insert leadShareList;
       }
       Catch(DmlException ex){          
        //Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(new String[] { 'vinoj.john@emc.com' });
        mail.setSubject('Leadshare Issue:');
        mail.setPlainTextBody('The exception cought while processing Leadshare the mail'+ex+' leadshare list:'+leadShareList);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       }
    }
    
/* @Method <This method is used to create the sharing access on Extension_Request__c for Queues
            based on Theater associated to Deal Reg>.
   @param <This is method is taking List of Extension_Request__c as Parameter>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    public void createExtensionShareForQueues(Map<Id,Extension_Request__c> newExtensionRequestMap,Map<Id,Extension_Request__c> oldExtensionRequestMap){
        Map<String,Set<Id>> extensionRequestQueueMap = new Map<String,Set<Id>>();
        Map<String,DealRegistration_CustomSetting__c>  data =  DealRegistration_CustomSetting__c.getall();
        String AmerExtensionRqstQueue = data.get('AmerExtensionRqstQueue').PSC_QueueId__c;
        String ApjExtensionRqstQueue = data.get('ApjExtensionRqstQueue').PSC_QueueId__c;
        String EmeaExtensionRqstQueue = data.get('EmeaExtensionRqstQueue').PSC_QueueId__c;
        List<Extension_Request__c>  extensionRequestList = new List<Extension_Request__c>();
        Set<Id> extensionRequestIds = new Set<Id>();       

        for(Extension_Request__c extensionRequest: newExtensionRequestMap.values()){
            if(extensionRequest.Extension_Request_Status__c=='Submitted' && 
            oldExtensionRequestMap.get(extensionRequest.id).Extension_Request_Status__c!='Submitted' && 
            extensionRequest.Deal_Registration__c!=null){
                extensionRequestIds.add(extensionRequest.id);
            }
        }
        if(extensionRequestIds.size()>0){
            extensionRequestList = [Select e.Deal_Registration__c, e.Deal_Registration__r.Id, e.Extension_Request_Status__c, 
                                    e.Id, e.Deal_Registration__r.DealReg_Theater__c
                                    from Extension_Request__c e 
                                    where id in: extensionRequestIds];
        }        
        for(Extension_Request__c extensionReqst: extensionRequestList){
            if(extensionReqst.Deal_Registration__r.DealReg_Theater__c == 'Americas'){
                if(extensionRequestQueueMap.containsKey(AmerExtensionRqstQueue)){
                    extensionRequestQueueMap.get(AmerExtensionRqstQueue).add(extensionReqst.id);
                }
                else{
                    extensionRequestQueueMap.put(AmerExtensionRqstQueue,new Set<Id>());
                    extensionRequestQueueMap.get(AmerExtensionRqstQueue).add(extensionReqst.id);
                }
            }
            else if(extensionReqst.Deal_Registration__r.DealReg_Theater__c == 'APJ'){
                if(extensionRequestQueueMap.containsKey(ApjExtensionRqstQueue)){
                    extensionRequestQueueMap.get(ApjExtensionRqstQueue).add(extensionReqst.id);
                }
                else{
                    extensionRequestQueueMap.put(ApjExtensionRqstQueue,new Set<Id>());
                    extensionRequestQueueMap.get(ApjExtensionRqstQueue).add(extensionReqst.id);
                }
            }
            else if(extensionReqst.Deal_Registration__r.DealReg_Theater__c == 'EMEA'){
                if(extensionRequestQueueMap.containsKey(EmeaExtensionRqstQueue)){
                    extensionRequestQueueMap.get(EmeaExtensionRqstQueue).add(extensionReqst.id);
                }
                else{
                    extensionRequestQueueMap.put(EmeaExtensionRqstQueue,new Set<Id>());
                    extensionRequestQueueMap.get(EmeaExtensionRqstQueue).add(extensionReqst.id);
                }
            }
        }
        if(extensionRequestQueueMap.values().size()>0){
            createExtensionRequestShare(extensionRequestQueueMap);
            
        }
    } 

/* @Method <This method is used to create the sharing access on Extension_Request for Queues>.
   @param <This is method is taking QueueId and Set of Extension_Request Id as Parameter from Map>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    public void createExtensionRequestShare(Map<String,Set<Id>> queueAndExtensionInfoMap){
        List<Extension_Request__Share> extensionReqstShareList = new List<Extension_Request__Share>();        
        for(String queueId :queueAndExtensionInfoMap.keySet()){
           if(queueAndExtensionInfoMap.containsKey(queueId)){
              for(String objExtensionId :queueAndExtensionInfoMap.get(queueId)){
                  extensionReqstShareList.add(new Extension_Request__Share(UserOrGroupId=queueId,AccessLevel='Edit',
                                                                            ParentId=objExtensionId));         
              }
           }              
        }
        insert extensionReqstShareList;
    } 
    

/* @Method <This method is used to populate expiration date based on Theater when a deal reg is approved>.
   @param <This is method is taking List of Lead Id as Parameter>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    public void autoPopulateExpirationDate(Map<Id,Lead> newLeadMap,Map<Id,Lead> oldLeadMap){
        if(IsExpDateChange){
            Map<String,DealRegistration_CustomSetting__c> extensionDateMap = DealRegistration_CustomSetting__c.getall();
            Double ExpirationDate = extensionDateMap.get('Expriation Date of America/Emea').Length_of_Extensions__c;
            Double ExpirationDateForAPJ = extensionDateMap.get('Expriation Date of APJ').Length_of_Extensions__c;
            Integer ExpirationDateValueForAPJ = ExpirationDateForAPJ.intValue();
            System.debug('ExpirationDate---->'+ExpirationDate);
            System.debug('Map size---->'+newLeadMap.values().size());         
            //Set<Id> approvedDealIdSet = new Set<Id>(); 
            for(Lead approvedDealReg: newLeadMap.values()){
                System.debug('DealReg_Deal_Registration_Status__c---->'+approvedDealReg.DealReg_Deal_Registration_Status__c); 
                if(approvedDealReg.DealReg_Deal_Registration_Status__c=='Approved' && oldLeadMap.get(approvedDealReg.id).DealReg_Deal_Registration_Status__c!='Approved'){
                    newLeadMap.get(approvedDealReg.Id).DealReg_PSC_Approval_Rejection_Date_Time__c = System.Now();
                    System.debug('approvedDealReg.DealReg_Theater__c---->'+approvedDealReg.DealReg_Theater__c);
                    System.debug('approvedDealReg.DealReg_Approval_Date__c---->'+approvedDealReg.DealReg_PSC_Approval_Rejection_Date_Time__c);
                    Map<String,Deal_Reg_Approval_Date_Check__c> submissiondates = Deal_Reg_Approval_Date_Check__c.getall();
                    //Added logic to handle the deal regs which are approved before and after Jan 1 2013
                    if(approvedDealReg.get('DealReg_Theater__c') != null){
                    	Date submissionDate = submissiondates.get('Deal Reg Approval Date').Approval_Date__c;
                        System.debug('Submission date is ---->'+submissionDate);
                        if(System.Today() < submissionDate){
                        	if(approvedDealReg.DealReg_Theater__c == 'Americas' ||
	                            approvedDealReg.DealReg_Theater__c == 'EMEA'){                     
	                            newLeadMap.get(approvedDealReg.Id).DealReg_Expiration_Date__c = System.Today() + ExpirationDate.intvalue();
                      			System.debug('Dealreg Exp date for Americas EMEA ---->'+newLeadMap.get(approvedDealReg.Id).DealReg_Expiration_Date__c);
	                        }
	                        else if(approvedDealReg.DealReg_Theater__c == 'APJ'){
	                        	//newLeadMap.get(approvedDealReg.Id).DealReg_Expiration_Date__c = calculateQuaterDate(3);
	                            //Changed By Arif(177387)
	                            newLeadMap.get(approvedDealReg.Id).DealReg_Expiration_Date__c = calculateQuaterDate(ExpirationDateValueForAPJ,approvedDealReg.DealReg_Expiration_Date__c);
	                            System.debug('Dealreg Exp date for APJ ---->'+newLeadMap.get(approvedDealReg.Id).DealReg_Expiration_Date__c);
	                        }
                        }else{
                        	newLeadMap.get(approvedDealReg.Id).DealReg_Expiration_Date__c = System.Today() + ExpirationDate.intvalue();
                        	System.debug('Dealreg Exp date for All regions ---->'+newLeadMap.get(approvedDealReg.Id).DealReg_Expiration_Date__c);
                        }               
                        System.debug('approvedDealReg.DealReg_Expiration_Date__c---->'+newLeadMap.get(approvedDealReg.Id).DealReg_Expiration_Date__c);
                    }   
                }
            }
            IsExpDateChange = false;
        }     
    }
    
/* @Method <This method is used to populate expiration date to next quarter for APJ>.
   @param <This is method is taking Integer noOfQuarter as Parameter>
   @return <Date> - <Date>
   @throws exception - <No Exception>
*/  
    public static Date calculateQuaterDate(Integer noOfQuarter,date ExpirationTime){
       Date dtTodayDate;
       //Changed By Arif(177387)
       Date dtExpirationDate;
       if(ExpirationTime == null){
            dtTodayDate = System.today();   
       }
       if(ExpirationTime != null){
            dtTodayDate = ExpirationTime;
       }        
       System.debug('dtTodayDate-->'+dtTodayDate);
       if(noOfQuarter>0){
            dtTodayDate = dtTodayDate.addMonths(noOfQuarter);
       }
       System.debug('dtTodayDate after-->'+dtTodayDate);
            
       if(dtTodayDate.month() ==1 || dtTodayDate.month() ==2 || dtTodayDate.month() ==3){
            dtExpirationDate = date.newinstance(dtTodayDate.year(), 3, 31);
       }else if(dtTodayDate.month() ==4 || dtTodayDate.month() ==5 || dtTodayDate.month() ==6){
            dtExpirationDate = date.newinstance(dtTodayDate.year(), 6, 30);
       }else if(dtTodayDate.month() ==7 || dtTodayDate.month() ==8 || dtTodayDate.month() ==9){
            dtExpirationDate = date.newinstance(dtTodayDate.year(), 9, 30);
       }else if(dtTodayDate.month() ==10 || dtTodayDate.month() ==11 || dtTodayDate.month() ==12){
            dtExpirationDate = date.newinstance(dtTodayDate.year(), 12, 31);
       }
            System.debug('dtExpirationDate-->'+dtExpirationDate);
        return dtExpirationDate;

    }

/* @Method <This method is used to calcuate "# of Extension Requests" and set 
            the Expiration date upon extension of a Deal Reg>.
   @param <This is method is taking List<Extension_Request__c> as Parameter>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    public static void extendExpirationDate(List<Extension_Request__c> extensionReqstList){
        isexecuted=true;    
        Map<Id,Id> extensionDealRegMap = new Map<Id,Id>();
        Map<Id,Id> extensionDealRegForAPJMap = new Map<Id,Id>();
        Map<Id,Id> extensionDealRegMapAllRegions = new Map<Id,Id>();
        Map<String,DealRegistration_CustomSetting__c> extensionDateMap = DealRegistration_CustomSetting__c.getall();
        Double ExtensionDate = extensionDateMap.get('Extension Date of America/Emea').Length_of_Extensions__c;
        Double ExtensionDateNew = extensionDateMap.get('Extension Date of America/Emea/APJ').Length_of_Extensions__c;
        Double ExtensionDateForAPJ = extensionDateMap.get('Extension Date of APJ').Length_of_Extensions__c;
        Integer ExtensionDateValueForAPJ = ExtensionDateForAPJ.intValue();              
		Map<String,Deal_Reg_Approval_Date_Check__c> approvalDates = Deal_Reg_Approval_Date_Check__c.getall();
       	Date approvalDate = approvalDates.get('Deal Reg Approval Date').Approval_Date__c;
        for(Extension_Request__c extensionReqst: extensionReqstList){
            if(extensionReqst.Deal_Registration__c!=null){
            	System.debug('Approval date is ---->'+approvalDate);
            	if(extensionReqst.Extension_Request_Status__c=='Approved'){	
            		if(extensionReqst.Deal_Registration__r.DealReg_PSC_Approval_Rejection_Date_Time__c < approvalDate && System.Today() < approvalDate){
                	    System.debug('extensionReqst.Deal_Registration__r.DealReg_Theater__c'+extensionReqst.Deal_Registration__r.DealReg_Theater__c);
	                   	if(extensionReqst.Deal_Registration__r.DealReg_Theater__c == 'Americas' ||
	                    	extensionReqst.Deal_Registration__r.DealReg_Theater__c == 'EMEA'){
	                        extensionDealRegMap.put(extensionReqst.id,extensionReqst.Deal_Registration__c);
	                    }
	                    if(extensionReqst.Deal_Registration__r.DealReg_Theater__c == 'APJ'){
	                        extensionDealRegForAPJMap.put(extensionReqst.id,extensionReqst.Deal_Registration__c);
	                    }
	                    System.debug('extensionDealRegForAPJMap size-->'+extensionDealRegForAPJMap.size());
                		System.debug('extensionReqst status-->'+extensionReqst.Extension_Request_Status__c);
	                    
	                }else{
	                	extensionDealRegMapAllRegions.put(extensionReqst.id,extensionReqst.Deal_Registration__c);
	                	System.debug('extensionDealRegForAPJMap size for All regions -->'+extensionDealRegMapAllRegions.size());
	                	System.debug('extensionReqst status for All regions-->'+extensionReqst.Extension_Request_Status__c);
	                }
            	}
                
            }    
        }
        if(extensionDealRegMap.Keyset().size()>0){
            List<Lead> dealRegsforExtension = [Select id,DealReg_of_Extension_Requests__c,DealReg_Expiration_Date__c,
                                                DealReg_Expiration_Date_changed_By_PSC__c
                                                from Lead 
                                                where id in: extensionDealRegMap.values()];
            for(Lead dealReg: dealRegsforExtension ){
                if(dealReg.DealReg_Expiration_Date__c!=null){
                	System.debug('AMER EMEA Length of extensions is ---->'+ExtensionDate.intvalue());
                    dealReg.DealReg_Expiration_Date__c = dealReg.DealReg_Expiration_Date__c+ExtensionDate.intvalue();
               }
               else{
                    dealReg.DealReg_Expiration_Date__c = System.today()+ExtensionDate.intvalue();
                    //dealReg.DealReg_Expiration_Date__c = ExtensionDate;                       
               }
               dealReg.DealReg_Expiration_Date_changed_By_PSC__c = true;
               System.debug('dealReg.DealReg_Expiration_Date__c---->'+dealReg.DealReg_Expiration_Date__c);
            }
            update dealRegsforExtension;
        }
        if(extensionDealRegForAPJMap.Keyset().size()>0){
            List<Lead> dealRegsforExtensionAPJ = [Select id,DealReg_of_Extension_Requests__c,DealReg_Expiration_Date__c,
                                                DealReg_Expiration_Date_changed_By_PSC__c
                                                from Lead 
                                                where id in: extensionDealRegForAPJMap.values()];
            for(Lead dealReg: dealRegsforExtensionAPJ ){
               //dealReg.DealReg_Expiration_Date__c = calculateQuaterDate(6);
               //Changed By Arif(177387)
               dealReg.DealReg_Expiration_Date__c = calculateQuaterDate(ExtensionDateValueForAPJ,dealReg.DealReg_Expiration_Date__c);
               dealReg.DealReg_Expiration_Date_changed_By_PSC__c = true;
               System.debug('dealReg.DealReg_Expiration_Date__c---->'+dealReg.DealReg_Expiration_Date__c);
               System.debug('dealReg.id---->'+dealReg.id);
            }
            update dealRegsforExtensionAPJ;
        }
        if(extensionDealRegMapAllRegions.Keyset().size()>0){
    		List<Lead> dealRegsforExtensionAllregions = [Select id,DealReg_of_Extension_Requests__c,DealReg_Expiration_Date__c,
                                        DealReg_Expiration_Date_changed_By_PSC__c
                                        from Lead 
                                        where id in: extensionDealRegMapAllRegions.values()];
    		for(Lead dealReg: dealRegsforExtensionAllregions ){
	        	if(dealReg.DealReg_Expiration_Date__c!=null){
	        		System.debug('All Regions Length of extensions is ---->'+ExtensionDateNew.intvalue());
		            dealReg.DealReg_Expiration_Date__c = dealReg.DealReg_Expiration_Date__c+ExtensionDateNew.intvalue();
		       	}else{
	            	dealReg.DealReg_Expiration_Date__c = System.today()+ExtensionDateNew.intvalue();
	            	//dealReg.DealReg_Expiration_Date__c = ExtensionDate;                       
	       		}
	       		dealReg.DealReg_Expiration_Date_changed_By_PSC__c = true;
	       		System.debug('dealReg.DealReg_Expiration_Date__c all regions ---->'+dealReg.DealReg_Expiration_Date__c);
    		}
    		update dealRegsforExtensionAllregions;
		}
    }

/* @Method <This method is used to calcuate "# of Extension Requests" and set 
            the Expiration date upon extension of a Deal Reg>.
   @param <This is method is taking List<Extension_Request__c> as Parameter>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/

    public static void calculateNOOfExtensions(List<Extension_Request__c> extensionReqstList){
        Map<Id,Id> noOfTimesExtendedDealRegMap = new Map<Id,Id>();
        for(Extension_Request__c extensionReqst: extensionReqstList){
            if(extensionReqst.Extension_Request_Status__c!='New' ){ 
                noOfTimesExtendedDealRegMap.put(extensionReqst.id,extensionReqst.Deal_Registration__c);
            }            
        }
        System.debug('noOfTimesExtendedDealRegMap size-->'+noOfTimesExtendedDealRegMap.keyset().size());
        if(noOfTimesExtendedDealRegMap.Keyset().size()>0){
        List<Lead> dealRegsforExtension = [Select l.DealReg_of_Extension_Requests__c, l.Id, l.DealReg_Deal_Registration_Status__c,
                                                   (Select Deal_Registration__c, Id From Extension_Requests__r 
                                                   where Extension_Request_Status__c!='New') // just keeping status not new
                                                   from Lead l
                                                   where id in: noOfTimesExtendedDealRegMap.values()];
          System.debug('dealRegsforExtension size---->'+dealRegsforExtension.size());
          for(Lead dealReg: dealRegsforExtension){
            if(dealReg.Extension_Requests__r.size()>0){             
              dealReg.DealReg_of_Extension_Requests__c=dealReg.Extension_Requests__r.size();
              System.debug('dealReg.DealReg_of_Extension_Requests__c-->'+dealReg.DealReg_of_Extension_Requests__c);
            }  
          } 
          try{
              update dealRegsforExtension;
          }catch(System.DmlException ex){
              string errorMessage = ex.getMessage();
              integer start = errorMessage.indexOf('FIELD_FILTER_VALIDATION_EXCEPTION');
              if(start != -1){
                  errorMessage = errorMessage.substring(start+35,errorMessage.indexOf(']')+1);
                  ex.setMessage(errorMessage);
              }     
          }
        }
    }  

/* @Method <This method is used to auto approve Extension_Request for Emea>.
   @param <This is method is taking list of Extension_Request as Parameter>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
   @future
   public static void autoApproveExtensionForAPjEMEA(Set<Id> setExtnId){
        Set<Id> extensionIdSet = new Set<Id>();
        List<Extension_Request__c>  extensionReqstForApproval = [Select e.Approved_By_EMEA_Field_Rep__c, e.Deal_Registration__c, e.Deal_Registration__r.Id, 
                               e.Deal_Registration__r.Related_Account__c, e.Extension_Request_Status__c, e.Id, e.Deal_Registration__r.DealReg_Theater__c,
                               e.Deal_Registration__r.Related_Account__r.Theater1__c,e.Deal_Registration__r.Related_Account__r.Grouping__c,
                               e.Deal_Registration__r.Related_Account__r.BillingCountry,e.Deal_Registration__r.Tier_2_Partner__r.Grouping__c,    
                               e.Deal_Registration__r.Tier_2_Partner__r.BillingCountry,e.Deal_Registration__r.Partner__r.Grouping__c, 
                               e.Deal_Registration__r.Partner__r.BillingCountry,e.Deal_Registration__r.DealReg_of_Extension_Requests__c
                               from Extension_Request__c e
                               where id in: setExtnId];
        List<ProcessInstanceWorkitem> lstPIWI = new List<ProcessInstanceWorkitem>();
        //Map<String, ProcessInstanceWorkitem> mapExtensionWithProcess = new Map<String, ProcessInstanceWorkitem>();
        Map<String,List<ProcessInstanceWorkitem>> mapExtensionWithProcess = new Map<String,List<ProcessInstanceWorkitem>>();
        List <EMCException> errors = new List <EMCException>();        
        for(Extension_Request__c extensionRequest : extensionReqstForApproval){
            System.debug('Extension_Request_Status__c-->'+extensionRequest.Extension_Request_Status__c);
            System.debug('Deal_Registration__c-->'+extensionRequest.Deal_Registration__c);
            System.debug('DealReg_Theater__c-->'+extensionRequest.Deal_Registration__r.DealReg_Theater__c);
            System.debug('DealReg_of_Extension_Requests__c-->'+extensionRequest.Deal_Registration__r.DealReg_of_Extension_Requests__c);
            if(extensionRequest.Extension_Request_Status__c=='Submitted' && 
            extensionRequest.Deal_Registration__c!=null && extensionRequest.Deal_Registration__r.DealReg_Theater__c!=null && 
            (extensionRequest.Deal_Registration__r.DealReg_Theater__c == 'EMEA' || 
            extensionRequest.Deal_Registration__r.DealReg_Theater__c == 'APJ') && 
            extensionRequest.Deal_Registration__r.DealReg_of_Extension_Requests__c<=1){
                extensionIdSet.add(extensionRequest.id);
            }
        }
        System.debug('extensionIdSet---->'+extensionIdSet.size());
        if(extensionIdSet.size()>0){
            lstPIWI = [Select p.Id, p.ProcessInstanceId, p.ProcessInstance.Status, 
                                                    p.ProcessInstance.TargetObjectId,OriginalActorId,ActorId 
                                                    from ProcessInstanceWorkitem p
                                                    where p.ProcessInstance.TargetObjectId in:extensionIdSet 
                                                    and ProcessInstance.Status='Pending'];
              System.debug('extensionIdSet---->'+lstPIWI.size());                                      
            for(ProcessInstanceWorkitem objPIWI: lstPIWI){
                if(mapExtensionWithProcess.containsKey(objPIWI.ProcessInstance.TargetObjectId)){
                    mapExtensionWithProcess.get(objPIWI.ProcessInstance.TargetObjectId).add(objPIWI);
                }
                else{
                    mapExtensionWithProcess.put(objPIWI.ProcessInstance.TargetObjectId,new List<ProcessInstanceWorkitem>());
                    mapExtensionWithProcess.get(objPIWI.ProcessInstance.TargetObjectId).add(objPIWI);
                }
                //mapExtensionWithProcess.put(objPIWI.ProcessInstance.TargetObjectId,objPIWI);
            }                                                                                                       
        }                     
        System.debug('mapExtensionWithProcess---->'+mapExtensionWithProcess);       
                     
        for(Extension_Request__c extensionRequest : extensionReqstForApproval){
            List<Approval.ProcessWorkitemRequest> lstReq = new List<Approval.ProcessWorkitemRequest>();                                                     
            if(extensionRequest.Deal_Registration__r.DealReg_of_Extension_Requests__c<=1){
                Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                //req2.setComments('Auto Approve Extension request.');
                req2.setAction('Approve');             
                // Use the ID from the newly created item to specify the item to be worked
                if(mapExtensionWithProcess.containsKey(extensionRequest.Id)){
                    if(mapExtensionWithProcess.get(extensionRequest.Id) != null && mapExtensionWithProcess.get(extensionRequest.Id).size() >0){
                        req2.setWorkitemId(mapExtensionWithProcess.get(extensionRequest.Id).get(0).Id); 
                    }                       
                }
               // WR-182932-IM7358588-Commented out else condtion.                
                /*else{
                    req2.setWorkitemId(lstPIWI.get(0).Id);
                }*/
                System.debug('req2.setWorkitemId-->'+req2.getWorkitemId());
                if(req2.getWorkitemId()!= Null){
                    Approval.ProcessResult result2 = Approval.process(req2);     
                    System.debug('result2-->'+result2);                                 
                }//End of if condtion -WorkitemId.
                else{
                    errors.add(new EMCException('UnProcessed ER- '+extensionRequest.Id, 'UNPROCESSED_APJEMEA_EXTENSION_REQUEST', new String [] {extensionRequest.Id}));
                }
                                
            }
              
        }

        // log upProcessed records.
          if (errors.size() > 0) { 
              EMC_UTILITY.logErrors(errors);  
      }
          
        Set<Id> setEmeaIds = new Set<Id>();
        for(Extension_Request__c extensionRequest : extensionReqstForApproval){                         
            if(extensionRequest.Extension_Request_Status__c=='Submitted' && extensionRequest.Deal_Registration__c!=null && 
                    extensionRequest.Deal_Registration__r.DealReg_Theater__c!=null && 
                    (extensionRequest.Deal_Registration__r.DealReg_Theater__c == 'EMEA') ){
                    setEmeaIds.add(extensionRequest.id);    
            }
        }
        if(setEmeaIds.size()>0){
            lstPIWI = [Select p.Id, p.ProcessInstanceId, p.ProcessInstance.Status, 
                                                        p.ProcessInstance.TargetObjectId,OriginalActorId,ActorId 
                                                        from ProcessInstanceWorkitem p
                                                        where p.ProcessInstance.TargetObjectId in:setEmeaIds 
                                                        and ProcessInstance.Status='Pending'
                                                        ];
            mapExtensionWithProcess.clear();
            if(lstPIWI.size()>0){
                for(ProcessInstanceWorkitem objPIWI: lstPIWI){
                        if(mapExtensionWithProcess.containsKey(objPIWI.ProcessInstance.TargetObjectId)){
                            mapExtensionWithProcess.get(objPIWI.ProcessInstance.TargetObjectId).add(objPIWI);
                        }
                        else{
                            mapExtensionWithProcess.put(objPIWI.ProcessInstance.TargetObjectId,new List<ProcessInstanceWorkitem>());
                            mapExtensionWithProcess.get(objPIWI.ProcessInstance.TargetObjectId).add(objPIWI);
                        }
                    }                                                       
                Map<String,DealRegistration_CustomSetting__c>  data =  DealRegistration_CustomSetting__c.getall();
                Id EmeaPSCDRQueue = data.get('EmeaPSCDRQueue').PSC_QueueId__c;                                            
                for(Extension_Request__c extensionRequest : extensionReqstForApproval){                         
                    if(extensionRequest.Extension_Request_Status__c=='Submitted' && extensionRequest.Deal_Registration__c!=null && 
                        extensionRequest.Deal_Registration__r.DealReg_Theater__c!=null && 
                        (extensionRequest.Deal_Registration__r.DealReg_Theater__c == 'EMEA') ){
                        Approval.ProcessWorkitemRequest req3 = new Approval.ProcessWorkitemRequest();
                        //req3.setComments('Auto Approve EMEA Extension request.');
                        req3.setAction('Approve');
                        if(mapExtensionWithProcess.containsKey(extensionRequest.Id)){
                            req3.setWorkitemId(mapExtensionWithProcess.get(extensionRequest.Id).get(0).Id);
                            Approval.ProcessResult result3 = Approval.process(req3); 
                        }    
                    }   
                } 
            }    
        }                
    } 
    
    public Lead leadObj;    

/* @Method <This method is used as getter Method for Reject Lead VF Page>.
   @param <void> - <Not taking anything>
   @return <Lead> - <Returning Lead Record>
   @throws exception - <No Exception>
*/ 
    public Lead getlead(){
        System.debug('LeaD----->'+leadObj.id);
        return leadObj;
    }
   
    ApexPages.StandardController stdController;

/* @Method <This is Standard Controller>.
   @throws exception - <No Exception>
*/
    public PRM_DEALREG_ApprovalRouting(ApexPages.StandardController controller) {
        stdController = controller;
        if(this.leadObj == null){
            this.leadObj = (Lead)controller.getRecord();
        }  
     }         

/* @Method <This is used to save Rejection Reason when a deal reg is rejected>.
   @param <void> - <Not taking anything>
   @return <PageReference> - <Returning to lead Record>
   @throws exception - <No Exception>
*/
     public PageReference SaveRejection(){ 
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c customSetting = DataValueMap.get('PSC User');
        String userProfile = Userinfo.getProfileId();
        String pscUser = customSetting.DataValue__c;
        String rejectDR = ApexPages.currentPage().getParameters().get('DealReg');
        if(rejectDR !=null && rejectDR !=''){
            Lead rejectDealReg = [Select id,DealReg_Theater__c,DealReg_PSC_Owner__c,DealReg_Deal_Registration_Status__c , External_Comments__c
                                    from lead 
                                    where id=: leadObj.id];
            if(rejectDealReg.DealReg_Deal_Registration_Status__c=='PSC Declined'){
                ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.Deal_Reg_is_already_Rejected);
                ApexPages.addMessage(msg1);         
            }
            else if(rejectDealReg.DealReg_Deal_Registration_Status__c!='Approved'){
                ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.You_cannot_accept_or_reject);
                ApexPages.addMessage(msg2);
            }
            else if(rejectDealReg.DealReg_PSC_Owner__c==null && rejectDealReg.DealReg_Theater__c!='EMEA'){
                ApexPages.Message msg3 = new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.Accept_Deal_Reg_Button_before_Approving_or_Rejecting);
                ApexPages.addMessage(msg3);
            }
            //Added By Arif WR 181055
            else if(!pscUser.contains(userProfile)){
                ApexPages.Message msg4 = new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.You_cannot_accept_or_reject);
                ApexPages.addMessage(msg4);
            }
            else{
                Savepoint sp;
                try{ 
                    sp = database.setSavepoint();  
                    Map<String,Schema.RecordTypeInfo> recordTypes = Lead.sObjectType.getDescribe().getRecordTypeInfosByName(); 
                    Id leadRecordTypeId = recordTypes.get('Deal Registration - Rejected').getRecordTypeId();  
                    leadObj.RecordTypeId = leadRecordTypeId;               
                    leadObj.DealReg_Deal_Registration_Status__c='PSC Declined';                    
                    update leadObj;                 
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    //req1.setComments('Submitting request for rejection.');
                    req1.setObjectId(rejectDealReg.id);
                    Approval.ProcessResult result = Approval.process(req1);
                    List<Id> newWorkItemIds = result.getNewWorkitemIds();
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setComments(leadObj.External_Comments__c);  
                    //req2.setComments(rejectDealReg.External_Comments__c);                    
                    req2.setAction('Reject');
                    req2.setWorkitemId(newWorkItemIds.get(0));
                    System.debug('req2 ----> ' + req2);
                    System.debug('rejectDealReg.External_Comments__c ----> ' + rejectDealReg.External_Comments__c);
                    Approval.ProcessResult result2 = Approval.process(req2);                    
                    return new PageReference ('/'+ leadObj.Id);
                }
                Catch(Exception ex){ 
                    Database.rollback(sp);
                    ApexPages.addMessages(ex);
                }
            }                                       
        }    
        else{  
            try{
                leadObj.DealReg_Deal_Registration_Status__c='PSC Declined';
                update leadObj;
                Lead rejectDealReg = [Select id,DealReg_Theater__c,External_Comments__c  from lead where id=: leadObj.id];
                ProcessInstanceWorkitem objPIWI = [Select p.Id, p.ProcessInstanceId, p.ProcessInstance.Status, 
                                                    p.ProcessInstance.TargetObjectId,OriginalActorId,ActorId 
                                                    from ProcessInstanceWorkitem p
                                                    where p.ProcessInstance.TargetObjectId =:leadObj.Id 
                                                    and ProcessInstance.Status='Pending'];                                                
                Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                req2.setComments(leadObj.External_Comments__c);
                //req2.setComments(rejectDealReg.External_Comments__c); 
                req2.setAction('Reject');
                req2.setWorkitemId(objPIWI.id);
                Approval.ProcessResult result2 = Approval.process(req2);            
                return new PageReference ('/'+ leadObj.Id);
            }
            catch(Exception ex){
                ApexPages.addMessages(ex);
            }  
        }
        return null;
     }    


/* @Method <This is used to create sharing access for the queues when the DR is Reassigned and theater is changed>.
   @param <List<Lead> dealRegList>
   @return <void> - <Returns Nothing>
   @throws exception - <No Exception>
*/    
    public void createLeadShareOnReAssignmentForQueues(Map<Id,Lead> newDealRegMap,Map<Id,Lead> oldDealRegMap){
        Map<String,Set<Id>> reassignedDRQueueMap = new Map<String,Set<Id>>();
        Map<String,DealRegistration_CustomSetting__c>  data =  DealRegistration_CustomSetting__c.getall();
        String AmerPSCDRQueue = data.get('AmerPSCDRQueue').PSC_QueueId__c;
        String ApjPSCDRQueue = data.get('ApjPSCDRQueue').PSC_QueueId__c;
        String EmeaPSCDRQueue = data.get('EmeaPSCDRQueue').PSC_QueueId__c; 

        for(Lead dealReg: newDealRegMap.values()){
            if(dealReg.DealReg_Theater__c!=oldDealRegMap.get(dealReg.id).DealReg_Theater__c){
                if(dealReg.DealReg_Theater__c == 'Americas'){
                  if(reassignedDRQueueMap.containsKey(AmerPSCDRQueue)){
                        reassignedDRQueueMap.get(AmerPSCDRQueue).add(dealReg.id);
                  }else{
                        reassignedDRQueueMap.put(AmerPSCDRQueue,new Set<Id>());
                        reassignedDRQueueMap.get(AmerPSCDRQueue).add(dealReg.id);
                  }
                }
                else if(dealReg.DealReg_Theater__c == 'APJ'){
                  if(reassignedDRQueueMap.containsKey(ApjPSCDRQueue)){
                        reassignedDRQueueMap.get(ApjPSCDRQueue).add(dealReg.id);
                  }else{
                        reassignedDRQueueMap.put(ApjPSCDRQueue,new Set<Id>());
                        reassignedDRQueueMap.get(ApjPSCDRQueue).add(dealReg.id);
                  }
                }
                else if(dealReg.DealReg_Theater__c == 'EMEA'){
                    if(reassignedDRQueueMap.containsKey(EmeaPSCDRQueue)){
                        reassignedDRQueueMap.get(EmeaPSCDRQueue).add(dealReg.id);
                  }else{
                        reassignedDRQueueMap.put(EmeaPSCDRQueue,new Set<Id>());
                        reassignedDRQueueMap.get(EmeaPSCDRQueue).add(dealReg.id);
                  }         

                }
            }
        }      
        if(reassignedDRQueueMap.size()>0){
            createLeadShare(reassignedDRQueueMap);
        }       

    } 


    
/*******************************Changes with user approach******************************/    


/* @Method <This is used to fetch Related Account Team Members based on teh User Role>.
   @param <List<Lead> emeaLeadsList>
   @return <Map<String,Set<Id>>> - <Returns Newly Created QueueName and Users associated to that Queue>
   @throws exception - <No Exception>
*/  
    public static Map<String, List<Id>> getRelatedAccountMembersForUsers(List<Lead> emeaLeadsList){
        Set<Id> accountIds = new Set<Id>();
        Map<String, Map<Id,AccountTeamMember>> mapRoleKeyAccountTeam = new Map<String, Map<Id,AccountTeamMember>>();        
        Map<String, List<Id>> mapAccuntTeamMember = new Map<String, List<Id>>();
        Map<String,CustomSettingDataValueMap__c>  dataValueMap =  CustomSettingDataValueMap__c.getall();
        String dealRegSetOfRoles = dataValueMap.get('dealRegSetOfRoles').DataValue__c;  
        System.Debug('emeaLeadsList--->' + emeaLeadsList.size()); 
        for(Lead emeaDealReg: emeaLeadsList){  
            System.Debug('emeaDealReg --->' + emeaDealReg);
            System.Debug('emeaDealReg Related_Account__c--->' + emeaDealReg.Related_Account__c);          
            if(emeaDealReg.Related_Account__c!=null ){                  
                System.Debug('emeaDealReg Related_Account__c--->' + emeaDealReg.Related_Account__c);               
                accountIds.add(emeaDealReg.Related_Account__c);                  
            }
        }    
        System.Debug('accountIds --->' + accountIds.size());     
        if(accountIds.size() >0){
            Map<Id, AccountTeamMember> mapAccountTeam = new Map<Id, AccountTeamMember>(
                                                            [Select AccountId, Id, TeamMemberRole, UserId , Account.Grouping__c
                                                            from AccountTeamMember
                                                            where AccountId in:accountIds and User.IsActive = true order by User.Name asc]);
            System.Debug('mapAccountTeam --->' + mapAccountTeam.size());                                                            
            if(mapAccountTeam.size() > 0){
                for(AccountTeamMember accTeam : mapAccountTeam.values()){                   
                    if(mapRoleKeyAccountTeam.containsKey(accTeam.AccountId)){ 
                        mapRoleKeyAccountTeam.get(accTeam.AccountId).put(accTeam.Id, accTeam);
                    }   
                    else{
                        mapRoleKeyAccountTeam.put(accTeam.AccountId, new Map<Id, AccountTeamMember>());
                        mapRoleKeyAccountTeam.get(accTeam.AccountId).put(accTeam.Id, accTeam);
                    }
                }
                
                for(Lead objLead :emeaLeadsList){
                    Boolean checkTeamMember = false;
                    if(objLead.Related_Account__c != null){
                        if(mapRoleKeyAccountTeam.containsKey(objLead.Related_Account__c)){
                            Map<Id, AccountTeamMember> mapTeamMember = mapRoleKeyAccountTeam.get(objLead.Related_Account__c);
                            if(mapTeamMember != null && mapTeamMember.size() >0){
                                for(String strRoles : dealRegSetOfRoles.split(';')){
                                    for(AccountTeamMember accTeam : mapTeamMember.values()){
                                        //if(!mapAccuntTeamMember.containskey(objLead.Id)){
                                        if(accTeam.TeamMemberRole == strRoles){
                                            if(mapAccuntTeamMember.containsKey(objLead.Id) ){ 
                                                System.Debug('strRoles ---> '+ strRoles);
                                                System.Debug('accTeam.TeamMemberRole ---> '+ accTeam.TeamMemberRole);
                                                //if(accTeam.TeamMemberRole == strRoles){
                                                    /*mapAccuntTeamMember.put(objLead.Id, new Set<Id>());                                     
                                                    mapAccuntTeamMember.get(objLead.Id).add(accTeam.UserId);
                                                    System.Debug('mapAccuntTeamMember --->' + mapAccuntTeamMember);
                                                    checkTeamMember = true;
                                                    break;*/
                                                    mapAccuntTeamMember.get(objLead.Id).add(accTeam.UserId);                                                
                                                //}                                           
                                            }  
                                            else{
                                                mapAccuntTeamMember.put(objLead.Id, new List<Id>());
                                                mapAccuntTeamMember.get(objLead.Id).add(accTeam.UserId);
                                            }
                                        }
                                                                                 
                                    }
                                    /*if(checkTeamMember){
                                        break;
                                    }*/
                                }   
                            }                               
                        }
                    }
                    
                }
            }                                                       
        }       
        System.debug('mapAccuntTeamMember----> ' + mapAccuntTeamMember); 
        return mapAccuntTeamMember;
    }
     
/* @Method <This is used to update Initial Approver to queue created of Field Reps and Direct Reps
            for EMEA Deal Reg>.
   @param <void> - <Set<Id> setNonQueueLead, Set<Id> setQueueLead, Set<String> setQueuesName>
   @return <void> - <Not returning anything>
   @throws exception - <No Exception>
*/  
    
    public static void updateApproverForUser(Map<String,Set<Id>> fieldRepsMap){
        Map<String,DealRegistration_CustomSetting__c>  data =  DealRegistration_CustomSetting__c.getall();
        String EmeaPSCDRQueue = data.get('EmeaPSCDRQueue').PSC_QueueId__c;      
                
        List<ProcessInstanceWorkitem> lstProcessIWI = [Select ActorId, Id, OriginalActorId, ProcessInstanceId, ProcessInstance.TargetObjectId 
                                                        from ProcessInstanceWorkitem 
                                                        where ProcessInstance.TargetObjectId in: fieldRepsMap.keySet()];                  
        System.debug('lstProcessIWI-->'+lstProcessIWI);        
         
        List<ProcessInstanceWorkitem> emeaProcessListUpdate = new List<ProcessInstanceWorkitem>(); 
        List<ProcessInstanceWorkitem> emeaProcessListNew = new List<ProcessInstanceWorkitem>();
        List<ProcessInstanceWorkitem> emeaProcessListDelete = new List<ProcessInstanceWorkitem>();
        Map<Id, List<ProcessInstanceWorkitem>> mapLeadProcess = new map<Id, List<ProcessInstanceWorkitem>>();
       // List<PRM_DealReg_EMEAProcessItem__c> emeaProcessList = new List<PRM_DealReg_EMEAProcessItem__c>();
                                                                 
        if(lstProcessIWI != null && lstProcessIWI.size() > 0){
            for(ProcessInstanceWorkitem objPIWI: lstProcessIWI){
                 if(mapLeadProcess.containskey(objPIWI.ProcessInstance.TargetObjectId)){   
                        mapLeadProcess.get( objPIWI.ProcessInstance.TargetObjectId).add(objPIWI); 
                  } 
                  else{ 
                        mapLeadProcess.put(objPIWI.ProcessInstance.TargetObjectId, new List<ProcessInstanceWorkitem>());  
                        mapLeadProcess.get(objPIWI.ProcessInstance.TargetObjectId).add(objPIWI); 
                  } 
            }
            Set<Id> setPWIT = new Set<Id>();
            for(String strLead : fieldRepsMap.keySet()){
                if(mapLeadProcess.containsKey(strLead)){
                    emeaProcessListUpdate = mapLeadProcess.get(strLead);
                    System.debug('emeaProcessListUpdate-->'+ emeaProcessListUpdate);
                    Set<Id> fieldRepsSet = fieldRepsMap.get(strLead);
                    Integer i=0;
                    setPWIT.clear();
                    if(fieldRepsSet.size() >0){
                        for(Id strRepIds: fieldRepsMap.get(strLead)){
                            System.debug('fieldRepsMap.get(strLead)-->'+ fieldRepsMap.get(strLead));
                            if(emeaProcessListUpdate.size() > i){
                                ProcessInstanceWorkitem objPIWI = emeaProcessListUpdate.get(i);
                                System.debug('objPIWI-->'+ objPIWI);
                                objPIWI.ActorId = strRepIds;
                                if(! setPWIT.contains(objPIWI.Id)){
                                    emeaProcessListNew.add(objPIWI);
                                    setPWIT.add(objPIWI.Id) ;
                                   // emeaProcessList.add(new PRM_DealReg_EMEAProcessItem__c(DealReg_ActorId__c= strRepIds,
                                                      //  DealReg_ProcessId__c = objPIWI.Id));
                                }    
                            }                                           
                            i++;                                                                        
                        }
                    }
                    
                    for(ProcessInstanceWorkitem objPIWI :emeaProcessListUpdate){
                        if(! setPWIT.contains(objPIWI.Id)){
                            emeaProcessListDelete.add(objPIWI);
                        }                        
                    }                    
                }
            }
            System.debug('emeaProcessListUpdate-->'+ emeaProcessListUpdate);
            System.debug('emeaProcessListDelete-->'+ emeaProcessListDelete);
            //System.debug('emeaProcessList-->'+ emeaProcessList);
            if(userinfo.getUserType() == 'PowerPartner' || userinfo.getUserType() =='Guest'){ 
               // Database.insert (emeaProcessList, false);
            }else{
                Database.update(emeaProcessListUpdate, false);
                Database.delete (emeaProcessListDelete, false);
            }             
        }
    } 
    
    
/* @Method <This is used to fetch Related Account Team Members based on teh User Role>.
   @param <List<Extension_Request__c> emeaExtensionList>
   @return <Map<String,Set<Id>>> - <Returns Newly Created QueueName and Users associated to that Queue>
   @throws exception - <No Exception>
*/ 
    
    public static Map<String, List<Id>> getRelatedAccountMembersForExtensionForUsers(List<Extension_Request__c> emeaExtensionList){
        Set<Id> accountIds = new Set<Id>();
        Map<String, Map<Id,AccountTeamMember>> mapRoleKeyAccountTeam = new Map<String, Map<Id,AccountTeamMember>>();        
        Map<String, List<Id>> mapAccountTeamMember = new Map<String, List<Id>>();
        Map<String,CustomSettingDataValueMap__c>  dataValueMap =  CustomSettingDataValueMap__c.getall();
        String dealRegSetOfRoles = dataValueMap.get('dealRegSetOfRoles').DataValue__c;
         
        for(Extension_Request__c emeaExtensionReqst: emeaExtensionList){            
            if(emeaExtensionReqst.Deal_Registration__r.Related_Account__c!=null ){              
                accountIds.add(emeaExtensionReqst.Deal_Registration__r.Related_Account__c);                  
            }
        }       
        if(accountIds.size() >0){
            Map<Id, AccountTeamMember> mapAccountTeam = new Map<Id, AccountTeamMember>(
                                                            [Select AccountId, Id, TeamMemberRole, UserId , Account.Grouping__c
                                                            from AccountTeamMember
                                                            where AccountId in:accountIds and User.isActive = true order by User.name asc]);
            if(mapAccountTeam.size() > 0){
                for(AccountTeamMember accTeam : mapAccountTeam.values()){                   
                    if(mapRoleKeyAccountTeam.containsKey(accTeam.AccountId)){ 
                        mapRoleKeyAccountTeam.get(accTeam.AccountId).put(accTeam.Id, accTeam);
                    }   
                    else{
                        mapRoleKeyAccountTeam.put(accTeam.AccountId, new Map<Id, AccountTeamMember>());
                        mapRoleKeyAccountTeam.get(accTeam.AccountId).put(accTeam.Id, accTeam);
                    }
                }        
                for(Extension_Request__c objExtension :emeaExtensionList){
                    //Boolean checkTeamMember = false;
                    if(objExtension.Deal_Registration__c != null && objExtension.Deal_Registration__r.Related_Account__c != null){
                        if(mapRoleKeyAccountTeam.containsKey(objExtension.Deal_Registration__r.Related_Account__c)){
                            Map<Id, AccountTeamMember> mapTeamMember = mapRoleKeyAccountTeam.get(objExtension.Deal_Registration__r.Related_Account__c);
                            if(mapTeamMember != null && mapTeamMember.size() >0){
                                for(String strRoles : dealRegSetOfRoles.split(';')){
                                    for(AccountTeamMember accTeam : mapTeamMember.values()){
                                    //if(!mapAccountTeamMember.containskey(objExtension.Deal_Registration__c)){
                                            System.Debug('strRoles ---> '+ strRoles);
                                            System.Debug('accTeam.TeamMemberRole ---> '+ accTeam.TeamMemberRole);
                                            if(accTeam.TeamMemberRole == strRoles){
                                                if(mapAccountTeamMember.containsKey(objExtension.Id) ){
                                                    //mapAccountTeamMember.put( objExtension.id, new Set<Id>());                                     
                                                    mapAccountTeamMember.get(objExtension.id).add(accTeam.UserId);
                                                    System.Debug('mapAccountTeamMember --->' + mapAccountTeamMember);
                                                    //checkTeamMember = true;
                                                    //break;
                                                }  
                                                else{
                                                    mapAccountTeamMember.put(objExtension.Id, new List<Id>());
                                                    mapAccountTeamMember.get(objExtension.Id).add(accTeam.UserId);
                                                }                                         
                                            }                                       
                                        }
                                    /*if(checkTeamMember){
                                        break;
                                    }*/
                                }   
                            }                               
                        }
                    }                    
                } 
            }                                                       
        }       
        return mapAccountTeamMember;
    }
    
    

    /* @Method <This is used to get top limited Field Reps based on role order >.
       @param Map<String,List<Id>> fieldRepsMap, Map<String,List<Id>> accountTeamMemMap, Integer DRRepsLimit>
       @return <Map<String,Set<Id>>> - <Returns Newly Created QueueName and Users associated to that Queue>
       @throws exception - <No Exception>
    */    
     public static Map<String,Set<Id>> getLimitedUserFromFieldAndDirectRep(Map<String,List<Id>> fieldRepsMap, Map<String,List<Id>> accountTeamMemMap, Integer DRRepsLimit){
        Map<String,Set<Id>> fieldRepsMapLimited = new Map<String,Set<Id>>();        
        if(fieldRepsMap.size() >0){
            for(String strFieldRepQueueName : fieldRepsMap.Keyset()){
                for(Id userId : fieldRepsMap.get(strFieldRepQueueName)){                     
                    if(fieldRepsMapLimited.containsKey(strFieldRepQueueName)){
                        if(fieldRepsMapLimited.get(strFieldRepQueueName).Size() < DRRepsLimit){ 
                            fieldRepsMapLimited.get(strFieldRepQueueName).add(userId);
                        }                       
                    }else{
                        fieldRepsMapLimited.put(strFieldRepQueueName , new Set<Id>());
                        fieldRepsMapLimited.get(strFieldRepQueueName).add(userId);
                    }
                                            
                }
            }
        }
        if(accountTeamMemMap.size()>0){
            for(String strAccountMemQueueName : accountTeamMemMap.keySet()){ 
                if(fieldRepsMapLimited.size() >0){
                    for(String strFieldRepQueueName : fieldRepsMapLimited.Keyset()){
                        if(strFieldRepQueueName.contains(strAccountMemQueueName)){
                            for(Id fieldRepId : accountTeamMemMap.get(strAccountMemQueueName)){
                                if(fieldRepsMapLimited.get(strFieldRepQueueName).Size() < DRRepsLimit){                         
                                    fieldRepsMapLimited.get(strFieldRepQueueName).add(fieldRepId);
                                }
                            }                        
                        }
                        else{
                            fieldRepsMapLimited.put(strAccountMemQueueName , new Set<Id>());
                            for(Id fieldRepId : accountTeamMemMap.get(strAccountMemQueueName)){
                                if(fieldRepsMapLimited.get(strFieldRepQueueName).Size() < DRRepsLimit){                         
                                    fieldRepsMapLimited.get(strFieldRepQueueName).add(fieldRepId);
                                }
                            }                        
                        }                       
                    } 
                }else{                                      
                    for(Id fieldRepId : accountTeamMemMap.get(strAccountMemQueueName)){ 
                        if(fieldRepsMapLimited.containsKey(strAccountMemQueueName)){
                            if(fieldRepsMapLimited.get(strAccountMemQueueName).Size() < DRRepsLimit){                           
                                fieldRepsMapLimited.get(strAccountMemQueueName).add(fieldRepId);
                            }
                        }else{
                            fieldRepsMapLimited.put(strAccountMemQueueName , new Set<Id>());
                            fieldRepsMapLimited.get(strAccountMemQueueName).add(fieldRepId);
                        } 
                    }                                   
                }                  
            }
        }
        System.debug('Final fieldRepsMapLimited-->'+fieldRepsMapLimited); 
        return fieldRepsMapLimited;
     }
    

/* @Method <This is used to update field on DR for auto approval based on business hours>.
   @param <void> - <No Parameter>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/

    public static void updateSLAFieldRepExpirationDateForDR(){
        String ScheduleTime = String.valueOfGmt(DateTime.Now().addMinutes(-5));
        ScheduleTime  = ScheduleTime.replace(' ', 'T');
        ScheduleTime = ScheduleTime +'.000Z';
        String ScheduleNowTime = String.valueOfGmt(DateTime.Now());
        ScheduleNowTime  = ScheduleNowTime.replace(' ', 'T');
        ScheduleNowTime = ScheduleNowTime +'.000Z';
        String QueryForDR;
        String Theater = 'EMEA';
        String ApprovalStatus = 'Submitted By Field Rep';
        String SlaFlag = 'Yes';
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        Integer batchSize = 20;
        try
        {            
            batchSize  = Integer.valueOf(DataValueMap.get('DealRegEMEA_DRSLA_BatchSize').DataValue__c);
        }
        catch(Exception e)
        {
            batchSize = 20;
        }        
        QueryForDR = 'Select id,DealReg_Approved_By_Field_Rep__c,DealReg_Field_SLA_Expire_on__c,DealReg_Theater__c,Approval_Status__c '+ 
                       'from Lead where (DealReg_Field_SLA_Expired__c =:SlaFlag OR (DealReg_Field_SLA_Expire_on__c >= ' + ScheduleTime + 
                       ' and DealReg_Field_SLA_Expire_on__c  <=' + ScheduleNowTime + ' )) and DealReg_Theater__c = : Theater' +
                       ' and Approval_Status__c = :ApprovalStatus limit '+ batchSize;
                       
        List<Lead> DealRegsForFieldRepApproval = database.query(QueryForDR);                                                                 
        if(DealRegsForFieldRepApproval.size()>0){
            for(Lead dealReg: DealRegsForFieldRepApproval){
                dealReg.DealReg_Approved_By_Field_Rep__c = true;
            }
            //update DealRegsForFieldRepApproval;
            Database.Saveresult[] resultsDR = database.update(DealRegsForFieldRepApproval,false);
            System.debug('resultsDR ------->' + resultsDR);
        }                                            
    }  

/* @Method <This is used to update field on ER for auto approval based on business hours>.
   @param <void> - <No Parameter>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    
    public static void updateSLAFieldRepExpirationDateForER(){
        String ScheduleTime = String.valueOfGmt(DateTime.Now().addMinutes(-5));
        ScheduleTime  = ScheduleTime.replace(' ', 'T');
        ScheduleTime = ScheduleTime +'.000Z';
        String ScheduleNowTime = String.valueOfGmt(DateTime.Now());
        ScheduleNowTime  = ScheduleNowTime.replace(' ', 'T');
        ScheduleNowTime = ScheduleNowTime +'.000Z';
        String QueryForER;
        String Theater = 'EMEA';
        String ApprovalStatus =  'Submitted By Field Rep';
        String SlaFlag = 'Yes';
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        Integer batchSize = 20;
        try
        {            
            batchSize  = Integer.valueOf(DataValueMap.get('DealRegEMEA_ER_SLA_BatchSize').DataValue__c);
        }
        catch(Exception e)
        {
            batchSize = 20;
        }
        
        QueryForER = 'Select id,Approved_By_EMEA_Field_Rep__c,DealReg_Field_SLA_Expire_on__c,DealReg_Theater__c,Approval_Status__c,Field_SLA_Expired__c,Deal_Registration__r.DealReg_of_Extension_Requests__c '+ 
                'from Extension_Request__c where (Field_SLA_Expired__c =:SlaFlag OR (DealReg_Field_SLA_Expire_on__c >= ' + ScheduleTime + 
                       ' and DealReg_Field_SLA_Expire_on__c  <=' + ScheduleNowTime + ' )) and DealReg_Theater__c = : Theater' +
                 ' and Deal_Registration__r.DealReg_of_Extension_Requests__c>1' + ' and Approval_Status__c = :ApprovalStatus limit ' + batchSize;
        List<Extension_Request__c> extensionsForFieldRepApproval = database.query(QueryForER);                                                               
        if(extensionsForFieldRepApproval.size()>0){
            for(Extension_Request__c extension: extensionsForFieldRepApproval){
                extension.Approved_By_EMEA_Field_Rep__c = true;
            }
            //update extensionsForFieldRepApproval;
            Database.Saveresult[] resultsER =  database.update(extensionsForFieldRepApproval,false);
            System.debug('resultsER ------->' + resultsER);
        }
    }
    
/* @Method <This is used to fetch DR Routing and Field Reps based on Grouping and Country>.
   @param <Map<Id, List<Registration_Product__c>>, List<Lead>>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/     
    public static void addErrorOnRecords(Database.Saveresult[] arrResult, List<Lead> dealRegsWithProducts,Map<Id, List<Registration_Product__c>> leadWithProductsMap ){
        for (integer i = 0; i < arrResult.size(); i++) {
            Database.SaveResult objResult = arrResult[i];
            System.debug('+++ objResult--->'+ objResult);
            if (!objResult.isSuccess()) {
                // if the particular record did not get deleted, we log the data error 
                String strErrorMessage = '';
                for (Database.Error err : objResult.getErrors()) {
                    strErrorMessage += err.getMessage();
                    break;
                }
                            
                if(strErrorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                    strErrorMessage = strErrorMessage.substring(strErrorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 35);
                }              
                if(strErrorMessage.endsWith(': []')){
                    strErrorMessage = strErrorMessage.substring(0, strErrorMessage.length() -4);
                }
                if(leadWithProductsMap.containsKey(dealRegsWithProducts.get(i).Id)){
                    List<Registration_Product__c> extensionsReqList = leadWithProductsMap.get(dealRegsWithProducts.get(i).Id);
                    for(Registration_Product__c objExtn: extensionsReqList){
                        objExtn.addError(strErrorMessage);
                    }
                }                
            }
        }
        
    } 
  /* @Method <This method is used to update Approved DRs asynchronously in order to break the context of Approval Process>.
   @param <This method is taking set<Id> of Leads from LeadAfterUpdate Trigger>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
  */   
    @future
    public static void updateApprovedDeal(Set<Id> setDeal){
        List<Lead> lstLead = [Select Id,Is_Extension_Request_Not_Submitted__c,Name, DealReg_Deal_Registration_Status__c, DealReg_Comments__c, Related_Account__c, Related_Account__r.Theater1__c,
                        Related_Account__r.Grouping__c, Related_Account__r.BillingCountry,DealReg_Approved_By_Field_Rep__c,
                        Tier_2_Partner__r.Grouping__c, Tier_2_Partner__r.BillingCountry,DealReg_Deal_Registration__c,
                        Partner__r.Grouping__c, Partner__r.BillingCountry,DealReg_Theater__c,Approval_Status__c,DealReg_PSC_Owner__c,
                        
                        (Select ProcessInstance.TargetObjectId, SystemModstamp, StepStatus, ProcessInstanceId, OriginalActorId, Id, 
                        CreatedDate, CreatedById, Comments, ActorId FROM ProcessSteps where StepStatus='Approved' Order By CreatedDate Desc limit 1)
                        
                        From Lead
                        where id in: setDeal];
        for(Lead objLead : lstLead){
            //Code added on 21st Feb,2012 to prevent exception for List has no rows for assignment to SObject
            if(objLead.ProcessSteps.size()>0)
            {
                ProcessInstanceHistory  objPIH = objLead.ProcessSteps;
                if(objPIH != null ){
                    objLead.DealReg_Comments__c = objPIH.Comments;
                    objLead.DealReg_Send_Approval_Notification__c = true;
                    if(!objLead.Is_Extension_Request_Not_Submitted__c)
                        objLead.Is_Extension_Request_Not_Submitted__c = true;
                } 
            }               
        }                
        update lstLead;
                                         
   }  
/* @Method <This method is used to calculate the difference between first submission and first App/Rej>.
   @param <This method is taking list<lead> LeadBeforeUpdate Trigger>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
  */         
    //Added By Arif WR 178752
   public void populateDiffOfOriginalAppRejAndSub(list<Lead> lstLead){
        for(Lead lead: lstLead){
            if(lead.Original_Approval_Rejection_Date_Time__c == null){
                lead.Original_Approval_Rejection_Date_Time__c = System.Now();
                //IM7560008
                if(lead.Original_Submission_Time__c != null){
                    Double intDiffOfSubAndAppRejInMiliSecond = lead.Original_Approval_Rejection_Date_Time__c.getTime()
                                                             - lead.Original_Submission_Time__c.getTime();
                    //lead.DR_Submitted_to_Approved_Declined__c = ((intDiffOfSubAndAppRejInMiliSecond*0.001)*0.0166666667)*0.0166666667;
                    lead.DR_Submitted_to_Approved_Declined__c = (intDiffOfSubAndAppRejInMiliSecond*0.000000277777778).round(System.RoundingMode.CEILING);
                } 
            }            
        }
   }
           
}