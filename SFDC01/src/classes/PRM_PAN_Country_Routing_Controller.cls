/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req     DESCRIPTION                               
 |  ====            =========       ======     ===========  
 |  02.9.2012      Anand Sharma               Controller for the PRM_PAN_VPP_Scorecard Component page.
 |  25.9.2012      Anirudh Singh              Updated code to show error message for Distributor Users
 |                                            when they try to view Distribution VAR PAN scorecards.
+=============================================================================================================================*/
public class PRM_PAN_Country_Routing_Controller{
    public Id profileAccountId;
    public string isScorecard;
    User currentUser;
    public PRM_PAN_Country_Routing_Controller(){
       if(userinfo.getUserType() == 'PowerPartner'){                   
            currentUser = [Select u.ContactId, u.Contact.AccountId,contact.Account.PROFILED_ACCOUNT_FLAG__c,
                           contact.Account.Profiled_Account__c,u.Velocity_Access__c, u.Co_Op_Access__c,
                           contact.Account.Partner_Type__c
                           from User u 
                           where id=:userinfo.getUserId()];
            if(ApexPages.currentPage().getParameters().get('Id')!=null){               
                if(ApexPages.currentPage().getParameters().get('Id').startswith('001')){               
                    profileAccountId = ApexPages.currentPage().getParameters().get('Id'); 
                }  
            }    
            if(currentUser.contact.AccountId != profileAccountId && profileAccountId !=null){
               profileAccountId = profileAccountId; 
            }               
            else if(currentUser.contact.Account.PROFILED_ACCOUNT_FLAG__c){
                profileAccountId = currentUser.contact.AccountId;
            } 
            else if(currentUser.contact.Account.Profiled_Account__c != null){
                profileAccountId = currentUser.contact.Account.Profiled_Account__c;
            } 
            isScorecard = ApexPages.currentPage().getParameters().get('isScoreCard');      
       }else{
           profileAccountId = ApexPages.currentPage().getParameters().get('Id');
           isScorecard = ApexPages.currentPage().getParameters().get('isScoreCard'); 
           system.debug('profileAccountId --------->' +profileAccountId );
           system.debug('isScorecard --------->' +isScorecard );
       }
    }
    public PageReference returnToPANORCountryPage(){
        //PageReference returnURL = new PageReference('/'+ profileAccountId);
        PageReference returnURL = null;
        Account profiledAccount = [Select Id,Account_Level__c from account where Id =: profileAccountId];
        system.debug('profiledAccount --------->' +profiledAccount );
        if(userinfo.getuserType()=='PowerPartner' && (currentUser.contact.AccountId != profileAccountId 
           && currentUser.contact.Account.Profiled_Account__c != profileAccountId ) && profiledAccount.Account_Level__c != 'NONE' && profiledAccount.Account_Level__c != 'COUNTRY'){
           ApexPages.Message errormessage = new ApexPages.Message(ApexPages.Severity.Error, System.Label.Insufficient_Access_To_VPP_Scorecards);
           ApexPages.addmessage(errormessage); 
           
        }   
        else if(profiledAccount.Account_Level__c == 'COUNTRY' && isScorecard == 'T'){
            returnURL = new PageReference('/apex/PRM_VPP_Velocity_Scorecard?id='+profileAccountId);
        }
        else if(profiledAccount.Account_Level__c == 'COUNTRY' && isScorecard == 'F'){
            returnURL = new PageReference('/apex/PRM_VPP_VelocitySpecialities?id='+profileAccountId);
        }
        else if(profiledAccount.Account_Level__c != 'NONE' && profiledAccount.Account_Level__c != 'COUNTRY' && isScorecard == 'T'){
            returnURL = new PageReference('/apex/PRM_PAN_VPP_Scorecard?id='+profileAccountId);
        }
        else if(profiledAccount.Account_Level__c != 'NONE' && profiledAccount.Account_Level__c != 'COUNTRY' && isScorecard == 'F'){
            returnURL = new PageReference('/apex/PRM_PAN_VPP_Specialty?id='+profileAccountId);
        }
        system.debug('returnURL --------->' +returnURL);
        return returnURL;
    }
}