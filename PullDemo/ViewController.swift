//
//  ViewController.swift
//  PullDemo
//
//  Created by Kevin on 2020/12/29.
//

import UIKit

class PullViewController: UIViewController, UIScrollViewDelegate {
    
    var isPull: Bool = false
    var nextVC: PullViewController? = nil
    
    lazy var mainScroll: UIScrollView = {
        let bounds = view.bounds
        let scroll = UIScrollView(frame: bounds)
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.isPagingEnabled = true
        scroll.backgroundColor = .clear
        scroll.contentSize = CGSize(width: bounds.width, height: bounds.height+0.1)
        return scroll
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if viewControllerToPresent.isKind(of: PullViewController.self) {
            nextVC = (viewControllerToPresent as! PullViewController)
            self.addChild(viewControllerToPresent)
            mainScroll.delegate = self
            view.addSubview(mainScroll)
            mainScroll.addSubview(viewControllerToPresent.view)
            let bounds = view.bounds
            viewControllerToPresent.view.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: bounds.height)
            UIView.animate(withDuration: 0.25) {
                viewControllerToPresent.view.frame = bounds
            } completion: { (finish) in
                self.mainScroll.setContentOffset(CGPoint.zero, animated: false)
                self.isPull = false
                if (completion != nil) {
                    completion!()
                }
            }
        }else {
            super.present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if ((self.parent?.isKind(of: PullViewController.self)) != nil) {
            let parent: PullViewController = self.parent as! PullViewController
            if parent.isPull == false {
                parent.isPull = true
                let bounds = view.bounds
                UIView.animate(withDuration: 0.25) {
                    self.view.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: bounds.height)
                } completion: { (finish) in
                    parent.mainScroll.removeFromSuperview()
                    self.view.removeFromSuperview()
                    if (completion != nil) {
                        completion!()
                    }
                }
            }
        }else {
            super.dismiss(animated: flag, completion: completion)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -view.bounds.height/5 {
            if nextVC != nil {
                nextVC!.dismiss(animated: true, completion: nil)
            }
        }else {
            scrollView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -view.bounds.height/5 {
            if nextVC != nil {
                nextVC!.dismiss(animated: true, completion: nil)
            }
        }else {
            scrollView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y < -view.bounds.height/5 {
            if nextVC != nil {
                nextVC!.dismiss(animated: true, completion: nil)
            }
        }else {
            scrollView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
}

class ParentController: PullViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 100, y: 200, width: view.bounds.width-200, height: 50)
        button.setTitle("跳转", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        button.addTarget(self, action: #selector(presentNext), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc func presentNext() {
        let vc = NextController()
        self.present(vc, animated: true, completion: nil)
    }
    
}

class NextController: PullViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 100, y: 200, width: view.bounds.width-200, height: 50)
        button.setTitle("收起", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        button.addTarget(self, action: #selector(backParent), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc func backParent() {
        self.dismiss(animated: true, completion: nil)
    }
}
