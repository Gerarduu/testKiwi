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
    
    private func cacheFlights(finish: @escaping () -> Void) {
        
        FlightManager.shared.getCachedFlights { (cachedFlights, error) in
            
            if error != nil {
                self.delegate?.error(AppError.noFlights)
            }
            
            var newFlights = Set<Flight>()
            
            //MARK: - If we dont' have cached flights, simply pick 5 flights from the returned API's flights.
            if cachedFlights.count == 0 {
                for (i,flight) in self.flights.enumerated() {
                    newFlights.insert(flight)
                    if i == kMaxFlights-1 {
                        FlightManager.shared.saveFlights(flights: newFlights) {
                            finish()
                        }
                        break
                    }
                }
            } else { //MARK: - If we already have cached flights, pick 5 different flights returned from the API.
                let filteredFlights = self.flights.filter { flight in
                    !cachedFlights.contains(where: {$0.id == flight.id}
                )}
                
                let count = filteredFlights.count
                
                if count <= 0 {
                    self.delegate?.error(AppError.noFlights)
                    return
                }
                
                for i in 0..<count {
                    if i == kMaxFlights-1 {
                        //MARK: - Clear old flights and add new ones.
                        self.clearOldCache {
                            FlightManager.shared.saveFlights(flights: newFlights) {
                                finish()
                            }
                        }
                        break
                    }
                    if let flight = filteredFlights.randomElement() {
                        newFlights.insert(flight)
                    }
                }
            }
        }
    }
    
    private func clearOldCache(finish: @escaping () -> Void) {
        FlightManager.shared.getCachedFlights { (cachedFlights, error) in
            if error != nil {
                
            } else {
                for cachedFlight in cachedFlights {
                    FlightManager.shared.deleteFlight(flight: cachedFlight)
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
                        FlightManager.shared.getCachedFlights { (cachedFlights, error) in
                            if error != nil {
                                self.delegate?.error(AppError.generic)
                                return
                            }
                            if cachedFlights.count > 0 {
                                let sortedFlights = self.sortedById(cachedFlights)
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
                    FlightManager.shared.getCachedFlights { (cachedFlights, error) in
                        let sortedFlights = self.sortedById(cachedFlights)
                        self.delegate?.didLoadData(sortedFlights)
                        Preferences.setPrefsAppFirstLaunchedTime(value: Date())
                    }
                }
                break
            }
        }
    }
}
