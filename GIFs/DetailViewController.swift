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

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()

        imageView.contentMode = .scaleAspectFit
        if let imageURLString = media.images?.original?.gifUrl, let imageURL = URL(string: imageURLString) {
            let options = YYWebImageOptions.setImageWithFadeAnimation
            imageView.yy_setImage(with: imageURL, placeholder: nil, options: options) { (_, _, _, _, _) in
                activityIndicator.stopAnimating()
            }
        } else {
            // TODO: Recover from this error?
            print("ERROR: Failed to create URL for media.")
        }

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        view.addSubview(imageView)
        view.addConstraints([
            imageView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
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
