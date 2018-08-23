//
//  DJILB2AUDRemoveParser.h
//
//  Copyright (c) 2013 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 Some version of LB2 will prefix each slice with AUD. DJIVideoPreviewer need to parse the stream before the stream is parsed by avparser.
 E.g.
 frame1_slice1
 AUD, ....
 frame1_slice2
 AUD, ....
 000000010c
 frame2_slice1
 AUD, ....
 frame2_slice2
 AUD, ....
 000000010c
 
 Also we found that there is an isssue in the stream sent by Lightbridge 2. Whenever there are two adjacent AUDs, the decoder may fail. This workaround will detect this scenario and remove the AUDs.
 */

@protocol DJILB2AUDRemoveParserDelegate <NSObject>
-(void) lb2AUDRemoveParser:(id)parser didParsedData:(void*)data size:(int)size;
@end

@interface DJILB2AUDRemoveParser : NSObject
@property (nonatomic, weak) id<DJILB2AUDRemoveParserDelegate> delegate;

-(id) init;
-(void) parse:(void*)data_in inSize:(int)in_size;
-(void) reset;
@end
