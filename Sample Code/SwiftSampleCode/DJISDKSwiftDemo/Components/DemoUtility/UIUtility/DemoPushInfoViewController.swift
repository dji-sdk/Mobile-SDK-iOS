//
//  DemoPushInfoViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 12/17/15.
//  Copyright © 2015 DJI. All rights reserved.
//
import UIKit
class DemoPushInfoViewController: DJIBaseViewController {
    @IBOutlet weak var pushInfoLabel: UILabel!

    init() {
        super.init(nibName: "DemoPushInfoViewController", bundle: NSBundle.mainBundle())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
