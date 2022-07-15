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
    @IBOutlet private var extraTextField: UITextField!
    
    @IBOutlet private var calculateButton: UIButton!
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var keyboardAvoidingConstraints: NSLayoutConstraint!
    
    @IBOutlet private var suggestionLabel: UILabel!
    @IBOutlet private var suggestionContainerView: UIView!
    @IBOutlet private var suggestionContainerTopConstraint: NSLayoutConstraint!
    
    private let defaultAnimationDuration: TimeInterval = 0.25
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        suggestionContainerView.addBorder()
        inputContainerView.addBorder()
        calculateButton.stylize()
        
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
        extraTextField.delegate = self
        
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
        
        extraTextField.addTarget(
            self,
            action: #selector(textFieldDidChange),
            for: .editingChanged
        )
    }
    
    private func attemptLocationAccess() {
        
    }
    
    private func hideSuggestionView(animated: Bool) {
        suggestionContainerTopConstraint.constant = -1 * (suggestionContainerView.bounds.height + 1)
        
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
        suggestionContainerTopConstraint.constant = -4 // to hide the top conrners
        
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
        
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let gestureView = gesture.view
        let point = gesture.location(in: gestureView)
        
        guard let hitView = gestureView?.hitTest(point, with: nil), hitView == gestureView else { return }
        
        view.endEditing(true)
    }
    
    @objc private func suggestionTapped(_ gesture: UITapGestureRecognizer) {
        
    }
    
    // TODO: - !!!!
    
    @IBAction private func calculateButtonTapped() {
        
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
        keyboardAvoidingConstraints.constant = visibleHeight + 32
        
        UIView.animate(withDuration: defaultAnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITextFieldDelegate

extension RouteSelectionViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
}

// MARK: - CLLocationManagerDelegate

extension RouteSelectionViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error requesting location: \(error.localizedDescription)")
    }
}

