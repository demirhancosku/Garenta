//
//  CarGroupViewController.m
//  Garenta
//
//  Created by Alp Keser on 12/27/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "CarGroupViewController.h"
#import <CoreText/CoreText.h>
@interface CarGroupViewController ()

@end

@implementation CarGroupViewController
@synthesize index,carGroup,myFrame;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithFrame:(CGRect)aFrame andCarGroups:(CarGroup*)aCarGroup{
    self = [super init];
    myFrame = aFrame;
    carGroup = aCarGroup;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    [[self view] setFrame:myFrame];
    [self prepareScreen];
    
    
    //icon views
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}



- (void)prepareScreen{
    //group label
    UILabel *groupLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [groupLabel setBackgroundColor:[UIColor clearColor]];
    [groupLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0f]];
    [groupLabel  setText:carGroup.groupName];
    //TODO: aalpk test
    //[groupLabel  setText:@"A Grubu"];
    //ToDo:biraz yukariya padding
    [groupLabel setTextColor:[ApplicationProperties getOrange]];
    [groupLabel setFrame:CGRectMake(0, 0, self.view.frame.size.width, [groupLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0f ]].height)];
    [groupLabel setTextAlignment:NSTextAlignmentCenter];
    [[self view] addSubview:groupLabel];
    
    
    //Benzeri label
    
    UILabel *sampleCarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [sampleCarLabel setBackgroundColor:[UIColor clearColor]];
    [sampleCarLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:14.0f]];

    //TODO: aalpk test
    //[sampleCarLabel  setText:@"BMW 31634243242432424323424232"];
    //ToDo:biraz yukariya padding
    [sampleCarLabel setTextColor:[ApplicationProperties getBlack]];
    

    NSString *sampleCarLabelText = [NSString stringWithFormat:@"%@ ya da benzeri" ,carGroup.sampleCar.modelName];
    NSString *boldFontName = @"HelveticaNeue-Bold";
    NSRange boldedRange = NSMakeRange(0,[carGroup.sampleCar.modelName length]);
    /* TODO:aalpk burayı coz
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:sampleCarLabelText];
    

    [attrString addAttribute:kCTFontAttributeName
                       value:boldFontName
                       range:boldedRange];
    
    [attrString setAttributes:@{NSFontAttributeName: boldFontName} range:boldedRange];
//    [sampleCarLabel  setText:carGroup.sampleCar.modelName];
    [sampleCarLabel  setAttributedText:attrString];
    */
    
    
    [sampleCarLabel setText:sampleCarLabelText];
    [sampleCarLabel setFrame:CGRectMake(0, groupLabel.frame.origin.y+groupLabel.frame.size.height, self.view.frame.size.width, [sampleCarLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f]].height)];
    [sampleCarLabel setTextAlignment:NSTextAlignmentCenter];
    [[self view] addSubview:sampleCarLabel];
    
    
    //arabaimage
    float imageRatio = 125.0f / 200.0f;
    float viewHeight = self.view.frame.size.height;
    float imageHeight = (self.view.frame.size.height - (sampleCarLabel.frame.size.height +sampleCarLabel.frame.origin.y)) * 0.4;
    float imageWidth = imageHeight / imageRatio;
    float imageStartPoint = (self.view.frame.size.width - imageWidth) /2 ;
    UIImageView *carImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageStartPoint, (sampleCarLabel.frame.size.height +groupLabel.frame.size.height),imageWidth ,imageHeight)];
    [carImageView setImage:carGroup.sampleCar.image];
    [[self view] addSubview:carImageView];
    
    //icons views
    //klanın %50si aşağı
    float paddingTop = (self.view.frame.size.height - (carImageView.frame.size.height+carImageView.frame.origin.y)) *0.1;
    int iconCount = 4; // get from car
    float iconSize = self.view.frame.size.height * 0.07;
    float iconPadding = self.view.frame.size.height * 0.1;
    //%10 for each %5 for padding
    float iconStartingX = (self.view.frame.size.width - ((iconCount * iconSize) + ( iconPadding * (iconCount -1)))) / 2;
    UIImageView *iconImageView;
    UILabel *iconText;
    for (int sayac = 0; sayac < iconCount; sayac++) {
        //hangi ikon benzn,sansz,klima,kislas
        //TODO aalpk label ekle duzelt
        iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(iconStartingX, carImageView.frame.origin.y + carImageView.frame.size.height+paddingTop, iconSize, iconSize)];
        
        
        iconText = [[UILabel alloc] initWithFrame:CGRectMake(0 , iconImageView.frame.origin.y + iconImageView.frame.size.height, 0,0)];
        [iconText setBackgroundColor:[UIColor clearColor]];
        [iconText setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.0f]];
        
        
        
        
        //aalpk TODO: burasini duzlet
        switch (sayac) {
            case 0:
                [iconImageView setImage:[UIImage imageNamed:@"yakit.png"]];
                [iconText setText:carGroup.fuelName];
                break;
            case 1:
                [iconImageView setImage:[UIImage imageNamed:@"vites.png"]];
                [iconText setText:carGroup.transmissonName];
                break;
            case 2:
                [iconImageView setImage:[UIImage imageNamed:@"klima.png"]];
                [iconText setText:@"Klima"];
                break;
            case 3:
                [iconImageView setImage:[UIImage imageNamed:@"kislastik.png"]];
                [iconText setText:@"Kis Lastigi"];
                break;
            default:
                break;
        }
        
        [iconText setFrame:CGRectMake(0 , iconImageView.frame.origin.y + iconImageView.frame.size.height, [sampleCarLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:10.0f]].width,[sampleCarLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:10.0f]].height)];
        
        [iconText setCenter:CGPointMake((iconImageView.frame.origin.x + iconImageView.frame.size.width) - (iconImageView.frame.size.width /2), iconText.center.y)];
        [iconText setTextAlignment:NSTextAlignmentCenter];

        CGRect alp = iconText.frame;
        [self.view addSubview:iconImageView];
        [self.view addSubview:iconText];
        iconStartingX = iconStartingX +  (iconPadding+iconSize);
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
