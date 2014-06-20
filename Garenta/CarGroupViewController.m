//
//  CarGroupViewController.m
//  Garenta
//
//  Created by Alp Keser on 12/27/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "CarGroupViewController.h"
#import <CoreText/CoreText.h>
@interface CarGroupViewController ()
@property (weak, nonatomic) IBOutlet UILabel *officeLabel;
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
	// Do any additional setup after loading the view.
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

- (void)prepareUI{
    [_fuelLabel setText:carGroup.fuelName];
    [_transmissionLabel setText:carGroup.transmissonName];
    [_acLabel setText:@"Klima"];
    [_passangerLabel setText:carGroup.sampleCar.passangerNumber];
    [_doorsLabel setText:carGroup.sampleCar.doorNumber];
    [_officeLabel setText:[(Office*)[Office getOfficeFrom:[ApplicationProperties getOffices] withCode:carGroup.sampleCar.officeCode] mainOfficeName]];
    [_carGroupLabel setText:carGroup.groupName];
    [_carModelLabel setText:[NSString stringWithFormat:@"%@ ve benzeri",carGroup.sampleCar.modelName]];
    [_carImageView setImage:carGroup.sampleCar.image];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
