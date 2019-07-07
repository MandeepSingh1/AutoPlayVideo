//
//  CollectionViewController.swift
//  VideoPlayer
//
//  Created by Mandeep Singh on 06/07/19.
//  Copyright © 2019 Mandeep Singh. All rights reserved.
//

import UIKit


class CollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!

    //MARK:- View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Collection View"

        self.collectionView.register(UINib(nibName: "CollectionCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CollectionCell")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.updateByContentOffset()
            self?.startLoading()
        }
        
        self.collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.collectionView.safeAdd(observer: self, forKeyPath: "contentOffset", options: [.new], context: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.collectionView.safeRemove(observer: self, forKeyPath: "contentOffset")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ModelObject.shared.demoData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as? CollectionCell {
            let image = ModelObject.shared.demoData[indexPath.row].image
            cell.cellImageView.dowloadFromServer(link: image ?? "")
            return cell
        }
        return UICollectionViewCell()
    }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let m = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        return CGSize.init(width: m, height: m*0.75)
    }
}

extension CollectionViewController {
    
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
        
        let p = CGPoint(x: self.collectionView!.frame.width/2, y: self.collectionView!.contentOffset.y + self.collectionView!.frame.width/2)
        
        if let path = self.collectionView!.indexPathForItem(at: p),
            self.presentedViewController == nil {
            self.updateCell(at: path)
        }
    }
    
    func updateCell(at indexPath: IndexPath) {
        
        if let cell = self.collectionView.cellForItem(at: indexPath) as? CollectionCell {
            // this thumb use when transition start and your video dosent start
            let postModel = ModelObject.shared.demoData[indexPath.row]
            ModelObject.shared.videoPlayer?.playView = cell.cellImageView
            ModelObject.shared.videoPlayer?.thumbImageView.contentMode = cell.cellImageView.contentMode
            //This means it contains video and text is not compulsory.
            if postModel.videoType == 1 {
                
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
        }
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
