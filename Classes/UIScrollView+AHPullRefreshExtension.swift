//
//  UIScrollView+AHPullRefreshExtension.swift
//  Meepoo
//
//  Created by 黄辉 on 05/31/16.
//  Copyright © 2015 com.fantasy.ahpullrefresh. All rights reserved.
//

import UIKit
import AHCategories

private var kPointerRefreshContentOffsetChangedContext = 3
private var kPointerRefreshContentChangedContextExist = 30
private var kPointerRefreshContentSizeChangedContext = 300

// 下拉刷新
private var kPointerTopRefreshViewForState = 0
private var kPointerShowTopRefresh = 1
private var kPointerTopRefreshBlock = 2
private var kPointerTopRefreshState = 4
private var kPointerTopRefreshCurrentCustomView = 5

// 上拉刷新
private var kPointerBottomRefreshViewForState = 10
private var kPointerShowBottomRefresh = 11
private var kPointerBottomRefreshBlock = 12
private var kPointerBottomRefreshState = 14
private var kPointerBottomRefreshCurrentCustomView = 15
private var kPointerBottomRefreshMode = 16 // 手动上拉刷新 OR 自动上拉刷新

private var kTimeEndRefreshAnimation: NSTimeInterval = 0.3

// 配置
public class AHPullRefreshConfig {
    /// 下拉刷新的高度
    public static var AHTopRefreshViewHeight: CGFloat = 70.0

    /// 上拉刷新的高度
    public static var AHBottomRefreshViewHeight: CGFloat = 60.0
}

private class BlockObject {
    var block: dispatch_block_t!
}

// 下拉刷新状态
public enum AHTopRefreshViewState: Int {
    case None      = -1 // 没有状态
    case Stopped   = 0  // 停止
    case Triggered = 1  // 提示松手
    case Loading   = 2  // 加载中
    case StateAll  = 5
}

// 上拉刷新状态
public enum AHBottomRefreshViewState: Int {
    case None      = -1 // 没有状态
    case Stopped   = 0  // 停止
    case Triggered = 1  // 提示松手
    case Loading   = 2  // 加载中
    case NoMore    = 5  // 没有更多
    case Error     = 6  // 加载失败
    case StateAll  = 7
}

public enum AHBottomRefreshMode: Int {
    case AutoRefresh   = 1  // 自动刷新
    case ManualRefresh = 2  // 手动刷新
}

// MARK: - 下拉刷新扩展
public extension UIScrollView {

