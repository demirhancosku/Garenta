//
//  CarGroupTableCellView.m
//  Garenta
//
//  Created by Alp Keser on 12/29/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "CarGroupTableCellView.h"

@implementation CarGroupTableCellView
@synthesize officeName,totalLabel,payNowLabel,currencyLabel,topBoarder;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    [payNowLabel setTextColor:[ApplicationProperties getOrange]];
    [currencyLabel setTextColor:[ApplicationProperties getOrange]];
    
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
