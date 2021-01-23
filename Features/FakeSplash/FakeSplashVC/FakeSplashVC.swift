//
//  FakeSplashVC.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import Foundation

class FakeSplashVC: BaseVC {
    let fakeSplashVM = FakeSplashVM()
    
    var flights = [Flight]()
    
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
        fakeSplashVM.loadData()
    }
    
    func pushHome(){}
}

extension FakeSplashVC: FakeSplashVMDelegate {
    func didLoadData(_ data: [Flight]) {
        stopWaiting()
        self.flights = data
        pushHome()
    }
    
    func error(_ error: Error) {
        stopWaiting()
    }
}
