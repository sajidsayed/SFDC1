/*

Test Class Name: ReportingSegmentationValuesPopulation_TC
Task: To cover the code for the trigger,ReportingSegmentationValuesPopulation
Author: Jayaraju Nulakachandanam
 
*/

/* Date of Modification        Release        Purpose                                        Modified by
	09-jan-2013                January        Test calss erros fix                           Krishna pydavula 

*/
@isTest(SeeAllData=true)
public class ReportingSegmentationValuesPopulation_TC
{
     static testMethod void ReportingSegmentation()
    {
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];
    	system.runAs(insertuser)
    	{
        //Creating an Account
             Account a = new Account();
             a.name = 'Testing Account234POB';
             a.Profiled_Account_Flag__c = true;
            insert  a;
            a.IsPartner = true;
            update  a;
        
        //Creating Auth Reseller Onboarding (Partner_Onboarding__c)
                 
            Partner_Onboarding__c pobRecord = new Partner_Onboarding__c();
               pobRecord.Region_you_are_applying_for__c = 'APJ';
                pobRecord.EMC_Sponsoring_Distributor__c = 'UNITTESTdistri';
                pobRecord.First_Name__c = 'UNITTESTFrstName';
                pobRecord.Last_Name__c = 'UNITTESTLastName';
                pobRecord.E_mail_Address__c = 'UNITTESTEmail@test.com' ;
                pobRecord.Title__c = 'UNITTESTTitle';
                pobRecord.Contact_Office_Number__c = '54485871';
                pobRecord.Corporate_URL__c = 'UNITTESTUrl@test.com' ;
                pobRecord.Legal_Parent_Company_Name__c = 'UNITTESTCompany';
                pobRecord.Country__c = 'India';
                pobRecord.Main_Company_Phone_Number__c = '54634656';
                pobRecord.Address_1__c = 'UNITTESTAddress1';
                pobRecord.City__c = 'UNITTESTCity';
                pobRecord.State__c='Andhra Pradesh';
                pobRecord.Zip_Postal_Code__c = '4515';
                pobRecord.Primary_EMC_Business_Line_Interest__c = 'Storage';
                pobRecord.Vertical_Market_Specialization__c = 'Construction';
                pobRecord.Application_Environments__c = 'Oracle';
                pobRecord.Company_Overview_1000_characters_max__c = 'UNITTESTCmpnyOverview';
                pobRecord.Primary_Business_Contact_First_Name__c = 'UNITTESTFrstNameBusiness';
                pobRecord.President_CEO_First_Name__c = 'UNITTESTFrstNameCEO';
                pobRecord.Primary_Business_Contact_Last_Name__c = 'UNITTESTLastNameBusiness';
                pobRecord.President_CEO_Last_Name__c = 'UNITTESTLastNameCEO';
                pobRecord.Primary_Business_Contact_E_mail_Address__c = 'UNITTESTEmail@test.com' ;
                pobRecord.President_CEO_E_mail_Address__c = 'UNITTESTEmail@test.com' ;
                pobRecord.Primary_Business_Contact_Title__c = 'UNITTESTTitleBusiness';
                pobRecord.President_CEO_Phone_Number__c = '16831655';
                pobRecord.Primary_Business_Contact_Phone_Number__c = '15461645';
                pobRecord.I_Accept__c = True;
                pobRecord.Authorized_Reseller_Account__c=a.id;
            
            insert pobRecord;
        
        
        //Creating Reseller Onboarding Task (Authorized_Reseller_Onboarding_Task__c)
            Id rt =[select id from RecordType where sObjectType='Authorized_Reseller_Onboarding_Task__c' and Name='Task Step 3a,3b,3c' limit 1][0].Id;
           
            Authorized_Reseller_Onboarding_Task__c AROT = new Authorized_Reseller_Onboarding_Task__c();
            AROT.RecordTypeId=rt;
            AROT.Name='Step-3b-008';
            AROT.Partner_Onboarding__c = pobRecord.id;            
            insert AROT;
            a.Reporting_Segmentation_Group__c = 'Distributor';
            a.Reporting_Segmentation__c='RESELLER - INDIRECT RESELLER';                  
            update a;                     
            
                
    	}
    }
}