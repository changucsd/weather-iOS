//
//  WeeklyViewController.swift
//  cs571HW9
//
//  Created by He Chang on 11/24/19.
//  Copyright © 2019 He Chang. All rights reserved.
//

import UIKit
import SwiftyJSON
import Charts



class WeeklyViewController: UIViewController {
    
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
    
    @IBOutlet weak var card: UITextView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var summary: UITextView!
    @IBOutlet weak var myLineChart: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let tabbar = tabBarController as! tabViewController
        let weeklyData = tabbar.weatherJson["daily"]

        print("load weekly tab view")

        let key = weeklyData["icon"].stringValue
        let imageName = iconDic[key];

        icon.image = UIImage(named: imageName!)
        summary.text = weeklyData["summary"].stringValue
        
        card.layer.cornerRadius = 20
        card.layer.borderColor = UIColor.white.cgColor
        card.layer.borderWidth = 0.7;
        card.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        
        
        myLineChart.layer.borderColor = UIColor.white.cgColor
        myLineChart.layer.borderWidth = 0.7;
        myLineChart.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        
        var lineChartEntryHigh = [ChartDataEntry]()
        var lineChartEntryLow = [ChartDataEntry]()
        
        let rows = weeklyData["data"]
        
        for i in 0...rows.count-1{
            
            var value = ChartDataEntry(x:Double(i),y:Double(String(format: "%.1f", Double(rows[i]["temperatureHigh"].stringValue)!))!.rounded())
            lineChartEntryHigh.append(value)
            
            value = ChartDataEntry(x:Double(i),y:Double(String(format: "%.1f", Double(rows[i]["temperatureLow"].stringValue)!))!.rounded())
            lineChartEntryLow.append(value)
            
        }
        
        let line1 = LineChartDataSet(entries: lineChartEntryHigh, label: "Maximum Temperature (°F)")
        line1.colors = [NSUIColor.orange]
        line1.circleColors = [NSUIColor.orange]
        line1.circleRadius = 5.0;
        line1.circleHoleRadius  = 0;
      
        let line2 = LineChartDataSet(entries: lineChartEntryLow, label: "Minimum Temperature (°F)")
        line2.colors = [NSUIColor.white]
        line2.circleColors = [NSUIColor.white]
        line2.circleRadius = 5.0;
        line2.circleHoleRadius  = 0;
      
        
        let data = LineChartData()
        data.addDataSet(line2)
        data.addDataSet(line1)
        myLineChart.data = data

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
