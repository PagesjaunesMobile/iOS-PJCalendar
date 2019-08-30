//
//  CalendarViewController.swift
//  PJCalendar
//
//  Created by Nicolas Bellon on 25/07/2019.
//  Copyright © 2019 Solocal. All rights reserved.
//

import Foundation
import UIKit


class CalendarViewController: UIViewController {

  init(dataController: CalendarDataController) {
    self.dataController = dataController
    self.dayListViewModel = DayListViewModel(dataController: dataController)
    self.monthListViewModel = MonthListViewModel(dataController: dataController)
    self.slotListViewModel = TimeSlotListViewModel(dataController: dataController)

    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  let dataController: CalendarDataController

  let dayListViewModel: DayListViewModel
  let monthListViewModel: MonthListViewModel
  let slotListViewModel: TimeSlotListViewModel

  let collectionView: UICollectionView = {

    let layout = UICollectionViewFlowLayout() // CalendarFlowLayout()

    layout.headerReferenceSize = CGSize(width: HeaderCell.hearderheight, height: HeaderCell.hearderheight)

    layout.sectionHeadersPinToVisibleBounds = true
    let dest = UICollectionView(frame: .zero, collectionViewLayout: layout)
    dest.translatesAutoresizingMaskIntoConstraints = false

    dest.clipsToBounds = true
    return dest
  }()

  func setupCollectionView() {
    self.collectionView.backgroundColor = UIColor.black
    self.collectionView.isOpaque = true
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    self.collectionView.register(SlotCell.self,
                                 forCellWithReuseIdentifier: SlotCell.reusueIdentifier)
    self.collectionView.register(HeaderCell.self,
                                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                 withReuseIdentifier: HeaderCell.reusueIdentifier)

    self.collectionView.register(SlotHeaderCell.self,
                                 forCellWithReuseIdentifier: SlotHeaderCell.reusueIdentifier)
  }

  func setupDataController() {
    self.dataController.loadData()
  }

  func setupLayout() {
    var constraints = [NSLayoutConstraint]()

    constraints.append(self.collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor))
    constraints.append(self.collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor))
    constraints.append(self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor))
    constraints.append(self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor))

    NSLayoutConstraint.activate(constraints)
  }

  func setupView() {
    self.view.addSubview(self.collectionView)
  }

  func setupViewModel() {
    self.slotListViewModel.shouldDisplaySLots.bind { [weak self] _, result in
      guard let `self` = self else { return }
      if result == true {
        self.collectionView.reloadData()
      }
    }
    self.slotListViewModel.delegate = self
  }

  func setup() {
    self.setupView()
    self.setupLayout()
    self.setupCollectionView()
    self.setupViewModel()
    self.setupDataController()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
  }
}

extension CalendarViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

  }
}

extension CalendarViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.slotListViewModel.slotCount
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    guard self.slotListViewModel.shouldDisplayHeaderSlotCellForIndexPath(indexPath) == false else {
      return collectionView.dequeueReusableCell(withReuseIdentifier: SlotHeaderCell.reusueIdentifier, for: indexPath)
    }

    let dequeueCell = collectionView.dequeueReusableCell(withReuseIdentifier: SlotCell.reusueIdentifier, for: indexPath)

    guard let dest = dequeueCell as? SlotCell else { return dequeueCell }
    guard let model = self.slotListViewModel[indexPath.item] else { return dequeueCell }
    dest.configure(model: model)

    return dest
  }


  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
      let hederView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                      withReuseIdentifier: HeaderCell.reusueIdentifier, for: indexPath)
      guard let castedHeaderView = hederView as? HeaderCell else { return hederView }
      castedHeaderView.configure(monthListViewModel: self.monthListViewModel, dayListViewModel: self.dayListViewModel)
      return castedHeaderView
  }
}

extension CalendarViewController: UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    guard self.slotListViewModel.shouldDisplayHeaderSlotCellForIndexPath(indexPath) == false else
    { return  CGSize(width: collectionView.frame.width, height: 88) }

    return CGSize(width: 88, height: 40)

//    return SlotCell.cellSize
  }


}

extension CalendarViewController: TimeSlotListViewModelDelegate {
  func reloadSlots() {
    self.collectionView.reloadData()
  }
}
