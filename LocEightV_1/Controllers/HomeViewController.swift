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
    
    var menuFunction:MenuFunction? {
        didSet {
            switch menuFunction {
            case .locate_vehicle:
                print("must locate your vehicle")
            case .find_parking_garage:
                print("find a parking garage downtown")
            case .find_eating_places:
                print("find a place to eat")
            case .find_shopping_places:
                print("find a place to shop")
            default:
                print("Do nothing")
            }
        }
    }
    
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapViewLayout()
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
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


