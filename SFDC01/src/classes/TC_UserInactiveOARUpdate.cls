/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class TC_UserInactiveOARUpdate 
{

    static Opportunity_Assignment_Rule__c oppAssigRuleRecord = new Opportunity_Assignment_Rule__c();
    static Profile objProfile = [Select id,Name from Profile where name=:'System Administrator'];
    static User usrObj,userObj;
            
    //static User usrObj=UserProfileTestClassDataHelper.createUser(objProfile.Id,null);
     public static testMethod void UserInsertForTest() 
    { 
        List<Account> acc = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        insert acc;
        Contact cont = UserProfileTestClassDataHelper.createContact();
        cont.AccountId=acc[0].id;
        cont.Email='test24@abc.com';
        insert cont;
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];
         System.runAs(insertUser)
        {  
           PRM_VPP_JobDataHelper.createVPPCustomSettingData();
           Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
           String distributorSuperUser = data.get('EMEA Distributor Super User').DataValue__c ;
           Profile amerUserProf = [select Id from Profile where Name=: distributorSuperUser];
           usrObj = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,cont.Id);  
           usrObj.IsActive=true;
           insert usrObj;
        }
    }
    public static testMethod void UserInactiveOARInsert() 
    {    
        UserInsertForTest();
        
        userObj = UserProfileTestClassDataHelper.createUser(objProfile.id ,null);
        //userObj.IsActive=true;
        //insert userObj;
        User runningUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];           
        System.runAs(runningUser)
        {
            test.startTest();
            
            
            // TO DO: implement unit test
            set<id> setId=new set<Id>();
            setId.add(usrObj.id);
            system.debug('test user'+userObj);
            
           /* AccessOnUserAssignmentRule__c objAccess= new AccessOnUserAssignmentRule__c();
            objAccess.UserID__c = userObj.Id;
            objAccess.EditAccess__c = true;
            Access.Name = 'TestUser';
            insert objAccess; */ 
            oppAssigRuleRecord.Resource_Name__c = usrObj.Id;
            oppAssigRuleRecord.Resource_Sales_Force__c='EMC';
            oppAssigRuleRecord.Active__c=true;
            oppAssigRuleRecord.Partner_Type__c='All Partners';
            oppAssigRuleRecord.Coverage_Model__c='A-Hunting';
            oppAssigRuleRecord.Customer_Segment__c='Enterprise Tier 1';
            oppAssigRuleRecord.Resource_Opportunity_Sales_Team_Role__c='Channel Ã¢â‚¬â€œ Execution Sales Rep';        
            insert oppAssigRuleRecord;
            UpdateOARIfUserIsInactive.deactivateOAR(setId); 
            test.stopTest(); 
        }
    } 
    
  
            
            
   /* static testMethod void UserInactiveOARUpdate() {        
        // TO DO: implement unit test
         UserInsertForTest();
         test.startTest();   
         System.debug('oppAssigRuleRecord===>'+oppAssigRuleRecord);
         usrObj.IsActive=false;
         update usrObj;
         test.stopTest();   
    }*/
    
 }