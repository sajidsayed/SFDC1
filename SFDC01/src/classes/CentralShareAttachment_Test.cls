/**
The trigger to create attachment to the sharing org as the
associated case has been already shared with the shared org

@Note: To deploy this test class the EMC S2S connection must be present. Also must be present
VCEStatic__c custom setting and "VCECaseRecordType" recordType value in the custom setting

Created Date: 09/23/11
Modification History:
*/
@isTest
public class CentralShareAttachment_Test {

    static VCEStatic__c taskRecType = VCEStatic__c.getInstance('VCETaskRecordType');    
    static VCEStatic__c caseRecType = VCEStatic__c.getInstance('VCECaseRecordType');

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        VCEStatic__c vceCs = prepareCustomSetting();
        Case c = prepareCase();
        PartnerNetworkRecordConnection pc = preparePartnerNetworkConnection(c, vceCs.Value__c);
        CentralShareAttachmentUtility.isFromTest=true;
        Attachment att = new Attachment(ParentId=c.Id, Name='TestAtt', Description='Test Descriptioin');
        att.Body =Blob.valueOf('Test');
        //att.
        insert att;
        CentralShareAttachmentUtility.isFromTest=false;
    }
    
    public static Case prepareCase(){
        String subject = 'Case 001 -- Attachment Test' + DateTime.newInstance(2010,12,1).date();        
        Case c = new Case();        
        c.Origin = 'EMC';        
        c.Status = 'Assigned - Relief';        
        c.Subject = subject;        
        c.VCE_Last_Modifying_Partner__c = 'EMC';        
        c.VCE_Originator_Open_Date__c = System.DateTime.now();        
        c.VCE_Theater__c = 'EMEA';        
        c.Priority = 'S1';        
        c.RecordTypeId = caseRecType.Value__c;        
        insert c;                      
        return c;
    }
    
    private static PartnerNetworkRecordConnection preparePartnerNetworkConnection(Case c, String cId){
        PartnerNetworkRecordConnection pc = new PartnerNetworkRecordConnection(LocalRecordId = c.Id
        , connectionid = cId);
        insert pc;
        return pc;
    }
    private static VCEStatic__c prepareCustomSetting()
    {
        VCEStatic__c vceCs = VCEStatic__c.getInstance('ConnectionId');
        if(vceCs==null){
            List<PartnerNetworkConnection> pc = [select id, connectionname, connectionstatus from partnernetworkconnection where connectionstatus = 'Accepted'];
            if(pc != null && pc.size()>0){
                Id connectionId = pc[0].Id;
                VCEStatic__c v = new VCEStatic__c(name='ConnectionId', value__c=connectionId);
                insert v;
                vceCs = v;
            }
        }
        return vceCs;
    }
}