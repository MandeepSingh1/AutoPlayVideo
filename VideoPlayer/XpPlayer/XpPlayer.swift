//
//  XpPlayer.swift
//  App411
//
//  Created by Mandeep Singh on 09/10/18.
//  Copyright © 2018 osvinuser. All rights reserved.
//
import UIKit
import AVFoundation

public class XpPlayerLayer: AVPlayerLayer {
    
    public var isStory = false
    var needRefreshFrame = false
    fileprivate var timeObserver: Any?
    fileprivate var isBackgroundPause = false
    fileprivate var cahce = XpCache()
    fileprivate var isUpdatePlayer = Bool()
    fileprivate var playStatusBlock: ((_ status: XpPlayerPlayStatus) ->Void)?
    
    fileprivate let assetKeysRequiredToPlay = [
        "duration",
        "playable",
        "hasProtectedContent",
        ]
    
    fileprivate var indicator = XpProgress()
    fileprivate var asset: AVURLAsset?
    public var cacheType: XpPlayerCacheType = .none
    fileprivate var isInitLayer = false
    public var changeViewClearPlayer = true
    var clearURLWhenChangeView = true
    
    var durationTime: Float64?
    
    // prevent set frame frequently
    override public var frame: CGRect {
        set {
            if newValue == frame {
                return
            }
            
            super.frame = newValue
            if newValue != .zero && needRefreshFrame {
                CATransaction.commit()
                needRefreshFrame = false
            }
        } get {
            return super.frame
        }
    }
    
