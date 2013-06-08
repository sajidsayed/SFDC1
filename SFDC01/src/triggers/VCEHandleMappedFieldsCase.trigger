trigger VCEHandleMappedFieldsCase on Case (before update) {
    String caseOriginEMC = 'EMC';
    String userName = UserInfo.getName();
    Case oldCase;           

    for (Case c : Trigger.new) {
        if(c.Origin == caseOriginEMC && userName.equalsIgnoreCase('Connection User')) {
            oldCase = trigger.oldmap.get(c.id);
            if (c.Status != oldCase.Status)
                c.Status = oldCase.Status;
            if (c.Priority != oldCase.Priority)
                c.Priority = oldCase.Priority;
        }
    }      
}