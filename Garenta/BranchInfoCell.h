//
//  BranchInfoCell.h
//  Garenta
//
//  Created by Onur Küçük on 30.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BranchInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *branchNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *branchAddressLabel;
@property (weak, nonatomic) IBOutlet UIButton *branchTelLabel;

@end
