/*===========================================================================+
|  HISTORY                                                                   
| 
|  DATE       DEVELOPER       WR       DESCRIPTION                                
|
   ====       =========       ==       ===========  
|  02-Apr-2013  Prachi                 Created 
+===========================================================================*/ 
@isTest(SeeAllData = true)
private class SetCondition_TC {
          public Static String field ='field';
          public Static Operator INCLUDES  = Operator.INCLUDES;
          public Static Operator EXCLUDES = Operator.EXCLUDES;
          public Static Operator INX = Operator.INX;
          public Static Operator NOT_IN = Operator.NOT_IN;
          public Static List<Object> values = new List<Object>();
          public Static SoqlBuilder builder = new SoqlBuilder();
          public Static SoqlOptions options = new SoqlOptions ();
static testMethod void SetCondition(){
    Test.StartTest();
    values.add('object');
    SetCondition obj=new SetCondition();
    SetCondition obj1=new SetCondition(field);
    SetCondition obj11=new SetCondition(field,INCLUDES,values);
    SetCondition obj2=new SetCondition(field,INCLUDES ,builder );
    SetCondition obj3=new SetCondition(field,EXCLUDES,builder );
    SetCondition obj4=new SetCondition(field,INX ,builder );
    SetCondition obj5=new SetCondition(field,NOT_IN,builder );
    obj.includes(builder );
    obj.excludes(builder );
    obj.inx (builder );
    obj.notIn (builder );
    obj.includes(values );
    obj.excludes(values );
    obj.inx (values );
    obj.notIn (values );
    //obj.toSoql();
    //obj.toSoql(Options);
    Test.StopTest();
}
}