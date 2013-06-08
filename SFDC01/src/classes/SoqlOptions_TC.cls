/**

Created By      :   Avinash Kaltari
Created Date    :   24 May 2012
Purpose         :   To increase the coverage of SoqlOptions class

*/
@isTest
private class SoqlOptions_TC 
{

    static testMethod void SoqlOptionsTest() 
    {
        SoqlOptions so = new SoqlOptions();
        
        so = so.wildcardStringsInLikeOperators();
        
        so = so.doNotEscapeSingleQuotes();
    }
}