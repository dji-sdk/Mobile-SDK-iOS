//
//  DJIDecodeImageCalibrateControlLogic.m
//  DJISdkDemo
//
//  Copyright © 2018 DJI. All rights reserved.
//



#import <DJISDK/DJISDK.h>
#import <DJIWidget/DJIDecodeImageCalibrateHelper.h>
#import <DJIWidget/DJIMavic2ZoomCameraImageCalibrateFilterDataSource.h>
#import <DJIWidget/DJIMavic2ProCameraImageCalibrateFilterDataSource.h>
#import "DJIDecodeImageCalibrateControlLogic.h"


@interface DJIDecodeImageCalibrateControlLogic(){
    BOOL _calibrateNeeded;
    BOOL _calibrateStandAlone;
    //data source info
    NSDictionary* _dataSourceInfo;
    //helper for calibration
    DJIImageCalibrateHelper* _helper;
    //calibrate datasource
    DJIImageCalibrateFilterDataSource* _dataSource;
    //camera work mode
    DJICameraMode _workMode;
}
@end

@implementation DJIDecodeImageCalibrateControlLogic

-(void)dealloc{
    [self releaseHelper];
}

- (instancetype)init{
    if (self = [super init]){
        [self initData];
        _dataSourceInfo = @{
                            DJICameraDisplayNameMavic2ZoomCamera:[DJIMavic2ZoomCameraImageCalibrateFilterDataSource class],
                            DJICameraDisplayNameMavic2ProCamera:[DJIMavic2ProCameraImageCalibrateFilterDataSource class],
                            };
    }
    return self;
}

- (void)initData{
    _helper = nil;
    _dataSource = nil;
    _calibrateNeeded = NO;
	_cameraIndex = 0;
    _calibrateStandAlone = NO;
}

- (void)setCameraName:(NSString *)cameraName {
    if ([_cameraName isEqualToString:cameraName]) {
        return;
    }
    _cameraName = cameraName;
    BOOL cameraSupported = ([_cameraName isEqualToString:DJICameraDisplayNameMavic2ZoomCamera] ||
                            [_cameraName isEqualToString:DJICameraDisplayNameMavic2ProCamera]
                            );
    _calibrateNeeded = cameraSupported;
    _calibrateStandAlone = NO;
}


-(Class)targetHelperClass{
    if (_calibrateStandAlone){
        return [DJIDecodeImageCalibrateHelper class];
    }
    return [DJIImageCalibrateHelper class];
}

#pragma mark - calibration delegate
-(BOOL)shouldCreateHelper{
    return _calibrateNeeded;
}

-(void)destroyHelper{
    [self releaseHelper];
}

-(DJIImageCalibrateHelper*)helperCreated{
    Class targetClass = [self targetHelperClass];
    if (_helper != nil){
        BOOL shouldRemoved = !_calibrateNeeded;
        if (targetClass == nil
            || ![_helper isMemberOfClass:targetClass]){
            shouldRemoved = YES;
        }
        if (shouldRemoved){
            _helper = nil;
        }
    }
    if (!_calibrateNeeded){
        return nil;
    }
    if (_helper){
        return _helper;
    }
    DJIImageCalibrateHelper* helper = [[targetClass alloc] initShouldCreateCalibrateThread:NO
                                                                           andRenderThread:NO];
    _helper = helper;
    return helper;
}

-(DJIImageCalibrateFilterDataSource*)calibrateDataSource{
    Class targetClass = [_dataSourceInfo objectForKey:self.cameraName];
    if (!targetClass
        || ![targetClass isSubclassOfClass:[DJIImageCalibrateFilterDataSource class]]){
        targetClass = [DJIImageCalibrateFilterDataSource class];
    }
    if (_dataSource != nil
        && (![_dataSource isMemberOfClass:targetClass]
            || _dataSource.workMode != _workMode)){
        _dataSource = nil;
    }
    if (!_dataSource){
        _dataSource = [targetClass instanceWithWorkMode:_workMode];
    }
    return _dataSource;
}

#pragma mark - internal
-(void)releaseHelper{
    if (_helper != nil){
        _helper = nil;
    }
    if (_dataSource != nil){
        _dataSource = nil;
    }
}

@end
