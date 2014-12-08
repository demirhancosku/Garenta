//
//  UpsellDownsellCarSelectionVC.h
//  Garenta
//
//  Created by Kerem Balaban on 5.12.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpsellDownsellCarSelectionVC : UIViewController <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property(strong,nonatomic)Reservation*reservation;
@property(strong,nonatomic)NSMutableArray *cars;
@property(strong,nonatomic)NSMutableArray *carSelectionArray;
@property(strong,nonatomic)NSMutableArray *additionalEquipments;
@property (strong,nonatomic) NSString *totalPrice;

@end
