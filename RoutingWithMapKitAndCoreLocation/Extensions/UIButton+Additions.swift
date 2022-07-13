//
//  UIButton+Additions.swift
//  RoutingWithMapKitAndCoreLocation
//
//  Created by Aleksandr Rybachev on 13.07.2022.
//

import UIKit

extension UIButton {
  func stylize() {
    setTitleColor(.white, for: .normal)
    setBackgroundImage(.buttonBackground, for: .normal)
    titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
    contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
  }
}

