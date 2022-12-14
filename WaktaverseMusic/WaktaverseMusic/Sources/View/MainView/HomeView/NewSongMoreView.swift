//
//  SwiftUIView.swift
//  Billboardoo
//
//  Created by yongbeomkwak on 2022/08/11.
//

import SwiftUI
import Foundation
import Combine
import Kingfisher

// MARK: 이달의 신곡 더보기를 눌렀을 때 나오는 뷰 입니다.
struct NewSongMoreView: View {

    @EnvironmentObject var playState: PlayState
    @Binding var newsongs: [NewSong]
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> // 스와이프하여 뒤로가기를 위해
    let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 0), count: 2)

    // GridItem 크기 130을 기기의 가로크기로 나눈 몫 개수로 다이나믹하게 보여줌

    // private var columns:[GridItem] = [GridItem]()

    var body: some View {

        if newsongs.count == 0 {
            VStack {
                Text("이달의 신곡이 아직 없습니다.").modifier(PlayBarTitleModifier())
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .background() // 전체 영역을 건드리기 위해
                .gesture(DragGesture().onEnded({ value in
                    if(value.translation.width > 100) // 왼 오 드래그가 만족할 때
                    {
                        self.presentationMode.wrappedValue.dismiss() // 뒤로가기
                    }
                }))
        } else {
            ScrollView(.vertical, showsIndicators: false) {

                    LazyVGrid(columns: columns, spacing: 0) {
                        TwoColumnsGrid
                    }

            }.navigationTitle("이달의 신곡")
                .gesture(DragGesture().onEnded({ value in
                    if(value.translation.width > 100) // 왼 오 드래그가 만족할 때
                    {
                        self.presentationMode.wrappedValue.dismiss() // 뒤로가기
                    }
                }))
        }

    }
}

extension NewSongMoreView {

    var TwoColumnsGrid: some View {

        ForEach(newsongs, id: \.self.id) { song in
            let width = UIScreen.main.bounds.width/2.5
            let simpleSong = SimpleSong(song_id: song.song_id, title: song.title, artist: song.artist)
            VStack(alignment: .center) {

                KFImage(URL(string: song.song_id.albumImage())!)
                    .placeholder({
                        Image("PlaceHolder")
                            .resizable()
                            .frame(width: width, height: width)
                            .transition(.opacity.combined(with: .scale))
                    })
                    .resizable()
                    .frame(width: width, height: width)
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(10)
                    .overlay {
                        Button {
                            playState.play(at: simpleSong)
                            playState.playList.uniqueAppend(item: simpleSong) // 현재 누른 곡 담기
                        } label: {
                            Image(systemName: "play.fill")
                                .resizable()
                                .frame(width: width/8, height: width/8)
                                .foregroundColor(.white)
                        }

                    }

                VStack(alignment: .leading) {
                    Text(song.title).font(.system(size: 13, weight: .semibold, design: Font.Design.default)).lineLimit(1).frame(width: width, alignment: .leading)
                    Text(song.artist).font(.caption).lineLimit(1).frame(width: width, alignment: .leading)
                    Text(song.date.convertReleaseTime()).font(.caption2).foregroundColor(.gray).lineLimit(1).frame(width: width, alignment: .leading)
                }.frame(width: width)

            }.padding(.vertical, 5).onTapGesture {
                playState.play(at: simpleSong)
                playState.playList.uniqueAppend(item: simpleSong) // 현재 누른 곡 담기
            }

        }

    }
}
