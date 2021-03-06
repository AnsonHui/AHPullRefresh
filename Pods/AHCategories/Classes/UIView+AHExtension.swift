//
//  UIView+AHExtension.swift
//  Meepoo
//
//  Created by AnsonHui on 2/17/16.
//  Copyright © 2015 com.fantasy.ahcategories. All rights reserved.
//

import UIKit

public extension UIView {

    public var ahLeft: CGFloat {
        get {
            return self.frame.minX
        }
        set {
            var origin = self.frame.origin
            origin.x = newValue
            self.frame.origin = origin
        }
    }

    public var ahRight: CGFloat {
        get {
            return self.frame.maxX
        }
        set {
            var origin = self.frame.origin
            origin.x = newValue - self.frame.size.width
            self.frame.origin = origin
        }
    }

    public var ahTop: CGFloat {
        get {
            return self.frame.minY
        }
        set {
            var origin = self.frame.origin
            origin.y = newValue
            self.frame.origin = origin
        }
    }

    public var ahBottom: CGFloat {
        get {
            return self.frame.maxY
        }
        set {
            var origin = self.frame.origin
            origin.y = newValue - self.frame.size.height
            self.frame.origin = origin
        }
    }

    public var ahWidth: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            var size = self.frame.size
            size.width = newValue
            self.frame.size = size
        }
    }

    public var ahHeight: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            var size = self.frame.size
            size.height = newValue
            self.frame.size = size
        }
    }

    public var ahCenterX: CGFloat {
        get {
            return self.center.x
        }
        set {
            self.center.x = newValue
        }
    }

    public var ahCenterY: CGFloat {
        get {
            return self.center.y
        }
        set {
            self.center.y = newValue
        }
    }

    public var ahSize: CGSize {
        get {
            return self.bounds.size
        }
        set {
            self.frame.size = CGSize(width: newValue.width, height: newValue.height)
        }
    }

    public func screenFrame() -> CGRect {
        var superView: UIView?
        superView = self.superview
        var rect = self.frame
        while (superView?.superview != nil) {
            rect = superView!.convert(rect, to: superView!.superview!)
            superView = superView!.superview
        }
        return rect
    }
}
