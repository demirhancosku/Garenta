//
//  AppDelegate.h
//  Garenta
//
//  Created by Kerem Balaban on 27.11.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClassicSearchVC.h"
#import "MenuSelectionVC.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    int timestamp;
}

@property (strong, nonatomic) UIWindow *window;

- (void)updateTimerObject:(id)sender;
@end
