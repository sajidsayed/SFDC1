/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  12.10.2012      Smitha       MOJO           Initial Creation. Register with GFS button on Opty. Creates/update GFS record, Validates opty tied to asset or not.
 |  19.10.2012      Avinash K   MOJO            Updated code to insert chatter feed on the Opportunity.
 |  23 Nov 2012     Suresh D    216140          Modifed code to remove District Manager validation check.
    10.01.2013      Medhavi D.   217884         Added sendmail method to send mails
    08 Mar 2013     Prachi        238113        Added code to update OpptyId for team member.
+========================================================================================================================*/

public class SFA_MOJO_RegisterWithGFSController {
    
    public Id Optyid;
    public List<Opportunity_Asset_Junction__c> lstRelAsset = new List<Opportunity_Asset_Junction__c>();
    public List<Trade_Ins_Competitive_Swap__c> lstGFSObj = new List<Trade_Ins_Competitive_Swap__c>();
    public Integer intNoAsset {get;set;} {intNoAsset = 0 ;} 
    public Integer intNotEligibleOpty {get;set;} {intNotEligibleOpty = 0 ;}
    public Integer intNotEligibleAsset {get;set;} {intNotEligibleAsset = 0 ;}
    public Set<Id> setAssetIds = new Set<Id>();
    public List<Asset__c> lstValidateAsset = new List<Asset__c>();
    public Id userAFM;
    public Opportunity opp;
    public List<OpportunityLineItem> oppProduct = new List<OpportunityLineItem>();
    //Hold Custom setting for record type ids for Competitive Install/ EMC Install.
    Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
    String strAmericasTheater ='';
    String strEMEATheater ='';
    String strAPJTheater ='';
      List<String> ccAdd = new List<String>();
    
//Following List variables has the List of Chatter feeds to be inserted      -Avinash K
    public List<FeedItem> lstFeedItem = new List<FeedItem>();
    public static Boolean blnStaticVariableInsert = false;
    public static Boolean blnStaticVariable = false;
    public static Boolean blnstaticEmailAlert=false;
//Following variable added by Avinash K
    String strUserName = '';

    public SFA_MOJO_RegisterWithGFSController(ApexPages.StandardController controller) {
    
        Optyid = ApexPages.currentPage().getParameters().get('id');
        if(Optyid==null)return;
        opp=[Select name,id,Product_Model__c,accountId,Account_TheaterText__c ,Partner__c,Country__c,Opportunity_Owner__c,District_Manager__c,District_Manager__r.Name,
        Quote_Cart_Number__c,Products__c,Opportunity_Number__c,ownerid,CloseDate,Account_Name1__c,StageName,Amount,RecordTypeId from opportunity where id =:Optyid limit 1];
        userAFM = [select id, email from user where id = :userInfo.getUserId() limit 1].id;
        //oppProduct=[select id,CurrencyIsoCode,PricebookEntryId,Product_Dependency__c,Product_Family__c, Product_Type__c,TotalPrice from OpportunityLineItem where OpportunityId =:Optyid];
        
        lstRelAsset = [select id,Related_Asset__c from Opportunity_Asset_Junction__c where Related_Opportunity__r.id = :Optyid];
        
        for(Opportunity_Asset_Junction__c assetId :lstRelAsset)
        {
            setAssetIds.add(assetId.Related_Asset__c);
        } 
        
        if((setAssetIds!=null)&&(setAssetIds.size() > 0))
        {
            lstValidateAsset = [select id,Configuration_Details__c,Total_Raw_Capacity_GB__c from Asset__c where id in:setAssetIds];
        }  
        if((lstValidateAsset!=null)&& (lstValidateAsset.size() > 0))
        {
            for(Asset__c configDetails :lstValidateAsset)
            {
                if((configDetails.Configuration_Details__c==null) ||(configDetails.Total_Raw_Capacity_GB__c==null))
                {
                    intNotEligibleAsset++;
                }
            }
        }   
        
        if((opp.accountid==null)||(opp.Country__c==null)||(opp.ownerid==null)||(opp.Opportunity_Number__c == null)||(opp.CloseDate == null) ||(opp.StageName==null)||(opp.Amount==null)||(opp.Products__c==null))
        {            
                intNotEligibleOpty++;  
        }
        if(lstRelAsset.size()<=0)
        {
            intNoAsset++;           
        }
        
        else
        {
            lstGFSObj = [select id,name,Registration_ID__c,RecordTypeid,Related_Opportunity__c, Related_Opportunity__r.Account_Name1__c, Related_Opportunity__r.id from Trade_Ins_Competitive_Swap__c where Related_Opportunity__r.id = :Optyid ];          
        }
        strAmericasTheater= DataValueMap.get('America Theater Email Notification').DataValue__c;
        strEMEATheater = DataValueMap.get('EMEA Theater Email Notification').DataValue__c;
        strAPJTheater = DataValueMap.get('APJ Theater Email Notification').DataValue__c;
        
        
    }
    
