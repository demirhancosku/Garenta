//
//  SAPJSONHandler.h
//  Garenta_Service
//
//  Created by Ata Cengiz on 01/09/14.
//  Copyright (c) 2014 Ata  Cengiz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAPJSONHandler : NSObject <NSURLConnectionDelegate>

- (instancetype)initConnectionURL:(NSString *)hostName andClient:(NSString *)client andDestination:(NSString *)destination andSystemNumber:(NSString *)systemNumber andUserId:(NSString *)userId andPassword:(NSString *)password andRFCName:(NSString *)RFCName;

- (void)addImportParameter:(NSString *)parameterName andValue:(NSString *)parameterValue;
- (void)addImportStructure:(NSString *)structureName andColumns:(NSArray *)columns andValues:(NSArray *)structureValues;
- (void)addImportTable:(NSString *)tableName andColumns:(NSArray *)columns andValues:(NSArray *)tableValues;
- (void)addTableForReturn:(NSString *)tableName;
- (void)addTableForImport:(NSString *)tableName andColumns:(NSArray *)columns andValues:(NSArray *)tableValues;
- (NSDictionary *)prepCall;

@end
