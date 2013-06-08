/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  19/09/2011     Shalabh Sharma          This class is used for adding To/CC email Ids as a Case team member.
 |  13/12/2011     Shalabh Sharma          Changed SuppliedEmail field value to lower case  
 |  27/12/2011     Shalabh Sharma   4806   Added logic to capture 'To' field on Email on case creation
 |  03/01/2012     Shalabh Sharma          Updated code to include custom label on line 47.  
 |  14/02/2012     Shalabh Sharma   5049   Updated code to fix bug 5049.
 |  14/02/2012     Shalabh Sharma   4686   Updated code to restrict requestor from adding to case team.                                    
 |  17/02/2012     Medhavi Deshapnde 5055  Added m/d to check email exists.
 +==================================================================================================================**/
public class Presales_UpdateCaseTeams {
    public void addToCcToCaseTeam(Id caseId,String emailIds,String fromAddress,String toAddress){      
        List<CaseTeamMember> lstCaseTeamMemberUser = new List<CaseTeamMember>();
        List<CaseTeamMember> lstCaseTeamMemberContact = new List<CaseTeamMember>();
        List<String> lstAddressToAdd = new List<String>();
        List<User> lstUser;
        List<Contact> lstContact;
        CaseTeamRole roleId;
        String caseTeamRole = System.label.Presales_CaseTeamRole;
        Map<String,User> mapEmailUser = new Map<String,User>();
        List<CaseTeamMember> lstCaseTeamMemberRecords = new  List<CaseTeamMember>();
        Map<Id,Case> mapCase = new Map<Id,Case>();
        List<EmailMessage> lstEmailMessage = new List<EmailMessage>();
        system.debug('fromAddress--->'+fromAddress);
        if(emailIds!=null){
        /*Splitting semicolon seperated email ids*/
            for(String s: emailIds.split(';')){
                lstAddressToAdd.add(s.toLowerCase().trim()); 
            }
        
        mapCase = new Map<Id,Case>([select Id,IsCaseTeam__c,SuppliedEmail,Status,Contact_Email1__c,IsMailAfterClose__c,Is_Email_To_Case__c,Send_Mail_On_Update__c,OwnerId from Case where Id=:caseId]);
        system.debug('mapCase--->'+mapCase);
        }
        system.debug('addr to add--->'+lstAddressToAdd);
        if(lstAddressToAdd.size()>0){
        
        lstUser = [select id,isActive, Email from User where Email like :lstAddressToAdd AND isActive=true AND UserType != 'PowerPartner' AND Email !=: fromAddress.toLowerCase()];
        system.debug('lstUser--->'+lstUser);
        
        for(User userRecord:lstUser){
            mapEmailUser.put(userRecord.Email,userRecord);
        }
        system.debug('mapEmailUser--->'+mapEmailUser);
        lstContact = [select Id,Email from Contact where Email in:lstAddressToAdd AND Email !=: fromAddress.toLowerCase()];
        roleId = [select Id from CaseTeamRole where Name =:caseTeamRole];
        system.debug('case role id--->'+roleId);
        }
       
       if(lstUser != null && lstUser.size()>0){
       lstCaseTeamMemberRecords = [select MemberId from CaseTeamMember where ParentId=:caseId and (MemberId in :lstUser or MemberId in :lstContact)];
        } 
       try{
        /*Checking if member is already present in the case team*/
            if(lstCaseTeamMemberRecords.size()==0 && mapCase.size()>0 && mapCase!=null){ 
                    if(mapCase.get(caseId).Status==(System.label.Presales_Initial_Status)){
                    system.debug('lstUser--->'+lstUser);
                        if(lstUser!=null){
                            for(User userLoop: lstUser){
                                if(mapCase.get(caseId).OwnerId != userLoop.Id) { 
                                    CaseTeamMember newCaseTeamMember = new CaseTeamMember();          
                                    newCaseTeamMember.MemberId = userLoop.Id;
                                    newCaseTeamMember.ParentId = caseId;
                                    newCaseTeamMember.TeamRoleId = roleId.Id;
                                    system.debug('newCaseTeamMember--->'+newCaseTeamMember);
                                    lstCaseTeamMemberUser.add(newCaseTeamMember);
                                }
                            }
                            system.debug('lstCaseTeamMemberUser--->'+lstCaseTeamMemberUser);
                            if(lstCaseTeamMemberUser!=null && lstCaseTeamMemberUser.size()>0){
                                insert lstCaseTeamMemberUser;   
                            }
                        }
                        system.debug('lstContact--->'+lstContact);
                        if(lstContact!=null){
                            for(Contact contactLoop:lstContact){
                            system.debug('contactLoop.Email--->'+contactLoop.Email);
                                if(!(mapEmailUser.containsKey(contactLoop.Email))){
                                    CaseTeamMember newCaseTeamMember = new CaseTeamMember();
                                    newCaseTeamMember.MemberId = contactLoop.Id;
                                    newCaseTeamMember.ParentId = caseId;
                                    newCaseTeamMember.TeamRoleId = roleId.Id; 
                                    lstCaseTeamMemberContact.add(newCaseTeamMember);  
                                }
                            }
                            if(lstCaseTeamMemberContact!=null && lstCaseTeamMemberContact.size()>0){
                                insert lstCaseTeamMemberContact;   
                            }
                        }   
                        
                    }
                    else if(mapCase.get(caseId).Status=='Closed'){
                        mapCase.get(caseId).IsMailAfterClose__c = true;
                        mapCase.get(caseId).From_Mail_After_Close__c = fromAddress.toLowerCase();
                        
                    }                  
            }
            if(mapCase.size()>0 && mapCase.get(caseId).Status=='Open'){
            mapCase.get(caseId).Contact_Email1__c = mapCase.get(caseId).SuppliedEmail.toLowerCase(); 
            mapCase.get(caseId).Send_Mail_On_Update__c = false;   
            mapCase.get(caseId).Is_Email_To_Case__c = true;
            mapCase.get(caseId).Email_TO_Capture__c = toAddress;
            //mapCase.get(caseId).IsCaseTeam__c = true; 
        
            system.debug('mapCase.get(caseId).Contact_Email1__c--->'+mapCase.get(caseId).Contact_Email1__c);
            //update mapCase.values();
            }
            else if(mapCase.size()==0){
                lstEmailMessage = [select Id from EmailMessage where ParentId=:caseId];
                system.debug('lstEmailMessage--->'+lstEmailMessage.size());
                mapCase = new Map<Id,Case>([select Id,IsCaseTeam__c,SuppliedEmail,Status,Contact_Email1__c,IsMailAfterClose__c,Is_Email_To_Case__c,Send_Mail_On_Update__c,OwnerId from Case where Id=:caseId]);
                if(mapCase.get(caseId).SuppliedEmail!=null && mapCase.get(caseId).Status=='Open'&& lstEmailMessage.size()==0){
                    mapCase.get(caseId).Contact_Email1__c = mapCase.get(caseId).SuppliedEmail.toLowerCase();
                }
                System.debug('Case else if-->'+mapCase);
                if(mapCase.get(caseId).Status=='Closed'){
                    mapCase.get(caseId).IsMailAfterClose__c = true;
                    mapCase.get(caseId).From_Mail_After_Close__c = fromAddress.toLowerCase();               
                }
                if(mapCase.get(caseId).Status=='Open'){
                    mapCase.get(caseId).Email_TO_Capture__c = toAddress;    
                }
            }
            System.debug('Case-->'+mapCase.get(caseId));
            
            update mapCase.values();
            System.debug('Case-->'+mapCase.get(caseId));
       }
       catch(Exception e){
            System.debug('Error during case team insertion ' + e);
       }
       System.debug('Case after catch-->'+mapCase.get(caseId));        
    }
/* @Method <This method execute is used to populate contact email in Email to Case>
@param <This method takes Id and String as parameter>
@return void - <Not returning anything>
@throws exception - <No Exception>
*/
    public void populateRequestorDetailsEmailToCase(Id caseId,String fromAddress){
        Map<Id,Case> mapCase = new Map<Id,Case>([select Id,Is_Email_To_Case__c,Status,Send_Mail_On_Update__c,OwnerId,Contact_Email1__c,IsMailAfterClose__c from Case where Id=:caseId]);
        system.debug('mapCase--->'+mapCase);
        if(mapCase.size()>0 && mapCase.get(caseId).Status=='Open'){
            mapCase.get(caseId).Contact_Email1__c = fromAddress.toLowerCase(); 
            mapCase.get(caseId).Send_Mail_On_Update__c = false;   
            mapCase.get(caseId).Is_Email_To_Case__c = true; 
        
        system.debug('mapCase.get(caseId).Contact_Email1__c--->'+mapCase.get(caseId).Contact_Email1__c);
        update mapCase.values();
        }
        /*Case caseUpdated = new Case();
        caseUpdated = [select Contact_Email1__c from Case where Id =:caseId];    
        system.debug('caseUpdated--->'+caseUpdated);*/
    }



/* defect 5055 - To chk if the incoming mail already exists in the system.If exists mark the mail as deleted.*/
public boolean chkemailContents(Id caseId, string sub, string bodyText){

boolean msgFlag= false;
if(sub != null){
Map<Id,List<EmailMessage>> mapEMsg = new Map<Id,List<EmailMessage>>();
List<EmailMessage> listEmails = [select Id,parentId,isDeleted ,TextBody from EmailMessage where parentId =: caseId and Subject =: sub ];

system.debug('Sub--->'+sub + '<---text--->' + bodyText +'<----->'+listEmails.size());


if(listEmails.size() >= 1 ){
       // msgFlag =true;
   /* for(EmailMessage EM : listEmails){
        mapEMsg.put(caseId,EM);
    }*/
    mapEMsg.put(caseId,listEmails);
}

system.debug('mapEMsg--->'+mapEMsg.size());
system.debug('body--->'+bodyText);      

if(mapEMsg.size() >0){
    system.debug('body--->'+bodyText);
   
      for(Id csId :mapEMsg.keyset()){
     for(EmailMessage e : mapEMsg.get(csId)){
         if(e.TextBody != null){
         string fetchedBody=e.TextBody;
          if(bodyText != null){
             Integer rows =  fetchedBody.compareTo(bodyText);
             if(rows == 0){
                 msgFlag =true;
             }
          }
             //system.debug('fetchedbody--->'+fetchedbody.trim());
           // system.debug('rows--->'+fetchedBody.equals(bodyText) +'<---->'+rows);
            //system.debug('length--->'+fetchedbody.length() +'---current length--->'+bodyText.length());
        }
     }
}
    
    //system.debug('rows--->'+fetchedBody.equals(bodyText));
   
    
    /*if(fetchedBody.equals(bodyText)){
        msgFlag =true;
    }*/
}


}
  
 system.debug('after mapEMsg--->'+msgFlag);
return msgFlag;     
}
}