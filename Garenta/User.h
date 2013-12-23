//
//  User.h
//  Garenta
//
//  Created by Kerem Balaban on 21.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Coordinate.h"

@interface User : NSObject

@property (nonatomic,retain) NSString *username;
@property (nonatomic,retain) NSString *password;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *surname;

@property (nonatomic,retain) Coordinate *userLocation;
@end
