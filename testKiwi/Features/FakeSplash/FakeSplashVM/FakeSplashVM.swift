//
//  FakeSplashVM.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import Foundation

protocol FakeSplashVMDelegate: class {
    func didLoadData(_ data: [Flight])
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
    func didLoadData(_ data: [Flight]) {
        delegate?.didLoadData(data)
    }
    func error(_ error: Error) {
        delegate?.error(error)
    }
}
