//
//  UIColor+AHExtension.swift
//  Meepoo
//
//  Created by AnsonHui on 12/11/15.
//  Copyright © 2015 com.fantasy.dycategories. All rights reserved.
//

import UIKit

public extension UIColor {

    public convenience init(argb: Int64) {
        let red = CGFloat((argb & 0x00ff0000) >> 16) / 255.0
        let green = CGFloat((argb & 0x0000ff00) >> 8) / 255.0
        let blue = CGFloat(argb & 0x000000ff) / 255.0
        let alpha = CGFloat(argb >> 24) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
