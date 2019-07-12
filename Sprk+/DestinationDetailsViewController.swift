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
    
    var selectedMapItem = MKMapItem()
    override func viewDidLoad() {
        super.viewDidLoad()
        var address = selectedMapItem.placemark.subThoroughfare! + " "
        address += selectedMapItem.placemark.thoroughfare! + "\n"
        address += selectedMapItem.placemark.locality! + ", "
        address += selectedMapItem.placemark.administrativeArea! + " "
        address += selectedMapItem.placemark.postalCode!
    }
}
