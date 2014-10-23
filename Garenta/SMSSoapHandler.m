//
//  SMSSoapHandler.m
//  Garenta
//
//  Created by Ata Cengiz on 22/10/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "SMSSoapHandler.h"

@implementation SMSSoapHandler

+ (NSString *)generateCode {
    
    NSURL *connectionURL = [NSURL URLWithString:@"http://mobil.garenta.com.tr/hgs/Asmx/SendSms.asmx"];
    
    NSString *signature = @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\">";
    NSString *openHeader = @"<soapenv:Header/>";
    NSString *openBody = @"<soapenv:Body>";
    NSString *function = @"<tem:GenerateCode/>";
    NSString *closeBody = @"</soapenv:Body>";
    NSString *closeHeader = @"</soapenv:Envelope>";
    
    NSString *soapMsg = [NSString stringWithFormat:@"%@%@%@%@%@%@", signature, openHeader, openBody, function, closeBody, closeHeader];
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
        NSString *response = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];

        NSArray *generatedCode = [response componentsSeparatedByString:@"<GenerateCodeResult>"];
        
        if (generatedCode.count > 0) {
            NSArray *afterCode = [[generatedCode objectAtIndex:1] componentsSeparatedByString:@"</GenerateCodeResult>"];
            
            if (afterCode.count > 0) {
                return [afterCode objectAtIndex:0];
            }
        }
    }
    
    return @"";
}

+ (BOOL)sendSMSMessage:(NSString *)message toNumber:(NSString *)phoneNumber {
    NSURL *connectionURL = [NSURL URLWithString:@"http://mobil.garenta.com.tr/hgs/Asmx/SendSms.asmx"];
    
    NSString *signature = @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\">";
    NSString *openHeader = @"<soapenv:Header/>";
    NSString *openBody = @"<soapenv:Body>";
    NSString *openFunction = @"<tem:Send>";
    NSString *gsmNumber = [NSString stringWithFormat:@"<tem:gsmNumber>%@</tem:gsmNumber>", phoneNumber];
    NSString *generatedCode = [NSString stringWithFormat:@"<tem:code>%@</tem:code>", message];
    NSString *closeFunction = @"</tem:Send>";
    NSString *closeBody = @"</soapenv:Body>";
    NSString *closeHeader = @"</soapenv:Envelope>";
    
    NSString *soapMsg = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@", signature, openHeader, openBody, openFunction, gsmNumber, generatedCode, closeFunction, closeBody, closeHeader];
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
