//
//  IDController.m
//  Garenta
//
//  Created by Ata  Cengiz on 7.03.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "IDController.h"

@implementation IDController

- (BOOL)idChecker:(NSString *)iID andName:(NSString *)iName andSurname:(NSString *)iSurname andBirthYear:(NSString *)iYear {
    
    iName = [iName uppercaseStringWithLocale:[NSLocale localeWithLocaleIdentifier:@"tr"]];
    iSurname = [iSurname uppercaseStringWithLocale:[NSLocale localeWithLocaleIdentifier:@"tr"]];
    
    NSString *header = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ws=\"http://tckimlik.nvi.gov.tr/WS\">"
                        "<soapenv:Header/>"
                        "<soapenv:Body>"
                        "<ws:TCKimlikNoDogrula>"];
    
    NSString *body = [NSString stringWithFormat:@"<ws:TCKimlikNo>%@</ws:TCKimlikNo>"
                      "<ws:Ad>%@</ws:Ad>"
                      "<ws:Soyad>%@</ws:Soyad>"
                      "<ws:DogumYili>%@</ws:DogumYili>", iID, iName, iSurname, iYear];
    
    NSString *footer = [NSString stringWithFormat:@"</ws:TCKimlikNoDogrula>"
                        "</soapenv:Body>"
                        "</soapenv:Envelope>"];
    
    
    NSString *soapMsg = @"";
    
    soapMsg = [NSString stringWithFormat:@"%@%@%@",header, body, footer];
    
    NSMutableURLRequest *soapReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://tckimlik.nvi.gov.tr/Service/KPSPublic.asmx"]];
    [soapReq addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [soapReq setHTTPMethod:@"POST"];
    [soapReq setHTTPBody:[soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSURLResponse *headerResponse;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:soapReq returningResponse:&headerResponse error:&error];
    NSString *response = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];

    
    // Değişmeli bu
    return [response containsString:@"true"];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    webData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *response = [[NSString alloc] initWithBytes:[webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"asd");
    
}


@end
