/*========================================================================================================================================================+

 |  HISTORY  |                                                                            

 |  DATE          DEVELOPER           WR      DESCRIPTION                                   

 |  ====          =========           ==      =========== 

 |  5/17/2011     Shalabh Sharma            This class is used to populate fields on Deal Registration.   
    7/6/2011      Ashwini Gowda             Introduced methods populateOpptyOwnerOnLead() and      
 |                                          populateChannelManagerOnLead() for sending notifications 
    1/7/2011      Ashwini Gowda             Added logic to send notifications when DR or ER is approved or
 |                                          Rejected by Field Rep/Direct Rep to rest of Reps.  
    14/07/2011    Ashwini Gowda             Updated for ReAssignment and added a fix for recurrsive call.
 |  27/07/2011    Anand Sharma              Updated populatedTheaterOnLead method to handle long Country name    
 |  09/08/2011    Ashwini Gowda             Updated To display current date time in template when Field Reps
                                            or Direct Reps Approves or Rejects any DR or ER.
 |  21/09/2011    Anil Sure                 Lead Opportunity mapping    
 |  22/09/2011    Anirudh Singh             Updated code to populate Account Category field on Deal Reg
 |                                          by inoking updateRelatedAccountFieldsOnDR method from LeadAccept Trigger 
 |  14/10/2011    Arif(177289)              Created method 'updateDealRegExpirationFlag'     
 |  28/10/2011    Prasad     WR#179347      Remove 20 deal reg fields and stamp Related Deal reg on opportunity
 |  01/11/2011    Suman B    IM7262561      Added logic in setRelatedAccount() and setRelatedAccountOnDealReg() methods to 
 |                                          populate DealReg Local Address from Related Account based on PartyNumber.
 |  04/11/2011    Suman B    IM7290735      Populating the CompanyLocal field with Related Account's NameLocal.
 |  10/11/2011    Suman B    IM7312572      To override the local address fields with new related Account Address on DR.
 |  15/11/2011    Suman B    IM7263083      Modified the logical check for updating the DR's related Account based on the Track
 |                                          Party Number if the PartyNumber changed on DR irrespective of old value. 
 |  15/11/2011    Arif Sheikh WR#178758     Updated logic to set Non_Distributor_Direct_Reseller_Partner__c flag if Partner Type is set.  
 |  16 Dec 2011   Arif                      Updated 'updateDealRegExpirationFlag' method to replace 'IsExpired__c' field by Is_Extension_Request_Not_Submitted__c  
 |  23/12/2011    Accenture   WR#183062     Added logic in populateClusterOnAccount() method to set Cluster Value on Account if biilling Country is Populated. 
 |  26/12/2011    Accenture   WR#183070     Added logic in calculateNumberOfDealsforPartnerSE() method to set Count of Approved Deals for A Partner SE contact.  
    28 Dec 2011   Arif        WR 184320     Created a method populateFieldsOnERWhileCreation to populate Oppty Owner,Additional Contact Email Address etc on ER   
    20 Jan 2012   Arif        WR 184320     Created a method setCommentsOnRejectedER for populating comment field on ER on rejection.  
    7 Feb 2012    Arif         185856       Created a method setSubmissionORApprRejDate for populating Submission Date and Approval/Rejection Date
 |  19-Feb-12     Kaustav                       Fixed FIELD_CUSTOM_VALIDATION_EXCEPTION Issue         
    20 March 2012 Arif                      Commented call of method 'SendEmailToFieldReps' and 'SendEmailToFieldRepsForExtension'
    24 April 2012 Arif                      Commented for EMEA Decommission
    27 April 2012 Arif                      Deleted Codes for EMEA Decommission
    30 April 2012 Arif                      Added IsRejected field
    18 Sept  2012 Sheriff                   Changing calculateNumberOfDealsforPartnerSE to a future method
    22 Jan   2013 Sheriff    208571,206408  Changing the filed "comments" data type. 
     +===============================================================================================================================================================*/
public class PRM_DealReg_Operations {

  
  public static Boolean recordProcessed = false; 
  
