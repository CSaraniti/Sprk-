//
//  DestinationDetailsViewController.swift
//  Sprk+
//
//  Created by Carlo Saraniti, Hanu Snyder, and Yifei Yao on 7/12/19.
//  Copyright © 2019 Carlo Saraniti, Hanu Snyder, and Yifei Yao. All rights reserved.
//

import UIKit
import MapKit
import SafariServices

class DestinationDetailsViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!

    var infoDictionary = [String: Any]()    //  collection of info of a location
    var mapItem = MKMapItem()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for (category, value) in infoDictionary {
            print (category, ": ", value)   //  have fun using it in storyboard
        }
        print ("")
        print(infoDictionary["address"])
    }

    override func viewWillAppear(_ animated: Bool) {
        nameLabel.text = infoDictionary["name"] as? String
        addressLabel.text = infoDictionary["address"] as? String
        phoneNumberLabel.text = infoDictionary["phoneNumber"] as? String
    }
    
    @IBAction func onDirectionsButtonTapped(_ sender: Any) {
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        MKMapItem.openMaps(with: [mapItem], launchOptions: launchOptions)
    }
    @IBAction func onWebsiteButtonTapped(_ sender: Any) {
        if let url = mapItem.url {
            present(SFSafariViewController(url: url), animated: true)
        }
    }
}
