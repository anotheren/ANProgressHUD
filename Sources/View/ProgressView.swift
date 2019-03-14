//
//  ProgressView.swift
//  ANProgressHUD
//
//  Created by 刘栋 on 2019/3/14.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

public protocol ProgressDisplayableView: class {
    
    var progress: Float { get set }
}
