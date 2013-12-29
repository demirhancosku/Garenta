//
//  LoaderAnimationVC.h
//  Garenta_Service
//
//  Created by Ata  Cengiz on 12.12.2013.
//  Copyright (c) 2013 Ata  Cengiz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoaderAnimationVC : UIViewController
{
    UIImageView *animationView;
}

- (void)playAnimation:(UIView *)iView;
- (void)stopAnimation;

@end
