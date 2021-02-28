//
//  Navigation.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import Foundation
import UIKit

class Navigation {
    
    static let shared = Navigation()
    private let window = UIWindow(frame: UIScreen.main.bounds)

    func setSplash() {
        let fakeSplashVC = kStoryboardMain.instantiateViewController(withIdentifier: kFakeSplashVC)
        setRootController(UINavigationController(rootViewController: fakeSplashVC))
    }
    
    func setRootHome(flights: [FlightObject]) {
        DispatchQueue.main.async { [weak self] in
            if let homeVC = kStoryboardHome.instantiateViewController(withIdentifier: kHomeVC) as? HomeVC {
                homeVC.flights = flights
                self?.setRootController(UINavigationController(rootViewController: homeVC))
            }
        }
    }
    
    private func setRootController(_ controller: UIViewController, animated: Bool = false, completion: (() -> Void)? = nil ) {
        if animated {
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            window.rootViewController = controller
            CATransaction.commit()
        } else {
            window.rootViewController = controller
            completion?()
        }
        window.makeKeyAndVisible()
    }
}



