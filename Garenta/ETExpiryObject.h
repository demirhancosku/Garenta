//
//  ETExpiryObject.h
//  Garenta
//
//  Created by Ata Cengiz on 05/11/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ETExpiryObject : NSObject

@property (nonatomic, strong) NSString *carGroup, *brandID, *modelID, *isPaid, *currency, *campaignID;
@property (nonatomic, strong) NSDate *beginDate, *endDate;
@property (nonatomic, strong) NSDecimalNumber *totalPrice;
@property (nonatomic, strong) NSString *materialNo;
@property (nonatomic, strong) NSString *campaignScopeType;

@end
