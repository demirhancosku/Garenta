//
//  AdditionalDriverVC.m
//  Garenta
//
//  Created by Alp Keser on 7/14/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "AdditionalDriverVC.h"
#import "AdditionalEquipment.h"
#import "IDController.h"

@interface AdditionalDriverVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *nationalitySegmented;
@property (weak, nonatomic) IBOutlet UITextField  *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField  *middleNameTextField;
@property (weak, nonatomic) IBOutlet UITextField  *surnameTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *birthdayPicker;
@property (weak, nonatomic) IBOutlet UITextField  *nationalityTextField;

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
    [self.middleNameTextField resignFirstResponder];
    [self.surnameTextField resignFirstResponder];
    [self.licenseNoTextField resignFirstResponder];
    [self.licensePlaceTextField resignFirstResponder];
    [self.nationalityTextField resignFirstResponder];
}

- (BOOL)checkFields
{
    NSString *alertString = @"";
    IDController *control = [[IDController alloc] init];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents =[gregorian components:NSYearCalendarUnit fromDate:[self.birthdayPicker date]];
    NSString *birtdayYearString = [NSString stringWithFormat:@"%li", (long)weekdayComponents.year];
    
    if ([self.genderSegment selectedSegmentIndex] == -1 )
        alertString = @"Bay/Bayan alanının seçilmesi gerekmektedir.";
    else if ([self.nameTextField.text isEqualToString:@""])
        alertString =  @"Ad alanının doldurulması gerekmektedir.";
    else if ([self.surnameTextField.text isEqualToString:@""])
        alertString =  @"Soyad alanının doldurulması gerekmektedir.";
    else if (self.birthdayPicker.date == nil)
        alertString =  @"Doğum Tarihi alanının doldurulması gerekmektedir.";
    else if ([self.nationalitySegmented selectedSegmentIndex] == -1 )
        alertString = @"Uyruk alanının seçilmesi gerekmektedir.";
    else if ([self.nationalityTextField.text isEqualToString:@""])
        alertString =  @"T.C. Kimlik No alanının doldurulması gerekmektedir.";
    else if ([self.nationalitySegmented selectedSegmentIndex] == 0 &&  [self.nationalityTextField.text length] != 11)
        alertString =  @"T.C: Kimlik No alanının 11 Karakter olması gerekmektedir.";
    else if ([self.licenseNoTextField.text isEqualToString:@""])
        alertString =  @"Ehliyet No. alanının doldurulması gerekmektedir.";
    else if ([self.licensePlaceTextField.text isEqualToString:@""])
        alertString =  @"Ehliyet Alış Yeri'nin doldurulması gerekmektedir.";
    else if (self.licenseDatePicker.date == nil)
        alertString =  @"Ehhliyet Alış Tarihi alanının doldurulması gerekmektedir.";

    else if (self.nationalitySegmented.selectedSegmentIndex == 0) {
        NSString *nameString = @"";
        
        if ([self.middleNameTextField.text isEqualToString:@""]) {
            nameString = self.nameTextField.text;
        }
        else {
            nameString = [NSString stringWithFormat:@"%@ %@", self.nameTextField.text, self.middleNameTextField.text];
        }
        
        BOOL checker = [control idChecker:self.nationalityTextField.text andName:nameString andSurname:self.surnameTextField.text andBirthYear:birtdayYearString];
        
        if (!checker) {
            alertString = @"Girdiğiniz isim ile T.C. Kimlik numarası birbiri ile uyuşmamaktadır. Lütfen kontrol edip tekrar deneyiniz";
        }
    }
    // min.genç sürücü yaşı ve min.ehliyet yılı kontrollerine göre ek sürücünün eklenip eklenemeyeceğine bakılır
    
    if ([alertString isEqualToString:@""]) {
        if ([CarGroup isCarGroupAvailableByAge:_reservation.selectedCarGroup andBirthday:_birthdayPicker.date])
        {
            alertString = [NSString stringWithFormat:@"Seçilen araç grubuna rezervasyon yapılamaz. (Min.Genç Sürücü yaşı: %li - Min.Genç Sürücü Ehliyet Yılı: %li)",(long)_reservation.selectedCarGroup.minYoungDriverAge,(long)_reservation.selectedCarGroup.minYoungDriverLicense];
        }
    }

    if (![alertString isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
        
        [alert show];
        return NO;
    }

    
    //min.Yaş ve min.Ehliyet yılı kontrollerine bakarak hizmet bedeli alınıp alınmayacağına bakar.
    if ([CarGroup checkYoungDriverAddition:_reservation.selectedCarGroup andBirthday:_birthdayPicker.date andLicenseDate:_licenseDatePicker.date])
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
        [[self myDriver] setAdditionalDriverMiddlename:self.middleNameTextField.text.uppercaseString];
        [[self myDriver] setAdditionalDriverSurname:self.surnameTextField.text.uppercaseString];
        [[self myDriver] setAdditionalDriverBirthday:self.birthdayPicker.date];
        
        
        if ([self.nationalitySegmented selectedSegmentIndex] == 0 ) {
            [[self myDriver] setAdditionalDriverNationality:@"TR"];
            [[self myDriver] setAdditionalDriverNationalityNumber:self.nationalityTextField.text];
        }
        else{
            [[self myDriver] setAdditionalDriverNationality:@""];
            [[self myDriver] setAdditionalDriverPassportNumber:self.nationalityTextField.text];
        }
        
        // ek sürücü ehliyet bilgileri
        [[self myDriver] setAdditionalDriverLicenseClass:[self.classSegment titleForSegmentAtIndex:self.classSegment.selectedSegmentIndex]];
        [[self myDriver] setAdditionalDriverLicenseNumber:self.licenseNoTextField.text];
        [[self myDriver] setAdditionalDriverLicensePlace:self.licensePlaceTextField.text.uppercaseString];
        [[self myDriver] setAdditionalDriverLicenseDate:self.licenseDatePicker.date];
        
        [self.reservation.additionalDrivers addObject:self.myDriver];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"additionalDriverAdded" object:nil];
        [[self navigationController] popViewControllerAnimated:YES];
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
