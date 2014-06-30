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

@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) NSString *password;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *surname;
@property (nonatomic,strong) NSDecimalNumber *garentaTl;
@property (nonatomic,strong) NSString *mobile;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSString *tckno;
@property (nonatomic,strong) NSString *company;
@property (nonatomic,strong) NSString *companyName;
@property (nonatomic,strong) NSString *companyName2;
@property (nonatomic,strong) NSString *middleName;
@property (nonatomic,strong) NSString *kunnr;
@property (nonatomic,strong) NSString *accountType;
@property (nonatomic,strong) NSString *gender;
@property (nonatomic,strong) NSDate *birthday;
@property (nonatomic,strong) NSDate *driversLicenseDate;
@property (nonatomic,assign) BOOL isLoggedIn;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *partnerType;



@property (nonatomic,retain) Coordinate *userLocation;
@end
