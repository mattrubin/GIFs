//
//  CollectionViewGIFCell.swift
//  GIFs
//
//  Created by Matt Rubin on 10/23/18.
//  Copyright © 2018 Matt Rubin. All rights reserved.
//

import UIKit
import YYWebImage

class CollectionViewGIFCell: UICollectionViewCell {
    private let imageView = YYAnimatedImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        contentView.addSubview(imageView)

        // Scale the image to fill the view, clipping the image if the aspect ratios do not match.
        imageView.contentMode = .scaleAspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    func setImageURL(_ imageURL: URL) {
        imageView.yy_setImage(with: imageURL, options: .setImageWithFadeAnimation)
    }
}
