//
//  searchHashtagsTableViewCell.swift
//  TIK TIK
//
//  Created by Mac on 07/11/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class searchHashtagsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    
    @IBOutlet weak var btnFav: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
