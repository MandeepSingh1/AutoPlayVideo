//
//  CollectionViewWithNestedController.swift
//  VideoPlayer
//
//  Created by Mandeep Singh on 08/07/19.
//  Copyright © 2019 Mandeep Singh. All rights reserved.
//

import UIKit

class CollectionViewWithNestedController: UIViewController {
    
    @IBOutlet weak var parentCollectionView: UICollectionView!
    var currentIndexPath: IndexPath?
    var cachedPosition = Dictionary<IndexPath,CGPoint>()

    //MARK:- View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Collection View Netsed Loop"
        
        self.parentCollectionView.register(UINib(nibName: "NestedCellWithCollectionView", bundle: Bundle.main), forCellWithReuseIdentifier: "NestedCellWithCollectionView")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.updateByContentOffset()
            self?.startLoading()
        }
        
        self.parentCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.parentCollectionView.safeAdd(observer: self, forKeyPath: "contentOffset", options: [.new], context: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.stopIt(isStart: true)
        self.parentCollectionView.safeRemove(observer: self, forKeyPath: "contentOffset")
    }
    
    //MARK:- viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopIt(isStart: true)
    }
    
    private func stopIt(isStart:Bool) {
        guard let player = ModelObject.shared.videoPlayer else { return }
        player.isStopPlayer = isStart
    }
}

extension CollectionViewWithNestedController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == parentCollectionView {
            return 10
        } else {
            return ModelObject.shared.demoData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == parentCollectionView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NestedCellWithCollectionView", for: indexPath) as? NestedCellWithCollectionView {
                cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
                cell.collectionView.contentOffset = self.cachedPosition[indexPath] ?? .zero
                return cell
            }
            return UICollectionViewCell()
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as? CollectionCell {
                let image = ModelObject.shared.demoData[indexPath.row].image
                cell.cellImageView.dowloadFromServer(link: image ?? "")
                return cell
            }
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if collectionView == parentCollectionView {
            if let innerCell = cell as? NestedCellWithCollectionView {
                self.cachedPosition[indexPath] = innerCell.collectionView.contentOffset
            }
        }
    }
}

extension CollectionViewWithNestedController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == parentCollectionView {
            let m = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
            return CGSize.init(width: m, height: m*0.75)
        } else {
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        }
    }
}

extension CollectionViewWithNestedController : UIScrollViewDelegate {
    
    public func setScrollPosition(x: CGFloat, collection: UICollectionView) {
        collection.setContentOffset(CGPoint(x: x >= 0 ? x : 0, y: 0), animated: false)
    }
    
    public func getScrollPosition(collection: UICollectionView) -> CGFloat {
        return collection.contentOffset.x
    }

    /* This function will execute when user swipe the collection view on Right Side */
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        if scrollView != parentCollectionView {
            let p = CGPoint(x: self.parentCollectionView!.frame.width/2, y: self.parentCollectionView!.contentOffset.y + self.parentCollectionView!.frame.width/2)

            if let path = self.parentCollectionView!.indexPathForItem(at: p),
                self.presentedViewController == nil {

                if let nestedCell = self.parentCollectionView.cellForItem(at: path) as? NestedCellWithCollectionView {
                    let pageWidth: Float = Float(nestedCell.collectionView!.frame.width)
                    // width + space
                    let currentOffset: Float = Float(scrollView.contentOffset.x)
                    let targetOffset: Float = Float(targetContentOffset.pointee.x)
                    var newTargetOffset: Float = 0
                    if targetOffset > currentOffset {
                        newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth
                    } else {
                        newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth
                    }
                    if newTargetOffset < 0 {
                        newTargetOffset = 0
                    } else if (newTargetOffset > Float(scrollView.contentSize.width)) {
                        newTargetOffset = Float(Float(scrollView.contentSize.width))
                    }

                    targetContentOffset.pointee.x = CGFloat(currentOffset)
                    scrollView.setContentOffset(CGPoint(x: CGFloat(newTargetOffset), y: scrollView.contentOffset.y), animated: true)
                }
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {

        if scrollView != self.parentCollectionView {

            let p = CGPoint(x: self.parentCollectionView!.frame.width/2, y: self.parentCollectionView!.contentOffset.y + self.parentCollectionView!.frame.width/2)

            if let path = self.parentCollectionView!.indexPathForItem(at: p),
                self.presentedViewController == nil {
                self.playAutoPlayVideo(path: path)
            }
        }
    }
    
    fileprivate func playAutoPlayVideo(path: IndexPath) {
        
        if let nestedCollectionView = self.parentCollectionView.cellForItem(at: path) as? NestedCellWithCollectionView {
            
            let nestedPoint = CGPoint(x: nestedCollectionView.collectionView!.frame.height / 2 + nestedCollectionView.collectionView!.contentOffset.x, y: nestedCollectionView.collectionView!.frame.origin.y)
            
            if let indexItem = nestedCollectionView.collectionView.indexPathForItem(at: nestedPoint) {
                
                if let oldIndexPath = self.currentIndexPath, indexItem == oldIndexPath {
                    return
                }
                
                self.currentIndexPath = indexItem
                
                if let nestedCell = nestedCollectionView.collectionView.cellForItem(at: indexItem) as? CollectionCell {
                    
                    let postModel = ModelObject.shared.demoData[indexItem.row]
                    
                    //This means it contains video and text is not compulsory.
                    if postModel.videoType == 1 {
                        
                        self.perform(#selector(startLoading), with: nil, afterDelay: 0.3)
                        
                        ModelObject.shared.videoPlayer?.playView = nestedCell.cellImageView
                        ModelObject.shared.videoPlayer?.thumbImageView.contentMode = nestedCell.cellImageView.contentMode
                        
                        if let videoURL = URL(string: postModel.url ?? "") {
                            ModelObject.shared.videoPlayer?.isStopPlayer = false
                            ModelObject.shared.videoPlayer?.set(url: videoURL, state: { (status) in
                                switch status {
                                case .playing: break
                                case .failed(err: _): break
                                default: break
                                }
                            })
                        }
                    } else {
                        self.destroyMMPlayerInstance()
                    }
                } else {
                    self.destroyMMPlayerInstance()
                }
            } else {
                self.destroyMMPlayerInstance()
            }
        }
    }
}

extension CollectionViewWithNestedController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //This logic means that user is staying on the timeline screen only.
        if keyPath == "contentOffset" {
            self.startVideoForCell()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func startVideoForCell() {
        self.updateByContentOffset()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(startLoading), with: nil, afterDelay: 0.3)
    }
    
    func updateByContentOffset() {
        
        let p = CGPoint(x: self.parentCollectionView!.frame.width/2, y: self.parentCollectionView!.contentOffset.y + self.parentCollectionView!.frame.width/2)
        
        if let path = self.parentCollectionView!.indexPathForItem(at: p),
            self.presentedViewController == nil {
            self.updateCell(at: path)
        }
    }
    
    func updateCell(at indexPath: IndexPath) {
        self.playAutoPlayVideo(path: indexPath)
    }
    
    func destroyMMPlayerInstance() {
        
        if let xpPlayer = ModelObject.shared.videoPlayer, xpPlayer.playView != nil {
            xpPlayer.isStopPlayer = true
            xpPlayer.playView = nil
        }
    }
    
    @objc func startLoading() {
        if self.presentedViewController != nil {
            return
        }
        // start loading video
        ModelObject.shared.videoPlayer?.startLoading()
    }
}
