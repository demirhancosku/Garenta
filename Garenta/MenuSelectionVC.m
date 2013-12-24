//
//  MenuSelectionVC.m
//  Garenta
//
//  Created by Kerem Balaban on 20.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "MenuSelectionVC.h"

@interface MenuSelectionVC ()

@end

@implementation MenuSelectionVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame;
{
    //    self = [super init];
    
    viewFrame = frame;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    user = [[User alloc] init];
    [self.view setBackgroundColor:[ApplicationProperties getMenuTableBackgorund]];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self prepareScreen];
}

- (void)prepareScreen
{

    [self setIphoneLayer];

    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Giriş" style:UIBarButtonItemStyleBordered target:self action:@selector(login:)];
    [[self navigationItem] setRightBarButtonItem:barButton];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [ApplicationProperties getBlack], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0], NSFontAttributeName, nil]];
    

    [classicSearch setTitleColor:[ApplicationProperties getBlack] forState:UIControlStateNormal];
    [classicSearch setTitle:@"Klasik" forState:UIControlStateNormal];
    [[classicSearch layer] setCornerRadius:5.0f];
    [[classicSearch layer] setBorderWidth:1.0f];
    [[classicSearch layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [classicSearch setTag:1];
    [classicSearch addTarget:self action:@selector(searchMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    [locationSearch setTitle:@"En Yakın Nokta" forState:UIControlStateNormal];
    [locationSearch setTitleColor:[ApplicationProperties getBlack] forState:UIControlStateNormal];
    [[locationSearch layer] setCornerRadius:5.0f];
    [[locationSearch layer] setBorderWidth:1.0f];
    [[locationSearch layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [locationSearch setTag:2];
    [locationSearch addTarget:self action:@selector(searchMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    [brandSearch setTitle:@"Markalar" forState:UIControlStateNormal];
    [brandSearch setTitleColor:[ApplicationProperties getBlack] forState:UIControlStateNormal];
    [[brandSearch layer] setCornerRadius:5.0f];
    [[brandSearch layer] setBorderWidth:1.0f];
    [[brandSearch layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [brandSearch setTag:3];
    [brandSearch addTarget:self action:@selector(searchMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:classicSearch];
    [self.view addSubview:locationSearch];
    [self.view addSubview:brandSearch];
    
    
    if ([user name] != nil) {
        [wellcome setText:[NSString stringWithFormat:@"%@ %@ %@",@"Hoşgeldiniz",[user name],[user surname]]];
        [self.view addSubview:wellcome];
        [[self navigationItem] setRightBarButtonItem:nil];
        
        
    }
    
}

- (void)setIphoneLayer
{
    
    wellcome = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.05, 0, self.view.frame.size.width * 0.6, self.view.frame.size.height * 0.1)];
    
    [wellcome setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0]];
    
    classicSearch = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.25, self.view.frame.size.height * 0.1, self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.2)];
    
    locationSearch = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.25, self.view.frame.size.height * 0.35, self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.2)];
    
    brandSearch = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.25, self.view.frame.size.height * 0.60, self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.2)];
    
}

- (void)login:(id)sender
{
    LoginVC *login = [[LoginVC alloc] initWithFrame:viewFrame andUser:(User *)user];
    [[self navigationController] pushViewController:login animated:YES];
}

- (void)searchMenu:(id)sender
{
    ClassicSearchVC *classic;
    LocationSearchVC *location;
    BrandSearchVC *brand;
    
    switch ([sender tag]) {
        case 1:
            classic = [[ClassicSearchVC alloc] initWithFrame:viewFrame];
            [[self navigationController] pushViewController:classic animated:YES];
            break;
        case 2:
            location = [[LocationSearchVC alloc] initWithFrame:viewFrame];
            [[self navigationController] pushViewController:location animated:YES];
            break;
        case 3:
//            brand = [[BrandSearchVC alloc] initWithFrame:viewFrame];
//            [[self navigationController] pushViewController:brand animated:YES];
        {
            CarGroupFilterVC *filter = [[CarGroupFilterVC alloc] init];
            [[self navigationController] pushViewController:filter animated:YES];
        }
            break;
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
