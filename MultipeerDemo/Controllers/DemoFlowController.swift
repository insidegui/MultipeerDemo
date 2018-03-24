//
//  DemoFlowController.swift
//  MultipeerDemo
//
//  Created by Guilherme Rambo on 23/03/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit
import MobileCoreServices

class DemoFlowController: UIViewController {

    private var isInDemoMode: Bool {
        return UserDefaults.standard.bool(forKey: "DemoMode")
    }

    private lazy var homeViewController: CSOnboardingViewController = {
        let c = CSOnboardingViewController()

        c.title = "Devices"

        return c
    }()

    private lazy var peerService: PeerService = {
        let s = PeerService()

        s.didFindDevice = { [weak self] deviceName in
            self?.homeViewController.addButton(with: deviceName, action: { button in
                self?.didTapDeviceButton(button, for: deviceName)
            })
        }

        return s
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        peerService.startAdvertising()
        peerService.startListening()
    }

    private func didTapDeviceButton(_ button: CSBigRoundedButton, for device: String = "") {
        guard !isInDemoMode else {
            runDemoUpload(for: button)
            return
        }

        transitionIntoConnectingState(for: button)

        peerService.didConnectToDevice = { [weak self] _ in
            self?.showPhotoPicker()
        }

        peerService.connectToDevice(named: device)
    }

    private lazy var photoPickerController: UIImagePickerController = {
        let c = UIImagePickerController()

        c.mediaTypes = [kUTTypeImage as String]
        c.delegate = self

        return c
    }()

    private func showPhotoPicker() {
        present(photoPickerController, animated: true, completion: nil)
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

    private func didFinishUpload(with error: Error?) {
        NSLog("Did finish upload. Error: \(String(describing: error))")

        if let error = error {
            loadingController.title = error.localizedDescription
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.hideOverlayLoading()
            })
        } else {
            hideOverlayLoading()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

extension DemoFlowController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        hideOverlayLoading()
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        DispatchQueue.main.async {
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                NSLog("Invalid content!")
                self.hideOverlayLoading()
                return
            }

            guard let pngData = UIImagePNGRepresentation(image) else {
                NSLog("Invalid content!")
                self.hideOverlayLoading()
                return
            }

            self.dismiss(animated: true, completion: nil)

            self.peerService.sendPicture(with: pngData, completion: { [weak self] error in
                self?.didFinishUpload(with: error)
            })
        }
    }

}