  /* @Method <This method execute is used to check the Deal Registration chechbox on Lead>
  @param <This method takes List<Lead> and Boolean as parameter>
  @return <void> - <The method is not returning anything>
  @throws exception - <No Exception>
  */
    public void markDealReg(List<Lead> lstLeads,boolean updateLeads){
        Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall(); 
        //List<CustomSettingDataValueMap__c> lstDealRegRecordTypes = new List<CustomSettingDataValueMap__c>();        
        CustomSettingDataValueMap__c DealRegRecordTypes = (mapCustomSettingDataValueMap.get('DealRegistration'));           
        String strRecType = DealRegRecordTypes.DataValue__c;
        system.debug('list of record types--->'+DealRegRecordTypes); 
            for(Lead leadRecord: lstLeads){
            System.debug('IfCondition check-->' + strRecType.indexof(leadRecord.RecordTypeId));             
                   if(strRecType.indexof(leadRecord.RecordTypeId,0)!= -1){
                       leadRecord.DealReg_Deal_Registration__c = true;
                   }
                   else{
                       leadRecord.DealReg_Deal_Registration__c = false;    
                   }
            }
    }
/* @Method <This method execute is used to check the Linked to Deal Reg chechbox on Opportunity>
@param <This method takes List<Lead> and Boolean as parameter>
@return <void> - <The method is not returning anything>
@throws exception - <No Exception>
*/ 
    public void linktoDealReg(Map<Id,Lead> mapNewLeads,Map<Id,Lead> mapOldLeads,boolean updateOpportunities){
         Set<Id> setNewOpptyId= new Set<Id>();
         Set<Id> setOldOpptyId= new Set<Id>();
         List<Opportunity> lstOppty = new List<Opportunity>();
         Map<Id,Lead> mapLeadWithOpptyId = new Map<Id,Lead>();
         
         if (mapOldLeads==null){
             mapOldLeads= new Map<Id,Lead>();
         }
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c DealrecordType = DataValueMap.get('DealRegistration');
        String strDealrecordType = DealrecordType.DataValue__c;
        
        for(Lead leadRecord: mapNewLeads.values()){ 
            String strLeadRecordType = leadRecord.RecordTypeId;
            if(strLeadRecordType !=null && strLeadRecordType !='' && strLeadRecordType.length() >15){
                strLeadRecordType= strLeadRecordType.substring(0,15);
            }
            if(strDealrecordType.contains(strLeadRecordType) && leadRecord.Related_Opportunity__c != null ){  
                setNewOpptyId .add(leadRecord.Related_Opportunity__c);
                mapLeadWithOpptyId.put(leadRecord.Related_Opportunity__c,leadRecord);
                system.debug('Related Opportunities--->'+setNewOpptyId );
                
                //delink earlier opp
                if( mapOldLeads.get(leadRecord.Id)!=null && mapOldLeads.get(leadRecord.Id).Related_Opportunity__c!=null){
                    setOldOpptyId.add((mapOldLeads.get(leadRecord.Id)).Related_Opportunity__c);
                }
            }
            else if(strDealrecordType.contains(strLeadRecordType)&& leadRecord.Related_Opportunity__c == null){
              system.debug('MINEmapOldLeads'+mapOldLeads );
              system.debug('MINEleadRecord--->'+leadRecord );
                if(mapOldLeads.get(leadRecord.Id)!=null ){
                    setOldOpptyId.add((mapOldLeads.get(leadRecord.Id)).Related_Opportunity__c);
                }
                system.debug('Related Opportunities--->'+setOldOpptyId );
            }            
                                     
        }
         if(setNewOpptyId.size() >0 || setOldOpptyId.size()>0 ) {  
             lstOppty = [select id,Linked_to_Deal_Registration__c,Related_Deal_Registration__c from Opportunity where Id in: setNewOpptyId or Id in: setOldOpptyId ];   
             system.debug('list of oppty--->'+lstOppty);
             if(lstOppty!=null){
                 for(Opportunity opportunityRecord: lstOppty){
                     if(setOldOpptyId.contains(opportunityRecord.id)){
                         opportunityRecord.Linked_to_Deal_Registration__c = false;
                         opportunityRecord.Related_Deal_Registration__c=null;
                     }if(setNewOpptyId.contains(opportunityRecord.id)){
                         opportunityRecord.Linked_to_Deal_Registration__c = true;
                         opportunityRecord.Related_Deal_Registration__c=((Lead)mapLeadWithOpptyId.get(opportunityRecord.Id)).Id;
                     }                     
                 }
             }
         }
         
        
         try{
             if(updateOpportunities== true){
                 update lstOppty;   
             } 
         }
         catch(Exception ex){
             system.debug('exception--->'+ex);
             for(Lead leads: mapNewLeads.values()){
                String strErrorMessage = 'Error : '+ ex.getMessage();   
                System.debug('strErrorMessage-->'+strErrorMessage);             
                if(strErrorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                    strErrorMessage = strErrorMessage.substring(strErrorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 35);
                    System.debug('strErrorMessage 22-->'+strErrorMessage);   
                }      
                leads.addError(strErrorMessage);
             }
         }       
    }
/* @Method <This method execute is used to populate partner judgement fields on Opportunity>
@Assumption <Two leads are never related to same opportunity>
@param <This method takes List<Lead> and Boolean as parameter>
@return <void> - <The method is not returning anything>
@throws exception - <No Exception>
*/ 
    public void populatePartnerJudgement(Map<Id,Lead> mapLeads, boolean updateOpportunities){
        Map<Id,Id> mapLeadOpportunity = new Map<Id,Id>();
        system.debug('map of lead---'+mapLeads);
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c DealrecordType = DataValueMap.get('DealRegistration');
        String strDealrecordType = DealrecordType.DataValue__c;
        
        for(Lead leadRecord: mapLeads.values()){
            String strLeadRecordType = leadRecord.RecordTypeId;
            if(strLeadRecordType !=null && strLeadRecordType !='' && strLeadRecordType.length() >15){
                strLeadRecordType= strLeadRecordType.substring(0,15);
            }
            system.debug('condition check---'+strDealrecordType.contains(strLeadRecordType));
            if(strDealrecordType.contains(strLeadRecordType)){  
                mapLeadOpportunity.put(leadRecord.Related_Opportunity__c,leadRecord.Id); 
                system.debug('lead---'+mapLeadOpportunity.values()); 
                system.debug('opportunity---'+mapLeadOpportunity.keyset());  
            }
             
        }
        system.debug('opportunity and lead---'+mapLeadOpportunity.keyset());
       /*  if(mapLeadOpportunity.keyset()!=null ){
            Map<Id,Opportunity> mapOpportunity = new Map<ID,Opportunity>([select DealReg_Partner_Expected_Close_Date__c,DealReg_Partner_Notes__c,DealReg_Partner_Probability__c,DealReg_Partner_Deal_Value_Amount_deal__c from Opportunity where Id in : mapLeadOpportunity.keyset()]);
            system.debug('opportunity fields---'+mapOpportunity);
            for(Opportunity opportunityRecord: mapOpportunity.values()){
               opportunityRecord.DealReg_Partner_Expected_Close_Date__c = mapLeads.get(mapLeadOpportunity.get(opportunityRecord.Id)).DealReg_Partner_Expected_Close_Date__c;
                //opportunityRecord.DealReg_Partner_Notes__c = mapLeads.get(mapLeadOpportunity.get(opportunityRecord.Id)).DealReg_Partner_Notes__c;
                opportunityRecord.DealReg_Partner_Probability__c = mapLeads.get(mapLeadOpportunity.get(opportunityRecord.Id)).DealReg_Partner_Probability__c;
                opportunityRecord.DealReg_Partner_Deal_Value_Amount_deal__c = mapLeads.get(mapLeadOpportunity.get(opportunityRecord.Id)).DealReg_Partner_Deal_Value_Amount_Deal_L__c;
                //Added by Anil
                opportunityRecord.Deal_Registration_Type__c = mapLeads.get(mapLeadOpportunity.get(opportunityRecord.Id)).DealReg_Deal_Registration_Type__c;
                opportunityRecord.Deal_Registration_Status__c = mapLeads.get(mapLeadOpportunity.get(opportunityRecord.Id)).DealReg_Deal_Registration_Status__c;
                opportunityRecord.Comments__c  = mapLeads.get(mapLeadOpportunity.get(opportunityRecord.Id)).DealReg_Comments__c;Related_Deal_Registration__r.
                opportunityRecord.Deal_Registration_Number__c = mapLds.get(mapLeadOpportunity.get(opportunityRecord.Id)).DealReg_Deal_Registration_Number__c;Related_Deal_Registration__r.
                opportunityRecord.Submission_Date__c= mapLeads.get(mapLeadOpportunity.get(opportunityRecord.Id)).DealReg_Submission_Date__c;
                opportunityRecord.PSC_Approval_Rejection_Date_Time__c= mapLeads.get(mapLeadOpportunity.get(opportunityRecord.Id)).DealReg_PSC_Approval_Rejection_Date_Time__c   ;
                opportunityRecord.Expiration_Date2__c = mapLeads.get(mapLeadOpportunity.get(opportunityRecord.Id)).DealReg_Expiration_Date__c;
                opportunityRecord.PSC_SLA_Expiration_Date_Time__c = mapLeads.get(mapLeadOpportunity.get(opportunityRecord.Id)).DealReg_PSC_SLA_Expire_On__c;
                opportunityRecord.PSC_SLA_Expired__c = mapLeads.get(mapLeadOpportunity.get(opportunityRecord.Id)).DealReg_PSC_SLA_Expired__c;
                opportunityRecord.Field_SLA_Expiration_Date_Time__c = mapLeads.get(mapLeadOpportunity.get(opportunityRecord.Id)).DealReg_Field_SLA_Expire_on__c;
                opportunityRecord.Field_SLA_Expired__c = mapLeads.get(mapLeadOpportunity.get(opportunityRecord.Id)).DealReg_Field_SLA_Expired__c;
                opportunityRecord.Deal_Description__c = mapLeads.get(mapLeadOpportunity.get(opportunityRecord.Id)).DealReg_Deal_Description__c;
                opportunityRecord.Expected_Deal_Value__c = mapLeads.get(mapLeadOpportunity.get(opportunityRecord.Id)).DealReg_Expected_Deal_Value__c;
                opportunityRecord.Expected_Close_Date__c = mapLeads.get(mapLeadOpportunity.get(opportunityRecord.Id)).DealReg_Expected_Close_Date__c;
                opportunityRecord.Deal_Registration_Justification__c = mapLeads.get(mapLeadOpportunity.get(opportunityRecord.Id)).DealReg_Deal_Registration_Justification__c;
                opportunityRecord.Submission_Source__c = mapLeads.get(mapLeadOpportunity.get(opportunityRecord.Id)).DealReg_Submission_Source__c;
                opportunityRecord.Lead_Number__c = mapLeads.get(mapLeadOpportunity.get(opportunityRecord.Id)).Lead_Number__c;                
             }           
            
            if(updateOpportunities == true){
                try{
                    update mapOpportunity.values();
                }
                catch(Exception ex){
                system.debug('exception--->'+ex);
                for(Lead leads: mapLeads.values()){
                    String strErrorMessage = 'Error : '+ ex.getMessage();   
                    System.debug('strErrorMessage-->'+strErrorMessage);             
                    if(strErrorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                        strErrorMessage = strErrorMessage.substring(strErrorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 35);
                        System.debug('strErrorMessage 22-->'+strErrorMessage);   
                    }      
                    leads.addError(strErrorMessage);
                }
            }
            
         }
        }*/
    }   
/* @Method <This method execute is used to populate Deal Submitter details on Lead>
@param <This method takes Map<Id,Lead> and Boolean as parameter>
@return <void> - <The method is not returning anything>
@throws exception - <No Exception>
*/    
    public void populateDealSubmitterDetails(Map<Id,Lead> mapNewLeads,Map<Id,Lead> mapOldLeads,boolean updateLeads){
    List<Lead> lstDealReg = new List<Lead>();
        for(Lead leadRecord: mapNewLeads.values()){
            if(leadRecord.DealReg_Deal_Registration__c == true && UserInfo.getUserType()== 'PowerPartner' && leadRecord.DealReg_Deal_Registration_Status__c == 'New'){
                lstDealReg.add(leadRecord);
            }
        }
        User user = [select Id,contact.accountId,contact.account.Party_Number__c,Name,contactId,Email,Phone from User where id = :UserInfo.getUserId()];
        system.debug('user details'+user);
        if(lstDealReg!=null){
            for(Lead leadRecord: lstDealReg){   
                if(leadRecord.DealReg_Submission_Source__c != 'Powerlink'){            
                    leadRecord.DealReg_Deal_Submitter_Name__c = user.Name;
                    leadRecord.DealReg_Deal_Submitter_Rep_Phone__c = user.Phone;
                    leadRecord.DealReg_Deal_Submitter_Rep_Email__c = user.Email;
                }    
                leadRecord.DealReg_Partner_Party_Number__c = user.contact.account.Party_Number__c;
                leadRecord.DealReg_Partner_Name__c = user.contact.accountId;
                leadRecord.DealReg_Deal_Submitter_Contact__c = user.contactId;    
            }
        }       
    }

  
 /* @Method <This method execute is used to mark the deal reg as hand off to track. 
 which will be auto-checked for EMEA and APJ upon Deal Submission and no Related Account. 
 For Americas, as the PSC will do the duplicate search - this would be checked by the PSC. >
@param <This method takes Map<Id,Lead> List of new leads and Boolean as parameter>
@return <void> - <The method is not returning anything>
@throws exception - <No Exception>
*/    
   public void dealRegMarkHandOfftoTrack(List<Lead> newLeadsList,boolean IsUpdate){
        for(Lead leadRecord: newLeadsList){
            if(!leadRecord.DealReg_Handoff_to_TRACK__c){
                if((leadRecord.DealReg_Theater__c =='APJ' || leadRecord.DealReg_Theater__c =='EMEA') && leadRecord.Related_Account__c==null )
                leadRecord.DealReg_Handoff_to_TRACK__c=true;
            }
        }/*
        if(IsUpdate){
            update newLeadsList;
        }  */
    }