    /**
     * 下拉刷新的各个状态的View
     */
    private var topRefreshViewsForState: NSMutableDictionary! {
        get {
            var customViewArray = objc_getAssociatedObject(self, &kPointerTopRefreshViewForState) as? NSMutableDictionary
            
            if customViewArray == nil {
                customViewArray = NSMutableDictionary()
                objc_setAssociatedObject(self, &kPointerTopRefreshViewForState, customViewArray,  objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
            return customViewArray!
        }
        set {
        }
    }

    /**
     * 当前显示的CustomView
     */
    private var currentTopRefreshCustomView: UIView? {
        get {
            return objc_getAssociatedObject(self, &kPointerTopRefreshCurrentCustomView) as? UIView
        }
        set {
            if let newValue = newValue {
                newValue.ahTop = -AHPullRefreshConfig.AHTopRefreshViewHeight - self.contentInset.top
            }
            objc_setAssociatedObject(self, &kPointerTopRefreshCurrentCustomView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    /**
     * 当前状态
     */
    private var topRefreshState: AHTopRefreshViewState! {
        get {
            let pullStateNumber = objc_getAssociatedObject(self, &kPointerTopRefreshState) as? NSNumber
            
            if let pullState = pullStateNumber {
                return AHTopRefreshViewState(rawValue: pullState.integerValue)
            } else {
                objc_setAssociatedObject(self, &kPointerTopRefreshState, NSNumber(integer: AHTopRefreshViewState.Stopped.rawValue), objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
                return AHTopRefreshViewState.Stopped
            }
        }
        set {
            objc_setAssociatedObject(self, &kPointerTopRefreshState, NSNumber(integer: newValue.rawValue), objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }

    /**
     * 是否要显示下拉刷新
     */
    public var showTopRefresh: Bool {
        get {
            var number = (objc_getAssociatedObject(self, &kPointerShowTopRefresh) as? NSNumber)
            if let obj = number {
                return obj.boolValue
            } else {
                number = NSNumber(bool: false)
                objc_setAssociatedObject(self, &kPointerShowTopRefresh, number, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
                return false
            }
        }
        set {
            objc_setAssociatedObject(self, &kPointerShowTopRefresh, NSNumber(bool: newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)

            if newValue {
                self.addObserver()
            } else {
                self.removeObserver()
            }
        }
    }

    /**
     * 刷新的回调
     */
    private var topRefreshBlock: dispatch_block_t! {
        get {
            if let blockObj = objc_getAssociatedObject(self, &kPointerTopRefreshBlock) as? BlockObject {
                return blockObj.block
            } else {
                return nil
            }
        }
        set {
            let blockObj = BlockObject()
            blockObj.block = newValue
            objc_setAssociatedObject(self, &kPointerTopRefreshBlock, blockObj, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    public func setCustomViewForTopRefreshState(view: UIView!, forState state: AHTopRefreshViewState) {
        let customViewArray = self.topRefreshViewsForState
        
        view.clipsToBounds = true
        customViewArray.setObject(view, forKey: "\(state.rawValue)")
    }

    /**
     * 添加下拉刷新的block
     */
    public func addTopRefreshBlock(refreshBlock: dispatch_block_t!) -> Void {
        self.topRefreshBlock = refreshBlock
        self.showTopRefresh = true
    }

    public func startTopRefreshAnimating() {

        self.topRefreshState = AHTopRefreshViewState.Loading

        // 移除旧的View
        if let currentView = self.currentTopRefreshCustomView {
            currentView.removeFromSuperview()
            self.currentTopRefreshCustomView = nil
        }
        // 更新View
        if let currentView = self.topRefreshViewsForState.objectForKey("\(AHTopRefreshViewState.Loading.rawValue)") as? UIView {
            self.addSubview(currentView)
            self.currentTopRefreshCustomView = currentView
        }

        self.setContentOffset(CGPointMake(0, -AHPullRefreshConfig.AHTopRefreshViewHeight - self.contentInset.top - 10), animated: true)

        self.topRefreshBlock()
    }

    public func stopTopRefreshAnimating() {

        // 延迟1.0秒
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.topRefreshState = AHTopRefreshViewState.None

            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                if self.contentOffset.y + self.contentInset.top < 0 {
                    self.contentOffset = CGPointMake(0, -self.contentInset.top)
                }

            }) { (completed) -> Void in

                if let view = self.currentTopRefreshCustomView { // 移除
                    view.setNeedsDisplay()
                    view.removeFromSuperview()
                    self.currentTopRefreshCustomView = nil
                }

                self.topRefreshState = AHTopRefreshViewState.Stopped
            }
        }
    }

    private func updateTopRefreshWithContentOffset(scrollViewContentOffset: CGPoint) {

        if self.topRefreshState == AHTopRefreshViewState.None {
            return
        }

        var contentOffset = scrollViewContentOffset

        if contentOffset.y >= 0 { // 没有往下拉，忽略
            if let currentView = self.currentTopRefreshCustomView {
                currentView.removeFromSuperview()
                self.currentTopRefreshCustomView = nil
            }
            self.topRefreshState = AHTopRefreshViewState.Stopped
            return
        }

        var pullState = self.topRefreshState

        if pullState.rawValue == AHTopRefreshViewState.Loading.rawValue { // 目前正在加载中
            if contentOffset.y > -AHPullRefreshConfig.AHTopRefreshViewHeight && !self.dragging {
                contentOffset.y = -AHPullRefreshConfig.AHTopRefreshViewHeight
                self.setContentOffset(CGPointMake(0, -AHPullRefreshConfig.AHTopRefreshViewHeight - self.contentInset.top), animated: false)
            }

            return
        }

        if self.dragging { // 正在拖拽
            if contentOffset.y < -AHPullRefreshConfig.AHTopRefreshViewHeight { // 提示放手刷新
                pullState = AHTopRefreshViewState.Triggered
            } else { // 普通
                pullState = AHTopRefreshViewState.Stopped
            }
        } else {
            if pullState.rawValue == AHTopRefreshViewState.Triggered.rawValue
                && contentOffset.y >= -AHPullRefreshConfig.AHTopRefreshViewHeight - 10
                && contentOffset.y <= -AHPullRefreshConfig.AHTopRefreshViewHeight { // 拖过分界线(10个像素误差)，放手
                
                pullState = AHTopRefreshViewState.Loading
                self.topRefreshBlock()
                
            } else if contentOffset.y > -AHPullRefreshConfig.AHTopRefreshViewHeight {
                pullState = AHTopRefreshViewState.Stopped
            }
        }

        // 移除当前显示的View
        if let currentView = self.currentTopRefreshCustomView {
            if pullState.rawValue != self.topRefreshState.rawValue { // 状态没变不处理
                currentView.removeFromSuperview()
                self.currentTopRefreshCustomView = nil
            }
        }

        // 更新显示的view
        if self.currentTopRefreshCustomView == nil {
            if let currentView = self.topRefreshViewsForState.objectForKey("\(pullState.rawValue)") as? UIView {
                self.addSubview(currentView)
                self.currentTopRefreshCustomView = currentView
                self.topRefreshState = pullState
            }
        }
    }
}

// MARK: - 上拉刷新扩展
public extension UIScrollView {

    /**
     * 下拉刷新的各个状态的View
     */
    private var bottomRefreshViewsForState: NSMutableDictionary! {
        get {
            var customViewArray = objc_getAssociatedObject(self, &kPointerBottomRefreshViewForState) as? NSMutableDictionary
            
            if customViewArray == nil {
                customViewArray = NSMutableDictionary()
                objc_setAssociatedObject(self, &kPointerBottomRefreshViewForState, customViewArray,  objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
            return customViewArray!
        }
        set {
        }
    }

    /**
     * 当前显示的CustomView
     */
    private var currentBottomRefreshCustomView: UIView? {
        get {
            if let view = objc_getAssociatedObject(self, &kPointerBottomRefreshCurrentCustomView) as? UIView {
                return view
            } else {
                return nil
            }
        }
        set {
            if let customView = newValue {
                if customView.userInteractionEnabled {
                    if customView.gestureRecognizers == nil || customView.gestureRecognizers!.count == 0 {
                        customView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.performBottomRefresh)))
                    }
                }
            }
            objc_setAssociatedObject(self, &kPointerBottomRefreshCurrentCustomView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    /**
     * 当前状态
     */
    private var bottomRefreshState: AHBottomRefreshViewState! {
        get {
            let pullStateNumber = objc_getAssociatedObject(self, &kPointerBottomRefreshState) as? NSNumber
            
            if let pullState = pullStateNumber {
                return AHBottomRefreshViewState(rawValue: pullState.integerValue)
            } else {
                objc_setAssociatedObject(self, &kPointerBottomRefreshState, NSNumber(integer: AHBottomRefreshViewState.None.rawValue), objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
                return AHBottomRefreshViewState.None
            }
        }
        set {
            objc_setAssociatedObject(self, &kPointerBottomRefreshState, NSNumber(integer: newValue.rawValue), objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }

    public var bottomRefreshMode: AHBottomRefreshMode! {
        get {
            if let mode = objc_getAssociatedObject(self, &kPointerBottomRefreshMode) as? NSNumber {
                return AHBottomRefreshMode(rawValue: mode.integerValue)
            } else {
                return AHBottomRefreshMode.AutoRefresh
            }
        }
        set {
            
        }
    }

    /**
     * 是否要显示下拉刷新
     */
    public var showBottomRefresh: Bool {
        get {
            var number = (objc_getAssociatedObject(self, &kPointerShowBottomRefresh) as? NSNumber)
            if let obj = number {
                return obj.boolValue
            } else {
                number = NSNumber(bool: false)
                objc_setAssociatedObject(self, &kPointerShowBottomRefresh, number, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
                return false
            }
        }
        set {
            objc_setAssociatedObject(self, &kPointerShowBottomRefresh, NSNumber(bool: newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
            
            if newValue {
                self.addObserver()
            } else {
                self.removeObserver()
            }
        }
    }

    /**
     * 刷新的回调
     */
    private var bottomRefreshBlock: dispatch_block_t? {
        get {
            if let blockObj = objc_getAssociatedObject(self, &kPointerBottomRefreshBlock) as? BlockObject {
                return blockObj.block
            } else {
                return nil
            }
        }
        set {
            let blockObj = BlockObject()
            blockObj.block = newValue
            objc_setAssociatedObject(self, &kPointerBottomRefreshBlock, blockObj, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    public func setCustomViewForBottomRefreshState(view: UIView!, forState state: AHBottomRefreshViewState) {
        let customViewArray = self.bottomRefreshViewsForState
        
        view.clipsToBounds = true
        customViewArray.setObject(view, forKey: "\(state.rawValue)")
    }

    /**
     * 添加上拉拉刷新的block
     */
    public func addBottomRefreshWithBlock(refreshBlock: dispatch_block_t!) {
        self.bottomRefreshBlock = refreshBlock
        self.showBottomRefresh = true
    }

    /**
     重置无更多数据的状态
     */
    public func bottomRefreshResetNoMoreDataState() {
        if self.bottomRefreshState == AHBottomRefreshViewState.NoMore {
            if let customView = self.currentBottomRefreshCustomView {
                customView.removeFromSuperview()
                self.currentBottomRefreshCustomView = nil
                
                // 设置底部的inset
                if self.contentInset.bottom > 0 {
                    var inset = self.contentInset
                    inset.bottom = 0
                    self.contentInset = inset
                }
            }
        }
        self.bottomRefreshState = AHBottomRefreshViewState.None

        // 恢复自动刷新
        self.bottomRefreshMode = AHBottomRefreshMode.AutoRefresh
    }

    public func startBottomRefresh() {
        if self.bottomRefreshState != AHBottomRefreshViewState.Loading {
            self.performBottomRefresh()
        }
    }

    public func stopBottomRefresh() {

        // 延迟0.5秒
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {

            // 延时
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.bottomRefreshState = AHBottomRefreshViewState.None
            }

            if let currentView = self.currentBottomRefreshCustomView { // 移除
                currentView.removeFromSuperview()
                self.currentBottomRefreshCustomView = nil
            }

            // 设置底部的inset
            if self.contentInset.bottom > 0 {
                UIView.animateWithDuration(kTimeEndRefreshAnimation, animations: {
                    var inset = self.contentInset
                    inset.bottom = 0
                    self.contentInset = inset
                })
            }
        }
    }

    public func stopBottomRefreshWithError() {
        // 延迟0.5秒
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {

            // 延时
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.bottomRefreshState = AHBottomRefreshViewState.None
            }

            if let currentView = self.currentBottomRefreshCustomView { // 移除
                currentView.removeFromSuperview()
                self.currentBottomRefreshCustomView = nil
            }

            if let customView = self.bottomRefreshViewsForState.objectForKey("\(AHBottomRefreshViewState.Error.rawValue)") as? UIView { // 有自定义View
                customView.ahTop = self.contentBottomTop()
                self.insertSubview(customView, atIndex: 0)
                self.currentBottomRefreshCustomView = customView
            } else { // 无自定义View
                // 设置底部的inset
                if self.contentInset.bottom > 0 {
                    UIView.animateWithDuration(kTimeEndRefreshAnimation, delay: 0.5, options: UIViewAnimationOptions.CurveLinear, animations: {

                        var inset = self.contentInset
                        inset.bottom = 0
                        self.contentInset = inset

                        }, completion: { (completed) in
                    })
                }
            }
        }
    }

    /**
     没有更多数据
     */
    public func stopBottomRefreshWithNoMoreState() {

        // 延迟0.5秒
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {

            if let customView = self.currentBottomRefreshCustomView {
                customView.removeFromSuperview()
                self.currentBottomRefreshCustomView = nil
            }

            if let customView = self.bottomRefreshViewsForState.objectForKey("\(AHBottomRefreshViewState.NoMore.rawValue)") as? UIView { // 有自定义View

                // 延时
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.bottomRefreshState = AHBottomRefreshViewState.NoMore
                }

                customView.ahTop = self.contentBottomTop()
                self.insertSubview(customView, atIndex: 0)
                self.currentBottomRefreshCustomView = customView

                // 设置底部的inset
                if self.contentInset.bottom > 0 {
                    UIView.animateWithDuration(kTimeEndRefreshAnimation, delay: 0.5, options: UIViewAnimationOptions.CurveLinear, animations: {

                        var inset = self.contentInset
                        inset.bottom = AHPullRefreshConfig.AHBottomRefreshViewHeight
                        self.contentInset = inset

                        }, completion: { (completed) in
                    })
                }

            } else {
                // 设置底部的inset
                if self.contentInset.bottom > 0 {
                    UIView.animateWithDuration(kTimeEndRefreshAnimation, delay: 0.5, options: UIViewAnimationOptions.CurveLinear, animations: {

                        var inset = self.contentInset
                        inset.bottom = 0
                        self.contentInset = inset

                        }, completion: { (completed) in
                    })
                }
            }

            // 禁止自动刷新
            self.bottomRefreshMode = AHBottomRefreshMode.ManualRefresh
        }
    }

    private func updateBottomRefreshWithContentOffset(scrollViewContentOffset: CGPoint) {

        let state = self.bottomRefreshState

        if state == AHBottomRefreshViewState.Loading { // 加载中
            return
        }

        var position = scrollViewContentOffset.y
        if self.contentSize.height > self.bounds.height {
            position = scrollViewContentOffset.y - (self.contentSize.height - self.bounds.height)
        }

        // 预加载 距离底部距离小于200 往前行进中 数据满屏 列表初始化完毕 自动加载模式可用
        if position > -200 && self.dragging && self.contentSize.height > self.bounds.height && self.bounds.height > 0 && self.bottomRefreshMode == AHBottomRefreshMode.AutoRefresh {
            self.performBottomRefresh()
            return
        }

        switch position {
        case 0 ..< AHPullRefreshConfig.AHBottomRefreshViewHeight: // 临界值之内
            if let customView = self.currentBottomRefreshCustomView {
                customView.removeFromSuperview()
                self.currentBottomRefreshCustomView = nil
            }
            if let customView = self.bottomRefreshViewsForState.objectForKey("\(AHBottomRefreshViewState.Stopped.rawValue)") as? UIView {
                self.currentBottomRefreshCustomView = customView
                customView.ahTop = self.contentBottomTop()
                self.insertSubview(customView, atIndex: 0)
            }

        case AHPullRefreshConfig.AHBottomRefreshViewHeight ..< AHPullRefreshConfig.AHBottomRefreshViewHeight + CGFloat.max: // 超过临界值
            if let customView = self.currentBottomRefreshCustomView {
                customView.removeFromSuperview()
                self.currentBottomRefreshCustomView = nil
            }
            if self.dragging { // 拖拽中
                if let customView = self.bottomRefreshViewsForState.objectForKey("\(AHBottomRefreshViewState.Triggered.rawValue)") as? UIView { // 提示松手
                    self.currentBottomRefreshCustomView = customView
                    customView.ahTop = self.contentBottomTop()
                    self.insertSubview(customView, atIndex: 0)
                }
            } else { // 松手
                self.performBottomRefresh()
            }

        default:
            break
        }
    }

    /**
     触发上拉刷新
     */
    public func performBottomRefresh() {
        if let customView = self.currentBottomRefreshCustomView {
            customView.removeFromSuperview()
            self.currentBottomRefreshCustomView = nil
        }

        if let customView = self.bottomRefreshViewsForState.objectForKey("\(AHBottomRefreshViewState.Loading.rawValue)") as? UIView { // 加载中
            self.bottomRefreshState = AHBottomRefreshViewState.Loading
            self.currentBottomRefreshCustomView = customView
            customView.ahTop = self.contentBottomTop()
            self.insertSubview(customView, atIndex: 0)
        }

        // 设置底部的inset
        var inset = self.contentInset
        inset.bottom = AHPullRefreshConfig.AHBottomRefreshViewHeight + max(self.bounds.height - self.contentSize.height, 0)
        self.contentInset = inset

        self.bottomRefreshBlock?() // 刷新
    }

    private func updateBottomRefreshWithContentSize(contentSize: CGSize) {
        if let customView = self.currentBottomRefreshCustomView {
            customView.ahTop = max(self.contentSize.height, self.bounds.height)
        }
    }

    private func contentBottomTop() -> CGFloat {
        return max(self.contentSize.height, self.bounds.height)
    }
}

// MARK -- 拖拉的处理

extension UIScrollView {

    /**
     * 添加监听
     */
    private func addObserver() {
        if !self.addedObserver {
            self.addedObserver = true
            self.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: &kPointerRefreshContentOffsetChangedContext)
            self.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: &kPointerRefreshContentSizeChangedContext)
        }
    }

    /**
     * 移除监听
     */
    private func removeObserver() {
        self.removeObserver(self, forKeyPath: "contentOffset", context: &kPointerRefreshContentOffsetChangedContext)
        self.removeObserver(self, forKeyPath: "contentSize", context: &kPointerRefreshContentSizeChangedContext)
        self.addedObserver = false
    }

    /**
     是否已经添加Observer
     */
    private var addedObserver: Bool {

        get {
            if let boolNumber = objc_getAssociatedObject(self, &kPointerRefreshContentChangedContextExist) as? NSNumber {
                return boolNumber.boolValue
            } else {
                return false
            }
        }
        set {
            let boolNumber = NSNumber(bool: newValue)
            objc_setAssociatedObject(self, &kPointerRefreshContentChangedContextExist, boolNumber, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {

        if context == &kPointerRefreshContentOffsetChangedContext {

            guard let contentOffset = change?[NSKeyValueChangeNewKey]?.CGPointValue else {
                return
            }

            if self.showTopRefresh { // 集成下拉刷新
                self.updateTopRefreshWithContentOffset(contentOffset)
                
            }

            if self.showBottomRefresh { // 集成上拉刷新
                self.updateBottomRefreshWithContentOffset(contentOffset)
            }
        } else if context == &kPointerRefreshContentSizeChangedContext {

            if self.showBottomRefresh {
                if let contentSize = change?[NSKeyValueChangeNewKey]?.CGSizeValue() {
                    self.updateBottomRefreshWithContentSize(contentSize)
                }
            }
        }
    }
}
