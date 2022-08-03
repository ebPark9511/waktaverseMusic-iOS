//
//  PlaybackFullScreenView.swift
//  Billboardoo
//
//  Created by yongbeomkwak on 2022/07/29.
//

import SwiftUI
import Kingfisher
import UIKit

struct PlaybackFullScreenView: View {
    
    var animation: Namespace.ID //화면전환을 위한 애니메이션 Identify
    @EnvironmentObject var playState:PlayState
    var titleModifier = FullScreenTitleModifier()
    var artistModifier = FullScreenArtistModifer()
    
    let window = UIScreen.main.bounds
    var body: some View {
        let window = UIScreen.main.bounds
        let standardLen = window.width > window.height ? window.width : window.height
        
        if let currentSong = playState.nowPlayingSong
        {
            //if let artwork = bringAlbumImage(url: currentSong.image)
            
            HStack{
                VStack {
                    
                    //Spacer(minLength: 0)
                    /*
                     .aspectRatio(contentMode: .fit) == scaledToFit() ⇒ 이미지의 비율을 유지 + 이미지의 전체를 보여준다.
                     .aspectRatio(contentMode: .fill) ⇒ 이미지의 비율을 유지 + 이미지가 잘리더라도 꽉채움
                     */
                    //                    Image(uiImage: artwork)
                    
                    
                    Group{ //그룹으로 묶어 조건적으로 보여준다.
                        if playState.isPlayerListViewPresented {
                            
                            PlayListView().environmentObject(playState)
                            
                                
                        }
                        
                        else
                        {
                            KFImage(URL(string: currentSong.image)!)
                                .resizable()
                                .frame(width:standardLen*0.5,height: standardLen*0.5)
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding()
                                .scaleEffect(playState.isPlaying == .playing ? 0.8 : 0.6)
                                .shadow(color: .black.opacity(playState.isPlaying == .playing ? 0.2:0.0), radius: 30, x: -60, y: 60)
                            //각 종 애니메이션
                        }
                        
                        
                    }
                    
                    
                    
                    
                    HStack{
                        
                        if playState.isPlayerListViewPresented { //ListView가 켜지면 작은 썸네일 보이게 
                            KFImage(URL(string: currentSong.image)!)
                                .resizable()
                                .frame(width:standardLen*0.1,height: standardLen*0.1)
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                
                                
                        }
                      
                        //  이미지 와 함께 중앙정렬 -> PlayList 꾸미러 가자
                        
                        
                        
                        VStack(alignment:.leading){
                            Text(currentSong.title)
                                .modifier(titleModifier)
                            
                            Text(currentSong.artist)
                                .modifier(artistModifier)
                        }
                        
                    }
                    .padding(.trailing, playState.isPlayerListViewPresented ? standardLen*0.1 : 0) //리스트 보여줄 때는 이미지 width만큼 padding
                    .padding(.bottom,30)
                    
                    
                    
                    Spacer(minLength: 0)
                    
                    ProgressBar().padding(.horizontal)
                    
                    Spacer(minLength: 0)
                    
                    
                    
                    PlayBar().environmentObject(playState)
                        .padding(.bottom,60) //밑에서 띄우기
                        .padding(.horizontal)
                    
                    
                    
                    
                }
            }
            
            .frame(width: window.width, height: window.height)
            .padding(.horizontal)
            .background(
                
                //                    Rectangle().foregroundColor(Color(artwork.averageColor ?? .clear)) //평균 색깔 출후 바탕에 적용
                //                        .saturation(0.5) //포화도
                //                        .background(.ultraThinMaterial) // 백그라운드는 blur 처리
                //                        .edgesIgnoringSafeArea(.all)
                
                // playList 백그라운드 색 해결 못해서 주석 ..
                //.ultraThinMaterial
                
            )
            
            
            
        }
        
        
    }
}


struct PlayBar: View {
    
    var buttonModifier: FullScreenButtonImageModifier = FullScreenButtonImageModifier()
    @EnvironmentObject var playState:PlayState
    
    var body: some View {
        HStack
        {
            
            Button {  //리스트 버튼을 누를 경우 animation과 같이 toggle
                withAnimation(Animation.spring(response: 0.3, dampingFraction: 0.85)) {
                    playState.isPlayerListViewPresented.toggle()
                }
                
            }label: {
                Image(systemName: "music.note.list")
                    .resizable()
                    .modifier(buttonModifier)
            }
            
            
            Spacer()
            
            Button {
                playState.backWard()
                //토스트 메시지 필요
            } label: {
                Image(systemName: "backward.fill")
                    .resizable()
                    .modifier(buttonModifier)
                
            }
            
            PlayPuaseButton().environmentObject(playState)
            
            
            
            
            Button {
                playState.forWard()
                //토스트 메시지 필요
            } label: {
                Image(systemName: "forward.fill")
                    .resizable()
                    .modifier(buttonModifier)
                
            }
            
            Spacer()
            
            Button {
                print("Sound!!")
            } label: {
                Image(systemName: "speaker.wave.3.fill")
                    .resizable()
                    .modifier(buttonModifier)
                
            }
            
            
            
            
            
        }
        .accentColor(Color("PrimaryColor"))
    }
}

struct ProgressBar: View{
    
    @EnvironmentObject var playState:PlayState
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    @State var playtime:String = "00:00"
    @State var endtime:String = "00:00"
    
    
    var body: some View{
        
        if let currentSong = playState.nowPlayingSong {
            VStack {
                ProgressView("",value: playState.currentProgress,total: 100)
                
                
                HStack{
                    
                    Text(playtime).modifier(FullScreenTimeModifer())
                    Spacer()
                    Text(endtime).modifier(FullScreenTimeModifer())
                }
                
            }.onReceive(timer) { _ in
                
                playState.youTubePlayer.getCurrentTime { completion in
                    switch completion{
                    case .success(let time):
                        playState.currentProgress = (time/playState.endProgress) * 100
                        playtime = playState.convertTimetoString(time)
                        endtime = playState.convertTimetoString(playState.endProgress)
                        //print("\(playState.currentProgress)  \(playState.endProgress)")
                    case.failure(let err):
                        print("currentProgress Error")
                    }
                }
            }
        }
    }
}

func bringAlbumImage(url:String) ->UIImage?
{
    let url = URL(string: url)
    let data = try? Data(contentsOf: url!)
    return UIImage(data: data!)
}

extension UIImage {
    //평균 색깔 구역
    var averageColor: UIColor? {
        
        //UIImage를 CIImage로 변환
        guard let inputImage = CIImage(image: self) else{ return nil }
        
        // extent vector 생성 ( width와 height은 input 이미지 그대로)
        let extentVector = CIVector (x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        
        //CIAreaAverage 이름이란 필터 만듬 , image에서 평균 색깔을 뽑아낼 것
        guard let filter = CIFilter(name: "CIAreaAverage",parameters:[kCIInputImageKey:inputImage, kCIInputExtentKey: extentVector]) else { return nil}
        
        //필터로 부터 뽑아낸 이미지
        guard let outputImage = filter.outputImage else { return nil}
        
        // bitmap (r,g,b,a)
        var bitmap = [UInt8](repeating: 0, count: 4)
        
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        
        // output 이미지를 1대1로 bitmap에 r g b a값을 뽑아내어 bitmap 배열 채워 랜더시킨다
        
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        
        //bitmap image를 rgba UIColor로 변환
        return UIColor(red: CGFloat(bitmap[0])*0.6/255, green: CGFloat(bitmap[1])*0.6/255, blue: CGFloat(bitmap[2])*0.6/255, alpha: CGFloat(bitmap[3])/255)
        
    }
}
