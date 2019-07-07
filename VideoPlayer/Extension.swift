//
//  Extension.swift
//  VideoPlayer
//
//  Created by Mandeep Singh on 07/07/19.
//  Copyright © 2019 Mandeep Singh. All rights reserved.
//

import Foundation
import UIKit

var bindObjKey = "ObserverBindKey"
var uuidKey = "uuid"
let imageCache = NSCache<NSString, UIImage>()

public extension NSObject {
    
    var bindObj: [UUID:[String]] {
        get {
            
            if let o = objc_getAssociatedObject(self, &bindObjKey) as? [UUID:[String]] {
                return o
            } else {
                self.bindObj = [UUID:[String]]()
                return self.bindObj
            }
            
        } set {
            objc_setAssociatedObject(self, &bindObjKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func safeAdd(observer: NSObject, forKeyPath: String, options:
        NSKeyValueObservingOptions, context: UnsafeMutableRawPointer?) {
        if bindObj[observer.uuid] == nil {
            bindObj[observer.uuid] = [String]()
        }
        if let b = bindObj[observer.uuid], !b.contains(forKeyPath) {
            bindObj[observer.uuid]?.append(forKeyPath)
            self.addObserver(observer, forKeyPath: forKeyPath, options: options, context: context)
        }
    }
    
    func safeRemove(observer: NSObject, forKeyPath: String) {
        if let b = bindObj[observer.uuid], let keyIdx = b.firstIndex(of: forKeyPath) {
            bindObj[observer.uuid]?.remove(at: keyIdx)
            self.removeObserver(observer, forKeyPath: forKeyPath)
        }
    }
    
    var uuid: UUID {
        get {
            if let o = objc_getAssociatedObject(self, &uuidKey) as? UUID {
                return o
            } else {
                objc_setAssociatedObject(self, &uuidKey, UUID(), .OBJC_ASSOCIATION_RETAIN)
                return self.uuid
            }
        }
    }
}


extension UIImageView {
    
    private func startDownload(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        
        DispatchCreate.instance.dispatchGroup.enter()

        URLSession.shared.dataTask(with: url) { data, response, error in
        
           guard let httpURLResponse = response as? HTTPURLResponse,
            let data = data, error == nil
            else { return }
            
            guard let image = UIImage(data: data) else {
                print("no image found")
                return
            }
            let string = httpURLResponse.url?.scheme ?? ""
            imageCache.setObject(image, forKey: string as NSString)
            DispatchQueue.main.async() {
                DispatchCreate.instance.dispatchGroup.leave()
                self.image = image
            }
        }.resume()
    }
    
    func dowloadFromServer(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        // check cached image
        if let cachedImage = imageCache.object(forKey: link as NSString)  {
            self.image = cachedImage
            return
        }

        guard let url = URL(string: link) else { return }
        objc_setAssociatedObject(self, &bindObjKey, url, .OBJC_ASSOCIATION_RETAIN)
        startDownload(url: url, contentMode: mode)
    }
    
}

struct DispatchCreate {
    static let instance = DispatchCreate()
    let dispatchGroup = DispatchGroup()
}