  /*@Method <setRelatedAccount> This method gets executed when lead is created it will look for any account where 
    *account.partynumber= lead.track_party number if a match is found it will link the account to the deal.
    @param List of old and new dealreg passed from update lead trigger
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
    */

   public void setRelatedAccount(MAP <iD,Lead> oldDealRegMap, Map<id,Lead> newDealRegMap ){
        List <String> partyNumber = new  List <String>();
        List <id> leadID = new  List <id>();
  
        Map <String,Lead> TrackNo_LeadMap =  new  Map <String,Lead> ();
  
        System.debug('setRelatedAccount Trigger started');
        Integer i= 0;
       
        for(Lead nextLead :newDealRegMap.values()){
             //Added for IM7263083  
             if (nextLead.DealReg_TRACK_Party_Number__c !=null && ((Lead)oldDealRegMap.get(nextLead.Id)).DealReg_TRACK_Party_Number__c != nextLead.DealReg_TRACK_Party_Number__c){
                System.debug('Track handoff check: for Loop enetered:'+((Lead)oldDealRegMap.get(nextLead.Id)).DealReg_TRACK_Party_Number__c);
                   TrackNo_LeadMap.put(nextLead.DealReg_TRACK_Party_Number__c,nextLead);
             }
             
        }
        List <Account> accountList = new List<Account>();
        if(TrackNo_LeadMap.size()>0){
             accountList = [Select a.Id,a.Party_Number__c,Country_Local__c, State_Province_Local__c, 
                                   City_Local__c, Zip_Postal_Code_Local__c, Street_Local__c,NameLocal 
                              FROM account a where a.Party_Number__c IN: TrackNo_LeadMap.keyset()]; 
        
        
            if(accountList.size()>0){
                for(Account acc :accountList){
                    Lead dealreg=TrackNo_LeadMap.get(acc.Party_Number__c);
                    if(dealreg != Null){ 
                      dealreg.Related_Account__c=acc.Id;
                      System.debug('Track handoff check: id:'+dealreg.Related_Account__c);

                      //Added by Suman -for populating the local Address fields -IM7290735,IM7262561.

                          dealreg.Country_Local__c=acc.Country_Local__c;
                          dealreg.Street_Local__c=acc.Street_Local__c;
                          dealreg.City_Local__c=acc.City_Local__c;
                          dealreg.Zip_Postal_Code_Local__c=acc.Zip_Postal_Code_Local__c;
                          dealreg.State_Province_Local__c=acc.State_Province_Local__c ;
                          dealreg.CompanyLocal = acc.NameLocal ;
                    }  
                      
                } // End of for loop.
            }
       }
   }
  
   /*@Method setRelatedDealReg This method gets executed when account is created it will look for any leads where 
    * lead.track_party number=account.partynumber if a match is found it will link the account to the lead
    @param List of Account 
    @return <void> - Not returning anything
    @throws exception - No Exception
    */
   public void setRelatedAccountOnDealReg (List <Account> listOfAccount)
   {
        Map  <String, Account> MapPartyNo_AccountId =  new  Map <String,Account> ();
        for(Account nextAccount :listOfAccount){
             if (nextAccount.Party_Number__c !=null )
                {
                     MapPartyNo_AccountId.put(nextAccount.Party_Number__c,nextAccount);
                }
      } 
                    
        if (MapPartyNo_AccountId.size() != 0)
        {   
             List <id> lstRecordTypeIds = new List <id>();   
             Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall();
             CustomSettingDataValueMap__c DealRegRecordTypes = (mapCustomSettingDataValueMap.get('DealRegistration'));
             String strRecType = DealRegRecordTypes.DataValue__c;
             lstRecordTypeIds=strRecType.split(',', 0);
                
             Map<id,Lead> MapDealRegs = new Map<id ,Lead>([Select l.Id,l.DealReg_TRACK_Party_Number__c,l.Related_Account__c,Street_Local__c,Country_Local__c,
                                                                  State_Province_Local__c,Zip_Postal_Code_Local__c,City_Local__c ,CompanyLocal
                                                              FROM Lead l where l.DealReg_TRACK_Party_Number__c!=null and Related_Account__c =null and 
                                                                   l.DealReg_TRACK_Party_Number__c IN: MapPartyNo_AccountId.keySet() and 
                                                                   recordtypeId in :lstRecordTypeIds]); 
            
             if(MapDealRegs.size()>0 ){
                 for(Lead dealReg: MapDealRegs.values()){
                   Account acc=MapPartyNo_AccountId.get(dealReg.DealReg_TRACK_Party_Number__c);
                   if(acc != Null){
                     dealReg.Related_Account__c=acc.Id;
                      //Added by Suman -for populating the local Address fields - IM7290735,IM7262561.
                          dealreg.Country_Local__c=acc.Country_Local__c;
                          dealreg.Street_Local__c=acc.Street_Local__c;
                          dealreg.City_Local__c=acc.City_Local__c;
                          dealreg.Zip_Postal_Code_Local__c=acc.Zip_Postal_Code_Local__c;
                          dealreg.State_Province_Local__c=acc.State_Province_Local__c ;
                          dealreg.CompanyLocal = acc.NameLocal ;
                   }                    
                 } // End of for loop.
                 update MapDealRegs.values();
             }     
             
         } 
      }

