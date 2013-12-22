//
//  LoginVC.m
//  Garenta
//
//  Created by Kerem Balaban on 20.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "LoginVC.h"

@interface LoginVC ()

@end

@implementation LoginVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame;
{
    self = [super init];
    
    viewFrame = frame;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [self prepareScreen];
    
    [[self view] setBackgroundColor:[ApplicationProperties getWhite]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareScreen
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self setIpadLayer];
    }
    else
    {
        [self setIphoneLayer];
    }
    
    [loginButton setTitle:@"Giriş" forState:UIControlStateNormal];
    [[loginButton layer] setCornerRadius:5.0f];
    [loginButton setBackgroundColor:[ApplicationProperties getOrange]];
    [loginButton setTintColor:[ApplicationProperties getWhite]];
    
    [signUpButton setTitle:@"Üye Ol" forState:UIControlStateNormal];
    [[signUpButton layer] setCornerRadius:5.0f];
    [signUpButton setBackgroundColor:[ApplicationProperties getOrange]];
    [signUpButton setTintColor:[ApplicationProperties getWhite]];
    
    [username setDelegate:self];
    [password setDelegate:self];
    
    [username setBorderStyle:UITextBorderStyleRoundedRect];
    [[username layer] setBorderWidth:1.0f];
    [[username layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[username layer] setCornerRadius:5.0f];
    [username setPlaceholder:@"Kullanıcı Adınızı Giriniz"];
    [username setTextAlignment:NSTextAlignmentCenter];
    
    [password setBorderStyle:UITextBorderStyleRoundedRect];
    [[password layer] setBorderWidth:1.0f];
    [[password layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[password layer] setCornerRadius:5.0f];
    [password setPlaceholder:@"Şifrenizi Giriniz"];
    [password setTextAlignment:NSTextAlignmentCenter];
    
    [self.view addSubview:userImageView];
    [self.view addSubview:loginButton];
    [self.view addSubview:username];
    [self.view addSubview:password];
    [self.view addSubview:signUpButton];
}

- (void)setIpadLayer
{
    username = [[UITextField alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.1, viewFrame.size.height * 0.35, viewFrame.size.width * 0.8, 40)];
    
    password = [[UITextField alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.1, viewFrame.size.height * 0.40, viewFrame.size.width * 0.8, 40)];
    
    loginButton = [[UIButton alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.1, viewFrame.size.height * 0.55, viewFrame.size.width * 0.8, 40)];
    
    signUpButton = [[UIButton alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.1, viewFrame.size.height * 0.60, viewFrame.size.width * 0.8, 40)];
    
    userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.35, viewFrame.size.height * -0.02, viewFrame.size.width * 0.3, viewFrame.size.height * 0.3)];
    [userImageView setContentMode:UIViewContentModeScaleAspectFill];
    [userImageView setImage:[UIImage imageNamed:@"UserLoginPic.png"]];
}

- (void)setIphoneLayer
{
    username = [[UITextField alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.1, viewFrame.size.height * 0.33, viewFrame.size.width * 0.8, 40)];
    
    password = [[UITextField alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.1, viewFrame.size.height * 0.43, viewFrame.size.width * 0.8, 40)];
    
    loginButton = [[UIButton alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.1, viewFrame.size.height * 0.60, viewFrame.size.width * 0.8, 40)];
    
    signUpButton = [[UIButton alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.1, viewFrame.size.height * 0.70, viewFrame.size.width * 0.8, 40)];
    
    userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.4, viewFrame.size.height * 0.05, viewFrame.size.width * 0.22, viewFrame.size.height * 0.22)];
    [userImageView setContentMode:UIViewContentModeScaleAspectFill];
    [userImageView setImage:[UIImage imageNamed:@"UserLoginPic.png"]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self releaseAllTextFields];
    return YES;
}

- (void)releaseAllTextFields
{
    [username resignFirstResponder];
    [password resignFirstResponder];
}

@end
