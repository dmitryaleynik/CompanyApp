public class AccountService
{
    public static void  setTotIncome( Map<Id, Account> relatedAccount)
    {
        for(Account account : relatedAccount.values())
        {
            account.Total_Income__c = 0;
        }
        AggregateResult [] aggregateResults = [SELECT Sum(Income__c) sum , Account__c
                                               FROM Order__c 
                                               WHERE Account__c in :relatedAccount.keySet()
                                               GROUP BY Account__c];
        for (AggregateResult aggRes : aggregateResults)
        {
            Double totIncome =(Double) aggRes.get('sum');
            Account currAccount = relatedAccount.get((Id)aggRes.get('Account__c'));
            currAccount.Total_Income__c = totIncome;
        }
        update relatedAccount.values();

    }
    public static Map<Id, Account> getRelatedAcc (Set<Id> parentsId)
    {
        Map <Id, Account> relatedAccount = new Map<Id, Account>([SELECT Total_Income__c, Last_Payment_Date__c
                FROM Account
                WHERE id in :parentsId]);
        return  relatedAccount;
    }

    public static void setLastPayDay (Map<Id, Account> relatedAccounts)
    {
        for(Account account : relatedAccounts.values())
        {
            account.Last_Payment_Date__c = null;
        }
        AggregateResult [] aggregateResult = [SELECT MAX(CreatedDate) max, Account__c
                                              FROM  Order__c
                                              WHERE Account__c in : relatedAccounts.keySet()
                                              GROUP BY Account__c];
        for (AggregateResult aggRes :aggregateResult)
        {
            Account currentAcc = relatedAccounts.get((Id)aggRes.get('Account__c'));
            currentAcc.Last_Payment_Date__c = (Datetime)aggRes.get('max');
        }
        update relatedAccounts.values();
    }

}