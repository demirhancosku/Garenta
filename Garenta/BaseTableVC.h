//
//  BaseTableVC.h
//  Garenta
//
//  Created by Kerem Balaban on 27.11.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplicationProperties.h"

@interface BaseTableVC : UITableViewController

- (UITableViewCell *)getMenuCell:(UITableViewCellStyle)style;
- (UITableViewCell *)refreshCell:(UITableViewCell *)cell;

- (id)initWithStyle:(UITableViewStyle)style;
@end
