//
//  AdditionalEquipment.h
//  Garenta
//
//  Created by Alp Keser on 6/3/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 Normalde vaktim olmadığı için böyle yoksa ortak alanlar super detaylar subclass tek arrayde toparlanır rez. objesinde tutulur
 ayırırken xxx class methodu çağırılarak ilgili tabloya eklenir.
 Hadi öptüm gözlerinizden
 */
@interface AdditionalEquipment : NSObject<NSCopying>

typedef enum{
    additionalDriver = 0, //ek surucu
    additionalInsurance, //sigorta
    standartEquipment //ek ekipman
}EquipmentType;

@property(strong,nonatomic) NSString *materialNumber;
@property(strong,nonatomic) NSString *materialDescription;
@property(strong,nonatomic) NSString *materialInfo;
@property(assign,nonatomic) int quantity;
@property(strong,nonatomic) NSDecimalNumber *price;
@property(strong,nonatomic) NSDecimalNumber *paid;
@property(strong,nonatomic) NSDecimalNumber *difference;
@property(strong,nonatomic) NSDecimalNumber *maxQuantity;
@property BOOL isRequired;

@property(strong,nonatomic) NSString *additionalDriverGender;
@property(strong,nonatomic) NSString *additionalDriverFirstname;
@property(strong,nonatomic) NSString *additionalDriverSurname;
@property(strong,nonatomic) NSDate   *additionalDriverBirthday;

@property(strong,nonatomic) NSString *additionalDriverLicenseClass;
@property(strong,nonatomic) NSString *additionalDriverLicenseNumber;
@property(strong,nonatomic) NSString *additionalDriverLicensePlace;
@property(strong,nonatomic) NSDate   *additionalDriverLicenseDate;
@property BOOL isAdditionalYoungDriver;
@property(assign) EquipmentType type;
@end
