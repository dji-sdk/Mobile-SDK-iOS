//
//  CameraPlaybackPushInfoViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 12/28/15.
//  Copyright © 2015 DJI. All rights reserved.
//
import DJISDK
class CameraPlaybackPushInfoViewController: DemoPushInfoViewController, DJIPlaybackDelegate{

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Set the delegate to receive the push data from camera
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            if camera!.isPlaybackSupported() == false {
                self.pushInfoLabel.text = "The camera does not support Playback Mode. "
            }
            else {
                camera!.playbackManager?.delegate = self
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // Clean camera's delegate before exiting the view
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil && camera!.isPlaybackSupported() && camera!.playbackManager?.delegate === self {
            camera!.playbackManager?.delegate = nil
        }
    }

    func playbackManager(playbackManager: DJIPlaybackManager, didUpdatePlaybackState playbackState: DJICameraPlaybackState) {
        NSLog("PlaybackState: \(playbackState)")
        
        let cameraPlayback: NSMutableString = NSMutableString()
        
        cameraPlayback.appendString("Playback file format(0:JPEG, 1:RAWDNG, 2:VIDEO, 3:Unknown): \(playbackState.mediaFileType)\n")
        cameraPlayback.appendString("Number of Thumbnails: \(playbackState.numberOfThumbnails) \n")
        cameraPlayback.appendString("Number of Media files: \(playbackState.numberOfMediaFiles) \n")
        cameraPlayback.appendString("Current selected file index: \(playbackState.currentSelectedFileIndex) \n")
        cameraPlayback.appendString("Video Duration: \(playbackState.videoDuration) \n")
        cameraPlayback.appendString("Video Play Progress: \(playbackState.videoPlayProgress) \n")
        cameraPlayback.appendString("Video Play Position: \(playbackState.videoPlayPosition) \n")
        cameraPlayback.appendString("Number of selected files: \(playbackState.numberOfSelectedFiles) \n")
        cameraPlayback.appendString("Number of photos in SD card: \(playbackState.numberOfPhotos) \n")
        cameraPlayback.appendString("Number of videos in SD card: \(playbackState.numberOfVideos) \n")
        
        cameraPlayback.appendString("Photo Size in previewing: \(playbackState.photoSize) \n")
        cameraPlayback.appendString("Current status of file to be deleted (0: Failure, 1: Deleting, 2: Success): \(playbackState.fileDeleteStatus) \n")
        cameraPlayback.appendString("Is all files in page selected: \(playbackState.isAllFilesInPageSelected) \n")
        cameraPlayback.appendString("Is selected file valid: \(playbackState.isSelectedFileValid) \n")
        cameraPlayback.appendString("Is previewing file downloaded: \(playbackState.isFileDownloaded) \n")
        
        cameraPlayback.appendString("Playback Mode: ")
        switch playbackState.playbackMode {
        case  .SingleFilePreview:
            cameraPlayback.appendString("Single File Preview\n")
        case .SinglePhotoZoomMode:
            cameraPlayback.appendString("Single Photo Zoom mode\n")
        case .SingleVideoPlaybackStart:
            cameraPlayback.appendString("Single Video Playback Started \n")
        case .SingleVideoPlaybackPause:
            cameraPlayback.appendString("Single Video Playback Paused\n")
        case .MultipleFilesEdit:
            cameraPlayback.appendString("Multiple File Edit\n")
        case .MultipleFilesPreview:
            cameraPlayback.appendString("Multiple File Preview\n")
        case .Download:
            cameraPlayback.appendString("Download \n")
        case .Unknown:
            cameraPlayback.appendString("Unknow \n")
        }
        
        self.pushInfoLabel.text = cameraPlayback as String
    }
}