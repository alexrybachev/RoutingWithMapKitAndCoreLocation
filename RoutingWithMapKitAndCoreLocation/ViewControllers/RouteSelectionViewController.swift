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
    
    // MARK: - View and subviews
    // title
    private lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.text = "RWRouter"
        title.font = .boldSystemFont(ofSize: 38)
        return title
    }()
    
    // labels and textFields
    private lazy var origintLabel: UILabel = {
        let title = UILabel()
        title.text = "Start / End"
        title.font = .boldSystemFont(ofSize: 15)
        return title
    }()
    
    private lazy var stopLabel: UILabel = {
        let title = UILabel()
        title.text = "Stop"
        title.font = .boldSystemFont(ofSize: 15)
        return title
    }()
    
    private lazy var extraStopLabel: UILabel = {
        let title = UILabel()
        title.text = "Extra Stop"
        title.font = .boldSystemFont(ofSize: 15)
        return title
    }()
    
    private lazy var originTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Origin Address"
        textField.font = .systemFont(ofSize: 14)
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var stopTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Stop #1 Address"
        textField.font = .systemFont(ofSize: 14)
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var extraStopTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Stop #2 Address"
        textField.font = .systemFont(ofSize: 14)
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var menuStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            origintLabel,
            originTextField,
            stopLabel,
            stopTextField,
            extraStopLabel,
            extraStopTextField
        ])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    private lazy var inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 10
        return view
    }()
    
    // address suggection
    private lazy var didYouMeanLabel: UILabel = {
        let label = UILabel()
        label.text = "Did you mean:"
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var suggestionLabel: UILabel = {
        let label = UILabel()
        label.text = "Address suggestion"
        label.tintColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    
    private lazy var suggestionStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [didYouMeanLabel, suggestionLabel])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    private lazy var suggestionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 10
        return view
    }()
    
    // calculate route and activityIndicator
    private var calculateButton: UIButton = {
        let button = UIButton()
        button.setTitle("Calculate Route", for: .normal)
        button.addTarget(RouteSelectionViewController.self, action: #selector(calculateButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.color = .blue
        return activityIndicator
    }()
    
    private lazy var calculateStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [calculateButton, activityIndicatorView])
        stackView.axis = .horizontal
        stackView.spacing = 7
        return stackView
    }()
    
    //    @IBOutlet private var inputContainerView: UIView!
    //    @IBOutlet private var originTextField: UITextField!
    //    @IBOutlet private var stopTextField: UITextField!
    //    @IBOutlet private var extraStopTextField: UITextField!
    //    @IBOutlet private var calculateButton: UIButton!
    //    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    //    @IBOutlet private var keyboardAvoidingConstraint: NSLayoutConstraint!
    
    //    @IBOutlet private var suggestionLabel: UILabel!
    //    @IBOutlet private var suggestionContainerView: UIView!
    //    @IBOutlet private var suggestionContainerTopConstraint: NSLayoutConstraint!
    
    private let locationManager = CLLocationManager()
    private var currentPlace: CLPlacemark?
    private let completer = MKLocalSearchCompleter()
    
    private var editingTextField: UITextField?
    private var currentRegion: MKCoordinateRegion?
    
    private let defaultAnimationDuration: TimeInterval = 0.25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        
        suggestionContainerView.addBorder()
        inputContainerView.addBorder()
        calculateButton.stylize()
        
        beginObserving()
        configureGestures()
        configureTextFields()
        attemptLocationAccess()
        hideSuggestionView(animated: false)
        
        completer.delegate = self
    }
    
    // MARK: - Add subviews and constraints
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(inputContainerView)
        
        inputContainerView.addSubview(menuStack)
        suggestionContainerView.addSubview(suggestionStack)
        
        view.addSubview(suggestionContainerView)
        view.addSubview(calculateStack)
        
        setConstraints()
    }
    
    private func setConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -32).isActive = true
        
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        //        menuView.heightAnchor.constraint(equalToConstant: 390).isActive = true
        
        menuStack.translatesAutoresizingMaskIntoConstraints = false
        menuStack.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 24).isActive = true
        menuStack.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -24).isActive = true
        menuStack.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 16).isActive = true
        menuStack.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -16).isActive = true
        
        suggestionContainerView.translatesAutoresizingMaskIntoConstraints = false
        suggestionContainerView.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 0).isActive = true
        suggestionContainerView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 32).isActive = true
        suggestionContainerView.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -32).isActive = true
        
        suggestionContainerView.addSubview(suggestionStack)
        suggestionStack.translatesAutoresizingMaskIntoConstraints = false
        suggestionStack.topAnchor.constraint(equalTo: suggestionContainerView.topAnchor, constant: 16).isActive = true
        suggestionStack.bottomAnchor.constraint(equalTo: suggestionContainerView.bottomAnchor, constant: -16).isActive = true
        suggestionStack.leadingAnchor.constraint(equalTo: suggestionContainerView.leadingAnchor, constant: 16).isActive = true
        suggestionStack.trailingAnchor.constraint(equalTo: suggestionContainerView.trailingAnchor, constant: -16).isActive = true
        
        calculateStack.translatesAutoresizingMaskIntoConstraints = false
        calculateStack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        calculateStack.topAnchor.constraint(equalTo: suggestionContainerView.bottomAnchor, constant: 42).isActive = true
        
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
            UITapGestureRecognizer(
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
        //        suggestionContainerTopConstraint.constant = -4 // to hide the top corners
        
        UIView.animate(withDuration: defaultAnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func presentAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        present(alertController, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func textFieldDidChange(_ field: UITextField) {
        
        if field == originTextField && currentPlace != nil {
            currentPlace = nil
            field.text = ""
        }
        
        guard let query = field.contents else {
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
        
        guard
            let hitView = gestureView?.hitTest(point, with: nil),
            hitView == gestureView
        else {
            return
        }
        
        view.endEditing(true)
    }
    
    @objc private func suggestionTapped(_ gesture: UITapGestureRecognizer) {
        hideSuggestionView(animated: true)
        
        editingTextField?.text = suggestionLabel.text
        editingTextField = nil
    }
    
    @objc private func calculateButtonTapped() {
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
        ]
            .compactMap { contents in
                if let value = contents {
                    return .text(value)
                } else {
                    return nil
                }
            }
        
        guard
            let originSegment = segment,
            !stopSegments.isEmpty
        else {
            presentAlert(message: "Please select an origin and at least 1 stop.")
            activityIndicatorView.stopAnimating()
            calculateButton.isEnabled = true
            return
        }
        
        RouteBuilder.buildRoute(
            origin: originSegment,
            stops: stopSegments,
            within: currentRegion
        ) { result in
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
                
                self.presentAlert(message: errorMessage)
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
        //        keyboardAvoidingConstraint.constant = visibleHeight + 32
        
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
        
        let commonDelta: CLLocationDegrees = 25 / 111 // 1/111 = 1 latitude km
        let span = MKCoordinateSpan(latitudeDelta: commonDelta, longitudeDelta: commonDelta)
        let region = MKCoordinateRegion(center: firstLocation.coordinate, span: span)
        
        currentRegion = region
        completer.region = region
        
        CLGeocoder().reverseGeocodeLocation(firstLocation) { places, _ in
            guard
                let firstPlace = places?.first,
                self.originTextField.contents == nil
            else {
                return
            }
            
            self.currentPlace = firstPlace
            self.originTextField.text = firstPlace.abbreviation
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        /*
         print("Error requesting location: \(error.localizedDescription)")
         */
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension RouteSelectionViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        guard let firstResult = completer.results.first else { return }
        showSuggestion(firstResult.title)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error suggesting a location: \(error.localizedDescription)")
    }
}
