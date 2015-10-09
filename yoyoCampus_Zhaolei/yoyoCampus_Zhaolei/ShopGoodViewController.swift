//
//  ShopGoodViewController.swift
//  yoyoCampus_Zhaolei
//
//  Created by 赵磊 on 15/10/7.
//  Copyright © 2015年 赵磊. All rights reserved.
//

import UIKit

class ShopGoodViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate{

    @IBOutlet var photoImgView: UIImageView!
    
    @IBOutlet var goodNameLabel: UILabel!
    
    @IBOutlet var roundBtn: UIButton!

    @IBOutlet var shopNameBtn: UIButton!
    
    @IBOutlet var originPriceLabel: UILabel!
    
    @IBOutlet var presentPriceLabel: UILabel!
    
    @IBOutlet var interestCountLabel: UILabel!
    
    @IBOutlet var soldCountLabel: UILabel!
    
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var detailBtn: UIButton!
    
    @IBOutlet var remarkBtn: UIButton!
    
    @IBOutlet var horizontalScroll: UIScrollView!
    
    ///指示器视图
    var scrollIndicator = UIScrollView()
    
    ///指示器内的指示色块
    var inScrollIndicator = UIView()
    
    ///详情视图
    var detailView = UITableView()
    
    ///评论视图
    var remarkTableView = UITableView()
    
    //页控制器
    var pageCtl = UIPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavigaitonBar()
        self.setUpInitialLooking()
        self.setUpActions()
        self.setUpOnlineData()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpNavigaitonBar(){
        Consts.setUpNavigationBarWithBackButton(self, title: "详情", backTitle: "<")
        
        let shareBtnItem = UIBarButtonItem(image: UIImage(named: "xiangqing_status bar_share"), style: UIBarButtonItemStyle.Plain, target: self, action: "Share")
        shareBtnItem.tintColor = Consts.white
        self.navigationItem.rightBarButtonItem = shareBtnItem
    }
    
    func setUpInitialLooking(){
        let newWidth = self.view.frame.width
        
        self.view.backgroundColor = Consts.grayView
        
        self.goodNameLabel.text = "恒通驾校报名"
        
        self.roundBtn.layer.cornerRadius = self.roundBtn.frame.width/2
        
        self.shopNameBtn.titleLabel?.text = "恒通"
        
        let attributedText = NSAttributedString(string: "¥ 5330", attributes: [NSStrikethroughStyleAttributeName: 1])//0表示不显示删除线，1表示显示删除线
        self.originPriceLabel.attributedText = attributedText
        
        self.presentPriceLabel.text = "¥ 4330"
        
        self.interestCountLabel.text = "10 人感兴趣"
        
        self.soldCountLabel.text = "已售 10"
        
        self.timeLabel.text = "2015-09-02"
        
        //设置指示器 scrollIndicator && inScrollIndicator
        /*
        *************************************************************
        1⃣️1⃣️1⃣️1⃣️1⃣️：frame.width==contentSize.width不是相当于不能滑动吗?
        *************************************************************
        */
        self.scrollIndicator.frame = CGRect(x: 0, y: self.detailBtn.frame.maxY+1, width: newWidth, height: 2.8)
        self.scrollIndicator.backgroundColor = Consts.grayView
        self.scrollIndicator.contentSize = CGSize(width: newWidth, height: 0)//height=0表明禁止垂直滑动
        self.scrollIndicator.contentOffset = CGPoint(x: 0, y: 0)
        self.scrollIndicator.pagingEnabled = true
        
        self.inScrollIndicator.frame = CGRect(x: self.detailBtn.frame.width/2.5, y: 0, width: self.detailBtn.frame.width/3, height: 2.8)
        self.inScrollIndicator.backgroundColor = Consts.tintGreen
        
        self.scrollIndicator.addSubview(self.inScrollIndicator)
        self.view.addSubview(self.scrollIndicator)
        
        //设置要显示的两个view
        //1------detailView
        self.detailView.frame = CGRect(x:0,y:0, width:self.horizontalScroll.frame.width, height: self.horizontalScroll.frame.height)
        self.detailView.backgroundColor = Consts.grayView
        
        //2------remarkView
        self.remarkTableView.frame = CGRect(x:self.horizontalScroll.frame.width, y: 0, width: self.horizontalScroll.frame.width, height: self.horizontalScroll.frame.height)
        self.remarkTableView.backgroundColor = Consts.grayView
        
        self.horizontalScroll.addSubview(self.detailView)
        self.horizontalScroll.addSubview(self.remarkTableView)
        
        //设置horizontalScrollView
        self.horizontalScroll.contentSize = CGSize(width: self.horizontalScroll.frame.width * 2, height: 0)//禁止垂直滑动
        self.horizontalScroll.contentOffset = CGPoint(x: 0, y: 0)
        self.horizontalScroll.showsHorizontalScrollIndicator = false
        self.horizontalScroll.pagingEnabled = true
        
        //设置pageCtl
        self.pageCtl.pageIndicatorTintColor = UIColor.clearColor()
        self.pageCtl.currentPageIndicatorTintColor = UIColor.clearColor()
        self.pageCtl.enabled = false
        self.horizontalScroll.addSubview(self.pageCtl)
    }
    
