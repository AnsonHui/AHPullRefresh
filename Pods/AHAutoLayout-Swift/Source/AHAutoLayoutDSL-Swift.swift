//
//  AHAutoLayoutDSK-Swift.swift
//  AnsonHui
//
//  Created by AnsonHui on 16/09/19.
//  Copyright (c) 2015 AnsonHui. All rights reserved.
//

import UIKit

let UILayoutPriorityDefaultHigh = 750 as Float
let UILayoutPriorityDefaultLow = 250 as Float
let UILayoutPriorityRequired = 1000 as Float

extension NSLayoutConstraint {
    public convenience init(item view1: AnyObject, attribute attr1: NSLayoutAttribute, relatedBy relation: NSLayoutRelation, toItem view2: AnyObject?, attribute attr2: NSLayoutAttribute, multiplier: CGFloat, constant c: CGFloat, priority: UILayoutPriority) {
        self.init(item: view1, attribute: attr1, relatedBy: relation, toItem: view2, attribute: attr2, multiplier: multiplier, constant: c)
        self.priority = priority
    }
}

open class NSLayoutConstraintBuilder {
    
    open class DestinationComponent {
        fileprivate var component: Component!
        var multiplier: CGFloat = 1
        var constant: CGFloat = 0
        
        public init(component: Component) {
            self.component = component
        }
        
        open func setConstant(_ constant: CGFloat) -> Self {
            self.constant = constant
            return self
        }
        
        open func setMultiplier(_ multiplier: CGFloat) -> Self {
            self.multiplier = multiplier
            return self
        }
    }
    
    open class Component {
        fileprivate var view: UIView?
        fileprivate var attribute: NSLayoutAttribute!
        
        public init(view: UIView?, attribute: NSLayoutAttribute) {
            self.view = view
            self.attribute = attribute
        }
        
        fileprivate func createBuilder(_ component: DestinationComponent, relation: NSLayoutRelation) -> NSLayoutConstraintBuilder {
            let builder = NSLayoutConstraintBuilder()
            builder.sourceComponent = self
            builder.destinationComponent = component
            builder.relation = relation
            return builder
        }
        
        open func equal(_ component: DestinationComponent) -> NSLayoutConstraintBuilder {
            return createBuilder(component, relation: .equal)
        }
        
        open func greaterThanOrEqual(_ component: DestinationComponent) -> NSLayoutConstraintBuilder {
            return createBuilder(component, relation: .greaterThanOrEqual)
        }
        
        open func lessThanOrEqual(_ component: DestinationComponent) -> NSLayoutConstraintBuilder {
            return createBuilder(component, relation: .lessThanOrEqual)
        }
        
        open func equal(_ constant: CGFloat) -> NSLayoutConstraintBuilder {
            return createBuilder(DestinationComponent(component: Component(view: nil, attribute: .notAnAttribute)).setConstant(constant), relation: .equal)
        }
        
        open func greaterThanOrEqual(_ constant: CGFloat) -> NSLayoutConstraintBuilder {
            return createBuilder(DestinationComponent(component: Component(view: nil, attribute: .notAnAttribute)).setConstant(constant), relation: .greaterThanOrEqual)
        }
        
        open func lessThanOrEqual(_ constant: CGFloat) -> NSLayoutConstraintBuilder {
            return createBuilder(DestinationComponent(component: Component(view: nil, attribute: .notAnAttribute)).setConstant(constant), relation: .lessThanOrEqual)
        }
    }
    
    fileprivate var sourceComponent: Component!
    fileprivate var relation: NSLayoutRelation!
    fileprivate var destinationComponent: DestinationComponent!
    fileprivate var layoutPrority: UILayoutPriority = UILayoutPriorityRequired

    
    open func setPriority(_ priority: UILayoutPriority) -> Self {
        self.layoutPrority = priority
        return self
    }
    
    open func build() -> NSLayoutConstraint {
        return NSLayoutConstraint(item: sourceComponent.view!, attribute: sourceComponent.attribute, relatedBy: relation, toItem: destinationComponent.component.view, attribute: destinationComponent.component.attribute, multiplier: destinationComponent.multiplier, constant: destinationComponent.constant, priority: layoutPrority)
    }
}

extension UIView {
    fileprivate func attribute(_ attribute: NSLayoutAttribute) -> NSLayoutConstraintBuilder.Component {
        return NSLayoutConstraintBuilder.Component(view: self, attribute: attribute)
    }
    
