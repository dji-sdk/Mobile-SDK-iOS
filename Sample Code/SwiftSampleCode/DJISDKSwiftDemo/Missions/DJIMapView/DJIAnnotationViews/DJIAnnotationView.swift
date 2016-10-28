//
//  DJIAnnotationView.swift
//  DJISDKSwiftDemo
//
import MapKit
//#define DJIAnnotationViewLongPressToDelete

let DropCompressAmount: CGFloat = 0.05

class DJIAnnotationView: MKAnnotationView {
   
    var containerView: UIView

    var imageView: UIImageView?=nil
    var shadowImageView: UIImageView?=nil
    var indexLabel: UILabel?=nil
    var distanceBackgroundImageView: UIImageView?=nil
    var distanceLabel: UILabel?=nil
    var topDistanceBackgroundImageView: UIImageView?=nil
    var topDistanceLabel: UILabel?=nil
    var preferedSize: CGSize
    var preferedCenterOffset: CGPoint
    var _annotation:DJIAnnotation?=nil
    override var annotation: MKAnnotation?{
        get {
            return _annotation
        }
        set (annotation) {
            _annotation = annotation as? DJIAnnotation
            let theAnnotation: DJIAnnotation = annotation as! DJIAnnotation
            if (self.indexLabel != nil) {
                self.indexLabel!.text = theAnnotation.index
            }
        }
    }

    
    //@property (readonly, strong, nonatomic) UILabel *distanceLabel;
    var panHandler: Void
    var longPressHandler: Void

    init(annotation: MKAnnotation, reuseIdentifier: String, size: CGSize, centerOffset offset: CGPoint) {
        // Initialization code
        preferedSize = size
        preferedCenterOffset = offset
        containerView = UIView(frame: CGRect.zero)
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.setupDefaults()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder:aDecoder)
//    }

    func setDistanceIndicatorHidden(_ hidden: Bool) {
        self.distanceBackgroundImageView!.isHidden = hidden
        self.distanceLabel!.isHidden = hidden
    }

    func setTopDistanceIndicatorHidden(_ hidden: Bool) {
        self.topDistanceBackgroundImageView!.isHidden = hidden
        self.topDistanceLabel!.isHidden = hidden
    }

