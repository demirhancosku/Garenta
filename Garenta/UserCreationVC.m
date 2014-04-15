//
//  UserCreationVC.m
//  Garenta
//
//  Created by Ata  Cengiz on 27.02.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "UserCreationVC.h"
#import "iToast.h"
#import "IDController.h"

@interface UserCreationVC ()

@end

@implementation UserCreationVC
@synthesize adressTextField, birthdayTextField, countryTextField, mobileTextField, headerLabel, emailTextField, nameTextField, passwordTextField, password2TextField, scrollView, secretQuestionTextField, secretAnswerTextField, surnameTextField, tcknNoTextField, nationSegmentedControl;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    bigData = [[NSMutableData alloc] init];
    cityArray = [[NSMutableArray alloc] init];
    countryArray = [[NSMutableArray alloc] init];
    countyArray = [[NSMutableArray alloc] init];
    
    secretQuestionsArray = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self prepareScreen];
    [self getLocationInformationFromSAP];
    [self getSecretQuestionsFromSAP];
}

- (void)prepareScreen
{
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, 550)];
    
    [nationSegmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDate * currentDate = [NSDate date];
    NSDateComponents * comps = [[NSDateComponents alloc] init];
    [comps setYear: -18];
    NSDate * maxDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
    [comps setYear: -100];
    NSDate * minDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
    
    
    datePicker = [[UIDatePicker alloc] init];
    [datePicker setFrame:CGRectMake(0, self.view.frame.size.height - datePicker.frame.size.height, datePicker.frame.size.width, datePicker.frame.size.height)];
    [datePicker setBackgroundColor:[ApplicationProperties getGrey]];
    [datePicker setMaximumDate:maxDate];
    [datePicker setMinimumDate:minDate];
    [datePicker setDate:maxDate];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker addTarget:self action:@selector(dateIsChanged:) forControlEvents:UIControlEventValueChanged];
    [[self view] addSubview:datePicker];
    [datePicker setHidden:YES];
    
    userCreationPickerView = [[UIPickerView alloc] initWithFrame:[datePicker frame]];
    [userCreationPickerView setDelegate:self];
    [userCreationPickerView setDataSource:self];
    [userCreationPickerView setBackgroundColor:[UIColor lightGrayColor]];
    [[self view] addSubview:userCreationPickerView];
    [userCreationPickerView setHidden:YES];
    
    barButton = [[UIBarButtonItem alloc] initWithTitle:@"Üye Ol" style:UIBarButtonItemStyleBordered target:self action:@selector(resume)];
    
    [[self navigationItem] setRightBarButtonItem:barButton];
    
    [self registerForKeyboardNotifications];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [scrollView addGestureRecognizer:singleFingerTap];
    
    [self setTextFieldsCorners];
}

