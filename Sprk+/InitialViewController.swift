//
//  InitialViewController.swift
//  Sprk+
//
//  Created by Carlo Saraniti on 7/12/19.
//  Copyright © 2019 Carlo Saraniti. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var pickerData = [String]()
    var input = ""
    @IBOutlet weak var picker: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.picker.delegate = self
        self.picker.dataSource = self
        pickerData = ["Restaurants", "Breakfast & Brunch", "Coffee & Tea"]

    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return pickerData[row]
    }
 
    @IBAction func goButton(_ sender: UIButton) {
        input = pickerData[picker.selectedRow(inComponent: 0)]
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dvc = segue.destination as! ViewController
        dvc.input = input
    }
    
}
