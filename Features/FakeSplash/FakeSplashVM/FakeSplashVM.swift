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
    
    weak var delegate: FakeSplashVMDelegate?
    
    func loadData() {
        APIClient.shared.requestObject(router: APIRouter.flights) { [weak self] (result: Result<FlightsRoot,Error>) in
            guard let `self` = self else {return}
            switch result {
            case .failure(let err):
                self.delegate?.error(err)
                break
            case .success(let value):
                guard let data = value.data else {
                    self.delegate?.error(AppError.generic)
                    return
                }
                self.delegate?.didLoadData(data)
                break
            }
        }
    }
}
