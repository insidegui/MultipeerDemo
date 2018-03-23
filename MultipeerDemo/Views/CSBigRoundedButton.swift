//
//  CSBigRoundedButton.swift
//  CutenessKit
//
//  Created by Guilherme Rambo on 22/02/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit

open class CSBigRoundedButton: UIButton {

    public enum HighlightStyle: Int {
        case darker
        case lighter
    }

    public var highlightStyle: HighlightStyle = .darker {
        didSet {
            guard highlightStyle != oldValue else { return }

            updateHighlightLayerBackground()
        }
    }

    private struct Metrics {
        static let height: CGFloat = 47
        static let cornerRadius: CGFloat = 11

        struct Animation {
            static let highlightDuration: TimeInterval = 0.3
            static let bounceDurationIn: TimeInterval = 0.6
            static let bounceDurationOut: TimeInterval = 0.8
            static let springVelocity: CGFloat = 1.2
            static let springDamping: CGFloat = 0.4
        }
    }

    public var titleFont: UIFont = UIFont.systemFont(ofSize: 16, weight: .medium)

    public var cornerRadius: CGFloat = Metrics.cornerRadius {
        didSet {
            setNeedsLayout()
        }
    }

    public var bounces = true

    private var _backgroundColor: UIColor?

    open override var backgroundColor: UIColor? {
        get {
            return _backgroundColor
        }
        set {
            _backgroundColor = newValue

            updateAppearance()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        updateAppearance()
    }

    private lazy var backgroundLayer: CALayer = CALayer()

    private lazy var highlightLayer: CALayer = {
        let l = CALayer()

        l.opacity = 0

        return l
    }()

    private var customizedFont = false

    private func setup() {
        backgroundLayer.addSublayer(highlightLayer)

        setTitleColor(.white, for: .normal)

        layer.addSublayer(backgroundLayer)

        updateAppearance()

        addTarget(self,
                  action: #selector(transitionIntoHighlightedAppearance),
                  for: [.touchDown, .touchDragEnter])

        addTarget(self,
                  action: #selector(transitionIntoNormalAppearance),
                  for: [.touchUpInside, .touchDragExit, .touchUpOutside])

        updateHighlightLayerBackground()
    }

    private func updateAppearance() {
        backgroundLayer.zPosition = 1

        titleLabel?.layer.zPosition = 2
        titleLabel?.font = titleFont

        backgroundLayer.masksToBounds = true
        backgroundLayer.cornerRadius = cornerRadius
        backgroundLayer.frame = layer.bounds
        backgroundLayer.backgroundColor = backgroundColor?.cgColor

        highlightLayer.frame = layer.bounds
    }

    private func updateHighlightLayerBackground() {
        switch highlightStyle {
        case .lighter:
            highlightLayer.backgroundColor = UIColor.white.withAlphaComponent(0.15).cgColor
        case .darker:
            highlightLayer.backgroundColor = UIColor.black.withAlphaComponent(0.2).cgColor
        }
    }

    open override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: Metrics.height)
    }

    private let animationOptions: UIViewAnimationOptions = [
        .beginFromCurrentState,
        .allowAnimatedContent,
        .allowUserInteraction
    ]

    @objc private func transitionIntoHighlightedAppearance() {
        UIView.animate(withDuration: Metrics.Animation.highlightDuration,
                       delay: 0,
                       options: animationOptions,
                       animations:
            {
                self.highlightLayer.opacity = 1
        }, completion: nil)

        bounceInIfNeeded()
    }

    private func bounceInIfNeeded() {
        guard bounces else { return }

        UIView.animate(withDuration: Metrics.Animation.bounceDurationIn,
                       delay: 0, usingSpringWithDamping: Metrics.Animation.springDamping,
                       initialSpringVelocity: Metrics.Animation.springVelocity,
                       options: animationOptions,
                       animations:
            {
                self.layer.transform = CATransform3DMakeScale(0.95, 0.95, 1)
        }, completion: nil)
    }

    @objc private func transitionIntoNormalAppearance() {
        UIView.animate(withDuration: Metrics.Animation.highlightDuration,
                       delay: 0,
                       options: animationOptions,
                       animations:
            {
                self.highlightLayer.opacity = 0
        }, completion: nil)

        bounceOutIfNeeded()
    }

    private func bounceOutIfNeeded() {
        guard bounces else { return }

        UIView.animate(withDuration: Metrics.Animation.bounceDurationOut,
                       delay: 0, usingSpringWithDamping: Metrics.Animation.springDamping,
                       initialSpringVelocity: Metrics.Animation.springVelocity,
                       options: animationOptions,
                       animations:
            {
                self.layer.transform = CATransform3DIdentity
        }, completion: nil)
    }

}
