//
//  DJIReverseDLogFilter.m
//

#import "DJIReverseDLogFilter.h"

#define DJI_VIDEOPREVIEW_RESOURCES_PATH @"VideoPreviewer.framework/VideoPreviewer.bundle"

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
        UIImage* lookupTexture = [self getImageFromNamed:lutName];
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
                   :@"delog_lut",
                   };
    });
    
    return lutDic[@(type)];
}

-(UIImage*) getImageFromNamed:(NSString*)imageName
{
    static NSBundle* bundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString* frameworkPath = [[NSBundle mainBundle] privateFrameworksPath];
        NSString* resourcePath = [frameworkPath stringByAppendingPathComponent:DJI_VIDEOPREVIEW_RESOURCES_PATH];
        bundle = [NSBundle bundleWithPath:resourcePath];
    });

    UIImage* image = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
}

@end
