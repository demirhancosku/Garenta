//
//  CarSelectionVC.h
//  Garenta
//
//  Created by Alp Keser on 6/16/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reservation.h"
@interface CarSelectionVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property(strong,nonatomic)Reservation*reservation;
@property(strong,nonatomic)NSMutableArray *carSelectionArray;
@end
