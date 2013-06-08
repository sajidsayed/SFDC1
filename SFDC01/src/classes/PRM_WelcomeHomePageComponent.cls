/*=======================================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 

| 1/10/2010      Karthik Shivprakash      1074          This class is used for
                                                        displaying welcome 
|                                                       component in partner
                                                        portal.
| 
| 19/10/2010     Suman B                   625          Added condition to check Whether
|                                                       AccountOwner is EMC Admin.  
| 14/10/2011     Anirudh Singh             3995        Added viewAllEducation Flag in order to
|                                                      render the View All Education Link for
|                                                      only Super Users.          
             
+=======================================================================================*/


public class PRM_WelcomeHomePageComponent{

public Id AccountId; 
public String EmailId;
public boolean isPartnerFinderAdmin;
public boolean viewAllEducation {get;set;}
public string ChannelMnagerName;
public string reportId;
public string AccountName;

/** Added for Req#625 **/

public boolean isAccountEMCAdmin {get;set;}

   /*@Method <This PRM_WelcomeHomePageComponent is constructor used to fetch the 
               current user's account Id, from that account its related owner's
               email Id.>
    @param <This constructor is not taking any parameters>
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
    */

   public PRM_WelcomeHomePageComponent(){
      User CurrentUser = [Select u.ContactId,u.Contact.AccountId,
                            Is_Admin_for_Partner_Finder_Profile__c,ProfileId 
                            from User u 
                            where u.id=:UserInfo.getUserId()];
        Map<String,CustomSettingDataValueMap__c> DataValueMap= CustomSettingDataValueMap__c.getall();
        string superusers = DataValueMap.get('Super User').DataValue__c+DataValueMap.get('Super User1').DataValue__c;
        viewAllEducation = false;
        if(superusers.contains(CurrentUser.ProfileId)){
           viewAllEducation=true;
        }
        AccountId = CurrentUser.Contact.AccountId;
        System.debug('AcocuntID-->'+accountId);
        isPartnerFinderAdmin=CurrentUser.Is_Admin_for_Partner_Finder_Profile__c;
        
       Account PartnerAccount = [Select name,a.OwnerId, a.Owner.Email,owner.name
                        from Account a 
                        where a.id=:AccountId];
                        
        EmailId = PartnerAccount.Owner.Email;
        ChannelMnagerName=PartnerAccount.Owner.name;
       
       /** ADDED FOR REQ#625. CHECKING IF THE OWNER IS 'EMC Admin' **/
            isAccountEMCAdmin = FALSE ;
           if(ChannelMnagerName == 'EMC Admin') {
            isAccountEMCAdmin = TRUE;
          } 
      /** CHANGES END FOR - 625.  **/  
      
      Map<String,CustomSettingDataValueMap__c> ReportIDMap = CustomSettingDataValueMap__c.getall();
      reportId=ReportIDMap.get('My Education Report').DataValue__c;
      
      AccountName=PartnerAccount.Name; 
      
      
    }

    public string getReportId(){
        return reportId;
    }

    public  String getAccountName(){
        return AccountName;
    }
   /*@Method <This getAccountId is a getter method to get the current users 
               account Id.>
    @param <This is not taking any parameters>
    @return <Id> - <Returning account Id>
    @throws exception - <No Exception>
    */

    public Id getAccountId(){
        return AccountId;
    }
    
    
   /*@Method <This getIsPartnerFinderAdmin is a getter method to get the 
               current user is Partner Finder Admin.>
    @param <This is not taking any parameters>
    @return <Boolean> - <Partner Finder Admin>
    @throws exception - <No Exception>
    */
    
    public boolean getIsPartnerFinderAdmin(){
        return isPartnerFinderAdmin;
    }
    
         
   /*@Method <This getChannelMnagerName is a getter method to get the current 
               users channel manager.>
    @param <This is not taking any parameters>
    @return <String> - <Returning Channel Manager>
    @throws exception - <No Exception>
    */
    
    public String getChannelMnagerName(){
        return ChannelMnagerName;
    }
    
    
   /*@Method <This getEmailID is a getter method to get the current users 
               account owner's email Id.>
    @param <This is not taking any parameters>
    @return <String> - <Returning Email Id>
    @throws exception - <No Exception>
    */
    
    public String getEmailID(){
        return EmailId;
    }
    
    
   /*@Method <This setAccountId is a setter method to set the current users 
               account Id.>
    @param <This is not taking any parameters>
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
    */
    
    public void setAccountId(Id AccountId){
        this.AccountId=AccountId;
    }
    
    
   /*@Method <This setEmailId is a setter method to set the current users 
               account owner's email Id.>
    @param <This is not taking any parameters>
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
    */
    
    public void setEmailId(String EmailId){
        this.EmailId=EmailId;
    }
    
    
}