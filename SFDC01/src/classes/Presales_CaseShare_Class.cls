/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  11/09/2011     Leonard Victor       This class is used for Case Sharing for Requestor and parent child Sharing     
    20/12/2011     Leonard Victor       Updated  insertUpd ateShare to populate Caseid field in Sharing Reason Object and also changes the 
                                        delete criteria for Sharing Reason Object and Restricted Duplicate entry in to Sharing Reason Object                                                           
    05/01/2012     Leonard Victor       Udated the Caseshare_reason__c insertion to include caseid
    06/01/2012     Leonard Victor       Change the code to reduce consecutive apex call     
 |  14March2013    Ganesh Soma    WR#247113    SOQL Optimization: Refactored some parts of code                               
 +==================================================================================================================**/


public class Presales_CaseShare_Class{
private static boolean chkShareFlag  = false;

private static boolean reasonFlag  = false;
public static boolean hasAlreadyChangedShare() {
    return chkShareFlag  ;
}

// By setting the variable to true, it maintains this new value throughout the duration of the request

public static void setAlreadyChangedShare() {
    chkShareFlag   = true;
 }


// Case Share Issue

public static boolean chkShareFlag1  = false;
public static boolean deleteShareFlag  = false;
public static Integer chkShr  = 0;
public static List<Case> caseList = new List<Case>();
public static List<Id> idparentList = new List<Id>();




// Method to Insert Record into CaseShare Object
 public void insertUpdateShare(List<Id> caseLst,String insertOrUpdate,string mailID ,List<Case> oldCaseLst,List<Id> parentId , Boolean checkCreator, List<Case> lstNewCase , Boolean ownerChange , Id oldUsrId , Boolean onlyCntChange)
 {
 	if(chkShareFlag1 || ownerChange)
    {
    	List<CaseShare> lstShare = new List<CaseShare>();
        Map<Id ,Id> mapCase = new MAp<Id, Id>();
        Map<Id,string> recMap = new Map<Id,String>();
        Map<String,String> mapGroup= new Map<String,String>();
        Map<String,id> mapGrpId= new Map<String,id>();
        String CSId =null;
        List<Id>CSRId = new List<Id>();
        List<CaseShare> shrLst = new List <CaseShare>();
        List<Presales_CaseSharingReasons__c> CSRLst = new List<Presales_CaseSharingReasons__c>();
        Map<Id,List<Id>> caseMap = new Map<Id,List<id>>();
        Map<Id,List<Id>> mapCaseid = new Map<Id,List<id>>();
        List<id> cntOwnerLst = new List<id>();
        try{    
        	List<Id> userId = new List<Id>();
            for (Integer caseRecord=0;caseRecord<caseLst.size();caseRecord++)  {
            	recMap.put(caseLst[caseRecord],'Application');
            }
         caseList= [Select id,parentid from case where parentid in :lstNewCase];
		if(parentId.size()==0 && caseList.size()>0){
        	for(Case cs : caseList){
				if (cs.parentid!=null){
                	//For Setting Parent Values*/
                    if(mapCaseid.containsKey(cs.id)){
                    	mapCaseid.get(cs.id).add(cs.parentid);
                    }
                    else
                    {
                    	List<Id> idList = new List<Id>();
                        idList.add(cs.parentid);
                        mapCaseid.put(cs.id , idList);
                    }
                }
        	}
            if(insertOrUpdate=='U' && !deleteShareFlag){
            	//COMMENTED AS PART OF CODE REFACTORING:
                /*if(mapCaseid.size()>0 ){
                	List<CaseShare> shtList = [Select Id from CaseShare where caseid in:mapCaseid.keyset() and rowcause = 'Manual' and  userorgroupid =:oldUsrId];
                	for(CaseShare csShare : shtList){
                    	shrLst.add(csShare);
                	}
                }
                else
                {
                	shrLst = [Select Id from CaseShare where caseid in:lstNewCase and rowcause = 'Manual'  and userorgroupid =:oldUsrId];
                }*/
                //END OF COMMENT AS PART OF CODE REFACTORING:
                
                Set<Id> setCaseIds = new Set<Id>();
                if(mapCaseid.size()>0) 
                setCaseIds = mapCaseid.keyset();
                else
                {
                  for(Case lst : lstNewCase)
                  {
                  	setCaseIds.add(lst.id);
                  }
                }             
                for(CaseShare csShare : [Select Id from CaseShare where caseid in:setCaseIds and rowcause = 'Manual'  and userorgroupid =:oldUsrId])
                {
                	shrLst.add(csShare);
                }
            }
		}
        else
        {
        	//COMMENTED AS PART OF CODE REFACTORING:
        	/*List<Case> idUsr = [Select Contact_Name_User__c,parentid from case where id in:parentId];
            List<Id> idList = new List<Id>();
			for(Case cse : idUsr){
            	cntOwnerLst.add(cse.Contact_Name_User__c);
            	if(cse.parentid!=null){
                	idList.add(cse.parentid);
            	}
			}
            if(idList.size()>0){
				List<Case> parentOwner = [Select Contact_Name_User__c,ownerid from case where id in:idList];
            	for(Case cse : parentOwner){
                	idparentList.add(cse.Contact_Name_User__c);
                    idparentList.add(cse.ownerid);
                    cntOwnerLst.add(cse.Contact_Name_User__c);
            	}
            }*/
            //END OF COMMENT AS PART OF CODE REFACTORING:
			if(insertOrUpdate=='U' && !deleteShareFlag){
				List<CaseShare> shtList = [Select Id from CaseShare where (caseid in:lstNewCase or caseid in:parentId or caseid in:caseList)  and rowcause = 'Manual' and userorgroupid =:oldUsrId];
                  List<CaseShare> shtListtest = [Select Id,userorgroupid,caseid,rowcause from CaseShare where (caseid in:lstNewCase or caseid in:parentId or caseid in:caseList)];
                 
                for(CaseShare csShare : shtList){
                	shrLst.add(csShare);
                }

			}
        }
        //COMMENTED AS PART OF CODE REFACTORING:
        /*
 		List<String> shareId = new List<String>();
		if(shrLst.size()>0  && insertOrUpdate=='U' && !deleteShareFlag){
        	for(CaseShare cR : shrLst){
            	CSId= '\''+ ((String)cR.Id) +'\'' ;
                shareId.add(CSId);
        	}
		List<Presales_CaseSharingReasons__c> cShare = [select id from Presales_CaseSharingReasons__c where Caseid__c IN :lstNewCase];
        delete cShare;
        delete shrLst;  
		} 
		*/
		//END OF COMMENTED AS PART OF CODE REFACTORING:
		
		if(shrLst.size()>0  && insertOrUpdate=='U' && !deleteShareFlag){
			List<Presales_CaseSharingReasons__c> cShare = [select id from Presales_CaseSharingReasons__c where Caseid__c IN :lstNewCase];
			//Check size of list before deleting
			if(cShare != null && cShare.size() > 0)
				delete cShare;
			delete shrLst;  
		}
		
		for(Case shareObj:lstNewCase){
        	CaseShare reqShare = new CaseShare();
            CaseShare creatorShare = new CaseShare();
            if(shareObj.Is_contact__c == false){
            	reqShare.CaseId = shareObj.Id;
                reqShare.CaseAccessLevel = 'Edit';
                Id id = shareObj.Contact_Name_User__c;
 				reqShare.UserOrGroupId = id;
                lstShare.add(reqShare); 
            }
	        if(chkShareFlag1){
				creatorShare.CaseId = shareObj.Id;
                creatorShare.CaseAccessLevel = 'Edit';
                creatorShare.UserOrGroupId = UserInfo.getUserId();
                lstShare.add(creatorShare);  
	        }
        }                
        if(lstShare.size()>0 ){
        	Database.SaveResult[] uResults =  Database.insert(lstShare,false);
            for(Database.SaveResult result : uResults) {
            	CSRId.add(result.getId());
            } // Ids of case share
            List<CaseShare> lstcs =  [Select id,CaseId,UserOrGroupId,CaseAccessLevel from caseshare where id in:CSRId];
            for(CaseShare csShare : lstcs){
            	mapCase.put(csShare.id , csShare.caseid);
            }
            for(CaseShare casShr : lstcs){
            	//System.debug('CRId--->'+CRId);
                Presales_CaseSharingReasons__c PSR = new Presales_CaseSharingReasons__c();
                PSR.CaseShareId__c = casShr.Id;
                PSR.CaseShareReason__c ='Requester';
                String usrGrp = casShr.UserOrGroupId;
                if(usrGrp.substring(0,3) == '005' && casShr.CaseAccessLevel == 'Edit'){
                	PSR.Caseid__c = mapCase.get(casShr.Id);
                    CSRLst.add(PSR);
                }
                    
            }
            if(!reasonFlag && CSRLst.size()>0){
            	Database.SaveResult[] uReasonResults =  Database.insert(CSRLst,false);
                reasonFlag = true;
            }
         
        }
        }
        catch (System.DmlException e){
        }
    }
 }
         
            

