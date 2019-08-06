//
//  LoadingOverlayViewController.swift
//  MultipeerDemo
//
//  Created by Guilherme Rambo on 23/03/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit

class LoadingOverlayViewController: UIViewController {

    private lazy var stackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [spinner, statusLabel])

        v.axis = .vertical
        v.spacing = 16
        v.translatesAutoresizingMaskIntoConstraints = false

        return v
    }()

    override var title: String? {
        didSet {
            statusLabel.text = title
        }
    }

    private lazy var statusLabel: UILabel = {
        let l = UILabel()

        l.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.8)
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping
        l.textAlignment = .center

        return l
    }()

    private lazy var spinner: UIActivityIndicatorView = {
        return UIActivityIndicatorView(style: .white)
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        spinner.startAnimating()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        spinner.stopAnimating()
    }

    func animateIn() {
        spinner.startAnimating()

        UIView.animate(withDuration: 0.4) {
            self.view.alpha = 1
        }
    }

    func animateOut() {
        UIView.animate(withDuration: 0.4, animations: {
            self.view.alpha = 0
        }) { _ in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }

    func hideSpinner() {
        UIView.animate(withDuration: 0.4) {
            self.spinner.isHidden = true
            self.spinner.alpha = 0
            self.stackView.setNeedsLayout()
            self.stackView.layoutIfNeeded()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.isOpaque = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.alpha = 0

        view.addSubview(stackView)
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
    }

}