   /* @Method <PopulateTheaterOnLead(): This method will populate theater on lead on basis of country>
       @param - <List<Lead> of Lead> 
       @return <void> - 
       @throws exception - <No Exception>
    */
    public void populatedTheaterOnLead(List<Lead> lstLead){
        if(lstLead != null && lstLead.size() >0){
            Map<String,CustomSettingCountryTheaterMapping__c> DataValueMap = CustomSettingCountryTheaterMapping__c.getAll();
            String strCountryname = '';
            for(Lead objLead : lstLead){
                System.debug('objLead.Country__c-->' + objLead.Country__c);
                if(objLead.Country__c != null){
                    strCountryname = objLead.Country__c;
                    System.debug('strCountryname.length()-->' + strCountryname.length());
                    if(strCountryname.length() >= 36){
                        strCountryname = strCountryname.substring(0, 36);
                        System.debug('strCountryname trim-->' + strCountryname);
                    }                   
                    if(DataValueMap.containsKey(strCountryname)){
                        objLead.DealReg_Theater__c = DataValueMap.get(strCountryname).Theater__c; 
                    }                   
                }
            }            
        }
    }   
    /* @Method <PopulateOpptyOwnerOnLead(): This method will populate related opportunity owner on lead>
       @param - <List<Lead> of Lead> 
       @return <void> - 
       @throws exception - <No Exception>*/
   public void populateOpptyOwnerOnLead(List<Lead> lstLead){
       Set<Id> opptyIdset = new Set<Id>();
        for(Lead leadRecord: lstLead){  
            if(leadRecord.Related_Opportunity__c != null) {
                opptyIdset.add(leadRecord.Related_Opportunity__c);
            }
        }
        Map<Id,Opportunity> mapLeadToUpdate = new Map<Id,Opportunity>([select Id,OwnerId,Owner.Email, Opportunity_Owner__c,Opportunity_Owner__r.Email 
                                                                        from Opportunity 
                                                                        where Id in :opptyIdset]);
        if(opptyIdset.size()>0){
            for(Lead leadRecord: lstLead){
                leadRecord.Linked_Opportunity_Owner__c = mapLeadToUpdate.get(leadRecord.Related_Opportunity__c).Owner.Email;
            }
        }
    } 

/* @Method <populateChannelManagerOnLead(): This method will populate CAM of Parnter User on lead>
       @param - <Map<Id,Lead> of Lead> 
       @return <void> - 
       @throws exception - <No Exception>*/
   public void populateChannelManagerOnLead(Map<Id,Lead> userIdForCAMsMap){
    
        Map<Id,User> mapUser = new Map<Id,User>([Select u.ContactId, u.Contact.AccountId, u.Email, u.Id, u.Contact.Account.Owner.Email 
                                        from User u 
                                        where id in:userIdForCAMsMap.Keyset() and Contact.AccountId!=null]);
                                        
        if(mapUser.size()>0){
            for(Lead dealReg: userIdForCAMsMap.values()){
                if(dealReg.OwnerId != null && mapUser.ContainsKey(dealReg.OwnerId) ){
                    if(mapUser.get(dealReg.OwnerId).ContactId != null && mapUser.get(dealReg.OwnerId).Contact.AccountId != null && 
                    mapUser.get(dealReg.OwnerId).Contact.Account.Ownerid != null && mapUser.get(dealReg.OwnerId).Contact.Account.Owner.Email != null)
                    dealReg.DealReg_Channel_Account_Manager__c = mapUser.get(dealReg.OwnerId).Contact.Account.Owner.Email;
                    System.debug('DealReg_Channel_Account_Manager__c-->'+dealReg.DealReg_Channel_Account_Manager__c);
                }                                       
            }
        }
    }    
//Added By Anirudh for Rejection Emails to be Sent
/* @Method <This method will Process all the Rejected leads based On theater>
@param <This method takes List<Leads> as paramater from Trigger>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/    
     public void ProcessRejectedLeads(List<Lead> lstLead){
        String QueueId;
        String TemplateId;
        List<Lead> lstAPJLeads = new List<Lead>();
        List<Lead> lstEMEALeads = new List<Lead>();
        List<Lead> lstAmericaLeads = new List<Lead>();
        Map<String,DealRegistration_CustomSetting__c> mapCustomSettingDealRegistration = DealRegistration_CustomSetting__c.getall(); 
        Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall(); 
        CustomSettingDataValueMap__c RejectedTemplate = mapCustomSettingDataValueMap.get('DealRegRejectionTemplate'); 
        TemplateId = RejectedTemplate.DataValue__c;
        for(Lead leadObj :lstLead){
            if(leadObj.DealReg_Theater__c=='APJ'){
               lstAPJLeads.add(leadObj);    
            }
            if(leadObj.DealReg_Theater__c=='EMEA'){
               lstEMEALeads.add(leadObj);   
            }
            if(leadObj.DealReg_Theater__c=='Americas'){
               lstAmericaLeads.add(leadObj);    
            }
        }
        if(lstAPJLeads.size()>0){
            DealRegistration_CustomSetting__c RejectedQueue = mapCustomSettingDealRegistration.get('ApjPSCDRQueue');
            QueueId = RejectedQueue.PSC_QueueId__c;
            SendEmail(lstAPJLeads,QueueId,TemplateId);
        }
        if(lstEMEALeads.size()>0){
            DealRegistration_CustomSetting__c RejectedQueue = mapCustomSettingDealRegistration.get('EmeaPSCDRQueue');
            QueueId = RejectedQueue.PSC_QueueId__c;
            SendEmail(lstEMEALeads,QueueId,TemplateId);
        }
        if(lstAmericaLeads.size()>0){
            DealRegistration_CustomSetting__c RejectedQueue = mapCustomSettingDealRegistration.get('AmerPSCDRQueue');
            QueueId = RejectedQueue.PSC_QueueId__c;
            SendEmail(lstAmericaLeads,QueueId,TemplateId);
        }
    }



/* @Method <This method execute is used to send emailn for Deal Reg Approval or Rejection>
@param <This method takes List<Leads>,string QueueId,string Template Id as parameters>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/    
     public void SendEmail(List<Lead> lstLead,string QueueId,string TemplateId){
        String[] toAdd = new String[] {};
        String setTargetId;
        toAdd = get_QueueMembers(QueueId);
        System.debug('toAdd--->'+toAdd.size());
        System.debug('toAdd--->'+toAdd);
        setTargetId = get_TargetId(toAdd);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if(setTargetId !=null && toAdd.size()>0){
            for(Lead lead :lstLead){
                mail.setToAddresses(toAdd);
                mail.setSaveAsActivity(false);
                mail.setTemplateId(TemplateId);    
                mail.setTargetObjectId(setTargetId);
                mail.setWhatId(lead.ID);
                Messaging.SendEmailResult [] res = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
            }
        }
     }  



/* @Method <This method execute is used to extract email ids of users from queue>
@param <This method takes Queue Id as parameter>
@return <List> - <Returning List of Email Ids>
@throws exception - <No Exception>
*/     
    public List<String> get_QueueMembers(String Queue_ID){
        Id[] allUserIds= new Id[] {};
        String[] allEmailIds = new String[] {};
        Set<Id> allGroupIds = new set<Id>();        
        Id[] allUserIdsOfGroupMem = new Id[] {};
        List<Groupmember> grmem;
        List<User> usr;
        string forusrchk = Queue_ID.substring(0,3);        
            
        // To get all queue members
        grmem = [select id,groupid,userorgroupid from groupmember where groupid = :Queue_ID] ;
        system.debug('grpmemdetails--->'+grmem);
        for(Groupmember grmemb : grmem){
            system.debug('grmemb---->'+grmemb.userorgroupid);
            if(((string)grmemb.userorgroupid).startswith('005')){
            allUserIds.add(grmemb.userorgroupid);            
            }
            if(((string)grmemb.userorgroupid).startswith('00G')){
                allGroupIds.add(grmemb.Id);
            }
        }
        system.debug('allUserIds.size()---->'+allUserIds.size());
        allUserIdsOfGroupMem = get_GroupMembers(allGroupIds);
        if(allUserIdsOfGroupMem.size()>0){
            for(Id idToAdd :allUserIdsOfGroupMem){
                allUserIds.add(idToAdd);
            }
        }
        // To get all users email
        usr = [select ID,email from User where ID in :allUserIds];
        system.debug('user---->'+usr);
        for(User us : usr) {
            allEmailIds.add(us.email);
        }
        return allEmailIds;
    }     
    
/* @Method <This method execute is used to extract contact Id>
@param <This method takes List of Email Ids as parameter>
@return <String> - <Returning Contact Id>
@throws exception - <No Exception>
*/
    public String get_TargetId(List<String> allEmailIds){             
        System.debug('allEmailIds.size()-->'+allEmailIds.size());
        System.debug('allEmailIds-->'+allEmailIds);
        Contact ConId = [select Id,email from Contact where email in :allEmailIds limit 1];
        system.debug('target Id--->'+ConId);
        return ConId.Id;
    }

/* @Method <This method is used to extact all the User Ids of Group Members>
@param <This method takes List of Group Ids as parameter>
@return <String> - <Returning List of User Id>
@throws exception - <No Exception>
*/
    public List<Id> get_GroupMembers(Set<Id> allGroupIds){   
        List<Id> UserIds = new List<Id>();
        List<Id> UserIdsOfGrpMem = new List<Id>();
        set<Id> GroupIds = new set<Id>();
        List<Groupmember> grmem;
        
        grmem = [select id,groupid,userorgroupid from groupmember where groupid = :allGroupIds] ;
        
         for(Groupmember grmemb : grmem){
                if(((string)grmemb.Id).startswith('005')){
                UserIds.add(grmemb.userorgroupid);
                }
                if(((string)grmemb.Id).startswith('00G')){
                    GroupIds.add(grmemb.Id);
                }
                
                
         }
         if(GroupIds.size()>0){
                   UserIdsOfGrpMem = get_GroupMembers(GroupIds) ;   
         }  
         if(UserIdsOfGrpMem.size()>0){
            for(Id idToAdd :UserIdsOfGrpMem){
                UserIds.add(idToAdd);
            }
         }          
            
        return UserIds;
        
    }
    
