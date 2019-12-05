//
//  HUD+UIView.swift
//  ANProgressHUD
//
//  Created by 刘栋 on 2019/3/8.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

extension UIView: HUDCompatible { }

extension HUDBase where Base: UIView {
    
    public func wait(text: String) {
        wait(text: text, animated: true, hideAfter: 30)
    }
    
    public func wait(text: String = "", animated: Bool = true, hideAfter delay: TimeInterval = 30) {
        DispatchQueue.main.async {
            self.hide()
            let hud = self.createHUD(mode: .indeterminate)
            hud.textLabel.text = text
            hud.isUserInteractionEnabled = true
            hud.hide(animined: animated, after: delay)
        }
    }
    
    public func show(text: String, hideAfter delay: TimeInterval = 1, completion handler: ProgressHUDCompletionBlock? = nil) {
        self.show(text: text, detail: "", animated: true, hideAfter: delay, isUserInteractionEnabled: false, completion: handler)
    }
    
    public func show(text: String, detail: String = "", animated: Bool = true, hideAfter delay: TimeInterval = 1, isUserInteractionEnabled: Bool = false, completion handler: ProgressHUDCompletionBlock? = nil) {
        DispatchQueue.main.async {
            self.hide()
            if delay > 0, text.isEmpty {
                return
            }
            
            let hud = self.createHUD(mode: .text)
            hud.textLabel.text = text
            hud.detailLabel.text = detail
            hud.isUserInteractionEnabled = isUserInteractionEnabled
            
            hud.hide(animined: animated, after: delay)
            
            if let handler = handler {
                DispatchQueue.main.asyncAfter(deadline: .now()+delay, execute: handler)
            }
        }
    }
    
    public func hide(animated: Bool = true) {
        DispatchQueue.main.async {
            ProgressHUD.hide(for: self.base, animated: animated)
        }
    }
    
    private func createHUD(mode: HUDMode, animated: Bool = true) -> ProgressHUD {
        let appearance = UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [ProgressHUD.self])
        appearance.color = UIColor.white
        let hud = ProgressHUD.show(to: base, animated: animated)
        base.bringSubviewToFront(hud)
        hud.mode = mode
        return hud
    }
}
