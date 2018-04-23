//
//  LoginPageViewController.swift
//  OnTheMap
//
//  Created by Nathaniel Warner on 4/17/18.
//  Copyright © 2018 Nathaniel Warner. All rights reserved.
//

import Foundation
import UIKit

class LoginPageViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    @IBAction func loginWithUdacity(sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            NetworkClient().udacityLogin(userName: email, password: password) { (wasSuccessful) in
                DispatchQueue.main.async {
                    if wasSuccessful == "successful" {
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                        let tabView = self.storyboard?.instantiateViewController(withIdentifier: "studentLocatorTabView")
                        self.navigationController?.pushViewController(tabView!, animated: true)
                    } else {
                        self.errorLabel.text = wasSuccessful
                     }
                }
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