- (void)resume
{
    // ATA burda kontroller yapılıcak
    NSString *alertString = @"";
    IDController *control = [[IDController alloc] init];
    
    NSDateFormatter *bdayFormatter = [[NSDateFormatter alloc] init];
    [bdayFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *birthdayDate = [bdayFormatter dateFromString:[birthdayTextField text]];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents =[gregorian components:NSYearCalendarUnit fromDate:birthdayDate];
    NSString *birtdayYearString = [NSString stringWithFormat:@"%li", (long)weekdayComponents.year];
    
    if ([nameTextField.text isEqualToString:@""])
        alertString =  @"Ad alanının doldurulması gerekmektedir";
    else if ([surnameTextField.text isEqualToString:@""])
        alertString =  @"Soyad alanının doldurulması gerekmektedir";
    else if ([birthdayTextField.text isEqualToString:@""])
        alertString =  @"Doğum Tarihi alanının doldurulması gerekmektedir";
    else if (!( [nationSegmentedControl selectedSegmentIndex] == 0 || [nationSegmentedControl selectedSegmentIndex] == 1) )
        alertString = @"Uyruk alanının seçilmesi gerekmektedir";
    else if ([tcknNoTextField.text isEqualToString:@""])
        alertString =  @"T.C. Kimlik No alanının doldurulması gerekmektedir";
    else if ([tcknNoTextField.text length] != 11)
        alertString =  @"T.C: Kimlik No alanının 11 Karakter olması gerekmektedir";
    else if ([control idChecker:[tcknNoTextField text] andName:[[nameTextField text] uppercaseStringWithLocale:[NSLocale localeWithLocaleIdentifier:@"tr"]] andSurname:[[surnameTextField text] uppercaseStringWithLocale:[NSLocale localeWithLocaleIdentifier:@"tr"]] andBirthYear:birtdayYearString] && !([nationSegmentedControl selectedSegmentIndex] == 1))
        alertString = @"Girdiğiniz T.C. Kimlik No Sistemde bulunamamıştır.";
    else if ([countryTextField.text isEqualToString:@""])
        alertString =  @"Ülkenin seçilmesi gerekmektedir";
    else if ([adressTextField.text isEqualToString:@""])
        alertString =  @"Adres alanının doldurulması gerekmektedir";
    else if ([emailTextField.text isEqualToString:@""])
        alertString =  @"E-mail alanının doldurulması gerekmektedir";
    else if ([mobileTextField.text isEqualToString:@""])
        alertString =  @"Cep Telefonu alanının doldurulması gerekmektedir";
    else if ([passwordTextField.text isEqualToString:@""])
        alertString =  @"Şifre alanının doldurulması gerekmektedir";
    else if ([password2TextField.text isEqualToString:@""])
        alertString =  @"Şifre(Tekrar) alanının doldurulması gerekmektedir";
    else if (![passwordTextField.text isEqualToString:[password2TextField text]])
        alertString =  @"Şifre alanlarının aynı olması gerekmektedir";
    else if ([secretQuestionTextField.text isEqualToString:@""])
        alertString =  @"Gizli Sorunun seçilmesi gerekmektedir";
    else if ([secretAnswerTextField.text isEqualToString:@""])
        alertString =  @"Gizli soru cevabı alanının doldurulması gerekmektedir";
    
    if (![alertString isEqualToString:@""])
    {
        iToastSettings *theSettings = [iToastSettings getSharedSettings];
        [theSettings setGravity:iToastGravityCenter];
        [theSettings setFontSize:16.0];
        [[iToast makeText:alertString] show];
        
        return;
    }
    
    NSCharacterSet *charactersToRemove = [NSCharacterSet characterSetWithCharactersInString:@"() "];
    NSString *trimmedReplacement = [[mobileTextField.text componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
    
    // Ata sonra atcaz etcez
    User *createdUser = [[User alloc] init];
    [createdUser setName:[nameTextField text]];
    [createdUser setSurname:[surnameTextField text]];
    [createdUser setBirthday:birthdayDate];
    [createdUser setTckno:[tcknNoTextField text]];
    [createdUser setCountry:[countryTextField text]]; // buna bakıcam
    [createdUser setAddress:[adressTextField text]];
    [createdUser setEmail:[emailTextField text]];
    [createdUser setMobile:trimmedReplacement];
    [createdUser setPassword:[passwordTextField text]];
    
    //tc ise tr değil ise boş
    NSString *nationality = @"";
    NSString *pasaportNo = @"";
    
    if ([nationSegmentedControl selectedSegmentIndex] == 0)
        nationality = @"TR";
    else
        pasaportNo = [tcknNoTextField text];
    
    NSString *mtype = @"X";
    NSString *distributionChannel = @"33";
    NSString *salesOrganization = @"3063";
    NSString *division = @"65";
    NSString *smsFlag = @"";
    NSString *kanalTuru = @"Z01";
    
    NSString *connectionString = [NSString stringWithFormat:@"https://garentarezapp.celikmotor.com.tr:8000/sap/opu/odata/sap/ZGARENTA_CREATE_CUST_SRV_01/IS_INPUTSet(Firstname='%@',Middlename='',Lastname='%@',Birthdate=datetime'%@T00:00:00',Tckn='%@',Vergidairesi='',Vergino='',Mtype='%@',Email='%@',Telno='%@',Nickname='',Password='%@',Ilkodu='',Ilcekod='',Adress='%@',Uyruk='%@',Ulke='%@',Ehliyetno='',Ehliyettarihi='',Pasaportno='%@',Smsflag='%@',SalesOrganization='%@',DistributionChannel='%@',Division='%@',Cinsiyet='',Guvensoru='%@',GuvensoruTxt='',Guvencevap='%@',EhliyetAlisyeri='',EhliyetSinifi='',TkKartno='',Kanalturu='%@',TelnoUlke='')?$format=json", [createdUser name], [createdUser surname], [birthdayTextField text], [createdUser tckno], mtype, [createdUser email], [createdUser mobile], [createdUser password], [createdUser address], nationality, countryCode, pasaportNo, smsFlag, salesOrganization, distributionChannel, division, secretQuestionNumber, [secretAnswerTextField text], kanalTuru];
    
    [self createUserAtSAP:connectionString];
}

- (void)dateIsChanged:(id)sender{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    [birthdayTextField setText:[formatter stringFromDate:[datePicker date]]];
}

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self releaseAllTextFields];
}

- (void)releaseAllTextFields
{
    [nameTextField resignFirstResponder];
    [surnameTextField resignFirstResponder];
    [mobileTextField resignFirstResponder];
    [birthdayTextField resignFirstResponder];
    [emailTextField resignFirstResponder];
    [tcknNoTextField resignFirstResponder];
    [datePicker setHidden:YES];
    [userCreationPickerView setHidden:YES];
    [passwordTextField resignFirstResponder];
    [password2TextField resignFirstResponder];
    [secretQuestionTextField resignFirstResponder];
    [secretAnswerTextField resignFirstResponder];
    [countryTextField resignFirstResponder];
    [adressTextField resignFirstResponder];
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
    
    if (scrollPoint.y > 0)
        [scrollView setContentOffset:scrollPoint animated:YES];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [scrollView setContentOffset:CGPointZero];
}

#pragma mark - textfield delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    activeField = textField;
    
    if ([textField tag] == 1) // doğum tarihi
    {
        [self releaseAllTextFields];
        [datePicker setHidden:NO];
        
        return NO;
    }
    else if ([textField tag] == 4) // Ülke ise
    {
        [self releaseAllTextFields];
        [userCreationPickerView setTag:1];
        [userCreationPickerView setHidden:NO];
        [userCreationPickerView reloadAllComponents];
        return NO;
    }
    else if ([textField tag] == 5) // Güvenlik sorusu
    {
        [self releaseAllTextFields];
        [userCreationPickerView setTag:2];
        [userCreationPickerView setHidden:NO];
        [userCreationPickerView reloadAllComponents];
        return NO;
    }
    else
        return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self releaseAllTextFields];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField tag] == 2)
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

