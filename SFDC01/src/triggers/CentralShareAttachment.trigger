/**
The trigger to create attachment to the sharing org as the
associated case has been already shared with the shared org

Created Date: 09/23/11
Modification History:
*/
trigger CentralShareAttachment on Attachment (after insert) {
    List<PartnerNetworkRecordConnection> saveList = new List<PartnerNetworkRecordConnection>();
    Set<String> sharedCaseSet = new Set<String>();
    Set<String> netrecs = new Set<String>();
    Set<Id> allCaseIdSet = new Set<Id>();
    Set<Id> sharedCaseIdSet = new Set<Id>();
    String connId = VCEStatic__c.getInstance('ConnectionId').Value__c;
    

    for(Attachment a: Trigger.New)
        allCaseIdSet.add(a.ParentId);

    for (PartnerNetworkRecordConnection p: 
            [select id, LocalRecordId, connectionid, status from PartnerNetworkRecordConnection 
            where LocalRecordId in :allCaseIdSet 
            and connectionid = :connId
            and (status = 'Sent' or status = 'Received')
            ]){
        sharedCaseIdSet.add(p.LocalRecordId);
    }

	CentralShareAttachmentUtility.toSupportTestClass(sharedCaseIdSet);
    for(Attachment c : Trigger.new) {
        //check if the parent case has been shared with connection
	    if(sharedCaseIdSet.contains(c.parentId)){
	        PartnerNetworkRecordConnection pnrc = new PartnerNetworkRecordConnection();
	        pnrc.ConnectionId = connId;
	        pnrc.LocalRecordId = c.Id;
	        pnrc.ParentRecordId = c.parentId;
	        saveList.add(pnrc);
	    }
    }
    if(!CentralShareAttachmentUtility.isFromTest)
    	insert saveList;
}