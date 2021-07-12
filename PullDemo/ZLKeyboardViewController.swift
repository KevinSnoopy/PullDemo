//
//  ZLKeyboardViewController.swift
//  WCDBDemo
//
//  Created by Kevin on 2021/7/9.
//

import UIKit

let screen = UIScreen.main.bounds,
    screenWidth = screen.width,
    screenHeight = screen.height
class ZLKeyboardViewController: UIViewController, UIScrollViewDelegate {
    
    var responderView: UIView?
    
    lazy var contentView: UIScrollView = {
        let contentView = UIScrollView(frame: screen)
        contentView.contentSize = CGSize(width: screenWidth, height: screenHeight+1)
        contentView.backgroundColor = .white
        contentView.showsVerticalScrollIndicator = false
        contentView.showsHorizontalScrollIndicator = false
        contentView.delegate = self
        contentView.contentInsetAdjustmentBehavior = .never
        return contentView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        addObserver()
    }
    
    private func setUpView() {
        view.addSubview(contentView)
        let textField = UITextField(frame: CGRect(x: 100, y: screenHeight-150, width: screenWidth-200, height: 30))
        textField.backgroundColor = .systemGray
        contentView.addSubview(textField)
        responderView = textField
    }
    
    private func addObserver() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardShow(_ notice: Notification) {
        if let userInfo = notice.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect, let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval, let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber, let bounds = responderView?.bounds, let window = UIApplication.shared.windows.first, let responderFrame = responderView?.convert(bounds, to: contentView) {
            let keyboardHeight = keyboardFrame.height,
                curve = UIView.AnimationOptions(rawValue: curveValue.uintValue),
                contentFrame = contentView.convert(responderFrame, to: window),
                contentY = contentView.contentSize.height,
                boundsH = contentView.bounds.height
            if contentFrame.maxY > screenHeight-keyboardHeight {
                let offsetY = contentFrame.maxY-screenHeight+keyboardHeight+contentView.contentOffset.y
                if contentY < boundsH+offsetY {
                    contentView.contentInset.bottom = boundsH+offsetY-contentY
                }
                UIView.animate(withDuration: duration, delay: 0, options: curve, animations: {
                    self.contentView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
                }, completion: nil)
            }
        }
    }
    
    @objc func keyboardHide(_ notice: Notification) {
        if let userInfo = notice.userInfo, let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval, let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber {
            let curve = UIView.AnimationOptions(rawValue: curveValue.uintValue)
            UIView.animate(withDuration: duration, delay: 0, options: curve, animations: {
                self.contentView.contentInset.bottom = 0
            }, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isTracking || scrollView.isDecelerating {
            view.endEditing(true)
            let orginY = scrollView.frame.origin.y-scrollView.contentOffset.y
            if orginY >= 0 {
                scrollView.frame.origin.y = orginY
                scrollView.setContentOffset(.zero, animated: false)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !scrollView.isTracking, !scrollView.isDragging, !scrollView.isDecelerating {
            resetOffset(scrollView)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate, scrollView.isTracking, !scrollView.isDragging, !scrollView.isDecelerating {
            resetOffset(scrollView)
        }
    }
    
    private func resetOffset(_ scrollView: UIScrollView) {
        if scrollView.frame.origin.y > screenHeight/3 {
            dismiss(animated: true, completion: nil)
        }else {
            scrollView.setContentOffset(.zero, animated: true)
            UIView.animate(withDuration: TimeInterval(0.25*scrollView.frame.origin.y/screenHeight*3)) {
                scrollView.frame.origin.y = 0
            }
        }
    }
    
}
