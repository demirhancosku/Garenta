//
//  UserCreationVC.m
//  Garenta
//
//  Created by Ata  Cengiz on 27.02.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "UserCreationVC.h"
#import "IDController.h"
#import "MBProgressHUD.h"

@interface UserCreationVC ()

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
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *password2TextField;
@property (weak, nonatomic) IBOutlet UITextField *securityAnswerTextField;
@property (weak, nonatomic) IBOutlet UILabel *tcknoLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *driverLicenseDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *birthdayDatePicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *driverLicenseTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIPickerView *secretQuestionPickerView;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *countyLabel;

@property (strong, nonatomic) NSArray *selectedCountry;
@property (strong, nonatomic) NSArray *selectedCity;
@property (strong, nonatomic) NSArray *selectedCounty;

@property (nonatomic) NSInteger selectedTextField;

@property (strong, nonatomic) UIAlertView *timerAlertView;
@property (nonatomic) NSUInteger smsAlertTimer;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSString *smsValidationCode;

@end

@implementation UserCreationVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:@"countrySelected"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"citySelected"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"countySelected"];
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

- (IBAction)continueButtonPressed:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
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
        else if ([self.mobilePhoneTextField.text isEqualToString:@""])
            alertString =  @"Cep Telefonu alanının doldurulması gerekmektedir";
        else if ([self.passwordTextField.text isEqualToString:@""])
            alertString =  @"Şifre alanının doldurulması gerekmektedir";
        else if ([self.passwordTextField.text length] < 5 && [self.passwordTextField.text length] > 10)
            alertString =  @"Şifre alanının 6 ile 10 karakter arasında olması gerekmektedir";
        else if ([self.password2TextField.text isEqualToString:@""])
            alertString =  @"Şifre(Tekrar) alanının doldurulması gerekmektedir";
        else if (![self.passwordTextField.text isEqualToString:[self.password2TextField text]])
            alertString =  @"Şifre alanlarının aynı olması gerekmektedir";
        else if ([self.secretQuestionPickerView selectedRowInComponent:0] == 0)
            alertString =  @"Gizli Sorunun seçilmesi gerekmektedir";
        else if ([self.securityAnswerTextField.text isEqualToString:@""])
            alertString =  @"Gizli soru cevabı alanının doldurulması gerekmektedir";
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
        
        if (![alertString isEqualToString:@""]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                [alert show];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self checkPhoneNumberValidation];
            });
        }
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (void)checkPhoneNumberValidation {
    self.timerAlertView = [[UIAlertView alloc] initWithTitle:@"Uyarı"
                                                     message:@"Lütfen Telefonunuza gelen onay kodunu 60 saniye içinde giriniz"
                                                    delegate:self
                                           cancelButtonTitle:@"Geri"
                                           otherButtonTitles:@"Tamam", nil];
    [self.timerAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [self.timerAlertView setTag:1];
    [self.timerAlertView show];
    
    self.smsAlertTimer = 60;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(updateAlert:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)updateAlert:(id)sender {
    self.smsAlertTimer--;
    self.timerAlertView.message = [NSString stringWithFormat:@"Lütfen Telefonunuza gelen onay kodunu %d saniye içinde giriniz", self.smsAlertTimer];
    
    if (self.smsAlertTimer == 0) {
        [self.timer invalidate];
        [self.timerAlertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            NSString *alertText = [alertView textFieldAtIndex:0].text;
            
            if ([alertText isEqualToString:self.smsValidationCode]) {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    
                    [self createUserAtSAP];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    });
                });
            }
        }
    }
}