     /*@Method <This method is called from the Trigger BeforeUpdateLeadOnDealSubmit.
              It is used to Update the Registered Product field on Lead and populates all Registered prod name.>
    @param <List<Lead> - All Reg Prod Names>
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
    */ 
    
    public void populateRegProducts(List<Lead> AllLeadRec)
    {
        // Creating a key for Lead ID and List of Reg Product
        string leadProdKey = NULL;
        
        // List to store all Product name for the corresponding Lead
        String Listproduct ='';
        String RegProducts;
        // Map to store Lead ID and List of Reg Product records
        Map<String, String> LeadProdMap = new Map<String, String>();    
        
        // List to store all Reg product records
        List<Registration_Product__c> allRegProd = [select ID,Product__c,Partner_Product_Catalog__r.Name,Deal_Registration__c from Registration_Product__c 
                                                    where Deal_Registration__c IN :AllLeadRec];
        
        // Loop for all Reg product records
        for (Registration_Product__c RegProdRec : allRegProd) {
        
            // Making a key for Lead ID and List of Reg Product
            leadProdKey = RegProdRec.Deal_Registration__c ;        
            Listproduct = LeadProdMap.get(leadProdKey);  
                    
            if(LeadProdMap == Null){   
               Listproduct =''; 
            }    
            Listproduct += RegProdRec.Product__c + ' - '+ RegProdRec.Partner_Product_Catalog__r.Name +' ; ';
            
            LeadProdMap.put(leadProdKey,Listproduct);  
                      
        }   

        // Loop for all the Leads
        for (Lead updateLead : AllLeadRec) {
            //added by arif
            if(LeadProdMap != null && LeadProdMap.containsKey(updateLead.Id)){
                RegProducts=LeadProdMap.get(updateLead.ID).substring(4);
                RegProducts= RegProducts.substring(0,RegProducts.length()-2);     
                updateLead.DealReg_Registered_Products__c = RegProducts;    
            }                
        }
    }
  
