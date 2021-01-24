//
//  ViewController.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import UIKit
import SafariServices

class HomeVC: BaseVC {

    var flights = [Flight]()
    var homeVM = HomeVM()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.gray
        
        return refreshControl
    }()
    
    @IBOutlet weak var mainTV: UITableView! {
        didSet {
            mainTV.showsVerticalScrollIndicator = false
            mainTV.rowHeight = 386.0
            mainTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            mainTV.delegate = self
            mainTV.dataSource = self
            
            mainTV.register(UINib(nibName: kFlightTVC, bundle: .main), forCellReuseIdentifier: kFlightTVC)
            
            mainTV.separatorStyle = .none
            
            mainTV.addSubview(refreshControl)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        mainTV.reloadData()
    }
    
    func setup() {
        homeVM.delegate = self
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
    
    @objc func pullToRefresh() {
        homeVM.loadHomeData()
    }
}

extension HomeVC: HomeVMDelegate {
    func didLoadData(_ data: [Flight]) {
        self.flights = data
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {return}
            self.refreshControl.endRefreshing()
            self.mainTV.reloadData()
        }
    }
    
    func error(_ error: Error) {
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
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
