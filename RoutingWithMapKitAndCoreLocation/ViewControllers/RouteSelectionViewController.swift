//
//  RouteSelectionViewController.swift
//  RoutingWithMapKitAndCoreLocation
//
//  Created by Aleksandr Rybachev on 28.06.2022.
//

import UIKit
import MapKit
import CoreLocation

class RouteSelectionViewController: UIViewController {
    
    @IBOutlet private var inputContainerView: UIView!
    @IBOutlet private var originTextField: UITextField!
    @IBOutlet private var stopTextField: UITextField!
    @IBOutlet private var extraStopTextField: UITextField!
    
    @IBOutlet private var calculateButton: UIButton!
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var keyboardAvoidingConstraints: NSLayoutConstraint!
    
    @IBOutlet private var suggestionLabel: UILabel!
    @IBOutlet private var suggestionContainerView: UIView!
    @IBOutlet private var suggestionContainerTopConstraint: NSLayoutConstraint!
    
    private let defaultAnimationDuration: TimeInterval = 0.25
    private let locationManager = CLLocationManager()
    private var currentPlace: CLPlacemark?
    private let completer = MKLocalSearchCompleter()
    private var editingTextField: UITextField?
    private var currentRegion: MKCoordinateRegion?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        suggestionContainerView.addBorder()
        inputContainerView.addBorder()
        calculateButton.stylize()
        
        completer.delegate = self
        
        beginObserving()
        configureGestures()
        configureTextFields()
        attemptLocationAccess()
        hideSuggestionView(animated: false)
    }
    
    // MARK: - Helpers
    
    private func configureGestures() {
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(handleTap)
            )
        )
        suggestionContainerView.addGestureRecognizer(
            UIGestureRecognizer(
                target: self,
                action: #selector(suggestionTapped)
            )
        )
    }
    
    private func configureTextFields() {
        originTextField.delegate = self
        stopTextField.delegate = self
        extraStopTextField.delegate = self
        
        originTextField.addTarget(
            self,
            action: #selector(textFieldDidChange),
            for: .editingChanged
        )
        
        stopTextField.addTarget(
            self,
            action: #selector(textFieldDidChange),
            for: .editingChanged
        )
        
        extraStopTextField.addTarget(
            self,
            action: #selector(textFieldDidChange),
            for: .editingChanged
        )
    }
    
    private func attemptLocationAccess() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.requestLocation()
        }
    }
    
    private func hideSuggestionView(animated: Bool) {
//        suggestionContainerTopConstraint.constant = -1 * (suggestionContainerView.bounds.height + 1)
        
        guard animated else {
            view.layoutIfNeeded()
            return
        }
        
        UIView.animate(withDuration: defaultAnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func showSuggestion(_ suggestion: String) {
        suggestionLabel.text = suggestion
//        suggestionContainerTopConstraint.constant = -4 // to hide the top conrners
        
        UIView.animate(withDuration: defaultAnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Alert
    
    private func presentAlert(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField == originTextField && currentPlace != nil {
            currentPlace = nil
            textField.text = ""
        }
        
        guard let query = textField.contents else {
            hideSuggestionView(animated: true)
            
            if completer.isSearching {
                completer.cancel()
            }
            return
        }
        
        completer.queryFragment = query
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let gestureView = gesture.view
        let point = gesture.location(in: gestureView)
        
        guard let hitView = gestureView?.hitTest(point, with: nil), hitView == gestureView else { return }
        
        view.endEditing(true)
    }
    
    @objc private func suggestionTapped(_ gesture: UITapGestureRecognizer) {
        hideSuggestionView(animated: true)
        
        editingTextField?.text = suggestionLabel.text
        editingTextField = nil
    }
    
    // TODO: - !!!!
    
    @IBAction private func calculateButtonTapped() {
        view.endEditing(true)
        
        calculateButton.isEnabled = false
        activityIndicatorView.startAnimating()
        
        let segment: RouteBuilder.Segment?
        if let currentLocation = currentPlace?.location {
            segment = .location(currentLocation)
        } else if let originValue = originTextField.contents {
            segment = .text(originValue)
        } else {
            segment = nil
        }
        
        let stopSegments: [RouteBuilder.Segment] = [
            stopTextField.contents,
            extraStopTextField.contents
        ].compactMap { contents in
            if let value = contents {
                return .text(value)
            } else {
                return nil
            }
        }
        
        guard let originSegment = segment, !stopSegments.isEmpty else {
            presentAlert("Please select an origin and at least 1 stop.")
            activityIndicatorView.stopAnimating()
            calculateButton.isEnabled = true
            return
        }
        
        RouteBuilder.buildRoute(
            origin: originSegment,
            stops: stopSegments,
            within: currentRegion) { result in
                self.calculateButton.isEnabled = true
                self.activityIndicatorView.stopAnimating()
                
                switch result {
                case .success(let route):
                    let viewController = DirectionsViewController(route: route)
                    self.present(viewController, animated: true)
                case .failure(let error):
                    let errorMessage: String
                    
                    switch error {
                    case .invalidSegment(let reason):
                        errorMessage = "There was an error with: \(reason)."
                    }
                    
                    self.presentAlert(errorMessage)
                }
            }
    }
    
    // MARK: - Notifications
    
    private func beginObserving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardFrameChange),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    @objc private func handleKeyboardFrameChange(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let viewHeight = view.bounds.height - view.safeAreaInsets.bottom
        let visibleHeight = viewHeight - frame.origin.y
//        keyboardAvoidingConstraints.constant = visibleHeight + 32
        
        UIView.animate(withDuration: defaultAnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITextFieldDelegate

extension RouteSelectionViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideSuggestionView(animated: true)
        
        if completer.isSearching {
            completer.cancel()
        }
        
        editingTextField = textField
    }
}

// MARK: - CLLocationManagerDelegate

extension RouteSelectionViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else { return }
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let firstLocation = locations.first else { return }
        
        let commonDelta: CLLocationDegrees = 25 / 111
        let span = MKCoordinateSpan(latitudeDelta: commonDelta, longitudeDelta: commonDelta)
        let region = MKCoordinateRegion(center: firstLocation.coordinate, span: span)

        currentRegion = region
        completer.region = region
        
        CLGeocoder().reverseGeocodeLocation(firstLocation) { places, _ in
            guard let firstPlace = places?.first, self.originTextField.contents == nil else { return }
            
            self.currentPlace = firstPlace
            self.originTextField.text = firstPlace.abbreviation
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error requesting location: \(error.localizedDescription)")
    }
}

// MARK: - MKLocalSerchCompleterDelegate

extension RouteSelectionViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        guard let firstResult = completer.results.first else { return }
        
        showSuggestion(firstResult.title)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error suggesting a location: \(error.localizedDescription)")
    }
}
