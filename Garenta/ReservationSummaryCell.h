//
//  ReservationSummaryCell.h
//  Garenta
//
//  Created by Alp Keser on 1/2/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReservationSummaryCell : UIView
@property(nonatomic,retain)IBOutlet UILabel *checkOutOfficeLabel;
@property(nonatomic,retain)IBOutlet UILabel *checkOutDateLabel;
@property(nonatomic,retain)IBOutlet UILabel *checkOutTimeLabel;
@property(nonatomic,retain)IBOutlet UILabel *checkInOfficeLabel;
@property(nonatomic,retain)IBOutlet UILabel *checkInDateLabel;
@property(nonatomic,retain)IBOutlet UILabel *checkInTimeLabel;
@property(nonatomic,retain)IBOutlet UILabel *totalLabel;

@end
