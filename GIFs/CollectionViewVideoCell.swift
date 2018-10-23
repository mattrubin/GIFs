//
//  CollectionViewVideoCell.swift
//  GIFs
//
//  Created by Matt Rubin on 10/23/18.
//  Copyright © 2018 Matt Rubin. All rights reserved.
//

import UIKit
import AVFoundation

class CollectionViewVideoCell: UICollectionViewCell {
    private let videoView = VideoView()
    private var looper: AVPlayerLooper?

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        contentView.addSubview(videoView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        videoView.frame = contentView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        videoView.player = nil
        looper = nil
    }

    func setAsset(_ asset: AVAsset) {
        let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
        let player = AVQueuePlayer(playerItem: playerItem)
        looper = AVPlayerLooper(player: player, templateItem: playerItem)
        videoView.player = player
    }

    func play() {
        videoView.player?.play()
    }

    func pause() {
        videoView.player?.pause()
    }
}

// Based on https://developer.apple.com/documentation/avfoundation/avplayerlayer#overview
private class VideoView: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    private var playerLayer: AVPlayerLayer {
        // swiftlint:disable:next force_cast
        return layer as! AVPlayerLayer
    }

    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        playerLayer.videoGravity = .resizeAspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