    public var left: NSLayoutConstraintBuilder.Component {
        get {
            return attribute(.left)
        }
    }
    
    public var right: NSLayoutConstraintBuilder.Component {
        get {
            return attribute(.right)
        }
    }
    
    public var top: NSLayoutConstraintBuilder.Component {
        get {
            return attribute(.top)
        }
    }
    
    public var bottom: NSLayoutConstraintBuilder.Component {
        get {
            return attribute(.bottom)
        }
    }
    
    public var centerX: NSLayoutConstraintBuilder.Component {
        get {
            return attribute(.centerX)
        }
    }
    
    public var centerY: NSLayoutConstraintBuilder.Component {
        get {
            return attribute(.centerY)
        }
    }
    
    public var width: NSLayoutConstraintBuilder.Component {
        get {
            return attribute(.width)
        }
    }
    
    public var height: NSLayoutConstraintBuilder.Component {
        get {
            return attribute(.height)
        }
    }
    
    public var leading: NSLayoutConstraintBuilder.Component {
        get {
            return attribute(.leading)
        }
    }
    
    public var trailing: NSLayoutConstraintBuilder.Component {
        get {
            return attribute(.trailing)
        }
    }
    
    public var baseline: NSLayoutConstraintBuilder.Component {
        get {
            return attribute(.lastBaseline)
        }
    }
    
    //TODO: add other iOS 8 only attributes and limit with api version when Swift 1.2 releases 
}

// Usage
// sourceView.sourceAttribute = destinationView.destinationAttribute (*|/) multiplier (+|-) constant
// * Support chain operions and will follow operation precedence to re-calculate multipliers and constaints
public func == (component: NSLayoutConstraintBuilder.Component, destinationComponent: NSLayoutConstraintBuilder.DestinationComponent) -> NSLayoutConstraint {
    let builder =  NSLayoutConstraintBuilder()
    builder.sourceComponent = component
    builder.destinationComponent = destinationComponent
    builder.relation = .equal
    return builder.build()
}

public func == (component: NSLayoutConstraintBuilder.Component, destinationComponent: NSLayoutConstraintBuilder.Component) -> NSLayoutConstraint {
    let builder =  NSLayoutConstraintBuilder()
    builder.sourceComponent = component
    builder.destinationComponent = NSLayoutConstraintBuilder.DestinationComponent(component: destinationComponent)
    builder.relation = .equal
    return builder.build()
}

public func == (component: NSLayoutConstraintBuilder.Component, constant: CGFloat) -> NSLayoutConstraint {
    let builder =  NSLayoutConstraintBuilder()
    builder.sourceComponent = component
    builder.destinationComponent = NSLayoutConstraintBuilder.DestinationComponent(component: NSLayoutConstraintBuilder.Component(view: nil, attribute: .notAnAttribute)).setConstant(constant)
    builder.relation = .equal
    return builder.build()
}

public func >= (component: NSLayoutConstraintBuilder.Component, destinationComponent: NSLayoutConstraintBuilder.DestinationComponent) -> NSLayoutConstraint {
    let builder =  NSLayoutConstraintBuilder()
    builder.sourceComponent = component
    builder.destinationComponent = destinationComponent
    builder.relation = .greaterThanOrEqual
    return builder.build()
}

public func >= (component: NSLayoutConstraintBuilder.Component, destinationComponent: NSLayoutConstraintBuilder.Component) -> NSLayoutConstraint {
    let builder =  NSLayoutConstraintBuilder()
    builder.sourceComponent = component
    builder.destinationComponent = NSLayoutConstraintBuilder.DestinationComponent(component: destinationComponent)
    builder.relation = .greaterThanOrEqual
    return builder.build()
}

public func >= (component: NSLayoutConstraintBuilder.Component, constant: CGFloat) -> NSLayoutConstraint {
    let builder =  NSLayoutConstraintBuilder()
    builder.sourceComponent = component
    builder.destinationComponent = NSLayoutConstraintBuilder.DestinationComponent(component: NSLayoutConstraintBuilder.Component(view: nil, attribute: .notAnAttribute)).setConstant(constant)
    builder.relation = .greaterThanOrEqual
    return builder.build()
}

public func <= (component: NSLayoutConstraintBuilder.Component, destinationComponent: NSLayoutConstraintBuilder.DestinationComponent) -> NSLayoutConstraint {
    let builder =  NSLayoutConstraintBuilder()
    builder.sourceComponent = component
    builder.destinationComponent = destinationComponent
    builder.relation = .lessThanOrEqual
    return builder.build()
}

