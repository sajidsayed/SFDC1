public class EMCException extends Exception {

    public String ProcessID {get; set;}
    public List <String> AffectedRecords {get; set;}

    public EMCException (String errMsg, String procId, List <String> affectedIds) {
        this.setMessage(errMsg);
        this.ProcessId = procId;
        this.AffectedRecords = affectedIds;
    }
    /**
     *   @Description : Test Method for the Controller Class
     */

    public static testmethod void testException(){
        List<String> affected=new list<string>{'test1','test2'};
        EMCException ex=new EMCException('Error','1111',affected);
         
    }
}