//
//  ProfileTableViewController.m
//  Garenta
//
//  Created by Ata Cengiz on 28/10/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "ProfileTableViewController.h"
#import "MBProgressHUD.h"
#import "CountrySelectionVC.h"
#import "SMSSoapHandler.h"
#import "MailSoapHandler.h"
#import "LoginVC.h"

@interface ProfileTableViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *middleNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *surnameTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *nationalitySegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *tcknoTextField;
@property (weak, nonatomic) IBOutlet UITextField *driverLicenseNoTextField;
@property (weak, nonatomic) IBOutlet UITextField *driverLicenseLocationTextField;
@property (weak, nonatomic) IBOutlet UITextField *adressTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobilePhoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobilePhone2TextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *email2TextField;
@property (weak, nonatomic) IBOutlet UILabel *tcknoLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *driverLicenseDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *birthdayDatePicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *driverLicenseTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *countyLabel;
@property (weak, nonatomic) IBOutlet UITextField *garentaTLTextField;

@property (strong, nonatomic) NSArray *selectedCountry;
@property (strong, nonatomic) NSArray *selectedCity;
@property (strong, nonatomic) NSArray *selectedCounty;

@property (strong, nonatomic) NSArray *phoneNumbersArray;
@property (strong, nonatomic) NSArray *mailsArray;

@property (strong, nonatomic) UIAlertView *timerAlertView;
@property (nonatomic) NSUInteger alertTimer;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSString *validationCode;

@property (strong, nonatomic) NSString *secretQuestion;
@property (strong, nonatomic) NSString *secretQuestionsAnswer;

@property (nonatomic) NSUInteger selectedRow;
@property (strong, nonatomic) NSString *tempPhoneNumber;
@property (strong, nonatomic) NSString *tempPhoneProcessType;
@property (strong, nonatomic) NSString *tempMailAdress;
@property (strong, nonatomic) NSString *tempIsStandart;

@property (strong, nonatomic) NSString *partnerNo;

@end

@implementation ProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    cityArray = [[NSMutableArray alloc] init];
    countryArray = [[NSMutableArray alloc] init];
    countyArray = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countrySelected:) name:@"countrySelected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(citySelected:) name:@"citySelected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countySelected:) name:@"countySelected" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:@"countrySelected"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"citySelected"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"countySelected"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[ApplicationProperties getUser] isLoggedIn]) {
        if (![self.partnerNo isEqualToString:[[ApplicationProperties getUser] kunnr]]) {
            [self getProfileInformationFromSAP];
        }
    }
    else {
        [self performSegueWithIdentifier:@"ToLoginVCSegue" sender:self];
    }
}

- (void)getProfileInformationFromSAP {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self getCountryInformationFromSAP];
        [self getUserInformationFromSAP];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[self tableView] reloadData];
    });
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

