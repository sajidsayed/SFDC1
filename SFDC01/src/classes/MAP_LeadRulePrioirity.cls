public class MAP_LeadRulePrioirity {

    public static Map<string, string> priorityLkpErrs;

    public void CheckRulesonUpdate(List<Lead_Routing_Rule_Priority__c> oldrecs, List<Lead_Routing_Rule_Priority__c> newrecs) {
        for(integer i=0; i<newrecs.Size();i++){
            if (newrecs[i].Rule_Fields__c != oldrecs[i].Rule_Fields__c
                   || newrecs[i].Rule_Type__c != oldrecs[i].Rule_Type__c ) {
                if (rulesExist(newrecs[i].id)) {
                    newrecs[i].adderror(System.Label.LeadPriorityUpdateErr);
                }
            }
        }
    }

    public void CheckRulesonDelete(List<Lead_Routing_Rule_Priority__c> oldrecs) {
        for(integer i=0; i<oldrecs.Size();i++){
            if (rulesExist(oldrecs[i].id)) {
                oldrecs[i].adderror(System.Label.LeadPriorityDeleteErr);
            }
        }
    }

    public static void LookupQueueId(List<Lead_Routing_Rule__c> rulelist) {
        Set<String> queueNames = new Set<String>();
        List<QueueSobject> queuelist = new List<QueueSobject>();
        Map<String, String> queuemap = new Map<String, String>();
        for(Lead_Routing_Rule__c rule :rulelist){
            if (rule.Queue_Name__c != null && rule.Queue_Name__c != '') {
                queueNames.add(rule.Queue_Name__c);
            }
        }
        if (queueNames.size() > 0 ) {
            queuelist = [Select q.QueueId, q.Queue.Name from QueueSobject q
                         where SobjectType = 'Lead' and q.Queue.Name in :queueNames];
            for(QueueSobject queuerec :queuelist) {
                queuemap.put(queuerec.Queue.Name, queuerec.QueueId);
            }
            for(Lead_Routing_Rule__c rule :rulelist){
                if (rule.Queue_Name__c != null && rule.Queue_Name__c != '') {
                    if (queuemap.containsKey(rule.Queue_Name__c) ) {
                        rule.Queue_ID__c = queuemap.get(rule.Queue_Name__c);
                    } else {
                        rule.adderror(System.Label.LeadRuleQueueErr);
                    }
                }
            }
        }
    }

    static Boolean rulesExist (String priorityId) {
        List<Lead_Routing_Rule__c> rules = [Select l.Id, l.Routing_Rule_Priority__c
                                            from Lead_Routing_Rule__c l
                                            where l.Routing_Rule_Priority__c = :priorityId
                                            limit 1];
        if (rules.size() > 0) {
            return true;
        } else {
            return false;
        }
    }

    public static void LookupRulePriority(List<Lead_Routing_Rule__c> rulelist) {
    
        List<Lead_Routing_Rule_Priority__c> prioritylist = new List<Lead_Routing_Rule_Priority__c>();
        Map<string, Map<String, String[]> > ruletypeAttrMap = new Map<string, Map<String, String[]> >();
        Map<String,String[]> attrIdMap = new Map<String,String[]>();
        List<String> attributelist = new List<String>();
        List<Lead_Routing_Field_Mapping__c> rulerecs = new List<Lead_Routing_Field_Mapping__c>();
        List<String> rulefields = new List<String>();
        List<RecordType> rectypelist = new List<RecordType>();
        Map<String,String> rectypeMap = new Map<String,String>();
        Set<String> idKeys = new Set<String>();
        Boolean matchfound = false;
        
        if (priorityLkpErrs == null) {
            priorityLkpErrs = new Map<string, string>();
        } else if (priorityLkpErrs.size() > 0) {
            priorityLkpErrs.clear();
        }
        // get all of the existing rule priority records
        prioritylist = [select id, Rule_Fields__c, Rule_Type__c from Lead_Routing_Rule_Priority__c];
        // Loop through the priority records and create the ruletypeAttrMap
        for(Lead_Routing_Rule_Priority__c priority :prioritylist) {
            // Rule_Fields__c will be semi-colon separated values so we put it into a sorted list
            attributelist = priority.Rule_Fields__c.split(';',0);
            attributelist.sort();
            // add the priority attribute list to the ruletypeAttrMap
            if (ruletypeAttrMap.containsKey(priority.Rule_Type__c)) {
                attrIdMap = ruletypeAttrMap.get(priority.Rule_Type__c);
                attrIdMap.put(priority.id, attributelist);
                ruletypeAttrMap.put(priority.Rule_Type__c, attrIdMap);
            } else {
                attrIdMap = new Map<String,String[]>();
                attrIdMap.put(priority.id, attributelist);
                ruletypeAttrMap.put(priority.Rule_Type__c, attrIdMap);
            }
        }
        
        // get the list of routing rule fields from the mapping object
        rulerecs = [Select l.Rule_Object_Field_API_Name__c from Lead_Routing_Field_Mapping__c l];
        for (Lead_Routing_Field_Mapping__c rec :rulerecs) {
            rulefields.add(rec.Rule_Object_Field_API_Name__c);
        }
        // get routing rule record type names so we can match on priority rule type key
        rectypelist = [Select r.Id, r.name from RecordType r
                       where SobjectType = 'Lead_Routing_Rule__c'];
        for (RecordType rectype :rectypelist) {
            rectypeMap.put(rectype.id, rectype.name);
        }
        // loop through the rulelist that was passed to the trigger
        for (Lead_Routing_Rule__c rule :rulelist) {
            // for the current rule, get a sorted list of fields that are not null
            List<String> rulekeylist = new List<String>();
            for (String fieldrec :rulefields) {
                if (rule.get(fieldrec) != null && rule.get(fieldrec) != '' ) {
                    rulekeylist.add(fieldrec);
                }
            }
            rulekeylist.sort();
             
            // find a priority that matches both the rule type and attribute combination
            String ruleRecType = rectypeMap.get(rule.RecordTypeId);
            if (ruletypeAttrMap.containskey(ruleRecType)){
                idKeys = ruletypeAttrMap.get(ruleRecType).keySet();
                for (String idVal :idKeys) {
                    matchfound = false;
                    if (ruletypeAttrMap.get(ruleRecType).get(idVal) == rulekeylist) {
                        // stamp the priority ID onto the current rule
                        rule.Routing_Rule_Priority__c = idVal;
                        matchfound = true;
                        break;
                    }
                }
                if (!matchfound) {
                    rule.Routing_Rule_Priority__c = null;
                    priorityLkpErrs.put(rule.name, System.Label.LeadRuleQualErr);
                }
            } else {
                rule.Routing_Rule_Priority__c = null;
                priorityLkpErrs.put(rule.name, System.Label.LeadRuleRecTypeErr);
            }
        }
    }
    
    public static void LookupRulePriorityAfter(List<Lead_Routing_Rule__c> rulelist) {

        if (priorityLkpErrs!= null && priorityLkpErrs.size() > 0) {
            for (Lead_Routing_Rule__c rule :rulelist) {
                if (priorityLkpErrs.containskey(rule.name)
                          && rule.Routing_Rule_Priority__c == null){
                    rule.adderror(priorityLkpErrs.get(rule.name));
                }
            }
        }
    }
}