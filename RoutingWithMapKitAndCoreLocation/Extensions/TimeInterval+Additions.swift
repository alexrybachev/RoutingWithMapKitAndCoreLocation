//
//  TimeInterval+Additions.swift
//  RoutingWithMapKitAndCoreLocation
//
//  Created by Aleksandr Rybachev on 28.06.2022.
//

import Foundation

extension TimeInterval {
    
    var formatted: String {
        let formatted = DateComponentsFormatter()
        formatted.unitsStyle = .full
        formatted.allowedUnits = [.hour, .minute]
        
        return formatted.string(from: self) ?? ""
    }
}
