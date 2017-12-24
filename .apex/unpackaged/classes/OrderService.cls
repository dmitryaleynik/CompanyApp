/**
 * Created by HP on 04.12.2017.
 */
public class OrderService {

    public static void setTax (List<Order__c> orders)
    {
        List<Order__c> result = new List<Order__C>();
        for (Order__c order : orders)
        {
            if(order.Payment_Type__c == 'Cash')
            {
                order.Tax_Percentage__c = 5;
                order.Tax_Amount__c = order.Payment_Amount__c * 0.05;

            }else if (order.Payment_Type__c == 'Credit Card')
            {
                order.Tax_Percentage__c = 5.5;
                order.Tax_Amount__c = order.Payment_Amount__c * 0.055;
            }else if (order.Payment_Type__c == 'Check' )
            {
                order.Tax_Percentage__c = 7;
                order.Tax_Amount__c = order.Payment_Amount__c * 0.07;
            }
            result.add(order);
        }
    }
    public static void setIncome (List<Order__c> orders)
    {
        List<Order__c> result = new List<Order__C>();
        for(Order__c order : orders)
        {
            order.Income__c = order.Payment_Amount__c - order.Tax_Amount__c;
            result.add(order);
        }
    }

}