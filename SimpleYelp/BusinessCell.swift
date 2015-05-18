//
//  BusinessCell.swift
//  SimpleYelp
//
//  Created by Benjamin Tsai on 5/12/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import UIKit
import Alamofire

class BusinessCell: UITableViewCell {

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var ratingImageView: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    
    var business: Business! {
        didSet {
            if let businessImageUrl = business.imageURL {
                loadImage(fromUrl: businessImageUrl, forImage: thumbImageView)
            }
            if let ratingImageUrl = business.ratingImageURL {
                loadImage(fromUrl: ratingImageUrl, forImage: ratingImageView)
            }
            
            nameLabel.text = business.name
            categoriesLabel.text = business.categories
            addressLabel.text = business.address
            reviewCountLabel.text = "\(business.reviewCount!) Reviews"
            distanceLabel.text = business.distance

            // without this multi line label doesn't always expand correctly
            // despite setting the compression resistance correctly
            self.layoutIfNeeded()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        thumbImageView.layer.cornerRadius = 3
        thumbImageView.clipsToBounds = true
        
        // necessary?
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // necessary? for rotation?
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // Rolling my own as Haneke seems to have some bugs
    func loadImage(fromUrl url: NSURL, forImage image: UIImageView) {
        Alamofire.request(.GET, url, parameters: nil).response { (request, response, data, error) in
            image.image = UIImage(data: data! as! NSData)
        }
    }

}
