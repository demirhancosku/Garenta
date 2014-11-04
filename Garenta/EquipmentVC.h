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
#import "AdditionalEquipmentTableViewCell.h"
#import "SelectCarTableViewCell.h"

@interface EquipmentVC : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong,nonatomic) NSMutableArray *additionalEquipments;
@property (strong,nonatomic) NSMutableArray *additionalEquipmentsFullList;
@property (strong,nonatomic) Reservation *reservation;
@property BOOL isYoungDriver;

- (AdditionalEquipmentTableViewCell*)additionalEquipmentTableViewCellForIndex:(int)index fromTable:(UITableView*)tableView;

- (SelectCarTableViewCell*)selectCarTableView:(UITableView*)tableView;
- (void)recalculate;
- (void)deleteAdditionalDriver;
@end
