//
//  BaseVC.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import Foundation
import UIKit

class BaseVC: UIViewController {
    
    var waitingView: LoadingVC?
    
    private var isShownPopup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavBar()
    }
    
    func setupNavBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
    }
    
    func startWaiting(color: UIColor = .white) {
        DispatchQueue.main.async {
            if self.waitingView == nil {
                self.waitingView = LoadingVC(color: color, containerView: self.view)
            }
            self.view.subviews.filter { $0.isKind(of: LoadingVC.self) }
                .forEach { $0.removeFromSuperview() }
            self.waitingView?.start()
        }
    }
    
    func stopWaiting(_ silent: Bool = false) {
        DispatchQueue.main.async {
            self.waitingView?.stop()
        }
    }
    
    func showPopup(withTitle title: String?, withText text: String?, withButton button: String?, button2: String? = nil, completion: ((Bool?, Bool?) -> Void)?) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {return}
            if !self.isShownPopup, self.presentedViewController == nil, UIApplication.shared.applicationState == .active {
                self.isShownPopup = true
                
                let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: button, style: .default, handler: { [weak self]
                    (value) in
                    self?.view.subviews.last?.removeFromSuperview()
                    self?.isShownPopup = false
                    completion?(true, nil)
                }))
                
                if let button2 = button2 {
                    alert.addAction(UIAlertAction(title: button2, style: .default, handler: { [weak self]
                        (value) in
                        self?.view.subviews.last?.removeFromSuperview()
                        self?.isShownPopup = false
                        completion?(nil, true)
                    }))
                }
        
                self.present(alert, animated: true, completion: nil)
                
            } else {
                debugPrint("There is still a popup ...")
            }
        }
    }
}
