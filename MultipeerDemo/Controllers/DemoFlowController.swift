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
        s.didReceiveFile = { [weak self] url in
            self?.didReceiveImage(at: url)
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
                self.transitionIntoUploadingState()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.transitionIntoSuccessState()
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

    private func transitionIntoUploadingState() {
        loadingController.title = "Uploading"
    }

    private lazy var feedbackGenerator: UINotificationFeedbackGenerator = {
        return UINotificationFeedbackGenerator()
    }()

    private func transitionIntoSuccessState() {
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
            transitionIntoSuccessState()
        }
    }

    private lazy var receivedImageController = FloatingPictureViewController()

    private func didReceiveImage(at url: URL) {
        guard let image = UIImage(contentsOfFile: url.path) else { return }

        receivedImageController = FloatingPictureViewController()

        installChild(receivedImageController)

        receivedImageController.animate(image: image, from: .bottom)
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

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        DispatchQueue.main.async {
            self.transitionIntoUploadingState()

            guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else {
                NSLog("Invalid content!")
                self.hideOverlayLoading()
                return
            }

            guard let pngData = image.withOrientationFixed.pngData() else {
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
