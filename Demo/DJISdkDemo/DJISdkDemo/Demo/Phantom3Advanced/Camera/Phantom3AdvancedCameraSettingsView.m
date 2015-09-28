//
//  CameraSettingsView.m
//  DJISdkDemo
//
//  Created by Ares on 14-7-14.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "Phantom3AdvancedCameraSettingsView.h"
#import <DJISDK/DJISDK.h>

@implementation Phantom3AdvancedCameraSettingsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSettings];
        _selectedItem = [_mainSettingItems objectAtIndex:0];
        
        NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"PhantomCameraSettingsView" owner:self options:Nil];
        if (nibObjects && nibObjects.count > 0) {
            UIView* mainView = (UIView*)[nibObjects objectAtIndex:0];
            _tableView1 = (UITableView*)[mainView viewWithTag:1];
            _tableView1.separatorStyle = UITableViewCellSeparatorStyleNone;
            _tableView1.dataSource = self;
            _tableView1.delegate = self;
            
            _tableView2 = (UITableView*)[mainView viewWithTag:2];
            _tableView2.separatorStyle = UITableViewCellSeparatorStyleNone;
            _tableView2.dataSource = self;
            _tableView2.delegate = self;
            
            _fovType = CameraRecordingFOV0 ;
            _resolutionType = CameraRecordingResolution640x48030p ;
            
            _tableView1.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
            _tableView2.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
            mainView.backgroundColor = [UIColor clearColor];
            self.backgroundColor = [UIColor clearColor];
            [self addSubview:mainView];
        }
    }
    return self;
}

-(void) setCamera:(DJICamera*)camera
{
    _camera = camera;
}

