//
//  HomeViewController.swift
//  LocEightV_1
//
//  Created by Michelle Grover on 4/13/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit

class HomeViewController: UIViewController {
    
    var delegate:CenterViewControllerDelegate?
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapViewLayout()
       
    }
    
    @IBAction func menuButtonAction(_ sender: Any) {
        delegate?.toggleLeftPanel()
    }
    
    
}

// MARK:- Configure mapView layout
extension HomeViewController {
    
    func configureMapViewLayout() {
        
        mapView.layer.borderWidth = 2
        mapView.layer.cornerRadius = 9
        mapView.layer.masksToBounds = true
        
    }
    
    
}
