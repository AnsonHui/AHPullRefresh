//
//  PullDownRefreshView.swift
//  Meepoo
//
//  Created by 黄辉 on 5/31/16.
//  Copyright © 2016 com.fantasy.ahpullrefresh. All rights reserved.
//

import UIKit
import AHAutoLayout_Swift

class PullDownRefreshView: UIView {

    private var titleLabel: UILabel!
    private var imageView: UIImageView!

    private var titles: [String]?

    init(titles: [String], images: [UIImage]?) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 70))

        self.titles = titles

        // 标题
        self.titleLabel = UILabel()
        self.titleLabel.backgroundColor = UIColor.clear
        self.titleLabel.textColor = UIColor.gray
        self.titleLabel.font = UIFont.systemFont(ofSize: 12.0)
        self.titleLabel.text = titles.first
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.titleLabel)

        self => self.titleLabel.centerX == self.centerX
        self ~~> self.titleLabel.top == self.top + 6

        // 图片
        self.imageView = UIImageView()
        self.imageView.animationImages = images
        self.imageView.animationDuration = 0.5
        self.imageView.startAnimating()
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.imageView)

        self => self.imageView.centerX == self.centerX
        self ~~> self.imageView.top == self.titleLabel.bottom + 6
    }

    override func setNeedsDisplay() {
        super.setNeedsDisplay()

        if let titles = self.titles {
            if titles.count > 1 {
                let index = Int(arc4random()) % titles.count
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
