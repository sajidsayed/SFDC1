/*=========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req          DESCRIPTION                               
 |  ====            =========       ==              =========== 
 |  23.11.2010      Anand Sharma    #1178           Controller for the PRM_ChannelPlanPDFView Page.     
 |  23.12.2010      Anand Sharma                    Removed ownerid field from Objective because change of 
                                                    lookup relation to master details  
 |  15/09/2011      Anand Sharma    #3544           Updated for America theater      
 |  05-12-2011      Anand Sharma                    Added few more fields                                                                  
 |  29-12-2011      Suman B                         Removed fetching OpenActivities from SFDC_Channel_Account_Plan__c and 
                                                    ActivityHistories from SFDC_Objective__c inside the query. 
 |  03-01-2012		Anand Sharma					Fixed Too many row limit                                                   
 +========================================================================================================================*/
public without sharing class PRM_ChannelAccountPlanExtension {
        
    public  List<SFDC_Objective__c> lstObjective {get;set;} 
    public  List<OpenActivity> lstOpenActivity {get;set;}                               
    public  List<ActivityHistory> lstActivityHistories {get;set;}
    public  List<Strategy__c>      lstStrategy   {get;set;}   
    public SFDC_Channel_Account_Plan__c channelAccountPlan {get; set;}
    
    Map<Id, SFDC_Objective__c> mapObjectives = new Map<Id, SFDC_Objective__c>();
    Map<Id, Strategy__c> mapStrategys = new Map<Id, Strategy__c>();
      
    // The extension constructor 
    public PRM_ChannelAccountPlanExtension(ApexPages.StandardController stdController) {
        
        this.channelAccountPlan = (SFDC_Channel_Account_Plan__c) stdController.getRecord();
        
        this.channelAccountPlan = [Select Active__c,Approval_Status__c, Business_Case_Attached__c, Business_Challenges__c, EMC_Sales_Mgt_Approver__c,
                                        Business_Opportunity__c, Co_Op_Dollars_Accrued__c, Co_Op_Dollars_Expired__c, Partner_Team_Member_1__c,
                                        Co_Op_Dollars_Spent__c,Compensation_plan_for_EMC_focused_employ__c,Country__c,EMC_Presales_Engineer__c, 
                                        Country_Manager__c, Country_Manager__r.Id, Country_Manager__r.Name, CreatedById, Partner_Team_Member_2__c,
                                        CreatedBy.Name, CreatedDate, CurrencyIsoCode,Current_Velocity_Tier__c,Current_Velocity_Tier2__c,Lock_CAP__c,  
                                        Duration_of_EMC_Partnership__c,EMC_CAM__c, EMC_CAM__r.Id, EMC_CAM__r.Name, Potential_Success_Inhibitors__c,
                                        EMC_Revenue_with_Partner__c, Employess_with_EMC_Focus__c,Financial_Rating__c,GAF_sent_H1__c, 
                                        GAF_sent_H2__c, GAF_signed_H1__c, GAF_signed_H2__c, GAF_Velocity_Revenue__c, Go_to_Market__c, Id, 
                                        IsDeleted, Key_customers_for_SSCP_PSP__c,  Key_Partner_1_Current_Year_Revenue_Ac__c, Current_Specialties2__c,
                                        Key_Partner_1_Current_Year_Revenue_Pl__c, Key_Partner_1_Previous_Year_Revenue__c, Q2_QBR_Date__c,Q2_Pipeline__c, 
                                        Key_Partner_2_Current_Year_Revenue_Ac__c, Key_Partner_2_Current_Year_Revenue_Pl__c, Q3_QBR_Date__c,Q3_Pipeline__c, 
                                        Key_Partner_2_Previous_Year_Revenue__c, Key_Partner_3_Current_Year_Revenue_Ac__c, Q4_QBR_Date__c,Q4_Pipeline__c, 
                                        Key_Partner_3_Current_Year_Revenue_Pl__c, Key_Partner_3_Previous_Year_Revenue__c, EMC_Postsales_Engineer__c,
                                        Key_Partner_4_Current_Year_Revenue_Ac__c, Key_Partner_4_Current_Year_Revenue_Pl__c, 
                                        Key_Partner_4_Previous_Year_Revenue__c, Key_Partner_5_Current_Year_Revenue_Ac__c, 
                                        Key_Partner_5_Current_Year_Revenue_Pl__c, Key_Partner_5_Previous_Year_Revenue__c,Q1_QBR_Date__c,Q1_Pipeline__c, 
                                        Key_Reseller_1__c, Key_Reseller_1__r.Id, Key_Reseller_1__r.Name, Key_Reseller_2__c,EMC_s_Share_of_Wallet__c, 
                                        Key_Reseller_2__r.Id, Key_Reseller_2__r.Name, Key_Reseller_3__c, Key_Reseller_3__r.Id,EMC_s_Rank__c, 
                                        Key_Reseller_3__r.Name, Key_Reseller_4__c, Key_Reseller_4__r.Id, Key_Reseller_4__r.Name, Competitor_List__c,
                                        Key_Reseller_5__c, Key_Reseller_5__r.Id, Key_Reseller_5__r.Name,key_vendors__c,  LastActivityDate,
                                        LastModifiedById, LastModifiedBy.Id, LastModifiedBy.Name, LastModifiedDate, Market_focus__c, Name,
                                        Notes__c, of_T2s__c,Offering__c,OwnerId, Partner_Account__c, Partner_Account__r.Id, Partner_Account__r.Name, 
                                        Partner_Grouping__c, Partner_Grouping__r.Id,Partner_Approver_User__c, Country1__c,Competing_Competitors__c,                                   
                                        Partner_Approver_User__r.Id, Partner_Approver_User__r.Name, Objective_for_this_Partnership__c,
                                        Partner_Grouping__r.Name, Period__c, Plan_End__c, Plan_Length__c, Plan_Start__c,Partner_Approver__c, 
                                        Previous_Year_Rev_with_EMC__c, Previous_Year_Revenue__c, RecordTypeId, RecordType.Id, RecordType.Name, Relevance_Factor__c, 
                                        Specialty_Archive_Actual__c, Specialty_Archive_Plan__c, Specialty_Archive_Start__c, Specialty_backup_Actual__c, 
                                        Specialty_backup_Plan__c, Specialty_backup_Start__c, Specialty_Consolidate_Actual__c, Specialty_Consolidate_Plan__c, 
                                        Specialty_Consolidate_Start__c, Specialty_Unified_Actual__c, Specialty_Unified_Plan__c, Specialty_Unified_Start__c, Status__c, 
                                        SystemModstamp, Total_Co_Op_Spend__c,Total_Number__c,Total_Employees__c,Total_Rebate__c, Total_Revenue__c, Value_Proposition__c, 
                                        Vertical_Market_Expertise__c, Partner_Total_Revenue_Last_Year__c,EMC_Share_of_Wallet__c,Partner_EMC_Sell_Out_Revenue_Last_Year__c,
                                        Specialty_Consolidate__c, Specialty_Advanced_Consolidate__c, Key_Customer_1_EMC_Sell_In_Revenue_LY__c, 
                                        Key_Customer_2_EMC_Sell_In_Revenue_LY__c, Key_Customer_3_EMC_Sell_In_Revenue_LY__c, Key_Customer_1__c , Key_Customer_2__c, Key_Customer_3__c,
                                        Challenges_to_Business_Opportunities__c, GAF_H1_Attached__c,GAF_H1_Payout__c,GAF_H2_Attached__c, GAF_H2_Payout__c,
                                        of_Active_Tier2_Resellers_Period_Start__c, Key_Reseller_1_EMC_Sell_In_Revenue_LY__c, Key_Reseller_2_EMC_Sell_In_Revenue_LY__c,
                                        Key_Reseller_3_EMC_Sell_In_Revenue_LY__c, Key_Reseller_4_EMC_Sell_In_Revenue_LY__c, Key_Reseller_5_EMC_Sell_In_Revenue_LY__c,
                                        Goal_Actual__c,Goal_Target__c,Overall_Plan_Goal__c
                                              
                                    from SFDC_Channel_Account_Plan__c 
                                    
                                    WHERE Id =: channelAccountPlan.Id ];     
        
       
        //list of Strategy
        //mapStrategys = new Map<Id, Strategy__c>(channelAccountPlan.Strategies__r);
        mapStrategys = new Map<Id, Strategy__c>([SELECT Additional_Information__c, Channel_Plan__c,Geography__c , Objective_Period__c ,Region__c ,CreatedById, CreatedDate, CurrencyIsoCode, 
                                            IsDeleted, LastModifiedById, LastModifiedDate, ConnectionReceivedId, Id, ConnectionSentId, Name, SystemModstamp 
                                            FROM Strategy__c where Channel_Plan__c =:channelAccountPlan.Id order By Id]);

        
        //lstStrategy = channelAccountPlan.Strategies__r;
        lstStrategy = mapStrategys.values();
        
        //list of Objective 
        mapObjectives = new Map<Id, SFDC_Objective__c>([Select Activity_Cost__c, Channel_Account_Plan__c, Success_Requirements__c, Co_Op__c, Cost_Per_QSO__c, CreatedById, CreatedDate, CurrencyIsoCode, Days_Left_Over__c, DGF__c, Objective_Owner__c,
                                                                End_Date__c, Focus_Area__c, Funding_Type__c, Gap__c, Goal_Attained__c, Id, Industry_Focus__c, IsDeleted, LastActivityDate, 
                                                                LastModifiedById, LastModifiedDate, Metric_Goal__c, Metric_Result__c, Name, Objective_Strategy__c, Objective_Type__c,Strategy__c,
                                                                Parent_Objective_Type__c, Priority__c, QSO_s__c, RecordTypeId, Region__c, Segment__c, Solution__c, Solution_Focus__c, Stage__c, 
                                                                Start_Date__c, Status__c,Success_Measure__c, SystemModstamp, Tracking_Comments__c, Vertical__c, Same_Period_Time_Last_Year__c,

                                                               (Select AccountId, Activity_Type__c, ActivityDate, ActivityType, Briefing_Event__c, CallDisposition, 
                                                                    CallDurationInSeconds, CallObject, CallType, CMA_Type_Details__c, Core_Sponsored_Call__c, CreatedById, CreatedDate, CurrencyIsoCode, 
                                                                    Description, DurationInMinutes, Event__c, ExternalId__c, Id, IsAllDayEvent, IsClosed, IsDeleted, IsReminderSet, IsTask, 
                                                                    IsVisibleInSelfService, LastModifiedById, LastModifiedDate, Location, Notification_Help__c, Original_Appointment_End__c, 
                                                                    Original_Appointment_Start__c, Outcome__c, OwnerId,Owner.Name, Priority, ReminderDateTime, Status, Subject, SystemModstamp, Transfer__c, 
                                                                    Type_Details__c, VCE_Assigned_To__c, VCE_Completion_Date__c, VCE_Last_Modifying_Partner__c, VCE_Owner_Engineer_Email__c, 
                                                                    VCE_Owner_Engineer_First_Name__c, VCE_Owner_Engineer_Last_Name__c, VCE_Owner_Engineer_Phone__c, VCE_Task_Initial_Accept__c, 
                                                                    VCE_Task_Initial_Response__c, WhatId, WhoId, Marketing_Campaign__c 
                                                                From ActivityHistories) ,
                                                                
                                                                (Select AccountId, Activity_Type__c, ActivityDate, ActivityType, Briefing_Event__c, CallDisposition, CallDurationInSeconds, CallObject, 
                                                                    CallType, CMA_Type_Details__c, Core_Sponsored_Call__c, CreatedById, CreatedDate, CurrencyIsoCode, Description, DurationInMinutes, Event__c, 
                                                                    ExternalId__c, Id, IsAllDayEvent, IsClosed, IsDeleted, IsReminderSet, IsTask, IsVisibleInSelfService, LastModifiedById, LastModifiedDate, 
                                                                    Location, Notification_Help__c, Original_Appointment_End__c, Original_Appointment_Start__c, Outcome__c, OwnerId, Owner.Name, Priority, ReminderDateTime, 
                                                                    Status, Subject, SystemModstamp, Transfer__c, Type_Details__c, VCE_Assigned_To__c, VCE_Completion_Date__c, VCE_Last_Modifying_Partner__c, 
                                                                    VCE_Owner_Engineer_Email__c, VCE_Owner_Engineer_First_Name__c, VCE_Owner_Engineer_Last_Name__c, VCE_Owner_Engineer_Phone__c, 
                                                                    VCE_Task_Initial_Accept__c, VCE_Task_Initial_Response__c, WhatId, WhoId, Marketing_Campaign__c
                                                                From OpenActivities) 
                                                            
                                                            From SFDC_Objective__c
                                                            WHERE Channel_Account_Plan__c =: channelAccountPlan.Id order By Strategy__r.Id]);
                                                            
        lstObjective =  mapObjectives.values();                                                     
    }
       
    public List<wrapStrategyDataContainer> getResults(){
        
        List<wrapStrategyDataContainer> objStrDataHelp = new List<wrapStrategyDataContainer>(); 
        List<wrapObjectivesDataContainer> lstObjectiveHelp = new List<wrapObjectivesDataContainer>();
        wrapStrategyDataContainer objStrObjHelp = new wrapStrategyDataContainer(); 
        wrapObjectivesDataContainer objObjectiveHelp = new wrapObjectivesDataContainer(); 
        Map<String, List<SFDC_Objective__c>> mapStratObjectives = new Map<String, List<SFDC_Objective__c>>();
        List<SFDC_Objective__c> lstTempObjective = new List<SFDC_Objective__c>();
        
        for(SFDC_Objective__c objObectives : lstObjective){
            if(mapStratObjectives.containsKey(objObectives.Strategy__c)){
                mapStratObjectives.get(objObectives.Strategy__c).add(objObectives);
            }
            else{
                mapStratObjectives.put(objObectives.Strategy__c,new List<SFDC_Objective__c>());
                mapStratObjectives.get(objObectives.Strategy__c).add(objObectives);
            }
        }    
        for(Integer i=0; i< lstStrategy.size(); i++){           
            lstObjectiveHelp = new List<wrapObjectivesDataContainer>();
            lstTempObjective = new List<SFDC_Objective__c>();
            objStrObjHelp = new wrapStrategyDataContainer(); 
            
            objStrObjHelp.intStrategyIndex = i+1;           
            objStrObjHelp.objStrategy = mapStrategys.get(lstStrategy.get(i).Id); 
            
            lstTempObjective = mapStratObjectives.get(lstStrategy.get(i).Id);
            if(lstTempObjective != null && lstTempObjective.size() >0 ) {
                for(Integer j=0; j< lstTempObjective.size(); j++){
                    objObjectiveHelp = new wrapObjectivesDataContainer(); 
                    objObjectiveHelp.intObjectiveIndex = j +1;
                    objObjectiveHelp.objObjective = lstTempObjective.get(j);
                    lstObjectiveHelp.add(objObjectiveHelp);
                }
            }           
            
            
            objStrObjHelp.lstObjectives = lstObjectiveHelp; 
            objStrDataHelp.add(objStrObjHelp); 
            //List<SFDC_Objective__c> tempChild = [select Id, name, Strategy__r.Id, (Select Id, Subject from ActivityHistories), (Select Id, Subject from OpenActivities)  from SFDC_Objective__c WHERE Strategy__r.Id =: tempParent[i].Id];
            //hierarchy.add(new wrapObjectives( i + 1 , tempParent[i], tempChild));
        }
        
        System.Debug('List of objStrDataHelp' + objStrDataHelp);
        return objStrDataHelp;
    } 
      
    public class wrapStrategyDataContainer{     
        public Integer intStrategyIndex {get;Set;}
        public Strategy__c objStrategy {get; set;}
        public List<wrapObjectivesDataContainer> lstObjectives {get; set;}
        public wrapStrategyDataContainer(){
            
        }       
        public wrapStrategyDataContainer(Integer intObj , Strategy__c objStrt, List<wrapObjectivesDataContainer> lstObjectivedata){
            intStrategyIndex = intObj;
            objStrategy = objStrt;
            lstObjectives = lstObjectivedata;
        }
    } 
    
    public class wrapObjectivesDataContainer{       
        public Integer intObjectiveIndex {get;Set;}
        public SFDC_Objective__c objObjective {get; set;}   
        public wrapObjectivesDataContainer(){
            
        }    
        public wrapObjectivesDataContainer(Integer intObj ,  SFDC_Objective__c objObject){
            intObjectiveIndex = intObj;
            objObjective = objObject;
        }
    }      
 }