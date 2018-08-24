//
//  DJIWidgetMacros.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#ifndef DJIWidgetMacros_h
#define DJIWidgetMacros_h

#define BEGIN_DISPATCH_QUEUE dispatch_async(_dispatchQueue, ^{
#define END_DISPATCH_QUEUE   });

#define BEGIN_MAIN_DISPATCH_QUEUE dispatch_async(dispatch_get_main_queue(), ^{

#define weakSelf(__TARGET__) __weak typeof(self) __TARGET__=self
#define strongSelf(__TARGET__, __WEAK__) typeof(self) __TARGET__=__WEAK__
#ifdef weakReturn
#undef weakReturn
#endif
#define weakReturn(__TARGET__) __strong typeof(__TARGET__) __strong##__TARGET__ = __TARGET__; \
if(__strong##__TARGET__==nil)return;

#define SAFE_BLOCK(block, ...) if(block){block(__VA_ARGS__);}

#define DJILOG(fmt, ...)

#endif /* VideoPreviewerMacros_h */
