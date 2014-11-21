//
//  CampaignObject.h
//  Garenta
//
//  Created by Ata Cengiz on 20/11/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Price.h"

@interface CampaignObject : NSObject

typedef enum {
    noneDefinedCampaign = 0,
    vehicleGroupCampaign,
    vehicleBrandCampaign,
    vehicleModelCampaign,
} CampaignScopeType;

typedef enum { // ZR1 Şimdi Öde, ZR2 Sonra Öde, ZR3 Ön Ödemeli iptal edilemez
    noneDefinedReservationType = 0,
    payNowReservation ,
    payLaterReservation,
    payFrontWithNoCancellation,
} CampaignReservationType;

@property (nonatomic, strong) NSString *campaignID;
@property (nonatomic, strong) NSString *campaignDescription;
@property (nonatomic, strong) Price *campaignPrice;
@property (nonatomic) CampaignReservationType campaignReservationType;
@property (nonatomic) CampaignScopeType campaignScopeType;

@end
