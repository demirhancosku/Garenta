//
//  Prices.h
//  Garenta Sube
//
//  Created by Alp Keser on 2/21/14.
//  Copyright (c) 2014 Alp Keser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Price : NSObject
@property (nonatomic,retain)NSString *modelId;
@property (nonatomic,retain)NSString *brandId;
@property (nonatomic,retain)NSString *carGroup;
@property (nonatomic,retain)NSString *payNowPrice; //sadece tl alıyoruz simdilik
@property (nonatomic,retain)NSString *payLaterPrice;
@property (nonatomic,retain)NSString *carSelectPrice;
@end
