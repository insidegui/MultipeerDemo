//
//  CSOnboardingViewController.swift
//  CutenessKit
//
//  Created by Guilherme Rambo on 22/02/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit

open class CSOnboardingViewController: UIViewController {

    private struct Metrics {
        static let buttonSpacing: CGFloat = 14
        static let mainSpacing: CGFloat = 130
        static let titleFontSize: CGFloat = 50
        static let lateralMargin: CGFloat = 30
    }

    public var buttons: [CSBigRoundedButton] = []

    private var buttonActions: [Int: (CSBigRoundedButton) -> Void] = [:]

    public var titleFont: UIFont = UIFont.systemFont(ofSize: Metrics.titleFontSize, weight: .bold) {
        didSet {
            updateTitleLabel()
        }
    }

    public var titleTextColor: UIColor = .white {
        didSet {
            updateTitleLabel()
        }
    }

    public lazy var titleLabel: UILabel = {
        let l = UILabel()

        l.textAlignment = .left
        l.font = titleFont
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping

        return l
    }()

    open override var title: String? {
        didSet {
            updateTitleLabel()
        }
    }

    private func prepareTitleText(with title: String?) -> NSAttributedString? {
        guard let text = title else { return nil }

        let pStyle = NSMutableParagraphStyle()
        pStyle.alignment = titleLabel.textAlignment
        pStyle.lineSpacing = -10

        let kern: CGFloat = -0.55

        let attrs: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .kern: kern,
            .foregroundColor: titleTextColor,
            .paragraphStyle: pStyle
        ]

        return NSAttributedString(string: text, attributes: attrs)
    }

    private func updateTitleLabel() {
        titleLabel.attributedText = prepareTitleText(with: title)
    }

    @discardableResult func addButton(with title: String, animated: Bool = true, action: @escaping (CSBigRoundedButton) -> Void) -> CSBigRoundedButton {
        let button = CSBigRoundedButton(type: .custom)

        buttons.append(button)
        buttonActions[button.hash] = action

        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)

        button.alpha = 0
        self.buttonsStackView.addArrangedSubview(button)

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.3, delay: 0.25, options: [.beginFromCurrentState, .allowAnimatedContent, .allowUserInteraction], animations: {
            button.alpha = 1
        }, completion: nil)

        return button
    }

    @objc private func buttonAction(_ sender: CSBigRoundedButton) {
        buttonActions[sender.hash]?(sender)
    }

    public lazy var buttonsStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [])

        v.axis = .vertical
        v.spacing = Metrics.buttonSpacing

        return v
    }()

    public lazy var mainStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.titleLabel, self.buttonsStackView])

        v.axis = .vertical
        v.spacing = Metrics.mainSpacing
        v.translatesAutoresizingMaskIntoConstraints = false

        return v
    }()

    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        view.addSubview(mainStackView)
        mainStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.lateralMargin).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metrics.lateralMargin).isActive = true
    }

}
