global class AssignNewOwner implements Database.Batchable<sObject>  {
   
    global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator([SELECT name, Tax_Percentage__c,Payment_Amount__c FROM Order__c]);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
     
       for (sObject obj : scope){
           Order__c order = (Order__c) obj; 
           order.Tax_Percentage__c = 3 ;
           order.Tax_Amount__c = 0.03 * order.Payment_Amount__c;
           order.Income__c = order.Payment_Amount__c  *  0.97; 
       }
       update scope;
    }

   global void finish(Database.BatchableContext BC){
   }
    

}