    func setUpActions(){
        self.scrollIndicator.delegate = self
        self.horizontalScroll.delegate = self
        
        self.detailView.delegate = self
        self.detailView.dataSource = self
        self.remarkTableView.delegate = self
        self.remarkTableView.dataSource = self
        
        //注意离开本页面的时候要removeObserver,此处使用KVO编程，为pageCtl(数据模型－－被监听对象)添加监听器（self--视图组件）,监听器要重写observerKeyForKeyPath方法
        self.pageCtl.addObserver(self, forKeyPath: "currentPage", options: .New, context: nil)
    }
    
    func setUpOnlineData(){
        
    }
    
    //滑动后按钮颜色变化
    func tabChangeTo(state:Int){
        switch (state){
        case 0://详情
            //设置动画
            UIView.beginAnimations(nil, context: nil)//开始动画
            UIView.setAnimationDuration(0.25)//持续时间
            UIView.setAnimationCurve(.EaseIn)
            self.detailBtn.titleLabel?.textColor = Consts.tintGreen
            self.remarkBtn.titleLabel?.textColor = Consts.darkGray
            UIView.commitAnimations()
            break
        case 1://评价
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.25)
            UIView.setAnimationCurve(.EaseIn)
            self.remarkBtn.titleLabel?.textColor = Consts.tintGreen
            self.detailBtn.titleLabel?.textColor = Consts.darkGray
            UIView.commitAnimations()
            break
        default:
            break
        }
    }
    
    //页面滑动后更改控制器当前页数
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if(scrollView == self.horizontalScroll){
            let newWidth = self.view.frame.width
            let offset:CGPoint = scrollView.contentOffset
            /*
            *************************************************************
            2⃣️2⃣️2⃣️2⃣️2⃣️2⃣️2⃣️2⃣️：此处x是怎么算出来的？
            *************************************************************
            */
            self.scrollIndicator.contentOffset = CGPoint(x: -offset.x/2, y: offset.y)
            let temPage = Int(floor((offset.x - newWidth/2)/newWidth)+1)
            self.pageCtl.currentPage = temPage
        }
    }
    
    //为监听器self监听pageCtl.currentPage变化,并更新界面
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if(keyPath == "currentPage"){
            self.tabChangeTo(self.pageCtl.currentPage)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        <#code#>
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (tableView == self.detailView){
            self.detailView.deselectRowAtIndexPath(indexPath, animated: true)
        }else if(tableView == self.remarkTableView){
            
        }
    }
    
    func goBack(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func Share(){
        
    }

}
