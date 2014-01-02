//
//  ReservationSummaryCell.m
//  Garenta
//
//  Created by Alp Keser on 1/2/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "ReservationSummaryCell.h"

@implementation ReservationSummaryCell
@synthesize checkInDateLabel,checkInOfficeLabel,checkInTimeLabel,checkOutDateLabel,checkOutOfficeLabel,checkOutTimeLabel;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
