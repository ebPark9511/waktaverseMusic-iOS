//
//  FiveRowSongGridMoreView.swift
//  Billboardoo
//
//  Created by yongbeomkwak on 2022/07/22.
//

import SwiftUI
import Kingfisher

struct FourRowSongGridView: View {

    private let rows = [GridItem(.fixed(40), spacing: 10), // fixed 행 크기 ,spacing, 행간의 거리
                        GridItem(.fixed(40), spacing: 10),
                        GridItem(.fixed(40), spacing: 10),
                        GridItem(.fixed(40), spacing: 10)]

    @Binding var nowChart: [RankedSong]
    @EnvironmentObject var playState: PlayState

    var body: some View {

        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { (proxy: ScrollViewProxy) in

                VStack(alignment: .leading) {
                    LazyHGrid(rows: rows, spacing: 30) { // GridItem 형태와, 요소간 옆 거리
                        FourRowSongGridItemViews.environmentObject(playState).id(0)
                    }
                }
                .onChange(of: nowChart) { _ in
                    withAnimation(.easeOut) {
                        proxy.scrollTo(0)
                    }
                }

            }.padding()

        }
    }

}

private extension FourRowSongGridView {

    var FourRowSongGridItemViews: some View {

        ForEach(nowChart.indices, id: \.self) { index in // 여기서 id설정이 굉장히 중요하다. indices로 접근하기 때문에 속성의 id 말고 \.self를 사용함
            let song = nowChart[index]

            Button {
                // FiveRowSong Grid에서는 재생 버튼 누르면 일단 load와 currentSong을 바꿈
                let simpleSong = SimpleSong(song_id: song.song_id, title: song.title, artist: song.artist)
                playState.play(at: simpleSong)
                playState.playList.uniqueAppend(item: simpleSong) // 현재 누른 곡 담기
            } label: {
                ZStack {
                    HStack {
                        AlbumImageView(url: nowChart[index].song_id.albumImage())
                        RankView(now: index+1, last: nowChart[index].last)

                        // 타이틀 , Artist 영역
                        VStack {
                            Text("\(nowChart[index].title)").font(.system(size: 13)).frame(width: 150, alignment: .leading)
                            Text("\(nowChart[index].artist)").font(.system(size: 11)).frame(width: 150, alignment: .leading)
                        }
                    }
                }
            }.accentColor(.primary)

        }
    }
}

struct AlbumImageView: View {

    var url: String
    var body: some View {
        KFImage(URL(string: url)!)
            .cancelOnDisappear(true)
            .placeholder {
                Image("PlaceHolder")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .transition(.opacity.combined(with: .scale))
            }

            .onSuccess { _ in

            }
            .onFailure { _ in

            }
            // 대부분 500*500 or 480*360 으로 들어옴
            .downsampling(size: CGSize(width: 200, height: 200)) // 약 절반 사이즈
            .resizable()
            .frame(width: 40, height: 40) // resize
    }
}
