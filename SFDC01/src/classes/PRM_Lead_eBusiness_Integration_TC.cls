/*===================================================================================================================================

History 

7th Aug 2012  Kaustav Debnath     This is the test class for testing the PRM_Lead_eBusiness_Integration class
====================================================================================================================================*/
@isTest
private class PRM_Lead_eBusiness_Integration_TC {

public static List<Lead> createLead()
{
    List<Lead> lstLead=new List<Lead>();
    for(Integer iCount=0;iCount<2;iCount++)
    {
        Lead leadObj=new Lead();
        leadObj.Lead_Originator__c='eStore';
        leadObj.FirstName='testFirstName'+iCount;
        leadObj.LastName='testLastName'+iCount;
        leadObj.Company='testCompany'+iCount;
        leadObj.Sales_Force__c='testSalesForce'+iCount;
        
        lstLead.add(leadObj);
        
    }
    return lstLead;
}
public static List<Account> createProfiledAccount(){
            list<Account> lstPartnerAccount = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
            lstPartnerAccount[0].name = 'Distributor Account for eBusiness';
            lstPartnerAccount[2].name = 'Distributor Account for eBusiness';
            insert lstPartnerAccount;
            lstPartnerAccount[0].PROFILED_ACCOUNT_FLAG__c = true;
            lstPartnerAccount[0].Ispartner=true;
            lstPartnerAccount[2].PROFILED_ACCOUNT_FLAG__c = true;
            lstPartnerAccount[2].Ispartner=true;
            update lstPartnerAccount;
            return lstPartnerAccount;
}
        
/*Method for Creation of PartnerContact*/
public static List<Contact> createPartnercontact(List<Account> ProfiledAccount){
            
            List<Contact> lstContact = new List<Contact>();
            Contact contact1 = new Contact();
            contact1.FirstName='Test Disti Contact';
            contact1.LastName='no Partner SE and no Inside';
            contact1.AccountId = ProfiledAccount[0].Id;
            contact1.Email = 'Contact1@abc.com';
            contact1.Active__c = true;
            lstContact.add(contact1);
            
            Contact contact2 = new Contact();
            contact2.FirstName='Test Disti Contact';
            contact2.LastName='no Partner SE and no Inside';
            contact2.AccountId = ProfiledAccount[0].Id;
            contact2.Email = 'Contact2@abc.com';
            contact2.Active__c = true;
            lstContact.add(contact2);
            insert lstContact;
            return lstContact;
            
}
 public static List<User> createPortalUsers(List<Contact> lstContact){
            User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
            System.runAs(insertUser)
            {
            PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
            }
            Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
            String AmericasDistributorCAP = data.get('AmericasDistributorCAP').DataValue__c;
            List<User> lstPartnerUsers = new List<User>();
            User PartnerUsertoadd;
            //List<Account> lstaccounts = createProfiledAccount();       
            //List<Contact> lstContact = createPartnercontact(lstaccounts);
            //for(Integer i=0;i<lstContact.size();i++)
            //{
                //lstContact[i].Email = 'Contact44'+i+'@abc.com';
            //}
            //update lstContact;            
            System.runAs(insertUser)
            {       
               String distributorSuperUser = data.get('EMEA Distributor Super User').DataValue__c ;
               Profile amerUserProf = [select Id from Profile where Name=: distributorSuperUser];
               for(integer i=0;i<lstContact.size();i++)
               PartnerUsertoadd = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,lstContact[i].Id);
               lstPartnerUsers.add(PartnerUsertoadd);              
            } 
            insert lstPartnerUsers;
            return lstPartnerUsers;
        }
    static testMethod void myUnitTest() {
        
        List<Lead> lstLeadToUpdate=new List<Lead>();        
        Set<Id> setLeadIds=new Set<Id>();
        List<Integration_Log__C> lstIntegration=new List<Integration_Log__C>();
        List<Lead> lstLeadToInsert=createLead();
        List<User> lstPartnerUsers = new list<User>();
            
        if(lstLeadToInsert!=null && lstLeadToInsert.size()>0)
        {
            System.debug('### Util.iseBusinessLeadInsert=>'+Util.iseBusinessLeadInsert);
            insert lstLeadToInsert;
            System.debug('### Util.iseBusinessLeadInsert after insert=>'+Util.iseBusinessLeadInsert);
            for(Integer iCount=0;iCount<lstLeadToInsert.size();iCount++)
            {
                lstLeadToInsert[iCount].eBus_Lead_Status__c='Accepted';
                lstLeadToInsert[iCount].eBus_RFQ_ID__c='Test_'+iCount;
                setLeadIds.add(lstLeadToInsert[iCount].id);
                lstLeadToUpdate.add(lstLeadToInsert[iCount]);
                Integration_Log__c intLogObj=new Integration_Log__c();
                intLogObj.SFDC_Object_ID__c=lstLeadToInsert[iCount].id;
                if(iCount==0)
                {
                    intLogObj.Integration_Status__c='SYNC COMPLETED';
                }
                else if(iCount==1)
                {
                    intLogObj.Integration_Status__c='NEW';
                }
                lstIntegration.add(intLogObj);
            }
            if(lstLeadToUpdate.size()>0)
            {
                if(lstIntegration!=null && lstIntegration.size()>0)         
                {
                    insert lstIntegration;
                }
                System.debug('#### lstIntegration=>'+lstIntegration);
                System.debug('#### lstLeadToUpdate=>'+lstLeadToUpdate);
                User systemUser=[select id,name from user where profile.Name='System Administrator' and isActive=true limit 1];
                Queuesobject testQueue=[select id,queueid from Queuesobject where sObjecttype='Lead' limit 1];
                
                List<Account> lstaccounts = createProfiledAccount();       
                List<Contact> lstContact = createPartnercontact(lstaccounts);
                System.runAs(systemUser)
                {
                    PRM_VPP_JobDataHelper.createVPPCustomSettingData();        
                    //lstPartnerUsers = createPortalUsers(lstContact);
                            
                }
                Util.iseBusinessLeadInsert=false;
                System.debug('### Util.iseBusinessLeadInsert before update=>'+Util.iseBusinessLeadInsert);
                update lstLeadToUpdate;
                System.debug('### Util.iseBusinessLeadInsert after update=>'+Util.iseBusinessLeadInsert);
                for(Integer iCount=0;iCount<lstLeadToUpdate.size();iCount++)
                {
                    lstLeadToUpdate[iCount].eBus_Lead_Status__c='Rejected';
                    lstLeadToUpdate[iCount].eBus_RFQ_ID__c='Test_'+iCount+1; 
                    setLeadIds.add(lstLeadToInsert[iCount].id);
                            //lstLeadToUpdate.add(lstLeadToInsert[iCount]);
                        }
                        if(lstLeadToUpdate.size()>0)
                        {
                            update lstLeadToUpdate;
                            if(testQueue!=null)
                            {
                                lstLeadToUpdate[0].OwnerId=testQueue.queueid;
                            }
                            lstLeadToUpdate[0].EMC_Lead_Rejected__c=true; 
                            if(lstLeadToUpdate.size()>0)
                            {
                                update lstLeadToUpdate;
                            }
                        }
                }
        } 
    }
}