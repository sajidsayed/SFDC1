/*
  17-10-2011    Srinivas Nalllapati     WR-172941   Create exemption for certain EMC Classifications for Top Offender
*/
public with sharing class MassChangeLeadStatusChangeController {
    public List<Lead> lstLead {get;set;}
    public Map<id,Lead> mapLead;
    public Boolean blnRecordPresent{get; set;}
    public List<LeadWrapper> lstWrapper {get;set;} 
    public String newStatus {get;set;}
    public String ClosedReason {get;set;}
    
    public Boolean isMassChangeUser {get;set;}
    public Boolean isClosedSelected {get;set;}
    public boolean isNoLeadSelected {get;set;}
    
    public integer NoofFailedrecords {get;set;}
    public integer NoofSuccessrecords {get;set;}
    
    public PageReference checkSelectedStatus(){
        if(newStatus == 'Closed')
            isClosedSelected = true;
        else{
            isClosedSelected = false;    
            ClosedReason = null;
        }
        return null;    
    }
    
   
    public MassChangeLeadStatusChangeController(ApexPages.StandardSetController controller)
    {
        isClosedSelected = false;
        lstLead = controller.getSelected();
        lstWrapper = new List<LeadWrapper>();
 
        Profile LoggedUserProfile = [Select Name, PermissionsManageLeads From Profile where id =:UserInfo.getProfileId()];
        isMassChangeUser = LoggedUserProfile.PermissionsManageLeads;
        
        //Check if there  are any record selected for update.
        if(lstLead!=null && lstLead.size()>0)
        {
            isNoLeadSelected = false;
            //Setting blnRecordPresent to true , Save button show's of the VF page.
            blnRecordPresent=true;
            //Hold set of Id of records selected for update
            Set<id> setleadId = new Set<Id>();
            //Loop on records to add Id to set.
            for(Lead led: lstLead)
            {
                setleadId.add(led.id);
            }
            //Query Lead for fields used.
            mapLead = new map<id,Lead>([Select Status, State, OwnerId, Name, Email, CreatedDate, Company From Lead where id in:setleadId]);
            lstLead = mapLead.values();            
        }else
            isNoLeadSelected= true;
    }
    
    
    //*** Method called on Save button click.***//
    public PageReference customSave()
    {
        for(Lead ld :lstLead)
        {
            ld.status = newStatus;
            if(newStatus=='Closed')
                ld.Closed_Reason__c = ClosedReason ;
        }
        
        database.saveresult[] lstresult = database.update(lstLead, false);
        
        lstWrapper = new list<LeadWrapper>();
        NoofFailedrecords = 0;
        NoofSuccessrecords = 0;
        
        map<id,Lead> mapLeadsAfterSave = new map<id,Lead>([Select Status, State, OwnerId, Name, Email, CreatedDate, Company From Lead where id in:mapLead.keyset()]);
        
        for(Integer i=0; I<lstLead.size();i++)
        {
            database.saveresult sr = lstresult[i]; 
            if(sr.isSuccess())
            {
                LeadWrapper ledWrap = new LeadWrapper(lstLead[i],'Success');
                lstWrapper.add(ledWrap);
                NoofSuccessrecords += 1; 
            }
            else{
                    String dataErrs = '';
                    //Looping on Database error for ith record.
                    for (Database.Error err : sr.getErrors()) 
                    {
                        //Adding error message in dataErrs.
                        dataErrs += err.getMessage();
                    }
                LeadWrapper ledWrap = new LeadWrapper(mapLeadsAfterSave.get(lstLead[i].id),'Error: '+dataErrs );
                lstWrapper.add(ledWrap);
                NoofFailedrecords += 1;                 
            }
        }
        ShowResult = true;
        return null;
    }
    
    public boolean ShowResult{get;set;}
    
    //*** Wrapper Class***//
    public class LeadWrapper
    {
        //Holds Lead record. Defining get,set property.
        public Lead objLead {get; set;}
        //Holds Error String. Defining get,set property.
        public String dmlError {get;set;}
        //Defining method with arguments (Lead, success message).
        public LeadWrapper(Lead objLead, String dmlError)
        {
            this.objLead = objLead;
            this.dmlError = dmlError;
        }
    }
}//End of class