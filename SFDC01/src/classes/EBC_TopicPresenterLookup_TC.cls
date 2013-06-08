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
 
 Modified By    :   Avinash K
 Modified Date  :   25 May 2012
 Purpose        :   To increase the coverage for EBC_TopicPresenterLookup class
 
 */
@isTest
private class EBC_TopicPresenterLookup_TC {

static testMethod void EBC_TopicPresenterLookup() {
        EBC_Topics__c topic =new EBC_Topics__c(Name='topic');
        insert topic;
        ApexPages.currentPage().getParameters().put('Topic','topic');
        EBC_TopicPresenterLookup TP_Lookup=new EBC_TopicPresenterLookup();
        TP_Lookup.searchTopicValue='topic';
        TP_Lookup.getPresenterName();
        TP_Lookup.getsearchTopicName();
        TP_Lookup.setsearchTopicName('topic');
        TP_Lookup.setPresenterName('topic');
        TP_Lookup.gettp();
        TP_Lookup.doSearch();
        
        TP_Lookup.PresenterName = '';
        //TP_Lookup.location = '';
        //TP_Lookup.areaOfExpertise = '';
        TP_Lookup.doSearch();
        
        ApexPages.currentPage().getParameters().put('Topic','');
        EBC_TopicPresenterLookup TP_Lookup1 = new EBC_TopicPresenterLookup();
        TP_Lookup1.setPresenterName('topic');
        TP_Lookup1.location = 'Bangalore';
        TP_Lookup1.doSearch();
        
        TP_Lookup1.PresenterName = '';
        TP_Lookup1.doSearch();
        
        TP_Lookup1.areaOfExpertise = 'CallCenter';
        TP_Lookup1.doSearch();
        
        TP_Lookup1.location = '';
        TP_Lookup1.doSearch();
        
        ApexPages.currentPage().getParameters().put('Topic','');
        EBC_TopicPresenterLookup TP_Lookup3 = new EBC_TopicPresenterLookup();
        TP_Lookup3.PresenterName = '';
        TP_Lookup3.location = '';
        TP_Lookup3.areaOfExpertise = '';
        ApexPages.currentPage().getParameters().put('Topic','');
        TP_Lookup3.doSearch();
        
        
    }
}