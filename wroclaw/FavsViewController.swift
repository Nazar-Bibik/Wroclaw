//
//  MainViewController.swift
//  wroclaw
//
//  Created by Nazar on 25/03/2019.
//  Copyright © 2019 N&M 2016. All rights reserved.
//

import UIKit
import CoreLocation


class FavsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var favs = [[String]]()
    
    

    func readListFile() -> [[String]]{
        let defaults = UserDefaults.standard
        let path = Bundle.main.path(forResource: "List", ofType: "txt")
        let content = FileManager().contents(atPath: path!)
        let textfile = String(data: content!, encoding: String.Encoding.utf8)
        let list = textfile?.components(separatedBy: "\n")
        var listarray = [[String]]()
        for n in 0...list!.count-2 {
            let readline = list![n].components(separatedBy: "/")
            let consecutive = defaults.string(forKey: "ID" + String(Int(readline[0])!))
            if (consecutive != nil){
                listarray.append(readline)
            }
        }
        return listarray
    }
    //

    //
    
    
    override func viewDidLoad() {
        navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationItem.title = "Favorites"
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let defaults = UserDefaults.standard
        let IDC = defaults.string(forKey: "IDC")
        if (IDC == nil) || (Int(IDC!)! == 0){
            return 1
        } else {
            return Int(IDC!)!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / (tableView.frame.height / 60).rounded(.down)
//        return tableView.frame.height / 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0){
                favs = readListFile()
        }
        
        if (favs.count != 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell", for: indexPath) as! MainTableViewCell
            cell.NameL.text = favs[indexPath.row][1]
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "emptycell", for: indexPath)
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        self.hidesBottomBarWhenPushed = true
        if (segue.identifier == "favobj") {
            if let indexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: indexPath, animated: false)
                let destinationController = segue.destination as! ObjectViewController
                destinationController.Title = favs[indexPath.row][1]
//                destinationController.Description = favs[indexPath.row][4]
//                destinationController.Image = favs[indexPath.row][7]
                destinationController.ID = Int(favs[indexPath.row][0])!
                destinationController.CurrentPosition = CLLocationCoordinate2DMake(Double(favs[indexPath.row][2])!, Double(favs[indexPath.row][3])!)
            }
        }
    }
    
    
}
