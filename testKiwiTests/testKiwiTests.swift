//
//  testKiwiTests.swift
//  testKiwiTests
//
//  Created by Gerard Riera  on 23/01/2021.
//

import XCTest
@testable import testKiwi

class testKiwiTests: XCTestCase {
    
    func testStrings() {
        XCTAssertEqual("home_vc.title".localized, "Flights")
        XCTAssertEqual("flight_tvc.from_desc".localized, "FROM")
        XCTAssertEqual("flight_tvc.to_desc".localized, "TO")
        XCTAssertEqual("flight_tvc.flight_info_btn".localized, "Flight Info")
        XCTAssertEqual("error.generic".localized, "Something went wrong...")
        XCTAssertEqual("error.retry".localized, "Retry")
        XCTAssertEqual("error.ok".localized, "OK")
        XCTAssertEqual("error.no_flights".localized, "Unfortunately, there are now flights available at the moment. Please, try again later.")
    }
        
    func testAPIRouter() {
        XCTAssertTrue(APIRouter.flights.asURLRequest() != nil)
    }
    
    func testPath() {
        XCTAssertEqual(kBaseURL, "https://api.skypicker.com")
        XCTAssertEqual(kFlightsPath, "/flights")
    }
    
    func testAPIResponse() {
           
        guard let request = APIRouter.flights.asURLRequest() else {
            return
        }
        
        let expectations = self.expectation(description: "GET API performance check")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                return
            }
            XCTAssertNotNil(data)
            expectations.fulfill()
        })
        task.resume()
        self.waitForExpectations(timeout: 10) {error in
            if let error = error {
                XCTFail("\(error)")
            }
        }
    }
    
    func testRequestObject() {
        let expectations = self.expectation(description: "Request object performance check")
        
        APIClient.shared.requestObject(router: APIRouter.flights) { (result: Result<FlightsRoot,Error>) in
            XCTAssertNotNil(result)
            expectations.fulfill()
        }
        
        self.waitForExpectations(timeout: 10) {error in
            if let error = error {
                XCTFail("\(error)")
            }
        }
    }
}


