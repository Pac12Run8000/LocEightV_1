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
    var mapItemsForAddresses:[MKMapItem]?
    var parkingAnnotation:ParkingAnnotation! {
        didSet {
            configureCurrentLocationSwitch()
        }
    }
    var userAnnotation:UserAnnotation! {
        didSet {
            switch menuFunction {
            case .locate_vehicle:
                addOverlayForAnnotations()
            default:
                print("I'm not drawing an overlay.")
            }
            
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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var takePhotoButtonOutlet: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configureMapViewLayout()
        managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistantContainer.viewContext
        
        fetchAllOfAnnotationEntity()
        
        menuFunction = .locate_vehicle
        
        checkLocationServices()
        configureCurrentLocationSwitch()
        setUpLocationManager()
        locationManager.startUpdatingLocation()
        
        guard checkLocationAuthorization() else {
               print("authorizeWhenInUse is false.")
               return
        }
        activityIndicator.layer.cornerRadius = 5
        
        configureResetButton()
        configureClearMapButton()
        configureTakePhotoButton()
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
       
        Alert.insureUserActionsAlert(vc: self, title: "Warning!", msg: "This action will delete all previous parking information and reset to your NEW current location. Are you sure that you want to proceed?") { (areProceeding) in
            if areProceeding {
                self.removeOverlays()
                self.clearAllMKAnnotations()
                self.centerViewOnUserLocation()
            }
        }

    }
    
    
    
    @IBAction func clearMapAction(_ sender: Any) {
        
        Alert.insureUserActionsAlert(vc: self, title: "Warning!", msg: "This action will clear your parking and current location. Do you want to do this?") { (areYouProceeding) in
            
            if areYouProceeding {
                self.removeOverlays()
                self.deleteAllOfAnnotationEntity()
                self.clearAllMKAnnotations()
                self.defaultRegionForClearMap()
            }
            
        }
        
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
    
    
    @IBAction func takePhotoAction(_ sender: Any) {
        
        
        ActionSheet.handleImageFunctionality(vc: self, title: "Taking a picture can help ...", message: "Take a picture of the garage level or your parking space number. These can help you find your parking space. Or you view an image that you've already taken.") { (imagePickerState) in
            
            let imagePickerController = self.setImagePickerDelegate()
            
            switch imagePickerState {
            case .photoLibrary:
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
                break
            case .camera:
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    imagePickerController.sourceType = .camera
                    self.present(imagePickerController, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Device error", message: "This device does not have a camera.", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
                break
            case .showImage:

                if self.fetchImage(managedObjectContext: self.managedObjectContext) {
                    self.performSegue(withIdentifier: "dispayImageSegue", sender: self)
                } else {
                    let alert = UIAlertController(title: "Missing Data", message: "You never saved an image to view. Go back to \"Take photo\" and save an image.", preferredStyle: .actionSheet)
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
                
                
                break
            case .removeImage:
                break
            case .cancel:
                self.dismiss(animated: true, completion: nil)
                break
            }
            
            
        }
        
        
        
        
    }
    
    
    func fetchImage(managedObjectContext:NSManagedObjectContext) -> Bool {
        var annotationEntity:AnnotationEntity!
        let fetch = NSFetchRequest<AnnotationEntity>(entityName: "AnnotationEntity")
        fetch.fetchLimit = 1
        do {
            try annotationEntity = managedObjectContext.fetch(fetch).first
        } catch {
            print("fetch error:\(error.localizedDescription)")
        }
        
        if annotationEntity.image != nil {
            return true
        }
        return false
    }
    
    
    
}


// MARK:- UIImagePickerControllerDelegate functionality
extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func setImagePickerDelegate() -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        return imagePickerController
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var imageToView:UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageToView = editedImage
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageToView = image
        }
        
        
        self.dismiss(animated: true) {
            
            ActionSheet.displayUIImageInActionSheet(vc: self, imageToView: imageToView) { (isSavingToCoreData) in
                if isSavingToCoreData {
                    CoreDataStack.updateImageForParkingInformation(image: imageToView!, managedObjectContext: self.managedObjectContext)
                }
            }
            
        }
        
    }
    
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
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
            takePhotoButtonOutlet.isHidden = true
            clearMapButtonOutlet.isHidden = true
            
            locationDisplaySwitchOutlet.isOn = false
            locationDisplaySwitchOutlet.isEnabled = false
            switchLabel.text = "<- Set parking"
           
        } else {
            clearMapButtonOutlet.isHidden = false
            takePhotoButtonOutlet.isHidden = false
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
    
    func configureTakePhotoButton() {
        takePhotoButtonOutlet.layer.borderWidth = 2
        takePhotoButtonOutlet.layer.cornerRadius = 9
        takePhotoButtonOutlet.layer.masksToBounds = true
        takePhotoButtonOutlet.layer.borderColor = UIColor.black.cgColor
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
        takePhotoButtonOutlet.isHidden = true
        switchLabel.isHidden = false
        takePhotoButtonOutlet.isHidden = true
        switchLabel.text = "number of shopping places:"
        locationDisplaySwitchOutlet.isHidden = true
        setDefaultForShowuserlocationAndSwitchoutlet()
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        defaultRegionForClearMap()
    }
    
    func configureFindingEatingPlaces() {
        
        
        clearMapButtonOutlet.isHidden = true
        resetButtonOutlet.isHidden = true
        takePhotoButtonOutlet.isHidden = true
        
        takePhotoButtonOutlet.isHidden = true
        
        switchLabel.isHidden = false
        switchLabel.text = "number of restaurants:"
        locationDisplaySwitchOutlet.isHidden = true
        setDefaultForShowuserlocationAndSwitchoutlet()
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        defaultRegionForClearMap()
    }
    
    func configureLoadingParkingGarages() {
        
//        mapView.pointOfInterestFilter = .some(MKPointOfInterestFilter(including: [.parking]))
        
        clearMapButtonOutlet.isHidden = true
        resetButtonOutlet.isHidden = true
        switchLabel.isHidden = false
        
        takePhotoButtonOutlet.isHidden = true
        
        locationDisplaySwitchOutlet.isHidden = true
        takePhotoButtonOutlet.isHidden = true
        
        setDefaultForShowuserlocationAndSwitchoutlet()
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        
        searchForParkingGarages()
    }
    
    
    func searchForParkingGarages() {
        
        guard let coordinate = locationManager.location?.coordinate else {
            print("There are no coordinates.")
            return
        }
        
        let clLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        
        
        returnLocationAddress(clLocation: clLocation) { (address, error) in
            guard error == nil else {
                print("There was an arror getting the address:\(error?.localizedDescription)")
                return
            }
            var defaultAddress = address != nil ? address : "The address is missing for this location"
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: self.regionInMetersForVehicle, longitudinalMeters: self.regionInMetersForVehicle)
            
            
            self.userAnnotation = UserAnnotation(coordinate: coordinate, title: "You are here ..", subtitle: "\(defaultAddress!)")
            self.mapView.addAnnotation(self.userAnnotation)
            self.mapView.setRegion(region, animated: true)
            
            self.getRegionForMKMapItemPlaceMarks(region: region)
        }
    }
    
    func getRegionForMKMapItemPlaceMarks(region:MKCoordinateRegion) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "parking"
        request.region = region
