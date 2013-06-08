/*
*  Created by         : Sunil Arora
*  Last Modified by   : Sunil Arora
*  Description        : This class will be called by EBC_ShowRoomAssignment(VF Page) to show room Calendar Records, if user click on any record, 
*                       he will get updated room assignment value on Briefing Event
*/
public class EBC_ShowRoomAssignment
{ 
         public Id briefingEventId{get; set;} // id of the Briefing Event Object
         public EBC_Briefing_Event__c briefingEvent {get; set;} 

         public List<EBC_Room__c> room = new List<EBC_Room__c>(); 
         public Id roomId {get; set;} 
         
         public List<EBC_WrapperShowRoomAssignment> wrpList=new List<EBC_WrapperShowRoomAssignment>();
         
         public  EBC_ShowRoomAssignment()
         {
            briefingEventId = System.currentPageReference().getParameters().get('id');
            //This call is used to fetch Briefing venue Id
            briefingEvent = [Select id,Briefing_Center__c,Briefing_Venue__c, Room_Assignment__c,Start_Date__c,End_Date__c from EBC_Briefing_Event__c where id =:briefingEventId];

            if(briefingEvent.Briefing_Venue__c ==null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , 'Briefing venue is not selected on the Briefing Event'));
                return;
            }


            //This call is used here to fetch Room Calendar
            room=[Select Name, Briefing_Venue__c, 
                         (Select End_Date__c, Room__c, Start_Date__c,Briefing_Event__c,Room__r.Name,Briefing_Event__r.Name
                                 From Room_Calendar__r 
                                 where (Start_Date__c <=: briefingEvent.Start_Date__c and End_Date__c >=: briefingEvent.Start_Date__c) or 
                                        (Start_Date__c <=: briefingEvent.End_Date__c and End_Date__c >=: briefingEvent.End_Date__c)
                                     or (Start_Date__c >=: briefingEvent.Start_Date__c and End_Date__c <=: briefingEvent.End_Date__c)                                      
                                       ) 
                     From EBC_Room__c 
                     where Briefing_Venue__c = :briefingEvent.Briefing_Venue__c];
             
         System.debug(room);

        //retrieveInvitees();
         }
   
         
         public List<EBC_WrapperShowRoomAssignment> getRecords()
         {
            for (Integer i=0;i<room.size();i++)
             {
             
                if(room[i].Room_Calendar__r.size() > 0)
                {
                    for(Integer j=0;j<room[i].Room_Calendar__r.size();j++)
                    {
                        EBC_WrapperShowRoomAssignment wrp=new EBC_WrapperShowRoomAssignment();
                       // wrp.StartDate= String.valueOf(room[i].Room_Calendar__r[j].Start_Date__c);
                       // wrp.EndDate=String.valueOf(room[i].Room_Calendar__r[j].End_Date__c);
                        
                        wrp.StartDate= room[i].Room_Calendar__r[j].Start_Date__c.format();
                        wrp.EndDate=room[i].Room_Calendar__r[j].End_Date__c.format();
                        wrp.RoomId=room[i].Id;
                        wrp.RoomName=room[i].Name;
                        wrp.BriefingEvent=room[i].Room_Calendar__r[j].Briefing_Event__r.Name;
                        wrpList.add(wrp);
                    }
                 }
                 else
                 {
                    EBC_WrapperShowRoomAssignment wrp=new EBC_WrapperShowRoomAssignment();
                    wrp.StartDate=null;
                    wrp.EndDate=null;
                    wrp.RoomId=room[i].Id;
                    wrp.RoomName=room[i].Name;
                    wrp.BriefingEvent='';
                    wrpList.add(wrp);
                 }
             }
             return wrpList;
         }
         
         //This method is used to update room assignment field
         public pageReference updateBriefingEvent()
         {
             try
             {
                 EBC_Room_Calendar__c rc = new EBC_Room_Calendar__c();
                 List<EBC_Room_Calendar__c> rcList = [Select End_Date__c, Room__c, Start_Date__c,Briefing_Event__c,Room__r.Name,Briefing_Event__r.Name
                                 From EBC_Room_Calendar__c where Briefing_Event__c = :briefingEvent.Id];
                 if(rcList.size() > 0)
                     rc = rcList[0];

                 rc.Room__c = roomId;
                 rc.Start_Date__c = briefingEvent.Start_Date__c;
                 rc.End_Date__c = briefingEvent.End_Date__c;
                 rc.Briefing_Event__c = briefingEvent.Id;
                 if(rcList.size() > 0)
                     update rc;
                 else
                     insert rc;
                briefingEvent.Room_Assignment__c=roomId;
                update briefingEvent;
                return null;
             }
             catch(Exception ex)
             {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getmessage()));
                return null;
             }
         }
}