-(void) initSettings
{
    _mainSettingItems = [[NSMutableArray alloc] init];

    SettingsItem* item100 = [[SettingsItem alloc] initWithItemName:@"SetWorkMode"];
    item100.itemAction = @selector(onSetCameraWorkMode:);
    item100.subSettings = [[NSMutableArray alloc] init];
    {
        CameraWorkMode workMode = CameraWorkModeCapture;
        SettingsItem* sub1 = [[SettingsItem alloc] initWithItemName:@"Capture"];
        sub1.isSubItem = YES;
        sub1.itemAction = @selector(onSetCameraWorkMode:);
        sub1.itemValue = [NSValue value:&workMode withObjCType:@encode(CameraWorkMode)];
        
        workMode = CameraWorkModeRecord;
        SettingsItem* sub2 = [[SettingsItem alloc] initWithItemName:@"Record"];
        sub2.isSubItem = YES;
        sub2.itemAction = @selector(onSetCameraWorkMode:);
        sub2.itemValue = [NSValue value:&workMode withObjCType:@encode(CameraWorkMode)];

        workMode = CameraWorkModePlayback;
        SettingsItem* sub3 = [[SettingsItem alloc] initWithItemName:@"Playback"];
        sub3.isSubItem = YES;
        sub3.itemAction = @selector(onSetCameraWorkMode:);
        sub3.itemValue = [NSValue value:&workMode withObjCType:@encode(CameraWorkMode)];

        workMode = CameraWorkModeDownload;
        SettingsItem* sub4 = [[SettingsItem alloc] initWithItemName:@"Download"];
        sub4.isSubItem = YES;
        sub4.itemAction = @selector(onSetCameraWorkMode:);
        sub4.itemValue = [NSValue value:&workMode withObjCType:@encode(CameraWorkMode)];
        
        [item100.subSettings addObject:sub1];
        [item100.subSettings addObject:sub2];
        [item100.subSettings addObject:sub3];
        [item100.subSettings addObject:sub4];
    }

    SettingsItem* item101 = [[SettingsItem alloc] initWithItemName:@"ExposureMode"];
    item101.itemAction = @selector(onSetCameraExposureMode:);
    item101.subSettings = [[NSMutableArray alloc] init];
    {
        CameraExposureMode exposureMode = CameraExposureModeProgram;
        exposureMode = CameraExposureModeProgram;
        SettingsItem* sub1 = [[SettingsItem alloc] initWithItemName:@"Program"];
        sub1.isSubItem = YES;
        sub1.itemAction = @selector(onSetCameraExposureMode:);
        sub1.itemValue = [NSValue value:&exposureMode withObjCType:@encode(CameraExposureMode)];
        
        exposureMode = CameraExposureModeShutter;
        SettingsItem* sub2 = [[SettingsItem alloc] initWithItemName:@"Shutter"];
        sub2.isSubItem = YES;
        sub2.itemAction = @selector(onSetCameraExposureMode:);
        sub2.itemValue = [NSValue value:&exposureMode withObjCType:@encode(CameraExposureMode)];
        
        exposureMode = CameraExposureModeManual;
        SettingsItem* sub4 = [[SettingsItem alloc] initWithItemName:@"Manual"];
        sub4.isSubItem = YES;
        sub4.itemAction = @selector(onSetCameraExposureMode:);
        sub4.itemValue = [NSValue value:&exposureMode withObjCType:@encode(CameraExposureMode)];

        [item101.subSettings addObject:sub1];
        [item101.subSettings addObject:sub2];
        [item101.subSettings addObject:sub4];

    }
    
    SettingsItem* item1 = [[SettingsItem alloc] initWithItemName:@"PhotoSize"];
    item1.itemAction = @selector(onSetPhotoSize:);
    item1.subSettings = [[NSMutableArray alloc] init];
    {
        CameraPhotoSizeType photoSize = CameraPhotoSizeDefault;
        SettingsItem* sub1 = [[SettingsItem alloc] initWithItemName:@"Default"];
        sub1.isSubItem = YES;
        sub1.itemAction = @selector(onSetPhotoSize:);
        sub1.itemValue = [NSValue value:&photoSize withObjCType:@encode(CameraPhotoSizeType)];
        
        photoSize = CameraPhotoSize4384x3288;
        SettingsItem* sub2 = [[SettingsItem alloc] initWithItemName:@"4384x3288"];
        sub2.isSubItem = YES;
        sub2.itemAction = @selector(onSetPhotoSize:);
        sub2.itemValue = [NSValue value:&photoSize withObjCType:@encode(CameraPhotoSizeType)];
        
        photoSize = CameraPhotoSize4384x2922;
        SettingsItem* sub3 = [[SettingsItem alloc] initWithItemName:@"4384x2922"];
        sub3.isSubItem = YES;
        sub3.itemAction = @selector(onSetPhotoSize:);
        sub3.itemValue = [NSValue value:&photoSize withObjCType:@encode(CameraPhotoSizeType)];
        
        photoSize = CameraPhotoSize4384x2466;
        SettingsItem* sub4 = [[SettingsItem alloc] initWithItemName:@"4384x2466"];
        sub4.isSubItem = YES;
        sub4.itemAction = @selector(onSetPhotoSize:);
        sub4.itemValue = [NSValue value:&photoSize withObjCType:@encode(CameraPhotoSizeType)];
        
        photoSize = CameraPhotoSize4608x3456;
        SettingsItem* sub5 = [[SettingsItem alloc] initWithItemName:@"4608x3456"];
        sub5.isSubItem = YES;
        sub5.itemAction = @selector(onSetPhotoSize:);
        sub5.itemValue = [NSValue value:&photoSize withObjCType:@encode(CameraPhotoSizeType)];
        
        [item1.subSettings addObject:sub1];
        [item1.subSettings addObject:sub2];
        [item1.subSettings addObject:sub3];
        [item1.subSettings addObject:sub4];
        [item1.subSettings addObject:sub5];
    }
    
    
    SettingsItem* item2 = [[SettingsItem alloc] initWithItemName:@"ISO"];
    item2.itemAction = @selector(onSetISOType:);
    item2.subSettings = [[NSMutableArray alloc] init];
    {
        CameraISOType isoType = CameraISOAuto;
        SettingsItem* sub1 = [[SettingsItem alloc] initWithItemName:@"ISOAuto"];
        sub1.isSubItem = YES;
        sub1.itemAction = @selector(onSetISOType:);
        sub1.itemValue = [NSValue value:&isoType withObjCType:@encode(CameraISOType)];
        
        isoType = CameraISO100;
        SettingsItem* sub2 = [[SettingsItem alloc] initWithItemName:@"ISO100"];
        sub2.isSubItem = YES;
        sub2.itemAction = @selector(onSetISOType:);
        sub2.itemValue = [NSValue value:&isoType withObjCType:@encode(CameraISOType)];
        
        isoType = CameraISO200;
        SettingsItem* sub3 = [[SettingsItem alloc] initWithItemName:@"ISO200"];
        sub3.isSubItem = YES;
        sub3.itemAction = @selector(onSetISOType:);
        sub3.itemValue = [NSValue value:&isoType withObjCType:@encode(CameraISOType)];
        
        isoType = CameraISO400;
        SettingsItem* sub4 = [[SettingsItem alloc] initWithItemName:@"ISO400"];
        sub4.isSubItem = YES;
        sub4.itemAction = @selector(onSetISOType:);
        sub4.itemValue = [NSValue value:&isoType withObjCType:@encode(CameraISOType)];
        
        isoType = CameraISO800;
        SettingsItem* sub5 = [[SettingsItem alloc] initWithItemName:@"ISO800"];
        sub5.isSubItem = YES;
        sub5.itemAction = @selector(onSetISOType:);
        sub5.itemValue = [NSValue value:&isoType withObjCType:@encode(CameraISOType)];
        
        isoType = CameraISO1600;
        SettingsItem* sub6 = [[SettingsItem alloc] initWithItemName:@"ISO1600"];
        sub6.isSubItem = YES;
        sub6.itemAction = @selector(onSetISOType:);
        sub6.itemValue = [NSValue value:&isoType withObjCType:@encode(CameraISOType)];
        
        isoType = CameraISO3200;
        SettingsItem* sub7 = [[SettingsItem alloc] initWithItemName:@"ISO3200"];
        sub7.isSubItem = YES;
        sub7.itemAction = @selector(onSetISOType:);
        sub7.itemValue = [NSValue value:&isoType withObjCType:@encode(CameraISOType)];
        
        [item2.subSettings addObject:sub1];
        [item2.subSettings addObject:sub2];
        [item2.subSettings addObject:sub3];
        [item2.subSettings addObject:sub4];
        [item2.subSettings addObject:sub5];
        [item2.subSettings addObject:sub6];
        [item2.subSettings addObject:sub7];
    }
    SettingsItem* item3 = [[SettingsItem alloc] initWithItemName:@"WhiteBalance"];
    item3.itemAction = @selector(onSetWhiteBalance:);
    item3.subSettings = [[NSMutableArray alloc] init];
    {
        CameraWhiteBalanceType whiteBalance = CameraWhiteBalanceAuto;
        SettingsItem* sub1 = [[SettingsItem alloc] initWithItemName:@"Auto"];
        sub1.isSubItem = YES;
        sub1.itemAction = @selector(onSetWhiteBalance:);
        sub1.itemValue = [NSValue value:&whiteBalance withObjCType:@encode(CameraWhiteBalanceType)];
        
        whiteBalance = CameraWhiteBalanceSunny;
        SettingsItem* sub2 = [[SettingsItem alloc] initWithItemName:@"Sunny"];
        sub2.isSubItem = YES;
        sub2.itemAction = @selector(onSetWhiteBalance:);
        sub2.itemValue = [NSValue value:&whiteBalance withObjCType:@encode(CameraWhiteBalanceType)];
        
        whiteBalance = CameraWhiteBalanceCloudy;
        SettingsItem* sub3 = [[SettingsItem alloc] initWithItemName:@"Cloudy"];
        sub3.isSubItem = YES;
        sub3.itemAction = @selector(onSetWhiteBalance:);
        sub3.itemValue = [NSValue value:&whiteBalance withObjCType:@encode(CameraWhiteBalanceType)];
        
        whiteBalance = CameraWhiteBalanceIndoor;
        SettingsItem* sub4 = [[SettingsItem alloc] initWithItemName:@"Indoor"];
        sub4.isSubItem = YES;
        sub4.itemAction = @selector(onSetWhiteBalance:);
        sub4.itemValue = [NSValue value:&whiteBalance withObjCType:@encode(CameraWhiteBalanceType)];
        
        [item3.subSettings addObject:sub1];
        [item3.subSettings addObject:sub2];
        [item3.subSettings addObject:sub3];
        [item3.subSettings addObject:sub4];
    }
    SettingsItem* item4 = [[SettingsItem alloc] initWithItemName:@"ExposureMetering"];
    item4.itemAction = @selector(onSetExposureMetering:);
    item4.subSettings = [[NSMutableArray alloc] init];
    {
        CameraExposureMeteringType exposureMetering = CameraExposureMeteringCenter;
        SettingsItem* sub1 = [[SettingsItem alloc] initWithItemName:@"Center"];
        sub1.isSubItem = YES;
        sub1.itemAction = @selector(onSetExposureMetering:);
        sub1.itemValue = [NSValue value:&exposureMetering withObjCType:@encode(CameraExposureMeteringType)];
        
        exposureMetering = CameraExposureMeteringAverage;
        SettingsItem* sub2 = [[SettingsItem alloc] initWithItemName:@"Average"];
        sub2.isSubItem = YES;
        sub2.itemAction = @selector(onSetExposureMetering:);
        sub2.itemValue = [NSValue value:&exposureMetering withObjCType:@encode(CameraExposureMeteringType)];
        
        exposureMetering = CameraExposureMeteringPoint;
        SettingsItem* sub3 = [[SettingsItem alloc] initWithItemName:@"Point"];
        sub3.isSubItem = YES;
        sub3.itemAction = @selector(onSetExposureMetering:);
        sub3.itemValue = [NSValue value:&exposureMetering withObjCType:@encode(CameraExposureMeteringType)];
        
        [item4.subSettings addObject:sub1];
        [item4.subSettings addObject:sub2];
        [item4.subSettings addObject:sub3];
    }
    SettingsItem* item5 = [[SettingsItem alloc] initWithItemName:@"RecordResolution"];
    item5.itemAction = @selector(onSetRecordingResolution:);
    item5.subSettings = [[NSMutableArray alloc] init];
    {
        CameraRecordingResolutionType resolutionType = CameraRecordingResolutionDefault;
        SettingsItem* sub1 = [[SettingsItem alloc] initWithItemName:@"Default"];
        sub1.isSubItem = YES;
        sub1.itemAction = @selector(onSetRecordingResolution:);
        sub1.itemValue = [NSValue value:&resolutionType withObjCType:@encode(CameraExposureMeteringType)];
        
        resolutionType = CameraRecordingResolution640x48030p;
        SettingsItem* sub2 = [[SettingsItem alloc] initWithItemName:@"640x48030p"];
        sub2.isSubItem = YES;
        sub2.itemAction = @selector(onSetRecordingResolution:);
        sub2.itemValue = [NSValue value:&resolutionType withObjCType:@encode(CameraExposureMeteringType)];
        
        resolutionType = CameraRecordingResolution1280x72030p;
        SettingsItem* sub3 = [[SettingsItem alloc] initWithItemName:@"1280x72030p"];
        sub3.isSubItem = YES;
        sub3.itemAction = @selector(onSetRecordingResolution:);
        sub3.itemValue = [NSValue value:&resolutionType withObjCType:@encode(CameraExposureMeteringType)];
        
        resolutionType = CameraRecordingResolution1280x72060p;
        SettingsItem* sub4 = [[SettingsItem alloc] initWithItemName:@"1280x72060p"];
        sub4.isSubItem = YES;
        sub4.itemAction = @selector(onSetRecordingResolution:);
        sub4.itemValue = [NSValue value:&resolutionType withObjCType:@encode(CameraExposureMeteringType)];
        
        resolutionType = CameraRecordingResolution1280x96030p;
        SettingsItem* sub5 = [[SettingsItem alloc] initWithItemName:@"1280x96030p"];
        sub5.isSubItem = YES;
        sub5.itemAction = @selector(onSetRecordingResolution:);
        sub5.itemValue = [NSValue value:&resolutionType withObjCType:@encode(CameraExposureMeteringType)];
        
        resolutionType = CameraRecordingResolution1920x108030p;
        SettingsItem* sub6 = [[SettingsItem alloc] initWithItemName:@"1920x108030p"];
        sub6.isSubItem = YES;
        sub6.itemAction = @selector(onSetRecordingResolution:);
        sub6.itemValue = [NSValue value:&resolutionType withObjCType:@encode(CameraExposureMeteringType)];
        
        resolutionType = CameraRecordingResolution1920x108060i;
        SettingsItem* sub7 = [[SettingsItem alloc] initWithItemName:@"1920x108060i"];
        sub7.isSubItem = YES;
        sub7.itemAction = @selector(onSetRecordingResolution:);
        sub7.itemValue = [NSValue value:&resolutionType withObjCType:@encode(CameraExposureMeteringType)];
        
        resolutionType = CameraRecordingResolution1920x108025p;
        SettingsItem* sub8 = [[SettingsItem alloc] initWithItemName:@"1920x108025p"];
        sub8.isSubItem = YES;
        sub8.itemAction = @selector(onSetRecordingResolution:);
        sub8.itemValue = [NSValue value:&resolutionType withObjCType:@encode(CameraExposureMeteringType)];
        
        resolutionType = CameraRecordingResolution1280x96025p;
        SettingsItem* sub9 = [[SettingsItem alloc] initWithItemName:@"1280x96025p"];
        sub9.isSubItem = YES;
        sub9.itemAction = @selector(onSetRecordingResolution:);
        sub9.itemValue = [NSValue value:&resolutionType withObjCType:@encode(CameraExposureMeteringType)];
        
        [item5.subSettings addObject:sub1];
        [item5.subSettings addObject:sub2];
        [item5.subSettings addObject:sub3];
        [item5.subSettings addObject:sub4];
        [item5.subSettings addObject:sub5];
        [item5.subSettings addObject:sub6];
        [item5.subSettings addObject:sub7];
        [item5.subSettings addObject:sub8];
        [item5.subSettings addObject:sub9];
    }
    
    SettingsItem* item6 = [[SettingsItem alloc] initWithItemName:@"FOV"];
    item6.itemAction = @selector(onSetRecording:);
    item6.subSettings = [[NSMutableArray alloc] init];
    {
        CameraRecordingFovType FovType = CameraRecordingFOV0;
        SettingsItem* sub1 = [[SettingsItem alloc] initWithItemName:@"FOV0"];
        sub1.isSubItem = YES;
        sub1.itemAction = @selector(onSetRecording:);
        sub1.itemValue = [NSValue value:&FovType withObjCType:@encode(CameraRecordingFovType)];
        
        FovType = CameraRecordingFOV1;
        SettingsItem* sub2 = [[SettingsItem alloc] initWithItemName:@"FOV1"];
        sub2.isSubItem = YES;
        sub2.itemAction = @selector(onSetRecording:);
        sub2.itemValue = [NSValue value:&FovType withObjCType:@encode(CameraRecordingFovType)];
        
        FovType = CameraRecordingFOV2;
        SettingsItem* sub3 = [[SettingsItem alloc] initWithItemName:@"FOV2"];
        sub3.isSubItem = YES;
        sub3.itemAction = @selector(onSetRecording:);
        sub3.itemValue = [NSValue value:&FovType withObjCType:@encode(CameraRecordingFovType)];
     
        
        [item6.subSettings addObject:sub1];
        [item6.subSettings addObject:sub2];
        [item6.subSettings addObject:sub3];
    }

    
    SettingsItem* item7 = [[SettingsItem alloc] initWithItemName:@"PhotoFormat"];
    item7.itemAction = @selector(onSetPhotoFormatType:);
    item7.subSettings = [[NSMutableArray alloc] init];
    {
        CameraPhotoFormatType PhotoFormatType = CameraPhotoRAW ;
        SettingsItem* sub1 = [[SettingsItem alloc] initWithItemName:@"RAW"];
        sub1.isSubItem = YES;
        sub1.itemAction = @selector(onSetPhotoFormatType:);
        sub1.itemValue = [NSValue value:&PhotoFormatType withObjCType:@encode(CameraPhotoFormatType)];
        
        PhotoFormatType = CameraPhotoJPEG ;
        SettingsItem* sub2 = [[SettingsItem alloc] initWithItemName:@"JPG"];
        sub2.isSubItem = YES;
        sub2.itemAction = @selector(onSetPhotoFormatType:);
        sub2.itemValue = [NSValue value:&PhotoFormatType withObjCType:@encode(CameraPhotoFormatType)];
        
        PhotoFormatType = CameraPhotoRAWAndJPEG ;
        SettingsItem* sub3 = [[SettingsItem alloc] initWithItemName:@"RAW+JPG"];
        sub3.isSubItem = YES;
        sub3.itemAction = @selector(onSetPhotoFormatType:);
        sub3.itemValue = [NSValue value:&PhotoFormatType withObjCType:@encode(CameraPhotoFormatType)];
        
        [item7.subSettings addObject:sub1];
        [item7.subSettings addObject:sub2];
        [item7.subSettings addObject:sub3];
    }

    
    SettingsItem* item8 = [[SettingsItem alloc] initWithItemName:@"ExposureCompensation"];
    item8.itemAction = @selector(onSetExposureCompensationType:);
    item8.subSettings = [[NSMutableArray alloc] init];
    {
        CameraExposureCompensationType ExposureCompensationType = CameraExposureCompensationDefault;
        SettingsItem* sub1 = [[SettingsItem alloc] initWithItemName:@"Default"];
        sub1.isSubItem = YES;
        sub1.itemAction = @selector(onSetExposureCompensationType:);
        sub1.itemValue = [NSValue value:&ExposureCompensationType withObjCType:@encode(CameraExposureCompensationType)];
        
        ExposureCompensationType = CameraExposureCompensationN20;
        SettingsItem* sub2 = [[SettingsItem alloc] initWithItemName:@"-2.0"];
        sub2.isSubItem = YES;
        sub2.itemAction = @selector(onSetExposureCompensationType:);
        sub2.itemValue = [NSValue value:&ExposureCompensationType withObjCType:@encode(CameraExposureCompensationType)];
        
        ExposureCompensationType = CameraExposureCompensationN17;
        SettingsItem* sub3 = [[SettingsItem alloc] initWithItemName:@"-1.7"];
        sub3.isSubItem = YES;
        sub3.itemAction = @selector(onSetExposureCompensationType:);
        sub3.itemValue = [NSValue value:&ExposureCompensationType withObjCType:@encode(CameraExposureCompensationType)];
        
        ExposureCompensationType = CameraExposureCompensationN13;
        SettingsItem* sub4 = [[SettingsItem alloc] initWithItemName:@"-1.3"];
        sub4.isSubItem = YES;
        sub4.itemAction = @selector(onSetExposureCompensationType:);
        sub4.itemValue = [NSValue value:&ExposureCompensationType withObjCType:@encode(CameraExposureCompensationType)];
        
        ExposureCompensationType = CameraExposureCompensationN10;
        SettingsItem* sub5 = [[SettingsItem alloc] initWithItemName:@"-1.0"];
        sub5.isSubItem = YES;
        sub5.itemAction = @selector(onSetExposureCompensationType:);
        sub5.itemValue = [NSValue value:&ExposureCompensationType withObjCType:@encode(CameraExposureCompensationType)];
        
        ExposureCompensationType = CameraExposureCompensationN07;
        SettingsItem* sub6 = [[SettingsItem alloc] initWithItemName:@"-0.7"];
        sub6.isSubItem = YES;
        sub6.itemAction = @selector(onSetExposureCompensationType:);
        sub6.itemValue = [NSValue value:&ExposureCompensationType withObjCType:@encode(CameraExposureCompensationType)];
        
        
        ExposureCompensationType = CameraExposureCompensationN03;
        SettingsItem* sub7 = [[SettingsItem alloc] initWithItemName:@"-0.3"];
        sub7.isSubItem = YES;
        sub7.itemAction = @selector(onSetExposureCompensationType:);
        sub7.itemValue = [NSValue value:&ExposureCompensationType withObjCType:@encode(CameraExposureCompensationType)];
        
        
        ExposureCompensationType = CameraExposureCompensationN00;
        SettingsItem* sub8 = [[SettingsItem alloc] initWithItemName:@"0"];
        sub8.isSubItem = YES;
        sub8.itemAction = @selector(onSetExposureCompensationType:);
        sub8.itemValue = [NSValue value:&ExposureCompensationType withObjCType:@encode(CameraExposureCompensationType)];
        
        ExposureCompensationType = CameraExposureCompensationP03;
        SettingsItem* sub9 = [[SettingsItem alloc] initWithItemName:@"+0.3"];
        sub9.isSubItem = YES;
        sub9.itemAction = @selector(onSetExposureCompensationType:);
        sub9.itemValue = [NSValue value:&ExposureCompensationType withObjCType:@encode(CameraExposureCompensationType)];
        
        ExposureCompensationType = CameraExposureCompensationP07;
        SettingsItem* sub10 = [[SettingsItem alloc] initWithItemName:@"+0.7"];
        sub10.isSubItem = YES;
        sub10.itemAction = @selector(onSetExposureCompensationType:);
        sub10.itemValue = [NSValue value:&ExposureCompensationType withObjCType:@encode(CameraExposureCompensationType)];
        
        ExposureCompensationType = CameraExposureCompensationP10;
        SettingsItem* sub11 = [[SettingsItem alloc] initWithItemName:@"+1.0"];
        sub11.isSubItem = YES;
        sub11.itemAction = @selector(onSetExposureCompensationType:);
        sub11.itemValue = [NSValue value:&ExposureCompensationType withObjCType:@encode(CameraExposureCompensationType)];
        
        ExposureCompensationType = CameraExposureCompensationP13;
        SettingsItem* sub12 = [[SettingsItem alloc] initWithItemName:@"+1.3"];
        sub12.isSubItem = YES;
        sub12.itemAction = @selector(onSetExposureCompensationType:);
        sub12.itemValue = [NSValue value:&ExposureCompensationType withObjCType:@encode(CameraExposureCompensationType)];
        
        ExposureCompensationType = CameraExposureCompensationP17;
        SettingsItem* sub13 = [[SettingsItem alloc] initWithItemName:@"+1.7"];
        sub13.isSubItem = YES;
        sub13.itemAction = @selector(onSetExposureCompensationType:);
        sub13.itemValue = [NSValue value:&ExposureCompensationType withObjCType:@encode(CameraExposureCompensationType)];
        
        ExposureCompensationType = CameraExposureCompensationP20;
        SettingsItem* sub14 = [[SettingsItem alloc] initWithItemName:@"+2.0"];
        sub14.isSubItem = YES;
        sub14.itemAction = @selector(onSetExposureCompensationType:);
        sub14.itemValue = [NSValue value:&ExposureCompensationType withObjCType:@encode(CameraExposureCompensationType)];
        
        [item8.subSettings addObject:sub1];
        [item8.subSettings addObject:sub2];
        [item8.subSettings addObject:sub3];
        [item8.subSettings addObject:sub4];
        [item8.subSettings addObject:sub5];
        [item8.subSettings addObject:sub6];
        [item8.subSettings addObject:sub7];
        [item8.subSettings addObject:sub8];
        [item8.subSettings addObject:sub9];
        [item8.subSettings addObject:sub10];
        [item8.subSettings addObject:sub11];
        [item8.subSettings addObject:sub12];
        [item8.subSettings addObject:sub13];
        [item8.subSettings addObject:sub14];
    }

    SettingsItem* item9 = [[SettingsItem alloc] initWithItemName:@"AntiFlicker"];
    item9.itemAction = @selector(onSetAntiFlickerType:);
    item9.subSettings = [[NSMutableArray alloc] init];
    {
        CameraAntiFlickerType AntiFlickerType = CameraAntiFlickerAuto;
        SettingsItem* sub1 = [[SettingsItem alloc] initWithItemName:@"Auto"];
        sub1.isSubItem = YES;
        sub1.itemAction = @selector(onSetAntiFlickerType:);
        sub1.itemValue = [NSValue value:&AntiFlickerType withObjCType:@encode(CameraAntiFlickerType)];
    
        AntiFlickerType =CameraAntiFlicker60Hz;
        SettingsItem* sub2 = [[SettingsItem alloc] initWithItemName:@"60Hz"];
        sub2.isSubItem = YES;
        sub2.itemAction = @selector(onSetAntiFlickerType:);
        sub2.itemValue = [NSValue value:&AntiFlickerType withObjCType:@encode(CameraAntiFlickerType)];
        
        AntiFlickerType =CameraAntiFlicker50Hz;
        SettingsItem* sub3 = [[SettingsItem alloc] initWithItemName:@"50Hz"];
        sub3.isSubItem = YES;
        sub3.itemAction = @selector(onSetAntiFlickerType:);
        sub3.itemValue = [NSValue value:&AntiFlickerType withObjCType:@encode(CameraAntiFlickerType)];
        
        [item9.subSettings addObject:sub1];
        [item9.subSettings addObject:sub2];
        [item9.subSettings addObject:sub3];
    
    }
    
    
    SettingsItem* item10 = [[SettingsItem alloc] initWithItemName:@"Sharpness"];
    item10.itemAction = @selector(onSetSharpnessType:);
    item10.subSettings = [[NSMutableArray alloc] init];
    {
        CameraSharpnessType SharpnessType = CameraSharpnessStandard;
        SettingsItem* sub1 = [[SettingsItem alloc] initWithItemName:@"Standard"];
        sub1.isSubItem = YES;
        sub1.itemAction = @selector(onSetSharpnessType:);
        sub1.itemValue = [NSValue value:&SharpnessType withObjCType:@encode(CameraSharpnessType)];
        
        SharpnessType = CameraSharpnessHard;
        SettingsItem* sub2 = [[SettingsItem alloc] initWithItemName:@"Hard"];
        sub2.isSubItem = YES;
        sub2.itemAction = @selector(onSetSharpnessType:);
        sub2.itemValue = [NSValue value:&SharpnessType withObjCType:@encode(CameraSharpnessType)];
        
        SharpnessType = CameraSharpnessSoft;
        SettingsItem* sub3 = [[SettingsItem alloc] initWithItemName:@"Soft"];
        sub3.isSubItem = YES;
        sub3.itemAction = @selector(onSetSharpnessType:);
        sub3.itemValue = [NSValue value:&SharpnessType withObjCType:@encode(CameraSharpnessType)];

        [item10.subSettings addObject:sub1];
        [item10.subSettings addObject:sub2];
        [item10.subSettings addObject:sub3];
    }
    
    SettingsItem* item11 = [[SettingsItem alloc] initWithItemName:@"Contrast"];
    item11.itemAction = @selector(onSetContrastType:);
    item11.subSettings = [[NSMutableArray alloc] init];
    {
        CameraContrastType ContrastType = CameraContrastStandard;
        SettingsItem* sub1 = [[SettingsItem alloc] initWithItemName:@"Standard"];
        sub1.isSubItem = YES;
        sub1.itemAction = @selector(onSetContrastType:);
        sub1.itemValue = [NSValue value:&ContrastType withObjCType:@encode(CameraContrastType)];
        
        ContrastType = CameraContrastHard;
        SettingsItem* sub2 = [[SettingsItem alloc] initWithItemName:@"Hard"];
        sub2.isSubItem = YES;
        sub2.itemAction = @selector(onSetContrastType:);
        sub2.itemValue = [NSValue value:&ContrastType withObjCType:@encode(CameraContrastType)];
        
        ContrastType = CameraContrastSoft;
        SettingsItem* sub3 = [[SettingsItem alloc] initWithItemName:@"Soft"];
        sub3.isSubItem = YES;
        sub3.itemAction = @selector(onSetContrastType:);
        sub3.itemValue = [NSValue value:&ContrastType withObjCType:@encode(CameraContrastType)];

        [item11.subSettings addObject:sub1];
        [item11.subSettings addObject:sub2];
        [item11.subSettings addObject:sub3];
        
    }
    
    
    SettingsItem* item12 = [[SettingsItem alloc] initWithItemName:@"ActionWhenBreak"];
    item12.itemAction = @selector(onSetActionWhenBreak:);
    item12.subSettings = [[NSMutableArray alloc] init];
    {
        CameraActionWhenBreak ActionWhenBreak = CameraKeepCurrentState;
        SettingsItem* sub1 = [[SettingsItem alloc] initWithItemName:@"KeepCurrentState"];
        sub1.isSubItem = YES;
        sub1.itemAction = @selector(onSetActionWhenBreak:);
        sub1.itemValue = [NSValue value:&ActionWhenBreak withObjCType:@encode(CameraActionWhenBreak)];
        
        ActionWhenBreak = CameraEnterContiuousShooting;
        SettingsItem* sub2 = [[SettingsItem alloc] initWithItemName:@"EnterContiuousShooting"];
        sub2.isSubItem = YES;
        sub2.itemAction = @selector(onSetActionWhenBreak:);
        sub2.itemValue = [NSValue value:&ActionWhenBreak withObjCType:@encode(CameraActionWhenBreak)];

        ActionWhenBreak = CameraEnterRecording;
        SettingsItem* sub3 = [[SettingsItem alloc] initWithItemName:@"EnterRecording"];
        sub3.isSubItem = YES;
        sub3.itemAction = @selector(onSetActionWhenBreak:);
        sub3.itemValue = [NSValue value:&ActionWhenBreak withObjCType:@encode(CameraActionWhenBreak)];

        [item12.subSettings addObject:sub1];
        [item12.subSettings addObject:sub2];
        [item12.subSettings addObject:sub3];
    }

    SettingsItem* item13 = [[SettingsItem alloc] initWithItemName:@"MultiCapture"];
    item13.itemAction = @selector(onSetMultiCaptureCount:);
    item13.subSettings = [[NSMutableArray alloc] init];
    {
        CameraMultiCaptureCount MultiCaptureCount = CameraMultiCapture3;
        SettingsItem* sub1 = [[SettingsItem alloc] initWithItemName:@"3"];
        sub1.isSubItem = YES;
        sub1.itemAction = @selector(onSetMultiCaptureCount:);
        sub1.itemValue = [NSValue value:&MultiCaptureCount withObjCType:@encode(CameraMultiCaptureCount)];
    
        MultiCaptureCount = CameraMultiCapture5;
        SettingsItem* sub2 = [[SettingsItem alloc] initWithItemName:@"5"];
        sub2.isSubItem = YES;
        sub2.itemAction = @selector(onSetMultiCaptureCount:);
        sub2.itemValue = [NSValue value:&MultiCaptureCount withObjCType:@encode(CameraMultiCaptureCount)];
        
        [item13.subSettings addObject:sub1];
        [item13.subSettings addObject:sub2];
        
    }
    
    SettingsItem* item14 = [[SettingsItem alloc] initWithItemName:@"VideoQuality"];
    item14.itemAction = @selector(onSetVideoQuality:);
    item14.subSettings = [[NSMutableArray alloc] init];
    {
        VideoQuality  Quality = Video320x24015fps;
        SettingsItem* sub1 = [[SettingsItem alloc] initWithItemName:@"320x24015fps"];
        sub1.isSubItem = YES;
        sub1.itemAction = @selector(onSetVideoQuality:);
        sub1.itemValue = [NSValue value:&Quality withObjCType:@encode(VideoQuality)];
        
        Quality = Video320x24030fps ;
        SettingsItem* sub2 = [[SettingsItem alloc] initWithItemName:@"320x24030fps"];
        sub2.isSubItem = YES;
        sub2.itemAction = @selector(onSetVideoQuality:);
        sub2.itemValue = [NSValue value:&Quality withObjCType:@encode(VideoQuality)];
        
        Quality = Video640x48015fps ;
        SettingsItem* sub3 = [[SettingsItem alloc] initWithItemName:@"640x48015fps"];
        sub3.isSubItem = YES;
        sub3.itemAction = @selector(onSetVideoQuality:);
        sub3.itemValue = [NSValue value:&Quality withObjCType:@encode(VideoQuality)];
        
        Quality = Video640x48030fps ;
        SettingsItem* sub4 = [[SettingsItem alloc] initWithItemName:@"640x48030fps"];
        sub4.isSubItem = YES;
        sub4.itemAction = @selector(onSetVideoQuality:);
        sub4.itemValue = [NSValue value:&Quality withObjCType:@encode(VideoQuality)];
        
        [item14.subSettings addObject:sub1];
        [item14.subSettings addObject:sub2];
        [item14.subSettings addObject:sub3];
        [item14.subSettings addObject:sub4];
    }
    
    SettingsItem* item15 = [[SettingsItem alloc] initWithItemName:@"GPS"];
    item15.itemAction = @selector(onSetCameraGPS:);
    item15.subSettings = [[NSMutableArray alloc] init];
    {
        SettingsItem* sub1 = [[SettingsItem alloc] initWithItemName:@"22.01234, 113.1234"];
        sub1.isSubItem = YES;
        sub1.itemAction = @selector(onSetCameraGPS:);
        [item15.subSettings addObject:sub1];
    }
    
    SettingsItem* item16 = [[SettingsItem alloc] initWithItemName:@"Save Settings"];
    item16.itemAction = @selector(onSetSaveCameraSettings:);
    item16.subSettings = [[NSMutableArray alloc] init];
    
    SettingsItem* item17 = [[SettingsItem alloc] initWithItemName:@"Restore"];
    item17.itemAction = @selector(onSetrestoreCameraDefaultSettings:);
    item17.subSettings = [[NSMutableArray alloc] init];
 
    SettingsItem* item18 = [[SettingsItem alloc] initWithItemName:@"SDCard Info"];
    item18.itemAction = @selector(onSetgetSDCardInfo:);
    item18.subSettings = [[NSMutableArray alloc] init];
    
    SettingsItem* item19 = [[SettingsItem alloc] initWithItemName:@"Format SDCard"];
    item19.itemAction = @selector(onSetformatSDCard:);
    item19.subSettings = [[NSMutableArray alloc] init];
    
    SettingsItem* item20 = [[SettingsItem alloc] initWithItemName:@"CaptureMode"];
    item20.itemAction = @selector(onSetCameraCaptureMode:);
    item20.subSettings = [[NSMutableArray alloc] init];
    {
        CameraCaptureMode   captureMode = CameraSingleCapture;
        SettingsItem* sub1 = [[SettingsItem alloc] initWithItemName:@"SingleCapture"];
        sub1.isSubItem = YES;
        sub1.itemAction = @selector(onSetCameraCaptureMode:);
        sub1.itemValue = [NSValue value:&captureMode withObjCType:@encode(CameraCaptureMode)];
    
        captureMode = CameraMultiCapture ;
        SettingsItem* sub2 = [[SettingsItem alloc] initWithItemName:@"MultiCapture"];
        sub2.isSubItem = YES;
        sub2.itemAction = @selector(onSetCameraCaptureMode:);
        sub2.itemValue = [NSValue value:&captureMode withObjCType:@encode(CameraCaptureMode)];
        
        captureMode =  CameraContinousCapture ;
        SettingsItem* sub3 = [[SettingsItem alloc] initWithItemName:@"ContinousCapture"];
        sub3.isSubItem = YES;
        sub3.itemAction = @selector(onSetCameraCaptureMode:);
        sub3.itemValue = [NSValue value:&captureMode withObjCType:@encode(CameraCaptureMode)];
        
        [item20.subSettings addObject:sub1];
        [item20.subSettings addObject:sub2];
        [item20.subSettings addObject:sub3];
 
    }
    [_mainSettingItems addObject:item100];
    [_mainSettingItems addObject:item101];
    [_mainSettingItems addObject:item1];
    [_mainSettingItems addObject:item2];
    [_mainSettingItems addObject:item3];
    [_mainSettingItems addObject:item4];
    [_mainSettingItems addObject:item5];
    [_mainSettingItems addObject:item6];
    [_mainSettingItems addObject:item7];
    [_mainSettingItems addObject:item8];
    [_mainSettingItems addObject:item9];
    [_mainSettingItems addObject:item10];
    [_mainSettingItems addObject:item11];
    [_mainSettingItems addObject:item12];
    [_mainSettingItems addObject:item13];
    [_mainSettingItems addObject:item14];
    [_mainSettingItems addObject:item15];
    [_mainSettingItems addObject:item16];
    [_mainSettingItems addObject:item17];
    [_mainSettingItems addObject:item18];
    [_mainSettingItems addObject:item19];
    [_mainSettingItems addObject:item20];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableView1) {
        return _mainSettingItems.count;
    }
    else
    {
        if (_selectedItem && _selectedItem.subSettings) {
            return _selectedItem.subSettings.count;
        }
        else
        {
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* s_Identifier1 = @"s_Identifier1";
    static NSString* s_Identifier2 = @"s_Identifier2";
    if (tableView == _tableView1) {
        CustomTableViewCell* cell = [_tableView1 dequeueReusableCellWithIdentifier:s_Identifier1];
        if (cell == Nil) {
            cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:s_Identifier1];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.font = [UIFont systemFontOfSize:13];
        }
        SettingsItem* item = [_mainSettingItems objectAtIndex:indexPath.row];
        cell.textLabel.text = item.itemName;
        cell.settingItem = item;
        
        return cell;
    }
    else
    {
        CustomTableViewCell* cell = [_tableView2 dequeueReusableCellWithIdentifier:s_Identifier2];
        if (cell == Nil) {
            cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:s_Identifier2];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.font = [UIFont systemFontOfSize:13];
        }
        SettingsItem* item = [_selectedItem.subSettings objectAtIndex:indexPath.row];
        cell.textLabel.text = item.itemName;
        cell.settingItem = item;
        
        return cell;
    }
    
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView1) {
        SettingsItem* item = [_mainSettingItems objectAtIndex:indexPath.row];
        if (item.subSettings && item.subSettings.count > 0) {
            _tableView2.alpha = 1.0;
        }
        else
        {
            _tableView2.alpha = 0.0;
        }
        [self performSelectorOnMainThread:item.itemAction withObject:item waitUntilDone:YES];
    }
    else
    {
        SettingsItem* item = [_selectedItem.subSettings objectAtIndex:indexPath.row];
        [self performSelectorOnMainThread:item.itemAction withObject:item waitUntilDone:YES];
    }
}

