/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR       DESCRIPTION                               

 |  ====          =========                ==       =========== 

 | 20/7/2010       Karthik Shivprakash     141590   This method is used to update both contact and user fields based on the current user.
 | 06/08/2010      Rajeev Choudhary        CR       make changes to reflect contact fields comes in edit mode on page.

 | 04/01/2011      Karthik Shivprakash     CR       Added "Cert Tracker Id" under Partner Information
 |                                                  section.
 | 07/08/2012      Anirudh Singh           196335   Updated Code in order to delete Original Functional Area Field.   |
 | 02/05/2013      Nimai Meher			            Commented EMC_Appointed_Membership__c field as part of WR - 256428 (Contact simplification) for June Release .
 +===========================================================================*/
public class PRM_PartnerContactProfile{
    Public Contact cont{get;set;}
    List<User> UserRecord = new List<User>();
    Map<String,String> langaugeMap = new Map<String,String>();
    //Here we are creating the controller variable
    //private ApexPages.StandardController contactController;
    public Contact contact {get;set;}
    User user;
    Public string FirstName {get;set;}
    Public String Phone {get;set;}
    Public string LastName {get;set;}
    Public string MobilePhone {get;set;}
    Public Id AccountId {get;set;}
    Public String OtherPhone {get;set;}
    Public Id ReportsToId {get;set;}
    Public string Email {get;set;}
    Public String Preferred_Contact_Method {get;set;}
    Public string Fax {get;set;}
    Public string AssistantName {get;set;}
    Public string AssistantPhone {get;set;}
    Public string Asst_Email {get;set;}
    Public List<string>  Primary_Program_Contact_for {get;set;}
    Public string Functional_Area {get;set;}
    Public Boolean Partner_Opt_Out_Notification {get;set;}
    Public string Language_Preference {get;set;}
    //Public Boolean Partner_Contact2 {get;set;}
    //Public string EMC_Appointed_Membership {get;set;}
    Public string MailingCity {get;set;}
    Public string MailingState {get;set;}
    Public string MailingPostalCode {get;set;}
    Public string MailingStreet {get;set;}
    Public string MailingCountry {get;set;}
    Public string Title {get;set;}
    //Added for R2 Jan Release
    Public String CertTrackerId {get;set;}

   List<SelectOption> language_PreferenceList ;
   public List<SelectOption> getLanguage_PreferenceList(){
        if(Language_PreferenceList ==null){
            Language_PreferenceList = new List<SelectOption>();
            Schema.DescribeFieldResult langPr_PickList = Schema.sObjectType.Contact.fields.Language_Preference__c;
            for (Schema.PickListEntry nextPickVal : langPr_PickList.getPicklistValues()){
                    Language_PreferenceList.add(new SelectOption(nextPickVal.getValue(),nextPickVal.getLabel()));

        }

            
        }
        return language_PreferenceList ; 
   }


   List<SelectOption> primary_Program_Contact_for_List ;
   public List<SelectOption> getPrimary_Program_Contact_for_List(){
        if(primary_Program_Contact_for_List == null){
            primary_Program_Contact_for_List = new List<SelectOption>();
            Schema.DescribeFieldResult pickListValues = Schema.sObjectType.Contact.fields.Primary_Program_Contact_for__c;
             //primary_Program_Contact_for_List.add(new SelectOption('None','None'));
            for (Schema.PickListEntry nextPickVal : pickListValues.getPicklistValues()){
                    primary_Program_Contact_for_List.add(new SelectOption(nextPickVal.getValue(),nextPickVal.getLabel()));

        }

            
        }
        return primary_Program_Contact_for_List ; 
   }

 
/* List<SelectOption> EMC_Appointed_MembershipList ;
   public List<SelectOption> getEMC_Appointed_MembershipList(){
        if(EMC_Appointed_MembershipList ==null){
            EMC_Appointed_MembershipList = new List<SelectOption>();
            Schema.DescribeFieldResult pickListValues = Schema.sObjectType.Contact.fields.EMC_Appointed_Membership__c;
             EMC_Appointed_MembershipList.add(new SelectOption('None','None'));
            for (Schema.PickListEntry nextPickVal : pickListValues.getPicklistValues()){
                    EMC_Appointed_MembershipList.add(new SelectOption(nextPickVal.getValue(),nextPickVal.getLabel()));

        }

            
        }
        return EMC_Appointed_MembershipList ; 
   }
*/

List<SelectOption> Preferred_Contact_MethodList ;
   public List<SelectOption> getPreferred_Contact_MethodList(){
        if(Preferred_Contact_MethodList ==null){
           Preferred_Contact_MethodList= new List<SelectOption>();
            Schema.DescribeFieldResult pickListValues = Schema.sObjectType.Contact.fields.Preferred_Contact_Method__c;
            Preferred_Contact_MethodList.add(new SelectOption('None','None'));
            for (Schema.PickListEntry nextPickVal : pickListValues.getPicklistValues()){
                    Preferred_Contact_MethodList.add(new SelectOption(nextPickVal.getValue(),nextPickVal.getLabel()));

        }

            
        }
        return Preferred_Contact_MethodList ; 
   }

List<SelectOption> Functional_AreaList ;
   public List<SelectOption> getFunctional_AreaList(){
        if(Functional_AreaList ==null){
          Functional_AreaList = new List<SelectOption>();
            Schema.DescribeFieldResult pickListValues = Schema.sObjectType.Contact.fields.Functional_Area1__c;
            Functional_AreaList.add(new SelectOption('None','None'));
            for (Schema.PickListEntry nextPickVal : pickListValues.getPicklistValues()){
                    Functional_AreaList.add(new SelectOption(nextPickVal.getValue(),nextPickVal.getLabel()));

        }

            
        }
        return Functional_AreaList ; 
   }


/* @Method <Constructor for the class>
   @param <Not taking any arguments>
   @return <void> - <returning nothing>
   @throws exception - <No Exception>
*/ 
    
