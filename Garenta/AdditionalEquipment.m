//
//  AdditionalEquipment.m
//  Garenta
//
//  Created by Alp Keser on 6/3/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "AdditionalEquipment.h"

@implementation AdditionalEquipment
- (id)copyWithZone:(NSZone *)zone{
    id copy = [[[self class] alloc] init];
    if (copy) {
        [copy setMaterialNumber:[self.materialNumber copyWithZone:zone]];
        [copy setDescription:[self.description copyWithZone:zone]];
        [copy setQuantity:self.quantity];
        [copy setPrice:[self.price copyWithZone:zone]];
        [copy setMaxQuantity:[self.maxQuantity copyWithZone:zone]];
        [copy setAdditionalDriverFirstname:@""];
        [copy setAdditionalDriverSurname:@""];
        [copy setAdditionalDriverBirthday:[NSDate date]];
        [(AdditionalEquipment*)copy setType:self.type];
    }
    
    return copy;
}
@end
