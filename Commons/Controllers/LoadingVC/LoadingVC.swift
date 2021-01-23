//
//  LoadingVC.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import Foundation
import UIKit


class LoadingVC: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var color: UIColor?
    let containerView: UIView?
        
    init(color: UIColor? = UIColor.white, containerView: UIView? = nil) {
        self.color = color
        self.containerView = containerView
        super.init(nibName: kLoadingVC, bundle: nil)
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        if let color = self.color {
            activityIndicator.color = color
        } else {
            activityIndicator.color = UIColor.white
        }
    }
        
    func start() {
        if let container = containerView {
            container.addSubview(view)
            UIView.addConstraints(self.view, in: container)
        } else if view.superview == nil {
            if let window = UIApplication.shared.keyWindow {
                view.frame = window.frame
                UIApplication.shared.keyWindow!.addSubview(view)
            }
        } else if activityIndicator.isAnimating { return }
            
        UIView.transition(with: view, duration: 0.4, options: .transitionCrossDissolve, animations: { [weak self] in ()
            self?.activityIndicator.alpha = 1.0
            self?.activityIndicator.startAnimating()
            self?.view.alpha = 1.0
        }, completion: nil)
    }
        
    func stop() {
        if activityIndicator == nil { return }
        if activityIndicator.isAnimating {
            UIView.transition(with: view, duration: 0.4, options: .transitionCrossDissolve, animations: { [weak self] in
                self?.activityIndicator.alpha = 0.0
                self?.activityIndicator.stopAnimating()
                self?.view.alpha = 0.0
                
            }, completion: { [weak self] (_) in
                self?.view.removeFromSuperview()
            })
        }
    }
}

