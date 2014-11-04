//
//  SAPJSONHandler.m
//  Garenta_Service
//
//  Created by Ata Cengiz on 01/09/14.
//  Copyright (c) 2014 Ata  Cengiz. All rights reserved.
//

#import "SAPJSONHandler.h"
#import "MBProgressHUD.h"
#import "Reachability.h"

@interface SAPJSONHandler ()

@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong) NSString *connectionURL;
@property (nonatomic, strong) NSString *importParameters;
@property (nonatomic, strong) NSString *importTableParameters;
@property (nonatomic, strong) NSString *tableForReturn;
@property (nonatomic, strong) NSString *tableForImport;
@property BOOL isParameterImportExist;
@property BOOL isTableImportExist;

@end

@implementation SAPJSONHandler

- (instancetype)initConnectionURL:(NSString *)hostName andClient:(NSString *)client andDestination:(NSString *)destination andSystemNumber:(NSString *)systemNumber andUserId:(NSString *)userId andPassword:(NSString *)password andRFCName:(NSString *)RFCName {
    
    self = [super init];
    
    if (self) {
        self.request = [[NSMutableURLRequest alloc] init];
        [self.request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
        [self.request setTimeoutInterval:300];
        [self.request setHTTPMethod:@"POST"];
        
        self.connectionURL = [NSString stringWithFormat:@"{\"sap_props\":{\"hostName\":\"%@\",\"client\":\"%@\",\"destination\":\"%@\",\"systemNumber\":\"%@\",\"userId\":\"%@\",\"password\":\"%@\",\"rfcName\":\"%@\"}" ,hostName, client, destination, systemNumber, userId, password, RFCName];
        
        self.isParameterImportExist = NO;
        self.isTableImportExist = NO;
    }
    
    return self;
}

- (void)addImportParameter:(NSString *)parameterName andValue:(NSString *)parameterValue {
    
    self.isParameterImportExist = YES;
    
    if (self.importParameters == nil || [self.importParameters isEqualToString:@""]) {
        self.importParameters = [NSString stringWithFormat:@"\"import\":{\"%@\":\"%@\"", parameterName, parameterValue];
    }
    else {
        self.importParameters = [NSString stringWithFormat:@"%@,\"%@\":\"%@\"", self.importParameters, parameterName, parameterValue];
    }
}

- (void)addImportStructure:(NSString *)structureName andColumns:(NSArray *)columns andValues:(NSArray *)structureValues {
    
    self.isParameterImportExist = YES;
    
    NSString *values = @"";
    
    for (int i = 0; i < [columns count]; i++) {
        if ([values isEqualToString:@""]) {
            values = [NSString stringWithFormat:@"\"%@\":\"%@\"", [columns objectAtIndex:i], [structureValues objectAtIndex:i]];
        }
        else {
            values = [NSString stringWithFormat:@"%@,\"%@\":\"%@\"", values, [columns objectAtIndex:i], [structureValues objectAtIndex:i]];
        }
    }
    
    if (self.importParameters == nil || [self.importParameters isEqualToString:@""]) {
        self.importParameters = [NSString stringWithFormat:@"\"import\":{\"%@\":{%@}", structureName, values];
    }
    else {
        self.importParameters = [NSString stringWithFormat:@"%@,\"%@\":{%@}", self.importParameters, structureName, values];
    }
}

- (void)addImportTable:(NSString *)tableName andColumns:(NSArray *)columns andValues:(NSArray *)tableValues {
    
    self.isParameterImportExist = YES;
    
    if (self.importParameters == nil || [self.importParameters isEqualToString:@""]) {
        self.importParameters = @"\"import\":{";
    }
    
    for (int rowCount = 0; rowCount < [tableValues count]; rowCount++) {
        
        NSArray *arr = [tableValues objectAtIndex:rowCount];
        NSString *values = @"{";
        
        for (int columnCount = 0; columnCount < [columns count]; columnCount++) {
            
            if ([values isEqualToString:@"{"]) {
                values = [NSString stringWithFormat:@"%@\"%@\":\"%@\"", values, [columns objectAtIndex:columnCount], [arr objectAtIndex:columnCount]];
            }
            else {
                values = [NSString stringWithFormat:@"%@,\"%@\":\"%@\"", values, [columns objectAtIndex:columnCount], [arr objectAtIndex:columnCount]];
            }
        }
        
        values = [NSString stringWithFormat:@"%@}", values];
        
        if (self.importTableParameters == nil || [self.importTableParameters isEqualToString:@""]) {
            self.importTableParameters = [NSString stringWithFormat:@"\"%@\":[%@", tableName, values];
        }
        else {
            self.importTableParameters = [NSString stringWithFormat:@"%@,%@", self.importTableParameters, values];
        }
    }
    
    self.importTableParameters = [NSString stringWithFormat:@"%@]", self.importTableParameters];
}

- (void)addTableForReturn:(NSString *)tableName {
    
    self.isTableImportExist = YES;
    
    if (self.tableForReturn == nil || [self.tableForReturn isEqualToString:@""]) {
        self.tableForReturn = [NSString stringWithFormat:@"{\"tipi\":\"1\",\"%@\":[]}", tableName];
    }
    else {
        self.tableForReturn = [NSString stringWithFormat:@"%@,{\"tipi\":\"1\",\"%@\":[]}", self.tableForReturn, tableName];
    }
}

- (void)addTableForImport:(NSString *)tableName andColumns:(NSArray *)columns andValues:(NSArray *)tableValues {
    
    self.isTableImportExist = YES;
    
    if (self.tableForImport == nil || [self.tableForImport isEqualToString:@""]) {
        self.tableForImport = [NSString stringWithFormat:@"{\"tipi\":\"0\",\"%@\":[", tableName];
    }
    else {
        self.tableForImport = [NSString stringWithFormat:@"%@,{\"tipi\":\"0\",\"%@\":[", self.tableForImport, tableName];
    }
    
    for (int rowCount = 0; rowCount < [tableValues count]; rowCount++) {
        
        NSArray *arr = [tableValues objectAtIndex:rowCount];
        NSString *value = @"{";
        
        for (int columnCount = 0; columnCount < [columns count]; columnCount++) {
            if ([value isEqualToString:@"{"]) {
                value = [NSString stringWithFormat:@"%@\"%@\":\"%@\"", value, [columns objectAtIndex:columnCount], [arr objectAtIndex:columnCount]];
            }
            else {
                value = [NSString stringWithFormat:@"%@,\"%@\":\"%@\"", value, [columns objectAtIndex:columnCount], [arr objectAtIndex:columnCount]];
            }
        }
        
        value = [NSString stringWithFormat:@"%@}", value];
        
        if (rowCount == 0) {
            self.tableForImport = [NSString stringWithFormat:@"%@%@", self.tableForImport, value];
        }
        else {
            self.tableForImport = [NSString stringWithFormat:@"%@,%@", self.tableForImport, value];
        }
    }
    
    self.tableForImport = [NSString stringWithFormat:@"%@]}", self.tableForImport];
}

- (NSDictionary *)prepCall {
    
    BOOL isInternetAvailable = [self checkReachability];
    
    NSString *alertString = @"";
    
    if (isInternetAvailable) {
        if (self.importParameters != nil && ![self.importParameters isEqualToString:@""]) {
            self.connectionURL = [NSString stringWithFormat:@"%@,%@", self.connectionURL, self.importParameters];
        }
        
        if (self.importTableParameters != nil && ![self.importTableParameters isEqualToString:@""]) {
            self.connectionURL = [NSString stringWithFormat:@"%@,%@", self.connectionURL, self.importTableParameters];
        }
        
        if (self.importTableParameters != nil && ![self.importTableParameters isEqualToString:@""]) {
            self.connectionURL = [NSString stringWithFormat:@"%@}", self.connectionURL];
        }
        else if (self.isParameterImportExist) {
            self.connectionURL = [NSString stringWithFormat:@"%@}", self.connectionURL];
        }
        
        if ((self.tableForImport != nil && ![self.tableForImport isEqualToString:@""]) || (self.tableForReturn != nil && ![self.tableForReturn isEqualToString:@""])) {
            self.connectionURL = [NSString stringWithFormat:@"%@,\"tables\":[", self.connectionURL];
            
            if (self.tableForImport != nil && ![self.tableForImport isEqualToString:@""]) {
                self.connectionURL = [NSString stringWithFormat:@"%@%@", self.connectionURL, self.tableForImport];
            }
            
            if (self.tableForReturn != nil && ![self.tableForReturn isEqualToString:@""] && (self.tableForImport != nil && ![self.tableForImport isEqualToString:@""])) {
                self.connectionURL = [NSString stringWithFormat:@"%@,%@", self.connectionURL, self.tableForReturn];
            }
            else if (self.tableForReturn != nil && ![self.tableForReturn isEqualToString:@""]) {
                self.connectionURL = [NSString stringWithFormat:@"%@%@", self.connectionURL, self.tableForReturn];
            }
            
            self.connectionURL = [NSString stringWithFormat:@"%@]", self.connectionURL];
        }
        
        self.connectionURL = [NSString stringWithFormat:@"%@}", self.connectionURL];
        
        NSLog(@"%@", self.connectionURL);
        
        self.connectionURL = [self.connectionURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *body = [NSString stringWithFormat:@"strJSON=%@", self.connectionURL];
        
        NSData *requestData = [body dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];

        [self.request setURL:[NSURL URLWithString:[ConnectionProperties getJSONConnectionURL]]];
        [self.request setHTTPBody:requestData];
        
        NSError *error;
        NSURLResponse *response;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:self.request returningResponse:&response error:&error];
        
        if (error == nil && data != nil && [data length] > 0) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            if (error == nil && dict != nil) {
                
                NSDictionary *resultDict = [dict objectForKey:@"RETURN"];
                
                if (resultDict != nil) {
                    NSLog(@"%@", resultDict);
                    
                    NSDictionary *expentionDict = [dict objectForKey:@"ABAP_EXCEPTION"];
                    
                    if (expentionDict == nil && [expentionDict count] < 1) {
                        return resultDict;
                    }
                    else {
                        alertString = @"İşlem sırasında hata oluştu. Lütfen tekrar deneyiniz";
                    }
                }
                else {
                   alertString = @"İşlem sırasında hata oluştu. Lütfen tekrar deneyiniz";
                }
            }
            else {
                alertString = @"Veri alımı sırasında hata oluştu";
            }
        }
        else {
            alertString = @"Server'a ulaşılamadı";
        }
    }
    else {
        alertString = @"Lütfen Internet erişiminizi kontrol ediniz";
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![alertString isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
            [alert show];
        }
    });
    
    return nil;
}

- (BOOL)checkReachability
{
    Reachability *reachability = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    BOOL isInternetAvailable;
    
    if(remoteHostStatus == NotReachable)
        isInternetAvailable = NO;
    else
        isInternetAvailable = YES;
    
    return isInternetAvailable;
}

@end
