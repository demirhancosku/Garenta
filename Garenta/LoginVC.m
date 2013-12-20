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
    
//    [loginButton setHidden:NO];
//    [username setHidden:NO];
//    [password setHidden:NO];
	// Do any additional setup after loading the view.
//    [self prepareScreen];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [self prepareScreen];
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
    
    [username setDelegate:self];
    [password setDelegate:self];
    
//    [loginButton setHidden:YES];
//    [username setHidden:YES];
//    [password setHidden:YES];
    
    [self.view addSubview:loginButton];
    [self.view addSubview:username];
    [self.view addSubview:password];
}

- (void)setIpadLayer
{
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    UINavigationController *nav = [[UINavigationController alloc] init];
    
//    destinationTableView = [[UITableView alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.05 ,(nav.navigationBar.frame.size.height + statusBarFrame.size.height) * 0.1,viewFrame.size.width * 0.9,viewFrame.size.height * 0.6) style:UITableViewStyleGrouped];
}

- (void)setIphoneLayer
{
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    UINavigationController *nav = [[UINavigationController alloc] init];
    
    username = [[UITextField alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.05 ,(nav.navigationBar.frame.size.height + statusBarFrame.size.height) * 0.1,viewFrame.size.width * 0.9, 50)];
    
    password = [[UITextField alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.05 ,username.frame.size.height * 1.9 ,viewFrame.size.width * 0.9, 30)];
    
    loginButton = [[UIButton alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.05, (username.frame.size.height + password.frame.size.height) * 1.2, password.frame.size.width, 40)];
    
}

@end
