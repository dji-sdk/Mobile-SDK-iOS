//
//  DJIWaypointAnnotationView.m
//  DJISdkDemo
//
//  Created by Ares on 15/7/2.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "DJIWaypointAnnotationView.h"

@implementation DJIWaypointAnnotationView

- (instancetype)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.enabled = NO;
        self.draggable = NO;
        UIImage* wpImage = [UIImage imageNamed:@"waypoint.png"];
        
        UIImageView* imgView = [[UIImageView alloc] initWithImage:wpImage];
        CGRect newFrame = self.frame;
        newFrame.size.width = wpImage.size.width;
        newFrame.size.height = wpImage.size.height * 2;
        [self setFrame:newFrame];
        
        CGRect lblFrame = imgView.frame;
        lblFrame.size.width = wpImage.size.width;
        lblFrame.size.height = wpImage.size.height * 0.7;
        self.titleLabel = [[UILabel alloc] initWithFrame:lblFrame];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [imgView addSubview:self.titleLabel];
        [self addSubview:imgView];
        
//        self.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.4];
    }
    
    return self;
}

@end
