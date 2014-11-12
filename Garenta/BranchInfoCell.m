//
//  BranchInfoCell.m
//  Garenta
//
//  Created by Onur Küçük on 30.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "BranchInfoCell.h"

@implementation BranchInfoCell

- (void)awakeFromNib {
    // Initialization code
    _branchTelLabel.layer.cornerRadius = 5;
    _branchTelLabel.layer.borderColor = (__bridge CGColorRef)([UIColor colorWithRed:255 green:6 blue:18 alpha:1]);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
