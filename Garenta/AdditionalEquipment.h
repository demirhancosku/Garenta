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
@interface AdditionalEquipment : NSObject
typedef enum{
    additionalDriver = 0, //ek surucu
    additionalInsurance, //sigorta
    standartEquipment //ek ekipman
}EquipmentType;
@property(strong,nonatomic)NSString*materialNumber;
@property(strong,nonatomic)NSString*description;
@property(assign,nonatomic)int quantity;
@property(strong,nonatomic)NSDecimalNumber *price;
@property(strong,nonatomic)NSDecimalNumber *maxQuantity;
@property(strong,nonatomic)NSString *additionalDriverFirstname;
@property(strong,nonatomic)NSString *additionalDriverSurname;
@property(strong,nonatomic)NSDate *additionalDriverBirthday;
@property(assign)EquipmentType type;
@end
