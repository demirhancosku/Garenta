//
//  CarGroupViewController.m
//  Garenta
//
//  Created by Alp Keser on 12/27/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "CarGroupViewController.h"

@interface CarGroupViewController ()

@end

@implementation CarGroupViewController
@synthesize index,carGroup,myBoss;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithFrame:(UIPageViewController*)aBoss andCarGroups:(CarGroup*)aCarGroup{
    self = [super init];
    myBoss = aBoss;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    [[self view] setFrame:myBoss.view.frame];
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
    [groupLabel  setText:@"A Grubu"];
    //ToDo:biraz yukariya padding
    [groupLabel setTextColor:[ApplicationProperties getOrange]];
    [groupLabel setFrame:CGRectMake(0, 0, self.view.frame.size.width, [groupLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:16.0f ]].height)];
    [groupLabel setTextAlignment:NSTextAlignmentCenter];
    [[self view] addSubview:groupLabel];
    
    
    //Benzeri label
    
    UILabel *sampleCarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [sampleCarLabel setBackgroundColor:[UIColor clearColor]];
    [sampleCarLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0f]];
    [sampleCarLabel  setText:carGroup.sampleCar.modelName];
    //TODO: aalpk test
    [sampleCarLabel  setText:@"BMW 31634243242432424323424232"];
    //ToDo:biraz yukariya padding
    [sampleCarLabel setTextColor:[ApplicationProperties getBlack]];
    [sampleCarLabel setFrame:CGRectMake(0, groupLabel.frame.origin.y+groupLabel.frame.size.height, self.view.frame.size.width, [sampleCarLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:16.0f]].height)];
    [sampleCarLabel setTextAlignment:NSTextAlignmentCenter];
    [[self view] addSubview:sampleCarLabel];
    
    
    //arabaimage
    float imageRatio = 125.0f / 200.0f;
    float viewHeight = self.view.frame.size.height;
    float imageHeight = (self.view.frame.size.height - (sampleCarLabel.frame.size.height +sampleCarLabel.frame.origin.y)) * 0.4;
    float imageWidth = imageHeight / imageRatio;
    float imageStartPoint = (self.view.frame.size.width - imageWidth) /2 ;
    UIImageView *carImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageStartPoint, (sampleCarLabel.frame.size.height +groupLabel.frame.size.height),imageWidth ,imageHeight)];
    [carImageView setImage:[UIImage imageNamed:@"a_grubu.jpg"]];
    [[self view] addSubview:carImageView];
    
    //icons views
    int iconCount = 4; // get from car
    float iconSize = self.view.frame.size.height * 0.1;
    float iconPadding = self.view.frame.size.height * 0.05;
    //%10 for each %5 for padding
    float iconStartingX = (self.view.frame.size.width - ((iconCount * iconSize) + ( iconPadding * (iconCount -1)))) / 2;
    UIImageView *iconImageView;
    UILabel *iconText;
    for (int sayac = 0; sayac < iconCount; sayac++) {
        //hangi ikon benzn,sansz,klima,kislas
        //TODO aalpk label ekle duzelt
        iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(iconStartingX, carImageView.frame.origin.y + carImageView.frame.size.height, iconSize, iconSize)];
        //iconText = [UILabel alloc] initWithCoder:CGRectMake(iconImageView.frame.origin.x, iconImageView.frame.origin.y + iconImageView.frame.size.height, iconImageView.frame.size., <#CGFloat height#>)
        switch (sayac) {
            case 0:
                [iconImageView setImage:[UIImage imageNamed:@"yakit.png"]];
                break;
            case 1:
                [iconImageView setImage:[UIImage imageNamed:@"vites.png"]];
                break;
            case 2:
                [iconImageView setImage:[UIImage imageNamed:@"klima.png"]];
                break;
            case 3:
                [iconImageView setImage:[UIImage imageNamed:@"kislastik.png"]];
                break;
            default:
                break;
        }
        
        [self.view addSubview:iconImageView];
        iconStartingX = iconStartingX +  (iconPadding+iconSize);
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
