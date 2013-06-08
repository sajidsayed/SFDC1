/*=============================================================================
    HISTORY                                                                  
                                                               
    DATE            DEVELOPER                WR             DESCRIPTION                               
    ====            =========                ==             =========== 
    04-Apr-2011     Srinivas Nallapati      170056          To send reject count email     
==============================================================================*/
public class TASyncLogCreateController{
    public TA_Sync_Log__c talog;
    public TASyncLogCreateController(ApexPages.StandardController controller) {
        talog = (TA_Sync_Log__c)controller.getRecord();
    }
    
    public pagereference save(){
        map<string,TASyncLimitCounter__c> mapTAlimitCounters = TASyncLimitCounter__c.getAll();
        
        try{
            insert talog;
            if(mapTAlimitCounters.ContainsKey(talog.Sales_Resource__c)){
                TASyncLimitCounter__c tal = mapTAlimitCounters.get(talog.Sales_Resource__c);
                tal.IsProcessedInNextCycle__c = 'Processed';
                update tal;
            }
            return new pagereference('/'+talog.id);
            
            
        }catch(system.dmlexception e){
            ApexPages.addMessages(e);
            system.debug(e.getmessage());
            system.debug(e.getmessage().indexOf(System.label.TA_Sync_OpenRecordsLimit_Error));
            system.debug(e.getmessage().indexOf(System.label.TA_Sync_CreatedIn7Days_Error));
            if(!mapTAlimitCounters.ContainsKey(talog.Sales_Resource__c))
            if(e.getmessage().indexOf(System.label.TA_Sync_OpenRecordsLimit_Error) != -1){
                 
                TASyncLimitCounter__c tal = new TASyncLimitCounter__c(name=talog.Sales_Resource__c); 
                insert tal;
                
            }
            
        }
        
        return null;
    }
    
    //Runs every day and if  there are more than 10 TA Sync records unprocessed in last 24 hours please send an e-mail alert to tier 2 support     
     public static void SendTASyncLimitNotification(){
        map<string,TASyncLimitCounter__c> mapTAlimitCounters = TASyncLimitCounter__c.getAll();
        
        /*
        mail.setToAddresses(new String[]{'venkatasrinivasu.nallapati@emc.com','Michael.gram@emc.com'});
        mail.setSubject('TA Sync request limit Notification');
        String Bdy = 'The purpose of this email is to alert the recipients when the number of TA synch requests exceeds the limits that have been set. The TA synch log shows the following statistics:';
        Bdy = Bdy+ '\nTotal Rejected TA Requests = '+TotalRejectCount+' . These requests exceeded the limit that can be processed in the period in which they were created';
        Bdy = Bdy+ 'Rejected TA Requests Processed in the next cycle = '+ProcessedInNextCycleCount+' . These requests were processed in the next processing period.'; 
        Bdy = Bdy+ 'Pending Rejected TA Requests = '+FinalRejectCount+' . These rejected requests have yet to be processed';
        mail.setPlainTextBody(Bdy);
        */
         
         List<EmailTemplate> lstET = [Select e.TemplateType, e.Subject, e.Name, e.Markup, e.Id, e.HtmlValue, e.Body From  EmailTemplate e where  name like 'TA Sync Log Limit notification'];
         
         list<groupmember> lstgm = [Select g.UserOrGroupId, g.Group.Name, g.GroupId From GroupMember g where Group.Name = 'TASync Notification Group'];
         set<id> setUid = new set<id>();
         for(groupmember gm : lstgm)
          setUid.add(gm.UserOrGroupId);
         List<user> lstUser = new List<user>();
         lstUser = [select id from user where id in :setUid and isActive=true];
         
         list<Messaging.Singleemailmessage> lstMail = new list<Messaging.Singleemailmessage>();
         if(mapTAlimitCounters.size() > 0 && lstET.size() > 0 && lstUser.size() > 0)
         for(User u : lstUser){
             Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
             mail.setTemplateID(lstET[0].id);
             mail.setTargetObjectId(u.id);
             mail.setSaveAsActivity(false);
             lstMail.add(mail); 
         }
         Messaging.sendEmail(lstMail);
         delete mapTAlimitCounters.Values();
     
     }
 }//end of class