//
//  LoginVC.h
//  Garenta
//
//  Created by Kerem Balaban on 20.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplicationProperties.h"
#import "User.h"
#import "MenuSelectionVC.h"
#import "UserCreationVC.h"

@interface LoginVC : BaseVC <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIButton *hideButton;
    CGRect viewFrame;
    UIImageView *userImageView;
    UIButton *loginButton;
    UILabel *infoLabel;
    User *user; //temp user if succ. assign to singleton
    UIButton *createUserButton;
}

- (id)initWithFrame:(CGRect)frame andUser:(User *)userInfo;
- (void)goToCreateUserView:(id)sender;

@end
