//
//  VideoPreviewerMacros.h
//  VideoPreviewer
//
//  Copyright © 2016 DJI. All rights reserved.
//

#ifndef VideoPreviewerMacros_h
#define VideoPreviewerMacros_h

#define BEGIN_DISPATCH_QUEUE dispatch_async(_dispatchQueue, ^{
#define END_DISPATCH_QUEUE   });

#define BEGIN_MAIN_DISPATCH_QUEUE dispatch_async(dispatch_get_main_queue(), ^{

#endif /* VideoPreviewerMacros_h */
