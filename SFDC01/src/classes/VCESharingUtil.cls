public class VCESharingUtil {

/*
This function will filter the list of case ids to those which
   1) have the correct record type
   2) have been previously shared with a connection
It creates a map keyed by ID of those case objects and returns it
*/
    public static Map<id,Case> getCaseMap(List<Id> caseIds, String rt) {
        List<Id> sharedCaseIdList = new List<Id>();
    
        for (PartnerNetworkRecordConnection p: 
                [select id, LocalRecordId, status from PartnerNetworkRecordConnection 
                where LocalRecordId in :caseIds and (status = 'Sent' or status = 'Received')])
            sharedCaseIdList.add(p.LocalRecordId);
    
        return new Map<Id,Case>([select Id,RecordTypeId from Case 
            where id IN :sharedCaseIdList and RecordTypeId = :rt]) ;
        
    }

    Public static PartnerNetworkRecordConnection newPNRC(Id connId, Id recId) {
        PartnerNetworkRecordConnection pnrc = new PartnerNetworkRecordConnection();
        pnrc.ConnectionId = connId;
        pnrc.LocalRecordId = recId;
        return pnrc;
    }

    Public static PartnerNetworkRecordConnection newPNRC(Id connId, Id recId, Id parentId) {
        PartnerNetworkRecordConnection pnrc = VCESharingUtil.newPNRC(connId, recId);
        pnrc.ParentRecordId = parentId;    
        return pnrc;
    }
}