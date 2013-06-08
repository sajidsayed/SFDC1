public class MAP_LeadAssignmentHandler
{
    private Lead leadObj;
    
    public MAP_LeadAssignmentHandler(Lead lObj)
    {
        leadObj = lObj;
    }
    
    public boolean handleAccountTeamAssignment(Lead_Routing_Rule__c accountRule)
    {
        Boolean matchFound = false;
        AccountTeamMember primary = null, secondary = null, tertiary = null;
        String BU_filter = '%' + leadObj.BU__c + '%';
        Set<String> roles = new Set<String>();

        if (accountRule.Primary_Role__c != null && accountRule.Primary_Role__c != '') {
            roles.add(accountRule.Primary_Role__c);
        }
        if (accountRule.Secondary_Role__c != null && accountRule.Secondary_Role__c != '') {
            roles.add(accountRule.Secondary_Role__c);
        }
        if (accountRule.Tertiary_Role__c != null && accountRule.Tertiary_Role__c != '') {
            roles.add(accountRule.Tertiary_Role__c);
        }
        List<AccountTeamMember> members = [Select a.userid, a.TeamMemberRole
                              from AccountTeamMember a
                              where a.AccountId = :leadObj.Related_Account__c
                              and a.TeamMemberRole in :roles
                              and a.User.BU_for_Lead_Routing__c like :BU_filter
                              and a.User.IsActive = true ];

        if (members.isEmpty()) {
            return false; 
        } else {
            for(AccountTeamMember u :members) {
                if (u.TeamMemberRole == accountRule.primary_role__c) {
                    leadObj.ownerid = u.userid;
                    primary = u;
                    leadObj.lead_routing_rule__c = accountRule.id;
                    matchFound = true;
                    return matchFound;
                } else if(u.TeamMemberRole == accountRule.secondary_role__c && secondary == null) {
                    secondary = u;
                    matchFound = true;
                } else if(u.TeamMemberRole == accountRule.tertiary_role__c && secondary == null && tertiary == null) {
                    tertiary = u;
                    matchFound = true;
                }
            }
        }
        if (matchFound && primary == null) {
            if(secondary != null) {
                leadObj.ownerid = secondary.userid;
            } else {
                leadObj.ownerid = tertiary.userid;
            }
            leadObj.lead_routing_rule__c = accountRule.id;
        }
        return matchFound;
    }
    
    public boolean handleQueueAssignment(Lead_Routing_Rule__c queueRule)
    {
        leadObj.OwnerId = queueRule.queue_id__c;
        leadObj.lead_routing_rule__c = queueRule.id;
        return true;
    }
}