//
//  OldReservationTableViewCell.h
//  Garenta
//
//  Created by Kerem Balaban on 16.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OldReservationTableViewCell : UITableViewCell

@property (weak,nonatomic) IBOutlet UILabel *reservationNo;
@property (weak,nonatomic) IBOutlet UILabel *checkOutOfficeName;
@property (weak,nonatomic) IBOutlet UILabel *checkInOfficeName;
@property (weak,nonatomic) IBOutlet UILabel *checkOutTime;
@property (weak,nonatomic) IBOutlet UILabel *checkInTime;
@property (weak,nonatomic) IBOutlet UILabel *statu;
@end
