//
//  tabViewController.swift
//  cs571HW9
//
//  Created by He Chang on 11/24/19.
//  Copyright © 2019 He Chang. All rights reserved.
//

import UIKit
import SwiftyJSON


class tabViewController: UITabBarController {
    
    var weatherJson: JSON! // for today and weekly
    var searchLocation: String! // for phote view
    
    var weatherPassed: JSON!{
           didSet {
               weatherJson = weatherPassed
           }
    }
    
    var locPassed: String!{
           didSet {
               searchLocation = locPassed
           }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var currentJson = weatherJson["currently"]
        
//        print(weatherJson["currently"])
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
