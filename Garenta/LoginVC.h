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
#import "WYPopoverController.h"

@interface LoginVC : BaseVC <UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate,WYPopoverControllerDelegate>
{
    UIButton *hideButton;
    CGRect viewFrame;
    UIImageView *userImageView;
    UIButton *loginButton;
    UILabel *infoLabel;
    UIButton *createUserButton;
    NSMutableArray *countryArray;
    NSMutableArray *secretQuestionsArray;
}

@property (nonatomic, strong) Reservation *reservation;
@property (nonatomic) BOOL shouldNotPop;
@property (nonatomic, strong) UIBarButtonItem *leftButton;

@end
