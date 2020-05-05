//
//  LocEightButton.swift
//  LocEightV_1
//
//  Created by Michelle Grover on 5/5/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit

class LocEightButton: UIButton {
    
    override func awakeFromNib() {
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 9
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    
    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
