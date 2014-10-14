//
//  SDReservObject.m
//  Garenta
//
//  Created by Ata Cengiz on 14/10/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "SDReservObject.h"

@implementation SDReservObject

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        self.office = @"";
        self.groupCode = @"";
        self.priceCode = @"";
        self.date = @"";
        self.rVbeln = @"";
        self.RGjahr = @"";
        self.rAuart = @"";
        self.matnr = @"";
        self.equnr = @"";
        self.kunnr = @"";
        self.destinationOffice = @"";
        self.augru = @"";
        self.vkorg = @"";
        self.vtweg = @"";
        self.spart = @"";
        self.price = @"";
        self.isGarentaTl = @"";
        self.isMiles = @"";
        self.isBonus = @"";
    }
    
    return self;
}

@end
