//
//  OldReservationSummaryVC.h
//  Garenta
//
//  Created by Kerem Balaban on 27.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "ReservationSummaryVC.h"

@interface OldReservationSummaryVC : ReservationSummaryVC

@property (strong,nonatomic) NSDecimalNumber *changeReservationPrice;
@property (strong,nonatomic) NSDecimalNumber *carSelectionPriceDifference;
@property (strong,nonatomic) CreditCard *creditCard;
@property (strong,nonatomic) NSString *totalPrice;
@property (strong,nonatomic) NSDecimalNumber *payNowDifference;
@property (strong,nonatomic) NSDecimalNumber *payLaterDifference;

@end
