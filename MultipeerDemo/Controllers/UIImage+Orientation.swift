//
//  UIImage+Orientation.swift
//  MultipeerDemo
//
//  Created by Guilherme Rambo on 24/03/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit

extension UIImage {

    var withOrientationFixed: UIImage {
        guard imageOrientation != .up else { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))

        guard let fixedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("Failed to get image from CGContext!")
        }

        UIGraphicsEndImageContext()

        return fixedImage
    }

}
