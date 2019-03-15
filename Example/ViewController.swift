//
//  ViewController.swift
//  Example
//
//  Created by 刘栋 on 2019/3/14.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import ANProgressHUD

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func showWait(_ sender: UIButton) {
        view.hud.wait()
    }
    
    @IBAction func showText(_ sender: UIButton) {
        view.hud.show(text: "hello", animated: true, hideAfter: 10)
    }
}
