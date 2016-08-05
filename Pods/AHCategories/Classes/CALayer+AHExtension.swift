//
//  CALayer+AHExtension.swift
//  Meepoo
//
//  Created by 黄辉 on 7/14/16.
//  Copyright © 2016 com.meizu.flyme. All rights reserved.
//

import UIKit

public extension CALayer {

    var ahLeft: CGFloat {
        get {
            return CGRectGetMinX(self.frame)
        }
        set {
            var origin = self.frame.origin
            origin.x = newValue
            self.frame.origin = origin
        }
    }

    var ahRight: CGFloat {
        get {
            return CGRectGetMaxX(self.frame)
        }
        set {
            var origin = self.frame.origin
            origin.x = newValue - self.frame.size.width
            self.frame.origin = origin
        }
    }

    var ahTop: CGFloat {
        get {
            return CGRectGetMinY(self.frame)
        }
        set {
            var origin = self.frame.origin
            origin.y = newValue
            self.frame.origin = origin
        }
    }

    var ahBottom: CGFloat {
        get {
            return CGRectGetMaxY(self.frame)
        }
        set {
            var origin = self.frame.origin
            origin.y = newValue - self.frame.size.height
            self.frame.origin = origin
        }
    }

    var ahWidth: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            var size = self.frame.size
            size.width = newValue
            self.frame.size = size
        }
    }

    var ahHeight: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            var size = self.frame.size
            size.height = newValue
            self.frame.size = size
        }
    }

    var ahCenterX: CGFloat {
        get {
            return self.frame.origin.x + self.bounds.size.width / 2
        }
        set {
            var tmpFrame = self.frame
            tmpFrame.origin.x = newValue - self.bounds.size.width / 2
            self.frame = tmpFrame
        }
    }

    var ahCenterY: CGFloat {
        get {
            return self.frame.origin.y + self.bounds.height / 2
        }
        set {
            var tmpFrame = self.frame
            tmpFrame.origin.y = newValue - self.bounds.size.height / 2
            self.frame = tmpFrame
        }
    }

    var ahSize: CGSize {
        get {
            return self.bounds.size
        }
        set {
            self.frame.size = CGSizeMake(newValue.width, newValue.height)
        }
    }

}