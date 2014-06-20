//
//  SelectCarTableViewCell.h
//  Garenta
//
//  Created by Alp Keser on 6/5/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectCarTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *mainText;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *carLabel;

@end