  /*@Method <Do not allow the user Admin + reporting user to delete lead record. We have given modify all to this profile
              to udpate track party nubmer on deal regs when it under approval process. Adding error if so.>
    @param <List<Lead> - Lead.old>
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
    */                         
    public void takeAwayDelete(List <Lead> Leads ){
        System.debug('UserInfo.getProfileId() ===  00e70000000x1Zv  ==='+UserInfo.getProfileId());
        if(UserInfo.getProfileId()=='00e70000000x1Zv' || UserInfo.getProfileId()=='00e70000000x1ZvAAI'){
        
            for(Lead lead: Leads){
                lead.addError('You have insufficient privileges to delete Lead records.');
            }
        }
    }

/*@Method <Method to to create a corresponding Deleted Account Association  
           record for AccountAssociation record before delete.>
  @param <Map<Id,APPR_MTV__RecordAssociation__c>>
  @return <void> - <Not returning anything>
  @throws exception - <No Exception>
*/    
    public void createAccountAssociationBeforeDelete(Map<Id,APPR_MTV__RecordAssociation__c> newRecordAssociation, Map<Id,APPR_MTV__RecordAssociation__c> oldRecordAssociation){
        Map<String,Outbound_Message_Log__c> mapDelAccAssociation = new Map<String,Outbound_Message_Log__c>() ;
        Map<String,CustomSettingDataValueMap__c> DataValueMap= CustomSettingDataValueMap__c.getall();

            system.debug('Inside AccountAssociation Delete event #####');  
                for (APPR_MTV__RecordAssociation__c accAsscn : oldRecordAssociation.values()){
                    if(accAsscn.APPR_MTV__Account_Role__c == 'Distributor'){
                        Outbound_Message_Log__c delaccASSON = new Outbound_Message_Log__c();
       // update by anand on 09/06/2011
                        delaccASSON.RecordId__c = accAsscn.Id ;
       //delaccASSON.RecordId__c = accAsscn.Name ;
                        delaccASSON.Integration_Operation__c = 'Delete Account Association';
                        delaccASSON.OwnerId = DataValueMap.get('System Integration').DataValue__c;
                        mapDelAccAssociation.put(delaccASSON.RecordId__c, delaccASSON);
                     } 
                }
        if(mapDelAccAssociation.size()>0){
                  System.debug('mapDelAccAssociationValuesbyAnirudh--->' +mapDelAccAssociation.values());
                  upsert mapDelAccAssociation.values() RecordId__c;
        }
     }
/*@Method <Method to to create a corresponding Deleted Account Association  
           record for AccountAssociation record before delete.>
  @param <Map<Id,APPR_MTV__RecordAssociation__c>>
  @return <void> - <Not returning anything>
  @throws exception - <No Exception>
*/     
    public void createAccountAssociationAfterInsert(Map<Id,APPR_MTV__RecordAssociation__c> newRecordAssociation, Map<Id,APPR_MTV__RecordAssociation__c> oldRecordAssociation){
         Map<String,Outbound_Message_Log__c> mapDelAccAssociation = new Map<String,Outbound_Message_Log__c>() ;
         Map<String,CustomSettingDataValueMap__c> DataValueMap= CustomSettingDataValueMap__c.getall();
         system.debug('Inside AccountAssociation Insert event #####');
         for (APPR_MTV__RecordAssociation__c accAsscn : newRecordAssociation.values()){
             if(accAsscn.APPR_MTV__Account_Role__c == 'Distributor'){
                 Outbound_Message_Log__c delaccASSON = new Outbound_Message_Log__c();
         // update by anand on 09/06/2011
                 delaccASSON.RecordId__c = accAsscn.Id ;
         //delaccASSON.RecordId__c = accAsscn.Name ;
                 delaccASSON.Integration_Operation__c = 'Upsert Account Association';
                 delaccASSON.OwnerId = DataValueMap.get('System Integration').DataValue__c;
                 mapDelAccAssociation.put(delaccASSON.RecordId__c, delaccASSON);
             } // End of if -condition.
         } //End of for -loop.
         if(mapDelAccAssociation.size()>0){
                  System.debug('mapDelAccAssociationValuesbyAnirudh--->' +mapDelAccAssociation.values());
                  upsert mapDelAccAssociation.values() RecordId__c;
         }
     }
/*@Method <Method to to create a corresponding Deleted Account Association  
           record for AccountAssociation record before delete.>
  @param <Map<Id,APPR_MTV__RecordAssociation__c>>
  @return <void> - <Not returning anything>
  @throws exception - <No Exception>
*/
    public void createAccountAssociationAfterUpdateDelete(Map<Id,APPR_MTV__RecordAssociation__c> newRecordAssociation, Map<Id,APPR_MTV__RecordAssociation__c> oldRecordAssociation){
        Map<String,Outbound_Message_Log__c> mapDelAccAssociation = new Map<String,Outbound_Message_Log__c>() ;
        Map<String,CustomSettingDataValueMap__c> DataValueMap= CustomSettingDataValueMap__c.getall();
                for (APPR_MTV__RecordAssociation__c accAsscn : newRecordAssociation.values() ){
                    if(accAsscn.APPR_MTV__Account_Role__c == 'Distributor'){
                        if((newRecordAssociation.get(accAsscn.id).APPR_MTV__Account__c != oldRecordAssociation.get(accAsscn.id).APPR_MTV__Account__c)
                          ||(newRecordAssociation.get(accAsscn.id).APPR_MTV__Primary__c != oldRecordAssociation.get(accAsscn.id).APPR_MTV__Primary__c )
                          ||(newRecordAssociation.get(accAsscn.id).APPR_MTV__Associated_Account__c != oldRecordAssociation.get(accAsscn.id).APPR_MTV__Associated_Account__c)
                          ||(newRecordAssociation.get(accAsscn.id).APPR_MTV__Account_Role__c != oldRecordAssociation.get(accAsscn.id).APPR_MTV__Account_Role__c)){ 
                            Outbound_Message_Log__c delaccASSON = new Outbound_Message_Log__c();
            // update by anand on 09/06/2011
                            delaccASSON.RecordId__c = accAsscn.Id ;
            //delaccASSON.RecordId__c = accAsscn.Name ;
                            delaccASSON.Integration_Operation__c = 'Upsert Account Association';
                            delaccASSON.OwnerId = DataValueMap.get('System Integration').DataValue__c;
                            mapDelAccAssociation.put(delaccASSON.RecordId__c, delaccASSON);
                        } 
                   } // End of if -condition.
                   else if( (oldRecordAssociation.get(accAsscn.id).APPR_MTV__Account_Role__c == 'Distributor') &&
                       (newRecordAssociation.get(accAsscn.id).APPR_MTV__Account_Role__c != 'Distribution VAR')){
                       Outbound_Message_Log__c delaccASSON = new Outbound_Message_Log__c();
            // update by anand on 09/06/2011
                       delaccASSON.RecordId__c = accAsscn.Id ;
            //delaccASSON.RecordId__c = accAsscn.Name ;
                       delaccASSON.Integration_Operation__c = 'Delete Account Association';
                       delaccASSON.OwnerId = DataValueMap.get('System Integration').DataValue__c;
                       mapDelAccAssociation.put(delaccASSON.RecordId__c, delaccASSON);
                   }   
               } //End of for -loop.

 
             if(mapDelAccAssociation.size()>0){
                  System.debug('mapDelAccAssociationValuesbyAnirudh--->' +mapDelAccAssociation.values());
                  upsert mapDelAccAssociation.values() RecordId__c;
                }
        }
  /* @Method <This method is used to set the Email Adress of Distributor and
              Direct Reseller Owner's Email Address >
  @param <This method takes List<Lead> from LeadBeforeInsert and LeadBeforeUpdate Trigger>
  @return <void> - <The method is not returning anything>
  @throws exception - <No Exception>
  */
    public void populatePartnerOwnerEmailforDealReg(List<Lead> lstLeads){  
        Set<Id> setDistributorAcc =new set<Id>();
        Set<Id> setDistributionVARAcc =new set<Id>();
        
        for(lead leadObj :lstLeads){
            //System.Debug('leadObj.Partner__r.Owner.Email-->' +leadObj.Partner__r.Owner.Email);
            if(leadObj.Partner__c!=null){
                setDistributorAcc.add(leadObj.Partner__c);
            }
            if(leadObj.Tier_2_Partner__c!=null){
                setDistributionVARAcc.add(leadObj.Tier_2_Partner__c);
            }
        }
        Map<Id,Account> mapAccount = new Map<Id,Account>([Select Id,Owner.Email from Account where id in:setDistributorAcc or id in:setDistributionVARAcc]);
        for(lead leadObj :lstLeads){
            //System.Debug('mapAccount.get(leadObj.Partner__c).Owner.Email---> '+ mapAccount.get(leadObj.Partner__c).Owner.Email);
            //System.Debug('mapAccount.get(leadObj.Tier_2_Partner__c).Owner.Email---> '+ mapAccount.get(leadObj.Tier_2_Partner__c).Owner.Email);
            if(leadObj.Partner__c!=null && setDistributorAcc.contains(leadObj.Partner__c)){
                //System.Debug('mapAccount.get(leadObj.Partner__c)---> '+ mapAccount.get(leadObj.Partner__c));
                //System.Debug('mapAccount.get(leadObj.Partner__c).Ownerid---> '+ mapAccount.get(leadObj.Partner__c).Ownerid);
                //System.Debug('mapAccount.get(leadObj.Partner__c).Owner.Email---> '+ mapAccount.get(leadObj.Partner__c).Owner.Email);
                leadObj.DealReg_Distributor_Owner_Email__c=mapAccount.get(leadObj.Partner__c).Owner.Email;
            }
            if(leadObj.Tier_2_Partner__c!=null ){
                //System.Debug('mapAccount.get(leadObj.Tier_2_Partner__c)---> '+ mapAccount.get(leadObj.Tier_2_Partner__c));
                //System.Debug('mapAccount.get(leadObj.Tier_2_Partner__c).Ownerid---> '+ mapAccount.get(leadObj.Tier_2_Partner__c).Ownerid);
                //System.Debug('mapAccount.get(leadObj.Tier_2_Partner__c).Owner.Email---> '+ mapAccount.get(leadObj.Tier_2_Partner__c).Owner.Email);
                leadObj.DealReg_Distribution_VAR_Owner_Email__c=mapAccount.get(leadObj.Tier_2_Partner__c).Owner.Email;
            }
        }
    }  
    
