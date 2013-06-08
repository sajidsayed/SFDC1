/*====================================================================================================================+

Created By      :   Avinash K, EMC Application Developer
Created Date    :   6 July 2012
Descripion      :   Class (called from the AllianceEngagementMapping trigger) excutes before insert and update of an Alliance Engagement
                    Mapping record and populates the Alliance_Engagement_URL__c field with the Document URL from the 
                    unique document name provided in the Alliance_Engagement_Document_Name__c field
                    
Updated By      :   Avinash K, EMC Application Developer
Updated Date    :   10 August 2012
Descripion      :   Added a method populateAllianceEngagementDocumentURL() that populates the Alliance Engagement Document URL field on 
                    Opportunity by fetching URL from the corresponding Alliance Engagement Mapping record based on the 
                    Primary Alliance Partner field value on Opportunity.                    

 +====================================================================================================================*/
public with sharing class AllianceEngagementMapping 
{
    
/*******
    The following method populateAllianceEngagementDocumentURL() populates the Alliance Engagement Document URL field on Opportunity by 
    fetching the document URL from the corresponding Alliance Engagement Mapping record based on the Primary Alliance Partner field 
    value on Opportunity
********/
    public void populateAllianceEngagementDocumentURL(List<Opportunity> lstOpp)
    {
        Map<Opportunity,String> mapOppAndPrimaryAlliancePartner = new Map<Opportunity,String>();
        Map<String, Alliance_Engagement_Mapping__c> mapPrimaryAlliancePartnerAndMapping = new Map<String,Alliance_Engagement_Mapping__c>();
        List <Alliance_Engagement_Mapping__c> lstMapping = new List <Alliance_Engagement_Mapping__c>();
        
//Populating mapOppAndPrimaryAlliancePartner
        for(Opportunity opp : lstOpp)
        {
            mapOppAndPrimaryAlliancePartner.put(opp, opp.Primary_Alliance_Partner__c);
            opp.Alliance_Engagement_Document__c = null;
            //opp.Alliance_Engagement_Document_URL__c = null;
        }
        
        if(mapOppAndPrimaryAlliancePartner.values() != null)
            lstMapping = [select name, Alliance_Engagement_URL__c, Primary_Alliance_Partner__c
                            from Alliance_Engagement_Mapping__c
                            where Primary_Alliance_Partner__c in :mapOppAndPrimaryAlliancePartner.values()
                                AND Alliance_Engagement_URL__c <> null
                                AND Alliance_Engagement_URL__c <> ''
                            limit 50000];
        
        if(lstMapping.size() > 0)
        {
            for(Alliance_Engagement_Mapping__c ae : lstMapping)
            {
                mapPrimaryAlliancePartnerAndMapping.put(ae.Primary_Alliance_Partner__c, ae);
            }
            
            for(Opportunity opp : lstOpp)
            {
                if (mapPrimaryAlliancePartnerAndMapping.keyset().contains(opp.Primary_Alliance_Partner__c))
                {
                    opp.Alliance_Engagement_Document__c = mapPrimaryAlliancePartnerAndMapping.get(opp.Primary_Alliance_Partner__c).id;
                    //opp.Alliance_Engagement_Document_URL__c = mapPrimaryAlliancePartnerAndMapping.get(opp.Primary_Alliance_Partner__c).Alliance_Engagement_URL__c;
                }
            }
        }
        
    }
    
    
    
    
    
    
    
    
    public void insertUpdateAllianceMapping(list<Alliance_Engagement_Mapping__c> lstNewAllianceMapping)
    {
//Map for name of Competitive Summary mapping and its related Competitive Summary field (containing the document name)
        map<string,string> mapAllianceMappingNameDocumentName = new map<string,string>();
        
//List of document from SFDC DB that are for the records being inserted/updated
        list<Document> lstDocument = new list<Document>();
        
//Map for the name & id of documents queried (for records being inserted/updated) 
        map<string,Id> mapDocUniqueNameDocId = new  map<string,Id>();
        
//Populates the "mapAllianceMappingNameDocumentName" map 
        for(Alliance_Engagement_Mapping__c ae : lstNewAllianceMapping)
        {
            if(ae != null)
            {
                ae.Alliance_Engagement_URL__c = ''; 
                if(ae.Alliance_Engagement_Document_Name__c != null && ae.Alliance_Engagement_Document_Name__c != '')
                {
                    if(!mapAllianceMappingNameDocumentName.containsKey(ae.Name))
                    {
                        mapAllianceMappingNameDocumentName.put(ae.Name,ae.Alliance_Engagement_Document_Name__c);
                    }    
                }
            }      
        }
        
//Populates the lstDocument i.e. Queries the List of document from SFDC DB that are for the records being inserted/updated
        if(!mapAllianceMappingNameDocumentName.isEmpty())
        {
            lstDocument = [Select Id,DeveloperName from Document where DeveloperName in: mapAllianceMappingNameDocumentName.values()];
        }
        
//Populates the mapDocUniqueNameDocId with KEY : document name & VALUE : its id.
        if(lstDocument.size()>0)
        {
            for(Document doc: lstDocument)
            {
                mapDocUniqueNameDocId.put(doc.DeveloperName.tolowercase(),doc.Id);
            }
        }
            
//Populates each Alliance Engagement Mapping record's Competitive_Summary_URL__c field with its respective document's URL
        if(!mapDocUniqueNameDocId.isEmpty())
        {
            String baseURL = URL.getSalesforceBaseUrl().getHost();
            for(Alliance_Engagement_Mapping__c ae: lstNewAllianceMapping)
            {
                if(mapAllianceMappingNameDocumentName.containsKey(ae.Name))
                { 
                    if(mapDocUniqueNameDocId.containsKey(mapAllianceMappingNameDocumentName.get(ae.Name).toLowercase()))
                    {                   
                        ae.Alliance_Engagement_URL__c =  'https://'+baseURL+'/servlet/servlet.FileDownload?file='+mapDocUniqueNameDocId.get(mapAllianceMappingNameDocumentName.get(ae.Name).toLowercase());
                    }
                }
            }
        }  
    }     
      
      
      public void restrictDuplicateRecord(list<Alliance_Engagement_Mapping__c> lstAllianceEngmtMappingNew)
      {
           List<Alliance_Engagement_Mapping__c> lstIdAllianceEngmtExisting = new List<Alliance_Engagement_Mapping__c> ();
           List<Id> lstPrimaryAllianceId = new List<ID>();
           
           for(Alliance_Engagement_Mapping__c ae : lstAllianceEngmtMappingNew)
           {
               lstPrimaryAllianceId.add(ae.Primary_Alliance_Partner__c);
           }
           
           lstIdAllianceEngmtExisting = [select id, name , Primary_Alliance_Partner__c, Primary_Alliance_Partner__r.name from Alliance_Engagement_Mapping__c where Primary_Alliance_Partner__c IN :lstPrimaryAllianceId];
           
           for(Alliance_Engagement_Mapping__c ae : lstAllianceEngmtMappingNew)
           {
               for(Alliance_Engagement_Mapping__c aeExisting : lstIdAllianceEngmtExisting)
               {
                    if(ae.Primary_Alliance_Partner__c == aeExisting.Primary_Alliance_Partner__c)
                        ae.addError(Label.Alliance_Engagement_Mapping_Error_Message);
               }
           }
             }
             
             //Start of March Relase 2013

           public void restrictDuplicateRecordSE(list<Service_Provider_Engagement_Mapping__c> lstServiceEngmtMappingNew)
           {
           List<Service_Provider_Engagement_Mapping__c> lstIdServiceEngmtExisting = new List<Service_Provider_Engagement_Mapping__c> ();
           List<Id> lstServiceProviderId = new List<ID>();
           
           for(Service_Provider_Engagement_Mapping__c se : lstServiceEngmtMappingNew)
           {
               lstServiceProviderId.add(se.Service_Provider__c);
           }
           
           lstIdServiceEngmtExisting = [select id, name , Service_Provider__c, Service_Provider__r.name from Service_Provider_Engagement_Mapping__c where Service_Provider__c IN :lstServiceProviderId];
           
           for(Service_Provider_Engagement_Mapping__c se : lstServiceEngmtMappingNew)
           {
               for(Service_Provider_Engagement_Mapping__c seExisting : lstIdServiceEngmtExisting)
               {
                    if(se.Service_Provider__c == seExisting.Service_Provider__c)
                        se.addError(Label.Service_Engagement_Mapping_Error_Message);
               }
           }
           
      }
      public void populateServiceEngagementDocumentURL(List<Opportunity> lstOpp)
    {
        Map<Opportunity,String> mapOppAndServiceProvider = new Map<Opportunity,String>();
        Map<String, Service_Provider_Engagement_Mapping__c> mapServiceProviderAndMapping = new Map<String,Service_Provider_Engagement_Mapping__c>();
        List <Service_Provider_Engagement_Mapping__c> lstMapping = new List <Service_Provider_Engagement_Mapping__c>();
        List<Id> opptyId= new List<Id>();
        //Populating mapOppAndServiceProvider
        for(Opportunity opp : lstOpp)
        {
            mapOppAndServiceProvider.put(opp, opp.Service_Provider__c);
            opp.Service_Engagement_Document_URL__c = null;
            //opp.Alliance_Engagement_Document_URL__c = null;
            opptyId.add(opp.Id);
        }
        
        if(mapOppAndServiceProvider.values() != null)
            lstMapping = [select name, Service_Provider_Engagment_URL__c, Service_Provider__c
                            from Service_Provider_Engagement_Mapping__c
                            where Service_Provider__c in :mapOppAndServiceProvider.values()
                                AND Service_Provider_Engagment_URL__c <> null
                                AND Service_Provider_Engagment_URL__c <> ''
                            limit 50000];
        
        if(lstMapping.size() > 0)
        {
            for(Service_Provider_Engagement_Mapping__c se : lstMapping)
            {
                mapServiceProviderAndMapping.put(se.Service_Provider__c , se);
            }

            for(Opportunity opp : lstOpp)
            {
                if (mapServiceProviderAndMapping.keyset().contains(opp.Service_Provider__c))
                {
                    opp.Service_Provider_Engagement_Document__c = mapServiceProviderAndMapping.get(opp.Service_Provider__c).id;
                    
                    //opp.Alliance_Engagement_Document_URL__c = mapPrimaryAlliancePartnerAndMapping.get(opp.Primary_Alliance_Partner__c).Alliance_Engagement_URL__c;
                }
            }
          // Feedpost(opptyId);
        }
     //End of March Relase 2013
}

 public void Feedpost(List<Id> opptyid)
    {
        List<FeedItem> lstFeedItem = new List<FeedItem>();
       // for(Id obj : opptyid){
             FeedItem fItem = new FeedItem();
             fItem.Type = 'Serice Provider';
             fItem.ParentId =opptyid[0];
             fItem.Title='Service Provider Engagment'; 
             fItem.Body = 'Service Provider is linked to this opportunity';
             lstFeedItem.add(fItem);
       //  }
         try{
           insert lstFeedItem;
         }
         catch(Exception ex){
             System.debug('---Exception---'+ex);  
         }
        
    }

    
}