//
//  OldReservationListVC.h
//  Garenta
//
//  Created by Kerem Balaban on 16.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OldReservationListVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong,retain) NSMutableArray *reservationList;
@property (strong,retain) Reservation *reservation;
@property (nonatomic,retain) UIRefreshControl *refreshControl NS_AVAILABLE_IOS(6_0);
@end
