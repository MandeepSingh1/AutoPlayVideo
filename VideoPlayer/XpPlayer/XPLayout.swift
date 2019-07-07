//
//  XPLayout.swift
//  App411
//
//  Created by Mandeep Singh on 09/10/18.
//  Copyright © 2018 osvinuser. All rights reserved.
//

import Foundation
import UIKit

struct XpPlayerLayoutFit {
    unowned let base: UIView
    
    init(_ base: UIView) {
        self.base = base
    }
    
    func layoutFitSuper() {
        self.base.translatesAutoresizingMaskIntoConstraints = false
        self.base.superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self.base]))
        self.base.superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self.base]))
    }
    
    func centerWith(size: CGSize) {
        self.base.translatesAutoresizingMaskIntoConstraints = false
        let cons = [
            NSLayoutConstraint(item: self.base,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: self.base.superview,
                               attribute: .centerX,
                               multiplier: 1,
                               constant: 0.0),
            NSLayoutConstraint(item: self.base,
                               attribute: .centerY,
                               relatedBy: .equal,
                               toItem: self.base.superview,
                               attribute: .centerY,
                               multiplier: 1,
                               constant: 0.0),
            NSLayoutConstraint(item: self.base,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 0.0,
                               constant: size.width),
            NSLayoutConstraint(item: self.base,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 0.0,
                               constant: size.height)]
        self.base.superview?.addConstraints(cons)
    }
}

protocol XpPlayerLayoutFitCompatible {
    var mPlayFit: XpPlayerLayoutFit { get set }
}

extension UIView: XpPlayerLayoutFitCompatible {
    var mPlayFit: XpPlayerLayoutFit {
        get {
            return XpPlayerLayoutFit(self)
        } set{}
    }
}

public enum XpPlayerCacheType {
    case none
    case memory(count: Int)
}

public enum XpPlayerPlayStatus {
    case ready
    case unknown
    case failed(err: String)
    case bufferingStart
    case bufferingEnd
    case playerStart
    case playing
    case pause
    case end
}

public enum XpViewFitType {
    case fitToPlayerView
    case fitToVideoRect
}

public protocol XpProgressProtocol {
    func start()
    func stop()
}

public enum ProgressType {
    case `default`
    case none
}

