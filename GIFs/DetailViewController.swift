//
//  DetailViewController.swift
//  GIFs
//
//  Created by Matt Rubin on 10/23/18.
//  Copyright © 2018 Matt Rubin. All rights reserved.
//

import UIKit
import GiphyCoreSDK
import YYWebImage

class DetailViewController: UIViewController {
    let media: GPHMedia
    lazy var imageView = YYAnimatedImageView()

    init(media: GPHMedia) {
        self.media = media
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        imageView.contentMode = .scaleAspectFit
        if let imageURLString = media.images?.original?.gifUrl, let imageURL = URL(string: imageURLString) {
            imageView.yy_setImage(with: imageURL, options: .setImageWithFadeAnimation)
        } else {
            // TODO: Recover from this error?
            print("ERROR: Failed to create URL for media.")
        }

        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        view.addConstraints([
            imageView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        ])
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: Interaction

    // At the end of any touch interaction, dismiss the detail view controller.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.presentingViewController?.dismiss(animated: true)
    }
}