    /* @Method <This method execute is used to populate creation and expiration date of deal on Opportunity>
        @param <This method takes List<Lead> and Boolean as parameter>
        @return <void> - <The method is not returning anything>
        @throws exception - <No Exception>
*/ 
  /* Taking out as removed the below fields.
   public void populateCreationAndExpirationDateofLeadONOpportunity(Map<Id,Lead> mapNewLeads){
      Set<Id> setNewOpptyId = new Set<Id>();
         Map<Id, Lead> mapLeadOpportunity = new Map<Id, Lead>();
         List<Opportunity> lstOppty= new List<Opportunity>();               
         for(Lead leadRecord: mapNewLeads.values()){             
            if(leadRecord.DealReg_Deal_Registration__c && leadRecord.Related_Opportunity__c != null){  
                setNewOpptyId .add(leadRecord.Related_Opportunity__c);    
                mapLeadOpportunity.put(leadRecord.Related_Opportunity__c,leadRecord);            
                system.debug('Related Opportunities--->'+setNewOpptyId );
            }                                     
        }
         if(setNewOpptyId != null && setNewOpptyId.size() >0){  
             lstOppty = [select Linked_to_Deal_Registration__c,Deal_Registration_Creation_Date__c,Expiration_Date__c from Opportunity where Id in: setNewOpptyId];   
             system.debug('list of oppty--->'+lstOppty);
             if(lstOppty!=null){
                 for(Opportunity opportunityRecord: lstOppty){                     
                     opportunityRecord.Deal_Registration_Creation_Date__c = mapLeadOpportunity.get(opportunityRecord.Id).CreatedDate;
                     opportunityRecord.Expiration_Date__c = mapLeadOpportunity.get(opportunityRecord.Id).DealReg_Expiration_Date__c;
                 }
             }
         }         
         try{           
               update lstOppty;           
         }
         catch(Exception ex){
             system.debug('exception--->'+ex);
             for(Lead leads: mapNewLeads.values()){
                String strErrorMessage = 'Error : '+ ex.getMessage();   
                System.debug('strErrorMessage-->'+strErrorMessage);             
                if(strErrorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                    strErrorMessage = strErrorMessage.substring(strErrorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 35);
                    System.debug('strErrorMessage 22-->'+strErrorMessage);   
                }      
                leads.addError(strErrorMessage);
             }
         }    
    } */
    /* @Method <This method is used to populateRelatedAccountFieldsOnDR
                is invoked from LeadAccept Trigger>
        @param <This method takes List<Lead> as parameter>
        @return <void> - <The method is not returning anything>
        @throws exception - <No Exception>
    */  
    public void updateRelatedAccountFieldsOnDR(list<Lead> lstNewLeads){
        map<Id,Id> mapDealRegWithRelatdAccId = new map<Id,Id>();        
        for(lead leadobj :lstNewLeads){
            if(leadobj.Related_Account__c !=null){
                mapDealRegWithRelatdAccId.put(leadobj.Id,leadobj.Related_Account__c);
            }
        }
        map<Id,Account> mapRelatedAccDetails = new map<Id,Account>([Select Id,EMC_Classification__c from Account where Id in :mapDealRegWithRelatdAccId.values()]);
        for(lead leadobj :lstNewLeads){
            if(mapDealRegWithRelatdAccId.get(leadobj.Id)!=null && mapRelatedAccDetails.get(mapDealRegWithRelatdAccId.get(leadobj.Id)) !=null){
               leadobj.DealReg_Account_Category__c= mapRelatedAccDetails.get(mapDealRegWithRelatdAccId.get(leadobj.Id)).EMC_Classification__c;
            }
        }       
    }
    
  /* @Method <This method is used to check the IsExpired checkbox on Lead>
  @param <This method takes Trigger.NewMap and Trigger.OldMap as parameter>
  @return <void> - <The method is not returning anything>
  @throws exception - <No Exception>
  */
    
    public void updateDealRegExpirationFlag(map<Id,Extension_Request__c> mapNewExtRequest,map<Id,Extension_Request__c> mapOldExtRequest){
        map<Id,Extension_Request__c> mapSubExtReq = new map<Id,Extension_Request__c>();
        map<Id,Extension_Request__c> mapApprExtReq = new map<Id,Extension_Request__c>();
        map<Id,Extension_Request__c> mapRejExtReq = new map<Id,Extension_Request__c>();
        list<Id> lstDealRegId = new list<Id>();
        map<Id,Lead> mapDealReg = new map<Id,Lead>();
        list<Lead> lstDealRegToUpdate = new list<Lead>();
        for(Extension_Request__c ext: mapNewExtRequest.values()){
            if(ext.Extension_Request_Status__c != mapOldExtRequest.get(ext.Id).Extension_Request_Status__c){
                if(ext.Extension_Request_Status__c == 'Submitted'){
                    mapSubExtReq.put(ext.Deal_Registration__c,ext);
                }
                if(ext.Extension_Request_Status__c == 'Approved'){
                    mapApprExtReq.put(ext.Deal_Registration__c,ext);
                }
                if(ext.Extension_Request_Status__c == 'PSC Declined'){
                    mapRejExtReq.put(ext.Deal_Registration__c,ext);
                }
            }
        }
        if((mapSubExtReq != null && mapSubExtReq.size()>0) || (mapApprExtReq != null && mapApprExtReq.size()>0) || (mapRejExtReq != null && mapRejExtReq.size()>0)){
            if(mapSubExtReq != null && mapSubExtReq.size()>0){
                lstDealRegId.addAll(mapSubExtReq.keyset());
            }
            if(mapApprExtReq != null && mapApprExtReq.size()>0){
                lstDealRegId.addAll(mapApprExtReq.keyset());
            }
            if(mapRejExtReq != null && mapRejExtReq.size()>0){
                lstDealRegId.addAll(mapRejExtReq.keyset()); 
            }
        }
        if(lstDealRegId != null && lstDealRegId.size()>0){
            for(Lead lead:[Select Id,Is_Extension_Request_Not_Submitted__c,DealReg_Deal_Registration_Status__c,DealReg_Expiration_Date__c from Lead where Id in:lstDealRegId]){
                mapDealReg.put(lead.Id,lead);
            }
        }
        if(mapDealReg != null && mapDealReg.size()>0){
            for(Lead lead:mapDealReg.values()){
                if(mapSubExtReq.containsKey(lead.Id)){
                    lead.Is_Extension_Request_Not_Submitted__c = false;
                }
                if(mapRejExtReq.containsKey(lead.Id)){
                    lead.Is_Extension_Request_Not_Submitted__c = true;
                    if(lead.DealReg_Expiration_Date__c <= System.Today()){
                        lead.DealReg_Deal_Registration_Status__c = 'Expired';
                    }
                }
                if(mapApprExtReq.containsKey(lead.Id)){
                    lead.Is_Extension_Request_Not_Submitted__c = true;
                }
                lstDealRegToUpdate.add(lead);
            }
        }
        if(lstDealRegToUpdate != null && lstDealRegToUpdate.size()>0){
            update lstDealRegToUpdate;
        }
    }
     
 /* @Method <This method is used to set the Non Distributor/Direct Reseller Partner>
  @param <This method takes list of updated Account for which we need to set the flag
          and is being invoked from TO_AccountInsertOrUpdate trigger>
  @return <void> - <The method is not returning anything>
  @throws exception - <No Exception>
  */
  public void setNonDistributorDirectResllerFlag(list<Account> lstAccount){
    Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
    string customSetting = DataValueMap.get('Partner Type').DataValue__c;
    list<string> lstString = customSetting.split(';');
    system.debug('lstString------>' +lstString);
      for(account acctObj :lstaccount){
        if(acctObj.Partner_Type__c != null && acctObj.Partner_Type__c != ''){
            Boolean flag = false;
                for(integer i = 0;i<lstString.size();i++){
                    if(acctObj.Partner_Type__c.contains(lstString[i])){
                        system.debug('contains------>');
                        acctObj.Non_Distributor_Direct_Reseller_Partner__c = true;  
                        flag = true;
                    }                   
                }
                if(!flag){
                    acctObj.Non_Distributor_Direct_Reseller_Partner__c = false; 
                }
        }else{
            acctObj.Non_Distributor_Direct_Reseller_Partner__c = false;
        }               
     }
  }
  
