//
//  XpProgress.swift
//  App411
//
//  Created by Mandeep Singh on 09/10/18.
//  Copyright © 2018 osvinuser. All rights reserved.
//

import Foundation
import UIKit

class XpProgress: UIView {
    public var isAnimatingStart = false
    var disable = false
    override var frame: CGRect {
        didSet {
            self.isHidden = frame.isEmpty
        }
    }
    
    fileprivate lazy var defaultIndicator = {
        return UIActivityIndicatorView()
    }()
    
    
    func set() {
        disable = false
        self.layoutIfNeeded()
    }
    
    convenience init() {
        self.init(frame: .zero)
        self.isUserInteractionEnabled = false
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    func setup() {
        defaultIndicator.style = .whiteLarge
        self.addSubview(defaultIndicator)
        defaultIndicator.mPlayFit.layoutFitSuper()
    }
    
    func start() {
        if disable {
            return
        }
        if !self.frame.isEmpty {
            self.isHidden = false
        }
        self.isAnimatingStart = true
        self.defaultIndicator.startAnimating()
    }
    
    func stop() {
        if disable {
            return
        }
        
        self.isHidden = true
        self.isAnimatingStart = false
        self.defaultIndicator.stopAnimating()
    }
}

fileprivate let kRotationAnimationKey = "kRotationAnimationKey.rotation"

open class VGPlayerLoadingIndicator: UIView {
    
    fileprivate let indicatorLayer = CAShapeLayer()
    var timingFunction : CAMediaTimingFunction!
    var isAnimating = false
    
    public override init(frame : CGRect) {
        super.init(frame : frame)
        commonInit()
    }
    
    public convenience init() {
        self.init(frame:CGRect.zero)
        commonInit()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    override open func layoutSubviews() {
        indicatorLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height);
        updateIndicatorLayerPath()
    }
    
    internal func commonInit(){
        timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        setupIndicatorLayer()
    }
    
    internal func setupIndicatorLayer() {
        self.backgroundColor = UIColor.black
        indicatorLayer.strokeColor = UIColor.red.cgColor
        indicatorLayer.fillColor = nil
        indicatorLayer.lineWidth = 1.0
        indicatorLayer.lineJoin = CAShapeLayerLineJoin.round;
        indicatorLayer.lineCap = CAShapeLayerLineCap.round;
        layer.addSublayer(indicatorLayer)
        updateIndicatorLayerPath()
    }
    
    internal func updateIndicatorLayerPath() {
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let radius = min(self.bounds.width / 2, self.bounds.height / 2) - indicatorLayer.lineWidth / 2
        let startAngle: CGFloat = 0
        let endAngle: CGFloat = 2 * CGFloat(Double.pi)
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        indicatorLayer.path = path.cgPath
        
        indicatorLayer.strokeStart = 0.1
        indicatorLayer.strokeEnd = 1.0
    }
    
    open var lineWidth: CGFloat {
        get {
            return indicatorLayer.lineWidth
        }
        set(newValue) {
            indicatorLayer.lineWidth = newValue
            updateIndicatorLayerPath()
        }
    }
    
    open var strokeColor: UIColor {
        get {
            return UIColor(cgColor: indicatorLayer.strokeColor!)
        }
        set(newValue) {
            indicatorLayer.strokeColor = newValue.cgColor
        }
    }
    
    open func startAnimating() {
        if self.isAnimating {
            return
        }
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = 1
        animation.fromValue = 0
        animation.toValue = (2 * Double.pi)
        animation.repeatCount = Float.infinity
        animation.isRemovedOnCompletion = false
        indicatorLayer.add(animation, forKey: kRotationAnimationKey)
        isAnimating = true;
    }
    
    open func stopAnimating() {
        if !isAnimating {
            return
        }
        
        indicatorLayer.removeAnimation(forKey: kRotationAnimationKey)
        isAnimating = false;
    }
    
}



