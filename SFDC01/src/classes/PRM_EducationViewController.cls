/* =======================================================================================================================
 |  HISTORY 
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION 
 |  22/Dec/2010     Arif                        This controller is used to return Education Record Owned By Super User to page
 |  04/Jan/2010     PRasad          Defect 223  Changed the columns in query.
 |  05/Jan/2011     Anirudh                     Updated Controller to Call VF Page on click of Link
 |  21-FEB-2011     Saravanan C     Req 2071    Added new field - Comments in VF Page
 |      18/Mar/2011             Ashwini Gowda   WR# 2593        Commented the check of Super User profiles in method
 |                                                                                              getLstEducationRecord() as it was using hard corded.
 |                                                                                              Access given to only super user profiles.Currently, they get 
 |                                                                                              insufficient when clicking on the View All Education Link.
 |  25/May/2011     Anirudh Singh   WR# 2918    Updated Query to Include check for contact field not equal to null
 |                                              on Education Record.   
 |  29/Dec/2011         Suman B                 IM7439801 - Implemented Pagination for displaying Education records.
 |                                                                                              Added getEducationDetails() metohd.
 |  04/Jan/2012         Suman B                 IM7439801 - Added Name_Detail__c field in the query inside getLstEducationRecord() method. 
 |  24/Aug/2012        Ganesh                   199997    - Added a new method 'LoadEducationDetail' which is inoked from Actionfunction
 |	15/Oct/2012        Suresh D                 ERFC210627 - On pagemanger object set the no.of pages and size to zero inside the constructor.
  =========================================================================================================================  */

public class PRM_EducationViewController {
      Id EducationId;
      Public Education__c Education{get;set;}
      Education__c EducationRecord = New Education__c();
      /*Property Declaration for Values to be displayed on Page*/
      public string Name;
      public string Owner;
      public string Contact;
      public string EducationType;
      public date Date_Achieved;
      public string Category;
      public Date Expiration_Date;
      public string Level;
      public decimal Days_to_Expiration;
      public string Mentoring_Required;
      public string Education_Master;
      public string Transaction_Id;
      public string Partner_Grouping_ID;
      public string Mentoring_Completed;
      public date Mentoring_Date;
      public string Mentoring_Type;
      public boolean Mentoring_Schduled;
      public string EMC_Mentoring_Location;
      public date Mentoring_Scheduled_Date;
      public string EMC_Mentor_Name;
      public boolean CLARiiON;
      public boolean BACKUP_NETWORKER;
      public boolean NAS;
      public string First_Name;
      public string Last_Name;
      public string ESBI_Name;
      public string Partner_Grouping;
      public string Cert_Id;
      public string Country;
      public string Education_Id;
      public string SABA_Contact_ID;
      public string Email;
      public string Attention_Partners;
      public string Attention_EMC_Employees;
      public string CreatedBy;
      public string LastModifiedBy;
      public string NameDetail;
      public string Comments;
      
       public string hiddenEducationId{get;set;} 

      // paging
      public PageManager objPageManager       {get;set;}
      Map<String,CustomSettingDataValueMap__c> dataValueMap = CustomSettingDataValueMap__c.getAll();
      List<Education__c> listEducationDetails = new List<Education__c>();
      
      public PRM_EducationViewController(){
        CustomSettingDataValueMap__c pageDetails = DataValueMap.get('View_All_Education');
        
        Integer pageSize = 200;        
        try
        {            
            pageSize  = Integer.valueOf(pageDetails.DataValue__c);
            
        }
        catch(Exception e)
        {
          pageSize = 200;
        } 
         
        objPageManager = new PageManager(pageSize);
        
        //ERFC210627-Added below two lines from getLstEducationRecord method and commented overthere on Oct 15, 2012
        objPageManager.page = 0;
        objPageManager.numberOfRows =0;
        
        getLstEducationRecord();
        
    }
    
    /*public List<Education__c> getLstEducationRecord() {
       lstEducationRecord=getEducation();
       System.debug('lstEducationRecord-->'+lstEducationRecord); 
       return lstEducationRecord; 
    }*/
    
    
      //Commented by Ganesh After invoking the method LoadEducationDetail from Action function
    /*
    public PageReference searchOption() {
    	    	 
        EducationId = ApexPages.currentPage().getParameters().get('eId');      
        EducationRecord = EductaionRecord(EducationId);
        return new PageReference ('/apex/PRM_EducationDetail');
    }    
    */
    
