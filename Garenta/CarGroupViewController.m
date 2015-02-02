//
//  CarGroupViewController.m
//  Garenta
//
//  Created by Alp Keser on 12/27/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "CarGroupViewController.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import "CampaignVC.h"

@interface CarGroupViewController ()
@property (weak, nonatomic) IBOutlet UILabel *officeLabel;
@property (weak, nonatomic) IBOutlet UILabel *minInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *carGroupLabel;
@property (weak, nonatomic) IBOutlet UILabel *carModelLabel;
@property (weak, nonatomic) IBOutlet UIImageView *carImageView;
@property (weak, nonatomic) IBOutlet UIImageView *leftArrowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightArrowImageView;
//icons
@property (weak, nonatomic) IBOutlet UIImageView *fuelIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *transmissonIconImageView;
@property (strong, nonatomic) IBOutlet UIView *acIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *passangerIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *doorsIconImageView;
//labels
@property (weak, nonatomic) IBOutlet UILabel *fuelLabel;
@property (weak, nonatomic) IBOutlet UILabel *transmissionLabel;
@property (weak, nonatomic) IBOutlet UILabel *acLabel;
@property (weak, nonatomic) IBOutlet UILabel *passangerLabel;
@property (weak, nonatomic) IBOutlet UILabel *doorsLabel;
@property (weak, nonatomic) IBOutlet UIButton *campaignCarGroupButton;

- (IBAction)campaignButtonIsPressed:(id)sender;
- (IBAction)infoButtonPressed:(id)sender;

@end

@implementation CarGroupViewController
@synthesize index,carGroup,myFrame,leftArrow,rightArrow,leftArrowShouldHide,rightArrowShouldHide;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithFrame:(CGRect)aFrame andCarGroups:(CarGroup*)aCarGroup{
    self = [super init];
    leftArrowShouldHide = NO;
    rightArrowShouldHide = NO;
    myFrame = aFrame;
    carGroup = aCarGroup;
    return self;
}
- (id)initWithCarGroups:(CarGroup*)aCarGroup{
    self = [super init];
    
    leftArrowShouldHide = NO;
    rightArrowShouldHide = NO;
    carGroup = aCarGroup;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareUI];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (leftArrowShouldHide) {
        [UIView animateWithDuration:0.6f animations:^(void){
            [_leftArrowImageView setAlpha:0.0f];
        }];
    }
    if (rightArrowShouldHide) {
        [UIView animateWithDuration:0.6f animations:^(void){
            [_rightArrowImageView setAlpha:0.0f];
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (leftArrowShouldHide) {
        [UIView animateWithDuration:0.6f animations:^(void){
            [_leftArrowImageView setAlpha:1.0f];
        }];
    }
    if (rightArrowShouldHide) {
        [UIView animateWithDuration:0.6f animations:^(void){
            [_rightArrowImageView setAlpha:1.0f];
        }];
    }
}

- (void)prepareUI
{
    [_fuelLabel setText:carGroup.fuelName];
    [_transmissionLabel setText:carGroup.transmissonName];
    [_acLabel setText:@"Klima"];
    [_passangerLabel setText:carGroup.sampleCar.passangerNumber];
    [_doorsLabel setText:carGroup.sampleCar.doorNumber];
//    [_minInfoLabel setText:[NSString stringWithFormat:@"Min.Genç sürücü yaşı:%li - Min.Ehliyet:%li \n Teminat Tutarı: 2500 TL",(long)carGroup.minAge,(long)carGroup.minDriverLicense]];
    [_officeLabel setText:[(Office*)[carGroup.carGroupOffices objectAtIndex:0] subOfficeName]];
    [_carGroupLabel setText:carGroup.groupName];
    [_carModelLabel setText:[NSString stringWithFormat:@"%@ ve benzeri",carGroup.sampleCar.modelName]];
    [_carImageView setImage:carGroup.sampleCar.image];
    
    if (carGroup.campaignsArray != nil && carGroup.campaignsArray.count > 0) {
        self.campaignCarGroupButton.hidden = NO;
        
//        UIColor *color = self.campaignCarGroupButton.currentTitleColor;
//        self.campaignCarGroupButton.titleLabel.layer.shadowColor = [color CGColor];
//        self.campaignCarGroupButton.titleLabel.layer.shadowRadius = 4.0f;
//        self.campaignCarGroupButton.titleLabel.layer.shadowOpacity = .9;
//        self.campaignCarGroupButton.titleLabel.layer.shadowOffset = CGSizeZero;
//        self.campaignCarGroupButton.titleLabel.layer.masksToBounds = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)campaignButtonIsPressed:(id)sender {
    NSLog(@"heyooo");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"campaignButtonPressed" object:carGroup];
}

- (IBAction)infoButtonPressed:(id)sender {
    NSLog(@"heyooo");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"infoButtonPressed" object:_infoButton];
}

@end
