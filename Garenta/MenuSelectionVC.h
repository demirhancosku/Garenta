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
#import "LocationSearchVC.h"
#import "BrandSearchVC.h"
#import "User.h"

@interface MenuSelectionVC : UIViewController
{
    UIButton *locationSearch;
    UIButton *classicSearch;
    UIButton *brandSearch;
    
    UILabel *wellcome;
    User *user;
    CGRect viewFrame;
}

- (id)initWithFrame:(CGRect)frame andUser:(User *)userInfo;
@end