-(void) setCheckmarkForItem:(SettingsItem*)item
{
    NSArray* visibleCells = _tableView2.visibleCells;
    for (CustomTableViewCell* aCell in visibleCells) {
        if (aCell.settingItem == item) {
            aCell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            aCell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    }
}

-(void) onSetCameraWorkMode:(SettingsItem*)item
{
    DJIInspireCamera* inspireCamera = (DJIInspireCamera*)_camera;
    if (item.isSubItem) {
        CameraWorkMode workMode;
        NSValue* itemValue = item.itemValue;
        [itemValue getValue:&workMode];
        
        [inspireCamera setCameraWorkMode:workMode withResult:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                NSLog(@"Set Work Mode Success");
            }
            else
            {
                NSLog(@"Set Work Mode Failed");
            }
        }];
    }
    else
    {
        [inspireCamera getCameraWorkModeWithResult:^(CameraWorkMode workMode, DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                int index = (int)workMode;
                SettingsItem* item = [_selectedItem.subSettings objectAtIndex:index];
                [self setCheckmarkForItem:item];
            }
            else
            {
                
            }
        }];
        _selectedItem = item;
        [_tableView2 reloadData];
    }
}

-(void) onSetCameraExposureMode:(SettingsItem*)item
{
    DJIInspireCamera* inspireCamera = (DJIInspireCamera*)_camera;
    if (item.isSubItem) {
        CameraExposureMode exposureMode;
        NSValue* itemValue = item.itemValue;
        [itemValue getValue:&exposureMode];
        
        [inspireCamera setCameraExposureMode:exposureMode withResult:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                NSLog(@"Set ExposureMode Success");
            }
            else
            {
                NSLog(@"Set ExposureMode Failed");
            }
        }];
    }
    else
    {
        [inspireCamera getCameraExposureModeWithResult:^(CameraExposureMode exposureMode, DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                int index = (int)exposureMode;
                SettingsItem* item = [_selectedItem.subSettings objectAtIndex:index];
                [self setCheckmarkForItem:item];
            }
            else
            {
                
            }
        }];
        _selectedItem = item;
        [_tableView2 reloadData];
    }
}

