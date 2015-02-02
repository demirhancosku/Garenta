//
//  SMSSoapHandler.h
//  Garenta
//
//  Created by Ata Cengiz on 22/10/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMSSoapHandler : NSObject

+ (NSString *)generateCode;
+ (BOOL)sendSMSMessage:(NSString *)message toNumber:(NSString *)phoneNumber;
+ (BOOL)sendWebPassword:(NSString *)message toNumber:(NSString *)phoneNumber;

@end
