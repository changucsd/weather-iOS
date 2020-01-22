//
//  PhotoViewController.swift
//  cs571HW9
//
//  Created by He Chang on 11/24/19.
//  Copyright © 2019 He Chang. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SwiftSpinner

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    let  searchUrl = "http://hechanghw9.us-east-2.elasticbeanstalk.com/searchPicture"
    var imageArrayLink = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftSpinner.show("Fetching Google Images...")
        
        let tabbar = tabBarController as! tabViewController
        let searchString = tabbar.locPassed // used to search for picture
        
        
       
        let imageViewHeight:CGFloat = 500.0
      
        
        var newY:CGFloat = 0
        
        let parameters: Parameters = ["place": searchString!]
        Alamofire.request(searchUrl, method: .get, parameters: parameters).responseJSON { (responseData) -> Void in
                if((responseData.result.value) != nil) {
                    
                    print("get picture JSON")
                    let picJson = JSON(responseData.result.value!)

                    let items = picJson["items"];
                    
                    self.mainScrollView.contentSize = CGSize(width: self.mainScrollView.frame.size.width, height: imageViewHeight*(CGFloat)(items.count))
                    
                    for i in 0...items.count-1 {
                        let imageUrl = items[i]["link"].stringValue
                        // print(imageUrl)
                        let imageView = UIImageView()
                        
                        let url = URL(string: imageUrl)
                        let data = try? Data(contentsOf: url!)

                        if let imageData = data {
                            imageView.image = UIImage(data: imageData)
                        }
                        
                        imageView.frame = CGRect(x: 0, y: newY, width: self.mainScrollView.frame.size.width, height: imageViewHeight)
                        newY = newY + CGFloat(imageViewHeight)
                        self.mainScrollView.addSubview(imageView)
                    }
                    
                    SwiftSpinner.hide()
                    
                }
        }
//        print(searchString!)
        
        
        

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
