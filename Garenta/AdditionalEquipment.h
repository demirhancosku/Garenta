//
//  AdditionalEquipment.h
//  Garenta
//
//  Created by Alp Keser on 6/3/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <Foundation/Foundation.h>

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
@property(strong,nonatomic) NSDecimalNumber *monthlyPrice;
@property(strong,nonatomic) NSDecimalNumber *paid;
@property(strong,nonatomic) NSDecimalNumber *difference;
@property(strong,nonatomic) NSDecimalNumber *maxQuantity;
@property(strong,nonatomic) NSString *updateStatus;
@property BOOL isRequired;

@property(strong,nonatomic) NSString *additionalDriverGender;
@property(strong,nonatomic) NSString *additionalDriverFirstname;
@property(strong,nonatomic) NSString *additionalDriverMiddlename;
@property(strong,nonatomic) NSString *additionalDriverSurname;
@property(strong,nonatomic) NSDate   *additionalDriverBirthday;
@property(strong,nonatomic) NSString *additionalDriverNationality;
@property(strong,nonatomic) NSString *additionalDriverPassportNumber;
@property(strong,nonatomic) NSString *additionalDriverNationalityNumber;

@property(strong,nonatomic) NSString *additionalDriverLicenseClass;
@property(strong,nonatomic) NSString *additionalDriverLicenseNumber;
@property(strong,nonatomic) NSString *additionalDriverLicensePlace;
@property(strong,nonatomic) NSDate   *additionalDriverLicenseDate;
@property BOOL isAdditionalYoungDriver;
@property(assign) EquipmentType type;

// Ata Cengiz 04.12.2014 Corparate
@property (strong, nonatomic) NSString *paymentType; // F for firma, P for personel

@end
