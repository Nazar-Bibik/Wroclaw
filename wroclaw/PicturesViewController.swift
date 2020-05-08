//
//  PicturesViewController.swift
//  wroclaw
//
//  Created by Nazar on 20/05/2019.
//  Copyright © 2019 N&M 2016. All rights reserved.
//

import UIKit

class PicturesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var Image = [String]()
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Image.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell", for: indexPath) as! PictureTableViewCell
        cell.Picture.image = UIImage(named: Image[indexPath.row])
        return cell
    }
    

    override func viewDidLoad() {
//        tableView.interactions = Image.count != 1
        tableView.isScrollEnabled = Image.count != 1
        tableView.isPagingEnabled = Image.count != 1
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
