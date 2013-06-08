/**

Created By		:	Avinash Kaltari
Created Date	:	17 May 2012
Purpose			:	To increase the coverage of GeoSearchCriteria class

*/
@isTest
private class GeoSearchCriteria_TC 
{

    static testMethod void GeoSearchCriteriaTest() 
    {
    	GeoPoint gp = new GeoPoint(90,90);
    	List<GeoPoint> lstGP = new List<GeoPoint>();
    	lstGP.add(gp);
    	
    	GeoBounds gb = new GeoBounds(lstGP);
    	
    	GeoSearchCriteria gsc = new GeoSearchCriteria(gp, 90, UnitOfLength.MILES);
    	GeoSearchCriteria gsc1 = new GeoSearchCriteria(gp, 90, UnitOfLength.KILOMETERS);
    	String str = gsc.toStr();
    	
    	gsc1 = gsc.cloneByDistanceIncrement(1, UnitOfLength.KILOMETERS);
    	
    	Double distance = gsc.distanceInMiles;
    	
    	
    	
    	try
    	{
    		gsc = new GeoSearchCriteria(gp, null, UnitOfLength.MILES);
    		
    	}
    	catch(Exception e)
    	{
    		
    	}
    	
    		
    		
    	try
    	{
    		gsc = new GeoSearchCriteria(null, 90, UnitOfLength.MILES);
    	}
    	catch(Exception e)
    	{
    		
    	}try
    	{
    		gsc = new GeoSearchCriteria(gp, 90, null);
    	}
    	catch(Exception e)
    	{
    		
    	}try
    	{
    		gsc = new GeoSearchCriteria(gp, 1000000000, UnitOfLength.KILOMETERS);
    	}
    	catch(Exception e)
    	{
    		
    	}
    }
}