//
//  MailSoapHandler.m
//  Garenta
//
//  Created by Ata Cengiz on 31/10/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "MailSoapHandler.h"

@implementation MailSoapHandler

+ (BOOL)sendMessage:(NSString *)message toMail:(NSString *)mail withFirstname:(NSString *)firstname andLastname:(NSString *)lastname {
    NSURL *connectionURL = [NSURL URLWithString:@"http://mobil.garenta.com.tr/hgs/Asmx/SendMail.asmx"];
    
    NSString *signature = @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\">";
    NSString *openHeader = @"<soapenv:Header/>";
    NSString *openBody = @"<soapenv:Body>";
    NSString *openFunction = @"<tem:SendConfirmationMail>";
    NSString *mailAdress = [NSString stringWithFormat:@"<tem:email>%@</tem:email>", mail];
    NSString *firstName = [NSString stringWithFormat:@"<tem:firstName>%@</tem:firstName>", firstname];
    NSString *lastName = [NSString stringWithFormat:@"<tem:lastName>%@</tem:lastName>", lastname];
    NSString *generatedCode = [NSString stringWithFormat:@"<tem:code>%@</tem:code>", message];
    NSString *closeFunction = @"</tem:SendConfirmationMail>";
    NSString *closeBody = @"</soapenv:Body>";
    NSString *closeHeader = @"</soapenv:Envelope>";
    
    NSString *soapMsg = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@", signature, openHeader, openBody, openFunction, mailAdress, firstName, lastName,generatedCode, closeFunction, closeBody, closeHeader];
    NSMutableURLRequest *soapReq = [NSMutableURLRequest requestWithURL:connectionURL];
    
    NSString *msgLength = [NSString stringWithFormat:@"%d" , [soapMsg length]];
    [soapReq addValue:@"text/xml; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [soapReq addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [soapReq setHTTPMethod:@"POST"];
    [soapReq setHTTPBody:[soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error;
    NSURLResponse *response;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:soapReq returningResponse:&response error:&error];
    
    if (error == nil && data != nil && [data length] > 0) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
