//
//  ViewController.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import UIKit
import SafariServices

class HomeVC: UIViewController {

    var flights = [Flight]()
    
    @IBOutlet weak var mainTV: UITableView! {
        didSet {
            mainTV.showsVerticalScrollIndicator = false
            mainTV.rowHeight = 200.0
            mainTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            mainTV.delegate = self
            mainTV.dataSource = self
            
            mainTV.register(UINib(nibName: kFlightTVC, bundle: .main), forCellReuseIdentifier: kFlightTVC)
            
            mainTV.separatorStyle = .none
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        mainTV.reloadData()
    }
    
    func setup() {
        title = "home_vc.title".localized
    }
    
    private func cellForFlightTVC(at indexPath: IndexPath) -> UITableViewCell{
        if let cell = mainTV.dequeueReusableCell(withIdentifier: kFlightTVC) as? FlightTVC {
            let flight = flights[indexPath.row]
            cell.selectionStyle = .none
            cell.delegate = self
            cell.configureCell(with: flight)
            return cell
        }
        return UITableViewCell()
    }
}

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flights.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellForFlightTVC(at: indexPath)
    }
}

extension HomeVC: FlightTVCDelegate {
    func pushInfo(deepLink: URL) {
        let vc = SFSafariViewController(url: deepLink)
        present(vc, animated: true)
    }
}
