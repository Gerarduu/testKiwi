//
//  LoadHomeDataFlowHelper.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import Foundation

protocol LoadHomeDataFlowHelperDelegate:class{
    func didLoadData(_ data: [FlightObject])
    func error(_ error: Error)
}

class LoadHomeDataFlowHelper {
    
    weak var delegate: LoadHomeDataFlowHelperDelegate?
    
    var flights = [Flight]()
    
    private func cacheFlights(finish: @escaping () -> Void) {
        
        var newFlights = Set<Flight>()
        
        //MARK: - If we already have cached flights, pick 5 different flights returned from the API.
        if let cachedFlights = FlightManager.shared.getCachedFlights() {
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
        } else { //MARK: - If we dont' have cached flights, simply pick 5 flights from the returned API's flights.
            for (i,flight) in self.flights.enumerated() {
                newFlights.insert(flight)
                if i == kMaxFlights-1 {
                    FlightManager.shared.saveFlights(flights: newFlights) {
                        finish()
                    }
                    break
                }
            }
        }
    }
    
    private func clearOldCache(finish: @escaping () -> Void) {
        guard let cachedFlights = FlightManager.shared.getCachedFlights() else { return }
        for n in 0..<cachedFlights.count {
            let cachedFlight = cachedFlights[n]
            FlightManager.shared.deleteFlight(flight: cachedFlight)
        }
        finish()
    }
    
    private func sortedById(_ flights: [FlightObject]) -> [FlightObject] {
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
                        if let cachedFlights = FlightManager.shared.getCachedFlights() {
                            if cachedFlights.count > 0 {
                                let sortedFlights = self.sortedById(cachedFlights)
                                self.delegate?.didLoadData(sortedFlights)
                            } else {
                                self.loadData()
                            }
                        } else {
                            self.delegate?.error(AppError.generic)
                            return
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
                    if let cachedFlights = FlightManager.shared.getCachedFlights() {
                        let sortedFlights = self.sortedById(cachedFlights)
                        self.delegate?.didLoadData(sortedFlights)
                        Preferences.setPrefsAppFirstLaunchedTime(value: Date())
                    } else {
                        self.delegate?.error(AppError.generic)
                        return
                    }
                }
                break
            }
        }
    }
}
