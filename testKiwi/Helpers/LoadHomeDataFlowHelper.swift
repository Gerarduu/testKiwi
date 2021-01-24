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
    var filteredFlights = [Flight]()
    var previousIndex: UInt32?
    
    private func cacheFlights(finish: @escaping () -> Void) {
        
        FlightCacheManager.shared.getCachedFlights { (flights, error) in
            if error != nil {
                self.delegate?.error(AppError.noFlights)
            }
            
            let oldFlights = flights
            var newFlights = Set<Flight>()
            
            if self.flights.count <= 0 {
                self.delegate?.error(AppError.noFlights)
                return
            }
            
            if oldFlights.count<=0 {
                for (i,flight) in self.flights.enumerated() {
                    if i == kMaxFlights {
                        break
                    }
                    newFlights.insert(flight)
                }
            } else {
                self.filteredFlights = self.flights.filter { flight in
                    !oldFlights.contains(where: {$0.id == flight.id}
                )}
                
                let count = self.filteredFlights.count
                
                if count <= 0 {
                    self.delegate?.error(AppError.noFlights)
                    return
                }
                
                for i in 0..<count {
                    if i == kMaxFlights {
                        break
                    }
                    if let flight = self.filteredFlights.randomElement() {
                        newFlights.insert(flight)
                    }
                }
            }
            
            self.clearOldCache {
                for flight in newFlights {
                    FlightCacheManager.shared.saveFlightId(flight: flight)
                }
                
                finish()
            }
        }
    }
    
    private func clearOldCache(finish: @escaping () -> Void) {
        FlightCacheManager.shared.getCachedFlights { (flights, error) in
            if error != nil {
                
            } else {
                let oldFlights = flights
                for oldFlight in oldFlights {
                    FlightCacheManager.shared.deleteFlight(flight: oldFlight)
                }
                finish()
            }
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
                if let diff = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour, diff > 24 {
                    loadData()
                } else {
                    FlightCacheManager.shared.getCachedFlights { (flights, error) in
                        if error != nil {
                            self.delegate?.error(AppError.generic)
                            return
                        }
                        self.cachedFlights = flights
                        if self.cachedFlights.count > 0 {
                            let sortedFlights = self.sortedById(self.cachedFlights)
                            self.delegate?.didLoadData(sortedFlights)
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
                    FlightCacheManager.shared.getCachedFlights { (flights, error) in
                        self.cachedFlights = flights
                        let sortedFlights = self.sortedById(self.cachedFlights)
                        self.delegate?.didLoadData(sortedFlights)
                        Preferences.setPrefsAppFirstLaunchedTime(value: Date())
                    }
                }
                break
            }
        }
    }
}