-(void) onSetPhotoSize:(SettingsItem*)item
{
    if (item.isSubItem) {
        CameraPhotoSizeType photoSize;// = CameraPhotoSizeUnknown;
        NSValue* itemValue = item.itemValue;
        [itemValue getValue:&photoSize];

        [_camera setCameraPhotoSize:photoSize withResultBlock:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                NSLog(@"Set Photo Size Success");
            }
            else
            {
                NSLog(@"Set Photo Size Failed");
            }
        }];
    }
    else
    {
        [_camera getCameraPhotoSize:^(CameraPhotoSizeType photoSize, DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                int index = (int)photoSize;
                SettingsItem* item = [_selectedItem.subSettings objectAtIndex:index];
                [self setCheckmarkForItem:item];
            }
            else
            {
                
            }
        }];
        _selectedItem = item;
        [_tableView2 reloadData];
    }
}

-(void) onSetISOType:(SettingsItem*)item
{
    if (item.isSubItem) {
        CameraISOType isoType;
        NSValue* itemValue = item.itemValue;
        [itemValue getValue:&isoType];
        [_camera setCameraISO:isoType withResultBlock:^(DJIError *error)
         {
             
             if (error.errorCode == ERR_Succeeded)
             {
                 NSLog(@"Set iso Type Success");
                 
             }
             else
             {
                 NSLog(@"Set iso Type Failed");
             }
             
         }];
    }
    else
    {
        [_camera getCameraISO:^(CameraISOType iso, DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                int index = (int)iso;
                SettingsItem* item =[_selectedItem.subSettings objectAtIndex:index];
                [self setCheckmarkForItem:item];
            }
           else
        
         {
             
         }
        }];
        
        _selectedItem = item;
        [_tableView2 reloadData];
    }
}

