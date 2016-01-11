//
//  DJIAnnotationView.h
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
        containerView = UIView(frame: CGRectZero)
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.setupDefaults()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder:aDecoder)
//    }

    func setDistanceIndicatorHidden(hidden: Bool) {
        self.distanceBackgroundImageView!.hidden = hidden
        self.distanceLabel!.hidden = hidden
    }

    func setTopDistanceIndicatorHidden(hidden: Bool) {
        self.topDistanceBackgroundImageView!.hidden = hidden
        self.topDistanceLabel!.hidden = hidden
    }

    func updateDistanceWithCoordinate(coordinate: CLLocationCoordinate2D) {
        let startingLocation: CLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let endingLocation: CLLocation = CLLocation(latitude: self.annotation!.coordinate.latitude, longitude: self.annotation!.coordinate.longitude)
        self.distanceLabel!.text = String(format: "%.1lfM", startingLocation.distanceFromLocation(endingLocation))
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
        animation2.toValue = NSValue(CATransform3D: CATransform3DScale(CATransform3DMakeTranslation(0, self.layer.frame.size.height * DropCompressAmount, 0), 1.0, 1.0 - DropCompressAmount, 1.0))
        animation2.fillMode = kCAFillModeForwards
        let animation3: CABasicAnimation = CABasicAnimation(keyPath: "transform")
        animation3.duration = 0.15
        animation3.beginTime = animation2.duration
        animation3.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation3.toValue = NSValue(CATransform3D: CATransform3DIdentity)
        animation3.fillMode = kCAFillModeForwards
        let group: CAAnimationGroup = CAAnimationGroup()
        group.animations = [animation2, animation3]
        group.duration = animation2.duration + animation3.duration
        group.fillMode = kCAFillModeForwards
        self.imageView!.layer.addAnimation(group, forKey: nil)
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
        self.backgroundColor = UIColor.clearColor()
        self.containerView.backgroundColor = UIColor.clearColor()
        self.containerView.clipsToBounds = false
        //    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
        self.containerView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.addSubview(self.containerView)
        self.imageView = UIImageView(frame: CGRectZero)
        self.imageView!.backgroundColor = UIColor.clearColor()
        self.imageView!.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(self.imageView!)
        self.containerView.addConstraint(NSLayoutConstraint(item: self.imageView!, attribute: .Left, relatedBy: .Equal, toItem: self.containerView, attribute: .Left, multiplier: 1, constant: 0))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.containerView, attribute: .Right, relatedBy: .Equal, toItem: self.imageView, attribute: .Right, multiplier: 1, constant: 0))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.imageView!, attribute: .Top, relatedBy: .Equal, toItem: self.containerView, attribute: .Top, multiplier: 1, constant: self.preferedCenterOffset.y))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.containerView, attribute: .Bottom, relatedBy: .Equal, toItem: self.imageView, attribute: .Bottom, multiplier: 1, constant: -self.preferedCenterOffset.y))
        let shadowImage: UIImage = UIImage(named: "gs_annotation_shadow.png")!
        self.shadowImageView = UIImageView(image: shadowImage)
        self.shadowImageView!.backgroundColor = UIColor.clearColor()
        self.shadowImageView!.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.insertSubview(self.shadowImageView!, belowSubview: self.imageView!)
        self.containerView.addConstraint(NSLayoutConstraint(item: self.shadowImageView!, attribute: .CenterX, relatedBy: .Equal, toItem: self.imageView, attribute: .CenterX, multiplier: 1, constant: 11))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.shadowImageView!, attribute: .CenterY, relatedBy: .Equal, toItem: self.imageView, attribute: .CenterY, multiplier: 1, constant: 5))
        self.shadowImageView!.addConstraint(NSLayoutConstraint(item: self.shadowImageView!, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: shadowImage.size.width))
        self.shadowImageView!.addConstraint(NSLayoutConstraint(item: self.shadowImageView!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: shadowImage.size.height))
        self.indexLabel = UILabel(frame: CGRectZero)
        self.indexLabel!.translatesAutoresizingMaskIntoConstraints = false
        self.indexLabel!.font = UIFont(name: "BebasNeue", size: 15.0)
        self.indexLabel!.textColor = UIColor.whiteColor()
        self.indexLabel!.backgroundColor = UIColor.clearColor()
        self.indexLabel!.textAlignment = .Center
        self.containerView.addSubview(self.indexLabel!)
        self.containerView.addConstraint(NSLayoutConstraint(item: self.indexLabel!, attribute: .CenterX, relatedBy: .Equal, toItem: self.imageView, attribute: .CenterX, multiplier: 1, constant: 0))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.indexLabel!, attribute: .Top, relatedBy: .Equal, toItem: self.imageView, attribute: .Top, multiplier: 1, constant: self.preferedSize.height * 0.15))
        self.distanceLabel = UILabel(frame: CGRectZero)
        self.distanceLabel!.translatesAutoresizingMaskIntoConstraints = false
        self.distanceLabel!.font = UIFont(name: "BebasNeue", size: 12.0)
        self.distanceLabel!.textColor = UIColor.whiteColor()
        self.distanceLabel!.backgroundColor = UIColor.clearColor()
        self.containerView.addSubview(self.distanceLabel!)
        self.containerView.addConstraint(NSLayoutConstraint(item: self.distanceLabel!, attribute: .Left, relatedBy: .Equal, toItem: self.containerView, attribute: .Left, multiplier: 1, constant: self.preferedSize.width / 2 + 5))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.distanceLabel!, attribute: .Top, relatedBy: .Equal, toItem: self.containerView, attribute: .Top, multiplier: 1, constant: self.preferedSize.height / 2))
        self.distanceBackgroundImageView = UIImageView(image: UIImage(named: "gs_annocation_distance_background.png")!.resizableImageWithCapInsets(UIEdgeInsetsMake(12, 20, 20, 12)))
        self.distanceBackgroundImageView!.backgroundColor = UIColor.clearColor()
        self.distanceBackgroundImageView!.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.insertSubview(self.distanceBackgroundImageView!, belowSubview: self.distanceLabel!)
        self.containerView.addConstraint(NSLayoutConstraint(item: self.distanceBackgroundImageView!, attribute: .Left, relatedBy: .Equal, toItem: self.distanceLabel!, attribute: .Left, multiplier: 1, constant: -10))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.distanceBackgroundImageView!, attribute: .Right, relatedBy: .Equal, toItem: self.distanceLabel!, attribute: .Right, multiplier: 1, constant: 8))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.distanceBackgroundImageView!, attribute: .Top, relatedBy: .Equal, toItem: self.distanceLabel!, attribute: .Top, multiplier: 1, constant: -6))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.distanceBackgroundImageView!, attribute: .Bottom, relatedBy: .Equal, toItem: self.distanceLabel!, attribute: .Bottom, multiplier: 1, constant: 4))
        self.topDistanceLabel = UILabel(frame: CGRectZero)
        self.topDistanceLabel!.translatesAutoresizingMaskIntoConstraints = false
        self.topDistanceLabel!.font = UIFont(name: "BebasNeue", size: 20.0)
        self.topDistanceLabel!.textColor = UIColor.whiteColor()
        self.topDistanceLabel!.backgroundColor = UIColor.clearColor()
        self.topDistanceLabel!.textAlignment = .Center
        self.containerView.addSubview(self.topDistanceLabel!)
        self.topDistanceLabel!.hidden = true
        self.containerView.addConstraint(NSLayoutConstraint(item: self.topDistanceLabel!, attribute: .CenterX, relatedBy: .Equal, toItem: self.imageView, attribute: .CenterX, multiplier: 1, constant: 0))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.topDistanceLabel!, attribute: .Top, relatedBy: .Equal, toItem: self.imageView, attribute: .Top, multiplier: 1, constant: self.preferedCenterOffset.y - self.preferedSize.height / 2))
        //[[UIImage imageNamed:@"gs_annocation_top_distance_background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 5.5, 7, 5.5)]
        self.topDistanceBackgroundImageView = UIImageView(image: UIImage(named: "gs_annocation_top_distance_background.png"))
        self.topDistanceBackgroundImageView!.backgroundColor = UIColor.clearColor()
        self.topDistanceBackgroundImageView!.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.insertSubview(self.topDistanceBackgroundImageView!, belowSubview: self.topDistanceLabel!)
        self.topDistanceBackgroundImageView!.hidden = true
        self.containerView.addConstraint(NSLayoutConstraint(item: self.topDistanceBackgroundImageView!, attribute: .Left, relatedBy: .Equal, toItem: self.topDistanceLabel, attribute: .Left, multiplier: 1, constant: -4))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.topDistanceBackgroundImageView!, attribute: .Right, relatedBy: .Equal, toItem: self.topDistanceLabel, attribute: .Right, multiplier: 1, constant: 4))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.topDistanceBackgroundImageView!, attribute: .Top, relatedBy: .Equal, toItem: self.topDistanceLabel, attribute: .Top, multiplier: 1, constant: -4))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.topDistanceBackgroundImageView!, attribute: .Bottom, relatedBy: .Equal, toItem: self.topDistanceLabel, attribute: .Bottom, multiplier: 1, constant: 8))
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

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

   
}
