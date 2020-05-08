//////
//////  SearchViewController.swift
//////  wroclaw
//////
//////  Created by Nazar on 19/05/2019.
//////  Copyright © 2019 N&M 2016. All rights reserved.
//////
////
import UIKit
import CoreLocation

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {



    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!

    var searchActive : Bool = false
    var data = [[String]]()
    var filteredTableData = [[String]]()


    func readListFile() -> [[String]]{

        let textlist = String(data: FileManager().contents(atPath: Bundle.main.path(forResource: "List", ofType: "txt")!)!, encoding: String.Encoding.utf8)
//        let textdesc = String(data: FileManager().contents(atPath: Bundle.main.path(forResource: "Description", ofType: "txt")!)!, encoding: String.Encoding.utf8)

        let list = textlist?.components(separatedBy: "\n")
//        let desc = textdesc?.components(separatedBy: "\n")
        var listarray = [[String]]()
//        let descarray = desc.map( { $0.map( { $0.components(separatedBy: "/") } ) } )
        for n in 1...list!.count-2 {
            var readline = list![n].components(separatedBy: "/")
//            readline[4] = descarray!.first(where: { $0[0] == readline[0] })![1] + " " + readline[1]
            readline[4] = readline[1]
            listarray.append(readline)
        }
        listarray = listarray.sorted { $0[1] < $1[1] }
        return listarray
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.text = nil
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)

        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
//

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

//        filteredTableData = data.filter({ (text) -> Bool in
//            let tmp: NSString = text[1] as NSString
//            let range = tmp.rangeOfString(searchText, options: NSString.CompareOptions.CaseInsensitiveSearch)
//            return range.location != NSNotFound
//        })
        filteredTableData = data.filter({ (text) -> Bool in
            let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchText)
            let array = (text as NSArray).filtered(using: searchPredicate)
            return array.count != 0
        })

        searchActive = searchText.count != 0;
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive && filteredTableData.count != 0 {
            return filteredTableData.count
        }
        if searchActive && filteredTableData.count == 0{
            return 1
        }
        return data.count
    }
//
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / (tableView.frame.height / 40).rounded(.down)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if filteredTableData.count == 0 && searchActive && searchBar.text?.count != 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptycell", for: indexPath)
            return cell
        }
        if searchActive && filteredTableData.count != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell", for: indexPath) as! MainTableViewCell
            cell.NameL.text = filteredTableData[indexPath.row][1]
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell", for: indexPath) as! MainTableViewCell
        cell.NameL.text = data[indexPath.row][1]
        return cell
    }

//    func updateSearchResults(for searchController: UISearchController) {
//        filteredTableData.removeAll(keepingCapacity: false)
//
//        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
//        let array = (data as NSArray).filtered(using: searchPredicate)
//        filteredTableData = array as! [[String]]
//
//        self.tableView.reloadData()
//    }

//
    override func viewDidLoad() {
        self.navigationItem.title = "Search"
        data = readListFile()
        searchBar.delegate = self
        super.viewDidLoad()
        self.tableView.reloadData()

        // Do any additional setup after loading the view.
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        self.hidesBottomBarWhenPushed = true
        if segue.identifier == "searchobj" {
            if let indexPath = tableView.indexPathForSelectedRow {
                var send = [String]()
                if searchActive && filteredTableData.count != 0{
                    send = filteredTableData[indexPath.row]
                } else {
                    send = data[indexPath.row]
                }
                let destinationController = segue.destination as! ObjectViewController
                destinationController.Title = send[1]
                destinationController.ID = Int(send[0])!
                destinationController.CurrentPosition = CLLocationCoordinate2DMake(Double(send[2])!, Double(send[3])!)
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
}