-(void) onSetWhiteBalance:(SettingsItem*)item
{
    if (item.isSubItem) {
        CameraWhiteBalanceType whiteBalance;
        NSValue* itemValue = item.itemValue;
        [itemValue getValue:&whiteBalance];
        [_camera setCameraWhiteBalance:whiteBalance withResultBlock:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                NSLog(@"Set WhiteBalance Type Success");
            }
            else
            {
                NSLog(@"Set WhiteBalance Type Failed");
            }
        
        }];
    }
    else
    {
        [_camera getCameraWhiteBalance:^(CameraWhiteBalanceType whiteBalance, DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                int index = (int)whiteBalance ;
                SettingsItem* item=[_selectedItem.subSettings objectAtIndex:index];
                [self setCheckmarkForItem:item];
            }
        }];
         _selectedItem = item;
        [_tableView2 reloadData];
    }
}

-(void) onSetExposureMetering:(SettingsItem*)item
{
    if (item.isSubItem) {
        CameraExposureMeteringType exposureMetering;
        NSValue* itemValue = item.itemValue;
        [itemValue getValue:&exposureMetering];
        [_camera setCameraExposureMetering:exposureMetering withResultBlock:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                NSLog(@"Set Exposure Metering Type Success");
            }
            else {
                NSLog(@"Set Exposure Metering Type Failed");
            }
        }];
       
    }
    else
    {
        [_camera getCameraExposureMetering:^(CameraExposureMeteringType exposureMetering, DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                int index = (int)exposureMetering ;
                SettingsItem* item =[_selectedItem.subSettings objectAtIndex:index];
                [self setCheckmarkForItem:item];
            }
        }];
        _selectedItem = item;
        [_tableView2 reloadData];
    }
}

