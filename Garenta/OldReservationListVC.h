//
//  OldReservationListVC.h
//  Garenta
//
//  Created by Kerem Balaban on 16.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OldReservationListVC : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *reservationList;
}
@property (nonatomic,retain) Reservation *reservation;
@end
