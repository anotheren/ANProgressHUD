//
//  HUDAnimation.swift
//  ANProgressHUD
//
//  Created by 刘栋 on 2019/3/8.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Foundation

public enum HUDAnimation {
    
    /// Opacity animation
    case fade
    /// Opacity + scale animation (zoom in when appearing zoom out when disappearing)
    case zoom
    /// Opacity + scale animation (zoom out style)
    case zoomOut
    /// Opacity + scale animation (zoom in style)
    case zoomIn
}
