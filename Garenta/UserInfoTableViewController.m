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
#import "MailSoapHandler.h"
#import "AdditionalEquipment.h"

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
@property (nonatomic) BOOL isMailChecked;

@property (nonatomic, strong) NSString *mailCheckString;
@property (nonatomic, strong) NSString *telnoCheckString;

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
    
    self.isMailChecked = NO;
    self.mailCheckString = @"";
    self.telnoCheckString = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self deleteYoungDriverAndMaxSecure];
    //    _reservation.additionalEquipments = [tempEquipments copy];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:@"countrySelected"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"citySelected"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"countySelected"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"phoneCountrySelected"];
}

- (void)deleteYoungDriverAndMaxSecure
{
    NSPredicate *youngDriver = [NSPredicate predicateWithFormat:@"materialNumber = %@",@"HZM0007"];
    NSPredicate *maxSecure = [NSPredicate predicateWithFormat:@"materialNumber = %@",@"HZM0012"];
    NSArray *youngDriverFilter;
    NSArray *maxSecureFilter;
    youngDriverFilter = [_reservation.additionalEquipments filteredArrayUsingPredicate:youngDriver];
    maxSecureFilter = [_reservation.additionalEquipments filteredArrayUsingPredicate:maxSecure];
    
    // daha önce eklenmemişse genç sürücüyü ekliyoruz
    if (youngDriverFilter.count > 0) {
        AdditionalEquipment *temp = [AdditionalEquipment new];
        temp = [youngDriverFilter objectAtIndex:0];
        temp.quantity = 1;
        temp.type = additionalInsurance;
        temp.isRequired = YES;
        
        [_reservation.additionalEquipments removeObject:temp];
        
        //Genç Sürücüyü silince, maksimum güvenceyide 0 yapmamız lazım
        temp = [AdditionalEquipment new];
        temp = [maxSecureFilter objectAtIndex:0];
        
        temp.quantity = 0;
        temp.isRequired = NO;
    }
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
    [self checkFields];
}

- (IBAction)loginButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"LoginVCSegue" sender:self];
}

- (void)checkFields {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        
        // ATA burda kontroller yapılıcak
        
        NSString *alertString = @"";
        
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
            
            IDController *control = [[IDController alloc] init];
            BOOL checker = [control idChecker:self.tcknoTextField.text andName:nameString andSurname:self.surnameTextField.text andBirthYear:birtdayYearString];
            
            if (!checker) {
                alertString = @"Girdiğiniz isim ile T.C. Kimlik numarası birbiri ile uyuşmamaktadır. Lütfen kontrol edip tekrar deneyiniz";
            }
        }
        
        if (![alertString isEqualToString:@""]) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
            [alert show];
        }
        else {
            
            BOOL isMailCheck = [self checkIfInformationIsDuplicate];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (isMailCheck) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:self.mailCheckString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                [alert show];
            }
            else {
                if ([self checkCarAvailableForYoungDriver]) //genç sürücü kontrolü yapar
                    [self verifyPhoneNumber];
            }
        }
    });
}

- (BOOL)checkCarAvailableForYoungDriver
{
    NSString *alertString;
    
    if (![CarGroup isCarGroupAvailableByAge:_reservation.selectedCarGroup andBirthday:self.birthdayDatePicker.date andLicenseDate:self.driverLicenseDatePicker.date])
    {
        alertString = [NSString stringWithFormat:@"Seçilen araç grubuna rezervasyon yapılamaz. (Min.Genç Sürücü yaşı: %li - Min.Genç Sürücü Ehliyet Yılı: %li)",(long)_reservation.selectedCarGroup.minYoungDriverAge,(long)_reservation.selectedCarGroup.minYoungDriverLicense];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
        
        [alert show];
        return NO;
    }
    
    //min.Yaş ve min.Ehliyet yılı kontrollerine bakarak hizmet bedeli alınıp alınmayacağına bakar.
    if ([CarGroup checkYoungDriverAddition:_reservation.selectedCarGroup andBirthday:self.birthdayDatePicker.date andLicenseDate:self.driverLicenseDatePicker.date])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:[NSString stringWithFormat:@"Seçmiş olduğunuz araç grubu için 'Genç Sürücü' ve 'Maksimum Güvence' hizmeti satın alınacaktır (Eklemiş olduğunuz diğer sigorta hizmetleri silinecektir). Devam etmek istiyor musunuz?"] delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Evet", nil];
        
        alert.tag = 5;
        [alert show];
        return NO;
    }
    
    return YES;
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
    
    temp.isUserMailChecked = @"";
    
    if (self.isMailChecked) {
        temp.isUserMailChecked = @"X";
    }
    
    _reservation.temporaryUser = temp;
    
    [self performSegueWithIdentifier:@"toReservationSummaryVCSegue" sender:self];
}