- (void)setTextFieldsCorners
{
    [[nameTextField layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[nameTextField layer] setBorderWidth:0.5f];
    nameTextField.layer.cornerRadius=8.0f;
    
    [[surnameTextField layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[surnameTextField layer] setBorderWidth:0.5f];
    surnameTextField.layer.cornerRadius=8.0f;
    
    [mobileTextField setTag:2];
    [[mobileTextField layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[mobileTextField layer] setBorderWidth:0.5f];
    mobileTextField.layer.cornerRadius=8.0f;
    
    [birthdayTextField setTag:1];
    [[birthdayTextField layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[birthdayTextField layer] setBorderWidth:0.5f];
    birthdayTextField.layer.cornerRadius=8.0f;
    
    [[emailTextField layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[emailTextField layer] setBorderWidth:0.5f];
    emailTextField.layer.cornerRadius=8.0f;
    
    [[tcknNoTextField layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[tcknNoTextField layer] setBorderWidth:0.5f];
    tcknNoTextField.layer.cornerRadius=8.0f;
    
    [password2TextField setSecureTextEntry:YES];
    [[password2TextField layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[password2TextField layer] setBorderWidth:0.5f];
    password2TextField.layer.cornerRadius=8.0f;
    
    [passwordTextField setSecureTextEntry:YES];
    [[passwordTextField layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[passwordTextField layer] setBorderWidth:0.5f];
    passwordTextField.layer.cornerRadius=8.0f;
    
    [[adressTextField layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[adressTextField layer] setBorderWidth:0.5f];
    adressTextField.layer.cornerRadius=8.0f;
    
    [countryTextField setTag:4];
    [[countryTextField layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[countryTextField layer] setBorderWidth:0.5f];
    countryTextField.layer.cornerRadius=8.0f;
    
    [[secretAnswerTextField layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[secretAnswerTextField layer] setBorderWidth:0.5f];
    secretAnswerTextField.layer.cornerRadius=8.0f;
    
    [secretQuestionTextField setTag:5];
    [[secretQuestionTextField layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[secretQuestionTextField layer] setBorderWidth:0.5f];
    secretQuestionTextField.layer.cornerRadius=8.0f;
}

- (void)createUserAtSAP:(NSString *)iConnectionString
{
    loaderVC = [[LoaderAnimationVC alloc] init];
    [loaderVC playAnimation:self.view];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:iConnectionString]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:20.0];
    
    createUserCon = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)getLocationInformationFromSAP
{
    loaderVC = [[LoaderAnimationVC alloc] init];
    [loaderVC playAnimation:self.view];
    
    NSString *connectionString = [ApplicationProperties getLocations];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:connectionString]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:20.0];
    
    getCountryCon = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)getSecretQuestionsFromSAP
{
    
    NSString *connectionString = @"https://garentarezapp.celikmotor.com.tr:8000/sap/opu/odata/sap/ZGARENTA_GET_SECRET_QUESTION_SRV/IS_INPUTSet(IvLangu='T')?$expand=ET_SORULARSet&$format=json";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:connectionString]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:20.0];
    
    getSecretQuestionsCon = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)space
{
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0) {
        NSLog(@"received authentication challenge");
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:[ApplicationProperties getSAPUser]
                                                                    password:[ApplicationProperties getSAPPassword]
                                                                 persistence:NSURLCredentialPersistenceForSession];
        NSLog(@"credential created");
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
        NSLog(@"responded to authentication challenge");
    }
    else {
        NSLog(@"previous authentication failure");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSError *err;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    
    
    if (connection == getCountryCon)
    {
        if (err != nil)
        {
            // Ata bu ülkeleri çeken rfc
            if (bigData == nil)
            {
                bigData = [NSMutableData dataWithData:data];
                return;
            }
            else
            {
                [bigData appendData:data];
                err = nil;
                
                jsonDict = [NSJSONSerialization JSONObjectWithData:bigData options:NSJSONReadingMutableContainers error:&err];
                
                if (err != nil)
                    return;
                else
                {
                    NSDictionary *resultDict = [jsonDict objectForKey:@"d"];
                    
                    NSString *resultString = [resultDict objectForKey:@"EvSubrc"];
                    
                    int result = [resultString intValue];
                    
                    if (result == 0)
                    {
                        NSDictionary *countryDict = [resultDict objectForKey:@"ET_ULKESet"];
                        NSDictionary *countryDictResult = [countryDict objectForKey:@"results"];
                        
                        NSDictionary *cityDict = [resultDict objectForKey:@"ET_ILSet"];
                        NSDictionary *cityDictResult = [cityDict objectForKey:@"results"];
                        
                        NSDictionary *countyDict = [resultDict objectForKey:@"ET_ILCESet"];
                        NSDictionary *countyDictResult = [countyDict objectForKey:@"results"];
                        
                        for (NSDictionary *result in countryDictResult)
                        {
                            NSArray *arr = [[NSArray alloc] initWithObjects:[result objectForKey:@"Land1"], [result objectForKey:@"Landx50"], [result objectForKey:@"Natio50"], nil];
                            [countryArray addObject:arr];
                        }
                        
                        for (NSDictionary *result in cityDictResult)
                        {
                            NSArray *arr = [[NSArray alloc] initWithObjects:[result objectForKey:@"Land1"], [result objectForKey:@"Bland"], [result objectForKey:@"Bezei"], nil];
                            [cityArray addObject:arr];
                        }
                        
                        for (NSDictionary *result in countyDictResult)
                        {
                            NSArray *arr = [[NSArray alloc] initWithObjects:[result objectForKey:@"Country"], [result objectForKey:@"Region"], [result objectForKey:@"CityCode"], [result objectForKey:@"McCity"], nil];
                            [countyArray addObject:arr];
                        }
                        
                        [userCreationPickerView reloadAllComponents];
                        
                        [loaderVC stopAnimation];
                    }
                    else
                    {
                        [loaderVC stopAnimation];
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Sistem hatası" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                        [alert show];
                    }
                }
                
            }

        }
    }
    if (connection == createUserCon)
    {
        // Bu zmob_kdk_create_pot_user
        
    }
    if (connection == getSecretQuestionsCon)
    {
        // Gizli soruları çeken rfc
        NSDictionary *resultDict = [jsonDict objectForKey:@"d"];
        
        NSString *resultString = [resultDict objectForKey:@"EReturn"];
        
        if ([resultString isEqualToString:@"T"])
        {
            NSDictionary *etSorular = [resultDict objectForKey:@"ET_SORULARSet"];
            NSDictionary *etSorularResult = [etSorular objectForKey:@"results"];
            
            for (NSDictionary *temp in etSorularResult)
            {
                NSArray *arr = [NSArray arrayWithObjects:[temp objectForKey:@"Sorutext"], [temp objectForKey:@"Sorukodu"], nil];
                [secretQuestionsArray addObject:arr];
            }
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Sistem hatası" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"gateway hatasi");
    [loaderVC stopAnimation];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Sistemde bir hata oluştu." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Pickerview Delegation Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView tag] == 1)
        return [countryArray count];
    if ([pickerView tag] == 2)
        return [secretQuestionsArray count];
    
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([pickerView tag] == 1)
        return [[countryArray objectAtIndex:row] objectAtIndex:1];
    if ([pickerView tag] == 2)
        return [[secretQuestionsArray objectAtIndex:row] objectAtIndex:0];
    
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([pickerView tag] == 1)
    {
        countryTextField.text = [[countryArray objectAtIndex:row] objectAtIndex:1];
        countryCode = [[countryArray objectAtIndex:row] objectAtIndex:0];
    }
    if ([pickerView tag] == 2)
    {
        secretQuestionTextField.text = [[secretQuestionsArray objectAtIndex:row] objectAtIndex:0];
        secretQuestionNumber = [[secretQuestionsArray objectAtIndex:row] objectAtIndex:1];
    }
}


@end
