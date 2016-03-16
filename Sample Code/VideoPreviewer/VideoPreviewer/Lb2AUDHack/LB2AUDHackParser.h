//
//  LB2AUDHackParser.h
//
//

#import <Foundation/Foundation.h>
/*
 Some version of LB2 will prefix each slice with AUD. VideoPreviewer need to parse the stream before the stream is parsed by avparser.
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

@protocol LB2AUDHackParserDelegate <NSObject>
-(void) lb2AUDHackParser:(id)parser didParsedData:(void*)data size:(int)size;
@end

@interface LB2AUDHackParser : NSObject
@property (nonatomic, weak) id<LB2AUDHackParserDelegate> delegate;

-(id) init;
-(void) parse:(void*)data_in inSize:(int)in_size;
-(void) reset;
@end
