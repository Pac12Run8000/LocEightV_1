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
import CoreData

class HomeViewController: UIViewController {
    
    var delegate:CenterViewControllerDelegate?
    let locationManager = CLLocationManager()
    let regionInMetersForVehicle:CLLocationDistance = 250
    var parkingAnnotation:ParkingAnnotation! {
        didSet {
            if parkingAnnotation == nil {
                locationDisplaySwitchOutlet.isOn = false
                locationDisplaySwitchOutlet.isEnabled = false
                switchLabel.text = "<- reset parking"
            } else {
                locationDisplaySwitchOutlet.isEnabled = true
                switchLabel.text = "Display current location."
            }
        }
    }
    var userAnnotation:UserAnnotation!
    var managedObjectContext:NSManagedObjectContext!
    
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
    @IBOutlet weak var resetButtonOutlet: UIButton!
    @IBOutlet weak var clearMapButtonOutlet: UIButton!
    @IBOutlet weak var locationDisplaySwitchOutlet: UISwitch!
    @IBOutlet weak var switchLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistantContainer.viewContext
        
        locationManager.startUpdatingLocation()
        setUpLocationManager()
        guard checkLocationAuthorization() else {
               print("authorizeWhenInUse is false.")
               return
        }
        
        configureMapViewLayout()


        if let ae = retrieveCenterLocationOfParkedCarFromCoreData(), let lat = ae.lat as? Double, let long = ae.long as? Double, let title = ae.title, let subtitle = ae.subtitle {
            centerViewOnUserLocation(lat: lat, long: long, title: title, subtitle: subtitle)
        }
        
        configureResetButton()
        configureClearMapButton()
        
        configureSwitch()
        
        
//        mapView.showsUserLocation = true
        
        
    }
    
    
    @IBAction func currentLocatioSwitchAction(_ sender: UISwitch) {
        
        switch sender.isOn {
        case true:
            addStartLocationForAnnotationToMap()
            break
        case false:
            mapView.removeAnnotation(userAnnotation)
            break
        default:
            print("do nothing")
        }
        
    }
    
    
    
    @IBAction func menuButtonAction(_ sender: Any) {
        delegate?.toggleLeftPanel()
    }
    
    @IBAction func resetLocationAction(_ sender: Any) {
        clearAllMKAnnotations()
        centerViewOnUserLocation()
    }
    
    @IBAction func clearMapAction(_ sender: Any) {
        deleteAllOfAnnotationEntity()
        clearAllMKAnnotations()
        defaultRegionForClearMap()
    }
    
    @IBAction func segmentedActionMapType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
            break
        case 1:
            mapView.mapType = .hybrid
            break
        default:
            print("Do nothing")
        }
    }
    
    
    
}

// MARK:- Configure mapView layout UI layout
extension HomeViewController {
    
    func configureSwitch() {
        locationDisplaySwitchOutlet.isOn = false
        
    }
    
    func configureMapViewLayout() {
        
        mapView.delegate = self
        mapView.layer.borderWidth = 2
        mapView.layer.cornerRadius = 9
        mapView.layer.masksToBounds = true
        
    }
    
    func configureResetButton() {
        resetButtonOutlet.layer.borderWidth = 2
        resetButtonOutlet.layer.cornerRadius = 9
        resetButtonOutlet.layer.masksToBounds = true
        resetButtonOutlet.layer.borderColor = UIColor.black.cgColor
    }
    
    func configureClearMapButton() {
        clearMapButtonOutlet.layer.borderWidth = 2
        clearMapButtonOutlet.layer.cornerRadius = 9
        clearMapButtonOutlet.layer.masksToBounds = true
        clearMapButtonOutlet.layer.borderColor = UIColor.black.cgColor
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
    
    func defaultRegionForClearMap() {
        let coordinate = CLLocationCoordinate2D(latitude: 37.090240, longitude:-95.712891)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 5000000, longitudinalMeters: 5000000)
        mapView.setRegion(region, animated: true)
    }
    
