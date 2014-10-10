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
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegment;
@property (weak, nonatomic) IBOutlet UITextField  *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField  *surnameTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *birthdayPicker;

@property (weak, nonatomic) IBOutlet UISegmentedControl *classSegment;
@property (weak, nonatomic) IBOutlet UITextField  *licenseNoTextField;
@property (weak, nonatomic) IBOutlet UITextField  *licensePlaceTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *licenseDatePicker;

- (IBAction)addButtonPressed:(id)sender;
- (IBAction)genderSegmentChanged:(id)sender;
- (IBAction)classSegmentChanged:(id)sender;


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
    
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDate * currentDate = [NSDate date];
    NSDateComponents * comps = [[NSDateComponents alloc] init];
    [comps setYear: - 18];
    NSDate * maxDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
    [comps setYear: - 100];
    NSDate * minDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
    // Do any additional setup after loading the view.
    
    [self.birthdayPicker setMaximumDate:maxDate];
    [self.birthdayPicker setMinimumDate:minDate];
    [self.birthdayPicker setDate:maxDate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self releaseAllTextFields];
}

- (void)releaseAllTextFields
{
    [self.nameTextField resignFirstResponder];
    [self.surnameTextField resignFirstResponder];
    [self.licenseNoTextField resignFirstResponder];
    [self.licensePlaceTextField resignFirstResponder];
}

- (BOOL)checkFields{
    if ([self.nameTextField.text isEqualToString:@""] || [self.surnameTextField.text isEqualToString:@""] || [self.licenseNoTextField.text isEqualToString:@""] || [self.licensePlaceTextField.text isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (IBAction)addButtonPressed:(id)sender
{
    if ([self checkFields])
    {
        if(!self.reservation.additionalDrivers){
            self.reservation.additionalDrivers = [NSMutableArray new];
        }
        
        // ek sürücü genel bilgiler
        if ([self.genderSegment selectedSegmentIndex] == 0)
            [[self myDriver] setAdditionalDriverGender:@"1"];   //Bay
        else
            [[self myDriver] setAdditionalDriverGender:@"2"];   //Bayan
        
        [[self myDriver] setAdditionalDriverFirstname:self.nameTextField.text.uppercaseString];
        [[self myDriver] setAdditionalDriverSurname:self.surnameTextField.text.uppercaseString];
        [[self myDriver] setAdditionalDriverBirthday:self.birthdayPicker.date];
        
        // ek sürücü ehliyet bilgileri
        [[self myDriver] setAdditionalDriverLicenseClass:[self.classSegment titleForSegmentAtIndex:self.classSegment.selectedSegmentIndex]];
        [[self myDriver] setAdditionalDriverLicenseNumber:self.licenseNoTextField.text];
        [[self myDriver] setAdditionalDriverLicensePlace:self.licensePlaceTextField.text.uppercaseString];
        [[self myDriver] setAdditionalDriverLicenseDate:self.licenseDatePicker.date];
        
        [self.reservation.additionalDrivers addObject:self.myDriver];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"additionalDriverAdded" object:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyari" message:@"Lütfen bütün alanları doldurunuz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)genderSegmentChanged:(id)sender
{
    
}

- (IBAction)classSegmentChanged:(id)sender
{
    
}
@end
