//
//  IPFinder.m
//  Garenta
//
//  Created by Alp Keser on 6/30/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "IPFinder.h"

@interface IPFinder()
@property(strong,nonatomic)NSMutableData *webData;
@end
@implementation IPFinder
- (NSString*)myIP{
    NSString *header = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ws=\"http://172.17.1.139:335/WebServices\">"
                        "<soapenv:Header/>"
                        "<soapenv:Body>"
                        "<ws:GetUserIpViaDotNet>"];
    
    NSString *body = [NSString stringWithFormat:@""];
    
    NSString *footer = [NSString stringWithFormat:@"</ws:GetUserIpViaDotNet>"
                        "</soapenv:Body>"
                        "</soapenv:Envelope>"];
    
    
    NSString *soapMsg = @"";
    soapMsg = [NSString stringWithFormat:@"%@%@%@",header, body, footer];
    
    
    NSMutableURLRequest *soapReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://172.17.1.139:335/WebServices/GetUserIP.asmx"]];
    

    __block BOOL waitingForBlock = YES;
    __block NSString *myIp;
    NSURLSession *session = [NSURLSession sharedSession];
    [soapReq addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
 [soapReq addValue:@"http://tempuri.org/GetUserIpViaDotNet" forHTTPHeaderField:@"SOAPAction"];
    soapReq.HTTPMethod = @"POST";
    [soapReq setHTTPBody:[soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:soapReq completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        waitingForBlock = NO;
        // handle response
        myIp = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
        NSLog(@"cevap : %@",myIp);
    }];
    [postDataTask resume];
    while(waitingForBlock) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    return myIp;
}
@end
