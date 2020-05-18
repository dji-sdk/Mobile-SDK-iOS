//
//  DJIPOIAnnotationView.m
//  Phantom3
//
//  Created by Jerome.zhang on 15/7/30.
//  Copyright (c) 2015年 DJIDevelopers.com. All rights reserved.
//

#import "DJIPOIAnnotationView.h"

@interface DJIPOIAnnotationView ()

@end

@implementation DJIPOIAnnotationView
- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.pinView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 54.0, 54.0)];
        [self.pinView setBackgroundColor:[UIColor clearColor]];
        UIImageView *pinIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigation_poi_pin"]];
        [self.pinView addSubview:pinIcon];
        [pinIcon setCenter:CGPointMake(self.pinView.center.x, self.pinView.center.y - pinIcon.frame.size.height*0.5)];
        CGRect frame = self.frame;
        frame.size = self.pinView.frame.size;
        [self setFrame:frame];
        [self addSubview:self.pinView];
        self.pinView.layer.zPosition = 101;
    }
    
    return self;
}


@end
