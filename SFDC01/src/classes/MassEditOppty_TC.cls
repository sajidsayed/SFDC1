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
 
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  06.12.2010      Shipra Misra    151285      Initial Creation of Test Class.Test Class for MassEditOppty.cls used for Inline Edit button on Opportunity List View.  
    11.6.2011       Srinivas N                  line 'System.currentPageReference().getParameters().put('retURL', '/006/o');' to avoid NullPointer error from MassEditOpty class
 +========================================================================================================================*/

 
@isTest
private class MassEditOppty_TC {

    static testMethod void massInlineEditPageTest() {
        // TO DO: implement unit test
        // Create List Of account 
        List<Account> accToBeAdded = new List<Account>();
        for(Integer i=0;i<10;i++)
        {
            Account accNew =new Account(Name='Test Account**'+i,CurrencyIsoCode='USD'); 
            accToBeAdded.add(accNew);
        }
        //Insert Accounts.
        insert accToBeAdded;
        //Creating Oppty 
        List<Opportunity> lstOppty=new List<Opportunity>();     
        for(Integer i = 0; i < 10; i++)
        {
          // Creating OAR Rrecord for Named Partner with same Tier1 Partner.
          //Added new fields Renewals Sales Stage - WR #230704
          Opportunity Oppty = new Opportunity(Name = 'Test Opportunity ' + i
                            ,AccountId=accToBeAdded.get(i).id
                                    ,Sales_Force__c='EMC'
                                    ,CurrencyIsoCode='USD',
                                    StageName ='Pipeline',CloseDate = System.today(),VCE_Related__c='VMWare Other',Amount = 500,Renewals_Sales_Stage__c ='7.Submitted for Booking',Close_Comments__c = 'Duplicate',Closed_Reason__c = 'Closed_Reason__c' );
            lstOppty.add(Oppty);
        }
        //Insert the records that cause the trigger to execute.
        test.startTest();
        insert lstOppty;
        for(Integer j=0; j<10;j++)
        {
            lstOppty.get(j).Amount=lstOppty.get(j).Amount+100;
        }
        ApexPages.StandardSetController oppController=new ApexPages.StandardSetController(lstOppty);
        /* All Record are selected */
        oppController.setSelected(lstOppty); 
        System.currentPageReference().getParameters().put('retURL', '/006/o');
        MassEditOppty massEdOpp= new MassEditOppty(oppController);
        massEdOpp.customSave();
        test.stopTest();
    }
}