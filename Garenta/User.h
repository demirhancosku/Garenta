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
@property (nonatomic,retain) NSString *garentaTl;
@property (nonatomic,retain) NSString *mobile;
@property (nonatomic,retain) NSString *email;
@property (nonatomic,retain) NSString *tckno;
@property (nonatomic,retain) NSString *company;
@property (nonatomic,retain) NSString *companyName;
@property (nonatomic,retain) NSString *companyName2;
@property (nonatomic,retain) NSString *middleName;
@property (nonatomic,retain) NSString *kunnr;
@property (nonatomic,retain) NSString *accountType;
@property (nonatomic,retain) NSString *gender;
@property (nonatomic,assign) BOOL isLoggedIn;



@property (nonatomic,retain) Coordinate *userLocation;
@end
