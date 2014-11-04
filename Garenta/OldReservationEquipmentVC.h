//
//  OldReservationEquipmentVC.h
//  Garenta
//
//  Created by Kerem Balaban on 22.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "EquipmentVC.h"

@interface OldReservationEquipmentVC : EquipmentVC

@property (strong,nonatomic) NSDecimalNumber *changeReservationPrice;
@property (strong,nonatomic) NSMutableArray *carSelectionArray;
@property BOOL isCarSelected;
@end
