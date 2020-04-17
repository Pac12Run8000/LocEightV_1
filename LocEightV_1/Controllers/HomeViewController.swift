//
//  HomeViewController.swift
//  LocEightV_1
//
//  Created by Michelle Grover on 4/13/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class HomeViewController: UIViewController {
    
    var delegate:CenterViewControllerDelegate?
    let locationManager = CLLocationManager()
    let regionInMetersForVehicle:CLLocationDistance = 250
    var parkingAnnotation:ParkingAnnotation!
    
    var menuFunction:MenuFunction? {
        didSet {
            switch menuFunction {
            case .locate_vehicle:
                configureLoadingVehicleLocation()
            case .find_parking_garage:
                configureLoadingParkingGarages()
                print("find a parking garage downtown")
            case .find_eating_places:
                configureFindingEatingPlaces()
                print("find a place to eat")
            case .find_shopping_places:
                configureFindingShoppingPlaces()
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
    
    @IBAction func resetLocationAction(_ sender: Any) {
        clearAllMKAnnotations()
    }
    
    @IBAction func clearMapAction(_ sender: Any) {
        clearAllMKAnnotations()
    }
    
    
}

// MARK:- Configure mapView layout
extension HomeViewController {
    
    func configureMapViewLayout() {
        
        mapView.delegate = self
        mapView.layer.borderWidth = 2
        mapView.layer.cornerRadius = 9
        mapView.layer.masksToBounds = true
        
    }
    
    
}


// MARK:- Functionality for loading vehicle location
extension HomeViewController {
    
    func configureFindingShoppingPlaces() {
        
    }
    
    func configureFindingEatingPlaces() {
        
    }
    
    func configureLoadingParkingGarages() {
        
    }
    
    func configureLoadingVehicleLocation() {
        checkLocationServices()
    }
    
    func clearAllMKAnnotations() {
        let allAnnotations = mapView.annotations
        mapView.removeAnnotations(allAnnotations)
    }
    
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        
        if let location = locationManager.location?.coordinate {
           
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMetersForVehicle, longitudinalMeters: regionInMetersForVehicle)
            
            parkingAnnotation = ParkingAnnotation(coordinate: location, title: "You've parked here ...", subtitle: "1810 san Jose Ave Alameda CA 94501")
            mapView.addAnnotation(parkingAnnotation)
            mapView.setRegion(region, animated: true)
        }
        
        
    }
    
    func checkLocationServices() {
        guard CLLocationManager.locationServicesEnabled() else {
            print("Location Services aren't enabled")
            showAlert(title: "Device issue", msg: "Location Services aren't enabled. Location services may not exist on this device.")
            return
        }
        
        print("Location Services are ready.")
       
        setUpLocationManager()
        guard checkLocationAuthorization() else {
            print("authorizeWhenInUse is false.")
            return
        }
        centerViewOnUserLocation()
        
    }
    
    func checkLocationAuthorization() -> Bool {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
//            mapView.showsUserLocation = true
            return true
            break
        case .denied:
             showAlert(title: "Security issue", msg: "You need to go to location services in your setting so that we can access your location.")
             return false
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return false
            break
        case .restricted:
            showAlert(title: "Parental Restriction", msg: "Your parents or guardians have placed restrictions on your ability to access your location.")
            return false
            break
        case .authorizedAlways:
            return false
            break
        }
    }
}

// MARK:- CLLocationManagerDelegate functionality
extension HomeViewController:CLLocationManagerDelegate {
    
    
    
}


// MARK:- MapView methods functionality
extension HomeViewController:MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotationView = MKAnnotationView(annotation: parkingAnnotation, reuseIdentifier: "parking") as? MKAnnotationView else {
            print("There was no parking annotation.")
            return nil
        }
        
        annotationView.image = UIImage(named: "currentLocationAnnotation")
        

        annotationView.isEnabled = true
        annotationView.canShowCallout = true
        let flyout = UIButton(type: .detailDisclosure)
        annotationView.rightCalloutAccessoryView = flyout
        
        return annotationView
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
}

// MARK:- Turn location services on
extension HomeViewController {
    
    func showAlert(title:String, msg:String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "ok", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}