public func <= (component: NSLayoutConstraintBuilder.Component, destinationComponent: NSLayoutConstraintBuilder.Component) -> NSLayoutConstraint {
    let builder =  NSLayoutConstraintBuilder()
    builder.sourceComponent = component
    builder.destinationComponent = NSLayoutConstraintBuilder.DestinationComponent(component: destinationComponent)
    builder.relation = .lessThanOrEqual
    return builder.build()
}

public func <= (component: NSLayoutConstraintBuilder.Component, constant: CGFloat) -> NSLayoutConstraint {
    let builder =  NSLayoutConstraintBuilder()
    builder.sourceComponent = component
    builder.destinationComponent = NSLayoutConstraintBuilder.DestinationComponent(component: NSLayoutConstraintBuilder.Component(view: nil, attribute: .notAnAttribute)).setConstant(constant)
    builder.relation = .lessThanOrEqual
    return builder.build()
}

public func * (component: NSLayoutConstraintBuilder.Component, multiplier: CGFloat) -> NSLayoutConstraintBuilder.DestinationComponent {
    return NSLayoutConstraintBuilder.DestinationComponent(component: component).setMultiplier(multiplier)
}

public func * (component: NSLayoutConstraintBuilder.DestinationComponent, multiplier: CGFloat) -> NSLayoutConstraintBuilder.DestinationComponent {
    return component.setMultiplier(component.multiplier * multiplier).setConstant(component.constant * multiplier)
}

public func / (component: NSLayoutConstraintBuilder.Component, multiplier: CGFloat) -> NSLayoutConstraintBuilder.DestinationComponent {
    return NSLayoutConstraintBuilder.DestinationComponent(component: component).setMultiplier( 1.0 / multiplier)
}

public func / (component: NSLayoutConstraintBuilder.DestinationComponent, multiplier: CGFloat) -> NSLayoutConstraintBuilder.DestinationComponent {
    return component.setMultiplier(component.multiplier / multiplier).setConstant(component.constant / multiplier)
}

public func + (component: NSLayoutConstraintBuilder.Component, constant: CGFloat) -> NSLayoutConstraintBuilder.DestinationComponent {
    return NSLayoutConstraintBuilder.DestinationComponent(component: component).setConstant(constant)
}

public func + (component: NSLayoutConstraintBuilder.DestinationComponent, constant: CGFloat) -> NSLayoutConstraintBuilder.DestinationComponent {
    return component.setConstant(component.constant + constant)
}

public func - (component: NSLayoutConstraintBuilder.Component, contant: CGFloat) -> NSLayoutConstraintBuilder.DestinationComponent {
    return NSLayoutConstraintBuilder.DestinationComponent(component: component).setConstant(-contant)
}

public func - (component: NSLayoutConstraintBuilder.DestinationComponent, constant: CGFloat) -> NSLayoutConstraintBuilder.DestinationComponent {
    return component.setConstant(component.constant - constant)
}


precedencegroup AutoLayoutSwiftAdditivePrecedence {
    associativity: left
    lowerThan: ComparisonPrecedence
}

// Help Function for adding NSLayoutConstaint
// => dont change c=priority, default is UILayoutPriorityRequired
// ~~> change priority to UILayoutPriorityDefaultHigh(750)
// ~~~> change priority to UILayoutPriorityDefaultLow(250)
// Operations will return view itself
// we set precedence lower than ComparisonPrecedence，so that it will be lower than ==, <=, >=
// reference swift operation precedence from http://nshipster.com/swift-operators/
infix operator =>: AutoLayoutSwiftAdditivePrecedence
@discardableResult
public func => (view: UIView, constaint: NSLayoutConstraint) -> UIView {
    view.addConstraint(constaint)
    return view
}

infix operator ~~>: AutoLayoutSwiftAdditivePrecedence
@discardableResult
public func ~~> (view: UIView, constaint: NSLayoutConstraint) -> UIView  {
    constaint.priority = UILayoutPriorityDefaultHigh
    view.addConstraint(constaint)
    return view
}

infix operator ~~~>: AutoLayoutSwiftAdditivePrecedence
@discardableResult
public func ~~~> (view: UIView, constaint: NSLayoutConstraint) -> UIView  {
    constaint.priority = UILayoutPriorityDefaultLow
    view.addConstraint(constaint)
    return view
}
