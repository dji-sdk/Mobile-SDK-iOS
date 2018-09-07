//
//  DJIMavic2ProCameraImageCalibrateFilterDataSource.m
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import "DJIMavic2ProCameraImageCalibrateFilterDataSource.h"

#define DJIMakeCalibrationKeyTag(__part1__,__part2__)      (@((((NSUInteger)((__part1__) + 0.5)) << 16) | ((NSUInteger)((__part2__) + 0.5))))
#define DJIMakeCalibrationResolutionTag(__size__)          DJIMakeCalibrationKeyTag((__size__).width,(__size__).height)
#define DJIMakeCalibrationFovAndIdxTag(__fov__,__idx__)    DJIMakeCalibrationKeyTag((__fov__),(__idx__))

@interface DJIMavic2ProCameraImageCalibrateFilterDataSource(){
    NSMutableDictionary* _fileInfo;
}
@end

@implementation DJIMavic2ProCameraImageCalibrateFilterDataSource

-(BOOL)loadFromFiles{
    return YES;
}

-(NSUInteger)validIndexCountForResolution:(CGSize)resolution{
    if (_fileInfo != nil){
        NSMutableDictionary* bundleInfo = [_fileInfo objectForKey:DJIMakeCalibrationResolutionTag(resolution)];
        if (bundleInfo != nil
            && [bundleInfo isKindOfClass:[NSMutableDictionary class]]){
            return bundleInfo.allKeys.count;
        }
    }
    NSString* type = [self fileType];
    NSArray* supportedFovStates = [self supportedFovStates];
    NSMutableDictionary* bundleInfo = [NSMutableDictionary dictionary];
    for (NSNumber* fovState in supportedFovStates){
        NSString* desc = [self fileDescriptionWithFovState:fovState.unsignedIntegerValue
                                             andResolution:resolution];
        NSString* preFileName = nil;
        int index = 0;
        do{
            NSString* fileName = [self fileNameFormatWithResolution:resolution
                                                            zoomIdx:index
                                                           focusIdx:0
                                                           splitIdx:0
                                             andFileDiscriptionInfo:desc];
            if (preFileName != nil
                &&  [preFileName isEqualToString:fileName]){
                //If the source file name is same, No need roop, exit.
                break;
            }
            preFileName = fileName;
			NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"DistortionResource" withExtension:@"bundle"]];
			NSString* bundlePath = [bundle pathForResource:fileName ofType:type inDirectory:@"distortion"];
            if (!bundlePath){
                break;
            }
            [bundleInfo setObject:bundlePath
                          forKey:DJIMakeCalibrationFovAndIdxTag(fovState.unsignedIntegerValue,index)];
            index++;
        } while(1);
    }
    if (!_fileInfo){
        _fileInfo = [NSMutableDictionary dictionary];
    }
    [_fileInfo setObject:bundleInfo
                  forKey:DJIMakeCalibrationResolutionTag(resolution)];
    return bundleInfo.allKeys.count;
}

-(NSData*)textureCoordinateDataForResolution:(CGSize)resolution
                                    dataIndex:(NSUInteger)index{
    NSString* file = nil;
    NSMutableDictionary* bundleInfo = [_fileInfo objectForKey:DJIMakeCalibrationResolutionTag(resolution)];
    if (bundleInfo != nil
        && [bundleInfo isKindOfClass:[NSMutableDictionary class]]
        && index < bundleInfo.allKeys.count){
        NSString* key = [bundleInfo.allKeys objectAtIndex:index];
        file = [bundleInfo objectForKey:key];
    }
    if (![file isKindOfClass:[NSString class]]){
        return nil;
    }
    return [NSData dataWithContentsOfFile:file];
}

-(NSUInteger)dataIndexForResolution:(CGSize)resolution
                           lutIndex:(NSUInteger)index
                        andFovState:(DJISEIInfoLiveViewFOVState)fovState{
    NSMutableDictionary* bundleInfo = [_fileInfo objectForKey:DJIMakeCalibrationResolutionTag(resolution)];
    if (bundleInfo != nil
        && [bundleInfo isKindOfClass:[NSMutableDictionary class]]){
        return [bundleInfo.allKeys indexOfObject:DJIMakeCalibrationFovAndIdxTag(fovState, index)];
    }
    return NSNotFound;
}

#pragma mark - files
-(NSString*)sensorType{
    return @"imx283";
}

-(NSString*)fileDescriptionWithFovState:(DJISEIInfoLiveViewFOVState)state
                          andResolution:(CGSize)resolution {
    
    if (self.workMode == 1/*DJICameraModeRecordVideo*/){
        //record mode fov
        switch (state){
            case DJISEIInfoLiveViewFOVState_Wide_Fov:{
                return @"recording_wide";
            }
                break;
            case DJISEIInfoLiveViewFOVState_Narrow_Fov:{
                return @"recording_narrow";
            }
                break;
            default:
                break;
        }
        return @"unknown";
    }
    return [NSString stringWithFormat:@"still_%@",
            [self ratioTypeForResolution:resolution]];// Add ratio
}

-(NSString*)fileType{
    return @"bin";
}

-(NSString*)fileNameFormatWithResolution:(CGSize)resolution
                                 zoomIdx:(int)zoomIdx
                                focusIdx:(int)focusIdx
                                splitIdx:(int)splitIdx
                  andFileDiscriptionInfo:(NSString*)desc{
    NSString* sensor = [self sensorType];
    int width = (int)(resolution.width + 0.5);
    int height = (int)(resolution.height + 0.5);
    //example:[sesor name]_[intput resolution]_to_[output resolution]_[desc].bin
    return [NSString stringWithFormat:@"%@_%dx%d_to_%dx%d_%@",
            sensor,
            width,height,
            width,height,
            desc];
}

-(NSString*)ratioTypeForResolution:(CGSize)resolution{
    static NSDictionary* supportedRatios = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        supportedRatios = @{
                            @"3x2" : [NSValue valueWithCGSize:CGSizeMake(3, 2)],
                            @"16x9" : [NSValue valueWithCGSize:CGSizeMake(16, 9)],
                            @"4x3" : [NSValue valueWithCGSize:CGSizeMake(4, 3)],
                            };
    });
    float minDist = FLT_MAX;
    NSString* targetRatio = nil;
    for (NSString* ratio in supportedRatios.allKeys){
        NSValue* ratioValue = [supportedRatios objectForKey:ratio];
        CGSize ratioSize = [ratioValue CGSizeValue];
        float dist = fabs((ratioSize.width / MAX(ratioSize.height,1)) - (resolution.width / MAX(resolution.height,1)));
        if (dist < minDist){
            minDist = dist;
            targetRatio = ratio;
        }
    }
    return targetRatio;
}

-(NSArray*)supportedFovStates{
    
    if (self.workMode == 1/*DJICameraModeRecordVideo*/) {
        return @[
                 @(DJISEIInfoLiveViewFOVState_Narrow_Fov),
                 @(DJISEIInfoLiveViewFOVState_Wide_Fov),
                 ];
    }
    //Not record mode, Only fov
    return @[
             @(DJISEIInfoLiveViewFOVState_Wide_Fov),
             ];
}

@end
