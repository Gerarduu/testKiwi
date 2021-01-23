//
//  HomeVM.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import Foundation

protocol HomeVMDelegate: class {
    func didLoadData(_ data: [Flight])
    func error(_ error: Error)
}

class HomeVM {
    
    var loadHomeDataFlowHelper = LoadHomeDataFlowHelper()
    
    weak var delegate: HomeVMDelegate?
        
    func loadHomeData() {
        loadHomeDataFlowHelper.delegate = self
        loadHomeDataFlowHelper.loadHomeData()
    }
}

extension HomeVM: LoadHomeDataFlowHelperDelegate {
    func didLoadData(_ data: [Flight]) {
        delegate?.didLoadData(data)
    }
    
    func error(_ error: Error) {
        delegate?.error(error)
    }
}
