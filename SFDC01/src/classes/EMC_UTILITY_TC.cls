@isTest
Private Class EMC_UTILITY_TC{
    Private static testMethod void startTest(){
        List<String> collection01=new list<string>{'test1','test2'};
        EMC_UTILITY.ListAsString(collection01,';');
        EMC_UTILITY.generateRandomInt(1);
        EMC_UTILITY.generateRandomString(2);
    }
}