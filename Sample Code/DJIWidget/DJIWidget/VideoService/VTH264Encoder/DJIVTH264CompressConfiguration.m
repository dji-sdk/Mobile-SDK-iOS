//
//  DJIVTH264CompressConfiguration.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import "DJIVTH264CompressConfiguration.h"
#import <VideoToolbox/VTCompressionProperties.h>


const NSUInteger kDefaultFrameRate = 30;

const float kLocalRecordAverageBitRate = 1024 * 1024 * 10;
const float kLocalRecordMaxBitRate = 1024 * 1024 * 20;

const float kLiveStreamAverageBitRate = 1024 * 1024 * 2;
const float kLiveStreamMaxBitRate = 1024 * 1024 * 4;

const float kQuickMovieAverageBitRate = 1024 * 1024 * 10;
const float kQuickMovieMaxBitRate = 1024 * 1024 * 20;


typedef NS_ENUM(NSUInteger, DJIVTH264CompressConfigurationProfileLevel) {
    //live broadcast
    DJIVTH264CompressConfigurationProfileLevel_H264_Baseline_1_3,//low resolution
    DJIVTH264CompressConfigurationProfileLevel_H264_Baseline_3_0,//SD
    DJIVTH264CompressConfigurationProfileLevel_H264_Baseline_3_1,//half HD
    DJIVTH264CompressConfigurationProfileLevel_H264_Baseline_4_1,//full HD
    DJIVTH264CompressConfigurationProfileLevel_H264_Baseline_AutoLevel, //auto
    
    //video cache
    DJIVTH264CompressConfigurationProfileLevel_H264_Main_3_0,//low resolution
    DJIVTH264CompressConfigurationProfileLevel_H264_Main_3_1,//half HD
    DJIVTH264CompressConfigurationProfileLevel_H264_Main_4_1,//full HD
    DJIVTH264CompressConfigurationProfileLevel_H264_Main_AutoLevel,//auto
    
    //HD cache
    DJIVTH264CompressConfigurationProfileLevel_H264_High_3_1,//half HD
    DJIVTH264CompressConfigurationProfileLevel_H264_High_4_0,//full HD
    DJIVTH264CompressConfigurationProfileLevel_H264_High_AutoLevel//auto
};


typedef NS_ENUM(NSUInteger, DJIVTH264CompressConfigurationEntropyMode) {
    DJIVTH264CompressConfigurationEntropyMode_CAVLC,
    DJIVTH264CompressConfigurationEntropyMode_CABAC,
};

@interface DJIVTH264CompressConfiguration ()

@property (nonatomic, assign, readwrite) DJIVTH264CompressConfigurationUsageType usageType;

// keyframe interval, kVTCompressionPropertyKey_ExpectedFrameRate
@property (nonatomic, assign) NSUInteger expectedFrameRate;

// keyframe interval, kVTCompressionPropertyKey_MaxKeyFrameInterval
@property (nonatomic, assign) NSUInteger maxKeyFrameInterval;

// average rate, kVTCompressionPropertyKey_AverageBitRate
@property (nonatomic, assign) NSUInteger averageBitRate;

// maximum bit rate, in bytes, kVTCompressionPropertyKey_DataRateLimits
@property (nonatomic, assign) NSUInteger dataRateLimits;

// maximum time interval from one keyframe to the next, kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration
@property (nonatomic, assign) NSTimeInterval maxKeyFrameIntervalDuration;

// specify the configuration file and level of the encoded bitstream, kVTCompressionPropertyKey_ProfileLevel
@property (nonatomic, assign) DJIVTH264CompressConfigurationProfileLevel profileLevel;

// enable temporal compression, kVTCompressionPropertyKey_AllowTemporalCompression
@property (nonatomic, assign) BOOL allowTemporalCompression;

// enable frame reordering when needed kVTCompressionPropertyKey_AllowFrameReordering
@property (nonatomic, assign) BOOL allowFrameReordering;

// enable real-time encoding (to avoid delay) kVTCompressionPropertyKey_RealTime
@property (nonatomic, assign) BOOL realTime;

// entropy H.264-specific see kVTCompressionPropertyKey_H264EntropyMode documentation for more details
@property (nonatomic, assign) DJIVTH264CompressConfigurationEntropyMode entropyMode;

@end


@implementation DJIVTH264CompressConfiguration

- (instancetype)initWithUsageType:(DJIVTH264CompressConfigurationUsageType)usageType {
    self = [super init];
    if (self) {
        self.usageType = usageType;
        self.allowFrameReordering = NO;
        self.allowTemporalCompression = YES;
        self.expectedFrameRate = kDefaultFrameRate;
        self.entropyMode = DJIVTH264CompressConfigurationEntropyMode_CABAC;
        [self setup];
    }
    return self;
}

- (void)setStreamFrameRate:(NSUInteger)frameRate {
    if (_expectedFrameRate != frameRate) {
        _expectedFrameRate = frameRate;
        [self setup];
    }
}

- (NSUInteger)configFrameRate {
    return _expectedFrameRate;
}

