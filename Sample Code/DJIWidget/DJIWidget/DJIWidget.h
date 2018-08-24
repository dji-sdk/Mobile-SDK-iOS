//
//  DJIWidget.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for DJIWidget.
FOUNDATION_EXPORT double DJIWidgetVersionNumber;

//! Project version string for DJIWidget.
FOUNDATION_EXPORT const unsigned char DJIWidgetVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <DJIWidget/PublicHeader.h>

/*------------DJIVideoPreviewer------------*/
#import <DJIWidget/DJISymbols.h>
#import <DJIWidget/DJILiveViewColorMonitorFilter.h>
#import <DJIWidget/DJIMovieGLView.h>
#import <DJIWidget/DJICustomVideoFrameExtractor.h>
#import <DJIWidget/DJIStreamCommon.h>
#import <DJIWidget/DJIVideoPreviewer.h>
#import <DJIWidget/DJIH264PocQueue.h>
#import <DJIWidget/DJIAlbumTransfer.h>
#import <DJIWidget/DJILiveViewRenderTexture.h>
#import <DJIWidget/DJIReverseDLogFilter.h>
#import <DJIWidget/DJISmoothDecode.h>
#import <DJIWidget/DJIVideoPreviewerH264Parser.h>
#import <DJIWidget/DJILiveViewFrameBuffer.h>
#import <DJIWidget/DJIJpegStreamImageDecoder.h>
#import <DJIWidget/DJILiveViewRenderColorMatrixFilter.h>
#import <DJIWidget/DJILiveViewRenderHighlightShadowFilter.h>
#import <DJIWidget/DJILiveViewRenderContext.h>
#import <DJIWidget/DJILiveViewRenderPass.h>
#import <DJIWidget/DJIH264FrameRawLayerDumper.h>
#import <DJIWidget/DJILiveViewRenderFocusWarningFilter.h>
#import <DJIWidget/DJIVideoHelper.h>
#import <DJIWidget/DJILiveViewRenderHSBFilter.h>
#import <DJIWidget/DJILiveViewRenderCommon.h>
#import <DJIWidget/DJILiveViewRenderScaleFilter.h>
#import <DJIWidget/DJILiveViewRenderProgram.h>
#import <DJIWidget/DJILiveViewRenderFilter.h>
#import <DJIWidget/DJILiveViewRenderDisplayView.h>
#import <DJIWidget/DJIVideoPresentViewAdjustHelper.h>
#import <DJIWidget/DJILiveViewRenderPicutre.h>
#import <DJIWidget/DJILiveViewRenderDataSource.h>
#import <DJIWidget/DJISoftwareDecodeProcessor.h>
#import <DJIWidget/DJILiveViewRenderLookupFilter.h>
#import <DJIWidget/DJIVideoPoolStructs.h>
#import <DJIWidget/DJIH264VTDecode.h>
#import <DJIWidget/DJILB2AUDRemoveParser.h>
#import <DJIWidget/DJIRTPlayerRenderView.h>
#import <DJIWidget/DJICameraRemotePlayerView.h>
#import <DJIWidget/DJIVTH264DecoderIFrameData.h>


/*------------VTH264Encoder------------*/
#import <DJIWidget/DJIVTH264CompressConfiguration.h>
#import <DJIWidget/DJIVTH264Compressor.h>
#import <DJIWidget/DJIVTH264CompressSession.h>
#import <DJIWidget/DJIVTH264Encoder.h>
#import <DJIWidget/NSError+DJIVTH264CompressSession.h>

/*------------RTMPProcessor------------*/
#import <DJIWidget/DJIRtmpIFrameProvider.h>
#import <DJIWidget/DJIRtmpMuxer.h>
#import <DJIWidget/DJIVideoPreviewSmoothHelper.h>
#import <DJIWidget/DJIAudioSampleBuffer.h>

/*------------VideoCacheing------------*/
#import <DJIWidget/DJILiveViewDammyCameraSessionProtocol.h>
#import <DJIWidget/DJILiveViewDammyCameraStructs.h>
#import <DJIWidget/DJILiveViewDammyCameraTakePhotoSession.h>
#import <DJIWidget/DJIVideoFeedCachingSession.h>

/*---------DecodeImageCalibrate--------*/
#import <DJIWidget/DJIDecodeImageCalibrateHelper.h>
#import <DJIWidget/DJIMavic2ProCameraImageCalibrateFilterDataSource.h>
#import <DJIWidget/DJIMavic2ZoomCameraImageCalibrateFilterDataSource.h>
