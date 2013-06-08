/**
The class is to support CentralShareAttachment trigger on Attachment object

Created Date: 09/23/11
Modification History:
*/
public with sharing class CentralShareAttachmentUtility {
    public static Boolean isFromTest = false;
    
    public static void toSupportTestClass(Set<Id> sharedCaseIdSet){
        if(isFromTest && sharedCaseIdSet.size()==0){
            Case c =CentralShareAttachment_Test.prepareCase();
            sharedCaseIdSet.add(c.Id);
        }
    }
}