//
//  SlotCell.swift
//  PJCalendar
//
//  Created by Nicolas Bellon on 25/07/2019.
//  Copyright © 2019 Solocal. All rights reserved.
//

import Foundation
import UIKit

class SlotCell: UICollectionViewCell {

  static let cellSize =  CGSize(width: 50, height: 50)

  let titleLabel: UILabel = {
    let dest = UILabel(frame: .zero)
    dest.translatesAutoresizingMaskIntoConstraints = false
    dest.backgroundColor = UIColor.red
    return dest
  }()

  func setupLayout() {
    var constraints = [NSLayoutConstraint]()

    constraints.append(self.titleLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor))
    constraints.append(self.titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor))

    constraints.append(self.titleLabel.leftAnchor.constraint(greaterThanOrEqualTo: self.contentView.leftAnchor, constant: 5))
    constraints.append(self.titleLabel.rightAnchor.constraint(lessThanOrEqualTo: self.contentView.rightAnchor, constant: -5))
    constraints.append(self.titleLabel.topAnchor.constraint(greaterThanOrEqualTo: self.contentView.topAnchor, constant: 5))
    constraints.append(self.titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.contentView.bottomAnchor, constant: -5))

    NSLayoutConstraint.activate(constraints)
  }

  func setupView() {
    self.contentView.backgroundColor = .green
    self.contentView.addSubview(self.titleLabel)
  }

  func setup() {
    self.setupView()
    self.setupLayout()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
  }

  func configure(model: TimeSlotViewModel) {
    self.titleLabel.text = model.displayText
  }

  static let reusueIdentifier = String(describing:self)

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}