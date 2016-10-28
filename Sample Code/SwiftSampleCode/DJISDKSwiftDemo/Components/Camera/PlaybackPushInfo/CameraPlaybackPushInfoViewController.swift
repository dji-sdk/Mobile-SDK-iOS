//
//  CameraPlaybackPushInfoViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 12/28/15.
//  Copyright © 2015 DJI. All rights reserved.
//
import DJISDK
class CameraPlaybackPushInfoViewController: DemoPushInfoViewController, DJIPlaybackDelegate{

    override func viewWillAppear(_ animated: Bool) {
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Clean camera's delegate before exiting the view
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil && camera!.isPlaybackSupported() && camera!.playbackManager?.delegate === self {
            camera!.playbackManager?.delegate = nil
        }
    }

    func playbackManager(_ playbackManager: DJIPlaybackManager, didUpdate playbackState: DJICameraPlaybackState) {
        NSLog("PlaybackState: \(playbackState)")
        
        let cameraPlayback: NSMutableString = NSMutableString()
        
        cameraPlayback.append("Playback file format(0:JPEG, 1:RAWDNG, 2:VIDEO, 3:Unknown): \(playbackState.mediaFileType)\n")
        cameraPlayback.append("Number of Thumbnails: \(playbackState.numberOfThumbnails) \n")
        cameraPlayback.append("Number of Media files: \(playbackState.numberOfMediaFiles) \n")
        cameraPlayback.append("Current selected file index: \(playbackState.currentSelectedFileIndex) \n")
        cameraPlayback.append("Video Duration: \(playbackState.videoDuration) \n")
        cameraPlayback.append("Video Play Progress: \(playbackState.videoPlayProgress) \n")
        cameraPlayback.append("Video Play Position: \(playbackState.videoPlayPosition) \n")
        cameraPlayback.append("Number of selected files: \(playbackState.numberOfSelectedFiles) \n")
        cameraPlayback.append("Number of photos in SD card: \(playbackState.numberOfPhotos) \n")
        cameraPlayback.append("Number of videos in SD card: \(playbackState.numberOfVideos) \n")
        
        cameraPlayback.append("Photo Size in previewing: \(playbackState.photoSize) \n")
        cameraPlayback.append("Current status of file to be deleted (0: Failure, 1: Deleting, 2: Success): \(playbackState.fileDeleteStatus) \n")
        cameraPlayback.append("Is all files in page selected: \(playbackState.isAllFilesInPageSelected) \n")
        cameraPlayback.append("Is selected file valid: \(playbackState.isSelectedFileValid) \n")
        cameraPlayback.append("Is previewing file downloaded: \(playbackState.isFileDownloaded) \n")
        
        cameraPlayback.append("Playback Mode: ")
        switch playbackState.playbackMode {
        case  .singleFilePreview:
            cameraPlayback.append("Single File Preview\n")
        case .singlePhotoZoomMode:
            cameraPlayback.append("Single Photo Zoom mode\n")
        case .singleVideoPlaybackStart:
            cameraPlayback.append("Single Video Playback Started \n")
        case .singleVideoPlaybackPause:
            cameraPlayback.append("Single Video Playback Paused\n")
        case .multipleFilesEdit:
            cameraPlayback.append("Multiple File Edit\n")
        case .multipleFilesPreview:
            cameraPlayback.append("Multiple File Preview\n")
        case .download:
            cameraPlayback.append("Download \n")
        case .unknown:
            cameraPlayback.append("Unknow \n")
        }
        
        self.pushInfoLabel.text = cameraPlayback as String
    }
}