-(void) onSetRecordingResolution:(SettingsItem*)item
{
    if (item.isSubItem) {
        
        NSValue* itemValue = item.itemValue;
        [itemValue getValue:&_resolutionType];
        [_camera setCameraRecordingResolution:_resolutionType andFOV:_fovType withResultBlock:^(DJIError *error) {
           
            if (error.errorCode == ERR_Succeeded) {
                NSLog(@"Set RecodingResolution Success");
            }
            else{
                NSLog(@"Set RecodingResolution Failed:(%d)", error.errorCode);
            }
            
        }];

    }
    else
    {
        [_camera getCameraRecordingResolution:^(CameraRecordingResolutionType resolution, CameraRecordingFovType fov, DJIError *error) {
           
            if (error.errorCode == ERR_Succeeded) {
                int index = (int)resolution;
                if (index <= CameraRecordingResolution1280x96025p) {
                    SettingsItem* item =[_selectedItem.subSettings objectAtIndex: index];
                    [self setCheckmarkForItem:item];
                }
                NSLog(@"Get Resolution:%d FOV:%d", resolution, fov);
            }
        }];
        _selectedItem = item;
        [_tableView2 reloadData];
    }
}

-(void) onSetRecording:(SettingsItem*)item
{
    if (item.isSubItem) {
        NSValue* itemValue = item.itemValue;
        [itemValue getValue:&_fovType];
        [_camera setCameraRecordingResolution:_resolutionType andFOV:_fovType withResultBlock:^(DJIError *error) {
           
            if (error.errorCode == ERR_Succeeded) {
                NSLog(@"Set Recoding Success");
            }
            else{
                NSLog(@"Set Recoding Failed");
            }
            
        }];
    }
    else
    {
        [_camera getCameraRecordingResolution:^(CameraRecordingResolutionType resolution, CameraRecordingFovType fov, DJIError *error) {
            
            if (error.errorCode == ERR_Succeeded) {
                int index = (int)fov;
                if (index <= CameraRecordingFOV2) {
                    SettingsItem* item =[_selectedItem.subSettings objectAtIndex: index];
                    [self setCheckmarkForItem:item];
                }
                
                NSLog(@"Get Resolution:%d FOV:%d", resolution, fov);
            }
        }];
        
        _selectedItem = item;
        [_tableView2 reloadData];
    }
}

