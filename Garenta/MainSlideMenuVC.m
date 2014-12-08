//
//  MainSlideMenuVC.m
//  Garenta
//
//  Created by Onur Küçük on 6.11.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "MainSlideMenuVC.h"

@interface MainSlideMenuVC ()

@end

@implementation MainSlideMenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(NSString *)segueIdentifierForIndexPathInLeftMenu:(NSIndexPath *)indexPath
{
    NSString *identifier;
    switch (indexPath.row) {
        case 0:
            identifier = @"carReservation";
            break;
        case 1:
            identifier = @"myReservations";
            break;
        case 2:
            identifier = @"profile";
            break;
        case 3:
            identifier = @"branchList";
            break;
        case 4:
            identifier = @"contact";
            break;
            
        default:
            break;
    }
    return identifier;
}
- (void)configureLeftMenuButton:(UIButton *)button;
{
    CGRect frame = button.frame;
    frame.origin = (CGPoint){0,0};
    frame.size = (CGSize){40,40};
    
    button.frame = frame;
    [button setImage:[UIImage imageNamed:@"icon-menu@2x"] forState:UIControlStateNormal];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