    func updateDistanceWithCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let startingLocation: CLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let endingLocation: CLLocation = CLLocation(latitude: self.annotation!.coordinate.latitude, longitude: self.annotation!.coordinate.longitude)
        self.distanceLabel!.text = String(format: "%.1lfM", startingLocation.distance(from: endingLocation))
        self.topDistanceLabel!.text = self.distanceLabel!.text!
    }


    func animateDrop() {
        //    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        //    animation.duration = 0.4;
        //    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        //    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, CGRectGetHeight([UIScreen mainScreen].bounds) / - 4.f, 0)];
        //    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        let animation2: CABasicAnimation = CABasicAnimation(keyPath: "transform")
        animation2.duration = 0.10
        //    animation2.beginTime = animation.duration;
        animation2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation2.toValue = NSValue(caTransform3D: CATransform3DScale(CATransform3DMakeTranslation(0, self.layer.frame.size.height * DropCompressAmount, 0), 1.0, 1.0 - DropCompressAmount, 1.0))
        animation2.fillMode = kCAFillModeForwards
        let animation3: CABasicAnimation = CABasicAnimation(keyPath: "transform")
        animation3.duration = 0.15
        animation3.beginTime = animation2.duration
        animation3.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation3.toValue = NSValue(caTransform3D: CATransform3DIdentity)
        animation3.fillMode = kCAFillModeForwards
        let group: CAAnimationGroup = CAAnimationGroup()
        group.animations = [animation2, animation3]
        group.duration = animation2.duration + animation3.duration
        group.fillMode = kCAFillModeForwards
        self.imageView!.layer.add(group, forKey: nil)
    }


    override func layoutSubviews() {
        super.layoutSubviews()
    }
    //- (void)didMoveToSuperview
    //{
    //    [super didMoveToSuperview];
    //    
    //    [self animateDrop];
    //}



    func setupDefaults() {
        //    self.backgroundColor = [UIColor colorWithWhite:.5 alpha:.1];
        self.backgroundColor = UIColor.clear
        self.containerView.backgroundColor = UIColor.clear
        self.containerView.clipsToBounds = false
        //    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
        self.containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(self.containerView)
        self.imageView = UIImageView(frame: CGRect.zero)
        self.imageView!.backgroundColor = UIColor.clear
        self.imageView!.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(self.imageView!)
        self.containerView.addConstraint(NSLayoutConstraint(item: self.imageView!, attribute: .left, relatedBy: .equal, toItem: self.containerView, attribute: .left, multiplier: 1, constant: 0))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.containerView, attribute: .right, relatedBy: .equal, toItem: self.imageView, attribute: .right, multiplier: 1, constant: 0))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.imageView!, attribute: .top, relatedBy: .equal, toItem: self.containerView, attribute: .top, multiplier: 1, constant: self.preferedCenterOffset.y))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.containerView, attribute: .bottom, relatedBy: .equal, toItem: self.imageView, attribute: .bottom, multiplier: 1, constant: -self.preferedCenterOffset.y))
        let shadowImage: UIImage = UIImage(named: "gs_annotation_shadow.png")!
        self.shadowImageView = UIImageView(image: shadowImage)
        self.shadowImageView!.backgroundColor = UIColor.clear
        self.shadowImageView!.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.insertSubview(self.shadowImageView!, belowSubview: self.imageView!)
        self.containerView.addConstraint(NSLayoutConstraint(item: self.shadowImageView!, attribute: .centerX, relatedBy: .equal, toItem: self.imageView, attribute: .centerX, multiplier: 1, constant: 11))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.shadowImageView!, attribute: .centerY, relatedBy: .equal, toItem: self.imageView, attribute: .centerY, multiplier: 1, constant: 5))
        self.shadowImageView!.addConstraint(NSLayoutConstraint(item: self.shadowImageView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: shadowImage.size.width))
        self.shadowImageView!.addConstraint(NSLayoutConstraint(item: self.shadowImageView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: shadowImage.size.height))
        self.indexLabel = UILabel(frame: CGRect.zero)
        self.indexLabel!.translatesAutoresizingMaskIntoConstraints = false
        self.indexLabel!.font = UIFont(name: "BebasNeue", size: 15.0)
        self.indexLabel!.textColor = UIColor.white
        self.indexLabel!.backgroundColor = UIColor.clear
        self.indexLabel!.textAlignment = .center
        self.containerView.addSubview(self.indexLabel!)
        self.containerView.addConstraint(NSLayoutConstraint(item: self.indexLabel!, attribute: .centerX, relatedBy: .equal, toItem: self.imageView, attribute: .centerX, multiplier: 1, constant: 0))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.indexLabel!, attribute: .top, relatedBy: .equal, toItem: self.imageView, attribute: .top, multiplier: 1, constant: self.preferedSize.height * 0.15))
        self.distanceLabel = UILabel(frame: CGRect.zero)
        self.distanceLabel!.translatesAutoresizingMaskIntoConstraints = false
        self.distanceLabel!.font = UIFont(name: "BebasNeue", size: 12.0)
        self.distanceLabel!.textColor = UIColor.white
        self.distanceLabel!.backgroundColor = UIColor.clear
        self.containerView.addSubview(self.distanceLabel!)
        self.containerView.addConstraint(NSLayoutConstraint(item: self.distanceLabel!, attribute: .left, relatedBy: .equal, toItem: self.containerView, attribute: .left, multiplier: 1, constant: self.preferedSize.width / 2 + 5))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.distanceLabel!, attribute: .top, relatedBy: .equal, toItem: self.containerView, attribute: .top, multiplier: 1, constant: self.preferedSize.height / 2))
        self.distanceBackgroundImageView = UIImageView(image: UIImage(named: "gs_annocation_distance_background.png")!.resizableImage(withCapInsets: UIEdgeInsetsMake(12, 20, 20, 12)))
        self.distanceBackgroundImageView!.backgroundColor = UIColor.clear
        self.distanceBackgroundImageView!.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.insertSubview(self.distanceBackgroundImageView!, belowSubview: self.distanceLabel!)
        self.containerView.addConstraint(NSLayoutConstraint(item: self.distanceBackgroundImageView!, attribute: .left, relatedBy: .equal, toItem: self.distanceLabel!, attribute: .left, multiplier: 1, constant: -10))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.distanceBackgroundImageView!, attribute: .right, relatedBy: .equal, toItem: self.distanceLabel!, attribute: .right, multiplier: 1, constant: 8))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.distanceBackgroundImageView!, attribute: .top, relatedBy: .equal, toItem: self.distanceLabel!, attribute: .top, multiplier: 1, constant: -6))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.distanceBackgroundImageView!, attribute: .bottom, relatedBy: .equal, toItem: self.distanceLabel!, attribute: .bottom, multiplier: 1, constant: 4))
        self.topDistanceLabel = UILabel(frame: CGRect.zero)
        self.topDistanceLabel!.translatesAutoresizingMaskIntoConstraints = false
        self.topDistanceLabel!.font = UIFont(name: "BebasNeue", size: 20.0)
        self.topDistanceLabel!.textColor = UIColor.white
        self.topDistanceLabel!.backgroundColor = UIColor.clear
        self.topDistanceLabel!.textAlignment = .center
        self.containerView.addSubview(self.topDistanceLabel!)
        self.topDistanceLabel!.isHidden = true
        self.containerView.addConstraint(NSLayoutConstraint(item: self.topDistanceLabel!, attribute: .centerX, relatedBy: .equal, toItem: self.imageView, attribute: .centerX, multiplier: 1, constant: 0))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.topDistanceLabel!, attribute: .top, relatedBy: .equal, toItem: self.imageView, attribute: .top, multiplier: 1, constant: self.preferedCenterOffset.y - self.preferedSize.height / 2))
        //[[UIImage imageNamed:@"gs_annocation_top_distance_background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 5.5, 7, 5.5)]
        self.topDistanceBackgroundImageView = UIImageView(image: UIImage(named: "gs_annocation_top_distance_background.png"))
        self.topDistanceBackgroundImageView!.backgroundColor = UIColor.clear
        self.topDistanceBackgroundImageView!.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.insertSubview(self.topDistanceBackgroundImageView!, belowSubview: self.topDistanceLabel!)
        self.topDistanceBackgroundImageView!.isHidden = true
        self.containerView.addConstraint(NSLayoutConstraint(item: self.topDistanceBackgroundImageView!, attribute: .left, relatedBy: .equal, toItem: self.topDistanceLabel, attribute: .left, multiplier: 1, constant: -4))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.topDistanceBackgroundImageView!, attribute: .right, relatedBy: .equal, toItem: self.topDistanceLabel, attribute: .right, multiplier: 1, constant: 4))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.topDistanceBackgroundImageView!, attribute: .top, relatedBy: .equal, toItem: self.topDistanceLabel, attribute: .top, multiplier: 1, constant: -4))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.topDistanceBackgroundImageView!, attribute: .bottom, relatedBy: .equal, toItem: self.topDistanceLabel, attribute: .bottom, multiplier: 1, constant: 8))
//        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressAction:")
//        //    longPressGesture.numberOfTapsRequired = 1;
//        longPressGesture.numberOfTouchesRequired = 1
//        longPressGesture.delegate = self
//        self.containerView.addGestureRecognizer(longPressGesture)
    }

//    func longPressAction(sender: UILongPressGestureRecognizer) {
//        //    NSLog();
//        if self.longPressHandler {
//            self.longPressHandler(sender.state)
//        }
//    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

   
}
