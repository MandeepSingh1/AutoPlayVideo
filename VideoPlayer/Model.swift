//
//  Model.swift
//  VideoPlayer
//
//  Created by Mandeep Singh on 06/07/19.
//  Copyright © 2019 Mandeep Singh. All rights reserved.
//

import Foundation

struct DataSourceModel {
    
    var url: String?
    var videoType: Int?
    var image: String?
}

class DemoSource: NSObject {
    static let shared = DemoSource()
    var demoData = [DataSourceModel]()
    
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
