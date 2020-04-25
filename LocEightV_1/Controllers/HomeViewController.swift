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
            configureCurrentLocationSwitch()
        }
    }
    var userAnnotation:UserAnnotation! {
        didSet {
            addOverlayForAnnotations()
        }
    }
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
    @IBOutlet weak var mapViewHeightConstraintOutlet: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapViewLayout()
        managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistantContainer.viewContext
        
        menuFunction = .locate_vehicle
        
        checkLocationServices()
        configureCurrentLocationSwitch()
        setUpLocationManager()
        locationManager.startUpdatingLocation()
        
        
        guard checkLocationAuthorization() else {
               print("authorizeWhenInUse is false.")
               return
        }
        
        

        


        
        configureResetButton()
        configureClearMapButton()
        
        configureSwitch()
        
        
        
    }
    
    
    
    
    
    
    @IBAction func currentLocatioSwitchAction(_ sender: UISwitch) {
        
        mapView.showsUserLocation = sender.isOn
        
        switch sender.isOn {
        case true:
            addStartLocationForAnnotationToMap()
            break
        case false:
            removeOverlays()
            centerOnParkingAnnotation()
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
        removeOverlays()
        clearAllMKAnnotations()
        centerViewOnUserLocation()
    }
    
    @IBAction func clearMapAction(_ sender: Any) {
        removeOverlays()
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
    
    func setDefaultForShowuserlocationAndSwitchoutlet() {
        mapView.showsUserLocation = false
        locationDisplaySwitchOutlet.isOn = false
    }
    
    func configureCurrentLocationSwitch() {
        if parkingAnnotation == nil {
            locationDisplaySwitchOutlet.isOn = false
            locationDisplaySwitchOutlet.isEnabled = false
            switchLabel.text = "<- Set parking"
        } else {
            locationDisplaySwitchOutlet.isEnabled = true
            switchLabel.text = "Display current location."
        }
    }
    
    func configureSwitch() {
        locationDisplaySwitchOutlet.isOn = false
        
    }
    
    func configureMapViewLayout() {
        mapViewHeightConstraintOutlet.constant = mapView.bounds.size.width
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


// MARK:- Functionality for loading the controller based on menuFunction
extension HomeViewController {
    
    func configureFindingShoppingPlaces() {
        clearMapButtonOutlet.isHidden = true
        resetButtonOutlet.isHidden = true
        switchLabel.isHidden = true
        locationDisplaySwitchOutlet.isHidden = true
        setDefaultForShowuserlocationAndSwitchoutlet()
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        defaultRegionForClearMap()
    }
    
    func configureFindingEatingPlaces() {
        clearMapButtonOutlet.isHidden = true
        resetButtonOutlet.isHidden = true
        switchLabel.isHidden = true
        locationDisplaySwitchOutlet.isHidden = true
        setDefaultForShowuserlocationAndSwitchoutlet()
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        defaultRegionForClearMap()
    }
    
    func configureLoadingParkingGarages() {
        clearMapButtonOutlet.isHidden = true
        resetButtonOutlet.isHidden = true
        switchLabel.isHidden = true
        locationDisplaySwitchOutlet.isHidden = true
        setDefaultForShowuserlocationAndSwitchoutlet()
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        defaultRegionForClearMap()
    }
    
    func configureLoadingVehicleLocation() {
        clearMapButtonOutlet.isHidden = false
        resetButtonOutlet.isHidden = false
        switchLabel.isHidden = false
        locationDisplaySwitchOutlet.isHidden = false
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        
        if let ai = retrieveCenterLocationOfParkedCarFromCoreData(), let lat = ai.lat as? Double, let long = ai.long as? Double, let title = ai.title, let subTitle = ai.subtitle {

            centerViewOnUserLocation(lat: lat, long: long, title: title, subtitle: subTitle)
        }
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
  
        let fetchRequest = NSFetchRequest<AnnotationEntity>(entityName: "AnnotationEntity")
        fetchRequest.fetchLimit = 1
        
        do {
            return try managedObjectContext.fetch(fetchRequest).first
        } catch {
            print("error:\(error.localizedDescription)")
        }
        
        return nil
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
    
    func centerOnParkingAnnotation() {
        let coordinate = parkingAnnotation.coordinate
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionInMetersForVehicle, longitudinalMeters: regionInMetersForVehicle)
        mapView.setRegion(region, animated: true)
    }
    
    func centerViewOnUserLocation(lat:Double, long:Double, title:String, subtitle:String) {
        if let lat = lat as? Double, let long = long as? Double, let title = title as? String, let subtitle = subtitle as? String, let location = CLLocationCoordinate2D(latitude: lat, longitude: long) as? CLLocationCoordinate2D {
            
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMetersForVehicle, longitudinalMeters: regionInMetersForVehicle)
            parkingAnnotation = ParkingAnnotation(coordinate: location, title: title, subtitle: subtitle)

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
        
//        print("locations:\(locations)")
           
       }
       
       func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
           
       }
    
}


// MARK:- MapView delegate and methods functionality
extension HomeViewController:MKMapViewDelegate {
    
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .red
        renderer.fillColor = .blue
        renderer.lineJoin = .round
        renderer.lineCap = .round
        
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
    
    func addOverlayForAnnotations() {
        if let userAnnotation = userAnnotation {
            createOverlayForCoordinates(startingCoordinate: userAnnotation.coordinate, destinationCoordinate: parkingAnnotation.coordinate)
        }
    }
    
    func removeOverlays() {
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
    }
    
    func createOverlayForCoordinates(startingCoordinate:CLLocationCoordinate2D, destinationCoordinate:CLLocationCoordinate2D) {
            
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
                
                if let mapRect = route?.polyline.boundingMapRect {
                    
                    self.mapView.setVisibleMapRect(mapRect, animated: true)
                    
                    
                }
                
                
            }
        }
    
    
    func shouldPresentLoadingView(status:Bool) {
        var fadeView:UIView?
        
        if (status) {
            fadeView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
            fadeView?.backgroundColor = UIColor(red: 2/255, green: 64/255, blue: 89/255, alpha: 1.0)
            fadeView?.alpha = 0.0
            fadeView?.tag = 99
            
            let spinner = UIActivityIndicatorView()
            spinner.color = UIColor.white
            spinner.style = .large
            spinner.center = view.center
            
            view.addSubview(fadeView!)
            fadeView?.addSubview(spinner)
            
            spinner.startAnimating()
            fadeView?.fadeTo(alphaValue: 0.7, withDuration: 0.2)
        } else {
            for subview in view.subviews {
                if subview.tag == 99 {
                    UIView.animate(withDuration: 0.2, animations: {
                        subview.alpha = 0.0
                    }) { (finished) in
                        subview.removeFromSuperview()
                    }
                }
            }
        }
    }
}





