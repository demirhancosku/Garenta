//
//  MenuSelectionVC.h
//  Garenta
//
//  Created by Kerem Balaban on 20.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginVC.h"
#import "ClassicSearchVC.h"
#import "User.h"
#import "CarGroupFilterVC.h"
#import "ApplicationProperties.h"
@interface MenuSelectionVC : UITableViewController<UITableViewDataSource,UITableViewDelegate>
{
    UILabel *welcomeLabel;
        LoaderAnimationVC * loaderVC;
    NSString*newAppLink;
}
@property(nonatomic,retain)LoaderAnimationVC *loaderVC;
- (id)initWithFrame:(CGRect)frame;
@end
