//
//  ProgressHUD.swift
//  ANProgressHUD
//
//  Created by 刘栋 on 2019/3/8.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

public protocol ProgressHUDDelegate: class {
    
    func hudHasHidden(_ hud: ProgressHUD)
}

public typealias ProgressHUDCompletionBlock = () -> Void

final public class ProgressHUD: UIView {
    
    public weak var delegate: ProgressHUDDelegate?
    public var completionBlock: ProgressHUDCompletionBlock?
    
    public var graceTime: TimeInterval = 0
    public var minShowTime: TimeInterval = 0
    public var removeFromSuperViewOnHide: Bool = false
    public var mode: HUDMode = .indeterminate {
        didSet {
            if mode != oldValue { updateIndicators() }
        }
    }
    public var contentColor: UIColor = UIColor(white: 0.0, alpha: 0.8)
    public var animationType: HUDAnimation = .fade
    public var offset: CGPoint = .zero {
        didSet {
            if offset != oldValue { setNeedsUpdateConstraints() }
        }
    }
    public var margin: CGFloat = 15.0 {
        didSet {
            if margin != oldValue { setNeedsUpdateConstraints() }
        }
    }
    public var minSize: CGSize = .zero {
        didSet {
            if minSize != oldValue { setNeedsUpdateConstraints() }
        }
    }
    public var isSquare: Bool = false {
        didSet {
            if isSquare != oldValue { setNeedsUpdateConstraints() }
        }
    }
    public var areDefaultMotionEffectsEnabled: Bool = true
    public var progress: Float = 0.0
    public var progressObject: Progress? {
        didSet {
            if progressObject != oldValue {
                
            }
        }
    }
    
    public var customView: UIView? {
        didSet {
            if customView != oldValue, mode == .customView { updateIndicators() }
        }
    }
    
    public private(set) lazy var backgroundView: BackgroundView = {
        let view = BackgroundView(frame: bounds)
        view.backgroundColor = .clear
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.alpha = 0
        return view
    }()
    
    public private(set) lazy var bezelView: BackgroundView = {
        let view = BackgroundView(frame: bounds)
        view.style = .blur
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12.0
        view.alpha = 0
        return view
    }()
    
