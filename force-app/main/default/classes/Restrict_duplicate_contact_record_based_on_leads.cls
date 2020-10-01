@isTest
public class CountChildAccountTest {

    @istest
public static void testme(){
   account a = new account(name='test', ShippingStreet = '155 De Haro', ShippingCity ='San Francisco', ShippingState = 'CA', ShippingPostalCode = '94044');
        insert a;
        account a1 = new account(ParentId=a.id,name='test', ShippingStreet = '155 De Haro', ShippingCity ='San Francisco', ShippingState = 'CA', ShippingPostalCode = '94044');
        insert a1;
}
}