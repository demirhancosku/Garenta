//
//  UserInfoTableViewController.m
//  Garenta
//
//  Created by Alp Keser on 6/6/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "UserInfoTableViewController.h"
#import "IDController.h"
#import "ReservationSummaryVC.h"
#import "MBProgressHUD.h"
#import "CountrySelectionVC.h"
#import "LoginVC.h"
#import "SMSSoapHandler.h"

@interface UserInfoTableViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *middleNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *surnameTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *nationalitySegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *tcknoTextField;
@property (weak, nonatomic) IBOutlet UITextField *driverLicenseNoTextField;
@property (weak, nonatomic) IBOutlet UITextField *driverLicenseLocationTextField;
@property (weak, nonatomic) IBOutlet UITextField *adressTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobilePhoneTextField;
@property (weak, nonatomic) IBOutlet UILabel *tcknoLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *driverLicenseDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *birthdayDatePicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *driverLicenseTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *countyLabel;

@property (strong, nonatomic) NSArray *selectedCountry;
@property (strong, nonatomic) NSArray *selectedCity;
@property (strong, nonatomic) NSArray *selectedCounty;

@property (strong, nonatomic) UIAlertView *timerAlertView;
@property (nonatomic) NSUInteger alertTimer;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSString *validationCode;

@property (weak, nonatomic) IBOutlet UILabel *mobilePhoneCountryLabel;
@end

@implementation UserInfoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    cityArray = [[NSMutableArray alloc] init];
    countryArray = [[NSMutableArray alloc] init];
    countyArray = [[NSMutableArray alloc] init];
    
    secretQuestionsArray =[NSMutableArray arrayWithObjects:@"Soru Seçiniz...", @"İlk evcil haynanınızın adı nedir ?", @"En sevdiğiniz oyunun adı nedir ?", @"Okuduğunuz ilkokulun adı nedir ?", @"En sevdiğiniz kahramanın adı nedir ?", nil];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [self getCountryInformationFromSAP];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    
    [self prepareScreen];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countrySelected:) name:@"countrySelected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(citySelected:) name:@"citySelected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countySelected:) name:@"countySelected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phoneCountrySelected:) name:@"phoneCountrySelected" object:nil];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:@"countrySelected"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"citySelected"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"countySelected"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"phoneCountrySelected"];
}