  /* @Method <populateClusterOnAccount(): This method will populate cluster on Account on basis of country>
       @param - <List<Account> of Account> 
       @return <void> - 
       @throws exception - <No Exception>
  */
    public void populateClusterOnAccount(List<Account> lstAccount){
        if(lstAccount != null && lstAccount.size() >0){
            Map<String,CustomSettingCountryTheaterMapping__c> CountryClusterMapping = CustomSettingCountryTheaterMapping__c.getAll();
            Map<String,CustomSettingCountryTheaterMapping__c> LowerCaseCountryClusterMapping = new Map<String,CustomSettingCountryTheaterMapping__c>();
            for(string countryname : CountryClusterMapping.keyset()){
                string lowercaseCountry = countryname.toLowerCase();
                LowerCaseCountryClusterMapping.put(lowercaseCountry,CountryClusterMapping.get(countryname));
            }
            String strCountryname = '';
            for(Account objAcc : lstAccount){
                System.debug('Account.BillingCountry-->' + Account.BillingCountry);
                if(objAcc.BillingCountry != null){
                    strCountryname = objAcc.BillingCountry.toLowerCase();
                    System.debug('strCountryname.length()-->' + strCountryname.length());
                    if(strCountryname.length() >= 36){
                        strCountryname = strCountryname.substring(0, 36);
                        System.debug('strCountryname trim-->' + strCountryname);
                    }                   
                    if(LowerCaseCountryClusterMapping.containsKey(strCountryname)){
                        objAcc.Cluster__c = LowerCaseCountryClusterMapping.get(strCountryname).Cluster__c; 
                    }                   
                }
                else{
                    objAcc.Cluster__c=null;
                }
            }            
        }
    } 
 

 /* @Method <calculateNumberOfDealsforPartnerSE(): This future method will calculate number of Approved Deals for Partner SE Contact>
       @param - <List<Lead> of Approved DealReg> 
       @return <void> - 
       @throws exception - <No Exception>
 */
    @future
    public static void calculateNumberOfDealsforPartnerSE(Set<Id> setDeal){
        
        List<Lead> lstLead = [Select Id,Name, DealReg_Deal_Registration__c, Partner_SE_Lookup__c 
            From Lead where id in: setDeal];
        
        
        Map<Id,List<Lead>> MapPartnerSEAndDeal = new Map<Id,List<Lead>>();      
        for(Lead leadObj :lstLead){
            list<Lead> lstLeadtoAdd = MapPartnerSEAndDeal.get(leadObj.Partner_SE_Lookup__c);
            if(lstLeadtoAdd==null){
                lstLeadtoAdd = new List<Lead>();
            }
            lstLeadtoAdd.add(leadObj);
            MapPartnerSEAndDeal.put(leadObj.Partner_SE_Lookup__c,lstLeadtoAdd);
        }
        
        // Exception Handling.
        List <EMCException> errors = new List <EMCException>();
        
        List<Contact> lstContactToUpdate = new List<Contact>([Select Id,Name,Deal_Registrations__c from Contact where id in:MapPartnerSEAndDeal.keyset()]);
        for (Contact conObj : lstContactToUpdate){
             if(conObj.Deal_Registrations__c==null){
                conObj.Deal_Registrations__c=0; 
             }  
             conObj.Deal_Registrations__c += MapPartnerSEAndDeal.get(conObj.Id).size();
        }

            if(lstContactToUpdate.size() >0){
                Database.Saveresult[] result =  Database.update(lstContactToUpdate, false);
                
                /* HANDLING EXCEPTION LOG*/
                for (Database.Saveresult sr : result) {
                    String dataErrs = '';
                    if (!sr.isSuccess()) {
                        // if the particular record did not get updated, we log the data error 
                        for (Database.Error err : sr.getErrors()) {
                            dataErrs += err.getMessage();
                        }
                        System.debug('An exception occurred while attempting an update on ' + sr.getId());
                        System.debug('ERROR: ' + dataErrs);
                        errors.add(new EMCException(dataErrs, 'ERROR_UPDATE_CONTACT_DEAL_REG', new String [] {sr.getId()}));
                    }
                }
              // log any errors that occurred
               if (errors.size() > 0) { 
                    EMC_UTILITY.logErrors(errors);  
                }
            }  
    }

      
  /* @Method <populateFieldsOnERWhileCreation(): This method will populate Oppty Owner,Additional Contact Email Address etc while creation fo a ER>
       @param - <list<Extension_Request__c> of newly created ER> 
       @return <void> - 
       @throws exception - <No Exception>
 */  
    //WR 184320
    public void populateFieldsOnERWhileCreation(list<Extension_Request__c> lstExtensionReq){
        list<Id> lstDRId = new list<Id>();
        if(lstExtensionReq != null && lstExtensionReq.size()>0){
            for(Extension_Request__c er: lstExtensionReq){
                lstDRId.add(er.Deal_Registration__c);
            }       
            map<Id,Lead> mapDR = new map<Id,Lead>([Select Id,Related_Opportunity__r.OwnerId,DealReg_Additional_Contact_Email_Address__c,
                                                   Partner_Manager__c,Additional_Notification_Email_1__c,Partner__r.OwnerId
                                                   from Lead where Id in: lstDRId]);
            if(mapDR!=null)
            {
                for(Extension_Request__c er: lstExtensionReq){
                    if(mapDR.get(er.Deal_Registration__c)!=null){
                        er.Additional_Contact_Email_Address__c = mapDR.get(er.Deal_Registration__c).DealReg_Additional_Contact_Email_Address__c;
                        er.Additional_Notification_Email_1__c = mapDR.get(er.Deal_Registration__c).Partner_Manager__c;
                        er.Additional_Notification_Email_2__c = mapDR.get(er.Deal_Registration__c).Additional_Notification_Email_1__c; 
                        er.Oppty_Owner__c = mapDR.get(er.Deal_Registration__c).Related_Opportunity__r.OwnerId;
                        er.Channel_Account_Manager__c = mapDR.get(er.Deal_Registration__c).Partner__r.OwnerId;
                    }
               }  
            }
        }       
    }  
    //WR 184320
     /* @Method <This method is used to set the value in comments field of ER on rejection of ER>.
   @param <This method is taking set<Id> of ER from afterUpdateOfExtensionRequest Trigger>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
  */   
    @future
    public static void setCommentsOnRejectedER(Set<Id> setER){
       List<Extension_Request__c> lstER = [Select Id,Comments__c,IsRejected__c,                      
                        (Select ProcessInstance.TargetObjectId, SystemModstamp, StepStatus, ProcessInstanceId, OriginalActorId, Id, 
                        CreatedDate, CreatedById, Comments, ActorId FROM ProcessSteps where StepStatus='Rejected' or StepStatus='Approved' Order By CreatedDate Desc limit 1)
                        From Extension_Request__c
                        where id in: setER];
        for(Extension_Request__c obj : lstER){
            ProcessInstanceHistory  objPIH = obj.ProcessSteps;
            if(objPIH != null ){
                obj.Comments__c = objPIH.Comments;
                obj.IsRejected__c = true;
            }            
        }                
        update lstER;                            
   }  
   
     /* @Method <This method is used to set the value in Submission Date and Date Approved/Rejected field>.
   @param <This method is taking list<Extension_Request__c> of ER from beforeUpdateOfExtensionRequest Trigger>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
  */   //185856
      public void setSubmissionORApprRejDate(List<Extension_Request__c> lstExtReq){
         for(Extension_Request__c obj : lstExtReq){
            if(obj.Extension_Request_Status__c == 'Submitted' && obj.Submission_Date__c == null){
                obj.Submission_Date__c = datetime.Now().dateGMT();
           }
        
            if((obj.Extension_Request_Status__c == 'Approved' || obj.Extension_Request_Status__c == 'PSC Declined') && obj.Date_Approved_Rejected__c == null){
                obj.Date_Approved_Rejected__c = datetime.Now().dateGMT();
           }            
        }                                         
    }       
    
    
    //WR #252201
    public void UpdateScontrolConvert(List<Lead> lstLeads){
    	
    	Set<id> objDealids = new set<id>();
    	for(Lead setids:lstLeads){    	
    	   objDealids.add(setids.id);    	
    	}
    	system.debug('objDealids11111'+objDealids);
    	List<Lead> objDealData = [Select id,status,S_Control_Converted__C from lead where id in:objDealids and S_Control_Converted__C=true];  	
    	
    	
    	for(Lead lstCheck:objDealData)
    	{
    	  if(lstCheck.S_Control_Converted__C == true){
    	   	     lstCheck.S_Control_Converted__C = false;
    	  }
    	}
    	if(objDealData.size()>0){
    	   update objDealData;
    	}
    }
  
                     
}