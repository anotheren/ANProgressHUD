//
//  HUDBase.swift
//  ANProgressHUD
//
//  Created by 刘栋 on 2019/3/8.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Foundation

public struct HUDBase<Base> {
    
    public let base: Base
    
    public init(base: Base) {
        self.base = base
    }
}
