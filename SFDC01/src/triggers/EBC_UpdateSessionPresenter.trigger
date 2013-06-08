/*
*  Created By       :- Sunil Arora
*  Created Date     :- 26/02/2010
*  Last Modified By :- Sunil Arora
*  Description      :- This trigger is used to update Presenter,EBC Name and EBC Title in Session  Presenter
*/
trigger EBC_UpdateSessionPresenter on EBC_Session_Presenter__c (before insert, before update)
{
    Set<id> topicIds = new Set<Id>();
    Set<id> topic_presenterids = new Set<Id>();
    Map<Id, EBC_Topic_Presenters__c> mapPresenter=new Map<Id, EBC_Topic_Presenters__c>();
    for(EBC_Session_Presenter__c sess: Trigger.New)
    {
            sess.Presenter__c =null;
        if(sess.Topic_Presenters__c !=null)
        topic_presenterids.add(sess.Topic_Presenters__c);
    }
    
    if(topic_presenterids.size()>0)
    {
        //This call is used here to fetch Topic Presenter details.
        mapPresenter= new Map<Id, EBC_Topic_Presenters__c>([Select Id,Name,isCertified__c,Presenter__c,Presenter__r.Name from EBC_Topic_Presenters__c where Id in :topic_presenterids]);
     if(mapPresenter.size()>0)
     {  
        for(EBC_Session_Presenter__c sess: Trigger.New)
        {
            if(sess.Topic_Presenters__c !=null)
            sess.Presenter__c =mapPresenter.get(sess.Topic_Presenters__c).Presenter__c;
        }
     }
    }

}