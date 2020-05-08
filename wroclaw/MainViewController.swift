//
//  MainViewController.swift
//  wroclaw
//
//  Created by Nazar on 25/03/2019.
//  Copyright © 2019 N&M 2016. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class MainViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
//    @IBOutlet var bottomConstraint: NSLayoutConstraint!
//    @IBOutlet var proportionConstraint: NSLayoutConstraint!
    
    var locationManager: CLLocationManager!
    var distances = [[String]]()
    
    
    // Center on map
    let regionRadius: CLLocationDistance = 4000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    //
    // Read locations
    func readListFile() -> [[String]]{
        let path = Bundle.main.path(forResource: "List", ofType: "txt")
        let content = FileManager().contents(atPath: path!)
        let textfile = String(data: content!, encoding: String.Encoding.utf8)
        let list = textfile?.components(separatedBy: "\n")
        var listarray = [[String]]()
        for n in 1...list!.count-2 {
            let readline = list![n].components(separatedBy: "/")
            listarray.append(readline)
        }
        return listarray
    }
    //
    // Add pins
    func addPins(list: [[String]]) {
        for n in 0...list.count-1{
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(Double(list[n][2])!, Double(list[n][3])!)
            annotation.title = list[n][1]
            mapView.addAnnotation(annotation)
        }
    }
    //
    // Find distance
    func findDistance() -> [[String]]{
        var locValue:CLLocation? = nil
        if (CLLocationManager.locationServicesEnabled()) && (locationManager.location != nil){
            locationManager.startUpdatingLocation()
            locValue = locationManager.location! as CLLocation
            locationManager.stopUpdatingLocation()
        }
        var list = readListFile()
        
        for n in 0...list.count-1{
            if locValue != nil {
                let location = CLLocation(latitude: Double(list[n][2])!,longitude: Double(list[n][3])!)
                list[n][4] = String(locValue!.distance(from: location))
            } else {
                list[n][4] = ""
            }
        }
        list.sort { left, right in
            Double(left[4])! < Double(right[4])!
        }
        return list
    }
    
//    func constraintRotate(orientation: Bool){
////        NSLayoutConstraint(item: mapView, attribute: .bottom, relatedBy: .equal, toItem: tableView, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = orientation
////        mapView.bottomAnchor.constraint(equalTo: tableView.topAnchor).isActive = !orientation
////        mapView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = orientation
////        tableView.heightAnchor.constraint(equalTo: tableView.widthAnchor, multiplier: 0.5).isActive = !orientation
////        NSLayoutConstraint(item: mapView, attribute: .bottom, relatedBy: .equal, toItem: tableView, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = !orientation
////        NSLayoutConstraint(item: tableView, attribute: .width, relatedBy: .equal, toItem: tableView, attribute: .height, multiplier: 1.5, constant: 0.0).isActive = !orientation
//        bottomConstraint.isActive = !orientation
//        proportionConstraint.isActive = !orientation
////        tableView.updateConstraints()
////        mapView.updateConstraints()
////        self.tableView.isHidden = orientation
//    }
    //
    
    
    override func viewDidLoad() {
//        locationManager.requestAlwaysAuthorization()
//        locationManager.requestWhenInUseAuthorization()

        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
//        self.tableView.isHidden = true
//        constraintRotate(orientation:  UIDevice.current.orientation.isLandscape)
        super.viewDidLoad()
        
        let list = readListFile()
        addPins(list: list)
        
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        self.hidesBottomBarWhenPushed = true
////        self.navigationController?.toolbar.isHidden = false
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        self.hidesBottomBarWhenPushed = false
////        self.navigationController?.toolbar.isHidden = true
//    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.startUpdatingLocation()
        let locValue:CLLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
        centerMapOnLocation(location: locValue)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        constraintRotate(orientation: UIDevice.current.orientation.isLandscape)
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return readListFile().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if !UIDevice.current.orientation.isLandscape{
//            return tableView.frame.height / (tableView.frame.height / 40).rounded(.down)
//        } else {
//            return 0
//        }
        return tableView.frame.height / (tableView.frame.height / 40).rounded(.down)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0){
            if CLLocationManager.locationServicesEnabled() {
                distances = findDistance()
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell", for: indexPath) as! MainTableViewCell
        if CLLocationManager.locationServicesEnabled() {
            cell.NameL.text = distances[indexPath.row][1]
        } else {
            cell.NameL.text = "NULL"
        }
        if (distances[indexPath.row][4] != ""){
            cell.DistL.text = String(round(Double(distances[indexPath.row][4])!) / 1000) + " km"
        } else {
            cell.DistL.text = ""
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        self.hidesBottomBarWhenPushed = true
        if segue.identifier == "displayobj" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! ObjectViewController
                destinationController.Title = distances[indexPath.row][1]
                destinationController.ID = Int(distances[indexPath.row][0])!
                destinationController.CurrentPosition = CLLocationCoordinate2DMake(Double(distances[indexPath.row][2])!, Double(distances[indexPath.row][3])!)
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "displayobj" {
//            if let indexPath = tableView.indexPathForSelectedRow {
//                let destinationPart = segue.destination as! IntermediateViewController
//                let destinationController = destinationPart.topViewController as! ObjectViewController
//                destinationController.Title = distances[indexPath.row][1]
//                destinationController.Description = distances[indexPath.row][4]
//                destinationController.Image = distances[indexPath.row][7]
//                destinationController.ID = Int(distances[indexPath.row][0])!
//                destinationController.CurrentPosition = CLLocationCoordinate2DMake(Double(distances[indexPath.row][2])!, Double(distances[indexPath.row][3])!)
//                self.hidesBottomBarWhenPushed = true
//            }
//        }
//    }

}
