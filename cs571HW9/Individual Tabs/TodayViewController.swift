//
//  TodayViewController.swift
//  cs571HW9
//
//  Created by He Chang on 11/24/19.
//  Copyright © 2019 He Chang. All rights reserved.
//

import UIKit
import SwiftyJSON

class TodayViewController: UIViewController {

    @IBOutlet weak var summary: UIImageView!
    @IBOutlet weak var summaryWord: UILabel!
    
    
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var precipitation: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var visibility: UILabel!
    @IBOutlet weak var cloudCover: UILabel!
    @IBOutlet weak var ozone: UILabel!
    
    
    @IBOutlet weak var cell1: UITextView!
    @IBOutlet weak var cell2: UITextView!
    @IBOutlet weak var cell3: UITextView!
    @IBOutlet weak var cell4: UITextView!
    @IBOutlet weak var cell5: UITextView!
    @IBOutlet weak var cell6: UITextView!
    @IBOutlet weak var cell7: UITextView!
    @IBOutlet weak var cell8: UITextView!
    @IBOutlet weak var cell9: UITextView!
    
    
    let iconDic = ["clear-day": "weather-sunny",
              
              "clear-night": "weather-night",
              
              "rain": "weather-rainy",
              
              "snow" : "weather-snowy",
              
              "sleet" : "weather-snowy-rainy",
              
              "wind" : "weather-windy-variant",
              
              "fog" : "weather-fog",
              
              "cloudy" : "weather-cloudy",
              
              "partly-cloudy-night" : "weather-night-partly-cloudy",
              
              "partly-cloudy-day" : "weather-partly-cloudy"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabbar = tabBarController as! tabViewController
        let currentData = tabbar.weatherJson["currently"]
        
        
        
        print("load today tab view")
        
        let key = currentData["icon"].stringValue
        let imageName = iconDic[key];
        
        summary.image = UIImage(named: imageName!)
        summaryWord.text = currentData["summary"].stringValue

           
        windSpeed.text = String(format: "%.2f", Double(currentData["windSpeed"].stringValue)!) + " mph"
        pressure.text = String(format: "%.1f", Double(currentData["pressure"].stringValue)!) + " mb"
        temperature.text = String(Int(round(Double(currentData["temperature"].stringValue)!))) + "°F"
        humidity.text = String(format: "%.1f", Double(currentData["humidity"].stringValue)! * 100.0) + " %"
        visibility.text = String(format: "%.2f", Double(currentData["visibility"].stringValue)!) + " km"
//        cloudCover.text = String(format: "%.2f", Double(currentData["cloudCover"].stringValue)!) + " %"
        cloudCover.text = String(format: "%.1f", Double(currentData["cloudCover"].stringValue)! * 100.0) + " %"
        ozone.text = String(format: "%.1f", Double(currentData["ozone"].stringValue)!) + " DU"
        precipitation.text = String(format: "%.1f", Double(currentData["precipIntensity"].stringValue)!) + " mmph"
        
        
        
        // stupid method to draw view
        cell1.layer.cornerRadius = 20
        cell1.layer.borderColor = UIColor.white.cgColor
        cell1.layer.borderWidth = 0.7;
        cell1.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        
        cell2.layer.cornerRadius = 20
        cell2.layer.borderColor = UIColor.white.cgColor
        cell2.layer.borderWidth = 0.7;
        cell2.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        
        cell3.layer.cornerRadius = 20
        cell3.layer.borderColor = UIColor.white.cgColor
        cell3.layer.borderWidth = 0.7;
        cell3.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        
        cell4.layer.cornerRadius = 20
        cell4.layer.borderColor = UIColor.white.cgColor
        cell4.layer.borderWidth = 0.7;
        cell4.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        
        cell5.layer.cornerRadius = 20
        cell5.layer.borderColor = UIColor.white.cgColor
        cell5.layer.borderWidth = 0.7;
        cell5.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        
        cell6.layer.cornerRadius = 20
        cell6.layer.borderColor = UIColor.white.cgColor
        cell6.layer.borderWidth = 0.7;
        cell6.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        
        cell7.layer.cornerRadius = 20
        cell7.layer.borderColor = UIColor.white.cgColor
        cell7.layer.borderWidth = 0.7;
        cell7.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        
        cell8.layer.cornerRadius = 20
        cell8.layer.borderColor = UIColor.white.cgColor
        cell8.layer.borderWidth = 0.7;
        cell8.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
    
        cell9.layer.cornerRadius = 20
        cell9.layer.borderColor = UIColor.white.cgColor
        cell9.layer.borderWidth = 0.7;
        cell9.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        
        
        
        
        
        
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
