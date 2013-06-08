trigger Presales_beforeInsertOfQuote on Quote_Custom__c (before Insert) {

    Presales_Quote objQuote = new Presales_Quote();
    system.debug('trigger.newMap---->'+trigger.newMap);
    system.debug('trigger.newMap---->'+trigger.new);
    objQuote.presalesSetQuoteCreatorGroup(trigger.new);   
}