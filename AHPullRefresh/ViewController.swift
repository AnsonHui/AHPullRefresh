//
//  ViewController.swift
//  AHPullRefresh
//
//  Created by 黄辉 on 8/5/16.
//  Copyright © 2016 Fantasy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var datas = [0, 1, 2, 3, 4, 5]
    private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.tableView = UITableView(frame: CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height - 20))
        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "UITableViewCellReuseIdentifier")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(tableView)

        self.initPullRefresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK -- 初始化上拉，下拉刷新

extension ViewController {

    func initPullRefresh() {

        // 自定义下拉显示的View
        let stopView = PullDownRefreshView(titles: ["再往下拉点，再拉一点点"], images: [UIImage(named: "loading_01")!])
        let triggeredView = PullDownRefreshView(titles: ["对对对就酱紫，可以松手啦"], images: [UIImage(named: "loading_01")!])
        let refreshAnimationView = PullDownRefreshView(titles: ["你懂的，偶在拼命加载中～(,,•́ . •̀,,)", "别着急，司机马上就到～～⁽⁽٩( ´͈ ᗨ `͈ )۶⁾⁾", "么么哒，就来啦～⊂(˃̶͈̀ε ˂̶͈́ ⊂ )"],
                                                       images: [
                                                        UIImage(named: "loading_01")!,
                                                        UIImage(named: "loading_02")!,
                                                        UIImage(named: "loading_03")!,
                                                        UIImage(named: "loading_04")!,
                                                        UIImage(named: "loading_05")!,
                                                        UIImage(named: "loading_06")!,
                                                        UIImage(named: "loading_07")!,
                                                        UIImage(named: "loading_08")!])

        // 自定义上拉显示的View
        let noMorePullUpRefreshView = PullUpRefreshView(titles: ["暂时看完啦！你不加点料吗？"], images: [UIImage(named: "loading_01")!])
        noMorePullUpRefreshView.userInteractionEnabled = true
        let errorPullUpRefreshView = PullUpRefreshView(titles: ["只是加载失败而已，点一下这里就好"], images: nil)
        errorPullUpRefreshView.userInteractionEnabled = true
        let bottomRefreshView = PullUpRefreshView(titles: ["本宝宝在拼命加载中..."],
                                                  images: [
                                                    UIImage(named: "loading_01")!,
                                                    UIImage(named: "loading_02")!,
                                                    UIImage(named: "loading_03")!,
                                                    UIImage(named: "loading_04")!,
                                                    UIImage(named: "loading_05")!,
                                                    UIImage(named: "loading_06")!,
                                                    UIImage(named: "loading_07")!,
                                                    UIImage(named: "loading_08")!])

        // 下拉刷新
        self.tableView.setCustomViewForTopRefreshState(stopView, forState: AHTopRefreshViewState.Stopped) // 继续下拉
        self.tableView.setCustomViewForTopRefreshState(triggeredView, forState: AHTopRefreshViewState.Triggered) // 松手刷新
        self.tableView.setCustomViewForTopRefreshState(refreshAnimationView, forState: AHTopRefreshViewState.Loading) // 加载中

        self.tableView.addTopRefreshBlock({
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                let top = self.datas.first!
                for i in 1 ..< 3 {
                    self.datas.insert(top - i, atIndex: 0)
                }
                self.tableView.reloadData()
                self.tableView.stopTopRefreshAnimating()
            }
        })

        // 上拉刷新
        self.tableView.setCustomViewForBottomRefreshState(noMorePullUpRefreshView, forState: AHBottomRefreshViewState.NoMore) // 没有更多数据
        self.tableView.setCustomViewForBottomRefreshState(bottomRefreshView, forState: AHBottomRefreshViewState.Loading) // 加载中
        self.tableView.setCustomViewForBottomRefreshState(errorPullUpRefreshView, forState: AHBottomRefreshViewState.Error) // 加载失败

        self.tableView.addBottomRefreshWithBlock({
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                let count = self.datas.count
                for i in count ..< count + 3 {
                    self.datas.append(i)
                }
                self.tableView.reloadData()
                self.tableView.stopBottomRefresh()
            }
        })
    }
}

// MARK -- UITableViewDelegate, UITableViewDataSource

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datas.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCellReuseIdentifier") {
            cell.textLabel?.text = "\(datas[indexPath.row])"
            return cell
        } else {
            return UITableViewCell()
        }
    }
}


