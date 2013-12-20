//
//  LoginVC.h
//  Garenta
//
//  Created by Kerem Balaban on 20.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginVC : UIViewController <UITextFieldDelegate>
{
    CGRect viewFrame;
    UITextField *username;
    UITextField *password;
    UIButton *loginButton;
}

- (id)initWithFrame:(CGRect)frame;

@end
