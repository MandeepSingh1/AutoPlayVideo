//
//  Model.swift
//  VideoPlayer
//
//  Created by Mandeep Singh on 06/07/19.
//  Copyright © 2019 Mandeep Singh. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit

struct DataSourceModel {
    
    var url: String?
    var videoType: Int?
    var image: String?
}

class ModelObject: NSObject {
    
    static let shared = ModelObject()
    var demoData = [DataSourceModel]()
    
    lazy var videoPlayer : XpPlayerLayer? = {
        let l = XpPlayerLayer()
        l.cacheType = .memory(count: 20)
        l.coverFitType = .fitToVideoRect
        l.videoGravity = AVLayerVideoGravity.resizeAspectFill
        return l
    }()
    
    override init() {
        demoData += [
            DataSourceModel(url: "https://streamingvideosonliv-hosting-mobilehub-1405133378.s3.amazonaws.com/hls/10938/image_or_video.png", videoType: 0, image: "https://streamingvideosonliv-hosting-mobilehub-1405133378.s3.amazonaws.com/hls/10938/image_thumb_300_image_or_video.png"),
            DataSourceModel(url: "https://d3v42n63sui3ft.cloudfront.net/hls/10706/output.m3u8", videoType: 1, image: "https://streamingvideosonliv-hosting-mobilehub-1405133378.s3.amazonaws.com/hls/10706/video_thumb_300_image_or_video.png"),
            DataSourceModel(url: "https://streamingvideosonliv-hosting-mobilehub-1405133378.s3.amazonaws.com/hls/10607/image_or_video.png", videoType: 0, image: "https://streamingvideosonliv-hosting-mobilehub-1405133378.s3.amazonaws.com/hls/10607/image_thumb_300_image_or_video.png"),
            DataSourceModel(url: "https://d3v42n63sui3ft.cloudfront.net/hls/10602/output.m3u8", videoType: 1, image: "https://streamingvideosonliv-hosting-mobilehub-1405133378.s3.amazonaws.com/hls/10602/video_thumb_300_image_or_video.png"),
            DataSourceModel(url: "https://d3v42n63sui3ft.cloudfront.net/hls/10706/output.m3u8", videoType: 1, image: "https://streamingvideosonliv-hosting-mobilehub-1405133378.s3.amazonaws.com/hls/10706/video_thumb_300_image_or_video.png")
        ]
    }
}