- (void)prepareScreen
{
    [[UITextField appearance] setTintColor:[UIColor blackColor]];
    [[UITableViewCell appearance] setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    self.nationalitySegmentedControl.selectedSegmentIndex = -1;
    self.genderSegmentedControl.selectedSegmentIndex = -1;
    self.driverLicenseTypeSegmentedControl.selectedSegmentIndex = -1;
    
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDate * currentDate = [NSDate date];
    NSDateComponents * comps = [[NSDateComponents alloc] init];
    [comps setYear: -18];
    NSDate * maxDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
    [comps setYear: -100];
    NSDate * minDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
    
    [self.birthdayDatePicker setMaximumDate:maxDate];
    [self.birthdayDatePicker setMinimumDate:minDate];
    [self.birthdayDatePicker setDate:maxDate];
    
    [self.driverLicenseDatePicker setMaximumDate:[NSDate date]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getCountryInformationFromSAP {
    
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZNET_GET_ULKE_IL_ILCE"];
        
        [handler addTableForReturn:@"ET_ULKE"];
        [handler addTableForReturn:@"ET_IL"];
        [handler addTableForReturn:@"ET_ILCE"];
        
        NSDictionary *result = [handler prepCall];
        
        if (result != nil) {
            NSDictionary *export = [result objectForKey:@"EXPORT"];
            NSString *evSubrc = [export valueForKey:@"EV_SUBRC"];
            
            if ([evSubrc isEqualToString:@"0"]) {
                NSDictionary *tables = [result objectForKey:@"TABLES"];
                
                NSDictionary *countryDict = [tables objectForKey:@"T005T"];
                
                for (NSDictionary *tempDict in countryDict) {
                    NSArray *arr = @[[tempDict valueForKey:@"LAND1"], [tempDict valueForKey:@"LANDX50"]];
                    [countryArray addObject:arr];
                }
                
                NSDictionary *cityDict = [tables objectForKey:@"T005U"];
                
                for (NSDictionary *tempDict in cityDict) {
                    NSArray *arr = @[[tempDict valueForKey:@"LAND1"], [tempDict valueForKey:@"BLAND"], [tempDict valueForKey:@"BEZEI"]];
                    [cityArray addObject:arr];
                }
                
                NSDictionary *countyDict = [tables objectForKey:@"ZGET_GET_ILCE_ST"];
                
                for (NSDictionary *tempDict in countyDict) {
                    NSArray *arr = @[[tempDict valueForKey:@"COUNTRY"], [tempDict valueForKey:@"REGION"], [tempDict valueForKey:@"CITY_CODE"], [tempDict valueForKey:@"MC_CITY"]];
                    [countyArray addObject:arr];
                }
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self releaseAllTextFields];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if ([identifier isEqualToString:@"CitySelectionSegue"]) {
        if (self.selectedCountry == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Lütfen önce ülke seçiniz" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
    }
    if ([identifier isEqualToString:@"CountySelectionSegue"]) {
        if (self.selectedCity == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Lütfen önce ülke seçiniz" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"CountrySelectionSegue"]) {
        CountrySelectionVC *selectionVC = (CountrySelectionVC *)[segue destinationViewController];
        selectionVC.selectionArray = countryArray;
        selectionVC.searchType = 1;
    }
    
    if ([[segue identifier] isEqualToString:@"CitySelectionSegue"]) {
        CountrySelectionVC *selectionVC = (CountrySelectionVC *)[segue destinationViewController];
        
        NSMutableArray *cityAccordingToCountry = [NSMutableArray new];
        
        if (self.selectedCountry != nil) {
            for (NSArray *arr in cityArray) {
                if ([[arr objectAtIndex:0] isEqualToString:[self.selectedCountry objectAtIndex:0]]) {
                    [cityAccordingToCountry addObject:arr];
                }
            }
        }
        
        selectionVC.selectionArray = cityAccordingToCountry;
        selectionVC.searchType = 2;
    }
    
    if ([[segue identifier] isEqualToString:@"CountySelectionSegue"]) {
        CountrySelectionVC *selectionVC = (CountrySelectionVC *)[segue destinationViewController];
        
        NSMutableArray *countyAccordingToCity = [NSMutableArray new];
        
        if (self.selectedCity != nil) {
            for (NSArray *arr in countyArray) {
                if ([[arr objectAtIndex:1] isEqualToString:[self.selectedCity objectAtIndex:1]] && [[arr objectAtIndex:0] isEqualToString:[self.selectedCountry objectAtIndex:0]]) {
                    [countyAccordingToCity addObject:arr];
                }
            }
        }
        
        selectionVC.selectionArray = countyAccordingToCity;
        selectionVC.searchType = 3;
    }
    if ([segue.identifier isEqualToString:@"toReservationSummaryVCSegue"]) {
        [(ReservationSummaryVC *)[segue destinationViewController] setReservation:_reservation];
    }
    if ([segue.identifier isEqualToString:@"LoginVCSegue"]) {
        [(LoginVC *)[segue destinationViewController] setReservation:_reservation];
    }
    if ([[segue identifier] isEqualToString:@"MobilePhoneCountrySelectionSegue"]) {
        CountrySelectionVC *selectionVC = (CountrySelectionVC *)[segue destinationViewController];
        selectionVC.selectionArray = countryArray;
        selectionVC.searchType = 4;
    }
}

- (void)nationalitySegmentChanged:(id)sender {
    UISegmentedControl *nationality = (UISegmentedControl *)sender;
    
    if (nationality.selectedSegmentIndex == 0) {
        self.tcknoLabel.text = @"T.C. Kimlik No*";
    }
    else if (nationality.selectedSegmentIndex == 1) {
        self.tcknoLabel.text = @"Pasaport No*";
    }
}

- (void)countrySelected:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSArray *country = [userInfo objectForKey:@"Country"];
    
    self.countryLabel.text = [country objectAtIndex:1];
    self.selectedCountry = country;
    
    self.selectedCity = nil;
    self.cityLabel.text = @"";
    self.selectedCounty = nil;
    self.countyLabel.text = @"";
}

- (void)citySelected:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSArray *city = [userInfo objectForKey:@"City"];
    
    self.cityLabel.text = [city objectAtIndex:2];
    self.selectedCity = city;
    
    self.selectedCounty = nil;
    self.countyLabel.text = @"";
}

- (void)countySelected:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSArray *county = [userInfo objectForKey:@"County"];
    
    self.countyLabel.text = [county objectAtIndex:3];
    self.selectedCounty = county;
}

- (void)phoneCountrySelected:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSArray *country = [userInfo objectForKey:@"PhoneCountry"];
    
    self.mobilePhoneCountryLabel.text = country[0];
}

- (IBAction)continueButtonPressed:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self checkFields];
}

