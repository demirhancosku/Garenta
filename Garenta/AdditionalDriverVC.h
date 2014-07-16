//
//  AdditionalDriverVC.h
//  Garenta
//
//  Created by Alp Keser on 7/14/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "BaseTableVC.h"
#import "Reservation.h"
#import "AdditionalEquipment.h"
@interface AdditionalDriverVC : UITableViewController
@property(strong,nonatomic)Reservation *reservation;
@property(copy,nonatomic)AdditionalEquipment *myDriver;
@end