- (void)createUserAtSAP {
    
    NSString *alertString = @"";
    
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZMOB_KDK_CREATE_POT_CUSTOMER"];
        
        NSArray *columns = @[@"FIRSTNAME", @"MIDDLENAME", @"LASTNAME", @"BIRTHDATE", @"TCKN", @"MTYPE", @"EMAIL", @"TELNO", @"NICKNAME", @"PASSWORD", @"ILKODU", @"ILCEKOD", @"ADRESS", @"KANALTURU", @"UYRUK", @"ULKE", @"EHLIYETNO", @"EHLIYETTARIHI", @"PASAPORTNO", @"SMSFLAG", @"SALES_ORGANIZATION", @"DISTRIBUTION_CHANNEL", @"DIVISION", @"CINSIYET", @"GUVENSORU", @"GUVENSORU_TXT", @"GUVENCEVAP", @"EHLIYET_ALISYERI", @"EHLIYET_SINIFI", @"TK_KARTNO", @"TELNO_ULKE", @"EMAIL_CONFIRM", @"TELNO_CONFIRM"];
        
        NSString *tcknNo = @"";
        NSString *passportNo = @"";
        NSString *nationality = @"";
        
        if (self.nationalitySegmentedControl.selectedSegmentIndex == 0) {
            tcknNo = self.tcknoTextField.text;
            nationality = @"TR";
        }
        else {
            passportNo = self.tcknoTextField.text;
        }
        
        NSCharacterSet *charactersToRemove = [NSCharacterSet characterSetWithCharactersInString:@"() "];
        NSString *trimmedMobilePhone = [[self.mobilePhoneTextField.text componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
        
        if (self.selectedCounty == nil) {
            self.selectedCounty = @[@"", @"", @"", @""];
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd"];
        
        NSString *driverLicenseDate = @"";
        
        if (![self.driverLicenseNoTextField.text isEqualToString:@""]) {
            driverLicenseDate = [formatter stringFromDate:[self.driverLicenseDatePicker date]];
        }
        
        NSString *gender = @"";
        
        if (self.genderSegmentedControl.selectedSegmentIndex == 0) {
            gender = @"1";
        }
        else {
            gender = @"2";
        }
        
        NSString *driverLicenseType = @"";
        
        if (self.driverLicenseTypeSegmentedControl.selectedSegmentIndex != -1) {
            driverLicenseType = [self.driverLicenseTypeSegmentedControl titleForSegmentAtIndex:self.driverLicenseTypeSegmentedControl.selectedSegmentIndex];
        }
        
        NSString *secretQuestion = [NSString stringWithFormat:@"00%i", [self.secretQuestionPickerView selectedRowInComponent:0]];
        
        NSArray *value = @[self.nameTextField.text, self.middleNameTextField.text, self.surnameTextField.text, @"", tcknNo, @"X", self.emailTextField.text, trimmedMobilePhone, @"", self.passwordTextField.text, self.selectedCity[1], self.selectedCounty[2], self.adressTextField.text, @"Z07", nationality, self.selectedCountry[0], self.driverLicenseNoTextField.text, driverLicenseDate, passportNo, @"X", @"3063", @"33", @"65", gender, secretQuestion, @"", self.securityAnswerTextField.text, self.driverLicenseLocationTextField.text, driverLicenseType, @"", @"90", @"", @""];
        
        [handler addImportStructure:@"IS_INPUT" andColumns:columns andValues:value];
        [handler addImportParameter:@"I_BIRTHDATE_TEXT" andValue:[formatter stringFromDate:self.birthdayDatePicker.date]];
        [handler addTableForReturn:@"ET_BAPIRET"];
        
        NSDictionary *response = [handler prepCall];
        
        if (response != nil) {
            NSDictionary *export = [response objectForKey:@"EXPORT"];
            
            NSString *subrc = [export valueForKey:@"E_RETURN"];
            
            if ([subrc isEqualToString:@"0"]) {
                alertString = @"Kullanıcınız başarı ile yaratılmıştır. Giriş yapabilirsiniz";
            }
            else {
                alertString = @"Kullanıcı yaratımı sırasında hata alındı. Lütfen tekrar deneyiniz";
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
            [alert show];
        });
    }
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
    [self.passwordTextField resignFirstResponder];
    [self.password2TextField resignFirstResponder];
    [self.securityAnswerTextField resignFirstResponder];
}

#pragma mark - textfield delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self releaseAllTextFields];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField tag] == 15)
    {
        switch ([textField.text length])
        {
            case 0:
                textField.text = [NSString stringWithFormat:@"( %@", textField.text];
                break;
            case 5:
                textField.text = [NSString stringWithFormat:@"%@ ) ", textField.text];
                break;
            case 11:
                textField.text = [NSString stringWithFormat:@"%@ ", textField.text];
                break;
            case 14:
                textField.text = [NSString stringWithFormat:@"%@ ", textField.text];
                break;
            default:
                break;
        }
    }
    
    return YES;
}

#pragma mark - Pickerview Delegation Methods

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel* tView = (UILabel*)view;
    
    if (!tView){
        tView = [[UILabel alloc] init];
        tView.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
    }
    
    tView.text = [secretQuestionsArray objectAtIndex:row];
    
    return tView;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [secretQuestionsArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [secretQuestionsArray objectAtIndex:row];
}

@end
