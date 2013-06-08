/**

Created By		:	Avinash Kaltari
Created Date	:	21 May 2012
Purpose			:	To increase the coverage of UserProfileTestClassDataHelper class

*/
@isTest
private class UserProfileTestClassDataHelper_TC 
{

    static testMethod void UserProfileTestClassDataHelperTest() 
    {
    	Profile p = [select name from Profile limit 1];
    	UserRole r = [select name from UserRole limit 1];
    	Contact c = [select name from Contact limit 1];
    	
    	
    	User u = UserProfileTestClassDataHelper.createUser(p.id, r.id);
    	
    	u = UserProfileTestClassDataHelper.createPortalUser(p.id, r.id, c.id);
    	
    	Contact con = UserProfileTestClassDataHelper.createContact();
    	
    	Education__c edu = UserProfileTestClassDataHelper.createEducation();
    	
    	Account acc = UserProfileTestClassDataHelper.getAccount();
    	
    	con = UserProfileTestClassDataHelper.getContact();
    	
    	u = UserProfileTestClassDataHelper.fetchPartnerUser();
    	
    	Lead l = UserProfileTestClassDataHelper.getLead();
    	
    }
}