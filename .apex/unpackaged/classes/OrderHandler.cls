public class OrderHandler implements  TriggerTemplate.Handler
{
    private List<Order__c> newValues;
    private List<Order__c> oldValues;
    private Map<Id, Order__C> newMap;
    private Map<Id, Order__C> oldMap;

    public void setValues(List<sObject> newValues, List<sObject> oldValues,
                         Map<Id, sObject> newMap ,Map<Id, sObject> oldMap){
        this.newValues = newValues;
        this.oldValues = oldValues;
        this.oldMap = (Map<Id, Order__c>) oldMap;
        this.newMap = (Map<Id, Order__c>) newMap;

    }
    public void handle(TriggerTemplate.TriggerAction action){

        if (action == TriggerTemplate.TriggerAction.beforeInsert){
            OrderService.setTax(newValues);
            OrderService.setIncome(newValues);

        }
        if( action == TriggerTemplate.TriggerAction.afterInsert){
            Set <Id> parentId = Utils.getParentIds(newValues,'Account__c');
            Map <Id, Account> relatedAccounts = new Map<Id, Account>([SELECT Total_Income__c, Last_Payment_Date__c
                    FROM Account
                    WHERE id in :parentId]);
            System.debug(relatedAccounts);
            AccountService.setTotIncome(relatedAccounts);
            AccountService.setLastPayDay(relatedAccounts);
            TaskService.createTask(newValues);


        }
        if( action == TriggerTemplate.TriggerAction.beforeUpdate)
        {
            OrderService.setTax(newValues);
            OrderService.setIncome(newValues);
        }
        if ( action  == TriggerTemplate.TriggerAction.afterUpdate)
        {
            List<Order__c> withModifiedAccount = Utils.getModifiedObjects(new List<String>{'Account__c'},
                                                                            newValues,oldValues);
            Set <Id> parentsId = Utils.getParentIds(withModifiedAccount,'Account__c');
            Map <Id, Account> relatedAccounts = AccountService.getRelatedAcc(parentsId);
            AccountService.setTotIncome( relatedAccounts);
            AccountService.setLastPayDay(relatedAccounts);
        }
        if (action == TriggerTemplate.TriggerAction.afterDelete)
        {
            Set <Id> parentsId = Utils.getParentIds(oldValues,'Account__c');
            Map <Id, Account> relatedAccounts = AccountService.getRelatedAcc(parentsId);
            AccountService.setTotIncome( relatedAccounts);
            AccountService.setLastPayDay(relatedAccounts);
        }
        if  (action == TriggerTemplate.TriggerAction.afterUndelete)
        {
            Set <Id> parentsId = Utils.getParentIds(newValues,'Account__c');
            Map <Id, Account> relatedAccounts = AccountService.getRelatedAcc(parentsId);
            AccountService.setTotIncome( relatedAccounts);
            AccountService.setLastPayDay(relatedAccounts);
        }

    }
}