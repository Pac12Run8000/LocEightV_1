//
//  LocEightButton.swift
//  LocEightV_1
//
//  Created by Michelle Grover on 5/5/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//
import Foundation
import UIKit

@IBDesignable

class LocEightButton: UIButton {
    
    @IBInspectable var cornerRadius:CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth:CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var masksToBounds:Bool = true {
        didSet {
            self.layer.masksToBounds = masksToBounds
        }
    }
    
    @IBInspectable var borderColor:UIColor = UIColor.black {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
  
    
    
    
    

   

}
