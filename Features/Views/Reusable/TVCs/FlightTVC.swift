//
//  FlightTVC.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import Foundation
import UIKit

protocol FlightTVCDelegate: class {
    func pushInfo(deepLink: URL)
}

class FlightTVC: UITableViewCell {
    
    @IBOutlet weak var flightView: UIView!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var fromDescLbl: UILabel!
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var toDescLbl: UILabel!
    @IBOutlet weak var toLbl: UILabel!
    @IBOutlet weak var infoBtn: MyInfoButton!
    
    var flight: Flight?
    
    weak var delegate: FlightTVCDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func setupUI() {
        
        flightView.layer.borderWidth = 2
        flightView.layer.borderColor = kColorLightGray.cgColor
        flightView.layer.cornerRadius = 8
        
        fromDescLbl.font = UIFont.systemFont(ofSize: 10)
        fromDescLbl.textColor = .gray
        fromDescLbl.text = "flight_tvc.from_desc".localized
        fromLbl.font = UIFont.boldSystemFont(ofSize: 30)
        
        durationLbl.font = UIFont.systemFont(ofSize: 10)
        
        toDescLbl.textColor = .gray
        toDescLbl.font = UIFont.systemFont(ofSize: 10)
        toDescLbl.text = "flight_tvc.to_desc".localized
        toLbl.font = UIFont.boldSystemFont(ofSize: 30)
        
        infoBtn.setTitle("flight_tvc.flight_info_btn".localized, for: .normal)
    }
    
    func configureCell(with flight: Flight) {
        self.flight = flight
        
        durationLbl.text = self.flight?.flyDuration
        fromLbl.text = self.flight?.flyFrom
        toLbl.text = self.flight?.flyTo
    }
    
    @IBAction func actionInfo(_ sender: Any) {
        guard let url = self.flight?.deepLink else {return}
        delegate?.pushInfo(deepLink: url)
    }
}
