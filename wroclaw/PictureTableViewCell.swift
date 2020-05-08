//
//  PictureTableViewCell.swift
//  wroclaw
//
//  Created by Nazar on 20/05/2019.
//  Copyright © 2019 N&M 2016. All rights reserved.
//

import UIKit

class PictureTableViewCell: UITableViewCell {
    
    @IBOutlet var Picture: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
