//
//  ProgressHUD.swift
//  ANProgressHUD
//
//  Created by 刘栋 on 2019/3/8.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

public protocol ProgressHUDDelegate: class {
    
    
}

public typealias ProgressHUDCompletionBlock = () -> Void

final public class ProgressHUD: UIView {
    
    
    
    
    public weak var delegate: ProgressHUDDelegate?
    public var completionBlock: ProgressHUDCompletionBlock?
    
    public var graceTime: TimeInterval = 0
    public var minShowTime: TimeInterval = 0
    public var removeFromSuperViewOnHide: Bool = false
    public var mode: HUDMode = .indeterminate
    public var contentColor: UIColor = .clear
    public var animationType: HUDAnimation = .fade
    public var offset: CGPoint = .zero
    public var margin: CGFloat = 20.0
    public var minSize: CGSize = .zero
    public var isSquare: Bool = false
    public var areDefaultMotionEffectsEnabled: Bool = false
    public var progress: Float = 0.0
    public var progressObject: Progress?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        
    }
    
    public func show(animated: Bool) {
        
    }
    
    public func hide(animined: Bool, after delay: TimeInterval = 0) {
        
    }
    
}

extension ProgressHUD {
    
    public static func show(to view: UIView, animated: Bool) -> ProgressHUD {
        fatalError()
    }
    
    public static func hide(for view: UIView, animated: Bool) -> Bool {
        fatalError()
    }
    
    public static func hud(for view: UIView) -> ProgressHUD? {
        fatalError()
    }
}
