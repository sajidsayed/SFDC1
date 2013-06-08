/*====================================================================================================================+

Created By      :   Avinash K, EMC Application Developer
Created Date    :   23 July 2012
Descripion      :   Test Class to cover the AllianceMappingEngagement class and trigger

 +====================================================================================================================*/
@isTest(SeeAllData=true)
private class AllianceEngagementMapping_TC 
{

    static testMethod void AllianceEngagementMapping() 
    {
        Alliance_Engagement_Mapping__c ae = new Alliance_Engagement_Mapping__c();
        Alliance_Engagement_Mapping__c aeUpdate = new Alliance_Engagement_Mapping__c();
        List<Alliance_Engagement_Mapping__c> lstAllianceMapping = new List<Alliance_Engagement_Mapping__c>();

       
        
     Account acc = [select name from account where Reporting_Segmentation_Group__c in ('Verticals','Technology Alliances','Global Alliances') and id not in
                        (select Primary_Alliance_Partner__c from Alliance_Engagement_Mapping__c) limit 1];
        
       
     
          ae.Alliance_Engagement_Document_Name__c  ='Test';
          ae.Alliance_Engagement_URL__c = 'https://test.com';
          ae.Primary_Alliance_Partner__c = acc.id;
          
       
       //Database.insert(lstAlliance);
       insert ae;
       
       lstAllianceMapping.add(ae);
       
       AllianceEngagementMapping mapalliance = new AllianceEngagementMapping();
       mapalliance.insertUpdateAllianceMapping(lstAllianceMapping);
            
       
        system.debug('ae--->'+ae);
        aeUpdate=[select Primary_Alliance_Partner__c, name, Alliance_Engagement_Document_Name__c ,Alliance_Engagement_URL__c
                                    from Alliance_Engagement_Mapping__c where id =:ae.Id ];
        
        aeUpdate.Alliance_Engagement_URL__c='https:\\test11.com';                   
        update aeUpdate;
        system.debug('aeUpdate--->'+aeUpdate);
        
        
         
      
        Opportunity opp_Obj = new Opportunity();
     
          opp_Obj.AccountId =acc.id;
          opp_Obj.Opportunity_Owner__c = UserInfo.getUserId();
          opp_Obj.Name = 'TEST';
          opp_Obj.StageName = 'TEST';
          opp_Obj.CloseDate = Date.today()+10;
          opp_Obj.Sales_Force__c = 'EMC';
          opp_Obj.Sales_Channel__c = 'Direct';
          opp_Obj.VMWare_Related__c = 'VMWare Backup';
          opp_Obj.Amount = 222.00;
          opp_Obj.bypass_validation__c = true;
          opp_Obj.Primary_Alliance_Partner__c = acc.id;
         // opp_Obj.Service_Provider__c = acc.id;                    
          
          insert opp_Obj; 
          List<id> lst=new List<id>();
          lst.add(opp_Obj.id);
          mapalliance.Feedpost(lst);
          
          
    /*
    static testMethod void AllianceEngagementMapping() 
    {
        
        Account acc = [select name from account 
                        where Reporting_Segmentation_Group__c in ('Verticals','Technology Alliances','Global Alliances') 
                        limit 1];
        
        Document doc = [select name, DeveloperName from Document limit 1];
        //insert doc;
        
        Alliance_Engagement_Mapping__c ae = new Alliance_Engagement_Mapping__c();

        List<Alliance_Engagement_Mapping__c> lstAllianceMapping = new List<Alliance_Engagement_Mapping__c>();

        lstAllianceMapping = [select Primary_Alliance_Partner__c, name, Alliance_Engagement_Document_Name__c 
                                from Alliance_Engagement_Mapping__c 
                                where Primary_Alliance_Partner__c = :acc.id limit 1];

        if(lstAllianceMapping.size() > 0)
        {
            ae = lstAllianceMapping.get(0);
        }

        else
        {
            ae = new Alliance_Engagement_Mapping__c(Primary_Alliance_Partner__c = acc.id, Name = 'Test', Alliance_Engagement_Document_Name__c = 'doc1');
            insert ae;
        }
        
        ae.Alliance_Engagement_Document_Name__c = doc.DeveloperName;
        update ae;
        
        Opportunity newrec = new Opportunity ( Name = 'Test Oppty', StageName = 'Pipeline',
                  CloseDate = System.today()+2, Sales_Force__c = 'EMC', Sales_Channel__c = 'Direct',
                  VMWare_Related__c = 'Not VMware Related', AccountId = acc.Id, Primary_Alliance_Partner__c = acc.id) ;
        
        insert newrec;
        
        
        Alliance_Engagement_Mapping__c ae1 = new Alliance_Engagement_Mapping__c(Primary_Alliance_Partner__c = acc.id, Name = 'Test1', Alliance_Engagement_Document_Name__c = 'doc1');
        try
        {
            insert ae1;
        }
        catch(Exception e)
        {
            
        }
        */
        
        
    }
    
    static testMethod void ServiceEngagementMapping() 
        {
        Service_Provider_Engagement_Mapping__c se = new Service_Provider_Engagement_Mapping__c();
        Service_Provider_Engagement_Mapping__c seUpdate = new Service_Provider_Engagement_Mapping__c();
        List<Service_Provider_Engagement_Mapping__c> lstServiceMapping = new List<Service_Provider_Engagement_Mapping__c>();

       
        Account acc1 = [select name from account  WHERE PROFILED_ACCOUNT_FLAG__c = true AND Type = 'Partner' AND Account_Status__c = 'Active' AND Partner_Type_Picklist__c = 'Service Provider' and id not in
                      (select Service_Provider__c from Service_Provider_Engagement_Mapping__c) limit 1];
        
   
     
       se.Service_Provider_Engagment_Mapping_Name__c  ='sp test';
       se.Service_Provider_Engagment_URL__c = 'https://test.com';
       se.Service_Provider__c = acc1.id;

       insert se;
       
       seUpdate=[select Service_Provider__c, Service_Provider_Engagment_Mapping_Name__c ,Service_Provider_Engagment_URL__c
                                    from Service_Provider_Engagement_Mapping__c where id =:se.Id ];
        seUpdate.Service_Provider_Engagment_Mapping_Name__c  ='sp test';
        seUpdate.Service_Provider_Engagment_URL__c='https:\\test11.com'; 
        seUpdate.Service_Provider__c = acc1.id; 
        update seUpdate;
        
         Opportunity opp_Obj = new Opportunity();
     
          opp_Obj.AccountId =acc1.id;
          opp_Obj.Opportunity_Owner__c = UserInfo.getUserId();
          opp_Obj.Name = 'TEST';
          opp_Obj.StageName = 'TEST';
          opp_Obj.CloseDate = Date.today()+10;
          opp_Obj.Sales_Force__c = 'EMC';
          opp_Obj.Sales_Channel__c = 'Direct';
          opp_Obj.VMWare_Related__c = 'VMWare Backup';
          opp_Obj.Amount = 222.00;
          opp_Obj.bypass_validation__c = true;
          opp_Obj.Service_Provider__c = acc1.id;                    
          
          insert opp_Obj; 
        }
}//End of Class