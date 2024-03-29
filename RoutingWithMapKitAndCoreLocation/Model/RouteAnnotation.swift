//
//  RouteAnnotation.swift
//  RoutingWithMapKitAndCoreLocation
//
//  Created by Aleksandr Rybachev on 28.06.2022.
//

import MapKit

class RouteAnnotation: NSObject {
    private let item: MKMapItem
    
    init(item: MKMapItem) {
        self.item = item
        
        super.init()
    }
}

// MARK: - MKAnnotation

extension RouteAnnotation: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return item.placemark.coordinate
    }
    
    var title: String? {
        return item.name
    }
}
