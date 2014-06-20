//
//  CarGroupTableViewCell.h
//  Garenta
//
//  Created by Alp Keser on 5/21/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarGroupTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *officeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *payLaterPriceLabel;

@end
