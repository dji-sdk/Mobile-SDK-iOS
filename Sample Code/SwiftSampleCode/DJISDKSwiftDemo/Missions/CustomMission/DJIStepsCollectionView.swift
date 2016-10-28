//
//  DJIStepsCollectionView.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 15/12/18.
//  Copyright © 2015 DJI. All rights reserved.
//
import UIKit
protocol DJIStepsCollectionViewDelegate: class {
    func stepsCollectionView(_ view: DJIStepsCollectionView, didSelectType type: DJICollectionViewCellType)

    func stepsCollectionViewDidDeleteLast(_ view: DJIStepsCollectionView)
}
class DJIStepsCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    weak var delegate: DJIStepsCollectionViewDelegate? = nil
    var allSteps:[DJICollectionViewCellType] = []
    @IBOutlet weak var collectionView:UICollectionView?
    
    init() {
        super.init(frame: CGRect.zero)
        var views: [AnyObject] = Bundle.main.loadNibNamed("DJIStepsCollectionView", owner:self, options: nil) as! [AnyObject]
        let mainView: UIView = views[0] as! UIView
        self.frame = mainView.bounds
        
        self.addSubview(mainView)
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
        let nib: UINib = UINib(nibName: "DJICollectionViewCell", bundle: Bundle.main)
        self.collectionView!.register(nib, forCellWithReuseIdentifier: "DJICollectionViewCell")
        
        for type in DJICollectionViewCellType.allValues {
            self.allSteps.append(type)
        }
        
    }

     required init?(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }

    required override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        if (self.delegate != nil) {
                let type: DJICollectionViewCellType = self.allSteps[(indexPath as NSIndexPath).row]
                self.delegate!.stepsCollectionView(self, didSelectType: type)
            }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allSteps.count
    }
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: DJICollectionViewCell? = (collectionView.dequeueReusableCell(withReuseIdentifier: "DJICollectionViewCell", for: indexPath) as? DJICollectionViewCell)
        if (cell == nil) {
            cell = DJICollectionViewCell.collectionViewCell()
        }
        
        let type: DJICollectionViewCellType = self.allSteps[(indexPath as NSIndexPath).row]
        cell!.cellType = type
        return cell!
    }

    @IBAction func onOKButtonClicked(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            self.alpha = 0.0
        })
    }

    @IBAction func onDELButtonClicked(_ sender: AnyObject) {
        if (self.delegate != nil) {
            self.delegate!.stepsCollectionViewDidDeleteLast(self)
        }
    }

    
}
