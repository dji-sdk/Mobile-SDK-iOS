//
//  DJIReverseDLogFilter.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//


#import "DJIReverseDLogFilter.h"

@implementation DJIReverseDLogFilter

-(id) initWithContext:(DJILiveViewRenderContext *)acontext{
    
    //load texture for reverse dlog

    
    if (self = [super initWithContext:acontext
                        lookupTexture:nil]) {
        self.lutType = DLogReverseLookupTableTypeDefault;
    }
    
    return self;
}

-(void) setLutType:(DLogReverseLookupTableType)lutType{
    if(_lutType == lutType)
        return;
    
    _lutType = lutType;
    self.lookupTexture = [self lutForType:_lutType];
}

-(DJILiveViewRenderTexture*) lutForType:(DLogReverseLookupTableType)lut{
    NSString* lutName = [DJIReverseDLogFilter imageNameWithLUTType:lut];
    DJILiveViewRenderTexture* texture = nil;
    
    if (lutName) {
        UIImage* lookupTexture = [UIImage imageNamed:lutName];
        texture = [[DJILiveViewRenderTexture alloc]
                                             initWithContext:context
                                             image:lookupTexture];
    }
    
    return texture;
}

+(NSString*) imageNameWithLUTType:(DLogReverseLookupTableType)type{
    static NSDictionary* lutDic = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lutDic = @{
                   @(DLogReverseLookupTableTypeDefault)
                   :@"p4p_dlog_lut_new",
                   
                   @(DLogReverseLookupTableP4POld)
                   :@"p4p_dlog_lut_old",
                   };
    });
    
    return lutDic[@(type)];
}

@end
