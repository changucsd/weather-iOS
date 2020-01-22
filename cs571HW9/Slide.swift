//
//  Slide.swift
//  cs571HW9
//
//  Created by He Chang on 11/21/19.
//  Copyright © 2019 He Chang. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toast_Swift

//struct dailyData{
//    let data:String!
//    let icon: String!
//    let sunrise: String!
//    let senset: String!
//}


class Slide: UIView, UITableViewDataSource, UITableViewDelegate  {
    
   
    @IBOutlet weak var imageView: UIImageView!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
//    @IBOutlet weak var weatherCard: UITextView!
    
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var cardSummary: UITextView!
    @IBOutlet weak var cardTemp: UITextView!
    @IBOutlet weak var cardCity: UITextView!
    
//    @IBOutlet weak var cardTemp: UILabel!
//    @IBOutlet weak var cardCity: UILabel!
//    
    @IBOutlet weak var windSpeed: UITextView!
    @IBOutlet weak var humidity: UITextView!
    @IBOutlet weak var visibility: UITextView!
    @IBOutlet weak var pressure: UITextView!
    
//    @IBOutlet weak var forecastTable: UITableView!
    
    @IBOutlet weak var tableCell: UITableViewCell!
    
    
//    @IBOutlet weak var favButton: UIImageView!
    
    
    var dailyWeather: [dailyData] = []
    var viewController: UIViewController! // the main view controller passed from main
    var jsonData: JSON!  // used to pass to tabview storyboard
    
    var placeString: String! // used to pass to tabview photo parts
    var prevView: String! // used to see where the xib lives
    
    var dataPassed: [dailyData]! {
          didSet {
               dailyWeather = dataPassed
          }
    }
    
    var controllerPassed:UIViewController!{
        didSet {
            viewController = controllerPassed
        }
    }
    
    var weatherPassed: JSON!{
        didSet {
             jsonData = weatherPassed
        }
    }
    
    var placePassed: String!{
          didSet {
               placeString = placePassed
          }
      }
    
    var prevPassed: String!{
         didSet {
              prevView = prevPassed
         }
    }
    
    var tableView = UITableView()
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    
    
    // for test
    var newWeatherCard = UITextView()
    var theButton = UIImageView()
    
    var twitterCity:String?
    var twitterTemp:String?
    var twitterSummary:String?
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      print("i am in override")
      setupView()
        
      tableView.delegate = self
      tableView.dataSource = self

    }
    
    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      print("i am required")
      setupView()
        
      tableView.delegate = self
      tableView.dataSource = self
