//
//  DJIH264FrameRawLayerDumper.m
//
//  Copyright (c) 2013 DJI. All rights reserved.
//


#import "DJIH264FrameRawLayerDumper.h"

#if __TEST_PACK_DUMP__
#import "DJIDataDumper.h"
#endif

#define READ_BUFFER_SIZE (1024*1024)

@interface DJIH264FrameRawLayerDumper (){
    uint8_t* readBuffer;
    FILE* inputFile;
}
#if __TEST_PACK_DUMP__
@property (nonatomic, strong) DJIDataDumper* dumper;
#endif
@end

@implementation DJIH264FrameRawLayerDumper
-(id) init{
    if (self = [super init]) {
        readBuffer = malloc(READ_BUFFER_SIZE);
    }
    return self;
}

-(void) dealloc{
    if (readBuffer) {
        free(readBuffer);
    }
}

-(void) dumpFrame:(VideoFrameH264Raw*)frame{
#if __TEST_PACK_DUMP__
    if (!self.dumper) {
        //create dumper
        self.dumper = [[DJIDataDumper alloc] init];
        self.dumper.namePerfix = @"h264frame";
    }
#endif
    
    if (!frame) {
        return;
    }
    
    //write file
#if __TEST_PACK_DUMP__
    [self.dumper dumpData:(void*)frame length:sizeof(VideoFrameH264Raw)];
    [self.dumper dumpData:frame->frame_data length:frame->frame_size];
#endif
}

-(void) endDumpFile{
#if __TEST_PACK_DUMP__
    [self.dumper reset];
    self.dumper = nil;
#endif
}


-(BOOL) openFile:(NSString *)name{
    NSArray* doucuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* filePath = [doucuments objectAtIndex:0];
    filePath = [filePath stringByAppendingPathComponent:name];
    
    FILE* file = fopen([filePath UTF8String], "rb");
    if (file) {
        inputFile = file;
        return YES;
    }
    
    return NO;
}

-(VideoFrameH264Raw*) readNextFrame{
    VideoFrameH264Raw* output = nil;
    
    if (!inputFile) {
        return nil;
    }
    
    size_t readsize = fread(readBuffer, sizeof(VideoFrameH264Raw), 1, inputFile);
    if (readsize != 1) {
        return nil;
    }
    VideoFrameH264Raw* frame = (VideoFrameH264Raw*)readBuffer;
    if (frame->frame_size >= READ_BUFFER_SIZE
        || frame->type_tag != TYPE_TAG_VideoFrameH264Raw) {
        return nil;
    }
    readsize = fread(readBuffer + sizeof(VideoFrameH264Raw), frame->frame_size, 1, inputFile);
    if (readsize != 1) {
        return nil;
    }
    
//    size_t pos = ftell(inputFile);
//    if (pos > 20244833) {
//        pos = pos;
//    }
    
    int size = sizeof(VideoFrameH264Raw) + frame->frame_size;
    output = malloc(size);
    memcpy(output, readBuffer, size);
    
    return output;
}

-(void) seekToHead{
    if (!inputFile) {
        return;
    }
    
    fseek(inputFile, 0, SEEK_SET);
}

@end
