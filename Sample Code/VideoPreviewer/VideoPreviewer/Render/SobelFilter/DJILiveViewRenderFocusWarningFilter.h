//
//  DJILiveViewRenderFocusWarningFilter.h
//

#import "DJILiveViewRenderFilter.h"

@interface DJILiveViewRenderFocusWarningFilter : DJILiveViewRenderFilter

-(id) initWithContext:(id)context;

@property (nonatomic, assign) CGFloat focusWarningThreshold;

@end