  public void SetParentChildAccess(List<Id> caseNewLst,List<Id> parentId,Map<id,id>requestorId, Map<id,id>mapChildCaseId,Map<id,id>mapParentCaseId ,Boolean ownerChange , Boolean caseOrigin){
	if((chkShareFlag1 || ownerChange) && (caseList.size()>0 || parentId.size()>0))
    {
    	List<CaseShare> caseShareParentLst = new List<CaseShare>();
    	List<CaseShare> caseShareChildLst = new List<CaseShare>();
    	List<Presales_CaseSharingReasons__c> caseShareResonLst = new List<Presales_CaseSharingReasons__c>();
	    List<Presales_CaseSharingReasons__c> caseShareResonParentLst = new List<Presales_CaseSharingReasons__c>();
    	List<ID> CSRParentId =new List<ID>();
    	List<CaseShare> caseShareChildList = new List<CaseShare>();
	    List<CaseShare> caseShareParentList = new List<CaseShare>();
	    List<Presales_CaseSharingReasons__c> caseShareResonList = new List<Presales_CaseSharingReasons__c>();
	    List<Presales_CaseSharingReasons__c> caseShareResonChildList = new List<Presales_CaseSharingReasons__c>();
	    List<ID> CSRChildId =new List<ID>();
	    List<ID> groupPId = new List<ID>();
	    List<ID> casePID =new List<ID>();
	    Map<ID,ID> childMap = new Map<Id,Id>();
	    Map<ID,ID> parentMap = new Map<Id,Id>();
	    Map<Id,List<Id>> caseMap = new Map<Id,List<id>>();
	    List<Case> csList = new List<Case>();
	    Map<Id,List<Id>> mapCase = new Map<Id,List<id>>();
        //To fetch the parent Case share records
    	if(parentId.size()>0){
        	//fetching all the parent related records.
       		caseShareParentLst =[select Id,CaseId,UserOrGroupId,CaseAccessLevel from CaseShare where CaseId IN : parentId and CaseId NOT IN:caseNewLst and rowcause != 'RelatedPortalUser' and userorgroupid not in :idparentList];
    	}
	    else
	    {
	    	if(caseNewLst.size() > 0)
	    	{
	  			csList= [Select id,parentid from case where parentid in :caseNewLst];
	    		caseShareParentLst =[select Id,CaseId,UserOrGroupId,CaseAccessLevel from CaseShare where CaseId IN :caseNewLst and rowcause != 'RelatedPortalUser'];
	    	}
	    }
  		if(csList.size()>0){
        	for(Case cs : csList){
            	//For Setting Child Values
            	if(caseMap.containsKey(cs.parentid)){
                	caseMap.get(cs.parentid).add(cs.id);
            	}
            	else
            	{
                	List<Id> idList = new List<Id>();
                	idList.add(cs.id);
                	caseMap.put(cs.parentid , idList);
            	}
            	//For Setting Parent Values
            	if(mapCase.containsKey(cs.id)){
                	mapCase.get(cs.id).add(cs.parentid);
                }   
            	else
            	{
                	List<Id> idList = new List<Id>();
                	idList.add(cs.parentid);
                	mapCase.put(cs.id , idList);
            	}
        	}
  		}
		for(Integer i=0 ; i<caseShareParentLst.size() ; i++){
        	parentMap.put(caseShareParentLst[i].UserOrGroupId , caseShareParentLst[i].CaseId);
		}
		for(CaseShare cId : caseShareParentLst) {
        	if(mapChildCaseId.size()>0){
        		CaseShare CS = new CaseShare();
        		CS.CaseID = mapChildCaseId.get(cId.CaseId);
        		if(cId.CaseAccessLevel =='All'){
           			CS.CaseAccessLevel = 'Edit';
           			groupPId.add(cId.UserOrGroupId);
           			casePID.add( mapChildCaseId.get(cId.CaseId));
        		}
         		else
         		{
           			CS.CaseAccessLevel = cId.CaseAccessLevel;
         		}
         		Id id = cId.UserOrGroupId;
         		CS.UserOrGroupId = id;
         		caseShareChildLst.add(CS);
        	}
        	else if(caseMap.size()>0)
        	{
        		if(cId!=null && caseMap.containsKey(cId.CaseId))
	        	{
		    		for(Id idIter : caseMap.get(cId.CaseId)){
			        	CaseShare CS = new CaseShare();
			        	CS.CaseID = idIter;
			        	if(cId.CaseAccessLevel =='All'){
			        		CS.CaseAccessLevel = 'Edit';
			           		groupPId.add(cId.UserOrGroupId);
			           		casePID.add( mapChildCaseId.get(cId.CaseId));
			        	}
			        	else
			        	{
			        		CS.CaseAccessLevel = cId.CaseAccessLevel;
			        	}
			        	Id id = cId.UserOrGroupId;
			        	CS.UserOrGroupId = id;
			         	caseShareChildLst.add(CS);
		    		} 
	        	}  
        	}
		}
    try
    {
    	Database.SaveResult[] uResults =  Database.insert(caseShareChildLst,false);
        for(Database.SaveResult result : uResults) {
        	CSRParentId.add(result.getId());
        } // Ids of case share
        List<CaseShare> listcs =  [Select id,CaseId,UserOrGroupId,CaseAccessLevel,ROWCAUSE from caseshare where id in:CSRParentId];
        for(CaseShare CRId : listcs ){
        	Presales_CaseSharingReasons__c PSR_ChildCase = new Presales_CaseSharingReasons__c();
          	PSR_ChildCase.CaseShareId__c = CRId.id;
          	PSR_ChildCase.CaseShareReason__c ='Parent Case';
          	PSR_ChildCase.Caseid__c = CRId.CaseId;
          	caseShareResonParentLst.add(PSR_ChildCase);
        }
       Database.SaveResult[] uReasonResults =  Database.insert(caseShareResonParentLst ,true);
    }   
	catch(DMLException ex){
   		throw ex;
	}//End of //To fetch the parent Case share records     
	//To fetch the Child Case share records
  	if(parentId.size()>0){
    	//fetching all the parent related records.
        caseShareChildList =[select Id,CaseId,UserOrGroupId,CaseAccessLevel from CaseShare where CaseId NOT IN : parentId and CaseId IN:caseNewLst and rowcause != 'RelatedPortalUser' and rowcause != 'Rule'];
  	}
	else
	{
  		caseShareChildList =[select Id,CaseId,UserOrGroupId,CaseAccessLevel from CaseShare where CaseId IN :mapCase.keyset() and rowcause != 'RelatedPortalUser' and rowcause != 'Rule'];
	}
	for(CaseShare cId : caseShareChildList ) {
    	if(mapParentCaseId.size()>0){
        	if(!parentMap.Containskey(cId.UserOrGroupId)){
            	CaseShare CS = new CaseShare();
                CS.CaseID = mapParentCaseId.get(cId.CaseId);
                if(cId.CaseAccessLevel == 'All'){
                	CS.CaseAccessLevel = 'Read';
                    groupPId.add(cId.UserOrGroupId);
                    casePID.add(mapParentCaseId.get(cId.CaseId));
                }
                else
                {
                	CS.CaseAccessLevel = cId.CaseAccessLevel;
                }
                Id id = cId.UserOrGroupId;
                CS.UserOrGroupId =id ;
                caseShareParentList.add(CS);
        	}
    	}
        else if(mapCase.size()>0){
        	for(Id idIter : mapCase.get(cId.CaseId)){
            	CaseShare CS = new CaseShare();
                CS.CaseID = idIter;
                if(cId.CaseAccessLevel == 'All'){
                	CS.CaseAccessLevel = 'Read';
                    groupPId.add(cId.UserOrGroupId);
                    casePID.add(mapParentCaseId.get(cId.CaseId));
                }
                else{
                	CS.CaseAccessLevel = cId.CaseAccessLevel;
                }
                Id id = cId.UserOrGroupId;
                CS.UserOrGroupId =id ;
                caseShareParentList.add(CS);
        	}
        }
	}
    try{
    	Database.SaveResult[] uResults1 =  Database.insert(caseShareParentList,false);
        for(Database.SaveResult result : uResults1) {
        	CSRChildId.add(result.getId());
        } // Ids of case share
        List<CaseShare> lstcs =  [Select id,CaseId,UserOrGroupId,CaseAccessLevel,rowcause from caseshare where id in:CSRChildId];
      	for(CaseShare CRId : lstcs){
        	Presales_CaseSharingReasons__c PSR_ChildCase = new Presales_CaseSharingReasons__c();
            PSR_ChildCase.CaseShareId__c = CRId.id;
            PSR_ChildCase.CaseShareReason__c ='Child Case';
            PSR_ChildCase.Caseid__c = CRId.CaseId;
            caseShareResonChildList.add(PSR_ChildCase);
      	}
		Database.SaveResult[] uReasonResults =  Database.insert(caseShareResonChildList  ,false);
    }
   	catch(DMLException ex){
    	throw ex;
   	}//End of //To fetch the parent Case share records     
    }
	chkShr++;
	if(chkShr>1 && caseOrigin){
    	chkShareFlag1  = true;
    	deleteShareFlag = true;
	}
   	else if(!caseOrigin){
    	chkShareFlag1  = false;
     	deleteShareFlag = true;
   	}
  }//End of m/d

}//end of class