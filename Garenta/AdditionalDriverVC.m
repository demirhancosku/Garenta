//
//  AdditionalDriverVC.m
//  Garenta
//
//  Created by Alp Keser on 7/14/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "AdditionalDriverVC.h"
#import "AdditionalEquipment.h"
@interface AdditionalDriverVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *surnameTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *birthdayPicker;
- (IBAction)addButtonPressed:(id)sender;


@end

@implementation AdditionalDriverVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)checkFields{
    if ([self.nameTextField.text isEqualToString:@""] || [self.surnameTextField.text isEqualToString:@""]) {
        return NO;
    }
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)addButtonPressed:(id)sender {
    if ([self checkFields]) {
        if(!self.reservation.additionalDrivers){
            self.reservation.additionalDrivers = [NSMutableArray new];
        }
        [[self myDriver] setAdditionalDriverFirstname:self.nameTextField.text];
        [[self myDriver] setAdditionalDriverSurname:self.surnameTextField.text];
        [[self myDriver] setAdditionalDriverBirthday:self.birthdayPicker.date];
        [self.reservation.additionalDrivers addObject:self.myDriver];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"additionalDriverAdded" object:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyari" message:@"Lutfen butun alanlari doldurunuz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
        [alert show];
    }
}
@end
