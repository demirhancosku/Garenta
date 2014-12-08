//
//  ReplacementVehicleObject.h
//  Garenta_Service
//
//  Created by Ata  Cengiz on 11.06.2014.
//  Copyright (c) 2014 Ata  Cengiz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReplacementVehicleObject : NSObject

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *matnr;
@property (nonatomic, strong) NSString *maktx;
@property (nonatomic, strong) NSString *segment;
@property (nonatomic, strong) NSString *segmentText;
@property (nonatomic, strong) NSString *group;
@property (nonatomic, strong) NSString *groupText;
@property (nonatomic, strong) NSString *brandId;
@property (nonatomic, strong) NSString *modelId;
@property (nonatomic, strong) NSString *minAge;
@property (nonatomic, strong) NSString *minLicense;
@property (nonatomic, strong) NSString *difference;
@property (nonatomic, strong) NSString *rentPrice;
@property (nonatomic, strong) NSString *currency;
@property (nonatomic, strong) NSString *depositDifference;
@property (nonatomic, strong) NSString *youngMinAge;
@property (nonatomic, strong) NSString *youngMinLicense;
@property (nonatomic, strong) NSString *youngDriverPrice;
@property (nonatomic, strong) NSString *doubleCreditCard;

@end