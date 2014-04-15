//
//  IDController.h
//  Garenta
//
//  Created by Ata  Cengiz on 7.03.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDController : NSObject
{
    NSMutableData *webData;
}
- (BOOL)idChecker:(NSString *)iID andName:(NSString *)iName andSurname:(NSString *)iSurname andBirthYear:(NSString *)iYear;

@end
