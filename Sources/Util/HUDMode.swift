//
//  HUDMode.swift
//  ANProgressHUD
//
//  Created by 刘栋 on 2019/3/8.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Foundation

public enum HUDMode {
    
    /// UIActivityIndicatorView.
    case indeterminate
    /// A round, pie-chart like, progress view.
    case determinate
    /// Horizontal progress bar.
    case determinateHorizontalBar
    /// Ring-shaped progress view.
    case annularDeterminate
    /// Shows a custom view.
    case customView
    /// Shows only labels.
    case text
}
