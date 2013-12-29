//
//  MenuTableCellView.m
//  Garenta
//
//  Created by Alp Keser on 12/25/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "MenuTableCellView.h"

@implementation MenuTableCellView
@synthesize index;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
     

    }
    return self;
}
- (id)initWithFrame:(CGRect)frame andIndex:(int) aIndex{
    self = [self initWithFrame:frame];
    index = aIndex;
    return self;
}


-(void)layoutSubviews{
    [super layoutSubviews];

    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width * 0.1, self.frame.size.height *0.8, self.frame.size.width * 0.8, self.frame.size.height*0.2)];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:16.0f]];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0,0,self.frame.size.height * 0.5,self.frame.size.height * 0.5)];
    [imageView setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)];
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0,0,self.frame.size.height * 0.3,self.frame.size.height * 0.3)];
    [arrowImageView setCenter:CGPointMake(50, self.frame.size.height/2)];
    [arrowImageView setImage:[UIImage imageNamed:@"AccessoryButton.png"]];
    [arrowImageView setFrame:CGRectMake((self.frame.size.width - arrowImageView.frame.size.width), arrowImageView.frame.origin.y, arrowImageView.frame.size.width, arrowImageView.frame.size.height)];
    

    switch (index) {
        case 0:
            [self setBackgroundColor:[UIColor colorWithRed:209.0f/255.0f green:209.0f/255.0f blue:209.0f/255.0f alpha:1.0f]];
            [textLabel setText:@"Size en yakın araçlar"];
            [imageView setImage:[UIImage imageNamed:@"location_icon.png"]];
            //fix width according to text
//            CGSize labelSize = [textLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:16.0f ]];
            

//            [textLabel setFrame:CGRectMake((self.frame.size.width - labelSize.width)/2,0.1,labelSize.width,labelSize.height)];
            break;
        case 1:
            [self setBackgroundColor:[UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f]];
            [textLabel setText:@"Araç Bul"];
            
            [imageView setImage:[UIImage imageNamed:@"arac_bul.png"]];
            break;
        case 2:
            [self setBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
            [textLabel setText:@"Detaylı Arama"];
            
            [imageView setImage:[UIImage imageNamed:@"detail_search.png"]];
            break;
        default:
            break;
    }
             [textLabel setTextAlignment:NSTextAlignmentCenter];
    
    
    [self addSubview:textLabel];
    [self addSubview:imageView];
    [self addSubview:arrowImageView];
    [self setNeedsDisplayInRect:self.frame];
    
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//    [super drawRect:rect];
//    
////    [self setNeedsDisplayInRect:rect];
//}


@end
