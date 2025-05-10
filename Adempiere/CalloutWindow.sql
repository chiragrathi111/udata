
Window context variables start with a W_ prefix
Login context variables start with G_ prefix
Parameters for callout start with A_ prefix
A_WindowNo
A_Tab
A_Field
A_Value
A_OldValue
A_Ctx
====================================================

import org.compiere.model.MPayment;

if(A_Tab.getValue("TenderType") != null && A_Tab.getValue("CreditCardType") != null && A_Tab.getValue("CreditCardType") != "")
{
   MPayment pmt = new MPayment(A_Ctx, 0,null);
   pmt.setTenderType(A_Tab.getValue("TenderType"));
   pmt.setC_Currency_ID(A_Tab.getValue("C_Currency_ID"));
   pmt.setCreditCardType(A_Tab.getValue("CreditCardType"));
   pmt.setPaymentProcessor();
   A_Tab.setValue("C_BankAccount_ID", pmt.getC_BankAccount_ID());
   pmt = null;
}
else
{
   A_Tab.setValue("C_BankAccount_ID", 0);
}    
result="";


====================================================

if (A_Value != null && A_Value instanceof String) {
    A_Tab.setValue(A_Field, ((String)A_Value).toUpperCase());
}
result = "";

====================================================
Tesing:-

if (A_Value != null && A_Value instanceof String) {
    def email = A_Value;
    if (!email.contains("@")) {
        result = "Invalid email: The value must contain '@'";
    } else {
        result = "";
    }
} else {
    result = ""; 
}
