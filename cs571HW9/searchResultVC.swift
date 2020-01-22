//
//  searchResultVC.swift
//  cs571HW9
//
//  Created by He Chang on 11/22/19.
//  Copyright © 2019 He Chang. All rights reserved.
//

import UIKit
import MapKit
import Foundation

import SwiftyJSON
import Alamofire
import SwiftSpinner
import CoreLocation

//struct dailyData{
//    let data:String!
//    let icon: String!
//    let sunrise: String!
//    let senset: String!
//}


class searchResultVC: UIViewController {
    
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
     
//    @IBOutlet weak var testText: UILabel?
    
    let inputUrl = "http://hechanghw9.us-east-2.elasticbeanstalk.com/searchInput"
    
    var searchlocation:String?
//    var weatherJson:JSON?
    var twitterCity:String?
    var twitterTemp:String?
    var twitterSummary:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        testText?.text = searchlocation
        SwiftSpinner.show("Fetching Weather Details for " + searchlocation! + "...")
        // setup title for the search result
        let result: [String] = searchlocation!.components(separatedBy: ",")
        self.navigationItem.title = result[0]
        
        let button = UIButton(type: .custom)
        let origImage = UIImage(named: "twitter")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = UIColor(red: 29.0/255.0, green: 161.0/255.0, blue: 242.0/255.0, alpha: 1.0)
       //add function for button
        button.addTarget(self, action: #selector(twitterButtonPressed), for: .touchUpInside)
       //set frame
        button.frame = CGRect(x: 0, y: 0, width: 57, height: 57)
        button.titleEdgeInsets.left = 20
//        button.transform = CGAffineTransform(translationX: 30, y: 0)

        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton

        
        let parameters: Parameters = ["input":searchlocation!]
        Alamofire.request(inputUrl, method: .get, parameters: parameters).responseJSON { (responseData) -> Void in
             if((responseData.result.value) != nil) {
                     
                print("get input weatherJson and start to build view on " + self.searchlocation!)
                
                let information = self.searchlocation?.components(separatedBy: ",")
                
                let cityName = information![0];
                self.twitterCity = cityName
//                let json = JSON(responseData.result.value!)
//                let current = json["currently"]
//
//                self.twitterSummary = current["summary"].stringValue
//                self.twitterTemp = String(Int(round(Double(current["temperature"].stringValue)!))) + "°F"
                
                let slide:Slide = self.generateSingleSlide(theweatherJson: JSON(responseData.result.value!), cityName: cityName,location: self.searchlocation!)
                slide.backgroundColor = UIColor.clear
                self.view.addSubview(slide)
                
                SwiftSpinner.hide()
             }
         }
    
        

        // Do any additional setup after loading the view.
    }
    
    //This method will call when you press button.
     @objc func twitterButtonPressed() {

        print("Share to tiwtter!!!")
        
        var twitterUrl: String =
            "https://twitter.com/intent/tweet?text=The current temperature at " + self.twitterCity! + " is " + self.twitterTemp!
        twitterUrl = twitterUrl + ". The weather conditions are " + self.twitterSummary! + ".&hashtags=CSCI571WeatherSearch"
//        print(twitterUrl)
        // encode a space to %20 for example
        let escapedShareString = twitterUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        let url = URL(string: escapedShareString)
        UIApplication.shared.open(url!)
         
     }
    
    func getHour(UNIX_timestamp: String) -> String{
        
      let date = Date(timeIntervalSince1970: Double(UNIX_timestamp)!)
      let dateFormatter = DateFormatter()
      dateFormatter.timeZone = TimeZone(abbreviation: "PST") //Set timezone that you want
      dateFormatter.locale = Locale(identifier: "en_US")
      dateFormatter.dateFormat = "HH:mm" //Specify your format that you want
      let strDate = dateFormatter.string(from: date)
      return strDate
    }

    func timeConverter(UNIX_timestamp:String) -> String{

        let date = Date(timeIntervalSince1970: Double(UNIX_timestamp)!)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "PST") //Set timezone that you want
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MM/dd/yyyy" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        return strDate
    }

    func getDaily(theweatherJson: JSON) -> [dailyData]{
        
        var output: [dailyData] = []
        
        var rows = theweatherJson["daily"]
        rows = rows["data"]
    //        var timeZone = theweatherJson["timezone"]
        
        for i in 0...rows.count-1 {
            output.append(dailyData(date: timeConverter(UNIX_timestamp: rows[i]["time"].stringValue),
                                    icon:iconDic[rows[i]["icon"].stringValue],
                                    sunrise:getHour(UNIX_timestamp: rows[i]["sunriseTime"].stringValue),
                                    senset:getHour(UNIX_timestamp: rows[i]["sunsetTime"].stringValue)))
        }
        
        
        return output
    }
    func generateSingleSlide(theweatherJson: JSON, cityName :String, location: String) -> Slide{
            
        
        let currentData = theweatherJson["currently"]
        
        let slide:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide

        slide.dataPassed = getDaily(theweatherJson:theweatherJson)
        
        // newly added on 24
        slide.controllerPassed = self
        slide.weatherPassed = theweatherJson
        slide.placePassed = location // needs to be city + country for google search engine
        slide.prevPassed = "search"
        
        // set up button for slide
        let favlistDic: [String: String] = UserDefaults.standard.object(forKey: "favList") as! [String : String]
        let check = favlistDic[location]
              
        if (check != nil) {
          // this place is in fav list already
          slide.theButton.image =  UIImage(named: "trash-can")
        }
        else{
          // this place is not in fav list
          slide.theButton.image =  UIImage(named: "plus-circle")
        }
        
        let key = currentData["icon"].stringValue
        let imageName = iconDic[key];
        
        slide.cardImage.image = UIImage(named: imageName!)
        slide.cardSummary.text = currentData["summary"].stringValue
        slide.cardTemp.text = String(Int(round(Double(currentData["temperature"].stringValue)!))) + "°F"
//        slide.cardTemp.font = .systemFont(ofSize: 20)
        slide.cardCity.text = cityName
        
        self.twitterSummary = currentData["summary"].stringValue
        self.twitterTemp = String(Int(round(Double(currentData["temperature"].stringValue)!))) + "°F"
        
        slide.windSpeed.text = String(format: "%.2f", Double(currentData["windSpeed"].stringValue)!) + " mph"
        slide.humidity.text = String(format: "%.1f", Double(currentData["humidity"].stringValue)! * 100.0) + " %"
        slide.visibility.text = String(format: "%.2f", Double(currentData["visibility"].stringValue)!) + " km"
        slide.pressure.text = String(format: "%.1f", Double(currentData["pressure"].stringValue)!) + " mb"
        
        return slide
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
