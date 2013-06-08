/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  28/03/2011        Arif      Req#162077 This controller is associated with PRM_PartnerOnBoardingPage 
                                           and PRM_PartnerOnBoardingSuccessPage.Used to save record in
                                           Partner Onboarding Object     
 | 17/05/2012         Arif      192906     Used property for EMC Sponsoring Distributor field                                    
 +==================================================================================================================**/
public class PRM_PartnerOnboardingExtensionController { 
        public ApexPages.StandardController stdCon;
        public Boolean flag = false;
        public Partner_Onboarding__c POB{get;set;}
        public static Id checkRecordID;
        public string EMCSponsoringDistributor{get;set;}
        
        public PRM_PartnerOnboardingExtensionController(ApexPages.StandardController stdController){
            stdCon = stdController;
            this.POB = (Partner_Onboarding__c)stdController.getRecord();
            PageReference pageRef = ApexPages.currentPage();
            lang=pageRef.getParameters().get('lang');  
            if(lang==''|| lang==null){
                lang='en_US';
            }
            system.debug('lang '+lang);
            caption='Click if you will be the primary business contact';
        }
        public PageReference save(){  
         //public void save(){    
            if(POB.I_will_be_the_primary_business_contact_f__c == true){
                POB.Primary_Business_Contact_Cell_Number__c = POB.Cell_Number__c;
                POB.Primary_Business_Contact_E_mail_Address__c = POB.E_mail_Address__c;
                POB.Primary_Business_Contact_First_Name__c = POB.First_Name__c;
                POB.Primary_Business_Contact_Last_Name__c = POB.Last_Name__c;
                POB.Primary_Business_Contact_Phone_Number__c = POB.Contact_Office_Number__c;
                POB.Primary_Business_Contact_Title__c = POB.Title__c;  
            }
            if(EMCSponsoringDistributor == null || EMCSponsoringDistributor == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,System.Label.Kindly_Populate_the_value_for_EMC_Sponsoring_Distributor_field));
                return null;
            }else{
                POB.EMC_Sponsoring_Distributor__c = EMCSponsoringDistributor;    
                stdCon.save();
                checkRecordID = stdCon.getID(); 
                
                if (checkRecordID <> NULL){
                    PageReference returnUrl = new PageReference('/apex/PRM_PartnerOnboardingSuccessPage');
                    return returnUrl;
                }
                else
                {
                    return NULL;
                }
            }    
            
            /* if(status){
                PageReference returnUrl = new PageReference('/apex/PartnerOnboardingSuccessPage');
                return returnUrl;   
             } */
             
                            
        }
        
        // Method to get Application ID
        public String getApplicationID(){
            system.debug('checkRecordID=='+checkRecordID);
            Partner_Onboarding__c pob =[select id,name from Partner_Onboarding__c where id = :checkRecordID];
            return pob.name;
        }
        
        public Boolean getflag(){
            return flag;
        }
        public void setflag(Boolean Flag){
            this.flag = flag;
        }
       
        public void populatefields(){
            flag = false;        
        } 
        
                       
        
        public PageReference reset(){
                PageReference returnUrl = new PageReference('/apex/PartnerOnboardingPageStd');
                return returnUrl;
        }
            
    // language logic
    public PageReference chnageLang() {
        //return ApexPages.currentPage();
        return new PageReference('/apex/PRM_PartnerOnBoardingPage?lang='+lang);
        
    }

    public String items;
    public String lang { get; set; }
    
    public List<SelectOption> getItems() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('en_US',' English'));
            options.add(new SelectOption('de','German'));
            options.add(new SelectOption('Ko','Korean'));
            options.add(new SelectOption('ja','Japanese'));
            options.add(new SelectOption('fr','French'));
            options.add(new SelectOption('zh_CN','Chinese'));
            options.add(new SelectOption('it','Italian'));
            options.add(new SelectOption('pt_BR','Portuguese'));
            options.add(new SelectOption('es','Spanish'));
            return options;
        }


  boolean primaryContact=false;
  public String caption{ get; set; }
  public PageReference primaryContactAction() {
        
        primaryContact=!primaryContact;
        POB.I_will_be_the_primary_business_contact_f__c=primaryContact;
        if(primaryContact){
            caption=Label.Click_if_you_will_NOT_be_the_primary_business_contact ;
           
        }else{
            caption=Label.Click_if_you_will_be_the_primary_business_contact;
        }
        return null;
    }
    
  }