//
//  ColorPalette.swift
//  LocEightV_1
//
//  Created by Michelle Grover on 5/4/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    static let pink = UIColor.colorFromHex("F25CA2")
    static let blue1 = UIColor.colorFromHex("0433BF")
    static let blue2 = UIColor.colorFromHex("032CA6")
    static let blue3 = UIColor.colorFromHex("021859")
    static let cyanLightBlue = UIColor.colorFromHex("0B9ED9")
    
    
    static func colorFromHex(_ hex:String) -> UIColor {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (hexString.hasPrefix("#")) {
            hexString.remove(at: hexString.startIndex)
        }
        
        if (hexString.count != 6) {
            return UIColor.black
        }
        
        var rgb:UInt32 = 0
        Scanner(string: hexString).scanHexInt32(&rgb)
        
        return UIColor.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgb & 0x0000FF) / 255.0, alpha: 1.0)
        
    }
    
    
}
