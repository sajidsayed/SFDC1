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
@isTest(SeeAllData=true)
private class Search_SetupTests {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        PageReference pageRef = Page.Search_Setup;
        Test.setCurrentPage(pageRef);
      
        SetupSearchComponentCls controller = new SetupSearchComponentCls();
        controller.selectedObject='Opportunity';
        controller.retrieveChildren();
        list<String> tmpLookUpflds= new list<string> ();
        tmpLookUpflds.add('Account');
        controller.selectedLookupFlds = tmpLookUpflds; 
        List<String> tmpDisplayFlds = new list<String>();
        tmpDisplayFlds.add('Id');
        tmpDisplayFlds.add('Name');
        tmpDisplayFlds.add('Account');
        tmpDisplayFlds.add('Amount');
        tmpDisplayFlds.add('Type');
        controller.lstDisplayFields = tmpDisplayFlds;
        controller.Save();
      
        }
    
    static testMethod void searchDataControllerUnitTest(){
        PageReference pageRef = Page.Search_Data;
        Test.setCurrentPage(pageRef);
      
        SearchController controller = new SearchController();
        controller.setSSelectedObject('Contact');
        controller.strSelRelationship= 'Contact & Account';
        
        controller.Search();
    	
    }
}