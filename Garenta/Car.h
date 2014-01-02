//
//  CarGroup.h
//  Garenta
//
//  Created by Alp Keser on 12/27/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Car : NSObject{
    
}
@property(nonatomic,retain)Office *office;
@property(nonatomic,retain)NSString *materialCode;
@property(nonatomic,retain)NSString *materialName;
@property(nonatomic,retain)NSString *isAvailableForPlate; //plakaya rez
@property(nonatomic,retain)NSString *colorCode;
@property(nonatomic,retain)NSString *colorName;
@property(nonatomic,retain)NSString *winterTire;
@property(nonatomic,retain)NSString *brandId;
@property(nonatomic,retain)NSString *brandName;
@property(nonatomic,retain)NSString *modelId;
@property(nonatomic,retain)NSString *modelName;
@property(nonatomic,retain)NSString *modelYear;
@property(nonatomic,retain)NSString *doorNumber;
@property(nonatomic,retain)NSString *engineVolume;
@property(nonatomic,retain)NSString *passangerNumber;
@property(nonatomic,retain)NSString *ac;
@property(nonatomic,retain)NSString *imagePath;
@property(nonatomic,retain)NSString *payNowPrice;
@property(nonatomic,retain)NSString *payLaterPrice;
@property(nonatomic,retain)NSString *discountedPrice;
@property(nonatomic,retain)NSString *earningPrice;//kazanc
@property(nonatomic,retain)NSString *discountRate;
@property(nonatomic,retain)NSString *currency;
@property(nonatomic,retain)UIImage *image;
@end
