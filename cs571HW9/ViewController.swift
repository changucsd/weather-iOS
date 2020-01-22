//
//  ViewController.swift
//  cs571HW9
//
//  Created by He Chang on 11/19/19.
//  Copyright © 2019 He Chang. All rights reserved.
//

import UIKit
import MapKit
import Foundation

import SwiftyJSON
import Alamofire
import SwiftSpinner
import CoreLocation

struct GeoJson {
    var lat: Float
    var lng: Float
    
    var cityName: String
    var countryName: String
    
    init() {
        lat = 0
        lng = 0
        cityName = ""
        countryName = ""
    }
    mutating func setLatLng(lat: Float, lng:Float) {
        self.lat = lat
        self.lng = lng
    }
    
    mutating func setCity(city: String) {
           self.cityName = city
    }
    
    mutating func setCountry(country: String) {
           self.countryName = country
    }
}


struct dailyData{
    let date:String!
    let icon: String!
    let sunrise: String!
    let senset: String!
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
UISearchBarDelegate,CLLocationManagerDelegate, UIScrollViewDelegate{
   
    

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    let autoUrl = "http://hechanghw9.us-east-2.elasticbeanstalk.com/auto" // auto complete link
    let currentUrl = "http://hechanghw9.us-east-2.elasticbeanstalk.com/current" // current weather link
    
    let inputUrl = "http://hechanghw9.us-east-2.elasticbeanstalk.com/searchInput" //

    
    
    var searchActive : Bool = false
    var filtered:[String] = []
 
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLoc = GeoJson()
    
    var localWeatherJson:JSON = []
    
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
    
    
    // test area
    var favJson : [JSON] = []

    var slides:[Slide] = [];
    
    var firstLoad: Bool = true
    
    var lastFavLength = 0;
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
 
        SwiftSpinner.show("Loading...")
        
        
        // store favlist object in userDefault
        if(UserDefaults.standard.object(forKey: "favList") == nil){
            print("favlist not exist and about to create one")
            let emptyDict: [String: String] = [:]
            UserDefaults.standard.set(emptyDict, forKey: "favList")
        }
        else{
            print("favlist already exists in userdefault")
            let favList: [String:String] = UserDefaults.standard.object(forKey: "favList") as! [String : String]
            print(favList.keys)
            lastFavLength = favList.count
        }
        
        /* Setup delegates */
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        scrollView.delegate = self
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
//            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//            locationManager.startUpdatingLocation()
            locationManager.requestLocation()
        }
        
        
        searchBar.placeholder = "Enter City Name..."
        let leftNavBarButton = UIBarButtonItem(customView:searchBar)
        self.navigationItem.leftBarButtonItem = leftNavBarButton
        
        self.tableView.layer.cornerRadius = 10
        
