//
//  ViewController.swift
//  VideoPlayer
//
//  Created by Mandeep Singh on 06/07/19.
//  Copyright © 2019 Mandeep Singh. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class TableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    //MARK:- View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Table View"

        self.tableView.register(UINib(nibName: "TableViewCellView", bundle: nil), forCellReuseIdentifier: "TableViewCellView")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.updateByContentOffset()
            self?.startLoading()
        }
        
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.safeAdd(observer: self, forKeyPath: "contentOffset", options: [.new], context: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.tableView.safeRemove(observer: self, forKeyPath: "contentOffset")
    }
}

//MARK:-  UITableViewDelegate, UITableViewDataSource
extension TableViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ModelObject.shared.demoData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCellView", for: indexPath) as! TableViewCellView
        let image = ModelObject.shared.demoData[indexPath.row].image
        cell.cellImageView.dowloadFromServer(link: image ?? "")
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let m = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        return m*0.75
    }
}

extension TableViewController {
    
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
        
        let p = CGPoint(x: self.tableView!.frame.width/2, y: self.tableView!.contentOffset.y + self.tableView!.frame.width/2)
        
        if let path = self.tableView!.indexPathForRow(at: p),
            self.presentedViewController == nil {
            self.updateCell(at: path)
        }
    }

    func updateCell(at indexPath: IndexPath) {
        
        if let cell = self.tableView.cellForRow(at: indexPath) as? TableViewCellView {
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

