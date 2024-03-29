//
//  DirectionsViewController.swift
//  RoutingWithMapKitAndCoreLocation
//
//  Created by Aleksandr Rybachev on 28.06.2022.
//

import UIKit
import MapKit

class DirectionsViewController: UIViewController {
    
    // mapView
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        return mapView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    // directions info
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = "Directions"
        label.font = .boldSystemFont(ofSize: 22)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        return activityIndicator
    }()
    
    private lazy var informationLabel: UILabel = {
        let label = UILabel()
        label.text = "Calculating..."
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    private lazy var calculatingStack:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [activityIndicatorView, informationLabel])
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    private lazy var directionsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [headerLabel, calculatingStack])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    
//    @IBOutlet private var mapView: MKMapView!
//    @IBOutlet private var headerLabel: UILabel!
//    @IBOutlet private var tableView: UITableView!
//    @IBOutlet private var informationLabel: UILabel!
//    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    
    private let cellIdentifier = "DirectionsCell"
    private let distanceFormatter = MKDistanceFormatter()
    
    private var mapRoutes: [MKRoute] = []
    private var totalTravelTime: TimeInterval = 0
    private var totalDistance: CLLocationDistance = 0
    
    private let route: Route
    
//    private var groupedRoutes: [(startItem: MKMapItem, endItem: MKMapItem)] = []
    
    // MARK: - Initial
    init(route: Route) {
        self.route = route
        super.init()
//        super.init(nibName: String(describing: DirectionsViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupAndRequestDirections()
        
        headerLabel.text = route.label
        
        tableView.dataSource = self
        
//        mapView.delegate = self
        mapView.showAnnotations(route.annotations, animated: false)
    }
    
    // MARK: - Subviews and constraints
    private func addSubviews() {
        view.addSubview(mapView)
        view.addSubview(directionsStack)
        view.addSubview(tableView)
        setConstraints()
    }
    
    private func setConstraints() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        
        directionsStack.translatesAutoresizingMaskIntoConstraints = false
        directionsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        directionsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        directionsStack.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20).isActive = true
        directionsStack.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -20).isActive = true
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    }
    
    // MARK: - Helpers
    private func groupAndRequestDirections() {
        /*
        guard let firstStop = route.stops.first else {
            return
        }
        
        groupedRoutes.append((route.origin, firstStop))
        
        if route.stops.count == 2 {
            let secondStop = route.stops[1]
            
            groupedRoutes.append((firstStop, secondStop))
            groupedRoutes.append((secondStop, route.origin))
        }
        
        fetchNextRoute()
         */
    }
    
    private func fetchNextRoute() {
        /*
        guard !groupedRoutes.isEmpty else {
            activityIndicatorView.stopAnimating()
            return
        }
        
        let nextGroup = groupedRoutes.removeFirst()
        let request = MKDirections.Request()
        
        request.source = nextGroup.startItem
        request.destination = nextGroup.endItem
        
        let directions = MKDirections(request: request)
        
        directions.calculate { response, error in
            guard let mapRoute = response?.routes.first else {
                self.informationLabel.text = error?.localizedDescription
                self.activityIndicatorView.stopAnimating()
                return
            }
            
            self.updateView(with: mapRoute)
            self.fetchNextRoute()
        }
         */
    }
    
    private func updateView(with mapRoute: MKRoute) {
        /*
        let padding: CGFloat = 8
        mapView.addOverlay(mapRoute.polyline)
        mapView.setVisibleMapRect(
            mapView.visibleMapRect.union(
                mapRoute.polyline.boundingMapRect
            ),
            edgePadding: UIEdgeInsets(
                top: 0,
                left: padding,
                bottom: padding,
                right: padding
            ),
            animated: true
        )
        
        totalDistance += mapRoute.distance
        totalTravelTime += mapRoute.expectedTravelTime
        
        let informationComponents = [
            totalTravelTime.formatted,
            "• \(distanceFormatter.string(fromDistance: totalDistance))"
        ]
        informationLabel.text = informationComponents.joined(separator: " ")
        
        mapRoutes.append(mapRoute)
        tableView.reloadData()
         */
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
        /*
        let cell = { () -> UITableViewCell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) else {
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
                cell.selectionStyle = .none
                return cell
            }
            return cell
        }()
        
        let route = mapRoutes[indexPath.section]
        let step = route.steps[indexPath.row + 1]
        
        cell.textLabel?.text = "\(indexPath.row + 1): \(step.notice ?? step.instructions)"
        cell.detailTextLabel?.text = distanceFormatter.string(
            fromDistance: step.distance
        )
        
        return cell
         */
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let route = mapRoutes[section]
        return route.name
    }
}

// MARK: - MKMapViewDelegate

extension DirectionsViewController: MKMapViewDelegate {
    /*
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 3
        
        return renderer
    }
    */
}
