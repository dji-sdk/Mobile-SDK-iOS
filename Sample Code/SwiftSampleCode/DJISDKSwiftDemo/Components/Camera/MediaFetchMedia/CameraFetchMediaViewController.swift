//
//  CameraFetchMediaViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 12/29/15.
//  Copyright © 2015 DJI. All rights reserved.
//
import UIKit
import DJISDK

class CameraFetchMediaViewController: DJIBaseViewController {

    @IBOutlet weak var showThumbnailButton: UIButton!
    @IBOutlet weak var showPreviewButton: UIButton!
    @IBOutlet weak var showFullImageButton: UIButton!
    var imageMedia: DJIMedia? = nil

    var mediaList: [DJIMedia]? {

        didSet{
            // Cache the first JPEG media file in the list.
            if (mediaList == nil)
            {
                return
            }
            
            for media:DJIMedia in mediaList! {
                if media.mediaType == DJIMediaType.JPEG {
                    self.imageMedia = media
                }
            }
            if self.imageMedia == nil {
                self.showAlertResult("There is no image media file in the SD card. ")
            }
            self.showThumbnailButton.isEnabled = (self.imageMedia != nil)
            self.showPreviewButton.isEnabled = (self.imageMedia != nil)
            self.showFullImageButton.isEnabled = (self.imageMedia != nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let camera: DJICamera? = self.fetchCamera()
        if camera == nil {
            self.showAlertResult("Cannot detect the camera.")
            return
        }
        if camera!.isMediaDownloadModeSupported() == false {
            self.showAlertResult("Media Download is not supported. ")
            return
        }
        // start to check the pre-condition
        self.getCameraMode()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.mediaList != nil {
            self.mediaList = nil
        }
        if self.imageMedia != nil {
            self.imageMedia = nil
        }
    }
    /**
     *  Check if the camera's mode is DJICameraModeMediaDownload.
     *  If the mode is not DJICameraModeMediaDownload, we need to set it to be DJICameraModeMediaDownload.
     */

    func getCameraMode() {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            camera!.getModeWithCompletion({[weak self] (mode: DJICameraMode, error: Error?) -> Void in
                if error != nil {
                    self?.showAlertResult("ERROR: getCameraModeWithCompletion:\(error!)")
                }
                else if mode != DJICameraMode.mediaDownload {
                    self?.setCameraMode()
                }
                else {
                    self?.startFetchMedia()
                }

            })
        }
    }
    /**
     *  Set the camera's mode to DJICameraModeMediaDownload.
     */

    func setCameraMode() {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil {
            camera!.setCameraMode(DJICameraMode.mediaDownload, withCompletion: {[weak self](error: Error?) -> Void in
                if error != nil {
                    self?.showAlertResult("ERROR: setCameraMode:withCompletion:\(error!)")
                }
                else {
                    self?.startFetchMedia()
                }
            })
        }
    }
    /**
     *  Get the list of media files from DJIMediaManager.
     */

    func startFetchMedia() {
        let camera: DJICamera? = self.fetchCamera()
        if camera != nil && camera?.mediaManager != nil {
            
            camera!.mediaManager!.fetchMediaList( completion: {[weak self](mediaList:[DJIMedia]?, error: Error?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: fetchMediaListWithCompletion:\(error!)")
                }
                else {
                    self?.mediaList = mediaList
                    self?.showAlertResult("SUCCESS: The media list is fetched. ")
                }
            })
        }
    }
    /**
     *  In order to fetch the thumbnail, we can check if the thumbnail property is nil or not. 
     *  If it is nil, we need to call fetchThumbnailWithCompletion: before fetching the thumbnail.
     */

    @IBAction func onShowThumbnailButtonClicked(_ sender: AnyObject) {
        self.showThumbnailButton.isEnabled = false
        if self.imageMedia?.thumbnail == nil {
            // fetch thumbnail is not invoked yet
            
            self.imageMedia?.fetchThumbnail(completion: {[weak self](error: Error?) -> Void in
                
                if error != nil {
                    self?.showAlertResult("ERROR: fetchThumbnailWithCompletion:\(error!)")
                }
                else {
                    self?.showPhotoWithImage(self!.imageMedia!.thumbnail!)
                }
                self?.showThumbnailButton.isEnabled = true
            })
        }
    }
    /**
     *  Because the preview image is not as small as the thumbnail image, SDK would not cache it as 
     *  a property in DJIMedia. Instead, user need to decide whether to cache the image after invoking
     *  fetchPreviewImageWithCompletion:.
     */

    @IBAction func onShowPreviewButtonClicked(_ sender: AnyObject) {
        self.showPreviewButton.isEnabled = false
        
        self.imageMedia?.fetchPreviewImage(completion: {[weak self](image: UIImage, error: Error?) -> Void in
            
            if error != nil {
                self?.showAlertResult("ERROR: fetchPreviewImageWithCompletion:\(error!)")
            }
            else {
                self?.showPhotoWithImage(image)
            }
            self?.showPreviewButton.isEnabled = true
        })
    }
    /**
     *  The full image is even larger than the preview image. A JPEG image is around 3mb to 4mb. Therefore, 
     *  SDK does not cache it. There are two differences between the process of fetching preview iamge and 
     *  the one of fetching full image: 
     *  1. The full image is received fully at once. The full image file is separated into several data packages. 
     *     The completion block will be called each time when a data package is ready. 
     *  2. The received data is the raw image file data rather than a UIImage object. It is more convenient to 
     *     store the file into disk.
     */

    @IBAction func onShowFullImageButtonClicked(_ sender: AnyObject) {
        self.showFullImageButton.isEnabled = false
        
        let downloadData: NSMutableData = NSMutableData()
        self.imageMedia?.fetchData(completion: {[weak self](data:Data?, stop:UnsafeMutablePointer<ObjCBool>?, error:Error?) -> Void in
            
            if error != nil {
                self?.showAlertResult("ERROR: fetchMediaDataWithCompletion:\(error!)")
                self?.showFullImageButton.isEnabled = true
            }
            else {
                downloadData.append(data!)
                if Int64(downloadData.length) == self?.imageMedia?.fileSizeInBytes {
                    DispatchQueue.main.async(execute: {() -> Void in
                        self?.showPhotoWithData(downloadData as Data)
                        self?.showFullImageButton.isEnabled = true
                    })
                }
            }
            self?.showFullImageButton.isEnabled = true
        })
    }

    // Utility methods to show the image
    func showPhotoWithImage(_ image: UIImage) {
        let bkgndView: UIView = UIView(frame: self.view.bounds)
        bkgndView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CameraFetchMediaViewController.onImageViewTap(_:)))
        bkgndView.addGestureRecognizer(tapGesture)
        var width: CGFloat = image.size.width
        var height: CGFloat = image.size.height
        if width > self.view.bounds.size.width * 0.7 {
            height = height * (self.view.bounds.size.width * 0.7) / width
            width = self.view.bounds.size.width * 0.7
        }
        let imgView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imgView.image = image
        imgView.center = bkgndView.center
        imgView.backgroundColor = UIColor.lightGray
        imgView.layer.borderWidth = 2.0
        imgView.layer.borderColor = UIColor.blue.cgColor
        imgView.layer.cornerRadius = 4.0
        imgView.layer.masksToBounds = true
        imgView.contentMode = .scaleAspectFill
        bkgndView.addSubview(imgView)
        self.view!.addSubview(bkgndView)
    }

    func showPhotoWithData(_ data: Data?) {
        if data != nil {
            let image: UIImage? = UIImage(data: data!)
            if image != nil {
                self.showPhotoWithImage(image!)
            }
            else {
                self.showAlertResult("Image Crashed")
            }
        }
    }

    func onImageViewTap(_ recognized: UIGestureRecognizer) {
        let view: UIView = recognized.view!
        view.removeFromSuperview()
    }

}