//      tableView.reloadData()

    }
    
    //common func to init our view
    private func setupView() {
        print("ready to setupView for a slide in xib:")


        tableView = UITableView(frame: CGRect(x: 20, y: 530, width: screenWidth*0.9, height: screenHeight * 0.3))
        tableView.backgroundColor = UIColor.white.withAlphaComponent(0.7)

        tableView.layer.cornerRadius = 20
        tableView.register(UINib(nibName: "TableViewCell1", bundle: nil), forCellReuseIdentifier: "theCell")
        self.addSubview(tableView)
        
        
        newWeatherCard = UITextView(frame: CGRect(x: 20, y: 160, width: screenWidth*0.9, height: screenHeight * 0.20))
        
        newWeatherCard.layer.cornerRadius = 20
        newWeatherCard.layer.borderColor = UIColor.white.cgColor
        newWeatherCard.layer.borderWidth = 0.7;
        newWeatherCard.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        
        // add tap gesture to newWeatherCard
        newWeatherCard.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target:self, action: #selector(self.tapGesture))
        newWeatherCard.addGestureRecognizer(tapGesture)
        
        // add tap gesture to fav button
        theButton = UIImageView(frame: CGRect(x: 355, y: 108, width: 40, height: 40))
        theButton.isUserInteractionEnabled = true
        let tapGesture2 = UITapGestureRecognizer(target:self, action: #selector(self.tapGesture2))
        theButton.addGestureRecognizer(tapGesture2)
        
//         theButton.image =  UIImage(named: "plus-circle")
//        if(placeString != nil){
//            print("check for placeString")
//        }
//        let check = defaults.string(forKey: placeString)
//        
//        if (check != nil) {
//            // this place is in fave list already
//            theButton.image =  UIImage(named: "trash-can")
//        }
//        else{
//            // this place is not in fav list
//            theButton.image =  UIImage(named: "plus-circle")
//        }
//        if (defaults.string(forKey: placeString) != nil){
//
//            // this place is in fave list already
//            theButton.image =  UIImage(named: "trash-can")
//
//        }
//        else{
//            // this place is not in fav list
//            theButton.image =  UIImage(named: "plus-circle")
//        }
  
        self.addSubview(newWeatherCard)
        self.addSubview(theButton)
    }
    

    
    @objc func tapGesture2(){
        
        var favlistDic: [String: String] = UserDefaults.standard.object(forKey: "favList") as! [String : String]
        let check = favlistDic[placeString]

        if (check == nil){

            // this place is not in fav list and user wants to add it
            theButton.image =  UIImage(named: "trash-can")
            
            favlistDic[placeString] = placeString
            UserDefaults.standard.set(favlistDic, forKey: "favList")
            viewController.view.makeToast(cardCity.text + " was added to the Favorite List")
        }
        else{
            // this place is in fave list already and user wants to remove it
            
            theButton.image =  UIImage(named: "plus-circle")
            favlistDic.removeValue(forKey: placeString)
            UserDefaults.standard.set(favlistDic, forKey: "favList")
            viewController.view.makeToast(cardCity.text + " was removed from the Favorite List")
            
            print(prevView)
            // for the xibs on main screen, we need to refresh mian page
            if(prevView == "main"){
                
               // cast the viewController passed to be our viewcontroller type
               let mianViewController = viewController as! ViewController
              
               mianViewController.setupSlideScrollView()

               mianViewController.pageControl.numberOfPages = favlistDic.count + 1

                if(mianViewController.pageControl.currentPage > favlistDic.count){
                           mianViewController.pageControl.currentPage = favlistDic.count
                }
                else if (mianViewController.pageControl.currentPage < 0){
                    mianViewController.pageControl.currentPage = 0
                }
               mianViewController.lastFavLength = favlistDic.count
            }
        }
        
       
//        viewController.viewWillAppear(true)
//        viewController.setupSlideScrollView()
//
//        viewController.pageControl.numberOfPages = favlistDic.count + 1
//
//        if(pageControl.currentPage > favList.count){
//                          pageControl.currentPage = favList.count
//        }
//        else if (pageControl.currentPage < 0){
//          pageControl.currentPage = 0
//      }
//      lastFavLength = favList.count

    }
    
    @objc func tapGesture(){
        
        print("tapped here")
        
        let storyboard = UIStoryboard(name: "Tabview", bundle: nil)
        let newTabViewController = storyboard.instantiateViewController(withIdentifier: "tabViewControllerID") as! tabViewController
       
        // pass json for tabviews to populate tab views
        newTabViewController.weatherPassed = self.jsonData
        newTabViewController.locPassed = self.placePassed  // pass for phote view
        
        // bug fix on 12/1 if we see detail from a search result, back button should be city name
        var backName = cardCity.text
        if(prevView == "main"){
            backName = "Weather"
        }
        viewController!.navigationItem.backBarButtonItem = UIBarButtonItem(title: backName, style: .plain, target: nil, action: nil)
        
        // set nav bar title for tab views
        newTabViewController.navigationItem.title = cardCity.text
        
        let button = UIButton(type: .custom)
        let origImage = UIImage(named: "twitter")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = UIColor(red: 29.0/255.0, green: 161.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        //add function for button
        button.addTarget(self, action: #selector(twitterButtonPressed), for: .touchUpInside)
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 63, height: 63)

        button.transform = CGAffineTransform(translationX: 30, y: 0)

        let barButton = UIBarButtonItem(customView: button)
        newTabViewController.navigationItem.rightBarButtonItem = barButton
        
        viewController!.navigationController?.pushViewController(newTabViewController, animated: true)
        
    }
    
    //This method will call when you press button.
    @objc func twitterButtonPressed() {

        print("Share to tiwtter")
        print("daily weather for" + cardCity.text)
        print(dailyWeather)
        twitterCity = cardCity.text
        twitterTemp = cardTemp.text
        twitterSummary = cardSummary.text
        
        var twitterUrl: String =
            "https://twitter.com/intent/tweet?text=The current temperature at " + self.twitterCity! + " is " + self.twitterTemp!
        twitterUrl = twitterUrl + ". The weather conditions are " + self.twitterSummary! + ".&hashtags=CSCI571WeatherSearch"
        let escapedShareString = twitterUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        let url = URL(string: escapedShareString)
        UIApplication.shared.open(url!)
    }

    
    // table controling methods

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        print("detect table sections for" + cardCity.text)
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("detect table rows for" + cardCity.text)
        return dailyWeather.count
    }
    
    //reload table data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "theCell", for: indexPath) as! TableViewCell1
        
        
//       setup cell information
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        cell.date.text = dailyWeather[indexPath.row].date
        cell.icon.image = UIImage(named: dailyWeather[indexPath.row].icon)
        cell.sunrise.text = dailyWeather[indexPath.row].sunrise
        cell.sunset.text = dailyWeather[indexPath.row].senset
        
        return cell;
     }
    
    
}
