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

@interface LoginVC : BaseVC <UITextFieldDelegate>
{
    UIButton *hideButton;
    CGRect viewFrame;
    UITextField *username;
    UITextField *password;
    UIImageView *userImageView;
    UIButton *loginButton;
    UIButton *signUpButton;
    UILabel *infoLabel;
    User *user; //temp user if succ. assign to singleton
    
}

- (id)initWithFrame:(CGRect)frame andUser:(User *)userInfo;

@end
