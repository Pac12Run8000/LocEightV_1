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
    
    
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle:String?
    
    init(coordinate:CLLocationCoordinate2D, title:String, subtitle:String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
    
}


