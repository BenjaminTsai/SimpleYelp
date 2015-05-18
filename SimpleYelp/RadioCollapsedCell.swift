//
//  RadioCollapsedCell.swift
//  SimpleYelp
//
//  Created by Benjamin Tsai on 5/17/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import UIKit

class RadioCollapsedCell: UITableViewCell {
    
    @IBOutlet weak var radioCollapsedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
