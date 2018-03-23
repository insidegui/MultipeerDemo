//
//  DemoFlowController.swift
//  MultipeerDemo
//
//  Created by Guilherme Rambo on 23/03/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit

class DemoFlowController: UIViewController {

    private var isInDemoMode: Bool {
        return UserDefaults.standard.bool(forKey: "DemoMode")
    }

    private lazy var homeViewController: CSOnboardingViewController = {
        let c = CSOnboardingViewController()

        c.title = "Devices"

        return c
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        installChild(homeViewController)

        if isInDemoMode {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.homeViewController.addButton(with: "iPhone X Rambo", action: { [weak self] button in
                    self?.didTapDeviceButton(button)
                })
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.homeViewController.addButton(with: "iPhone 6S", action: { [weak self] button in
                    self?.didTapDeviceButton(button)
                })
            }
        }
    }

    private func didTapDeviceButton(_ button: CSBigRoundedButton) {
        guard !isInDemoMode else {
            runDemoUpload(for: button)
            return
        }
    }

    private func runDemoUpload(for button: CSBigRoundedButton) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.transitionIntoConnectingState(for: button)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.transitionIntoUploadingState(for: button)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.transitionIntoSuccessState(for: button)
                })
            })
        })
    }

    private lazy var loadingController = LoadingOverlayViewController()

    private func transitionIntoConnectingState(for button: CSBigRoundedButton) {
        loadingController = LoadingOverlayViewController()
        loadingController.title = "Connecting"

        installChild(loadingController)

        loadingController.animateIn()
    }

    private func transitionIntoUploadingState(for button: CSBigRoundedButton) {
        loadingController.title = "Uploading"
    }

    private lazy var feedbackGenerator: UINotificationFeedbackGenerator = {
        return UINotificationFeedbackGenerator()
    }()

    private func transitionIntoSuccessState(for button: CSBigRoundedButton) {
        loadingController.hideSpinner()
        loadingController.title = "Done!"
        
        feedbackGenerator.notificationOccurred(.success)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hideOverlayLoading()
        }
    }

    private func hideOverlayLoading() {
        loadingController.animateOut()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