    public private(set) lazy var textLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.adjustsFontSizeToFitWidth = false
        view.textAlignment = .center
        view.textColor = contentColor
        view.font = .label
        view.isOpaque = false
        view.backgroundColor = .clear
        return view
    }()
    
    public private(set) lazy var detailLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.adjustsFontSizeToFitWidth = false
        view.textAlignment = .center
        view.textColor = contentColor
        view.numberOfLines = 0
        view.font = .detailLabel
        view.isOpaque = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var topSpacer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var bottomSpacer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private var useAnimation: Bool = false
    private var hasFinished: Bool = false
    private var indicator: UIView?
    private var showStarted: Date?
    private var paddingConstraints: [NSLayoutConstraint] = []
    private var bezelConstraints: [NSLayoutConstraint] = []
    
    private weak var graceTimer: Timer?
    private weak var minShowTimer: Timer?
    private weak var hideDelayTimer: Timer?
    private var progressObjectDisplayLink: CADisplayLink? {
        didSet {
            if progressObjectDisplayLink != oldValue {
                oldValue?.invalidate()
                progressObjectDisplayLink?.add(to: .main, forMode: .default)
            }
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
}

extension ProgressHUD {
    
    public class func show(to view: UIView, animated: Bool) -> ProgressHUD {
        let hud = ProgressHUD(frame: view.bounds)
        hud.removeFromSuperViewOnHide = true
        view.addSubview(hud)
        hud.show(animated: animated)
        return hud
    }
    
    @discardableResult
    public class func hide(for view: UIView, animated: Bool) -> Bool {
        guard let hud = hud(for: view) else { return false }
        hud.removeFromSuperViewOnHide = true
        hud.hide(animined: animated)
        return true
    }
    
    public class func hud(for view: UIView) -> ProgressHUD? {
        let subviews = view.subviews.reversed()
        for subview in subviews {
            if let hud = subview as? ProgressHUD, !hud.hasFinished {
                return hud
            }
        }
        return nil
    }
}

// MARK: - Show & hide

extension ProgressHUD {
    
    public func show(animated: Bool) {
        assert(Thread.isMainThread, "needs to be accessed on the main thread.")
        graceTimer?.invalidate()
        useAnimation = animated
        hasFinished = false
        // If the grace time is set, postpone the HUD display
        if graceTime > 0 {
            let timer = Timer(timeInterval: graceTime, target: self, selector: #selector(handle(graceTimer:)), userInfo: nil, repeats: false)
            RunLoop.current.add(timer, forMode: .common)
            graceTimer = timer
        } else {
            show(using: useAnimation)
        }
    }
    
    public func hide(animined: Bool) {
        assert(Thread.isMainThread, "needs to be accessed on the main thread.")
        graceTimer?.invalidate()
        useAnimation = animined
        hasFinished = true
        // If the minShow time is set, calculate how long the HUD was shown,
        // and postpone the hiding operation if necessary
        if minShowTime > 0, let showStarted = showStarted {
            let timeInterval = Date().timeIntervalSince(showStarted)
            if timeInterval < minShowTime {
                let timer = Timer(timeInterval: minShowTime-timeInterval, target: self, selector: #selector(handle(minShowTimer:)), userInfo: nil, repeats: false)
                RunLoop.current.add(timer, forMode: .common)
                minShowTimer = timer
                return
            }
        }
        hide(using: useAnimation)
    }
    
    public func hide(animined: Bool, after delay: TimeInterval) {
        hideDelayTimer?.invalidate()
        let timer = Timer(timeInterval: delay, target: self, selector: #selector(handle(hideTimer:)), userInfo: animined, repeats: false)
        RunLoop.current.add(timer, forMode: .common)
        hideDelayTimer = timer
    }
    
    private func show(using animated: Bool) {
        // Cancel any previous animations
        bezelView.layer.removeAllAnimations()
        backgroundView.layer.removeAllAnimations()
        
        // Cancel any scheduled hideAnimated:afterDelay: calls
        hideDelayTimer?.invalidate()
        
        showStarted = Date()
        alpha = 1.0
        
        // Needed in case we hide and re-show with the same NSProgress object attached.
        updateProgressDisplayLink(enabled: true)
        
        if animated {
            animate(isAnimatingIn: true, type: animationType, completion: nil)
        } else {
            bezelView.alpha = 1.0
            backgroundView.alpha = 1.0
        }
    }
    
    private func hide(using animined: Bool) {
        // Cancel any scheduled hideAnimated:afterDelay: calls.
        // This needs to happen here instead of in done,
        // to avoid races if another hideAnimated:afterDelay:
        // call comes in while the HUD is animating out.
        hideDelayTimer?.invalidate()
        
        if animined, showStarted != nil {
            showStarted = nil
            animate(isAnimatingIn: false, type: animationType) { [weak self] finished in
                guard let strongSelf = self else { return }
                strongSelf.done()
            }
        } else {
            showStarted = nil
            bezelView.alpha = 0
            backgroundView.alpha = 1
            done()
        }
    }
    
    private func animate(isAnimatingIn: Bool, type: HUDAnimation, completion: ((Bool) -> Void)?) {
        // Automatically determine the correct zoom animation type
        var currentType = type
        if type == .zoom {
            currentType = isAnimatingIn ? .zoomIn : .zoomOut
        }
        
        let small = CGAffineTransform(scaleX: 0.5, y: 0.5)
        let large = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        // Set starting state
        if isAnimatingIn && bezelView.alpha == 0 && currentType == .zoomIn {
            bezelView.transform = small
        } else if isAnimatingIn && bezelView.alpha == 0 && currentType == .zoomOut {
            bezelView.transform = large
        }
        
        // Perform animations
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
            if isAnimatingIn {
                self.bezelView.transform = .identity
            } else if !isAnimatingIn && currentType == .zoomIn {
                self.bezelView.transform = large
            } else if !isAnimatingIn && currentType == .zoomOut {
                self.bezelView.transform = small
            }
            let alpha: CGFloat = isAnimatingIn ? 1 : 0
            self.bezelView.alpha = alpha
            self.backgroundView.alpha = alpha
        }, completion: completion)
    }
    
    private func done() {
        updateProgressDisplayLink(enabled: false)
        
        if hasFinished {
            alpha = 0
            if removeFromSuperViewOnHide {
                removeFromSuperview()
            }
        }
        completionBlock?()
        
        delegate?.hudHasHidden(self)
    }
}

// MARK: - Timer callbacks

extension ProgressHUD {
    
    @objc private func handle(graceTimer: Timer) {
        // Show the HUD only if the task is still running
        if !hasFinished {
            show(using: useAnimation)
        }
    }
    
    @objc private func handle(minShowTimer: Timer) {
        hide(using: useAnimation)
    }
    
    @objc private func handle(hideTimer: Timer) {
        let useAnimation = hideTimer.userInfo as? Bool ?? true
        hide(using: useAnimation)
    }
}

// MARK: - View Hierrarchy

extension ProgressHUD {
    
    public override func didMoveToSuperview() {
        if let superview = superview {
            frame = superview.bounds
        }
    }
}

// MARK: - UI

extension ProgressHUD {
    
    private func setupView() {
        // Transparent background
        isOpaque = false
        backgroundColor = .clear
        // Make it invisible for now
        alpha = 0
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        layer.allowsGroupOpacity = false
        
        // UI
        addSubview(backgroundView)
        addSubview(bezelView)
        updateBezelMotionEffects()
        
        for view in [textLabel, detailLabel] {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.setContentHuggingPriority(UILayoutPriority(998), for: .horizontal)
            view.setContentHuggingPriority(UILayoutPriority(998), for: .vertical)
            bezelView.addSubview(view)
        }
        
        bezelView.addSubview(topSpacer)
        bezelView.addSubview(bottomSpacer)
        updateIndicators()
    }
    
    private func updateIndicators() {
        switch mode {
        case .indeterminate:
            let isActivityIndicator = indicator?.isKind(of: UIActivityIndicatorView.self) ?? false
            if !isActivityIndicator {
                // Update to indeterminate indicator
                indicator?.removeFromSuperview()
                let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
                activityIndicatorView.startAnimating()
                bezelView.addSubview(activityIndicatorView)
                indicator = activityIndicatorView
            }
        case .determinateHorizontalBar:
            // Update to bar determinate indicator
            indicator?.removeFromSuperview()
            let barProgressView = BarProgressView(frame: .zero)
            bezelView.addSubview(barProgressView)
            indicator = barProgressView
        case .determinate:
            let isRoundIndicator = indicator?.isKind(of: RoundProgressView.self) ?? false
            if !isRoundIndicator {
                indicator?.removeFromSuperview()
                let roundProgressView = RoundProgressView(frame: .zero)
                bezelView.addSubview(roundProgressView)
                indicator = roundProgressView
            }
        case  .annularDeterminate:
            let isRoundIndicator = indicator?.isKind(of: RoundProgressView.self) ?? false
            if !isRoundIndicator {
                indicator?.removeFromSuperview()
                let roundProgressView = RoundProgressView(frame: .zero)
                roundProgressView.isAnnular = true
                bezelView.addSubview(roundProgressView)
                indicator = roundProgressView
            }
        case .customView:
            if let customView = customView, customView != indicator {
                // Update custom view indicator
                indicator?.removeFromSuperview()
                bezelView.addSubview(customView)
                indicator = customView
            }
        case .text:
            indicator?.removeFromSuperview()
            indicator = nil
        }
        indicator?.translatesAutoresizingMaskIntoConstraints = false
        
        if let pregressDisplayableView = indicator as? ProgressDisplayableView {
            pregressDisplayableView.progress = progress
        }
        
        indicator?.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 998), for: .horizontal)
        indicator?.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 998), for: .vertical)
        
        updateViews(for: contentColor)
        setNeedsUpdateConstraints()
    }
    
    private func updateViews(for color: UIColor) {
        textLabel.textColor = color
        detailLabel.textColor = color
        
        // UIAppearance settings are prioritized. If they are preset the set color is ignored.
        
        switch indicator {
        case let activityIndicatorView as UIActivityIndicatorView:
            let appearance = UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [ProgressHUD.self])
            if appearance.color == nil {
                activityIndicatorView.color = color
            }
        case let roundProgressView as RoundProgressView:
            let appearance = RoundProgressView.appearance(whenContainedInInstancesOf: [ProgressHUD.self])
            if appearance.progressTintColor != color {
                roundProgressView.progressTintColor = color
            }
            if appearance.backgroundTintColor != color {
                roundProgressView.backgroundTintColor = color.withAlphaComponent(0.1)
            }
        case let barProgressView as BarProgressView:
            let appearance = BarProgressView.appearance(whenContainedInInstancesOf: [ProgressHUD.self])
            if appearance.progressColor != color {
                barProgressView.progressColor = color
            }
            if appearance.lineColor != color {
                barProgressView.lineColor = color
            }
        default:
            indicator?.tintColor = color
        }
    }
    
    private func updateBezelMotionEffects() {
        if areDefaultMotionEffectsEnabled {
            let effectOffset: CGFloat = 10
            
            let effectX = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
            effectX.maximumRelativeValue = effectOffset
            effectX.minimumRelativeValue = -effectOffset
            
            let effectY = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
            effectY.maximumRelativeValue = effectOffset
            effectY.minimumRelativeValue = -effectOffset
            
            let group = UIMotionEffectGroup()
            group.motionEffects = [effectX, effectY]
            
            bezelView.addMotionEffect(group)
        } else {
            let motionEffects = bezelView.motionEffects
            for effect in motionEffects {
                bezelView.removeMotionEffect(effect)
            }
        }
    }
}

