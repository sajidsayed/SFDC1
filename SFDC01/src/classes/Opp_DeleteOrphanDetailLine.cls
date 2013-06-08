/*===========================================================================+
 |  //This class is to delete the orphan detail lines from Detail Line object to remove Attempt to de-reference a null object.
 |	//Due to number of processes (Mass Reassignment Bug, Data Loader Removal from Opportunity Sales Team) there instances where 
 |	//there exists a detail line on the opportunity, but there is no opportunity team member on the opportunity sales team.  
 |	//When this event occurs Update Sales Team/Splits button is no longer usable as null reference exception is raised.  
 |	//Requirement here is to delete an “orphan detail line(s)” so that user can transact on the opportunity
 |  HISTORY                                                                  
 |  DATE       DEVELOPER     DESCRIPTION                               
 |  ====       =========     =========== 
 | 
 |  16-Feb-10  Shipra       WR# 135993 Initial creation to delete orphan detail lines.
 |  23-Jul-10  Shipra		WR# 141882 Removed With Share clause to make code working for 
 +===========================================================================*/
  

public class Opp_DeleteOrphanDetailLine 
{
		
	//Variable declaration.
	
	//This holds list of OpportunityTeamMember on the Opportunity.
	public List<OpportunityTeamMember> lst_salesTeamMem=new List<OpportunityTeamMember>(); 
  	//This holds list of Detail_Line__c on the Opportunity which are Orphan(exist without SalesTeamMember).
  	public List<Detail_Line__c> lst_OrpDetailLine=new List<Detail_Line__c>();
  	//This holds Set of ID of SalesTeamMember on Opportunity.
  	Set <ID> Set_distinctSalesMemIds = new Set <ID>();
  	
  	 
	//Method to track Orphan Detail Lines from Opportunity.	
	//This Method also deletes the Orphan detail lines.
	
	public void delOrphanDetailLines(id id_Oppty)
	{
		try
		{
			//Fetch the list of Opportunity Team Member (Sales Team Memner)in List lst_salesTeamMem.
			lst_salesTeamMem=[Select UserId, TeamMemberRole, OpportunityId, Id From OpportunityTeamMember  where OpportunityId =: id_Oppty ];
			System.debug('Thevalue of salesteam is'+lst_salesTeamMem);
			//Loop on Opportunity Team Member Records.
			for(OpportunityTeamMember oppTM: lst_salesTeamMem)
			{
				//Add Sales Team members's user Id in Set Set_distinctSalesMemIds.
				System.debug('Thevalue of oppTM is'+oppTM);
				Set_distinctSalesMemIds.add(oppTM.UserId);
			}
			// Fetch the list of Orphan Detail lines in List lst_OrpDetailLine.Detail Lines without salesteam member on oppty.
			lst_OrpDetailLine=[Select Id,Split__c,Product__r.Name, Opportunity__c,Opportunity_Access_Level__c,Quote_Amount__c, Opportunity__r.Id,  OpportunityTeamMember__c, Owner__c From Detail_Line__c   where Opportunity__r.Id =: id_Oppty and Owner__c NOT in: (Set_distinctSalesMemIds)];
			
			//Check for Null value of lst_OrpDetailLine
			if(lst_OrpDetailLine!=null)
			{
				//If lst_OrpDetailLine is not null (Orphan detail lines exist on oppty).
				//DML to delete lst_OrpDetailLine(Orphan Detail lines.)
				delete lst_OrpDetailLine;
			}
							
		}
		//Catch block to catch the exception occurring.
		catch (System.DmlException ex1)
		{
			//Log the exception to track the issue.
			System.debug('The exception occurred in deletion is'+ex1);
		}
	
	}

}
/* 

public with sharing class Opp_DeleteOrphanDetailLine {


	OP_SSF_CommonUtils cls_oppSSF = new OP_SSF_CommonUtils();
	Public	Map<Id,Map<Id,SalesTeamMember>> map_salesTeamMbr = new Map<Id,Map<Id,SalesTeamMember>>();
	public list<Detail_Line__c> deleteThisDetailLines=new list<Detail_Line__c>();
	
	public Opp_DeleteOrphanDetailLine(){
		
	}

	Public void delOrphanDetailLines(list<id> List_Oppty){
		
		map_salesTeamMbr = cls_oppSSF.getSalesTeamMembers(List_Oppty);
			for(Id Oppty: List_Oppty ){
				for( SalesTeamMember stm : map_salesTeamMbr.get(Oppty).values() ){
					log('stm===>'+stm);
					 if(stm.opptyTeamMember == null && stm.detailSplit != null ){
					 	log('This is Orphan Detail Line===>'+stm.detailSplit);
					 	 deleteThisDetailLines.add(stm.detailSplit);
					 	
					 }
				}
		
		}
		log('I am going to delete this list ===>'+deleteThisDetailLines);
		delete deleteThisDetailLines;
	
	}
	
	private void log(String logMsg){
	        System.debug('*** '+logMsg+' ***');
	 }
}
*/