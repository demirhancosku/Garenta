//
//  IDController.m
//  Garenta
//
//  Created by Ata  Cengiz on 7.03.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "IDController.h"

@implementation IDController

- (BOOL)idChecker:(NSString *)iID andName:(NSString *)iName andSurname:(NSString *)iSurname andBirthYear:(NSString *)iYear
{
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
    
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:soapReq delegate:self];

    return NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    webData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
}

//- (void)connectionDidFinishLoading:(NSURLConnection *)connection
//{
//    NSString *response = [[NSString alloc] initWithBytes:[webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
//    
//        NSMutableArray *valueList = [[NSMutableArray alloc] init];
//        NSString *openTag = [NSString stringWithFormat:@"<%@>",@"TCKimlikNoDogrulaResult"];
//        NSString *closeTag = [NSString stringWithFormat:@"</%@>",@"TCKimlikNoDogrulaResult"];
//        NSMutableArray *components = [NSMutableArray arrayWithArray:[response componentsSeparatedByString:openTag]];
//    
//        [components removeObjectAtIndex:0];
//    
//        for (NSString *component in components)
//        {
//            NSString *object = [[component componentsSeparatedByString:closeTag] objectAtIndex:0]];
//            [valueList addObject:[object ]]
//        
//        if ([valueList count] == 0) {
//            //wierd
//            //NSLog(anEnvelope);
//        }
//        return valueList;
//    }
//}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"asd");

}


@end
