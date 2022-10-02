//
//  HomeViewModel.swift
//  WaktaverseMusic
//
//  Created by YoungK on 2022/10/02.
//

import Foundation
import Combine

protocol HomeViewModelInput {
    // 라디오버튼

    // 더보기

    // 음악 재생

    // 이달의신곡 더보기

    // 이달의신곡 재생

    // 뉴스 더보기

    //
}

protocol HomeViewModelOutput {

}

final class HomeViewModel: ObservableObject {
    @Published var selectedIndex: Int = 0
    @Published var nowChart: [RankedSong] = [RankedSong]()
    @Published var newSongs: [NewSong] = [NewSong]()

    var subscription = Set<AnyCancellable>()

    init() {
        fetchTop20(category: .total) // 초기화  chart는 누적으로 지정
        fetchNewSong()
    }

    func fetchTop20(category: TopCategory) {
        Repository.shared.fetchTop20(category: category)
            .sink { _ in

            } receiveValue: { [weak self] (datas: [RankedSong]) in

                guard let self = self else {return}

                self.nowChart = datas  // chart 갱신

            }.store(in: &subscription)
    }

    func fetchNewSong() {
        Repository.shared.fetchNewMonthSong()
            .sink { completion in

                switch completion {
                case .failure(let err):
                    print(" \(#file) \(#function) \(#line) \(err.localizedDescription)")

                case .finished:
                    print(" \(#file) \(#function) \(#line) Finish")
                }

            } receiveValue: { [weak self] (rawData: newMonthInfo) in

                guard let self = self else {return}

                self.newSongs = rawData.data

            }.store(in: &subscription)
    }

    func didChangeNowChart(index: Int) {
        switch index {
        case 0:
            fetchTop20(category: .total)
        case 1:
            fetchTop20(category: .time)
        case 2:
            fetchTop20(category: .daily)
        case 3:
            fetchTop20(category: .weekly)
        case 4:
            fetchTop20(category: .monthly)
        default:
            fetchTop20(category: .total)
        }
    }

}
