//
//  PullUpRefreshView.swift
//  Meepoo
//
//  Created by 黄辉 on 6/17/16.
//  Copyright © 2016 com.fantasy.ahpullrefresh. All rights reserved.
//

import UIKit
import AutoLayoutDSL_Swift

class PullUpRefreshView: UIView {

    private var titleLabel: UILabel!
    private var imageView: UIImageView!

    private var titles: [String]?

    init(titles: [String], images: [UIImage]?) {
        super.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 60))

        self.userInteractionEnabled = false

        self.titles = titles

        // 图片
        self.imageView = UIImageView()
        self.imageView.animationImages = images
        self.imageView.animationDuration = 0.5
        self.imageView.startAnimating()
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.imageView)

        self => self.imageView.centerY == self.centerY

        // 标题
        self.titleLabel = UILabel()
        self.titleLabel.backgroundColor = UIColor.clearColor()
        self.titleLabel.textColor = UIColor.grayColor()
        self.titleLabel.font = UIFont.systemFontOfSize(12.0)
        self.titleLabel.text = titles.first
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.titleLabel)

        self => self.titleLabel.centerY == self.centerY
        self => self.titleLabel.left == self.imageView.right + 20

        // 适配
        let leftBankView = UIView()
        leftBankView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(leftBankView)
        self => leftBankView.left == self.left
        self => leftBankView.right == self.imageView.left

        let rightBankView = UIView()
        rightBankView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(rightBankView)
        self => rightBankView.left == self.titleLabel.right
        self => rightBankView.right == self.right
        self => leftBankView.width == rightBankView.width
    }

    override func setNeedsDisplay() {
        super.setNeedsDisplay()

        if let titles = self.titles {
            if titles.count > 1 {
                let index = random() % titles.count
                if index < titles.count {
                    self.titleLabel.text = titles[index]
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
}