//
//  DJIH264FrameRawLayerDumper.h
//
//  Copyright (c) 2013 DJI. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "DJIStreamCommon.h"

/**
 *  for frame layer dump and test
 */
@interface DJIH264FrameRawLayerDumper : NSObject

/**
 *  create dump file
 */
-(void) dumpFrame:(VideoFrameH264Raw* _Nonnull)frame;

-(void) endDumpFile;


/**
 *  open dump file
 */
-(BOOL) openFile:(NSString* _Nonnull)name;

-( VideoFrameH264Raw* _Nullable ) readNextFrame;

-(void) seekToHead;

@end
