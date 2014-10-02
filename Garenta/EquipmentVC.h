//
//  EquipmentVC.h
//  Garenta
//
//  Created by Kerem Balaban on 23.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reservation.h"
#import "AdditionalEquipmentInfoVC.h"

@interface EquipmentVC : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong,nonatomic) Reservation *reservation;


@end