    //background View
    lazy var bgView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(self.thumbImageView)
        v.addSubview(self.indicator)
        self.indicator.mPlayFit.layoutFitSuper()
        self.thumbImageView.mPlayFit.layoutFitSuper()
        v.frame = .zero
        v.backgroundColor = UIColor.clear
        return v
    }()
    
    weak fileprivate var _playView: UIView? {
        willSet {
            bgView.removeFromSuperview()
            self.removeFromSuperlayer()
        } didSet {
            guard let new = _playView else {
                return
            }
            new.addSubview(self.bgView)
            self.bgView.mPlayFit.layoutFitSuper()
            self.bgView.layoutIfNeeded()
            self.updateCoverConstraint()
            new.isUserInteractionEnabled = true
            new.layer.insertSublayer(self, at: 0)
        }
    }
    
    public var progressType: ProgressType = .default {
        didSet {
            indicator.set()
        }
    }
    
    public var coverFitType: XpViewFitType = .fitToVideoRect {
        didSet {
            thumbImageView.contentMode = (coverFitType == .fitToVideoRect) ? .scaleAspectFit : .scaleAspectFill
            self.updateCoverConstraint()
        }
    }
    
    public lazy var thumbImageView: UIImageView = {
        let t = UIImageView()
        t.clipsToBounds = true
        return t
    }()
    
    public var isStopPlayer : Bool {
        set {
            self.isUpdatePlayer = newValue
            if newValue == true {
                self.startLoading(isStart: false)
                self.player?.pause()
                self.player?.cancelPendingPrerolls()
            } else if newValue == false && self.playView != nil {
                self.updateCoverConstraint()
                self.currentPlayStatus = .playerStart
            }
        } get {
            return isUpdatePlayer
        }
    }
    
    public var playView: UIView? {
        set {
            if self.playView != newValue {
                self._playView = newValue
                if clearURLWhenChangeView && changeViewClearPlayer {
                    self.playUrl = nil
                }
            }
        } get {
            return _playView
        }
    }
    
    public var currentPlayStatus: XpPlayerPlayStatus = .unknown {
        didSet {
            if let block = self.playStatusBlock {
                block(currentPlayStatus)
            }
            switch self.currentPlayStatus {
            case .playerStart:
//                self.thumbImageView.isHidden = true
                self.startLoading(isStart: false)
                self.player?.play()
            case .ready:
                self.thumbImageView.isHidden = false
            case .bufferingStart:
                self.thumbImageView.isHidden = false
                self.startLoading(isStart: true)
                self.player?.pause()
            case .bufferingEnd:
                self.thumbImageView.isHidden = false
                self.startLoading(isStart: false)
                if !self.isStopPlayer && self.playView != nil {
                    self.player?.play()
                } else {
                    self.player?.pause()
                }
            case .failed(err: _):
                self.thumbImageView.isHidden = false
                self.startLoading(isStart: false)
            case .unknown:
                self.thumbImageView.isHidden = false
                self.startLoading(isStart: false)
            default:
                self.thumbImageView.isHidden = true
                break
            }
        }
    }
    
    
    public var playUrl: URL? {
        willSet {
            self.currentPlayStatus = .unknown
            self.isBackgroundPause = false
            
            autoreleasepool {
                self.player?.replaceCurrentItem(with: nil)
            }
            
            guard let url = newValue else {
                return
            }
            self.startLoading(isStart: true)
            if let cacheItem = self.cahce.getItem(key: url) , cacheItem.status == .readyToPlay {
                self.asset = (cacheItem.asset as? AVURLAsset)
                autoreleasepool {
                    self.player?.replaceCurrentItem(with: cacheItem)
                }
            } else {
                self.asset = AVURLAsset(url: url)
                
                self.asset?.loadValuesAsynchronously(forKeys: assetKeysRequiredToPlay) { [weak self] in
                    DispatchQueue.main.async {
                        if let a = self?.asset, let keys = self?.assetKeysRequiredToPlay {
                            for key in keys {
                                var error: NSError?
                                let _ =  a.statusOfValue(forKey: key, error: &error)
                                if let e = error {
                                    self?.currentPlayStatus = .failed(err: e.localizedDescription)
                                    return
                                }
                            }
                            
                            let item = AVPlayerItem(asset: a)
                            switch self?.cacheType {
                            case .some(.memory(let count)):
                                self?.cahce.cacheCount = count
                                self?.cahce.appendCache(key: url, item: item)
                            default:
                                self?.cahce.removeAll()
                                
                            }
                            self?.player?.replaceCurrentItem(with: item)
                        }
                    }
                }
            }
        }
    }
  
    public override init(layer: Any) {
        isInitLayer = true
        super.init(layer: layer)
        (layer as? XpPlayerLayer)?.isInitLayer = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init() {
        super.init()
        self.setup()
    }
    
    fileprivate func setup() {
        self.player = AVPlayer()
        if #available(iOS 10.0, *) {
            self.player?.playImmediately(atRate: 1.0)
            player?.automaticallyWaitsToMinimizeStalling = false
        } else {
            // Fallback on earlier versions
        }
        self.backgroundColor = UIColor.black.cgColor
        self.progressType = .default
        self.addPlayerObserver()
        CATransaction.setDisableActions(true)
    }
    
    func updateCoverConstraint() {
        self.frame = bgView.bounds
        self.bounds = bgView.frame
    }
    
    fileprivate var willPlayUrl: URL? {
        didSet {
            if oldValue != willPlayUrl {
                self.playUrl = nil
            }
        }
    }
    public func set(url: URL?, state: ((_ status: XpPlayerPlayStatus) -> ())?) {
        self.playStatusBlock = state
        self.willPlayUrl = url
    }
    
    public func stopLoading() {
        self.willPlayUrl = nil
    }
    
    public func startLoading() {
        switch self.currentPlayStatus {
        case .playing, .pause:
            if self.playUrl == willPlayUrl {
                return
            }
        default:
            break
        }
        self.playUrl = willPlayUrl
    }
    
    // for video file time Duration
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    fileprivate func addPlayerObserver() {
        NotificationCenter.default.removeObserver(self)
        if timeObserver == nil {
            timeObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [weak self] (time) in
                
                guard let strongSelf = self else {return}
                
                if time.isIndefinite {
                    return
                }

                if strongSelf.player?.currentItem?.currentTime() != time && strongSelf.player?.isPlaying ?? false {
                    if strongSelf.indicator.isAnimatingStart {
                        strongSelf.currentPlayStatus = .playerStart
                    }
                }
            })
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil, using: { [weak self] (nitification) in
            switch self?.currentPlayStatus ?? .unknown {
            case .pause:
                self?.isBackgroundPause = true
            default:
                self?.isBackgroundPause = false
            }
            self?.player?.pause()
        })
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil, using: { [weak self] (nitification) in
            if self?.isBackgroundPause == false {
                if let strongSelf = self {
                    if !strongSelf.isStopPlayer && strongSelf.playView != nil {
                        strongSelf.player?.play()
                    }
                }
            }
            self?.isBackgroundPause = false
        })
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: nil, using: { [weak self] (_) in
            
            guard let strongSelf = self else {return}
            
            if let s = self?.currentPlayStatus {
                switch s {
                case .playing, .pause, .playerStart:
                    self?.currentPlayStatus = .end
                    if !strongSelf.isStory {
                        strongSelf.startAgain()
                    }
                case .end:
                    self?.startAgain()
                default: break
                }
            }
        })
        bgView.safeAdd(observer: self, forKeyPath: "frame", options: [.new,.old], context: nil)
        bgView.safeAdd(observer: self, forKeyPath: "bounds", options: [.new,.old], context: nil)
        self.safeAdd(observer: self, forKeyPath: "videoRect", options: [.new , .old], context: nil)
        self.player?.safeAdd(observer: self, forKeyPath: "Muted", options: [.new, .old], context: nil)
        self.player?.safeAdd(observer: self, forKeyPath: "rate", options: [.new, .old], context: nil)
        self.player?.safeAdd(observer: self, forKeyPath: "currentItem", options: [.new , .old], context: nil)
    }
    
    private func startAgain() {
        if !self.isStopPlayer && self.playView != nil {
            self.player?.seek(to: CMTime.zero)
            self.player?.play()
        }
    }
    
    func removeAllObserver() {
        bgView.safeRemove(observer: self, forKeyPath: "frame")
        bgView.safeRemove(observer: self, forKeyPath: "bounds")
        self.player?.replaceCurrentItem(with: nil)
        self.player?.pause()
        self.safeRemove(observer: self, forKeyPath: "videoRect")
        self.player?.safeRemove(observer: self, forKeyPath: "Muted")
        self.player?.safeRemove(observer: self, forKeyPath: "rate")
        NotificationCenter.default.removeObserver(self)
        self.player?.safeRemove(observer: self, forKeyPath: "currentItem")
        
        if let t = timeObserver {
            self.player?.removeTimeObserver(t)
            timeObserver = nil
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let k = keyPath {
            switch k {
            case "frame":
                let old = (change?[.oldKey] as? CGRect) ?? .zero
                if let new = change?[.newKey] as? CGRect, old != new && new != .zero {
                    self.updateCoverConstraint()
                }
            case "bounds":
                let old = (change?[.oldKey] as? CGRect) ?? .zero
                if let new = change?[.newKey] as? CGRect, old != new && new != .zero{
                    self.updateCoverConstraint()
                }
            case "videoRect":
                let old = (change?[.oldKey] as? CGRect) ?? .zero
                
                if let new = change?[.newKey] as? CGRect, old != new {
                    self.updateCoverConstraint()
                }
            case "Muted":
                if let old = change?[.oldKey] as? Bool,
                    let new = change?[.newKey] as? Bool, old != new {
                    self.player?.isMuted = new
                }
            case "rate":
                switch self.currentPlayStatus {
                case .playing, .pause, .ready, .bufferingStart, .bufferingEnd:
                    if let new = change?[.newKey] as? CGFloat {
                        self.currentPlayStatus = (new == 0.0) ? .pause : .playing
                    }
                case .end:
                    let current = self.player?.currentItem?.currentTime().seconds ?? 0.0
                    let total = self.player?.currentItem?.duration.seconds ?? 0.0
                    if let new = change?[.newKey] as? CGFloat , current < total {
                        self.currentPlayStatus = (new == 0.0) ? .pause : .playing
                    }
                default:
                    break
                }
            case "currentItem":
                if let old = change?[.oldKey] as? AVPlayerItem {
                    old.safeRemove(observer: self, forKeyPath: "playbackBufferEmpty")
                    old.safeRemove(observer: self, forKeyPath: "playbackLikelyToKeepUp")
                    old.safeRemove(observer: self, forKeyPath: "status")
                }
                
                if let new = change?[.newKey] as? AVPlayerItem {
                    new.safeAdd(observer: self, forKeyPath: "status", options: [.new], context: nil)
                    new.safeAdd(observer: self, forKeyPath: "playbackLikelyToKeepUp", options: [.new , .old], context: nil)
                    new.safeAdd(observer: self, forKeyPath: "playbackBufferEmpty", options: [.new , .old], context: nil)
                }
            case "playbackBufferEmpty":
                if let c = change?[.newKey] as? Bool, c == true {
                    self.startLoading(isStart: true)
                    currentPlayStatus = .bufferingStart
                }
            case "playbackLikelyToKeepUp":
                if let c = change?[.newKey] as? Bool, c == true {
                    self.startLoading(isStart: false)
                    currentPlayStatus = .bufferingEnd
                }
            case "status":
                print("status")
                let s = self.convertItemStatus()
                switch s {
                case .failed(_) , .unknown:
                    self.currentPlayStatus = s
                case .ready:
                    switch self.currentPlayStatus {
                        
                    case .bufferingStart:
                        self.currentPlayStatus = s
                        
                    case .bufferingEnd:
                        self.currentPlayStatus = s
                        
                    case .ready:
                        if self.isBackgroundPause {
                            return
                        }
                        self.currentPlayStatus = s
                    case .failed(_) ,.unknown:
                        self.currentPlayStatus = s
                    default:
                        break
                    }
                default:
                    print(k)
                    break
                }
            default:
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
        }
    }
    
    fileprivate func convertItemStatus() -> XpPlayerPlayStatus {
        if let item = self.player?.currentItem {
            switch item.status {
            case .failed:
                let msg =  item.error?.localizedDescription ??  ""
                return .failed(err: msg)
            case .readyToPlay:
                return .ready
            case .unknown:
                return .unknown
            @unknown default:
                break
            }
        }
        return .unknown
    }
    
    public func startLoading(isStart: Bool) {
        if isStart {
            self.indicator.start()
        } else {
            self.indicator.stop()
        }
    }
    
    deinit {
        if !isInitLayer {
            self.removeAllObserver()
        }
    }
}

extension AVPlayer {
    
    var isPlaying: Bool {
        return ((rate != 0) && (error == nil))
    }
    
    var isStop: Bool {
        return ((rate == 0) && (error == nil))
    }
}
