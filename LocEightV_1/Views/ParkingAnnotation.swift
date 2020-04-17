//
//  ParkingAnnotation.swift
//  LocEightV_1
//
//  Created by Michelle Grover on 4/17/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import Foundation
import MapKit

class ParkingAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    
    
    init(coordinate:CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}