- (void)getUserInformationFromSAP {
    NSString *alertString = @"";
    
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZNET_GET_PROFIL_BILGILERI"];
        
        [handler addImportParameter:@"IV_PARTNER" andValue:[[ApplicationProperties getUser] kunnr]];
        [handler addImportParameter:@"IV_LANGU" andValue:@"T"];
        
        [handler addTableForReturn:@"ET_RETURN"];
        [handler addTableForReturn:@"ET_ADRES"];
        [handler addTableForReturn:@"IT_EMAIL"];
        [handler addTableForReturn:@"IT_TELNO"];
        
        NSDictionary *response = [handler prepCall];
        
        if (response != nil) {
            NSDictionary *export = [response objectForKey:@"EXPORT"];
            
            NSDictionary *esProfile = [export valueForKey:@"ES_PROFILBILGI"];
            
            NSString *gender = [esProfile valueForKey:@"GENDER"];
            
            if ([gender isEqualToString:@"1"]) {
                [self.genderSegmentedControl setSelectedSegmentIndex:0];
            }
            else if ([gender isEqualToString:@"1"]) {
                [self.genderSegmentedControl setSelectedSegmentIndex:1];
            }
            else {
                [self.genderSegmentedControl setSelectedSegmentIndex:-1];
            }
            
            self.nameTextField.text = [esProfile valueForKey:@"MC_NAME2"];
            self.middleNameTextField.text = [esProfile valueForKey:@"NAMEMIDDLE"];
            self.surnameTextField.text = [esProfile valueForKey:@"MC_NAME1"];
            
            NSDateFormatter *formatter = [NSDateFormatter new];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            
            NSDate *birthday = [formatter dateFromString:[esProfile valueForKey:@"BIRTHDT"]];
            
            if (birthday != nil) {
                self.birthdayDatePicker.date = birthday;
            }
            
            NSString *nationality = [esProfile valueForKey:@"UYRUK"];
            
            if ([nationality isEqualToString:@"TR"]) {
                [self.nationalitySegmentedControl setSelectedSegmentIndex:0];
            }
            else {
                [self.nationalitySegmentedControl setSelectedSegmentIndex:1];
                self.tcknoLabel.text = @"Pasaport No";
            }
            
            self.tcknoTextField.text = [esProfile valueForKey:@"ZZTCKN"];
            
            self.driverLicenseNoTextField.text = [esProfile valueForKey:@"EHLIYET_NO"];
            self.driverLicenseLocationTextField.text = [esProfile valueForKey:@"EHLIYET_ALISYERI"];
            
            NSString *driverLicenseDate = [esProfile valueForKey:@"EHLIYET_TARIHI"];
            if (![driverLicenseDate isEqualToString:@""] || driverLicenseDate != nil) {
                self.driverLicenseDatePicker.date = [formatter dateFromString:driverLicenseDate];
            }
            
            NSString *driverLicenseType = [esProfile valueForKey:@"EHLIYET_SINIFI"];
            
            if ([driverLicenseType isEqualToString:@"B"]) {
                self.driverLicenseTypeSegmentedControl.selectedSegmentIndex = 0;
            }
            
            NSDictionary *tables = [response objectForKey:@"TABLES"];
            NSDictionary *adressTable = [tables objectForKey:@"ZGET_PROFILBILGI_ADRS_ST"];
            
            for (NSDictionary *adress in adressTable) {
                if ([[adress valueForKey:@"ADRES_TYPE"] isEqualToString:@"1"]) {
                    NSString *country = [adress valueForKey:@"COUNTRY"];
                    
                    if (country != nil && ![country isEqualToString:@""]) {
                        for (NSArray *temp in countryArray) {
                            if ([[temp objectAtIndex:0] isEqualToString:country]) {
                                self.selectedCountry = temp;
                                self.countryLabel.text = self.selectedCountry[1];
                                break;
                            }
                        }
                    }
                    
                    NSString *city = [adress valueForKey:@"REGION"];
                    
                    if (city != nil && ![city isEqualToString:@""]) {
                        for (NSArray *temp in cityArray) {
                            if ([[temp objectAtIndex:0] isEqualToString:self.selectedCountry[0]] && [[temp objectAtIndex:1] isEqualToString:city]) {
                                self.selectedCity = temp;
                                self.cityLabel.text = self.selectedCity[2];
                                break;
                            }
                        }
                    }
                    
                    NSString *county = [adress valueForKey:@"CITY_NO"];
                    
                    if (county != nil && ![county isEqualToString:@""]) {
                        for (NSArray *temp in countyArray) {
                            if ([[temp objectAtIndex:0] isEqualToString:self.selectedCountry[0]] && [[temp objectAtIndex:1] isEqualToString:self.selectedCity[1]] &&[[temp objectAtIndex:2] isEqualToString:county]) {
                                self.selectedCounty = temp;
                                self.countyLabel.text = self.selectedCounty[3];
                                break;
                            }
                        }
                    }
                    
                    self.adressTextField.text = [adress valueForKey:@"ADRESS"];
                    
                    
                    // Telefon numaraları
                    NSDictionary *phoneNumbers = [tables objectForKey:@"ZNET_INT_016"];
                    NSMutableArray *tempPhoneNumbers = [NSMutableArray new];
                    
                    for (NSDictionary *temp in phoneNumbers) {
                        NSString *number = [temp valueForKey:@"TELNO"];
                        NSString *isDefault = [temp valueForKey:@"C_STANDART"];
                        NSString *country = [temp valueForKey:@"TELNO_ULKE"];
                        
                        NSArray *phoneLine = @[number, isDefault, country];
                        
                        if ([isDefault isEqualToString:@"X"]) {
                            self.mobilePhoneTextField.text = number;
                        }
                        else {
                            self.mobilePhone2TextField.text = number;
                        }
                        
                        [tempPhoneNumbers addObject:phoneLine];
                    }
                    
                    self.phoneNumbersArray = tempPhoneNumbers;
                    
                    // Email adresleri
                    NSDictionary *emails = [tables objectForKey:@"ZNET_INT_015"];
                    NSMutableArray *emailAdresses = [NSMutableArray new];
                    
                    for (NSDictionary *temp in emails) {
                        NSString *email = [temp valueForKey:@"EMAIL"];
                        NSString *isDefault = [temp valueForKey:@"C_STANDART"];
                        
                        NSArray *emailLine = @[email, isDefault];
                        
                        if ([isDefault isEqualToString:@"X"]) {
                            self.emailTextField.text = email;
                        }
                        else {
                            self.email2TextField.text = email;
                        }
                        
                        [emailAdresses addObject:emailLine];
                    }
                    
                    self.mailsArray = emailAdresses;
                }
            }
            
            self.secretQuestion = [esProfile valueForKey:@"GUVENSORU"];
            self.secretQuestionsAnswer = [esProfile valueForKey:@"GUVENCEVAP"];
            self.garentaTLTextField.text = [[[ApplicationProperties getUser] garentaTl] stringValue];
            self.partnerNo = [[ApplicationProperties getUser] kunnr];
        }
        else {
            alertString = @"Kullanıcı bilgileri alınırken hata oluştu.";
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    if (![alertString isEqualToString:@""]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
            
            [alert show];
        });
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self releaseAllTextFields];
    self.tempMailAdress = nil;
    self.tempPhoneNumber = nil;
    self.tempIsStandart = @"";
    
    if (indexPath.section == 3) {
        self.selectedRow = indexPath.row;
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Seçiniz.." delegate:self cancelButtonTitle:@"Geri" destructiveButtonTitle:nil otherButtonTitles:@"Değiştir", @"Sil",  nil];
        [action showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Değiştir
    if (buttonIndex == 0) {
        if (self.selectedRow == 0) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Telefon numaranızı giriniz.." message:@"" delegate:self cancelButtonTitle:@"Geri" otherButtonTitles:@"Tamam", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[alert textFieldAtIndex:0] setText:self.mobilePhoneTextField.text];
            [[alert textFieldAtIndex:0] setPlaceholder:@"5xxxxxxxxx"];
            [alert setTag:3];
            
            if ([self.mobilePhoneTextField.text isEqualToString:@""]) {
                self.tempPhoneProcessType = @"I";
            }
            else {
                self.tempPhoneProcessType = @"U";
            }
            
            self.tempIsStandart = @"X";
            
            [alert show];
        }
        if (self.selectedRow == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Telefon numaranızı giriniz.." message:@"" delegate:self cancelButtonTitle:@"Geri" otherButtonTitles:@"Tamam", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[alert textFieldAtIndex:0] setText:self.mobilePhone2TextField.text];
            [[alert textFieldAtIndex:0] setPlaceholder:@"5xxxxxxxxx"];
            [alert setTag:3];
            
            if ([self.mobilePhone2TextField.text isEqualToString:@""]) {
                self.tempPhoneProcessType = @"I";
            }
            else {
                self.tempPhoneProcessType = @"U";
            }
            
            self.tempIsStandart = @"";
            
            [alert show];
        }
        if (self.selectedRow == 2) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail adresinizi giriniz.." message:@"" delegate:self cancelButtonTitle:@"Geri" otherButtonTitles:@"Tamam", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[alert textFieldAtIndex:0] setText:self.emailTextField.text];
            [alert setTag:4];
            
            if ([self.emailTextField.text isEqualToString:@""]) {
                self.tempPhoneProcessType = @"I";
            }
            else {
                self.tempPhoneProcessType = @"U";
            }
            
            self.tempIsStandart = @"X";
            
            [alert show];
        }
        if (self.selectedRow == 3) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail adresinizi giriniz.." message:@"" delegate:self cancelButtonTitle:@"Geri" otherButtonTitles:@"Tamam", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[alert textFieldAtIndex:0] setText:self.email2TextField.text];
            [alert setTag:4];
            
            if ([self.email2TextField.text isEqualToString:@""]) {
                self.tempPhoneProcessType = @"I";
            }
            else {
                self.tempPhoneProcessType = @"U";
            }
            
            self.tempIsStandart = @"";
            
            [alert show];
        }
    }
    // Sil
    else if (buttonIndex == 1) {
        
        // Asıl cep no
        if (self.selectedRow == 0) {
            if ([self.mobilePhone2TextField.text isEqualToString:@""]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Cep telefonunuzu silmek için önce yeni bir numara eklemeniz gerekmektedir" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                [alert show];
            }
            else {
                if ([self.mobilePhoneTextField.text isEqualToString:@""]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Seçtiğiniz cep telefonu bulunmadığından dolayı silinemez" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                    [alert show];
                }
                else {
                    [self modifyPhoneNumber:self.mobilePhoneTextField.text andProcessType:@"D" andPhoneCheck:@""];
                }
            }
        }
        // Yedek cep no
        if (self.selectedRow == 1) {
            if ([self.mobilePhone2TextField.text isEqualToString:@""]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Seçtiğiniz cep telefonu bulunmadığından dolayı silinemez" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                [alert show];
            }
            else {
                [self modifyPhoneNumber:self.mobilePhone2TextField.text andProcessType:@"D" andPhoneCheck:@""];
            }
        }
        // Asıl mail
        if (self.selectedRow == 2) {
            if ([self.email2TextField.text isEqualToString:@""]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Mail adresinizi silmek için önce yeni bir mail adresi eklemeniz gerekmektedir" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                [alert show];
            }
            else {
                [self modifyMailAdress:self.emailTextField.text andProcessType:@"D" andMailCheck:@""];
            }
        }
        // Yedek mail
        if (self.selectedRow == 3) {
            if ([self.email2TextField.text isEqualToString:@""]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Seçtiğiniz mail adresi bulunmadığından dolayı silinemez" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                [alert show];
            }
            else {
                [self modifyMailAdress:self.email2TextField.text andProcessType:@"D" andMailCheck:@""];
            }
        }
    }
}

