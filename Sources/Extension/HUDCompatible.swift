//
//  HUDCompatible.swift
//  ANProgressHUD
//
//  Created by 刘栋 on 2019/3/8.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Foundation

public protocol HUDCompatible {
    
    associatedtype HUDCompatible
    
    static var hud: HUDBase<HUDCompatible>.Type { get }
    
    var hud: HUDBase<HUDCompatible> { get }
}

extension HUDCompatible {
    
    public static var hud: HUDBase<Self>.Type {
        get {
            return HUDBase<Self>.self
        }
    }
    
    public var hud: HUDBase<Self> {
        get {
            return HUDBase(base: self)
        }
    }
}
