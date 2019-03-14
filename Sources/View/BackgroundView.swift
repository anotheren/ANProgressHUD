//
//  BackgroundView.swift
//  ANProgressHUD
//
//  Created by 刘栋 on 2019/3/8.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final public class BackgroundView: UIView {
    
    public var style: HUDBackgroundStyle = .solidColor {
        didSet {
            if style != oldValue { updateForBackgroundStyle() }
        }
    }
    
    public var blurEffectStyle: UIBlurEffect.Style = .light {
        didSet {
            if blurEffectStyle != oldValue { updateForBackgroundStyle() }
        }
    }
    
    public var color: UIColor = UIColor(white: 0.8, alpha: 0.6) {
        didSet {
            if color != oldValue { updateViewsForColor() }
        }
    }
    
    public private(set) var effectView: UIVisualEffectView?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        clipsToBounds = true
        updateForBackgroundStyle()
    }
    
    public override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    private func updateForBackgroundStyle() {
        effectView?.removeFromSuperview()
        effectView = nil
        switch style {
        case .blur:
            let effect = UIBlurEffect(style: blurEffectStyle)
            let effectView = UIVisualEffectView(effect: effect)
            insertSubview(effectView, at: 0)
            effectView.frame = bounds
            effectView.autoresizingMask =  [.flexibleWidth, .flexibleHeight]
            backgroundColor = color
            layer.allowsGroupOpacity = false
            self.effectView = effectView
        case .solidColor:
            backgroundColor = color
        }
    }
    
    private func updateViewsForColor() {
        backgroundColor = color
    }
}
