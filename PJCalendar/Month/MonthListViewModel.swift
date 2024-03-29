//
//  MonthListViewModel.swift
//  PJCalendar
//
//  Created by Nicolas Bellon on 20/08/2019.
//  Copyright © 2019 Solocal. All rights reserved.
//

import Foundation

extension MonthViewModel: Equatable {
  static func == (lhs: MonthViewModel, rhs: MonthViewModel) -> Bool {
    return lhs.originalModels == rhs.originalModels
  }
}

extension MonthViewModel: Comparable {

  static func < (lhs: MonthViewModel, rhs: MonthViewModel) -> Bool {
    guard let firstLeft = lhs.originalModels.first, let firstRight = rhs.originalModels.first else { return false }
    return firstLeft < firstRight
  }
}

protocol MonthListViewModelDelegate: class {
  func shouldReloadMonth()
}

class MonthViewModel {

  private let originalModels: [DayApiModel]

  let monthText: String
  let yearText: String
  let dataController: CalendarDataController

  init?(model: [DayApiModel], dataController: CalendarDataController) {
    self.originalModels = model
    guard let first = model.first else { return nil }
    self.monthText = first.monthText.capitalized
    guard let year =  model.first?.yearText else { return nil }
    self.yearText = year
    self.dataController = dataController
  }

  func dayIsContainInThisMonth(day: DayApiModel) -> Bool {
    return self.originalModels.contains(day)
  }

  func userWantToShowDayOfThisMonth() {
    guard let first = self.originalModels.first else { return }
    self.dataController.updateSelectedDay(day: first)
  }

  static func getMonthsViewModelFrom(daysModel: [DayApiModel], datacontroller: CalendarDataController) -> [MonthViewModel] {

    var months: [MonthViewModel] = []

    var dest: [String : [DayApiModel]] = [:]

    for aDay in daysModel {
      if var tab = dest[aDay.monthText + aDay.yearText] {
        tab.append(aDay)
        dest[aDay.monthText + aDay.yearText] = tab
      } else {
        dest[aDay.monthText + aDay.yearText] = [aDay]
      }
    }

    for (_, value) in dest {
      if let month = MonthViewModel(model: value, dataController: datacontroller) {
        months.append(month)
      }
    }

    months.sort { return $0 < $1 }
    return months
  }

}

class MonthListViewModel {

  weak var delegate: MonthListViewModelDelegate?

  enum ArrowButtonDisplayState {
    case enable
    case disabled
    case loading
  }

  enum DisplayState {

    case notReady
    case monthSelected(monthSelected: Int, months: [MonthViewModel])

    static func getMonthIndexForDay(day: DayApiModel, months: [MonthViewModel]) -> Int? {
      if let first = (months.first { $0.dayIsContainInThisMonth(day: day) }) {
        return months.firstIndex(of: first)
      }
      return nil
    }

    func getMonthIndexForDay(day: DayApiModel) -> Int? {
      switch self {
      case .monthSelected(monthSelected: _, months: let months):
        return DisplayState.getMonthIndexForDay(day: day, months: months)
      case .notReady:
        return nil
      }
    }

    init(days: [DayApiModel], dataController: CalendarDataController) {
      let months = MonthViewModel.getMonthsViewModelFrom(daysModel: days, datacontroller: dataController)

      guard months.isEmpty == false else { self = .notReady; return }
      guard let selectedDay = dataController.selectedDayModel, let index = DisplayState.getMonthIndexForDay(day: selectedDay, months: months) else {
        self = .notReady; return
      }
      self = .monthSelected(monthSelected: index, months: months)
    }
  }

  var leftButtonDisplayState = Observable<ArrowButtonDisplayState>(.disabled)
  var rightButtonDisplayState = Observable<ArrowButtonDisplayState>(.disabled)

  let dataController: CalendarDataController
  var displayState: DisplayState {
    didSet {
      self.updateObservableValue()
    }
  }

  var monthsCount: Int {
    switch self.displayState {
    case .monthSelected(monthSelected: _, months: let months):
      return months.count
    case .notReady:
      return 0
    }
  }

  var selectedIndexPath = Observable<IndexPath>(IndexPath(item: 0, section: 0))

  subscript (index: IndexPath) -> MonthViewModel? {
    switch self.displayState {
    case .monthSelected(monthSelected: _, months: let months):
      guard index.item >= 0, index.item < months.count else { return nil }
      return months[index.item]
    case .notReady:
      return nil
    }
  }

