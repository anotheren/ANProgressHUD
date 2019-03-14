//
//  RoundProgressView.swift
//  ANProgressHUD
//
//  Created by 刘栋 on 2019/3/12.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final public class RoundProgressView: UIView, ProgressDisplayableView {
    
    public var progress: Float = 0 {
        didSet {
            guard progress != oldValue else { return }
            setNeedsDisplay()
        }
    }
    
    public var progressTintColor: UIColor = UIColor(white: 1.0, alpha: 1.0) {
        didSet {
            guard progressTintColor != oldValue else { return }
            setNeedsDisplay()
        }
    }
    
    public var backgroundTintColor: UIColor = UIColor(white: 1.0, alpha: 0.1) {
        didSet {
            guard backgroundTintColor != oldValue else { return }
            setNeedsDisplay()
        }
    }
    
    public var isAnnular: Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: - UI
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 37, height: 37)
    }
    
    private func setupView() {
        backgroundColor = .clear
        isOpaque = false
    }
    
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        if isAnnular {
            // Draw background
            let lineWidth: CGFloat = 2.0
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            let radius = (bounds.size.width-lineWidth)/2
            let startAngle = -CGFloat.pi/2
            let endAngle1 = 2*CGFloat.pi+startAngle
            let processBackgroundPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle1, clockwise: true)
            processBackgroundPath.lineWidth = lineWidth
            processBackgroundPath.lineCapStyle = .butt
            backgroundTintColor.set()
            processBackgroundPath.stroke()
            // Draw progress
            let endAngle2 = CGFloat(progress)*2*CGFloat.pi+startAngle
            let processPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle2, clockwise: true)
            processPath.lineWidth = lineWidth
            processPath.lineCapStyle = .square
            progressTintColor.set()
            processPath.stroke()
        } else {
            // Draw background
            let lineWidth: CGFloat = 2.0
            let allRect = bounds
            let circleRect = allRect.insetBy(dx: lineWidth/2, dy: lineWidth/2)
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            progressTintColor.setStroke()
            backgroundTintColor.setFill()
            context.setLineWidth(lineWidth)
            context.strokeEllipse(in: circleRect)
            // Draw progress
            let radius = bounds.width/2-lineWidth
            let startAngle = -CGFloat.pi/2
            let endAngle = CGFloat(progress)*2*CGFloat.pi+startAngle
            let processPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            processPath.lineWidth = lineWidth*2
            processPath.lineCapStyle = .butt
            // Ensure that we don't get color overlapping when _progressTintColor alpha < 1.f.
            context.setBlendMode(.copy)
            progressTintColor.set()
            processPath.stroke()
        }
    }
}
