@isTest
private class OP_SSF_Exceptn_TC {
    public static testmethod void test(){
        //Exception e = new Exception();
        Account a = new Account();
        Account[] accs = new Account[]{a, a};        

        try{
            insert accs;
        }
        Catch(Exception e){
            OP_SSF_Exception opSSFException = new OP_SSF_Exception(3,e);
        }          
        
    }
}