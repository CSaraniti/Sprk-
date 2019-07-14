//
//  DestinationDetailsViewController.swift
//  Sprk+
//
//  Created by Carlo Saraniti, Hanu Snyder, and Yifei Yao on 7/12/19.
//  Copyright © 2019 Carlo Saraniti. All rights reserved.
//

import UIKit
import MapKit

class DestinationDetailsViewController: UIViewController {
    
    var infoDictionary = [String: Any]()    //  collection of info of a location
    var mapItem = MKMapItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for (category, value) in infoDictionary {
            print (category, ": ", value)   //  have fun using it in storyboard
        }
        print ("")
    }
}

