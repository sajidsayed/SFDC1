@istest
public class MassChangeLeadStatusChangeController_TC {

  Public static testmethod void method(){
      
      List<lead> lst=new List<lead>();
      lead le1=new lead();
      lead le2=new lead();
      le1=[select id from lead limit 1];
      //le2=[select id from lead]
      
      lst.add(le1);
      //lst.add(le2); 
      insert lst;
      ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(lst);
      MassChangeLeadStatusChangeController con=new MassChangeLeadStatusChangeController(setcon);
      MassChangeLeadStatusChangeController.LeadWrapper lwp = new MassChangeLeadStatusChangeController.LeadWrapper(le1,'dmlerror' );
      PageReference p1=con.checkSelectedStatus();
      PageReference p2=con.customSave();
      
      }
}