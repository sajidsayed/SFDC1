@isTest
Private Class EMCException_TC{
    Private static testMethod void startTest(){
        List<String> affected=new list<string>{'test1','test2'};
        EMCException ex=new EMCException('Error','1111',affected);
    }
}