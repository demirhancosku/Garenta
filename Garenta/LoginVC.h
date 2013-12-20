//
//  LoginVC.h
//  Garenta
//
//  Created by Kerem Balaban on 20.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplicationProperties.h"

@interface LoginVC : UIViewController <UITextFieldDelegate>
{
    CGRect viewFrame;
    UITextField *username;
    UITextField *password;
    UIImageView *userImageView;
    UIButton *loginButton;
    UIButton *signUpButton;
}

- (id)initWithFrame:(CGRect)frame;

@end
