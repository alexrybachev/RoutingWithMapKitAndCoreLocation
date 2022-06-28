//
//  UITextField+Additions.swift
//  RoutingWithMapKitAndCoreLocation
//
//  Created by Aleksandr Rybachev on 28.06.2022.
//

import UIKit

extension UITextField {
    
    var contents: String? {
        guard
            let text = text?.trimmingCharacters(in: .whitespaces),
            !text.isEmpty
        else {
            return nil
        }
        
        return text
    }
}