    func clearAllMKAnnotations() {
        parkingAnnotation = nil
        let allAnnotations = mapView.annotations
        mapView.removeAnnotations(allAnnotations)
    }
    
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func retrieveCenterLocationOfParkedCarFromCoreData() -> AnnotationEntity? {
        var annotationEntity:AnnotationEntity?
        var annotationEntityArray = [AnnotationEntity]()

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AnnotationEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lat", ascending: true)]
        
        do {
            annotationEntityArray = try managedObjectContext.fetch(fetchRequest) as! [AnnotationEntity]
        } catch {
            print("error:\(error.localizedDescription)")
        }

        
        guard annotationEntityArray.count >= 1 else {
            print("There is no AnnotationEntity.")
            return nil
        }
        
        
        annotationEntity = annotationEntityArray[0] as? AnnotationEntity
        return annotationEntity
    }
    
    func addStartLocationForAnnotationToMap() {
        guard let userLocation = locationManager.location?.coordinate else {
            print("No userLocation is present.")
            return
        }
        let tempCoords = CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude)
        userAnnotation = UserAnnotation(coordinate: tempCoords, title: "Starting Location", subtitle: "")
        mapView.addAnnotation(userAnnotation)
    }
    
    func centerViewOnUserLocation(lat:Double, long:Double, title:String, subtitle:String) {
        if let lat = lat as? Double, let long = long as? Double, let title = title as? String, let subtitle = subtitle as? String, let location = CLLocationCoordinate2D(latitude: lat, longitude: long) as? CLLocationCoordinate2D {
            
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMetersForVehicle, longitudinalMeters: regionInMetersForVehicle)
            parkingAnnotation = ParkingAnnotation(coordinate: location, title: title, subtitle: subtitle)
//            getTheParkedVehicleCoordinates(destinationCoordinate: location)
            mapView.addAnnotation(parkingAnnotation)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func centerViewOnUserLocation() {
        
        if let location = locationManager.location?.coordinate, let lat = location.latitude as? CLLocationDegrees, let long = location.longitude as? CLLocationDegrees, let clLocation = CLLocation(latitude: lat, longitude: long) as? CLLocation {
            
            // MARK:-  This is where my placeMarks functionality goes ...
            
            
            
            returnParkingLocationAddress(clLocation: clLocation) { (address, error) in
                guard error == nil else {
                    print("There was an error:\(error?.localizedDescription)")
                    return
                }
//                print("\(address)")
                self.insertUpdateAnnotationEntity(lat: lat, long: long, title: "You are parked here ...", subtitle:address)
                
                let region = MKCoordinateRegion(center: location, latitudinalMeters: self.regionInMetersForVehicle, longitudinalMeters: self.regionInMetersForVehicle)
                    
                self.parkingAnnotation = ParkingAnnotation(coordinate: location, title: "You are parked here ...", subtitle:address!)
                self.mapView.addAnnotation(self.parkingAnnotation)
                self.mapView.setRegion(region, animated: true)
            }
           
        } else {
            print("Location Manager isn't working.")
        }
        
        
    }
    
    
    
    
    
    
    func returnParkingLocationAddress(clLocation:CLLocation, completion handler:@escaping(_ address:String?,_ error:Error?) -> ()) {
        var myAddress:String?
        CLGeocoder().reverseGeocodeLocation(clLocation) { (placemarks, error) in
            guard error == nil else {
                print("There was an error:\(error?.localizedDescription)")
                handler(nil, error)
                return
            }
            if let place = placemarks![0] as? CLPlacemark {
                
                if let subThouroughfare = place.subThoroughfare, let thoroughfare = place.thoroughfare, let locality = place.locality, let administrativeArea = place.administrativeArea, let postalCode = place.postalCode, let country = place.country {
                    myAddress = "\(subThouroughfare) \(thoroughfare), \(locality), \(administrativeArea), \(postalCode) \(country)"
                    
                } else {
                    myAddress = "Invalid address information"
                }
                

            }
            
            handler(myAddress, nil)
        }
    
    }
    
    func checkLocationServices() {
        guard CLLocationManager.locationServicesEnabled() else {
            print("Location Services aren't enabled")
            showAlert(title: "Device issue", msg: "Location Services aren't enabled. Location services may not exist on this device.")
            return
        }
        
        print("Location Services are ready.")
       
//        setUpLocationManager()
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
            return true
            break
        }
    }
}

// MARK:- CLLocationManagerDelegate functionality
extension HomeViewController:CLLocationManagerDelegate {
    
      func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("locations:\(locations)")
           
       }
       
       func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
           
       }
    
}