- (void)addYoungDriverAndMaxSecure
{
    NSPredicate *youngDriver = [NSPredicate predicateWithFormat:@"materialNumber = %@",@"HZM0007"];
    NSPredicate *maxSecure = [NSPredicate predicateWithFormat:@"materialNumber = %@",@"HZM0012"];
    NSArray *youngDriverFilter;
    NSArray *youngDriverFilter2;
    NSArray *maxSecureFilter;
    youngDriverFilter = [_reservation.additionalFullEquipments filteredArrayUsingPredicate:youngDriver];
    youngDriverFilter2 = [_reservation.additionalEquipments filteredArrayUsingPredicate:youngDriver];
    maxSecureFilter = [_reservation.additionalEquipments filteredArrayUsingPredicate:maxSecure];
    
    // daha önce eklenmemişse genç sürücüyü ekliyoruz
    if (youngDriverFilter.count > 0 && youngDriverFilter2.count == 0) {
        AdditionalEquipment *temp = [AdditionalEquipment new];
        temp = [youngDriverFilter objectAtIndex:0];
        temp.quantity = 1;
        temp.type = additionalInsurance;
        temp.isRequired = YES;
        
        [_reservation.additionalEquipments addObject:temp];
    }
    
    //genç sürücü eklendiği için maksimum güvenceyi ekliyoruz
    if (maxSecureFilter.count > 0) {
        AdditionalEquipment *tempEqui = [AdditionalEquipment new];
        tempEqui = [maxSecureFilter objectAtIndex:0];
        
        //eğer maksimum güvence daha önce eklendiyse bidaha eklemeye gerek yok
        if (tempEqui.quantity == 0)
        {
            tempEqui.quantity = 1;
            tempEqui.type = additionalInsurance;
            tempEqui.isRequired = YES;
            
            //maksimum güvence ekleneceği için diğer sigortalar varmı yokmu kontrol ediyoruz, eğer varsa quantity 0 olacak
            for (AdditionalEquipment *temp in _reservation.additionalEquipments) {
                if (([[temp materialNumber] isEqualToString:@"HZM0011"] || [[temp materialNumber] isEqualToString:@"HZM0024"] || [[temp materialNumber] isEqualToString:@"HZM0009"] || [[temp materialNumber] isEqualToString:@"HZM0006"]) && [temp quantity] == 1) {
                    [temp setQuantity:0];
                }
            }
        }
    }
    
    [self verifyPhoneNumber];
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
    
    NSString *timerAlert = @"";
    
    if (![self.telnoCheckString isEqualToString:@""]) {
        timerAlert = [NSString stringWithFormat:@"%@ Lütfen telefonunuza gelen konfirmasyon kodunu 120 saniye içinde giriniz", self.telnoCheckString];
    }
    else {
        timerAlert = @"Lütfen telefonunuza gelen konfirmasyon kodunu 120 saniye içinde giriniz";
    }
    
    self.timerAlertView = [[UIAlertView alloc] initWithTitle:@"Uyarı"
                                                     message:timerAlert
                                                    delegate:self
                                           cancelButtonTitle:@"Geri"
                                           otherButtonTitles:@"Tamam", nil];
    [self.timerAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [self.timerAlertView setTag:1];
    [self.timerAlertView show];
    
    self.alertTimer = 120;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(updateSMSAlert:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)verifyEmailAdress {
    [self.timer invalidate];
    [self releaseAllTextFields];
    
    NSString *generatedCode = [SMSSoapHandler generateCode];
    
    if (generatedCode == nil || [generatedCode isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Kod gönderilemedi, lütfen tekrar deneyiniz" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else {
        self.validationCode = generatedCode;
        
        NSString *mailAdress = self.emailTextField.text;
        
        BOOL success = [MailSoapHandler sendVerificationMessage:self.validationCode toMail:mailAdress withFirstname:self.nameTextField.text andLastname:self.surnameTextField.text];
        
        if (!success) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Mail gönderilemedi, lütfen tekrar deneyiniz" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    
    self.timerAlertView = [[UIAlertView alloc] initWithTitle:@"Uyarı"
                                                     message:@"Lütfen mail'inize gelen konfirmasyon kodunu 120 saniye içinde giriniz"
                                                    delegate:self
                                           cancelButtonTitle:@"Onaylamadan Devam Et"
                                           otherButtonTitles:@"Tamam", nil];
    [self.timerAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [self.timerAlertView setTag:3];
    [self.timerAlertView show];
    
    self.alertTimer = 120;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(updateEmailAlert:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)updateSMSAlert:(id)sender {
    self.alertTimer--;
    
    NSString *timerAlert = @"";
    
    if (![self.telnoCheckString isEqualToString:@""]) {
        timerAlert = [NSString stringWithFormat:@"%@ Lütfen telefonunuza gelen konfirmasyon kodunu %lu saniye içinde giriniz", self.telnoCheckString, (unsigned long)_alertTimer];
    }
    else {
        timerAlert = [NSString stringWithFormat:@"Lütfen telefonunuza gelen konfirmasyon kodunu %lu saniye içinde giriniz", (unsigned long)_alertTimer];
    }
    
    self.timerAlertView.message = timerAlert;
    
    if (self.alertTimer == 0) {
        [self.timer invalidate];
        [self.timerAlertView dismissWithClickedButtonIndex:0 animated:YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Konfirmasyon kodunu giremediniz. Tekrar deneyebilir veya girmiş olduğunuz telefon numarasını kontrol edebilirsiniz" delegate:self cancelButtonTitle:@"Geri" otherButtonTitles:@"Tekrar Dene", nil];
        [alert setTag:2];
        [alert show];
    }
}

- (void)updateEmailAlert:(id)sender {
    self.alertTimer--;
    self.timerAlertView.message = [NSString stringWithFormat:@"Lütfen mail'inize gelen konfirmasyon kodunu %lu saniye içinde giriniz", (unsigned long)self.alertTimer];
    
    if (self.alertTimer == 0) {
        [self.timer invalidate];
        [self.timerAlertView dismissWithClickedButtonIndex:0 animated:YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Konfirmasyon kodunu giremediniz. Tekrar deneyebilir veya girmiş olduğunuz mail adresini kontrol edebilirsiniz" delegate:self cancelButtonTitle:@"Onaylamadan Devam Et" otherButtonTitles:@"Tekrar Dene", nil];
        [alert setTag:4];
        [alert show];
    }
}

#pragma mark - alertview delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1) {
        [self.timer invalidate];
        
        if (buttonIndex == 1) {
            NSString *alertViewText = [[alertView textFieldAtIndex:0] text];
            
            if (alertViewText != nil && ![alertViewText isEqualToString:@""]) {
                if ([alertViewText isEqualToString:self.validationCode]) {
                    [self verifyEmailAdress];
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
    }
    else if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            [self verifyPhoneNumber];
        }
    }
    else if (alertView.tag == 3) {
        [self.timer invalidate];
        
        if (buttonIndex == 1) {
            
            NSString *alertViewText = [[alertView textFieldAtIndex:0] text];
            
            if (alertViewText != nil && ![alertViewText isEqualToString:@""]) {
                if ([alertViewText isEqualToString:self.validationCode]) {
                    self.isMailChecked = YES;
                    
                    [self goToReservationSummary];
                }
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Girmiş olduğunuz kod ile konfirmasyon kodu uyuşmamaktadır" delegate:self cancelButtonTitle:@"Onaylamadan Devam Et" otherButtonTitles:@"Tekrar Dene", nil];
                [alert setTag:4];
                [alert show];
            }
        }
        else {
            [self goToReservationSummary];
        }
    }
    else if (alertView.tag == 4) {
        if (buttonIndex == 1) {
            [self verifyEmailAdress];
        }
        else {
            [self goToReservationSummary];
        }
    }
    else if (alertView.tag == 5)
        if (buttonIndex == 1) {
            [self addYoungDriverAndMaxSecure];
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

- (BOOL)checkIfInformationIsDuplicate {
    
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZNET_CHECK_BP_TELNO_EMAIL"];
        
        NSString *isInputName = @"IS_INPUT";
        NSArray *isInputColumns = @[@"EMAIL", @"TELNO", @"KANALTURU"];
        NSArray *isInputValue = @[self.emailTextField.text, self.mobilePhoneTextField.text, @"Z07"];
        
        [handler addImportStructure:isInputName andColumns:isInputColumns andValues:isInputValue];
        [handler addImportParameter:@"IV_NEW" andValue:@"X"];
        
        [handler addTableForReturn:@"ET_RETURN"];
        
        NSDictionary *result = [handler prepCall];
        
        if (result != nil) {
            NSDictionary *export = [result objectForKey:@"EXPORT"];
            NSString *evSubrc = [export valueForKey:@"EV_SUBRC"];
            
            if ([evSubrc isEqualToString:@"4"]) {
                NSDictionary *tables = [result objectForKey:@"TABLES"];
                NSDictionary *etReturn = [tables objectForKey:@"BAPIRET2"];
                
                NSString *telnoCheck = [export valueForKey:@"EV_CEPTEL_CHECK"];
                
                if ([telnoCheck isEqualToString:@"X"]) {
                    for (NSDictionary *dict in etReturn) {
                        self.telnoCheckString = [dict valueForKey:@"MESSAGE"];
                    }
                }
                else {
                    for (NSDictionary *dict in etReturn) {
                        self.mailCheckString = [dict valueForKey:@"MESSAGE"];
                        return YES;
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    return NO;
}

@end