        self.tableView.isHidden = true
        
        

    }
    
    // when user navigates back to main page
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        
        if(firstLoad == false){
            print("comesback to main view")
            let favList: [String:String] = UserDefaults.standard.object(forKey: "favList") as! [String : String]
            // check if user changes faveList length
            if(lastFavLength != favList.count){

                setupSlideScrollView()

                self.pageControl.numberOfPages = favList.count + 1

                if(pageControl.currentPage > favList.count){
                    pageControl.currentPage = favList.count
                }
                else if (pageControl.currentPage < 0){
                    pageControl.currentPage = 0
                }
                lastFavLength = favList.count

            }
        }
    }
    
    /*  scroll view function group
     * default function called when view is scolled. In order to enable callback
     * when scrollview is scrolled, the below code needs to be called:
     * slideScrollView.delegate = self or
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

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
            output.append(dailyData(date: timeConverter(
                UNIX_timestamp: rows[i]["time"].stringValue),
                icon:iconDic[rows[i]["icon"].stringValue],
                sunrise:getHour(UNIX_timestamp: rows[i]["sunriseTime"].stringValue),
                senset:getHour(UNIX_timestamp: rows[i]["sunsetTime"].stringValue)))
        }
        
        
        return output
    }
    
    
    func generateSingleSlide(theweatherJson: JSON, cityName :String, location: String, slide: Slide){
        
       
        
        let currentData = theweatherJson["currently"]
        
        slide.dataPassed = getDaily(theweatherJson:theweatherJson)
        
        
        // newly added on 24
        slide.controllerPassed = self
        slide.weatherPassed = theweatherJson
        slide.placePassed = location
        slide.prevPassed = "main"
        
        // setup button for the slide
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
        slide.cardCity.text = cityName
        
        
        slide.windSpeed.text = String(format: "%.2f", Double(currentData["windSpeed"].stringValue)!) + " mph"
        slide.humidity.text = String(format: "%.1f", Double(currentData["humidity"].stringValue)! * 100.0) + " %"
        slide.visibility.text = String(format: "%.2f", Double(currentData["visibility"].stringValue)!) + " km"
        slide.pressure.text = String(format: "%.1f", Double(currentData["pressure"].stringValue)!) + " mb"
        
        slide.tableView.reloadData()

    }

    func setupSlideScrollView() {
        
        let favlistDic: [String: String] = UserDefaults.standard.object(forKey: "favList") as! [String : String]
        
        // clean subviews
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        
        // set up scrollview size
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height*0.92)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(favlistDic.count + 1), height: view.frame.height*0.92)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        
        // create a list of lists to store information:
        var slideList: [Slide] = []
        
        var weatherJsonList: [JSON] = []
        var locationList: [String] = []
        
        // build empty list of slides
        for i in 1...favlistDic.count + 1{
            
            let slide:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
            slideList.append(slide);
            slide.backgroundColor = UIColor.clear
            
            slide.frame = CGRect(x: view.frame.width * CGFloat(i-1), y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            scrollView.addSubview(slide)
        }
        
        // load the first slide of current position
        let loc = currentLoc.cityName + "," + currentLoc.countryName
        self.generateSingleSlide(theweatherJson: self.localWeatherJson, cityName: currentLoc.cityName, location: loc, slide: slideList[0])
        slideList[0].theButton.isHidden = true

        
        // if there is no favlist, only show current slide and hide spinner
        if(slideList.count == 1){
             SwiftSpinner.hide()
        }
        
        //      loop through all fav location and get and store their weatherjson
        var index = 1
        for key in favlistDic.keys {
          print("check key values in userdefault")
          print(key)

          let favlocaitonString = key
            
          locationList.append(favlocaitonString)
          
          let parameters: Parameters = ["input":favlocaitonString]
          Alamofire.request(inputUrl, method: .get, parameters: parameters).responseJSON { (responseData) -> Void in
               if((responseData.result.value) != nil) {

                  print("get fav weatherJson on " + favlocaitonString)
                    
                  weatherJsonList.append(JSON(responseData.result.value!))
                
                  index = index + 1
                  if(index >= favlistDic.count - 1){
                       
                    // if all weatherjson is got and we are ready to load into slides
                    print("all weath json is ready")
                    for k in 0...weatherJsonList.count - 1{
                        
                        let theweatherJson = weatherJsonList[k]
                        let thelocationString = locationList[k]
                        
                        let information = thelocationString.components(separatedBy: ",")
                        let thecityName = information[0];
                        
                        self.generateSingleSlide(theweatherJson: theweatherJson, cityName: thecityName,location: thelocationString, slide: slideList[k+1])
                    }
                    SwiftSpinner.hide()
                  }
                   
                  

               }
          }
        }

    }

    //MARK: UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
//        print(pageNumber)

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    // location function group
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
               
              print("Found user's location: \(location)")
             
              let location:CLLocationCoordinate2D = manager.location!.coordinate
                    currentLoc.setLatLng(lat: Float(location.latitude), lng: Float(location.longitude))
                    print("currentloc= \(currentLoc.lat), \(currentLoc.lng)")
                    
                    let geocoder = CLGeocoder()
                    geocoder.reverseGeocodeLocation(manager.location!) { (placemarks, error) in
                          // Process Response
                          if let error = error {
                              print("Unable to Reverse Geocode Location (\(error))")
                          } else {
                              if let placemarks = placemarks, let placemark = placemarks.first {

                                self.currentLoc.setCity(city:placemark.locality!)
                                self.currentLoc.setCountry(country: placemark.country!)
                                print(self.currentLoc.cityName)
                                print(self.currentLoc.countryName)
                              }
                          }
                      }
                    
                    let parameters: Parameters = ["localLat":currentLoc.lat, "localLon":currentLoc.lng]
                    Alamofire.request(currentUrl, method: .get, parameters: parameters).responseJSON { (responseData) -> Void in
                        if((responseData.result.value) != nil) {
                            self.localWeatherJson = JSON(responseData.result.value!)
                            print("get local weatherJson")

                            self.setupSlideScrollView()
                            
                            let favlistDic: [String: String] = UserDefaults.standard.object(forKey: "favList") as! [String : String]
                            self.pageControl.numberOfPages = favlistDic.keys.count + 1
            //                self.pageControl.numberOfPages = self.slides.count
                            self.pageControl.currentPage = 0
                            self.view.bringSubviewToFront(self.pageControl)
                            
                            self.firstLoad = false
                            
                        }
                    }
            
        }
        
      
    }


    
    
    
    
    // search bar function group
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        self.tableView.isHidden = true
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        self.tableView.isHidden = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        let parameters: Parameters = ["input": searchText.lowercased()]
        Alamofire.request(autoUrl, method: .get, parameters: parameters).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
//                let swiftyJsonVar = JSON(responseData.result.value!)
                print("get auto complete")
//                print(swiftyJsonVar)
                self.filtered = responseData.result.value! as! [String]
                
                if(self.filtered.count == 0 || searchText ==  ""){
                    self.searchActive = false;
                    self.tableView.isHidden = true
                } else {
                    self.searchActive = true;
                    self.tableView.isHidden = false
                }
                self.tableView.reloadData()
                
            }
        }
   }

   override func didReceiveMemoryWarning() {
       super.didReceiveMemoryWarning()
       // Dispose of any resources that can be recreated.
   }
    
    
    
    // table function group
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }
        return 0;
    }

       
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
       if(searchActive){
           cell.textLabel?.text = filtered[indexPath.row]
       } else {
           cell.textLabel?.text = "";
       }

       return cell;
        
    }
    
    // cancell the slected state after being selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath){
//        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "showSearchResult", sender: self)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"Weather", style: .plain, target: nil, action: nil)
        
        self.tableView.isHidden = true
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender:Any? ){
        if let destination = segue.destination as? searchResultVC{
            
            // send cityname, state, country string to searchResultView controller
            destination.searchlocation = self.filtered[(self.tableView.indexPathForSelectedRow?.row)!]
        }
    }
    
 


}