// MARK: - Layout

extension ProgressHUD {
    
    public override func updateConstraints() {
        
        let metrics = ["margin": margin]
        
        var subviews: [UIView] = [topSpacer, textLabel, detailLabel, bottomSpacer]
        if let indicator = indicator {
            subviews.insert(indicator, at: 1)
        }
        
        // Remove existing constraints
        removeConstraints(constraints)
        topSpacer.removeConstraints(topSpacer.constraints)
        bottomSpacer.removeConstraints(bottomSpacer.constraints)
        if !bezelConstraints.isEmpty {
            bezelView.removeConstraints(bezelConstraints)
            bezelConstraints.removeAll()
        }
        
        // Center bezel in container (self), applying the offset if set
        var centeringConstraints = [NSLayoutConstraint]()
        centeringConstraints.append(NSLayoutConstraint(item: bezelView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: offset.x))
        centeringConstraints.append(NSLayoutConstraint(item: bezelView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: offset.y))
        apply(priority: UILayoutPriority(rawValue: 998), to: centeringConstraints)
        addConstraints(centeringConstraints)
        
        // Ensure minimum side margin is kept
        var sideConstraints = [NSLayoutConstraint]()
        sideConstraints += NSLayoutConstraint.constraints(withVisualFormat: "|-(>=margin)-[bezelView]-(>=margin)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metrics, views: ["bezelView": bezelView])
        sideConstraints += NSLayoutConstraint.constraints(withVisualFormat: "|-(>=margin)-[bezelView]-(>=margin)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metrics, views: ["bezelView": bezelView])
        apply(priority: UILayoutPriority(rawValue: 999), to: sideConstraints)
        addConstraints(sideConstraints)
        
        // Minimum bezel size, if set
        if minSize != .zero {
            var minSizeConstraints = [NSLayoutConstraint]()
            minSizeConstraints.append(NSLayoutConstraint(item: bezelView, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: minSize.width))
            minSizeConstraints.append(NSLayoutConstraint(item: bezelView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: minSize.height))
            apply(priority: UILayoutPriority(997), to: minSizeConstraints)
            bezelConstraints.append(contentsOf: minSizeConstraints)
        }
        
        // Square aspect ratio, if set
        if isSquare {
            let square = NSLayoutConstraint(item: bezelView, attribute: .height, relatedBy: .equal, toItem: bezelView, attribute: .width, multiplier: 1.0, constant: 0)
            square.priority = UILayoutPriority(997)
            bezelConstraints.append(square)
        }
        
        // Top and bottom spacing
        topSpacer.addConstraint(NSLayoutConstraint(item: topSpacer, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: margin))
        bottomSpacer.addConstraint(NSLayoutConstraint(item: bottomSpacer, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: margin))
        // Top and bottom spaces should be equal
        bezelConstraints.append(NSLayoutConstraint(item: topSpacer, attribute: .height, relatedBy: .equal, toItem: bottomSpacer, attribute: .height, multiplier: 1.0, constant: 0))
        
        // Layout subviews in bezel
        var paddingConstraints = [NSLayoutConstraint]()
        for (index, view) in subviews.enumerated() {
            // Center in bezel
            bezelConstraints.append(NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: bezelView, attribute: .centerX, multiplier: 1.0, constant: 0))
            // Ensure the minimum edge margin is kept
            bezelConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-(>=margin)-[view]-(>=margin)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metrics, views: ["view": view]))
            // Element spacing
            if index == 0 {
                // First, ensure spacing to bezel edge
                bezelConstraints.append(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: bezelView, attribute: .top, multiplier: 1.0, constant: 0))
            } else if index == subviews.count-1 {
                // Last, ensure spacing to bezel edge
                bezelConstraints.append(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: bezelView, attribute: .bottom, multiplier: 1.0, constant: 0))
            }
            if index > 0 {
                // Has previous
                let padding = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: subviews[index-1], attribute: .bottom, multiplier: 1.0, constant: 0)
                bezelConstraints.append(padding)
                paddingConstraints.append(padding)
            }
        }
        
        bezelView.addConstraints(bezelConstraints)
        self.paddingConstraints = paddingConstraints
        
        updatePaddingConstraints()
        super.updateConstraints()
    }
    
    public override func layoutSubviews() {
        if !needsUpdateConstraints() {
            updatePaddingConstraints()
        }
        super.layoutSubviews()
    }
    
    private func updatePaddingConstraints() {
        var hasVisibleAncestors = false
        for padding in paddingConstraints {
            var firstVisible = false
            var secondVisible = false
            if let firstView = padding.firstItem as? UIView {
                firstVisible = !firstView.isHidden && firstView.intrinsicContentSize != CGSize.zero
            }
            if let secondView = padding.secondItem as? UIView {
                secondVisible = !secondView.isHidden && secondView.intrinsicContentSize != CGSize.zero
            }
            padding.constant = firstVisible && (secondVisible || hasVisibleAncestors) ? Detault.padding : 0
            hasVisibleAncestors = secondVisible
        }
    }
    
    private func apply(priority: UILayoutPriority, to constraints: [NSLayoutConstraint]) {
        for constraint in constraints {
            constraint.priority = priority
        }
    }
}

// MARK: - Progress

extension ProgressHUD {
    
    private func updateProgressDisplayLink(enabled: Bool) {
        if enabled, progressObject != nil {
            // Only create if not already active.
            if progressObjectDisplayLink == nil {
                progressObjectDisplayLink = CADisplayLink(target: self, selector: #selector(updateProgressFromProgressObject))
            }
        } else {
            progressObjectDisplayLink = nil
        }
    }
    
    @objc private func updateProgressFromProgressObject() {
        if let fractionCompleted = progressObject?.fractionCompleted {
            progress = Float(fractionCompleted)
        }
    }
}
