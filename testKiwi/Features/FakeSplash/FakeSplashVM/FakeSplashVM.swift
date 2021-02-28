//
//  FakeSplashVM.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import Foundation

protocol FakeSplashVMDelegate: class {
    func didLoadData(_ data: [FlightObject])
    func error(_ error: Error)
}

class FakeSplashVM {
    
    var loadHomeDataFlowHelper = LoadHomeDataFlowHelper()
    
    weak var delegate: FakeSplashVMDelegate?
        
    func loadHomeData() {
        loadHomeDataFlowHelper.delegate = self
        loadHomeDataFlowHelper.loadHomeData()
    }
}

extension FakeSplashVM: LoadHomeDataFlowHelperDelegate {
    func didLoadData(_ data: [FlightObject]) {
        delegate?.didLoadData(data)
    }
    func error(_ error: Error) {
        delegate?.error(error)
    }
}
