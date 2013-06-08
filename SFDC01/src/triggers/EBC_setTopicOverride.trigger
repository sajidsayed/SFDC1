//trigger to override the topic override text field with the Name of the Topic from the Topic object
trigger EBC_setTopicOverride on EBC_Session__c (before insert, before update) 
{
  
    Set<id> topicIds = new Set<Id>();
    //Create a set of the topic ids of the sessions
    for(EBC_Session__c sess: Trigger.New)
    {
        topicIds.add(sess.Topic__c);
    }

    //Create a map with the ids of the Topics of the set topicIds and in the value set obtain the Name of the topics
    Map<Id, EBC_Topics__c> mapTopics = new Map<Id, EBC_Topics__c>([Select Name from EBC_Topics__c where Id in :topicIds]);
    
    for(EBC_Session__c sess: Trigger.New)
    {
    	if(sess.Topic__c != null)
    	{
	    	sess.Name=mapTopics.get(sess.Topic__c).Name;
	        if(sess.Topic_Override__c == null || sess.Topic_Override__c.Length() == 0)
	        {
	            //Populate the Name of the topic in the Topic Override field of the session
	            sess.Topic_Override__c = mapTopics.get(sess.Topic__c).Name;
	        }
    	}
    	
    }
}