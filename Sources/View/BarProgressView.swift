//
//  BarProgressView.swift
//  ANProgressHUD
//
//  Created by 刘栋 on 2019/3/13.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final public class BarProgressView: UIView, ProgressDisplayableView {
    
    public var progress: Float = 0 {
        didSet {
            guard progress != oldValue else { return }
            setNeedsDisplay()
        }
    }
    
    public var lineColor: UIColor = .white {
        didSet {
            guard lineColor != oldValue else { return }
            setNeedsDisplay()
        }
    }
    
    public var progressRemainingColor: UIColor = .clear {
        didSet {
            guard progressRemainingColor != oldValue else { return }
            setNeedsDisplay()
        }
    }
    
    public var progressColor: UIColor = .white {
        didSet {
            guard progressColor != oldValue else { return }
            setNeedsDisplay()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        isOpaque = false
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 120, height: 10)
    }
    
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setLineWidth(2)
        context.setStrokeColor(lineColor.cgColor)
        context.setFillColor(progressRemainingColor.cgColor)
        
        // Draw background and Border
        var radius = rect.size.height/2-2
        context.move(to: CGPoint(x: 2, y: rect.size.height/2))
        context.addArc(tangent1End: CGPoint(x: 2, y: 2), tangent2End: CGPoint(x: radius+2, y: 2), radius: radius)
        context.addArc(tangent1End: CGPoint(x: rect.size.width-2, y: 2), tangent2End: CGPoint(x: rect.size.width-2, y: rect.size.height/2), radius: radius)
        context.addArc(tangent1End: CGPoint(x: rect.size.width-2, y: rect.size.height-2), tangent2End: CGPoint(x: rect.size.width-radius-2, y: rect.size.height-2), radius: radius)
        context.addArc(tangent1End: CGPoint(x: 2, y: rect.size.height-2), tangent2End: CGPoint(x: 2, y: rect.size.height/2), radius: radius)
        context.drawPath(using: .fillStroke)
        
        context.setFillColor(progressColor.cgColor)
        radius -= 2
        let amount = CGFloat(progress)*rect.size.width
        
        if amount >= radius+4 && amount <= rect.size.width-radius-4 {
            // Progress in the middle area
            context.move(to: CGPoint(x: 4, y: rect.size.height/2))
            context.addArc(tangent1End: CGPoint(x: 4, y: 4), tangent2End: CGPoint(x: radius+4, y: 4), radius: radius)
            context.addLine(to: CGPoint(x: amount, y: 4))
            context.addLine(to: CGPoint(x: amount, y: radius+4))
            
            context.move(to: CGPoint(x: 4, y: rect.size.height/2))
            context.addArc(tangent1End: CGPoint(x: 4, y: rect.size.height-4), tangent2End: CGPoint(x: radius+4, y: rect.size.height-4), radius: radius)
            context.addLine(to: CGPoint(x: amount, y: rect.size.height-4))
            context.addLine(to: CGPoint(x: amount, y: radius+4))
            
            context.fillPath()
        } else if amount > radius+4 {
            // Progress in the right arc
            let x = amount-(rect.size.width-radius-4)
            
            context.move(to: CGPoint(x: 4, y: rect.size.height/2))
            context.addArc(tangent1End: CGPoint(x: 4, y: 4), tangent2End: CGPoint(x: radius+4, y: 4), radius: radius)
            context.addLine(to: CGPoint(x: rect.size.width-radius-4, y: 4))
            
            var angle1 = -acos(x/radius)
            if angle1.isNaN { angle1 = 0 }
            context.addArc(center: CGPoint(x: rect.size.width-radius-4, y: rect.size.height/2), radius: radius, startAngle: .pi, endAngle: angle1, clockwise: false)
            context.addLine(to: CGPoint(x: amount, y: rect.size.height/2))
            
            context.move(to: CGPoint(x: 4, y: rect.size.height/2))
            context.addArc(tangent1End: CGPoint(x: 4, y: rect.size.height-4), tangent2End: CGPoint(x: radius+4, y: rect.size.height-4), radius: radius)
            context.addLine(to: CGPoint(x: rect.size.width-radius-4, y: rect.size.height-4))
            
            var angle2 = acos(x/radius)
            if angle2.isNaN { angle2 = 0 }
            context.addArc(center: CGPoint(x: rect.size.width-radius-4, y: rect.size.height/2), radius: radius, startAngle: -.pi, endAngle: angle2, clockwise: true)
            context.addLine(to: CGPoint(x: amount, y: rect.size.height/2))
            
            context.fillPath()
        } else if amount < radius+4 && amount > 0 {
            // Progress is in the left arc
            context.move(to: CGPoint(x: 4, y: rect.size.height/2))
            context.addArc(tangent1End: CGPoint(x: 4, y: 4), tangent2End: CGPoint(x: radius+4, y: 4), radius: radius)
            context.addLine(to: CGPoint(x: radius+4, y: rect.size.height/2))
            
            context.move(to: CGPoint(x: 4, y: rect.size.height/2))
            context.addArc(tangent1End: CGPoint(x: 4, y: rect.size.height-4), tangent2End: CGPoint(x: radius+4, y: rect.size.height-4), radius: radius)
            context.addLine(to: CGPoint(x: radius+4, y: rect.size.height/2))
            
            context.fillPath()
        }
    }
}