    public void Validate()
    {           
        if(intNotEligibleAsset!=0)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Asset_missing_Configuration_Details_or_Total_Raw_Capacity);
            ApexPages.addMessage(msg);
        }
        if(intNoAsset!=0)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Cannot_register_an_opportunity_without_any_assets);
            ApexPages.addMessage(msg);
        }
        
        if(intNotEligibleOpty!=0)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Not_eligible_to_register_for_GFS);
            ApexPages.addMessage(msg);
        }
    }
    
    public PageReference RegisterGFS()
    {
        Validate();
        List<OAR_Member_Added__c> lstteam=new List<OAR_Member_Added__c>();
                
        if((intNoAsset<=0)&&(intNotEligibleOpty<=0)&&(intNotEligibleAsset<=0))
        {           
            
//Code by Avinash K begins...

            if (System.Userinfo.getFirstName() != null && System.Userinfo.getFirstName() != '') 
            {
                strUserName += System.Userinfo.getFirstName();
            }
            if (System.Userinfo.getLastName() != null && System.Userinfo.getLastName() != '') 
            {
                strUserName += ' ' + System.Userinfo.getLastName();
            }
            
//Code by Avinash k ends.
            
            if(lstGFSObj.size()<=0)
            {
                // create record;   
                Trade_Ins_Competitive_Swap__c tics = new Trade_Ins_Competitive_Swap__c();
                tics.Related_Opportunity__c = Optyid;   
                tics.Sales_Rep__c = userAFM;             
                try
                {
                    insert tics;
                    //shipra
                    
                    String strBaseURL = URL.getSalesforceBaseUrl().getHost();
                    String strTradeInURL = 'https://' + strBaseURL + '/' +tics.id;
                    String strOppURL = 'https://' + strBaseURL + '/' +opp.id;
                    
                    OAR_Member_Added__c oppMemAdd= new OAR_Member_Added__c();
                    oppMemAdd.Text_1__c=opp.Id;
                    oppMemAdd.Text_2__c=opp.Name;
                    oppMemAdd.Text_3__c=opp.Opportunity_Number__c;
                    oppMemAdd.Text_4__c=opp.Account_Name1__c;
                    oppMemAdd.Text_5__c=opp.StageName;
                    oppMemAdd.Text_6__c=opp.District_Manager__r.Name;
                    oppMemAdd.Text_7__c=opp.Country__c;
                    oppMemAdd.Text_8__c=opp.Quote_Cart_Number__c;
                    oppMemAdd.Text_9__c=System.label.SWAP_Registration_Request;
                    oppMemAdd.Text_10__c=tics.ID;
                    oppMemAdd.Number_1__c=opp.Amount;
                    oppMemAdd.Text_11__c=opp.Products__c;
                    oppMemAdd.Account_1__c=opp.Partner__c;
                    //oppMemAdd.Account_2__c=opp.Tier_2_Partner__c;
                    oppMemAdd.Condition__c='GFS Registration';
                    oppMemAdd.User_1__c=opp.Opportunity_Owner__c;
                    oppMemAdd.Team_Member_Added__c=tics.Sales_Rep__c;
                    //code added by Prachi: Start
                    oppMemAdd.OpptyId_For_Team_Member__c=opp.Id;
                    //code added by Prachi: ends
                    oppMemAdd.Date_1__c=opp.CloseDate;
                    System.debug('opp.Account_TheaterText__c###'+opp.Account_TheaterText__c);
                    
                    if(opp.Account_TheaterText__c=='Americas')
                    {
                        if(strAmericasTheater!=null)
                        {
                            oppMemAdd.Email_notification_1__c=DataValueMap.get('America Theater Email Notification').DataValue__c;
                        }
                    }
                    else if(opp.Account_TheaterText__c=='EMEA')
                    {
                        if(strEMEATheater!=null)
                        {
                            oppMemAdd.Email_notification_1__c=DataValueMap.get('EMEA Theater Email Notification').DataValue__c;
                        }
                    }
                    
                    else if(opp.Account_TheaterText__c=='APJ')
                    {
                        if(strAPJTheater!=null)
                        {
                            oppMemAdd.Email_notification_1__c=DataValueMap.get('APJ Theater Email Notification').DataValue__c;
                        }
                    }
                    
                    blnstaticEmailAlert=true;
                    lstteam.add(oppMemAdd);

//Code by Avinash K begins...

                   // String strBaseURL = URL.getSalesforceBaseUrl().getHost();
                   // String strTradeInURL = 'https://' + strBaseURL + '/' +tics.id;
                   // String strOppURL = 'https://' + strBaseURL + '/' +opp.id;

                    
                    if(!blnStaticVariableInsert)
                    {
                        blnStaticVariableInsert = true;
                        FeedItem fi = new FeedItem();
                        //fi.Title = 'Return to the GFS Competitive Swap page';
                        //fi.LinkURL = strTradeInURL;
                        fi.ParentId = opp.id;
                        fi.Body = System.Label.MOJO_SWAP_Registration_Chatter_Post_Part_1 + opp.Account_Name1__c + ' : ' + strUserName + '\n \n';
                        fi.Body += System.Label.MOJO_SWAP_Registration_Chatter_Post_Part_2 + strOppURL; 


                        insert fi;
                    }

//Code by Avinash ends.


                    
                }
                Catch(DmlException e)
                {
                }
                    
            }           
            
            else
            {
                system.debug('else');                               
                
//Code by Avinash K begins...

                    String strBaseURL = URL.getSalesforceBaseUrl().getHost();

                    List<FeedItem> lstFeedItem = new List<FeedItem>();
                    
//Code by Avinash ends.

                for(Trade_Ins_Competitive_Swap__c t : lstGFSObj)
                {
                    t.Registration_ID__c = null;                    
                    t.Sales_Rep__c = userAFM;
                    t.Swap_Value__c = null;

//Code by Avinash K begins...
                    
                    
                    if(!blnStaticVariable)
                    {
                        blnStaticVariable = true;
                        String strTradeInURL = 'https://' + strBaseURL + '/' +t.id;
                        String strOppURL = 'https://' + strBaseURL + '/' +t.Related_Opportunity__r.id;

                        FeedItem fi = new FeedItem();
                        //fi.Title = 'Return to the GFS Competitive Swap page';
                        //fi.LinkURL = strTradeInURL;
                        fi.ParentId = t.Related_Opportunity__r.id;
                        fi.Body = 'UPDATE ' + System.Label.MOJO_SWAP_Registration_Chatter_Post_Part_1 + t.Related_Opportunity__r.Account_Name1__c + ' : ' + strUserName + '\n \n';
                        fi.Body += System.Label.MOJO_SWAP_Registration_Chatter_Post_Part_2 + strOppURL; 

                        lstFeedItem.add(fi);
                    }
                    

//Code by Avinash ends.
                }

                //update record
                try
                {
                    system.debug('lstGFSObj update'+lstGFSObj);
                    update lstGFSObj;
                    if(!blnstaticEmailAlert)
                    {
                        OAR_Member_Added__c oppMemAdd1= new OAR_Member_Added__c();
                        oppMemAdd1.Text_1__c=opp.Id;
                        oppMemAdd1.Text_2__c=opp.Name;
                        oppMemAdd1.Text_3__c=opp.Opportunity_Number__c;
                        oppMemAdd1.Text_4__c=opp.Account_Name1__c;
                        oppMemAdd1.Text_5__c=opp.StageName;
                        oppMemAdd1.Text_6__c=opp.District_Manager__r.Name;
                        oppMemAdd1.Text_7__c=opp.Country__c;
                        oppMemAdd1.Text_8__c=opp.Quote_Cart_Number__c;
                        oppMemAdd1.Text_9__c=System.label.Updated_SWAP_Registration_Request;
                        oppMemAdd1.Text_10__c=lstGFSObj[0].id;
                        oppMemAdd1.Number_1__c=opp.Amount;
                        oppMemAdd1.Text_11__c=opp.Products__c;
                        oppMemAdd1.Account_1__c=opp.Partner__c;
                        //oppMemAdd.Account_2__c=opp.Tier_2_Partner__c;
                        oppMemAdd1.Condition__c='GFS Registration';
                        oppMemAdd1.User_1__c=opp.Opportunity_Owner__c;
                        oppMemAdd1.Team_Member_Added__c=lstGFSObj[0].Sales_Rep__c;
                        oppMemAdd1.Date_1__c=opp.CloseDate;
                        //code added by Prachi: Start
                        oppMemAdd1.OpptyId_For_Team_Member__c=opp.Id;
                        //code added by Prachi: ends
                        /*if(opp.Account_TheaterText__c=='America')
                        {
                            oppMemAdd1.Email_notification_1__c='sangeeta.hegde@emc.com';
                        }
                        else if(opp.Account_TheaterText__c=='EMEA')
                        {
                            oppMemAdd1.Email_notification_1__c='swarup.kemparaju@emc.com';
                        }
                        else if(opp.Account_TheaterText__c=='APJ')
                        {
                            oppMemAdd1.Email_notification_1__c='aditi.bharadwaj@emc.com';
                        }
                        */
                        if(opp.Account_TheaterText__c=='Americas')
                        {
                            if(strAmericasTheater!=null)
                            {
                                oppMemAdd1.Email_notification_1__c=DataValueMap.get('America Theater Email Notification').DataValue__c;
                            }
                        }
                        else if(opp.Account_TheaterText__c=='EMEA')
                        {
                            if(strEMEATheater!=null)
                            {
                                oppMemAdd1.Email_notification_1__c=DataValueMap.get('EMEA Theater Email Notification').DataValue__c;
                            }
                        }
                        else if(opp.Account_TheaterText__c=='APJ')
                        {
                            if(strAPJTheater!=null)
                            {
                                oppMemAdd1.Email_notification_1__c=DataValueMap.get('APJ Theater Email Notification').DataValue__c;
                            }
                        }
                        lstteam.add(oppMemAdd1);
                        }
                    
                    
//Code by Avinash K begins...
                    if (lstFeedItem != null && lstFeedItem.size() > 0) 
                    {
                        insert lstFeedItem;
                    }
//Code by Avinash ends.

                }
                Catch(DmlException e)
                {
                }
            }
               if(lstteam!=null && lstteam.size()>0)
                {
                    Enterprise_Under_Pen_Email_Notification.insertEmailMemberAlertRecords(lstteam);
                    sendEmail(lstteam);
                }
                PageReference opty= new PageReference ('/'+Optyid );                
                return opty;        
        }
        return null;
    }
    
    public PageReference Cancel()
    {
        PageReference optypg= new PageReference ('/'+Optyid );                              
        return optypg;  
    }
    
    public void sendEmail(List<OAR_Member_Added__c> oarLst){
    List<String> toAdd = new List<String>();
    List<String> ccAdd = new List<String>();
    List<Id> prId = new List<Id>();
    List<String> idList = new List<String>(); 
String template;
        System.debug('oarLst--->'+oarLst[0].Id);
  List<AccountTeamMember> lstAccountMemebr = [Select a.UserId,a.TeamMemberRole  From AccountTeamMember a where a.AccountId=:opp.accountid];
      for(AccountTeamMember aObj :lstAccountMemebr){
        if(aObj.TeamMemberRole == System.Label.GFS_Area_Finance_Manager || 
            aObj.TeamMemberRole == System.Label.GFS_Channel_Finance_Manager || 
            aObj.TeamMemberRole == System.Label.GFS_Geo_Finance_Manager || 
            aObj.TeamMemberRole == System.Label.GFS_Regional_Finance_Manager || 
            aObj.TeamMemberRole == System.Label.GFS_Regional_Finance_Specialist ){
        idList.add(aObj.UserId);}
      }
   
        if(opp.Account_TheaterText__c=='Americas')
          {
          //  toAdd.add('RFS_Americas1@emc.com');
            toAdd.add(System.Label.Transformation_RFS_Americas);
          }
         else if(opp.Account_TheaterText__c=='EMEA')
          {
          //  toAdd.add('RFSEMEA1@emc.com');
            toAdd.add(System.Label.Transformation_RFSEMEA);
          }
          else if(opp.Account_TheaterText__c=='APJ')
          {
          //  toAdd.add('RFSAPJ1@emc.com');
            toAdd.add(System.Label.Transformation_RFSAPJ);
          }
          //toAdd.add('colleen.m.davis@accenture.com');
          //toAdd.add('Deidra.Zarrella@emc.com');
           toAdd.add('prachi.bhasin@accenture.com');

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
        template = 'Transformation GFS Registration';
       //template ='Register With GFS';
        
        if(toAdd.size() > 0){
            Message.setToAddresses(toAdd);   
            system.debug('toAdd--->'+toAdd);
            ccAdd.addAll(getEmailAddresses(idList));
            if(ccAdd.size() > 0){
              Message.setCcAddresses(ccAdd);
            }
            system.debug('ccAdd--->'+getEmailAddresses(idList));
            Message.setTargetObjectId(UserInfo.getUserId()); //The first Team Member ID found, this email address will not be in the emailList
    
            Message.setWhatId(oarLst[0].Id); 
            Message.setTemplateId([select id from EmailTemplate where Name =: template].id); 
            Message.SaveAsActivity = false;
            Messaging.sendEmail(new Messaging.singleemailMessage[] {message}); 
       } 
   }
   
   
    //To fetch the group member email id
   
   private List<String> getEmailAddresses(List<String> idList) {   
        List<String> mailToAddresses = new List<String>(); 
      if(idList.size() > 0){
          User[] usr = [SELECT email FROM user WHERE id IN :idList];    
          for(User u : usr) {          
          mailToAddresses.add(u.email);   
           }      
      }
        System.debug('mailToAddresses-->'+mailToAddresses); 
        return mailToAddresses;   
    }
}