- (IBAction)loginButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"LoginVCSegue" sender:self];
}

- (void)checkFields {
    // ATA burda kontroller yapılıcak
    
    NSString *alertString = @"";
    
    IDController *control = [[IDController alloc] init];
    
    NSDateFormatter *bdayFormatter = [[NSDateFormatter alloc] init];
    [bdayFormatter setDateFormat:@"yyyyMMdd"];
    NSString *birthdayDate = [bdayFormatter stringFromDate:[self.birthdayDatePicker date]];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents =[gregorian components:NSYearCalendarUnit fromDate:[self.birthdayDatePicker date]];
    NSString *birtdayYearString = [NSString stringWithFormat:@"%li", (long)weekdayComponents.year];
    
    if ([self.genderSegmentedControl selectedSegmentIndex] == -1 )
        alertString = @"Bay/Bayan alanının seçilmesi gerekmektedir";
    else if ([self.nameTextField.text isEqualToString:@""])
        alertString =  @"Ad alanının doldurulması gerekmektedir";
    else if ([self.surnameTextField.text isEqualToString:@""])
        alertString =  @"Soyad alanının doldurulması gerekmektedir";
    else if ([birthdayDate isEqualToString:@""] || birthdayDate == nil)
        alertString =  @"Doğum Tarihi alanının doldurulması gerekmektedir";
    else if ([self.nationalitySegmentedControl selectedSegmentIndex] == -1 )
        alertString = @"Uyruk alanının seçilmesi gerekmektedir";
    else if ([self.tcknoTextField.text isEqualToString:@""])
        alertString =  @"T.C. Kimlik No alanının doldurulması gerekmektedir";
    else if ([self.nationalitySegmentedControl selectedSegmentIndex] == 0 &&  [self.tcknoTextField.text length] != 11)
        alertString =  @"T.C: Kimlik No alanının 11 Karakter olması gerekmektedir";
    else if (self.selectedCountry == nil)
        alertString =  @"Ülkenin seçilmesi gerekmektedir";
    else if (self.selectedCity == nil)
        alertString = @"Şehrin seçilmesi gerekmektedir";
    else if ([[self.selectedCountry objectAtIndex:0] isEqualToString:@"TR"] && self.selectedCounty == nil)
        alertString = @"İlçenin seçilmesi gerekmektedir";
    else if ([self.adressTextField.text isEqualToString:@""])
        alertString =  @"Adres alanının doldurulması gerekmektedir";
    else if ([self.emailTextField.text isEqualToString:@""])
        alertString =  @"E-mail alanının doldurulması gerekmektedir";
    else if ([[self.mobilePhoneTextField.text substringFromIndex:3] isEqualToString:@""])
        alertString =  @"Cep Telefonu alanının doldurulması gerekmektedir";
    else if (self.nationalitySegmentedControl.selectedSegmentIndex == 0) {
        NSString *nameString = @"";
        
        if ([self.middleNameTextField.text isEqualToString:@""]) {
            nameString = self.nameTextField.text;
        }
        else {
            nameString = [NSString stringWithFormat:@"%@ %@", self.nameTextField.text, self.middleNameTextField.text];
        }
        
        BOOL checker = [control idChecker:self.tcknoTextField.text andName:nameString andSurname:self.surnameTextField.text andBirthYear:birtdayYearString];
        
        if (!checker) {
            alertString = @"Girdiğiniz isim ile T.C. Kimlik numarası birbiri ile uyuşmamaktadır. Lütfen kontrol edip tekrar deneyiniz";
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    
    if (![alertString isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
        [alert show];
    }
    else {
        [self verifyPhoneNumber];
    }
}

- (void)goToReservationSummary {
    // if all user verifications are right
    
    User *temp = [[User alloc] init];
    
    temp.gender = @"";
    if (self.genderSegmentedControl.selectedSegmentIndex == 0) {
        temp.gender = @"1";
    }
    else {
        temp.gender = @"2";
    }
    
    temp.name = self.nameTextField.text;
    temp.middleName = self.middleNameTextField.text;
    temp.surname = self.surnameTextField.text;
    temp.birthday = self.birthdayDatePicker.date;
    temp.nationality = self.selectedCountry[0];
    temp.tckno = self.tcknoTextField.text;
    temp.country = self.selectedCountry[0];
    temp.city = self.selectedCity[1];
    
    temp.county = @"";
    
    if (self.selectedCounty != nil) {
        temp.county = self.selectedCounty[2];
    }
    
    temp.address = self.adressTextField.text;
    temp.email = self.emailTextField.text;
    temp.mobile = self.mobilePhoneTextField.text;
    temp.mobileCountry = self.mobilePhoneCountryLabel.text;
    
    temp.driversLicenseDate = self.driverLicenseDatePicker.date;
    temp.driverLicenseNo = self.driverLicenseNoTextField.text;
    temp.driverLicenseLocation = self.driverLicenseLocationTextField.text;
    
    NSString *driverLicenseType = @"";
    
    if (self.driverLicenseTypeSegmentedControl.selectedSegmentIndex != -1) {
        driverLicenseType = [self.driverLicenseTypeSegmentedControl titleForSegmentAtIndex:self.driverLicenseTypeSegmentedControl.selectedSegmentIndex];
    }
    temp.driverLicenseType = driverLicenseType;
    
    _reservation.temporaryUser = temp;
    
    [self performSegueWithIdentifier:@"toReservationSummaryVCSegue" sender:self];
}

- (void)releaseAllTextFields
{
    [self.nameTextField resignFirstResponder];
    [self.middleNameTextField resignFirstResponder];
    [self.surnameTextField resignFirstResponder];
    [self.tcknoTextField resignFirstResponder];
    [self.driverLicenseNoTextField resignFirstResponder];
    [self.driverLicenseLocationTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.mobilePhoneTextField resignFirstResponder];
    [self.adressTextField resignFirstResponder];
}

- (void)verifyPhoneNumber {
    
    [self.timer invalidate];
    [self releaseAllTextFields];
    
    NSString *generatedCode = [SMSSoapHandler generateCode];
    
    if (generatedCode == nil || [generatedCode isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"SMS gönderilemedi, lütfen tekrar deneyiniz" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else {
        self.validationCode = generatedCode;
        
        NSString *phoneNumber = self.mobilePhoneTextField.text;
        
        BOOL success = [SMSSoapHandler sendSMSMessage:self.validationCode toNumber:phoneNumber];
        
        if (!success) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"SMS gönderilemedi, lütfen tekrar deneyiniz" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    
    self.timerAlertView = [[UIAlertView alloc] initWithTitle:@"Uyarı"
                                                     message:@"Lütfen telefonunuza gelen konfirmasyon kodunu 60 saniye içinde giriniz"
                                                    delegate:self
                                           cancelButtonTitle:@"Geri"
                                           otherButtonTitles:@"Tamam", nil];
    [self.timerAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [self.timerAlertView setTag:1];
    [self.timerAlertView show];
    
    self.alertTimer = 60;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(updateSMSAlert:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)updateSMSAlert:(id)sender {
    self.alertTimer--;
    self.timerAlertView.message = [NSString stringWithFormat:@"Lütfen telefonunuza gelen konfirmasyon kodunu %lu saniye içinde giriniz", (unsigned long)self.alertTimer];
    
    if (self.alertTimer == 0) {
        [self.timer invalidate];
        [self.timerAlertView dismissWithClickedButtonIndex:0 animated:YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Konfirmasyon kodunu giremediniz. Tekrar deneyebilir veya girmiş olduğunuz telefon numarasını kontrol edebilirsiniz" delegate:self cancelButtonTitle:@"Geri" otherButtonTitles:@"Tekrar Dene", nil];
        [alert setTag:2];
        [alert show];
    }
}

#pragma mark - alertview delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1) {
        [self.timer invalidate];
        
        NSString *alertViewText = [[alertView textFieldAtIndex:0] text];
        
        if (alertViewText != nil && ![alertViewText isEqualToString:@""]) {
            if ([alertViewText isEqualToString:self.validationCode]) {
                [self goToReservationSummary];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Girmiş olduğunuz kod ile konfirmasyon kodu uyuşmamaktadır" delegate:self cancelButtonTitle:@"Geri" otherButtonTitles:@"Tekrar Dene", nil];
                [alert setTag:2];
                [alert show];
            }
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Girmiş olduğunuz kod ile konfirmasyon kodu uyuşmamaktadır" delegate:self cancelButtonTitle:@"Geri" otherButtonTitles:@"Tekrar Dene", nil];
            [alert setTag:2];
            [alert show];
        }
    }
    else if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            [self verifyPhoneNumber];
        }
    }
}

#pragma mark - textfield delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self releaseAllTextFields];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField tag] == 5 && self.nationalitySegmentedControl.selectedSegmentIndex == 0)
    {
        if (range.location == 11) {
            return NO;
        }
    }
    
    if ([textField tag] == 15)
    {
        if (range.location == 10)
            return NO;
    }
    
    return YES;
}

@end
