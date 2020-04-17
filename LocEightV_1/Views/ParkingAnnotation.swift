//
//  ParkingAnnotation.swift
//  LocEightV_1
//
//  Created by Michelle Grover on 4/17/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import Foundation
import MapKit

class CarAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    
    
    init(coordinate:CLLocationCoordinate2D, title:String, description:String) {
        self.coordinate = coordinate
        super.init()
    }
}


