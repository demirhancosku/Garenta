//
//  SelectCarTableViewCell.m
//  Garenta
//
//  Created by Alp Keser on 6/5/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "SelectCarTableViewCell.h"

@implementation SelectCarTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
