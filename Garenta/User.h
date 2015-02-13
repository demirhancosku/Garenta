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
@property (nonatomic, strong) NSString *mobileCountry;
@property (nonatomic,strong) NSString *mobile;
@property (nonatomic,strong) NSString *email;
@property (nonatomic, strong) NSString *nationality;
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
@property (nonatomic,strong) NSString *driverLicenseNo;
@property (nonatomic,strong) NSString *driverLicenseLocation;
@property (nonatomic,strong) NSString *driverLicenseType;
@property (nonatomic,assign) BOOL isLoggedIn;
@property (nonatomic, assign) BOOL isPriority;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *county;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *partnerType;

@property (nonatomic, strong) NSString *priceCode;
@property (nonatomic, strong) NSString *priceType;

@property (nonatomic, strong) NSArray *creditCards;
@property (nonatomic, strong) NSMutableArray *reservationList;
@property (nonatomic, strong) NSArray *userList;

@property (nonatomic,retain) Coordinate *userLocation;

// Ata Cengiz 03.12.2014 Corporate Renting
@property (nonatomic, assign) BOOL isCorporateVehiclePayment;

// Ata cengiz 13.01.2015 Email check
@property (nonatomic, strong) NSString *isUserMailChecked;

+ (NSArray *)loginToSap:(NSString *)username andPassword:(NSString *)password;

@end