    public PageReference LoadEducationDetail()
    {
    	System.debug('SFDCDEV******hiddenEducationId****'+hiddenEducationId);         
        EducationId  = hiddenEducationId;         
        EducationRecord = EductaionRecord(EducationId);
        return new PageReference ('/apex/PRM_EducationDetail');
    } 
    
    
    public Transient List<Education__c> lstEducationRecord = new List<Education__c>();
    List<Contact> lstContactRelatedToGrouping = new List<Contact>();
    Profiles__c lstOfIDs = Profiles__c.getOrgDefaults();
    public Boolean status=true;
    public Boolean flag=true;
    User userRecord;
    Account accountRecord;
            
    public List<Education__c> getLstEducationRecord(){
    	
    	//ERFC210627-Below lines commented by Suresh on Oct 15, 2012
    	//objPageManager.page = 0;
        //objPageManager.numberOfRows =0;
        
        System.debug('User LoggedIn--------->' +UserInfo.getProfileID());
        System.debug('Direct Reseller Super User--------->' +lstOfIds.Direct_Reseller_Super_User__c);
        System.debug('Distributor Var Super User--------->' +lstOfIds.Distribution_VAR_Super_User__c);
        System.debug('Distributor Super User--------->' +lstOfIds.Distributor_Super_User__c);
        System.debug('Non Reseller Super User--------->' +lstOfIds.Non_Reseller_Super_User__c);
        
       /* if(UserInfo.getProfileID() == lstOfIds.Direct_Reseller_Super_User__c||
           UserInfo.getProfileID() == lstOfIds.Distribution_VAR_Super_User__c||
           UserInfo.getProfileID() == lstOfIds.Distributor_Super_User__c||
           UserInfo.getProfileID() == lstOfIds.Non_Reseller_Super_User__c){*/
            userRecord = [Select u.Id,u.ContactId,u.Contact.AccountId from User u where u.Id=:UserInfo.getUserId()]; 
            System.Debug('userRecord------->' +userRecord);
            accountRecord = [Select a.Grouping__r.ID, a.Grouping__c,a.Name From Account a where a.Id=:userRecord.Contact.AccountId ];
            lstContactRelatedToGrouping = [Select Id,Name from Contact where Account.Grouping__c =:accountRecord.Grouping__c];
            System.Debug('accountRecord------->' +accountRecord);
            lstEducationRecord = [Select e.Id,e.Name, e.Active__c,e.Category__c, e.Expiration_Date__c,e.Type__c,e.Date_Achieved__c,e.Contact__r.Name,
                                  e.Contact__r.Account.Name,Comments__c,Name_Detail__c
                                  From Education__c e where e.contact__c in :lstContactRelatedToGrouping and e.contact__c!=null order by Contact__r.Name limit 5000];
            System.Debug('lstEducationRecord------->' +lstEducationRecord); 
           status=true;       
            flag=false;
      // }
       /*else{
           flag=true;
           status=false;
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'Access Denied');
           ApexPages.addMessage(msg);
       }*/
       
           return lstEducationRecord;
    }
    
    public List<Education__c> getEducationDetails(){
    	//ERFC210627-Below lines added by Suresh on Oct 15, 2012
    	if(lstEducationRecord==null)
    	getLstEducationRecord();
    	
    	listEducationDetails.clear();     
        if(lstEducationRecord != Null){        
           objPageManager.numberOfRows = lstEducationRecord.size();             
          for(integer i=objPageManager.startIndex;i<objPageManager.endIndex&&i<lstEducationRecord.size();i++){
                  listEducationDetails.add(lstEducationRecord.get(i));
          }
        }       
       return listEducationDetails ;   
    } // End of getEducationDetails- method.
    
    public Boolean getstatus(){
        System.Debug('Status----------->' +status);
        return status;
    }
    public Boolean getflag(){
        System.Debug('Flag----------->' +flag);
        return flag;
       
    }
    public Education__c EductaionRecord(Id EducationId){
        
        Education = [Select Id,OwnerId,Owner.Name,Partner_Grouping__c,Partner_Grouping__r.Name, Name, First_Name__c,Last_Name__c, Email__c, Cert_ID__c, Active__c,Category__c,
                                  Days_to_Expiration__c, Contact__c,Contact__r.Name,Expiration_Date__c,Mentoring_Required__c,Type__c,Date_Achieved__c,Level__c,Mentoring_Date__c,
                                  Attention_EMC_Employees__c,Education_Master__c,Education_Master__r.Name,Transaction_Id__c,Partner_Grouping_ID__c,Mentoring_Completed__c,
                                  Mentoring_Type__c,Name_Detail__c,Mentoring_Schduled__c,EMC_Mentoring_Location__c,Mentoring_Scheduled_Date__c,EMC_Mentor_Name__c,CLARiiON__c,
                                  CreatedById,LastModifiedById,BACKUP_NETWORKER__c,NAS__c,ESBI_Name__c,Country__c,Education_Id__c,SABA_Contact_ID__c,Attention_Partners__c,
                                  CreatedBy.Name,LastModifiedBy.Name,Comments__c 
                                  From Education__c where Id = :EducationId];
        return Education;                          
    }
  
