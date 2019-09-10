//
//  CalendarDataController.swift
//  PJCalendar
//
//  Created by Nicolas Bellon on 19/08/2019.
//  Copyright © 2019 Solocal. All rights reserved.
//

import Foundation

class CalendarDataController {

  enum LoadingState {
    case ready
    case loading
    case error
  }

  let morningName = "Matin"
  let afterNoonName = "Apres midi"

  var loadingState = Observable<LoadingState>(.loading)

  let apiService: RdvApiService

  var days: Observable<[DayApiModel]> = Observable<[DayApiModel]>([])
  var selectedDay: Observable<Int> = Observable<Int>(0)
  var selectedSlot: Observable<Int?> = Observable<Int?>(nil)
  
  var selectedDayModel: DayApiModel? {
    guard selectedDay.value >= 0, selectedDay.value < self.days.value.count else { return nil }
    return self.days.value[self.selectedDay.value]
  }

  var selectedSlotModel: SlotApiModel? {
    guard let selectedDay = self.selectedDayModel else { return nil }
    guard let selectedSlot = self.selectedSlot.value else { return nil }
    guard selectedSlot >= 0, selectedSlot < selectedDay.slots.count else { return nil }
    return selectedDay.slots[selectedSlot]
  }

  init(apiService: RdvApiService) {
    self.apiService = apiService
  }

  func updateSelectedDay(day: DayApiModel) {
    if let dest = self.days.value.firstIndex(of: day) {
      self.selectedDay.value = Int(dest)
      self.selectedSlot.value = nil
    }
  }
  
  func updateSelectedSlot(slot: SlotApiModel) -> Bool {
    guard let day = self.selectedDayModel else { return false }
    guard let index = day.slots.firstIndex(of: slot) else { return false }
    self.selectedSlot.value = Int(index)
    return true
  }

  func getFirstDayWithSlotBefore(day: DayApiModel) -> DayApiModel? {
    return self.days.value.filter { ($0 < day) && $0.slots.isEmpty == false }.first
  }

  func getFisrtDayWithSlotAter(day: DayApiModel) -> DayApiModel? {
    return self.days.value.filter { ($0 > day) && $0.slots.isEmpty == false }.first
  }

  func loadData() {
    self.loadingState.value = .loading
    self.apiService.makeRequest { result in
      switch result {
      case .success(rdvList: let model):
        self.loadingState.value = .ready
        self.days.value = model
        self.selectedDay.value = 0
      case .error:
        self.loadingState.value = .error
      }
    }
  }

}