    public PRM_PartnerContactProfile() {
        init();
    }

/* @Method <Setter method for contact>
   @param <This method is taking contact as arguments>
   @return <void> - <returning nothing>
   @throws exception - <No Exception>
*/ 
    
   // public void setContact(Contact contact){
    //     this.contact=contact;
    //}
    
/* @Method <Getter method for contact>
   @param <This method is not taking any arguments>
   @return <contact> - <returning contacts>
   @throws exception - <No Exception>
*/     
    
  //  public contact getContact(){
  //      return contact;
   // }

/* @Method <This is init method called during the load of the class>
   @param <This method is not taking any arguments>
   @return <void> - <returning nothing>
   @throws exception - <No Exception>
*/ 
    
    public void init(){
         
        user = [select id,contactId,Email from user where id=:UserInfo.getUserId()];
        /*contact = [select id,FirstName,Phone,LastName,MobilePhone,Title,OtherPhone,Functional_Area1__c,Email,ReportsToId,Fax,Preferred_Contact_Method__c,
                   AssistantName,Partner_Opt_Out_Notification__c,AssistantPhone,Asst_Email__c,Primary_Program_Contact_for__c,Active__c,EMC_Appointed_Membership__c,
                   Inactive_Reason__c,Language_Preference__c,DoNotCall,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet,
                   AccountId,Partner_Contact2__c,Cert_Tracker_Contact_ID__c from contact where id=:user.contactId];
         */
		contact = [select id,FirstName,Phone,LastName,MobilePhone,Title,OtherPhone,Functional_Area1__c,Email,ReportsToId,Fax,Preferred_Contact_Method__c,
                   AssistantName,Partner_Opt_Out_Notification__c,AssistantPhone,Asst_Email__c,Primary_Program_Contact_for__c,Active__c,
                   Inactive_Reason__c,Language_Preference__c,DoNotCall,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet,
                   AccountId,Partner_Contact2__c,Cert_Tracker_Contact_ID__c from contact where id=:user.contactId];


             FirstName = contact.FirstName ;
             Phone = contact.Phone ;
             LastName = contact.LastName ;
             MobilePhone = contact.MobilePhone ;
            // AccountId = contact.AccountId;
             OtherPhone = contact.OtherPhone ;
            // ReportsToId = contact.ReportsToId ;
             Email = contact.Email ;
             Primary_Program_Contact_for = new List<String>();

             if(contact.Primary_Program_Contact_for__c !=null)
                Primary_Program_Contact_for = contact.Primary_Program_Contact_for__c.split(';') ;

             Fax = contact.Fax ;
             AssistantName = contact.AssistantName ;
             AssistantPhone = contact.AssistantPhone ;
             Asst_Email = contact.Asst_Email__c ;
             Preferred_Contact_Method =  contact.Preferred_Contact_Method__c ;
             Functional_Area = contact.Functional_Area1__C ;
             Partner_Opt_Out_Notification = contact.Partner_Opt_Out_Notification__c ;
             Language_Preference = contact.Language_Preference__c ;
             //Partner_Contact2 = contact.Partner_Contact2__c ;
             //EMC_Appointed_Membership = contact.EMC_Appointed_Membership__c ;
             MailingStreet = contact.MailingStreet ;
             MailingCity = contact.MailingCity ;
             MailingState = contact.MailingState ;
             MailingPostalCode = contact.MailingPostalCode ;
             MailingCountry = contact.MailingCountry ;
             //Added for R2 Jan Release
             CertTrackerId = contact.Cert_Tracker_Contact_ID__c;
    }
    
/* @Method <Adding the values into the Map for Language>
   @param <This method is not taking any arguments>
   @return <Map<String,String>> - <returning langauge with its values>
   @throws exception - <No Exception>
*/     
    
