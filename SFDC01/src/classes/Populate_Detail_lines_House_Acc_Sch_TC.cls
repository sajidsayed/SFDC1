/*=====================================================================================================+

|  HISTORY  |                                                                            

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 
                                                       
| 11/20/2012     Krishna Pydavula        212217        This Test class is used to coverage the code for "Populate_Detail_lines_House_Acc_Schedule" 
                                                       and "Populate_Detail_lines_House_Account" Classes. 
                                                                                                          
+=====================================================================================================*/
@IsTest
private class Populate_Detail_lines_House_Acc_Sch_TC {

    static testMethod void populatedetails() {
        List<Opportunity> Opp = [Select o.Id,o.AccountId, o.IsClosed,o.Partner__c, o.Tier_2_Partner__c,o.OwnerId from Opportunity o where o.IsClosed = false and o.Id in(select OpportunityId from OpportunityLineItem) limit 5];
        User u=[Select id,name from User where name='House Account' AND Isactive=True limit 1];
        HouseAccount__c houseacc=new HouseAccount__c(House_Account_User__c=u.id); 
        Database.upsert(houseacc,false);
        CustomSettingDataValueMap__c Querylimit = new CustomSettingDataValueMap__c();
        Querylimit.Name ='Oppty query limit';
        Querylimit.DataValue__c ='10';
        Database.upsert(Querylimit,false);
        Populate_Detail_lines_House_Account details=new Populate_Detail_lines_House_Account();
        details.query ='select Id,OpportunityId,PricebookEntry.Product2Id,UnitPrice,Opportunity.CurrencyIsoCode,Quote_Amount__c from OpportunityLineItem where OpportunityId in:Opp limit 100';
        Populate_Detail_lines_House_Acc_Schedule sh1 = new Populate_Detail_lines_House_Acc_Schedule();        
        String sch = '0 0 23 * * ?';        
        System.Test.startTest();
        system.schedule('Test Check', sch, sh1);
        id  batchid = Database.executeBatch(details);
        System.Test.stopTest();
        
                  
    }
}