// MARK:- MapView delegate and methods functionality
extension HomeViewController:MKMapViewDelegate {
    
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .green
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? ParkingAnnotation {
                   let identifier = "parking"
                   var view:MKAnnotationView
                   view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                   view.image = UIImage(named: "destinationAnnotation")
                   view.isEnabled = true
                   view.canShowCallout = true
                   let flyout = UIButton(type: .detailDisclosure)
                   view.rightCalloutAccessoryView = flyout
                   return view
               } else if let annotation = annotation as? UserAnnotation {
                   let identifier = "user"
                   var view:MKAnnotationView
                   view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                   view.image = UIImage(named: "currentLocationAnnotation")
                   view.isEnabled = true
                   view.canShowCallout = true
                    let flyout = UIButton(type: .detailDisclosure)
                    view.rightCalloutAccessoryView = flyout
                   return view
               }
               return nil
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


// MARK:- CoreData Functionality
extension HomeViewController {
    
    func insertUpdateAnnotationEntity(lat:Double?, long:Double?, title:String?, subtitle:String?) {
        var annotationEntity:AnnotationEntity!
        var annotationUpdateEntity:AnnotationEntity!
        var annotationArray = [AnnotationEntity]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AnnotationEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lat", ascending: true)]
        
        do {
            try annotationArray = managedObjectContext.fetch(fetchRequest) as! [AnnotationEntity]
            print("Fetch was successful")
        } catch {
            print("There was an error:\(error.localizedDescription)")
        }
        
        if (annotationArray.count == 0) {
            let annotationEntity = AnnotationEntity(context: managedObjectContext)
            annotationEntity.lat = lat!
            annotationEntity.long = long!
            annotationEntity.title = title!
            annotationEntity.subtitle = subtitle!
            do {
                try CoreDataStack.saveContext(context: managedObjectContext)
                print("Save was successful")
            } catch {
                print("Error:\(error.localizedDescription)")
            }
            
        } else {
            annotationUpdateEntity = annotationArray[0]
            annotationUpdateEntity.lat = lat!
            annotationUpdateEntity.long = long!
            annotationUpdateEntity.title = title!
            annotationUpdateEntity.subtitle = subtitle!
            
            do {
                try CoreDataStack.saveContext(context: managedObjectContext)
            } catch {
                print("Error:\(error.localizedDescription)")
            }
        }
        
    }
    
    
    func fetchAllOfAnnotationEntity() {
        var annotationEntityArray = [AnnotationEntity]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AnnotationEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lat", ascending: true)]

           do {
               annotationEntityArray = try managedObjectContext.fetch(fetchRequest) as! [AnnotationEntity]
           } catch {
               print("There was an error retrieving the data.")
           }

           for item in annotationEntityArray {
               print("item:\(item.lat), \(item.long), \(item.subtitle)")
           }
    }
    
    
    func deleteAllOfAnnotationEntity() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "AnnotationEntity")
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            let result = try managedObjectContext!.execute(request)
            print("Deletion completed")
        } catch {
            print("Error:\(error.localizedDescription)")
        }
    }
    
    
    
    
}


// MARK:- This is the overlay functionality creation
extension HomeViewController {
    
    func createOverlayForCoordinates(startingCoordinate:CLLocationCoordinate2D, destinationCoordinate:CLLocationCoordinate2D) {
            
    //        guard let startingCoordinate = locationManager.location?.coordinate else {
    //            print("There is no starting coordinate.")
    //            return
    //        }
            
    //        let startingCoordinate = CLLocationCoordinate2D(latitude: 37.765740, longitude: -122.257350)
    //        let destinationCoordinate = CLLocationCoordinate2D(latitude: 39.091690, longitude: -104.835430)
            
            let startingPlaceMark = MKPlacemark(coordinate: startingCoordinate)
            let destinationPlaceMark = MKPlacemark(coordinate: destinationCoordinate)
            
            let startItem = MKMapItem(placemark: startingPlaceMark)
            let destinationItem = MKMapItem(placemark: destinationPlaceMark)
            
            let destinationRequest = MKDirections.Request()
            destinationRequest.source = startItem
            destinationRequest.destination = destinationItem
            destinationRequest.transportType = .automobile
            destinationRequest.requestsAlternateRoutes = true
            
            let directions = MKDirections(request: destinationRequest)
            directions.calculate { (response, error) in
                guard error == nil else {
                    print("There was an error:\(error?.localizedDescription)")
                    return
                }
                
                let route = response?.routes[0]
                self.mapView.addOverlay(route!.polyline)
        
            }
            
            
        }
}


