//
//  ConnectionProperties.m
//  Garenta_Service
//
//  Created by Ata  Cengiz on 20.03.2014.
//  Copyright (c) 2014 Ata  Cengiz. All rights reserved.
//

#import "ConnectionProperties.h"

@implementation ConnectionProperties

static NSString *jsonConnectionURL = @"http://webservicesJSON.celikmotor.com/SapJSONWebserviceRfc/rest/serviceRFCJSON/postServiceRFC";

// R3 Canlı Bilgileri
//NSString *r3HostName = @"10.98.102.19";
//NSString *r3Client = @"500";
//NSString *r3Destination = @"CDP";
//NSString *r3SystemNumber = @"01";
//NSString *r3Username = @"ABHMODUL";
//NSString *r3Password = @"Canli12345";

//// R3 QA Bilgileri
//NSString *r3HostName = @"10.98.102.18";
NSString *r3HostName = @"10.98.102.50";
NSString *r3Client = @"500";
//NSString *r3Destination = @"CDQ";
NSString *r3Destination = @"CQ2";
NSString *r3SystemNumber = @"00";
NSString *r3Username = @"WSUSER";
NSString *r3Password = @"Ws123456";

//// R3 Test Bilgileri
//NSString *r3HostName = @"10.12.3.174";
//NSString *r3Client = @"500";
//NSString *r3Destination = @"CDD";
//NSString *r3SystemNumber = @"00";
//NSString *r3Username = @"AATAC";
//NSString *r3Password = @"1Q2w3e4r5t";


// CRM

// CRM Canlı Bilgileri
//NSString *crmHostName = @"10.98.102.34";
//NSString *crmClient = @"300";
//NSString *crmDestination = @"KCP";
//NSString *crmSystemNumber = @"00";
//NSString *crmUsername = @"WSUSER";
//NSString *crmPassword = @"Ws123456";

//// CRM QA Bilgileri
//NSString *crmHostName = @"10.98.102.33";
NSString *crmHostName = @"10.98.102.51";
NSString *crmClient = @"300";
//NSString *crmDestination = @"KCQ";
NSString *crmDestination = @"KQ2";
NSString *crmSystemNumber = @"00";
NSString *crmUsername = @"WSUSER";
NSString *crmPassword = @"Ws123456";


//// CRM Test Bilgileri
//NSString *crmHostName = @"10.12.3.182";
//NSString *crmClient = @"100";
//NSString *crmDestination = @"KCD";
//NSString *crmSystemNumber = @"00";
//NSString *crmUsername = @"ABATAC";
//NSString *crmPassword = @"1Q2w3e4r5t";

+ (NSString *)getJSONConnectionURL {
    return jsonConnectionURL;
}

+ (NSString *)getR3HostName
{
    return r3HostName;
}

+ (NSString *)getR3Client
{
    return r3Client;
}

+ (NSString *)getR3Destination
{
    return r3Destination;
}

+ (NSString *)getR3SystemNumber
{
    return r3SystemNumber;
}

+ (NSString *)getR3UserId
{
    return r3Username;
}

+ (NSString *)getR3Password
{
    return r3Password;
}

+ (NSString *)getCRMHostName
{
    return crmHostName;
}

+ (NSString *)getCRMClient
{
    return crmClient;
}

+ (NSString *)getCRMDestination
{
    return crmDestination;
}

+ (NSString *)getCRMSystemNumber
{
    return crmSystemNumber;
}

+ (NSString *)getCRMUserId
{
    return crmUsername;
}

+ (NSString *)getCRMPassword
{
    return crmPassword;
}

@end
