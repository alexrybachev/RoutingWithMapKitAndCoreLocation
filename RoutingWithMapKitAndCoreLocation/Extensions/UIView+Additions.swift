//
//  UIView+Additions.swift
//  RoutingWithMapKitAndCoreLocation
//
//  Created by Aleksandr Rybachev on 13.07.2022.
//

import UIKit

extension UIView {
    func addBorder() {
        layer.borderWidth = 1
        layer.cornerRadius = 3
        layer.borderColor = UIColor.border.cgColor
    }
}