- (void)modifyPhoneNumber:(NSString *)phoneNumber andProcessType:(NSString *)processType andPhoneCheck:(NSString *)phoneCheck {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        UIAlertView *alert = [[UIAlertView alloc] init];
        NSString *alertString = @"";
        [alert setTitle:@"Uyarı"];
        
        @try {
            SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZNET_UPDATE_BP_TELNO_EMAIL"];
            
            NSString *tableName = @"IT_TELNO";
            NSArray *columns = @[@"TELNO", @"C_STANDART", @"STATU", @"TELNO_ULKE"];
            NSArray *value = @[phoneNumber, self.tempIsStandart, processType, @"TR"];
            NSArray *values = @[value];
            
            [handler addImportParameter:@"IV_MUSTERINO" andValue:[[ApplicationProperties getUser] kunnr]];
            [handler addImportParameter:@"IV_CEPTEL_CONFIRM" andValue:phoneCheck];
            [handler addTableForImport:tableName andColumns:columns andValues:values];
            [handler addTableForReturn:@"ET_RETURN"];
            
            NSDictionary *response = [handler prepCall];
            
            if (response != nil) {
                NSDictionary *export = [response objectForKey:@"EXPORT"];
                
                NSString *result = [export valueForKey:@"EV_SUBRC"];
                
                if (![result isEqualToString:@"0"]) {
                    
                    NSString *evPhoneCheck = [export valueForKey:@"EV_CEPTEL_CHECK"];
                    
                    if ([evPhoneCheck isEqualToString:@"X"]) {
                        alertString = @"Girmiş olduğunuz telefon numarası başka bir müşterimize ait gözükmektedir. Devam derseniz sizin kullanıcınıza aktarılıcaktır.";
                        
                        [alert addButtonWithTitle:@"Geri"];
                        [alert addButtonWithTitle:@"Devam"];
                        [alert setTag:2];
                    }
                    else {
                        NSDictionary *tables = [response objectForKey:@"TABLES"];
                        NSDictionary *etReturn = [tables objectForKey:@"BAPIRET2"];
                        
                        for (NSDictionary *temp in etReturn) {
                            if ([[temp valueForKey:@"TYPE"] isEqualToString:@"E"]) {
                                alertString = [temp valueForKey:@"MESSAGE"];
                            }
                        }
                        
                        if ([alertString isEqualToString:@""]) {
                            alertString = @"Güncelleme sırasında hata alındı. Lütfen tekrar deneyiniz";
                        }

                    }
                }
                else {
                    
                    if ([self.tempPhoneProcessType isEqualToString:@"D"]) {
                        if (self.selectedRow == 0) {
                            self.mobilePhoneTextField.text = @"";
                        }
                        else if (self.selectedRow == 1) {
                            self.mobilePhone2TextField.text = @"";
                        }
                    }
                    else {
                        if (self.selectedRow == 0) {
                            self.mobilePhoneTextField.text = self.tempPhoneNumber;
                        }
                        else if (self.selectedRow == 1) {
                            self.mobilePhone2TextField.text = self.tempPhoneNumber;
                        }
                    }
                    
                    alertString = @"Bilgileriniz başarı ile güncellenmiştir";
                }
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        if ([alert tag] == 0) {
            [alert addButtonWithTitle:@"Tamam"];
        }
        else {
            [alert setDelegate:self];
        }
        
        [alert setMessage:alertString];
        [alert show];
        
        [[self tableView] reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (void)modifyMailAdress:(NSString *)mailAdress andProcessType:(NSString *)processType andMailCheck:(NSString *)mailCheck {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        UIAlertView *alert = [[UIAlertView alloc] init];
        NSString *alertString = @"";
        [alert setTitle:@"Uyarı"];
        
        @try {
            SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZNET_UPDATE_BP_TELNO_EMAIL"];
            
            NSString *tableName = @"IT_EMAIL";
            NSArray *columns = @[@"EMAIL", @"C_STANDART", @"STATU", @"IS_AGROUP"];
            NSArray *value = @[mailAdress, self.tempIsStandart, processType, @""];
            NSArray *values = @[value];
            
            [handler addImportParameter:@"IV_MUSTERINO" andValue:[[ApplicationProperties getUser] kunnr]];
            [handler addImportParameter:@"IV_EMAIL_CONFIRM" andValue:mailCheck];
            [handler addTableForImport:tableName andColumns:columns andValues:values];
            [handler addTableForReturn:@"ET_RETURN"];
            
            NSDictionary *response = [handler prepCall];
            
            if (response != nil) {
                NSDictionary *export = [response objectForKey:@"EXPORT"];
                
                NSString *result = [export valueForKey:@"EV_SUBRC"];
                
                if (![result isEqualToString:@"0"]) {
                    
                    NSString *evMailCheck = [export valueForKey:@"EV_MAIL_CHECK"];
                    
                    if ([evMailCheck isEqualToString:@"X"]) {
                        alertString = @"Girmiş olduğunuz mail adresi başka bir müşterimize ait gözükmektedir. Devam derseniz sizin kullanıcınıza aktarılıcaktır.";
                        
                        [alert addButtonWithTitle:@"Geri"];
                        [alert addButtonWithTitle:@"Devam"];
                        [alert setTag:6];
                    }
                    else {
                        NSDictionary *tables = [response objectForKey:@"TABLES"];
                        NSDictionary *etReturn = [tables objectForKey:@"BAPIRET2"];
                        
                        for (NSDictionary *temp in etReturn) {
                            if ([[temp valueForKey:@"TYPE"] isEqualToString:@"E"]) {
                                alertString = [temp valueForKey:@"MESSAGE"];
                            }
                        }
                        
                        if ([alertString isEqualToString:@""]) {
                            alertString = @"Güncelleme sırasında hata alındı. Lütfen tekrar deneyiniz";
                        }
                        
                    }
                }
                else {
                    
                    if ([self.tempPhoneProcessType isEqualToString:@"D"]) {
                        if (self.selectedRow == 2) {
                            self.emailTextField.text = @"";
                        }
                        else if (self.selectedRow == 3) {
                            self.email2TextField.text = @"";
                        }
                    }
                    else {
                        if (self.selectedRow == 2) {
                            self.emailTextField.text = self.tempMailAdress;
                        }
                        else if (self.selectedRow == 3) {
                            self.email2TextField.text = self.tempMailAdress;
                        }
                    }
                    
                    alertString = @"Bilgileriniz başarı ile güncellenmiştir";
                }
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        if ([alert tag] == 0) {
            [alert addButtonWithTitle:@"Tamam"];
        }
        else {
            [alert setDelegate:self];
        }
        
        [alert setMessage:alertString];
        [alert show];
        
        [[self tableView] reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (IBAction)changePassword:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Giriniz.." message:@"Lütfen eski ve yeni şifrenizi giriniz" delegate:self cancelButtonTitle:@"Geri" otherButtonTitles:@"Tamam", nil];
    [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [[alert textFieldAtIndex:0] setSecureTextEntry:YES];
    [[alert textFieldAtIndex:0] setPlaceholder:@"Eski Şireniz..."];
    [[alert textFieldAtIndex:1] setSecureTextEntry:YES];
    [[alert textFieldAtIndex:1] setPlaceholder:@"Yeni Şifreniz..."];
    [alert setTag:7];
    [alert show];
}

- (void)updateUserPasswordAtSAP:(NSString *)oldPassword andNewPassword:(NSString *)newPassword {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSString *alertString = @"";
        
        @try {
            SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZNET_UPDATE_USER_PASSWORD"];
            
            NSData *oldPasswordData = [oldPassword dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
            NSString *oldPasswordEncoded = [oldPasswordData base64EncodedStringWithOptions:0];
            
            NSData *newPasswordData = [newPassword dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
            NSString *newPasswordEncoded = [newPasswordData base64EncodedStringWithOptions:0];
            
            [handler addImportParameter:@"IV_PARTNER" andValue:[[ApplicationProperties getUser] kunnr]];
            [handler addImportParameter:@"IV_PASSWORD" andValue:oldPasswordEncoded];
            [handler addImportParameter:@"IV_NEWPASSWORD" andValue:newPasswordEncoded];
            [handler addTableForReturn:@"ET_RETURN"];
            
            NSDictionary *response = [handler prepCall];
            
            if (response != nil) {
                NSDictionary *export = [response objectForKey:@"EXPORT"];
                
                NSString *result = [export valueForKey:@"EV_SUBRC"];
                
                if (![result isEqualToString:@"0"]) {
                    
                    NSDictionary *tables = [response objectForKey:@"TABLES"];
                    NSDictionary *etReturn = [tables objectForKey:@"BAPIRET2"];
                        
                    for (NSDictionary *temp in etReturn) {
                        if ([[temp valueForKey:@"TYPE"] isEqualToString:@"E"]) {
                                alertString = [temp valueForKey:@"MESSAGE"];
                        }
                    }
                        
                    if ([alertString isEqualToString:@""]) {
                        alertString = @"Güncelleme sırasında hata alındı. Lütfen tekrar deneyiniz";
                    }
                        
                }
                else {
                    [[NSUserDefaults standardUserDefaults] setObject:newPasswordEncoded forKey:@"PASSWORD"];
                    alertString = @"Bilgileriniz başarı ile güncellenmiştir";
                }
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
        [alert show];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (void)releaseAllTextFields {
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

- (IBAction)updateButtonPressed:(id)sender {
    
    NSString *alertString = @"";
    
    if (self.selectedCountry == nil)
        alertString =  @"Ülkenin seçilmesi gerekmektedir";
    else if (self.selectedCity == nil)
        alertString = @"Şehrin seçilmesi gerekmektedir";
    else if ([[self.selectedCountry objectAtIndex:0] isEqualToString:@"TR"] && self.selectedCounty == nil)
        alertString = @"İlçenin seçilmesi gerekmektedir";
    else if ([self.adressTextField.text isEqualToString:@""])
        alertString =  @"Adres alanının doldurulması gerekmektedir";
    else {
        [self checkPhoneNumberValidation];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 1) {
        if (buttonIndex == 1) {
            NSString *alertText = [alertView textFieldAtIndex:0].text;
            
            if ([alertText isEqualToString:self.validationCode]) {
                
                if (self.tempPhoneNumber != nil) {
                    [self modifyPhoneNumber:self.tempPhoneNumber andProcessType:self.tempPhoneProcessType andPhoneCheck:@""];
                }
                else {
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        
                        NSString *alertString = [self updateUserAtSAP];
                        
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                        [alert show];
                    });
                }
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Girdiğiniz kod ile gönderilen kod uyuşmamaktadır" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    if ([alertView tag] == 2) {
        if (buttonIndex == 1) {
            [self modifyPhoneNumber:self.tempPhoneNumber andProcessType:self.tempPhoneProcessType andPhoneCheck:@"X"];
        }
    }
    if ([alertView tag] == 3) {
        if (buttonIndex == 1) {
            self.tempPhoneNumber = nil;

            NSString *tempPhoneNumber = [[alertView textFieldAtIndex:0] text];
            
            if (tempPhoneNumber == nil || [tempPhoneNumber isEqualToString:@"" ]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Girdiğiniz telefon numarası uygun değildir" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                [alert show];
            }
            else {
                self.tempPhoneNumber = tempPhoneNumber;
                [self checkPhoneNumberValidation];
            }
        }
    }
    if ([alertView tag] == 4) {
        if (buttonIndex == 1) {
            self.tempMailAdress = nil;
            
            NSString *tempMailAdress = [[alertView textFieldAtIndex:0] text];
            
            if (tempMailAdress == nil || [tempMailAdress isEqualToString:@""]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Girdiğiniz mail adresi uygun değildir" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                [alert show];
            }
            else {
                self.tempMailAdress = tempMailAdress;
                [self checkEmailVerificationCode];
            }
        }
    }
    if ([alertView tag] == 5) {
        if (buttonIndex == 1) {
            NSString *alertText = [alertView textFieldAtIndex:0].text;
            
            if ([alertText isEqualToString:self.validationCode]) {
                
                if (self.tempMailAdress != nil) {
                    [self modifyMailAdress:self.tempMailAdress andProcessType:self.tempPhoneProcessType andMailCheck:@""];
                }
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Girdiğiniz kod ile gönderilen kod uyuşmamaktadır" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    if ([alertView tag] == 6) {
        if (buttonIndex == 1) {
            [self modifyMailAdress:self.tempMailAdress andProcessType:self.tempPhoneProcessType andMailCheck:@"X"];
        }
    }
    if ([alertView tag] == 7) {
        if (buttonIndex == 1) {
            NSString *oldPassword = [alertView textFieldAtIndex:0].text;
            NSString *newPassword = [alertView textFieldAtIndex:1].text;
            
            if (oldPassword == nil || [oldPassword isEqualToString:@""]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Şifrenizi değiştirmek için eski şifrenizi girmeniz gerekmektedir" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                [alert show];
            }
            else if (newPassword == nil || [newPassword isEqualToString:@""] || newPassword.length < 5 ) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Şifreniz en az 6 karakterli olabilir. Lütfen tekrar deneyiniz" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                [alert show];
            }
            else {
                [self updateUserPasswordAtSAP:oldPassword andNewPassword:newPassword];
            }
        }
    }
}

- (void)checkPhoneNumberValidation {
    
    NSString *generatedCode = [SMSSoapHandler generateCode];
    
    if (generatedCode == nil || [generatedCode isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"SMS gönderilemedi, lütfen tekrar deneyiniz" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else {
        self.validationCode = generatedCode;
        
        NSString *phoneNumber = @"";
        
        if (self.tempPhoneNumber != nil) {
            phoneNumber = self.tempPhoneNumber;
        }
        else {
            phoneNumber = self.mobilePhoneTextField.text;
        }
        
        BOOL success = [SMSSoapHandler sendSMSMessage:self.validationCode toNumber:phoneNumber];
        
        if (!success) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"SMS gönderilemedi, lütfen tekrar deneyiniz" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    
    self.timerAlertView = [[UIAlertView alloc] initWithTitle:@"Uyarı"
                                                     message:@"Lütfen Telefonunuza gelen konfirmasyon kodunu 60 saniye içinde giriniz"
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
    self.timerAlertView.message = [NSString stringWithFormat:@"Lütfen Telefonunuza gelen konfirmasyon kodunu %d saniye içinde giriniz", self.alertTimer];
    
    if (self.alertTimer == 0) {
        [self.timer invalidate];
        [self.timerAlertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}


- (void)checkEmailVerificationCode {
    
    NSString *generatedCode = [SMSSoapHandler generateCode];
    
    if (generatedCode == nil || [generatedCode isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Mail gönderilemedi, lütfen tekrar deneyiniz" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else {
        self.validationCode = generatedCode;
        
        NSString *email = @"";
        
        if (self.tempMailAdress != nil) {
            email = self.tempMailAdress;
        }
        else {
            email = self.emailTextField.text; // müşterinin email adresi
        }
        
        BOOL success = [MailSoapHandler sendVerificationMessage:generatedCode toMail:email withFirstname:self.nameTextField.text andLastname:self.surnameTextField.text];
        
        if (!success) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Mail gönderilemedi, lütfen tekrar deneyiniz" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    
    self.timerAlertView = [[UIAlertView alloc] initWithTitle:@"Uyarı"
                                                     message:@"Lütfen mail adresinize gelen konfirmasyon kodunu 60 saniye içinde giriniz"
                                                    delegate:self
                                           cancelButtonTitle:@"Geri"
                                           otherButtonTitles:@"Tamam", nil];
    [self.timerAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [self.timerAlertView setTag:5];
    [self.timerAlertView show];
    
    self.alertTimer = 60;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(updateEmailAlert:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)updateEmailAlert:(id)sender {
    self.alertTimer--;
    self.timerAlertView.message = [NSString stringWithFormat:@"Lütfen mail'inize gelen konfirmasyon kodunu %d saniye içinde giriniz", self.alertTimer];
    
    if (self.alertTimer == 0) {
        [self.timer invalidate];
        [self.timerAlertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}

- (NSString *)updateUserAtSAP {
    
    NSString *alertString = @"";
    
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZNET_UPDATE_POT_MUSTERI"];
        
        NSArray *isInputColumns = @[@"MUSTERINO", @"FIRSTNAME", @"MIDDLENAME", @"LASTNAME", @"BIRTHDATE", @"TCKN", @"VERGIDAIRESI", @"VERGINO", @"MTYPE", @"NICKNAME", @"PASSWORD", @"KANALTURU", @"UYRUK", @"ULKE", @"EHLIYETNO", @"EHLIYETTARIHI", @"PASAPORTNO", @"SMSFLAG", @"SALES_ORGANIZATION", @"DISTRIBUTION_CHANNEL", @"DIVISION", @"CINSIYET", @"EHLIYET_ALISYERI", @"EHLIYET_SINIFI", @"GUVENSORU", @"GUVENSORU_TXT", @"GUVENCEVAP"];
        
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
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        
        NSString *gender = @"";
        
        if (self.genderSegmentedControl.selectedSegmentIndex == 0) {
            gender = @"1";
        }
        else if (self.genderSegmentedControl.selectedSegmentIndex == 1) {
            gender = @"2";
        }
        
        NSString *driverLicenseDate = @"";
        
        if (![self.driverLicenseNoTextField.text isEqualToString:@""]) {
            driverLicenseDate = [formatter stringFromDate:[self.driverLicenseDatePicker date]];
        }
        
        NSString *driverLicenseType = @"";
        
        if (self.driverLicenseTypeSegmentedControl.selectedSegmentIndex != -1) {
            driverLicenseType = [self.driverLicenseTypeSegmentedControl titleForSegmentAtIndex:self.driverLicenseTypeSegmentedControl.selectedSegmentIndex];
        }
        
        NSArray *isInputValues = @[[[ApplicationProperties getUser] kunnr], self.nameTextField.text, self.middleNameTextField.text, self.surnameTextField.text, [formatter stringFromDate:self.birthdayDatePicker.date], tcknNo, @"", @"", @"X", @"", @"", @"Z07", nationality, self.selectedCountry[0], self.driverLicenseNoTextField.text, driverLicenseDate, passportNo, @"X", @"3063", @"33", @"65", gender, self.driverLicenseLocationTextField.text, driverLicenseType, self.secretQuestion, @"", self.secretQuestionsAnswer];
        
        [handler addImportStructure:@"IS_INPUT" andColumns:isInputColumns andValues:isInputValues];
        
        NSArray *itAdresColumns = @[@"ADRES_TYPE", @"ILKODU", @"ILCEKOD", @"ADRESS", @"ULKE"];
        
        NSString *cityCode = @"";
        
        if (self.selectedCity != nil) {
            cityCode = self.selectedCity[1];
        }
        
        NSString *countyCode = @"";
        
        if (self.selectedCounty != nil) {
            countyCode = self.selectedCounty[2];
        }
        
        NSArray *itAdresValue = @[@"1", cityCode, countyCode, self.adressTextField.text, self.selectedCity[0]];
        NSArray *itAdresValues = @[itAdresValue];
        
        [handler addTableForImport:@"IT_ADRES" andColumns:itAdresColumns andValues:itAdresValues];
        [handler addTableForReturn:@"ET_RETURN"];
        
        NSDictionary *response = [handler prepCall];
        
        if (response != nil) {
            NSDictionary *export = [response objectForKey:@"EXPORT"];
            
            NSString *result = [export valueForKey:@"EV_SUBRC"];
            
            if (![result isEqualToString:@"0"]) {
                NSDictionary *tables = [response objectForKey:@"TABLES"];
                NSDictionary *etReturn = [tables objectForKey:@"BAPIRET2"];
                
                for (NSDictionary *temp in etReturn) {
                    if ([[temp valueForKey:@"TYPE"] isEqualToString:@"E"]) {
                        alertString = [temp valueForKey:@"MESSAGE"];
                    }
                }
                
                if ([alertString isEqualToString:@""]) {
                    alertString = @"Güncelleme sırasında hata alındı. Lütfen tekrar deneyiniz";
                }
            }
            else {
                alertString = @"Bilgileriniz başarı ile güncellenmiştir";
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    return alertString;
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
    if ([[segue identifier] isEqualToString:@"ToLoginVCSegue"]) {
        LoginVC *loginVC = (LoginVC *)[segue destinationViewController];
        loginVC.shouldNotPop = YES;
        loginVC.leftButton = [[self navigationItem] leftBarButtonItem];
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


@end
