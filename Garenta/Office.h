//
//  Office.h
//  Garenta
//
//  Created by Ata  Cengiz on 19.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OfficeWorkingTime.h"

@interface Office : NSObject

@property (nonatomic, retain) NSString *mainOfficeName;
@property (nonatomic, retain) NSString *mainOfficeCode;
@property (nonatomic, retain) NSString *subOfficeName;
@property (nonatomic, retain) NSString *subOfficeCode;
@property (nonatomic, retain) NSString *subOfficeType;
@property (nonatomic, retain) NSString *subOfficeTypeCode;
@property (nonatomic, retain) NSString *cityCode;
@property (nonatomic, retain) NSString *cityName;
@property (nonatomic, retain) NSString *fax;
@property (nonatomic, retain) NSString *tel;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *latitude;
@property (nonatomic, retain) NSString *longitude;

@property (nonatomic, retain) NSMutableArray *workingHours;
@property (nonatomic, retain) NSMutableArray *holidayDates;

+ (Office*)getOfficeFrom:(NSMutableArray*)offices withCode:(NSString*)officeCode;
+ (Office*)getClosestOfficeFromList:(NSMutableArray*)officeList withCoordinate:(Coordinate*) lastLocation;
@end
