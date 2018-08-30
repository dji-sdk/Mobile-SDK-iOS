//
//  DJIVideoPresentViewAdjustHelper.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#define FLOAT_SWAP(a,b) {CGFloat temp = a; a = b; b = temp;}

#import "DJIVideoPresentViewAdjustHelper.h"

@implementation DJIVideoPresentViewAdjustHelper

-(CGRect) getFinalFrame{
    
    if (_contentMode == VideoPresentContentModeNone) {
        return _lastFrame;
    }
    
    // `adjustFrame` is the final result
    CGRect adjustFrame = _lastFrame;
    
    // `superSize` is the size of container
    CGSize superSize = self.boundingFrame.size;
    
    // `contentSize` is the size of raw video stream input, including the black
    // bars if there is any.
    CGSize contentSize = CGSizeMake(_videoSize.width, _videoSize.height);
    if (_videoSize.width == 0
        || _videoSize.height == 0) {
        contentSize = superSize;
    }
    
    //get a available rect from stream space
    CGRect contentClipRect = _contentClipRect;
    
    if (self.contentClipRect.size.width == 0
        || self.contentClipRect.size.height == 0) {
        //use content size
        contentClipRect = CGRectMake(0, 0, 1, 1);
    }
    
    //check rotation
    if (self.rotation == VideoStreamRotationCW90
        || self.rotation == VideoStreamRotationCW270) {
        
        
        //swap content height & width
        FLOAT_SWAP(contentClipRect.origin.x, contentClipRect.origin.y);
        FLOAT_SWAP(contentClipRect.size.width, contentClipRect.size.height);
        FLOAT_SWAP(contentSize.width, contentSize.height);
    }
    
    CGRect availableRectInStreamSpace = CGRectZero;
    {
        CGFloat width = contentSize.width;
        CGFloat height = contentSize.height;
        availableRectInStreamSpace = CGRectMake(contentClipRect.origin.x*width,
                                                contentClipRect.origin.y*height,
                                                contentClipRect.size.width*width,
                                                contentClipRect.size.height*height);
    }
    
    //get adjusted size
    if (superSize.width == 0
        || superSize.height == 0) {
        //do not adjust,
    }
    else{
        
        CGRect filledStreamFrame = CGRectZero;
        CGRect boundingBox = CGRectMake(0, 0, superSize.width, superSize.height);
        if(_contentMode == VideoPresentContentModeAspectFit){
            // just like UIViewContentModeScaleAspectFit
            
            filledStreamFrame = [DJIVideoPresentViewAdjustHelper aspectFitWithFrame:boundingBox
                                                    size:availableRectInStreamSpace.size];
        }
        else if(_contentMode == VideoPresentContentModeAspectFill){
            // just like UIViewContentModeScaleAspectFill
            
            filledStreamFrame = [DJIVideoPresentViewAdjustHelper aspectFillWithFrame:boundingBox
                                                     size:availableRectInStreamSpace.size];
        }
        
        //get adjust frame from avaiable area
        adjustFrame.size.width = filledStreamFrame.size.width/contentClipRect.size.width;
        adjustFrame.size.height = filledStreamFrame.size.height/contentClipRect.size.height;
        adjustFrame.origin.x = (boundingBox.size.width - adjustFrame.size.width)*0.5;
        adjustFrame.origin.y = (boundingBox.size.height - adjustFrame.size.height)*0.5;
    }
    
    return adjustFrame;
}

+(CGRect) normalizeFrame:(CGRect)frame withIdentityRect:(CGRect)rect{
    
    CGRect normalized = CGRectZero;
    //move the frame into rect system
    frame.origin.x = frame.origin.x - rect.origin.x;
    frame.origin.y = frame.origin.y - rect.origin.y;
    
    //width
    if (rect.size.width == 0) {
    }else{
        normalized.origin.x = frame.origin.x/rect.size.width;
        normalized.size.width = frame.size.width/rect.size.width;
    }
    
    if (rect.size.height == 0) {
    }else{
        normalized.origin.y = frame.origin.y/rect.size.height;
        normalized.size.height = frame.size.height/rect.size.height;
    }
    
    return normalized;
}

+(CGRect) aspectFitWithFrame:(CGRect)frame size:(CGSize)size{
    //UIViewContentModeScaleAspectFit
    CGRect fit_frame = frame;
    
    CGFloat frameWHRate = frame.size.width/frame.size.height;
    CGFloat sizeWHRate = size.width/size.height;
    
    if (fabs(frameWHRate - sizeWHRate) < 10e-6) {
        fit_frame.origin = CGPointZero;
        fit_frame.size = frame.size;
        return fit_frame;
    }
    
    if (sizeWHRate > frameWHRate) {
        //use frame width
        fit_frame.size.height = frame.size.width / sizeWHRate;
        //adjust origin
        fit_frame.origin.x = 0;
        fit_frame.origin.y = (frame.size.height - fit_frame.size.height) * 0.5;
    }else{
        //use frame height
        fit_frame.size.width = frame.size.height * sizeWHRate;
        //adjust origin
        fit_frame.origin.y = 0;
        fit_frame.origin.x = (frame.size.width - fit_frame.size.width) * 0.5;
        
    }
    
    return fit_frame;
}

+(CGRect) aspectFillWithFrame:(CGRect)frame size:(CGSize)size{
    //UIViewContentModeScaleAspectFill
    
    CGRect fit_frame = frame;
    
    CGFloat frameWHRate = frame.size.width/frame.size.height;
    CGFloat sizeWHRate = size.width/size.height;
    
    if (fabs(frameWHRate - sizeWHRate) < 10e-6) {
        fit_frame.origin = CGPointZero;
        fit_frame.size = frame.size;
        return fit_frame;
    }
    
    if (sizeWHRate < frameWHRate) {
        //use frame width
        fit_frame.size.height = frame.size.width / sizeWHRate;
        //adjust origin
        fit_frame.origin.x = 0;
        fit_frame.origin.y = (frame.size.height - fit_frame.size.height) * 0.5;
    }else{
        //use frame height
        fit_frame.size.width = frame.size.height * sizeWHRate;
        //adjust origin
        fit_frame.origin.y = 0;
        fit_frame.origin.x = (frame.size.width - fit_frame.size.width) * 0.5;
        
    }
    
    return fit_frame;
}


@end
