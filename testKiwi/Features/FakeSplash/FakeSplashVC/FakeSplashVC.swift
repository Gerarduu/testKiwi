//
//  FakeSplashVC.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import Foundation

class FakeSplashVC: BaseVC {
    let fakeSplashVM = FakeSplashVM()
    
    var flights = [FlightObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadData()
    }
    
    func setup() {
        fakeSplashVM.delegate = self
    }
    
    func loadData() {
        startWaiting()
        fakeSplashVM.loadHomeData()
    }
    
    func pushHome(){
        Navigation.shared.setRootHome(flights: self.flights)
    }
}

extension FakeSplashVC: FakeSplashVMDelegate {
    func didLoadData(_ data: [FlightObject]) {
        stopWaiting()
        self.flights = data
        pushHome()
    }
    
    func error(_ error: Error) {
        stopWaiting()
        /// Wait for the LoadingVC's animation transition to finish
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) { [weak self] in
            guard let `self` = self else { return }
            self.showPopup(withTitle: "error.generic".localized, withText: error.localizedDescription, withButton: "error.retry".localized, completion: { (retry,_) in
                self.loadData()
            })
        }
    }
}
