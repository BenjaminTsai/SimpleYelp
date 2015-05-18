//
//  RadioCell.swift
//  SimpleYelp
//
//  Created by Benjamin Tsai on 5/16/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import UIKit

class RadioCell: UITableViewCell {

    @IBOutlet weak var radioLabel: UILabel!
    @IBOutlet weak var checkboxImage: UIImageView!
    
    private var radioGroupName: String?
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSLog("Deinit")
    }
    
    func setRadioGroup(name: String) {
        if radioGroupName != nil {
            unsubscribe()
            radioGroupName = nil
        }
        radioGroupName = name
        
        // [unowned self] before usingBlock giving problems, why?
        NSNotificationCenter.defaultCenter().addObserverForName(name,
            object: nil,
            queue: nil,
            usingBlock: { (notification: NSNotification!) in
                let sender = notification.object as! RadioCell
                
                if sender != self {
                    self.checkboxImage.image = UIImage(named: "checkbox_unchecked")
                }
            }
        )
    }

    func setCheckbox(isChecked: Bool) {
        if isChecked {
            self.checkboxImage.image = UIImage(named: "checkbox_checked")
        } else {
            self.checkboxImage.image = UIImage(named: "checkbox_unchecked")
        }
    }
    
    func onSelect() {
        NSNotificationCenter.defaultCenter().postNotificationName(radioGroupName!, object: self)
        setCheckbox(true)
    }
    
    private func unsubscribe() {
        NSNotificationCenter.defaultCenter().removeObserver(self)// , name: radioGroupName, object: nil)
    }
}
