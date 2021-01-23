//
//  LoadHomeDataFlowHelper.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import Foundation

protocol LoadHomeDataFlowHelperDelegate:class{
    func didLoadData(_ data: [Flight])
    func error(_ error: Error)
}

class LoadHomeDataFlowHelper {
    
    weak var delegate: LoadHomeDataFlowHelperDelegate?
    
    var flights = [Flight]()
    var cachedFlights = [Flight]()
    var flightsTemp = [Flight]()
    var previousIndex: UInt32?
    
    private func randomIndex() -> UInt32 {
        var randomIndex = arc4random_uniform(UInt32(self.flightsTemp.count-1))
        while previousIndex == randomIndex {
            randomIndex = arc4random_uniform(UInt32(self.flightsTemp.count-1))
        }
        previousIndex = randomIndex
        return randomIndex
    }
    
    private func cacheFlights(finish: @escaping () -> Void) {
        
        DispatchQueue.main.async {
            let oldFlights = FlightCacheManager.shared.getCachedFlights()
            var newFlights = [Flight]()
            
            if self.flights.count <= 0 {
                self.delegate?.error(AppError.generic)
                return
            }
            
            if oldFlights.count<=0 {
                for (i,flight) in self.flights.enumerated() {
                    if i == kMaxFlights {
                        break
                    }
                    newFlights.append(flight)
                }
            } else {
                self.flightsTemp = self.flights.filter { flight in
                    !oldFlights.contains(where: {$0.id == flight.id}
                )}
                
                for _ in 0..<kMaxFlights {
                    newFlights.append(self.flightsTemp[Int(self.randomIndex())])
                }
            }
            
            self.clearOldCache {
                for flight in newFlights {
                    FlightCacheManager.shared.saveFlightId(flight: flight)
                }
                DispatchQueue.main.async {
                    finish()
                }
            }
        }
    }
    
    private func clearOldCache(finish: @escaping () -> Void) {
        DispatchQueue.main.async {
            let oldFlights = FlightCacheManager.shared.getCachedFlights()
            for oldFlight in oldFlights {
                FlightCacheManager.shared.deleteFlight(flight: oldFlight)
            }
            finish()
        }
    }
    
    private func sortedById(_ flights: [Flight]) -> [Flight] {
        let sortedFlights = flights.sorted(by: {
            guard let first: String = $0.id, let second: String = $1.id else {
                self.delegate?.error(AppError.generic)
                return false
            }
            return first > second
        })
        return sortedFlights
    }
    
    func loadHomeData() {
        if let hasAlreadyLaunched = Preferences.getPrefsHasAlreadyLaunched() {
            if hasAlreadyLaunched {
                if let date = Preferences.getPrefsAppFirstLaunchedTime() {
                    if let diff = Calendar.current.dateComponents([.second], from: date, to: Date()).second, diff > 1 {
                        loadData()
                    } else {
                        DispatchQueue.main.async {
                            self.cachedFlights = FlightCacheManager.shared.getCachedFlights()
                            if self.cachedFlights.count > 0 {
                                self.delegate?.didLoadData(self.sortedById(self.cachedFlights))
                            } else {
                                self.loadData()
                            }
                        }
                    }
                }
            } else {
                Preferences.setPrefsHasAlreadyLaunched(value: true)
                loadData()
            }
        }
    }
    
    private func loadData() {
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
                self.flights = data
                self.cacheFlights {
                    DispatchQueue.main.async {
                        self.cachedFlights = FlightCacheManager.shared.getCachedFlights()
                        self.delegate?.didLoadData(self.sortedById(self.cachedFlights))
                        Preferences.setPrefsAppFirstLaunchedTime(value: Date())
                    }
                }
                break
            }
        }
    }
}