- (void)setup {
    
    switch (self.usageType) {
        case DJIVTH264CompressConfigurationUsageTypeLocalRecord: {
            self.profileLevel = DJIVTH264CompressConfigurationProfileLevel_H264_High_AutoLevel;
            self.averageBitRate = kLocalRecordAverageBitRate;
            self.dataRateLimits = kLocalRecordMaxBitRate;
            self.realTime = YES;
            self.maxKeyFrameIntervalDuration = 1;//One key frame every 1 second
            self.maxKeyFrameInterval = self.maxKeyFrameIntervalDuration * self.expectedFrameRate;//Key frame interval
        }
            break;
            
        case DJIVTH264CompressConfigurationUsageTypeLiveStream: {
            self.profileLevel = DJIVTH264CompressConfigurationProfileLevel_H264_Main_AutoLevel;
            self.averageBitRate = kLiveStreamAverageBitRate;
            self.dataRateLimits = kLiveStreamMaxBitRate;
            self.realTime = NO;
            self.maxKeyFrameIntervalDuration = 2;//One key frame every 2 second
            self.maxKeyFrameInterval = self.maxKeyFrameIntervalDuration * self.expectedFrameRate;
        }
            break;
            
        case DJIVTH264CompressConfigurationUsageTypeQuickMovie: {
            self.profileLevel = DJIVTH264CompressConfigurationProfileLevel_H264_High_AutoLevel;
            self.averageBitRate = kQuickMovieAverageBitRate;
            self.dataRateLimits = kQuickMovieMaxBitRate;
            self.realTime = YES;
            self.maxKeyFrameIntervalDuration = 1;//One key frame every 1 second
            self.maxKeyFrameInterval = self.maxKeyFrameIntervalDuration * self.expectedFrameRate;
        }
            break;
    }
}

- (NSDictionary *)configDict {
    return @{(__bridge NSString *)kVTCompressionPropertyKey_MaxKeyFrameInterval:@(self.maxKeyFrameInterval),
             (__bridge NSString *)kVTCompressionPropertyKey_ExpectedFrameRate:@(self.expectedFrameRate),
             (__bridge NSString *)kVTCompressionPropertyKey_AverageBitRate:@(self.averageBitRate),
             (__bridge NSString *)kVTCompressionPropertyKey_DataRateLimits:@[@(self.dataRateLimits),@1],
             (__bridge NSString *)kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration:@(self.maxKeyFrameIntervalDuration),
             (__bridge NSString *)kVTCompressionPropertyKey_AllowTemporalCompression:@(self.allowTemporalCompression),
             (__bridge NSString *)kVTCompressionPropertyKey_AllowFrameReordering:@(self.allowFrameReordering),
             (__bridge NSString *)kVTCompressionPropertyKey_RealTime:@(self.realTime),
             (__bridge NSString *)kVTCompressionPropertyKey_ProfileLevel:[self profileLevelStringFromLevel:self.profileLevel],
             (__bridge NSString *)kVTCompressionPropertyKey_H264EntropyMode:[self entropyModeStringFromMode:self.entropyMode]};
}


- (NSString *)entropyModeStringFromMode:(DJIVTH264CompressConfigurationEntropyMode)mode {
    switch (mode) {
        case DJIVTH264CompressConfigurationEntropyMode_CAVLC:return (__bridge NSString *)kVTH264EntropyMode_CAVLC;
        case DJIVTH264CompressConfigurationEntropyMode_CABAC:return (__bridge NSString *)kVTH264EntropyMode_CABAC;
    }
}

- (NSString *)profileLevelStringFromLevel:(DJIVTH264CompressConfigurationProfileLevel)level {
    switch (level) {
        case DJIVTH264CompressConfigurationProfileLevel_H264_Baseline_1_3:return (__bridge NSString *)kVTProfileLevel_H264_Baseline_1_3;
        case DJIVTH264CompressConfigurationProfileLevel_H264_Baseline_3_0:return (__bridge NSString *)kVTProfileLevel_H264_Baseline_3_0;
        case DJIVTH264CompressConfigurationProfileLevel_H264_Baseline_3_1:return (__bridge NSString *)kVTProfileLevel_H264_Baseline_3_1;
        case DJIVTH264CompressConfigurationProfileLevel_H264_Baseline_4_1:return (__bridge NSString *)kVTProfileLevel_H264_Baseline_4_1;
        case DJIVTH264CompressConfigurationProfileLevel_H264_Baseline_AutoLevel:return (__bridge NSString *)kVTProfileLevel_H264_Baseline_AutoLevel;
            
        case DJIVTH264CompressConfigurationProfileLevel_H264_Main_3_0:return (__bridge NSString *)kVTProfileLevel_H264_Main_3_0;
        case DJIVTH264CompressConfigurationProfileLevel_H264_Main_3_1:return (__bridge NSString *)kVTProfileLevel_H264_Main_3_1;
        case DJIVTH264CompressConfigurationProfileLevel_H264_Main_4_1:return (__bridge NSString *)kVTProfileLevel_H264_Main_4_1;
        case DJIVTH264CompressConfigurationProfileLevel_H264_Main_AutoLevel:return (__bridge NSString *)kVTProfileLevel_H264_Main_AutoLevel;
            
        case DJIVTH264CompressConfigurationProfileLevel_H264_High_3_1:return (__bridge NSString*)kVTProfileLevel_H264_High_3_1;
        case DJIVTH264CompressConfigurationProfileLevel_H264_High_4_0:return (__bridge NSString *)kVTProfileLevel_H264_High_4_0;
        case DJIVTH264CompressConfigurationProfileLevel_H264_High_AutoLevel:return (__bridge NSString *)kVTProfileLevel_H264_High_AutoLevel;
    }
}

@end



