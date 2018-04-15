//
//  ViewController.swift
//  OnTheMap
//
//  Created by Nathaniel Warner on 4/14/18.
//  Copyright © 2018 Nathaniel Warner. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //NetworkConnector().getRequest(urlString: "https://parse.udacity.com/parse/classes/StudentLocation")
        NetworkClient().getStudents()
        //var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

