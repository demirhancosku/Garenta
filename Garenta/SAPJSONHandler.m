//
//  SAPJSONHandler.m
//  Garenta_Service
//
//  Created by Ata Cengiz on 01/09/14.
//  Copyright (c) 2014 Ata  Cengiz. All rights reserved.
//

#import "SAPJSONHandler.h"

@interface SAPJSONHandler ()

@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong) NSString *connectionURL;
@property (nonatomic, strong) NSString *importParameters;
@property (nonatomic, strong) NSString *importTableParameters;
@property (nonatomic, strong) NSString *tableForReturn;
@property (nonatomic, strong) NSString *tableForImport;
@property BOOL isAnyImport;

@end

@implementation SAPJSONHandler

- (instancetype)initConnectionURL:(NSString *)hostName andClient:(NSString *)client andDestination:(NSString *)destination andSystemNumber:(NSString *)systemNumber andUserId:(NSString *)userId andPassword:(NSString *)password andRFCName:(NSString *)RFCName {
    
    self = [super init];
    
    if (self) {
        self.request = [[NSMutableURLRequest alloc] init];
        [self.request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
        [self.request setTimeoutInterval:300];
        [self.request setHTTPMethod:@"GET"];
        
        self.connectionURL = [NSString stringWithFormat:@"%@?strJSON={\"sap_props\":{\"hostName\":\"%@\",\"client\":\"%@\",\"destination\":\"%@\",\"systemNumber\":\"%@\",\"userId\":\"%@\",\"password\":\"%@\",\"rfcName\":\"%@\"}", [ConnectionProperties getJSONConnectionURL], hostName, client, destination, systemNumber, userId, password, RFCName];
        
        self.isAnyImport = NO;
    }
    
    return self;
}

- (void)addImportParameter:(NSString *)parameterName andValue:(NSString *)parameterValue {
    
    self.isAnyImport = YES;
    
    if (self.importParameters == nil || [self.importParameters isEqualToString:@""]) {
        self.importParameters = [NSString stringWithFormat:@"\"import\":{\"%@\":\"%@\"", parameterName, parameterValue];
    }
    else {
        self.importParameters = [NSString stringWithFormat:@"%@,\"%@\":\"%@\"", self.importParameters, parameterName, parameterValue];
    }
}

- (void)addImportStructure:(NSString *)structureName andColumns:(NSArray *)columns andValues:(NSArray *)structureValues {
    
    self.isAnyImport = YES;
    
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
    
    self.isAnyImport = YES;
    
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
    
    self.isAnyImport = YES;
    
    if (self.tableForReturn == nil || [self.tableForReturn isEqualToString:@""]) {
        self.tableForReturn = [NSString stringWithFormat:@"{\"tipi\":\"1\",\"%@\":[]}", tableName];
    }
    else {
        self.tableForReturn = [NSString stringWithFormat:@"%@,{\"tipi\":\"1\",\"%@\":[]}", self.tableForReturn, tableName];
    }
}

- (void)addTableForImport:(NSString *)tableName andColumns:(NSArray *)columns andValues:(NSArray *)tableValues {
    
    self.isAnyImport = YES;
    
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
        
        if ([self.tableForImport isEqualToString:[NSString stringWithFormat:@"{\"tipi\":\"0\",\"%@\":[", tableName]]) {
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
        else {
            self.connectionURL = [NSString stringWithFormat:@"%@}", self.connectionURL];
        }
        
        if ((self.tableForImport != nil && ![self.tableForImport isEqualToString:@""]) || (self.tableForReturn != nil && ![self.tableForReturn isEqualToString:@""])) {
            self.connectionURL = [NSString stringWithFormat:@"%@,\"tables\":[", self.connectionURL];
            
            if (self.tableForImport != nil && ![self.tableForImport isEqualToString:@""]) {
                self.connectionURL = [NSString stringWithFormat:@"%@%@", self.connectionURL, self.tableForImport];
            }
            
            if (self.tableForReturn != nil && ![self.tableForReturn isEqualToString:@""]) {
                self.connectionURL = [NSString stringWithFormat:@"%@%@", self.connectionURL, self.tableForReturn];
            }
            
            self.connectionURL = [NSString stringWithFormat:@"%@]", self.connectionURL];
        }
        
        if (self.isAnyImport) {
            self.connectionURL = [NSString stringWithFormat:@"%@}", self.connectionURL];
        }
        
        NSLog(@"%@", self.connectionURL);
        
        [self.request setURL:[NSURL URLWithString:[self.connectionURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
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
                        LoaderAnimationVC *loader = [LoaderAnimationVC uniqueInstance];
                        [loader stopAnimation];
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"İşlem sırasında hata oluştu. Lütfen tekrar deneyiniz" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                        [alert show];
                    }
                }
                else {
                    LoaderAnimationVC *loader = [LoaderAnimationVC uniqueInstance];
                    [loader stopAnimation];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"İşlem sırasında hata oluştu. Lütfen tekrar deneyiniz" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                    [alert show];
                }
            }
            else {
                LoaderAnimationVC *loader = [LoaderAnimationVC uniqueInstance];
                [loader stopAnimation];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Veri alımı sırasında hata oluştu" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                [alert show];
            }
        }
        else {
            LoaderAnimationVC *loader = [LoaderAnimationVC uniqueInstance];
            [loader stopAnimation];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Server'a ulaşılamadı" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
            [alert show];
        }
    }
    else {
        LoaderAnimationVC *loader = [LoaderAnimationVC uniqueInstance];
        [loader stopAnimation];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Lütfen Internet erişiminizi kontrol ediniz" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
        [alert show];
    }
    
    return nil;
}

- (BOOL)checkReachability
{
    return YES;
    //    Reachability *reachability = [Reachability reachabilityWithHostName:@"google.com"];
    //    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    //
    //    BOOL isInternetAvailable;
    //
    //    if(remoteHostStatus == NotReachable)
    //        isInternetAvailable = NO;
    //    else
    //        isInternetAvailable = YES;
    //
    //    return isInternetAvailable;
}

@end
