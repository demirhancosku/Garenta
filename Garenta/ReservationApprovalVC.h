//
//  ReservationApprovalVC.h
//  Garenta
//
//  Created by Alp Keser on 1/2/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reservation.h"
@interface ReservationApprovalVC : UIViewController
@property(nonatomic,retain)IBOutlet UILabel *headerLabel;
@property(nonatomic,retain)IBOutlet UILabel *reservationNumberLabel;
@property(nonatomic,retain)Reservation * reservation;
- (id)initWithReservation:(Reservation*)aReservation;
@end