//        request.resultTypes = .pointOfInterest
        let search = MKLocalSearch(request: request)
        
        search.start { (response, error) in
            guard error == nil else {
                print("There was an error getting mapItems:\(error?.localizedDescription)")
                return
            }
            
            guard let mapItems = response?.mapItems, mapItems.count > 0 else {
                print("There were no mapItems.")
                return
            }
            
            for mapItem in mapItems {
               
                if let lat = mapItem.placemark.location?.coordinate.latitude, let long = mapItem.placemark.location?.coordinate.longitude, let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long) as? CLLocationCoordinate2D {
                    
                    let garageAnnotation = GarageAnnotation(coordinate: coordinate, title: "Park here.", subtitle: "\(mapItem.placemark.title ?? "Name not available")")
                    self.mapView.addAnnotation(garageAnnotation)
                 
                }
            }
            
            if let garageAnnotationCount = self.mapView.annotations.filter({ $0 is GarageAnnotation }).count as? Int {
                self.switchLabel.text = "parking locations: \(garageAnnotationCount)"
            } else {
                self.switchLabel.text = "There are no parking locations."
            }
            
        }
        
        
    }
    
    func configureLoadingVehicleLocation() {
        clearMapButtonOutlet.isHidden = false
        resetButtonOutlet.isHidden = false
        switchLabel.isHidden = false
        locationDisplaySwitchOutlet.isHidden = false
        takePhotoButtonOutlet.isHidden = false
        takePhotoButtonOutlet.isHidden = false
        
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
            
            
            
            returnLocationAddress(clLocation: clLocation) { (address, error) in
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
    
    
    func returnLocationAddress(clLocation:CLLocation, completion handler:@escaping(_ address:String?,_ error:Error?) -> ()) {
        
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
            Alert.showAlert(vc:self, title: "Device issue", msg: "Location Services aren't enabled. Location services may not exist on this device.")
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
            Alert.showAlert(vc:self, title: "Security issue", msg: "You need to go to location services in your setting so that we can access your location.")
             return false
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return false
            break
        case .restricted:
            Alert.showAlert(vc:self, title: "Parental Restriction", msg: "Your parents or guardians have placed restrictions on your ability to access your location.")
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
                } else if let annotation = annotation as? GarageAnnotation {
                    let identifier = "garage"
                    var view:MKAnnotationView
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    view.image = UIImage(named: "driverAnnotation")
                    view.isEnabled = true
                    view.canShowCallout = true
                     let flyout = UIButton(type: .detailDisclosure)
                     view.rightCalloutAccessoryView = flyout
                    return view
                }
               return nil
    }
    
}

// MARK:- CoreData Functionality
extension HomeViewController {
    
    func insertUpdateAnnotationEntity(lat:Double?, long:Double?, title:String?, subtitle:String?) {
        
        var annotationEntity:AnnotationEntity!
        
        let fetchRequest = NSFetchRequest<AnnotationEntity>(entityName: "AnnotationEntity")
        fetchRequest.fetchLimit = 1
        do {
            try annotationEntity = managedObjectContext.fetch(fetchRequest).first
        } catch {
            print("There was an error fetching data:\(error.localizedDescription)")
        }
        
        if annotationEntity == nil {
            let annotationEntity = AnnotationEntity(context: managedObjectContext)
            annotationEntity.lat = lat!
            annotationEntity.long = long!
            annotationEntity.title = title
            annotationEntity.subtitle = subtitle
            
            do {
                try CoreDataStack.saveContext(context: managedObjectContext)
                print("successful data save.")
            } catch {
                print("There was an error when saving:\(error.localizedDescription)")
            }
        } else {
            annotationEntity.lat = lat!
            annotationEntity.long = long!
            annotationEntity.title = title
            annotationEntity.subtitle = subtitle
            
            do {
                try CoreDataStack.saveContext(context: managedObjectContext)
                print("successful data update.")
            } catch {
                print("There was an error when saving:\(error.localizedDescription)")
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
            print("item:\(item.lat), \(item.long), \(item.subtitle), image data:\(item.image)")
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
        
        
        activityIndicator.startAnimating()
            
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
                    self.activityIndicator.stopAnimating()
                    
                }
                
                
            }
        }
    
    
    
}





