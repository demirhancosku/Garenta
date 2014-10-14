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

- (BOOL)checkFields
{
    if ([self.nameTextField.text isEqualToString:@""] || [self.surnameTextField.text isEqualToString:@""] || [self.licenseNoTextField.text isEqualToString:@""] || [self.licensePlaceTextField.text isEqualToString:@""] || self.licenseDatePicker.date == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyari" message:@"Lütfen bütün alanları doldurunuz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
    // min.genç sürücü yaşı ve min.ehliyet yılı kontrollerine göre ek sürücünün eklenip eklenemeyeceğine bakılır
    if ([ApplicationProperties isCarGroupAvailableByAge:_reservation.selectedCarGroup andBirthday:_birthdayPicker.date])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:[NSString stringWithFormat:@"Seçilen araç grubuna rezervasyon yapılamaz. (Min.Genç Sürücü yaşı: %i - Min.Genç Sürücü Ehliyet Yılı: %i)",_reservation.selectedCarGroup.minYoungDriverAge,_reservation.selectedCarGroup.minYoungDriverLicense] delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
        
        [alert show];
        return NO;
    }
    
    //min.Yaş ve min.Ehliyet yılı kontrollerine bakarak hizmet bedeli alınıp alınmayacağına bakar.
    if ([ApplicationProperties checkYoungDriverAddition:_reservation.selectedCarGroup andBirthday:_birthdayPicker.date andLicenseDate:_licenseDatePicker.date])
    {
        
        [[self myDriver] setIsAdditionalYoungDriver:YES];
        return YES;
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

    }
}

- (IBAction)genderSegmentChanged:(id)sender
{
    
}

- (IBAction)classSegmentChanged:(id)sender
{
    
}
@end
