//
//  LoaderAnimationVC.m
//  Garenta_Service
//
//  Created by Ata  Cengiz on 12.12.2013.
//  Copyright (c) 2013 Ata  Cengiz. All rights reserved.
//

#import "LoaderAnimationVC.h"

@interface LoaderAnimationVC ()

@end

@implementation LoaderAnimationVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Singleton
+ (LoaderAnimationVC*)uniqueInstance{
    static LoaderAnimationVC *instance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [[LoaderAnimationVC alloc] init];
    });
    return instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[self view] setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7]];
    [[self view] setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.height, [[UIScreen mainScreen] applicationFrame].size.width )];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)playAnimation:(UIView *)iView
{
    [self.view setFrame:CGRectMake(0, 0, iView.frame.size.width, iView.frame.size.height)];
    animationView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height * 0.2, self.view.frame.size.height * 0.2)];
    [animationView setCenter:CGPointMake(iView.frame.size.width/2, iView.frame.size.height/3)];
    [animationView setContentMode:UIViewContentModeScaleAspectFit];
    
    animationView.animationImages = [NSArray arrayWithObjects:
                                     [UIImage imageNamed:@"load_1.png"],
                                     [UIImage imageNamed:@"load_2.png"],
                                     [UIImage imageNamed:@"load_3.png"],
                                     [UIImage imageNamed:@"load_4.png"],
                                     [UIImage imageNamed:@"load_5.png"],
                                     [UIImage imageNamed:@"load_6.png"],
                                     [UIImage imageNamed:@"load_7.png"],
                                     [UIImage imageNamed:@"load_8.png"],
                                     [UIImage imageNamed:@"load_9.png"],
                                     [UIImage imageNamed:@"load_10.png"],
                                     [UIImage imageNamed:@"load_11.png"],
                                     nil];
    
    [[self view] addSubview:animationView];
    // all frames will execute in 1.75 seconds
    animationView.animationDuration = 0.8;
    // repeat the annimation forever
    animationView.animationRepeatCount = 0;
    [animationView startAnimating];
    
    [iView addSubview:self.view];
}

- (void)stopAnimation
{
    [animationView stopAnimating];
    
    [self.view removeFromSuperview];
}

@end
