//
//  RouteSelectionViewController.swift
//  RoutingWithMapKitAndCoreLocation
//
//  Created by Aleksandr Rybachev on 28.06.2022.
//

import UIKit

class RouteSelectionViewController: UIViewController {
    
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var stopTextField: UITextField!
    @IBOutlet weak var extraTextField: UITextField!
    
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var suggestionContainerView: UIView!
    @IBOutlet weak var suggestionLabel: UILabel!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextFields()
    }

    private func configureTextFields() {
        originTextField.delegate = self
        stopTextField.delegate = self
        extraTextField.delegate = self
    }

}

// MARK: - UITextFieldDelegate

extension RouteSelectionViewController: UITextFieldDelegate {
    
}

