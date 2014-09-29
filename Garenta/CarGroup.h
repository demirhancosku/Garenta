//
//  CarGroup.h
//  Garenta
//
//  Created by Alp Keser on 12/28/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Car.h"
#import "ZGARENTA_ARAC_SRVServiceV0.h"
@interface CarGroup : NSObject

@property(nonatomic,retain)NSString *segment;
@property(nonatomic,retain)NSString *segmentName;
@property(nonatomic,retain)NSString *groupCode;
@property(nonatomic,retain)NSString *groupName;
@property(nonatomic,retain)NSString *imagePath;
@property(nonatomic,retain)NSString *payNowPrice;
@property(nonatomic,retain)NSString *payLaterPrice;
@property(nonatomic,retain)NSString *bodyId;
@property(nonatomic,retain)NSString *bodyName;
@property(nonatomic,retain)NSString *fuelId;
@property(nonatomic,retain)NSString *fuelName;
@property(nonatomic,retain)NSString *transmissonId;
@property(nonatomic,retain)NSString *transmissonName;
@property(nonatomic,retain)Car *sampleCar;
@property(nonatomic,retain)NSMutableArray *cars;

#pragma mark - filter methods
+ (CarGroup*)getGroupFromList:(NSMutableArray*)carList WithCode:(NSString*)aGroupCode;
- (NSMutableArray*)getBestCarsWithFilter:(NSString*)aFilter;

#pragma mark - parsing
+ (NSMutableArray*)getCarGroupsFromServiceResponse:(NSDictionary *)serviceResponse withOffices:(NSMutableArray*)offices;
+ (NSString*)urlOfResolution:(NSString*)aResolution fromBaseUrl:(NSString*)baseUrl;

#pragma mark - util methods
- (NSMutableArray*)carGroupOffices;
@end
