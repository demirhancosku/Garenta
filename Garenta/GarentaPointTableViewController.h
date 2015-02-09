//
//  GarentaPointTableViewController.h
//  Garenta
//
//  Created by Ata Cengiz on 02/02/15.
//  Copyright (c) 2015 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GarentaPointTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) Reservation *reservation;
@end