    public string getName(){
        return EducationRecord.Name;
    }
    public string getNameDetail(){
        return EducationRecord.Name_Detail__c;
    }
    public string getOwner(){
        return EducationRecord.Owner.Name;
    }
    public string getContact(){
        return EducationRecord.Contact__r.Name;
    }
    public string getEducationType(){
        return EducationRecord.Type__c;
    }
    public date getDate_Achieved(){
        return EducationRecord.Date_Achieved__c;
    }
    public string getCategory(){
        return EducationRecord.Category__c;
    }
    public date getExpiration_Date(){
        return EducationRecord.Expiration_Date__c;
    }
    public string getLevel(){
        return EducationRecord.Level__c;
    }
    public Decimal getDays_to_Expiration(){
        Days_to_Expiration = EducationRecord.Days_to_Expiration__c;
        return Days_to_Expiration;
    }
    
    public string getMentoring_Required(){
        return EducationRecord.Mentoring_Required__c;
    }
    public string getEducation_Master(){
        return EducationRecord.Education_Master__r.Name;
    }
    public string getTransaction_Id(){
        return EducationRecord.Transaction_Id__c;
    }
    public string getPartner_Grouping_ID(){
        return EducationRecord.Partner_Grouping_ID__c;
    }
     public string getMentoring_Completed(){
        return EducationRecord.Mentoring_Completed__c;
    }
    public date getMentoring_Date(){
        return EducationRecord.Mentoring_Date__c;
    }
    public string getMentoring_Type(){
        return EducationRecord.Mentoring_Type__c;
    }
    public boolean getMentoring_Schduled(){
        return EducationRecord.Mentoring_Schduled__c;
    }
    public void setMentoring_Schduled(boolean Mentoring_Schduled){
        
    }
    public string getEMC_Mentoring_Location(){
        return EducationRecord.EMC_Mentoring_Location__c;
    }
    public date getMentoring_Scheduled_Date(){
        return EducationRecord.Mentoring_Scheduled_Date__c;
    }
    public string getEMC_Mentor_Name(){
        return EducationRecord.EMC_Mentor_Name__c;
    }
   
    public boolean getCLARiiON(){
        return EducationRecord.CLARiiON__c;
    }
    public void setCLARiiON(boolean CLARiiON){
        
    }
    
    public boolean getBACKUP_NETWORKER(){
        return EducationRecord.BACKUP_NETWORKER__c;
    }
    public void setBACKUP_NETWORKER(boolean BACKUP_NETWORKER){
        
    }
    public boolean getNAS(){
        return EducationRecord.NAS__c;
    }
    public void setNAS(boolean NAS){
        
        
    }
     public string getFirst_Name(){
        return EducationRecord.First_Name__c;
    }
     public string getLast_Name(){
        return EducationRecord.Last_Name__c;
    }
    public string getESBI_Name(){
        return EducationRecord.ESBI_Name__c;
    }
     public string getPartner_Grouping(){
        return EducationRecord.Partner_Grouping__r.Name;
    }
     public string getCert_Id(){
        return EducationRecord.Cert_Id__c;
    }
     public string getCountry(){
        return EducationRecord.Country__c;
    }
     public string getEducation_Id(){
        return EducationRecord.Education_Id__c;
    }
     public string getSABA_Contact_ID(){
        return EducationRecord.SABA_Contact_ID__c;
    }
     public string getEmail(){
        return EducationRecord.Email__c;
    }
     public string getAttention_Partners(){
        return EducationRecord.Attention_Partners__c;
    }
     public string getAttention_EMC_Employees(){
        return EducationRecord.Attention_EMC_Employees__c;
    }
    public string getCreatedBy(){
        return EducationRecord.CreatedBy.Name;
    }
    public string getLastModifiedBy(){
        return EducationRecord.LastModifiedBy.Name;
    }
    // Added for req 2071
    public string getComments(){
        return EducationRecord.Comments__c;
    }

}