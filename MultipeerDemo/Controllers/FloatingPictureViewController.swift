//
//  FloatingPictureViewController.swift
//  MultipeerDemo
//
//  Created by Guilherme Rambo on 24/03/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit

class FloatingPictureViewController: UIViewController {

    enum AnimationOrigin: Int {
        case top
        case bottom
    }

    private lazy var imageView: UIImageView = {
        let v = UIImageView()

        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.height - 120).isActive = true
        v.clipsToBounds = true
        v.layer.cornerRadius = 10
        v.contentMode = .scaleAspectFill

        return v
    }()

    private lazy var imageViewCenteringConstraint: NSLayoutConstraint = {
        return imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -UIScreen.main.bounds.height)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(imageView)

        imageViewCenteringConstraint.isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(hide))
        view.addGestureRecognizer(tap)
    }

    func animate(image: UIImage, from origin: AnimationOrigin) {
        imageView.alpha = 0
        imageView.image = image

        imageViewCenteringConstraint.constant = origin == .bottom ? -UIScreen.main.bounds.height : UIScreen.main.bounds.height

        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.2, options: [.allowAnimatedContent, .beginFromCurrentState], animations: {
            self.imageView.alpha = 1
            self.imageViewCenteringConstraint.constant = 0
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    @objc func hide() {
        UIView.animate(withDuration: 0.4, animations: {
            self.view.alpha = 0
        }) { _ in
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }
    }

}
