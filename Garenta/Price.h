//
//  Prices.h
//  Garenta Sube
//
//  Created by Alp Keser on 2/21/14.
//  Copyright (c) 2014 Alp Keser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Price : NSObject
@property (nonatomic, retain) NSString *modelId;
@property (nonatomic, retain) NSString *brandId;
@property (nonatomic, retain) NSString *carGroup;
@property (nonatomic, retain) NSDecimalNumber *payNowPrice; //sadece tl alıyoruz simdilik
@property (nonatomic, retain) NSDecimalNumber *payLaterPrice;
@property (nonatomic, retain) NSDecimalNumber *carSelectPrice;
@property (nonatomic, retain) NSDecimalNumber *documentCarPrice;
@property (nonatomic, strong) NSDecimalNumber *dayCount;
@property (nonatomic, strong) NSString *salesOffice; // et_fiyat cikis_sube
@property (nonatomic, strong) NSDecimalNumber *priceWithKDV;
@property (nonatomic, strong) NSDecimalNumber *campaignDiscountPrice;

// 04.02.2015 Ata
@property (nonatomic) BOOL canGarentaPointEarn;
@property (nonatomic) BOOL canMilesPointEarn;
// 04.02.2015 Ata
@end