-(void) onSetPhotoFormatType:(SettingsItem*)item
{
    if (item.isSubItem) {
        CameraPhotoFormatType photoFormatType;
        NSValue* itemValue = item.itemValue;
        [itemValue getValue:&photoFormatType];
        [_camera setCameraPhotoFormat:photoFormatType withResultBlock:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                NSLog(@"Set Photo Format Type Success");
            }
            else{
                
                NSLog(@"Set Photo Format Type Failed");
            }
 
        }];
        
    }
    else
    {
        [_camera getCameraPhotoFormat:^(CameraPhotoFormatType photoFormat, DJIError *error) {
            if (error.errorCode ==ERR_Succeeded) {
                int index = (int)photoFormat ;
                SettingsItem* item =[_selectedItem.subSettings objectAtIndex:index];
                [self setCheckmarkForItem:item];
            }
        }];
        _selectedItem = item;
        [_tableView2 reloadData];
    }
}

-(void) onSetExposureCompensationType:(SettingsItem*)item
{
    if (item.isSubItem) {
        CameraExposureCompensationType  exposureCompensationType;
        NSValue* itemValue = item.itemValue;
        [itemValue getValue:&exposureCompensationType];
        [_camera setCameraExposureCompensation:exposureCompensationType withResultBlock:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                NSLog(@"Set Exposure Compensation Success");
            }
            else{
                NSLog(@"Set Exposure Compensation Failed");
            }
        }];
    }
    else
    {
        [_camera getCameraExposureCompensation:^(CameraExposureCompensationType exposureCompensation, DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                int index = (int) exposureCompensation;
                SettingsItem* item =[_selectedItem.subSettings objectAtIndex:index];
                [self setCheckmarkForItem:item];
            }
        }];
        _selectedItem = item;
        [_tableView2 reloadData];
    }
}

-(void) onSetAntiFlickerType:(SettingsItem*)item
    {
    if (item.isSubItem) {
        CameraAntiFlickerType antiFlickerType;
        NSValue* itemValue = item.itemValue;
        [itemValue getValue:&antiFlickerType];
        [_camera setCameraAntiFlicker:antiFlickerType withResultBlock:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                NSLog(@"Set Antiflicker Type Success");
            }
            else{
                NSLog(@"Set Antiflicker Type Failed");
            }
        }];
    }
    else
    {
        [_camera getCameraAntiFlicker:^(CameraAntiFlickerType antiFlicker, DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
               int index = (int) antiFlicker;
               SettingsItem* item =[_selectedItem.subSettings objectAtIndex:index];
               [self setCheckmarkForItem:item];
            }
        }];
        _selectedItem = item;
        [_tableView2 reloadData];
    }
}

-(void) onSetSharpnessType:(SettingsItem*)item
{
    if (item.isSubItem) {
        CameraSharpnessType SharpnessType;
        NSValue* itemValue = item.itemValue;
        [itemValue getValue:&SharpnessType];
        [_camera setCameraSharpness:SharpnessType withResultBlock:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                NSLog(@"Set Sharpness Type Success");
            }
            else{
                NSLog(@"Set Sharpness Type Failed");
            }
        }];
    }
    else
    {
        [_camera getCameraSharpness:^(CameraSharpnessType sharpness, DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                int index = (int)sharpness;
                SettingsItem* item =[_selectedItem.subSettings objectAtIndex:index];
                [self setCheckmarkForItem:item];
            }
        }];
        _selectedItem = item;
        [_tableView2 reloadData];
    }
}

-(void) onSetContrastType:(SettingsItem*)item
{
    if (item.isSubItem) {
        CameraContrastType  contrastType;
        NSValue* itemValue = item.itemValue;
        [itemValue getValue:&contrastType];
        [_camera setCameraContrast:contrastType withResultBlock:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                NSLog(@"Set Contrast Type Success");
            }
            else{
                NSLog(@"Set Contrast Type Failed");
            }
        }];
    }
    else
    {   [_camera getCameraContrast:^(CameraContrastType contrast, DJIError *error) {
        if (error.errorCode == ERR_Succeeded) {
            int index = (int)contrast;
            SettingsItem* item =[_selectedItem.subSettings objectAtIndex:index];
            [self setCheckmarkForItem:item];
        }
    }];
        
        _selectedItem = item;
        [_tableView2 reloadData];
    }
}

-(void) onSetActionWhenBreak:(SettingsItem*)item
{
    if (item.isSubItem) {
        CameraActionWhenBreak actionWhenBreak;
        NSValue* itemValue = item.itemValue;
        [itemValue getValue:&actionWhenBreak];
        [_camera setCameraActionWhenConnectionBroken:actionWhenBreak withResultBlock:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                NSLog(@"Set ActionWhenBreak Success");
            }
            else{
                NSLog(@"Set ActionWhenBreak Success");
            }
        }];
        
    }
    else
    {   [_camera getCameraActionWhenConnectionBroken:^(CameraActionWhenBreak cameraAction, DJIError *error) {
        if (error.errorCode == ERR_Succeeded) {
            int index = (int)cameraAction;
            SettingsItem* item =[_selectedItem.subSettings objectAtIndex:index];
            [self setCheckmarkForItem:item];
        }
    }];
        _selectedItem = item;
        [_tableView2 reloadData];
    }
}

-(void) onSetMultiCaptureCount:(SettingsItem*)item
{
    if (item.isSubItem) {
        CameraMultiCaptureCount multiCaptureCount;
        NSValue* itemValue = item.itemValue;
        [itemValue getValue:&multiCaptureCount];
        [_camera setMultiCaptureCount:multiCaptureCount withResultBlock:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                NSLog(@"Set MultiCapture Count Success");
            }
            else{
                NSLog(@"Set MultiCapture Count Failed");
            
            }
        }];
    }
    else
    {
        [_camera getMultiCaptureCount:^(CameraMultiCaptureCount multiCaptureCount, DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                int index = (int)multiCaptureCount;
                if (index == 3) {
                    index = 0;
                }
                if (index == 5) {
                    index = 1;
                }
                SettingsItem* item =[_selectedItem.subSettings objectAtIndex:index];
                [self setCheckmarkForItem:item];
            }
            
        }];
        _selectedItem = item;
        [_tableView2 reloadData];
    }
}


