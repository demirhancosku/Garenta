//
//  ConnectionProperties.h
//  Garenta_Service
//
//  Created by Ata  Cengiz on 20.03.2014.
//  Copyright (c) 2014 Ata  Cengiz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionProperties : NSObject

+ (NSString *)getJSONConnectionURL;

+ (NSString *)getCRMHostName;
+ (NSString *)getCRMClient;
+ (NSString *)getCRMDestination;
+ (NSString *)getCRMSystemNumber;
+ (NSString *)getCRMUserId;
+ (NSString *)getCRMPassword;

+ (NSString *)getR3HostName;
+ (NSString *)getR3Client;
+ (NSString *)getR3Destination;
+ (NSString *)getR3SystemNumber;
+ (NSString *)getR3UserId;
+ (NSString *)getR3Password;

@end

