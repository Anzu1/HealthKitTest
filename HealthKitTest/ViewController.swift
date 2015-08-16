//
//  ViewController.swift
//  HealthKitTest
//
//  Created by Appcamp on 16/08/15.
//  Copyright (c) 2015 Appcamp. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {

    @IBOutlet weak var biologicalSexLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        }
        else {
            return nil
        }
    }()
    @IBAction func getHealthKitData(sender: AnyObject) {
        if healthStore != nil {
            var error: NSError? = NSError()
            var biologicalSexObject = healthStore!.biologicalSexWithError(&error)!.biologicalSex
            println(biologicalSexObject)
            var biologicalSex = " "
            
            switch biologicalSexObject {
                case .Female: biologicalSex = "Female"
                case .Male: biologicalSex = "Male"
                case .NotSet: biologicalSex = "Not set"
                case .Other: biologicalSex = "Other"
            }
            
            biologicalSexLabel.text = biologicalSex
            
            var sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            
            let heightSampleQuery = HKSampleQuery(sampleType: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight), predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) {
                (query, results, error) in
                if let mostRecentSample = results.first as? HKQuantitySample {
                    let unit = HKUnit(fromString: "m")
                    let value = mostRecentSample.quantity.doubleValueForUnit(unit)
                    
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        self.heightLabel.text = "\(value)\(unit)"
                
                })
                }
            }
            healthStore?.executeQuery(heightSampleQuery)
        }
    }
    
    func requestAccessToHealthData() {
        let dataTypesToWrite = NSSet()
        let dataTypesToRead = NSSet(objects: HKCharacteristicType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex), HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight))
        
        if healthStore != nil {
            healthStore!.requestAuthorizationToShareTypes(dataTypesToWrite as Set<NSObject>, readTypes: dataTypesToRead as Set<NSObject>) {
            (success, error) -> Void in
            if success {
                println("success")
            }
            else {
                println(error.description)
            }
        }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAccessToHealthData()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