-(void) onSetVideoQuality:(SettingsItem*)item
{
    if (item.isSubItem) {
        VideoQuality quality;
        NSValue* itemValue = item.itemValue;
        [itemValue getValue:&quality];
        [_camera setVideoQuality:quality withResultBlock:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                NSLog(@"Set Video Quality Success");
            }
            else{
                NSLog(@"Set Video Quality Failed");
            }
            
        }];
        
    }
    else
    {
        _selectedItem = item;
        [_tableView2 reloadData];
    }
}

-(void) onSetCameraGPS:(SettingsItem*)item
{
    if (item.isSubItem) {
        CLLocationCoordinate2D cameraGPS = {22.01234, 113.1234};
        [_camera setCameraGps:cameraGPS withResultBlock:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                NSLog(@"Set GPS Success");
            }
            else{
                NSLog(@"Set GPS Failed");
            }
            
        }];
    }
    else
    {
        [_camera getCameraGps:^(CLLocationCoordinate2D coordinate, DJIError *error)
         {
             if (error.errorCode==ERR_Succeeded)
             {
                 NSLog(@"Get GPS {%f,%f}",coordinate.latitude, coordinate.longitude);
             }
             else
             {
                 NSLog(@"Get GPS Failed");
             }
         }];
        
        _selectedItem = item;
        [_tableView2 reloadData];
     }
}



-(void) onSetSaveCameraSettings:(SettingsItem*)item
{
    if (item.isSubItem)
    {
        [_camera saveCameraSettings:^(DJIError *error)
        {
            if (error.errorCode == ERR_Succeeded)
            {
                
                NSLog(@"Save Camera Settings Success");
                
            }
            else
            {
                NSLog(@"Save Camera Settings Failed");
            }
            
        }];
        
    }
    else
    {
        [_camera saveCameraSettings:^(DJIError *error)
        {
            if (error.errorCode == ERR_Succeeded)
            {
                
                NSLog(@"Save Camera Settings Success");
                
            }
            else
            {
                NSLog(@"Save Camera Settings Failed");
            }
            
        }];
        _selectedItem = item;
        [_tableView2 reloadData];
    }
}





-(void) onSetrestoreCameraDefaultSettings:(SettingsItem*)item
{
    if (item.isSubItem) {
        [_camera restoreCameraDefaultSettings:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                
                NSLog(@"Restore Camera Default Settings Success");
            
            }
            else{
                NSLog(@"Restore Camera Default Settings Failed");
            }
            
        }];
        
    }
    else
    {
        [_camera restoreCameraDefaultSettings:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                
                NSLog(@"Restore Camera Default Settings Success");
                
            }
            else{
                
                NSLog(@"Restore Camera Default Settings Failed");
            }
            
        }];
        _selectedItem = item;
        [_tableView2 reloadData];
    }
}



-(void) onSetgetSDCardInfo:(SettingsItem*)item
{
    if (item.isSubItem)
    {
        
        [_camera getSDCardInfo:^(DJICameraSDCardInfo *sdInfo, DJIError *error)
        {
            if (error.errorCode == ERR_Succeeded)
            {
                NSLog(@"Get SDCard Info Success");
                NSLog(@"SDCard hasError : %d", sdInfo.hasError);
                NSLog(@"SDCard readOnly : %d", sdInfo.readOnly);
                NSLog(@"SDCard invalidFormat : %d", sdInfo.invalidFormat);
                NSLog(@"SDCard isFormated : %d", sdInfo.isFormated);
                NSLog(@"SDCard isFormating : %d", sdInfo.isFormating);
                NSLog(@"SDCard isFull : %d", sdInfo.isFull);
                NSLog(@"SDCard isValid : %d", sdInfo.isValid);
                NSLog(@"SDCard Inserted : %d", sdInfo.isInserted);
                NSLog(@"SDCard totalSize : %d MB", sdInfo.totalSize);
                NSLog(@"SDCard remainSize : %d MB", sdInfo.remainSize);
                NSLog(@"SDCard availableCaptureCount : %d\n",sdInfo.availableCaptureCount);

        
            }
            else
            {
                NSLog(@"Get SDCard Info Failed\n");
            
            }
        }];
    }
    else
    {
        [_camera getSDCardInfo:^(DJICameraSDCardInfo *sdInfo, DJIError *error)
        {
            if (error.errorCode == ERR_Succeeded)
            {
                NSLog(@"Get SDCard Info Success");
                NSLog(@"SDCard hasError : %d", sdInfo.hasError);
                NSLog(@"SDCard readOnly : %d", sdInfo.readOnly);
                NSLog(@"SDCard invalidFormat : %d", sdInfo.invalidFormat);
                NSLog(@"SDCard isFormated : %d", sdInfo.isFormated);
                NSLog(@"SDCard isFormating : %d", sdInfo.isFormating);
                NSLog(@"SDCard isFull : %d", sdInfo.isFull);
                NSLog(@"SDCard isValid : %d", sdInfo.isValid);
                NSLog(@"SDCard Inserted : %d", sdInfo.isInserted);
                NSLog(@"SDCard totalSize : %d MB", sdInfo.totalSize);
                NSLog(@"SDCard remainSize : %d MB", sdInfo.remainSize);
                NSLog(@"SDCard availableCaptureCount : %d",sdInfo.availableCaptureCount);
                
            }
            else
            {
                
                NSLog(@"Get SDCard Info Failed\n");
            }
            
        }];
        _selectedItem = item;
        [_tableView2 reloadData];
    }
            
}


-(void) onSetformatSDCard:(SettingsItem*)item
{
    if (item.isSubItem) {
        [_camera formatSDCard:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                
                NSLog(@"Format SDCard Success");
                
            }
            else{
                
                NSLog(@"Format SDCard Failed");
            }
            
        }];
        
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure format SD card?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        alertView.tag = 1001;
        [alertView show];
    
        _selectedItem = item;
        [_tableView2 reloadData];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001 && buttonIndex == 1) {
        [_camera formatSDCard:^(DJIError *error) {
            NSString* message = nil;
            if (error.errorCode == ERR_Succeeded) {
                message = @"Format SDCard Success";
                NSLog(message);
                
            }
            else{
                message = @"Format SDCard  Failed";
                NSLog(message);
            }
            UIAlertView* alertView1 = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView1 show];
        }];
    }
}

-(void) onSetCameraCaptureMode:(SettingsItem*)item
{
    if (item.isSubItem) {
        int index = (int)[_selectedItem.subSettings indexOfObject:item];
        if (index == 0) {
            _captureMode = CameraSingleCapture;
            NSLog(@"SingleCapture Mode");
        }
        if (index == 1) {
            _captureMode = CameraMultiCapture;
            NSLog(@"Set MultiCapture Success");
        }
        if (index == 2) {
            
            _captureMode = CameraContinousCapture;

            CameraContinuousCapturePara countAndTime = {2, 5};
            [_camera setContinuousCapture:countAndTime withResultBlock:^(DJIError *error) {
                if (error.errorCode == ERR_Succeeded) {
                    NSLog(@"Set Continuous Capture Success");
                }
                else
                {
                    NSLog(@"Set Continuous Capture Failed");
                }
            }];
        }
    }
    
    else
    {
        if (_captureMode == CameraSingleCapture) {
            NSLog(@"Get SingleCapture Success");
        }
        
        if (_captureMode == CameraMultiCapture) {
            NSLog(@"Get MultiCapture Success");
        }
        if (_captureMode == CameraContinousCapture) {
            [_camera getContinuousCaptureParam:^(CameraContinuousCapturePara capturePara, DJIError *error) {
                
                if (error.errorCode == ERR_Succeeded) {
                    
                    NSLog(@"Get ContinuousCapture Param Success,count:%d, time:%d", capturePara.contiCaptureCount ,capturePara.timeInterval);
                    
                }
                
            }];
        }

        
         _selectedItem = item;
        [_tableView2 reloadData];
    }
}

@end
