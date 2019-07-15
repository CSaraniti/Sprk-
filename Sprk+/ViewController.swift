//
//  ViewController.swift
//  Sprk+
//
//  Created by Carlo Saraniti, Hanu Snyder, and Yifei Yao on 7/12/19.
//  Copyright © 2019 Carlo Saraniti, Hanu Snyder, and Yifei Yao. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CDYelpFusionKit  //import Yelp API Client
import Foundation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    // some comments
    
    @IBOutlet weak var mapView: MKMapView!
    var region = MKCoordinateRegion()
    let locationManager = CLLocationManager()
    var selectedMapItem = MKMapItem()
    var input = String()
    var yelpAPIClient = CDYelpAPIClient(apiKey: "Eyyj7cp9X622nkhFQvhJiJRP_h26M-JANYmm87SIWYsr-uKJG8hDxsxGKksxTE3s0GZW209md3OhFQ372NbV4ERuq-C1THUSys_9TipBBLERLWybn59t2Ggt00UqXXYx")
    var keyWord = ""
    var mapInfo = [MKMapItem: [String: Any]]()   // to store properties of mapItem, dictionaries in a dictionary. [MapItem: [category: value]]
    var location = CLLocation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        mapView.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first!
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
        region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        
        
        keyWord = input   //entry for searching with keywords. Work for both name and some categories. "restaurant", "pizza", "breakfast", "mcdonald", etc.
        
        
        // search using Yelp API
        yelpAPIClient.searchBusinesses(byTerm: keyWord, location: nil, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, radius: nil, categories: nil, locale: nil, limit: nil, offset: nil, sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil, attributes: nil) { (response) in
            if let response = response,
                let businesses = response.businesses,
                businesses.count > 0 {
                for item in businesses{
                    let latitude = item.coordinates?.latitude
                    let longitude = item.coordinates?.longitude
                    let coordinate = CLLocationCoordinate2D (latitude: latitude!, longitude: longitude!)
                    let mPlacemark = MKPlacemark(coordinate: coordinate)
                    let mapItem = MKMapItem(placemark: mPlacemark)
                    let annotation2 = MKPointAnnotation()
                    annotation2.coordinate = mapItem.placemark.coordinate
                    annotation2.title = item.name!
                    self.mapView.addAnnotation(annotation2)
                    var infoDictionary = [String: Any]()
                    infoDictionary["coordinate"] = annotation2.coordinate
                    infoDictionary["name"] = item.name
                    infoDictionary["phoneNumber"] = item.phone
                    infoDictionary["rating"] = item.rating
                    infoDictionary["id"] = item.id
                    infoDictionary["url"] = item.url
                    infoDictionary["address"] = ("\(String(describing: item.location?.addressOne))), \(String(describing: item.location?.city)), \(String(describing: item.location?.state))  \(String(describing: item.location?.zipCode))")
                    infoDictionary["image_url"] = item.imageUrl
                    infoDictionary["isClosed"] = item.isClosed
                    infoDictionary["distance"] = item.distance
                    infoDictionary["category"] = item.categories
                    infoDictionary["isFromYelp"] = true
                    self.mapInfo[mapItem] = infoDictionary
                }
            }
        }
        

        // search using Apple Map
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = keyWord
        request.region = region
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let response = response {
                for mapItem in response.mapItems {
                    let coordinate = mapItem.placemark.coordinate
                    var isIdentical = false
                    // algorithm to filter out duplicated results of Apple Map and Yelp
                    for value in self.mapInfo.values {
                        if value["isFromYelp"] as! Bool == true {
                            if (value["name"] as! String).prefix(5).lowercased() == mapItem.name?.prefix(5).lowercased() {
                                if self.calcDistance(coordinate0: value["coordinate"] as! CLLocationCoordinate2D, coordinate1: coordinate) < 1000.0 {   // 30.0 is enough for most cases.
                                    isIdentical = true
                                    print (value["name"]!)
                                    print (mapItem.name!)
                                }
                            }
                        }
                    }
                    if isIdentical == true{
                        continue
                    }
                    let annotation = MKPointAnnotation()
                    var infoDictionary = [String: Any]()    //  to collect data for each MKMapItem / annotation
                    infoDictionary["coordinate"] = coordinate
                    infoDictionary["name"] = mapItem.name
                    annotation.coordinate = coordinate
                    annotation.title = mapItem.name!
                    self.mapView.addAnnotation(annotation)
                    infoDictionary["phoneNumber"] = mapItem.phoneNumber
                    infoDictionary["address"] = mapItem.placemark.subThoroughfare! + " " + mapItem.placemark.thoroughfare! + "\n" + mapItem.placemark.locality! + ", " + mapItem.placemark.administrativeArea! + " " + mapItem.placemark.postalCode!
                    infoDictionary["url"] = mapItem.url
                    infoDictionary["isFromYelp"] = false

                    self.mapInfo[mapItem] = infoDictionary
                }
            }
        }
        
        
        
        //  autocomplete suggestions for searching keywords and categories, to be finished
        yelpAPIClient.autocompleteBusinesses(byText: "pizza", latitude: 42.0557, longitude: -87.6743, locale: nil) { (response) in
            if let response = response,
                let businesses = response.businesses,
                businesses.count > 0 {
                for item in businesses{
                    
                }
            }
        }
    }
    
    // to calculate distance between two coordinates
    func calcDistance(coordinate0: CLLocationCoordinate2D,coordinate1: CLLocationCoordinate2D) -> Double {
        let location0 = CLLocation(latitude: coordinate0.latitude, longitude: coordinate0.longitude)
        let location1 = CLLocation(latitude: coordinate1.latitude, longitude: coordinate1.longitude)
        let distanceInMeters = location0.distance(from: location1)
        print (distanceInMeters)
        return distanceInMeters
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinView")
            pinView?.canShowCallout = true
            pinView?.rightCalloutAccessoryView = UIButton(type: .infoLight)
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        for mapItem in mapInfo.keys {
            if mapItem.placemark.coordinate.latitude == view.annotation?.coordinate.latitude && mapItem.placemark.coordinate.longitude == view.annotation?.coordinate.longitude {
                selectedMapItem = mapItem
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DestinationDetailsViewController {
            var infoDictionary = [String: Any]()
            infoDictionary = mapInfo[selectedMapItem]!
            destination.infoDictionary = infoDictionary
            destination.mapItem = selectedMapItem
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "ShowLocationDetailsSegue", sender: nil)
    }
    
}

