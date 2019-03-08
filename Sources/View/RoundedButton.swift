//
//  RoundedButton.swift
//  ANProgressHUD
//
//  Created by 刘栋 on 2019/3/8.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final class RoundedButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        layer.borderWidth = 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = ceil(bounds.height/2)
    }
    
    override var intrinsicContentSize: CGSize {
        guard !allControlEvents.isEmpty else {
            return .zero
        }
        var size = super.intrinsicContentSize
        size.width += 20
        return size
    }
    
    override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        super.setTitleColor(color, for: state)
        
    }
    
    override var isHighlighted: Bool {
        didSet {
            let baseColor = titleColor(for: .selected)
            backgroundColor = isHighlighted ? baseColor?.withAlphaComponent(0.1) : .clear
        }
    }
}
