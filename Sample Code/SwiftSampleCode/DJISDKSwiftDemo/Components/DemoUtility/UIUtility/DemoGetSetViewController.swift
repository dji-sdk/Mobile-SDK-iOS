//
//  DemoGetSetViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 12/17/15.
//  Copyright © 2015 DJI. All rights reserved.
//
import UIKit
class DemoGetSetViewController: DJIBaseViewController {
    @IBOutlet weak var getValueTextField: UITextField!
    @IBOutlet weak var setValueTextField: UITextField!
    @IBOutlet weak var getValueButton: UIButton!
    @IBOutlet weak var setValueButton: UIButton!
    @IBOutlet weak var rangeLabel: UILabel!

    @IBAction func onGetButtonClicked(_ sender: AnyObject) {
    }

    @IBAction func onSetButtonClicked(_ sender: AnyObject) {
    }

    init() {
        super.init(nibName: "DemoGetSetViewController", bundle: Bundle.main)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.getValueTextField.isUserInteractionEnabled = false
    }
}