  func updateLeftButtonIfNeeded(state: ArrowButtonDisplayState) {
    if self.leftButtonDisplayState.value != state {
      self.leftButtonDisplayState.value = state
    }
  }

  func updateRightButtonIfNeeded(state: ArrowButtonDisplayState) {
    if self.rightButtonDisplayState.value != state {
      self.rightButtonDisplayState.value = state
    }
  }

  func updateButtonsObservable(monthSelectedIndex: Int, months: [MonthViewModel]) {

    guard months.count != 0 else {
      self.updateLeftButtonIfNeeded(state: .disabled)
      self.updateRightButtonIfNeeded(state: .disabled)
      return
    }

    if monthSelectedIndex == 0 {
      self.updateLeftButtonIfNeeded(state: .disabled)
      self.updateRightButtonIfNeeded(state: .enable)
    }

    if monthSelectedIndex > 0 && monthSelectedIndex < months.count {
      self.updateLeftButtonIfNeeded(state: .enable)
      self.updateRightButtonIfNeeded(state: .enable)
    }

    if monthSelectedIndex == months.count - 1 && self.dataController.lazyLoadingState.value == .loading {
      self.updateRightButtonIfNeeded(state: .loading)
    } else if monthSelectedIndex == months.count - 1 {
      self.updateRightButtonIfNeeded(state: .disabled)
    }
  }

  func updateObservableValue() {
    switch self.displayState {
    case .monthSelected(monthSelected: let selected, months: let months):
      self.updateButtonsObservable(monthSelectedIndex: selected, months: months)
      let indexPath = IndexPath(item: selected, section: 0)
      if self.selectedIndexPath.value != indexPath {
        self.selectedIndexPath.value = indexPath
      }

    case .notReady:
      break
    }
  }

  func setupDataController() {

    self.dataController.lazyLoadingState.bind { _, state in
      switch self.displayState {
      case .monthSelected(monthSelected: let monthSelected, months: let months):
        self.updateButtonsObservable(monthSelectedIndex: monthSelected, months: months)
      case .notReady:
        break
      }
    }

    self.dataController.days.bind { [weak self] _, days in
      guard let `self` = self else { return }

      switch self.displayState {
      case .notReady:
        self.displayState = DisplayState(days: days, dataController: self.dataController)
        self.delegate?.shouldReloadMonth()
      case .monthSelected(monthSelected: let monthIndex, months: _):
        let months = MonthViewModel.getMonthsViewModelFrom(daysModel: days, datacontroller: self.dataController)
        self.displayState = .monthSelected(monthSelected: monthIndex, months: months)
        self.delegate?.shouldReloadMonth()
      }
    }

    self.dataController.selectedDay.bind { _, newIndex in
      guard let day = self.dataController.selectedDayModel else { return }
      guard let monthSelected = self.displayState.getMonthIndexForDay(day: day) else { return }
      switch self.displayState {
      case .monthSelected(monthSelected: _, months: let months):
        self.displayState = .monthSelected(monthSelected: monthSelected, months: months)
      case .notReady:
        break
      }
    }
  }

  func userWantToDisplayMonthDay(indexPath: IndexPath) {
    switch self.displayState {
    case .monthSelected(monthSelected: _, months: let months):
      if indexPath.item >= 0 && indexPath.item < months.count {
        months[indexPath.item].userWantToShowDayOfThisMonth()
      }
    case .notReady:
      break
    }
  }

  func userWantToDisplayNextMont() {
    switch self.displayState {
    case .monthSelected(monthSelected: _, months: let months):
      guard self.selectedIndexPath.value.item + 1 < months.count else { return }
    self.userWantToDisplayMonthDay(indexPath: IndexPath(item: self.selectedIndexPath.value.item + 1, section: 0))
    case .notReady:
      break
    }
  }

  func userWantToDisplayPreviousMonth() {
    guard self.selectedIndexPath.value.item - 1 >= 0 else { return }
    self.userWantToDisplayMonthDay(indexPath: IndexPath(item: self.selectedIndexPath.value.item - 1, section: 0))
  }

  init(dataController: CalendarDataController) {
    self.dataController = dataController
    self.displayState = DisplayState(days: self.dataController.days.value, dataController: dataController)
    self.setupDataController()
    self.updateObservableValue()
  }
}
