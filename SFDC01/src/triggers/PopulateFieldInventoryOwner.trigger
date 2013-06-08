/* 
  5-5-2011   Srinivas Nallapati        Field Inventory 
                                       this trigger sets the value of FI_Owner.  FI_Ower is a duplicate of 
                                       the Field Inventory owner.  This duplicate relationship is to support
                                       formula fields which display values from the User record for District, Area, 
                                       etc.
  6-8-2011   Srinivas Nallapati        this trigger is needed because the data loader process that initially populates
                                       this object uses the User external id field   employee_number__c for setting the owner of the object and the data loader does not support external ids for establishing    user ownership 
*/   
trigger PopulateFieldInventoryOwner on Field_Inventory__c (before insert, before update) 
{
    try
    {
        if(Trigger.isInsert) 
        {
           for (Field_Inventory__c fi : Trigger.new)
           {
               if(fi.FI_Owner__c != null)
                   fi.OwnerId=fi.FI_Owner__c ;
           }
        }
        else
        {    
            for(Integer i=0;i<Trigger.new.size();i++)
            {
                if((Trigger.new[i].FI_Owner__c!=Trigger.old[i].FI_Owner__c) && Trigger.new[i].FI_Owner__c!= null )
                    Trigger.new[i].ownerid=Trigger.new[i].FI_Owner__c;                    
            }
        }
    }catch(Exception e)
    {
        trigger.new[0].adderror('The following error occured, Please contact Administrator \n '+e.getMessage());
    }
}//End of Trigger