    public Map<String,String> insertIntoMap(){
        langaugeMap.put('Bulgarian','bg');
        langaugeMap.put('Chinese(Simplified)','zh_CN');
        langaugeMap.put('Chinese(Traditional)','zh_TW');
        langaugeMap.put('Czech','cs');
        langaugeMap.put('Danish','da');
        langaugeMap.put('Dutch','nl_NL');
        langaugeMap.put('English','en_US');
        langaugeMap.put('Finnish','fi');
        langaugeMap.put('French','fr');
        langaugeMap.put('German','de');
        langaugeMap.put('Greek','el');
        langaugeMap.put('Hungarian','hu');
        langaugeMap.put('Indonesian','in');
        langaugeMap.put('Italian','it');
        langaugeMap.put('Japanese','ja');
        langaugeMap.put('Korean','ko');
        langaugeMap.put('Polish','pl');
        langaugeMap.put('Portuguese(Brazilian)','pt_BR');
        langaugeMap.put('Romanian','ro');
        langaugeMap.put('Russian','ru');
        langaugeMap.put('Spanish','es');
        langaugeMap.put('Spanish(Mexican)','es_MX');
        langaugeMap.put('Swedish','sv');
        langaugeMap.put('Thai','th');
        langaugeMap.put('Turkish','tr');
        langaugeMap.put('Ukrainian','uk');
        langaugeMap.put('Vietnamese','vi');
        return langaugeMap;
    }

/* @Method <In this method we are saving the contact fields same time updating the current user object fields>
   @param <This method is not taking any arguments>
   @return <Page Reference> - <returning to home page on save>
   @throws exception - <No Exception>
*/ 
    
    public PageReference saveAndReturnToHome(){
        //this.contact.save();
        insertIntoMap();
        try{

            System.debug('Preferred_Contact_Method============' + Preferred_Contact_Method);

            user.FirstName =  FirstName;
            user.LastName = LastName;
            user.Title = Title;
            user.Manager__c = Contact.ReportsToId;
            user.Phone = Phone;
            user.MobilePhone = MobilePhone;
            user.Email = Email;
            user.Fax = Fax;
            user.LanguageLocaleKey = langaugeMap.get(Language_Preference);
            user.City = MailingCity;
            user.Country = MailingCountry;
            user.PostalCode = MailingPostalCode;
            user.State = MailingState;
            user.Street = MailingStreet;
            user.Opt_Out_of_Notifications__c = Partner_Opt_Out_Notification;
            update user;

            contact.FirstName = FirstName ;
            contact.Phone = Phone ;
            contact.LastName = LastName ;
            contact.MobilePhone = MobilePhone ;
           // contact.AccountId = AccountId;
            contact.OtherPhone = OtherPhone ;
            contact.ReportsToId = ReportsToId ;
            contact.Email = Email ;
            String concateValues ='';
            if(Primary_Program_Contact_for !=null){
                for(String nextStr : Primary_Program_Contact_for){
                    if(nextStr !='')
                        concateValues = concateValues + nextStr + ';';
                }
            }
            if(concateValues !='')        
                contact.Primary_Program_Contact_for__c =  concateValues ;
           
            contact.Fax = Fax ;
            contact.AssistantName = AssistantName ;
            contact.AssistantPhone = AssistantPhone ;
            contact.Asst_Email__c = Asst_Email ;
            if(Preferred_Contact_Method !='None')
                contact.Preferred_Contact_Method__C = Preferred_Contact_Method ;
            else
                contact.Preferred_Contact_Method__C ='';

            if(Functional_Area !='None')
                contact.Functional_Area1__c = Functional_Area ;
            else 
                contact.Functional_Area1__c ='';

            contact.Partner_Opt_Out_Notification__c = Partner_Opt_Out_Notification ;
            contact.Language_Preference__c = Language_Preference ;
            //contact.Partner_Contact2__c = Partner_Contact2 ;
           // if(EMC_Appointed_Membership !='None')
           //      contact.EMC_Appointed_Membership__c = EMC_Appointed_Membership ;
           // else 
           //     contact.EMC_Appointed_Membership__c ='';

            contact.MailingStreet = MailingStreet ;
            contact.MailingCity = MailingCity ;
            contact.MailingState = MailingState ;
            contact.MailingPostalCode = MailingPostalCode ;
            contact.MailingCountry = MailingCountry ;
            //Added for R2 Jan Release
            contact.Cert_Tracker_Contact_ID__c = CertTrackerId;
            
            update contact;
        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
            return null ;
        }
        return new PageReference('/home/home.jsp');
    }
}