//
//  DirectionsViewController.swift
//  RoutingWithMapKitAndCoreLocation
//
//  Created by Aleksandr Rybachev on 28.06.2022.
//

import UIKit
import MapKit

class DirectionsViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    
    private let callIdentifier = "DirectionsCell"
    private let distanceFormatter = MKDistanceFormatter()
    
    private var mapRoutes: [MKRoute] = []
    private var totalTravelTime: TimeInterval = 0
    private var totalDistance: CLLocationDistance = 0
    
    private let route: Route
    
    // MARK: - Initial
    
    init(route: Route) {
        self.route = route
        super.init(nibName: "DirectionsViewController", bundle: Bundle.main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        headerLabel.text = route.label
        tableView.dataSource = self
        
        mapView.showAnnotations(route.annotations, animated: false)
    }
    
    // MARK: - Helpers
    
    private func groupAndRequestDirections() {
        
    }
    
    private func fetchNextRoute() {
        
    }
    
    private func updateView(with mapRoute: MKRoute) {
        
    }
}

// MARK: - UITableViewDataSource

extension DirectionsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return mapRoutes.isEmpty ? 0 : mapRoutes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let route = mapRoutes[section]
        return route.steps.count - 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let route =  mapRoutes[section]
        return route.name
    }
    
}
