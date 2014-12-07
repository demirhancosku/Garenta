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
        [copy setMaterialDescription:[self.materialDescription copyWithZone:zone]];
        [copy setMaterialInfo:[self.materialInfo copyWithZone:zone]];
        [copy setQuantity:self.quantity];
        [copy setPrice:[self.price copyWithZone:zone]];
        [copy setMaxQuantity:[self.maxQuantity copyWithZone:zone]];
        [copy setAdditionalDriverFirstname:@""];
        [copy setAdditionalDriverMiddlename:@""];
        [copy setAdditionalDriverSurname:@""];
        [copy setAdditionalDriverBirthday:[NSDate date]];
        [copy setAdditionalDriverGender:@""];
        [copy setAdditionalDriverNationality:@""];
        [copy setAdditionalDriverNationalityNumber:@""];
        [copy setAdditionalDriverPassportNumber:@""];
        [copy setAdditionalDriverLicenseClass:@""];
        [copy setAdditionalDriverLicenseNumber:@""];
        [copy setAdditionalDriverLicensePlace:@""];
        [copy setUpdateStatus:@""];
        [copy setAdditionalDriverLicenseDate:[NSDate date]];
        [copy setIsRequired:NO];
        
        [(AdditionalEquipment*)copy setType:self.type];
    }
    
    return copy;
}
@end
