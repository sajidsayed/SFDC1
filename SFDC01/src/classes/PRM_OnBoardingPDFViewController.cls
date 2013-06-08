/*================================================================================================+ 
|  HISTORY  
|
|  DATE          DEVELOPER                WR       DESCRIPTION                                
|  ====          =========                ==       ===========  
| 
| 21/04/2011    Anil Sure                         This class will extract the details of New Partner Onboaridng Record 
                                                  and Generetaes the PDF View                        
================================================================================================+ */

public class PRM_OnBoardingPDFViewController {
        private final Partner_Onboarding__c POB;
         public PRM_OnBoardingPDFViewController(ApexPages.StandardController controller) 
         {
            POB = [select id,Name,Region_you_are_applying_for__c,EMC_Sponsoring_Distributor__c,First_Name__c,
                                    Last_Name__c,E_mail_Address__c,Title__c,Contact_Office_Number__c,Cell_Number__c,Corporate_URL__c,
                                    Legal_Parent_Company_Name__c,Country__c,Address_1__c,Address_2__c,City__c,State__c,Zip_Postal_Code__c,
                                    Main_Company_Phone_Number__c,Primary_EMC_Business_Line_Interest__c,Vertical_Market_Specialization__c,
                                    Application_Environments__c,Company_Overview_1000_characters_max__c,Primary_Business_Contact_First_Name__c,
                                    Primary_Business_Contact_Last_Name__c,Primary_Business_Contact_E_mail_Address__c,Primary_Business_Contact_Title__c,
                                    Primary_Business_Contact_Phone_Number__c,Primary_Business_Contact_Cell_Number__c,President_CEO_First_Name__c,
                                    President_CEO_Last_Name__c,President_CEO_E_mail_Address__c,President_CEO_Phone_Number__c,Sales_Contact_First_Name__c,
                                    Sales_Contact_Last_Name__c,Sales_Contact_E_mail_Address__c,Sales_Contact_Phone_Number__c,Marketing_Contact_First_Name__c,
                                    Marketing_Contact_Last_Name__c,Marketing_Contact_E_mail_Address__c,Marketing_Contact_Phone_Number__c,I_Accept__c,CreatedDate 
                                    from  Partner_Onboarding__c where id =:ApexPages.currentPage().getParameters().get('id')];
             
            
            }  
  
        public Partner_Onboarding__c getPOB() {    
        return POB;
        }
        }