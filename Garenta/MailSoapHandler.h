//
//  MailSoapHandler.h
//  Garenta
//
//  Created by Ata Cengiz on 31/10/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MailSoapHandler : NSObject

+ (BOOL)sendVerificationMessage:(NSString *)message toMail:(NSString *)mail withFirstname:(NSString *)firstname andLastname:(NSString *)lastname;
+ (BOOL)sendLostPasswordMessage:(NSString *)message toMail:(NSString *)mail;

@end
