//
//  SearchViewModel.swift
//  WaktaverseMusic
//
//  Created by YoungK on 2022/10/02.
//

import Foundation
import Combine

final class SearchViewModel: ObservableObject {
    @Published var currentValue: String
    @Published var debouncedValue: String
    @Published var results: [NewSong] = [NewSong]()
    @Published var type: SearchType
    @Published var showBottomSheet: Bool
    var subscription = Set<AnyCancellable>()

    init(initalValue: String, delay: Double = 0.5) {
        _currentValue = Published(initialValue: initalValue)
        _debouncedValue = Published(initialValue: initalValue)
        type = .title
        showBottomSheet = false

        $currentValue
            .removeDuplicates()
            .debounce(for: .seconds(delay), scheduler: RunLoop.main)
            .assign(to: &$debouncedValue)
    }

    deinit {

        print("❌ SearchViewModel deinit")
    }

    func fetchSong(_ keyword: String) {

        Repository.shared.fetchSearchWithKeyword(keyword, self.type)
            .sink { (_) in

            } receiveValue: { [weak self] (data: [NewSong]) in
                self?.results = data
            }.store(in: &subscription)

    }
}
