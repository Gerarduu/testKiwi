//
//  Buttons.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import Foundation
import UIKit

final class MyInfoButton: UIButton {
    
    override func awakeFromNib() {
        setupStyle()
    }
    
    func setupStyle() {
        backgroundColor = .systemBlue
        titleLabel?.font =  UIFont.boldSystemFont(ofSize: 14)
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = frame.height/2
    }
}
