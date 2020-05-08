//
//  ObjectViewController.swift
//  wroclaw
//
//  Created by Nazar on 06/05/2019.
//  Copyright © 2019 N&M 2016. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import ARKit


class ObjectViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    func tabBarController(tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //        let tabBarIndex = tabBarController.selectedIndex
        //        if tabBarIndex == 0 {
        //            //do your stuff
        //        }
        
        dismiss(animated: true, completion: nil)
    }

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var ImageL: UIButton!
    @IBOutlet var DescriptionL: UITextView!
    @IBOutlet var BarButton: UIBarButtonItem!
    @IBOutlet var MapButton: UIBarButtonItem!
    @IBOutlet var ARButton: UIBarButtonItem!
    @IBOutlet var ImageF: UIImageView!
    
//    var Path =  [MKMapPoint]()
    var Trail = [[Double]]()
    var Title = ""
    var Image = [String]()
    var Description = ""
    var CurrentPosition: CLLocationCoordinate2D?
    var ID = 0
    var mapType = false
    
    func readDescFile() -> String{
        let path = Bundle.main.path(forResource: "Description", ofType: "txt")
        let content = FileManager().contents(atPath: path!)
        let textfile = String(data: content!, encoding: String.Encoding.utf8)
        let list = textfile?.components(separatedBy: "\n")
        var listarray = " NONE "
        for n in 0...list!.count-2 {
            let readline = list![n].components(separatedBy: "/")
            if ID == Int(readline[0]){
                listarray = readline[1]
                break
            }
        }
        return listarray
    }
    
    func readImgFile() -> [String]{
        let path = Bundle.main.path(forResource: "Pictures", ofType: "txt")
        let content = FileManager().contents(atPath: path!)
        let textfile = String(data: content!, encoding: String.Encoding.utf8)
        let list = textfile?.components(separatedBy: "\n")
        var listarray = [String]()
        for n in 0...list!.count-2 {
            let readline = list![n].components(separatedBy: "/")
            if ID == Int(readline[0]){
                listarray = [String](readline[1 ..< readline.endIndex])
                break
            }
        }
        return listarray
    }
    
    @IBAction func addToFav(_ sender: Any) {
        let defaults = UserDefaults.standard
        if (defaults.integer(forKey: "IDC") == -1) {
            defaults.removeObject(forKey: "IDC")
        }
        if (defaults.string(forKey: "ID" + String(ID)) != nil) {
            defaults.removeObject(forKey: "ID" + String(ID))
            let IDC = defaults.integer(forKey: "IDC")
            defaults.set(IDC - 1, forKey: "IDC")
            BarButton.title = "Add to favourite"
        } else {
            if (defaults.string(forKey: "IDC") == nil){
                defaults.set(0, forKey: "IDC")
            }
            let IDC = defaults.integer(forKey: "IDC")
            defaults.set(IDC, forKey: "ID" + String(ID))
            defaults.set(IDC + 1, forKey: "IDC")
            BarButton.title = "Remove favourite"
        }
    }
    
    @IBAction func mapChangeView(_ sender: Any) {
        if !mapType{
            MapButton.title = "Flat"
            mapView.mapType = .satellite
            mapType = !mapType
        } else {
            mapType = !mapType
            MapButton.title = "Satellite"
            mapView.mapType = .standard
        }
    }
    
    
    var locationManager: CLLocationManager!

    
    override func viewDidLoad() {
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.title = Title
        Description = readDescFile()
        Image = readImgFile()
        if Image.count != 0{
            ImageL.setImage(UIImage(named: Image[0]), for: .normal)
            ImageL.isEnabled = true
        } else {
            ImageL.setImage(UIImage(named: "ico_wro")!, for: .normal)
            ImageL.isEnabled = false
        }
        DescriptionL.text = Description
        let defaults = UserDefaults.standard
        if (defaults.string(forKey: "ID" + String(ID)) != nil) {
            BarButton.title = "Remove favourite"
        } else {
            BarButton.title = "Add to favourite"
        }
        
        MapButton.title = "Sattelite"
        ImageF.isHidden = Image.count < 2
        self.ARButton.isEnabled = ARWorldTrackingConfiguration.isSupported
        super.viewDidLoad()
        mapView.delegate = self
        let annotation = MKPointAnnotation()
        annotation.coordinate = CurrentPosition!
        annotation.title = Title
        mapView.addAnnotation(annotation)
//        self.hidesBottomBarWhenPushed = true
    }
    

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.startUpdatingLocation()
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        manager.stopUpdatingLocation()
        showRouteOnMap(sourceCoordinate: locValue, destinationCoordinate: CurrentPosition!)
        
    }
    
    func showRouteOnMap(sourceCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: sourceCoordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            for i in 0...unwrappedResponse.routes[0].polyline.pointCount{
                let position = unwrappedResponse.routes[0].polyline.points()[i].coordinate
                self.Trail.append( [position.latitude, position.longitude] )
            }
            if (unwrappedResponse.routes.count > 0) {
                self.mapView.addOverlay(unwrappedResponse.routes[0].polyline)
                self.mapView.setVisibleMapRect(unwrappedResponse.routes[0].polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView!, rendererFor overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return nil
    }
    
//    func showRouteOnMap(sourceCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
//
//        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate, addressDictionary: nil)
//        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
//
//        let directionRequest = MKDirections.Request()
//        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
//        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
//        directionRequest.transportType = .automobile
//
//        let directions = MKDirections(request: directionRequest)
//        directions.calculate { (response, error) in
//            guard let directionResonse = response else {
//                if let error = error {
//                    print("we have error getting directions==\(error.localizedDescription)")
//                }
//                return
//            }
//
//            let route = directionResonse.routes[0]
//            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
//
//            let rect = route.polyline.boundingMapRect
//            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
//        }
//
//        //set delegate for mapview
////        self.mapView.delegate = self
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        self.hidesBottomBarWhenPushed = true
        if segue.identifier == "pictureobj" {
            let destinationController = segue.destination as! PicturesViewController
            destinationController.Image = Image
        }
        if segue.identifier == "arobj" {
            let destinationController = segue.destination as! ARViewController
            destinationController.ObjPosition = [CurrentPosition?.longitude, CurrentPosition?.latitude] as! [Double]
            if (CLLocationManager.locationServicesEnabled()) && (locationManager.location != nil){
                locationManager.startUpdatingLocation()
                let UserPosition = locationManager.location!.coordinate
                destinationController.UserPosition = [UserPosition.longitude, UserPosition.latitude]
                locationManager.stopUpdatingLocation()
            }
        }
    }
    
//    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
//
//        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
//        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
//        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
//        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
//        let sourceAnnotation = MKPointAnnotation()
//        if let location = sourcePlacemark.location {
//            sourceAnnotation.coordinate = location.coordinate
//        }
//        let destinationAnnotation = MKPointAnnotation()
//        if let location = destinationPlacemark.location {
//            destinationAnnotation.coordinate = location.coordinate
//        }
//        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
//        let directionRequest = MKDirections.Request()
//        directionRequest.source = sourceMapItem
//        directionRequest.destination = destinationMapItem
//        directionRequest.transportType = .automobile
//        // Calculate the direction
//        let directions = MKDirections(request: directionRequest)
//        directions.calculate {
//            (response, error) -> Void in
//            guard let response = response else {
//                if let error = error {
//                    print("Error: \(error)")
//                }
//                return
//            }
//            let route = response.routes[0]
//            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
//            let rect = route.polyline.boundingMapRect
//            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
//        }
//    }
    
    // MARK: - MKMapViewDelegate
    
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        let renderer = MKPolylineRenderer(overlay: overlay)
//        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
//        renderer.lineWidth = 5.0
//        return renderer
//    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }

}
