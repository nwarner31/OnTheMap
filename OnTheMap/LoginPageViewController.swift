//
//  LoginPageViewController.swift
//  OnTheMap
//
//  Created by Nathaniel Warner on 4/17/18.
//  Copyright © 2018 Nathaniel Warner. All rights reserved.
//

import Foundation
import UIKit

class LoginPageViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func loginWithUdacity(sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            NetworkClient().udacityLogin(userName: email, password: password) { (wasSuccessful) in
                DispatchQueue.main.async {
                    if wasSuccessful {
                        let tabView = self.storyboard?.instantiateViewController(withIdentifier: "studentLocatorTabView")
                        self.navigationController?.pushViewController(tabView!, animated: true)
                    } else {
                
                        self.errorLabel.text = "There was a problem with your login please make sure that your email and password are correct. If you are still having trouble please reset your password"
                     }
                }
            }
        }
    }
}
