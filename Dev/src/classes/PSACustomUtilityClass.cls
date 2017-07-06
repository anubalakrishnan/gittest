// Generic utility class to use in customization logic
public class PSACustomUtilityClass {
    
    // method to send email to single internal recipient
    public static void sendEmailToSingleRecipient(String recipient, String subject, String mailBody) {               
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectID(recipient);
        mail.setSaveAsActivity(false);
        mail.setSubject(subject);
        mail.setHTMLBody(mailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public static void sendEmailToMultipleRecipient(List<Id> recipient, String subject, String mailBody) {               
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(recipient);
        mail.setSaveAsActivity(false);
        mail.setSubject(subject);
        mail.setHTMLBody(mailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public static Messaging.SingleEmailMessage buildEmail(String recipient, String subject, String mailBody) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectID(recipient);
        mail.setSaveAsActivity(false);
        mail.setSubject(subject);
        mail.setHTMLBody(mailBody);
        return mail;        
    }
}