//
//  detailView.swift
//  Ibum
//
//  Created by tanaka niko on 2025/06/06.
//

import SwiftUI
import _SwiftData_SwiftUI
import Photos
import UIKit

struct DetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
//    @State var position:CGPoint
    @State var scale:CGFloat = 1
    @State var width = UIScreen.main.bounds.width / 4 * 3
    @Binding var photo:Photo
    @State var title:String = ""
    @Query private var quests: [Quest]
    
    @State var isShowAlert = false
    @State var isShowSavedAlert = false
    @State var showToSettingAlert = false
    @State var phtoSavedAlert = false
    
    @Binding var clearSum : Int
    
    @State var photos: [Photo] = []
    

    var body: some View {
        ZStack{
            ZStack{
                Image(uiImage: UIImage(data: photo.photoData)!)
                    .resizable()
                    .scaleEffect(scale * 2)
//                    .frame(width: width)
                    .scaledToFit()
                    .position(CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 4))
                    .opacity(0.5)
                    
                Color.white
                    .frame(height: UIScreen.main.bounds.height / 2)
                    .position(CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 4 * 3))
                    .ignoresSafeArea()
            }
                

            VStack{
                Text(photo.questTitle)
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .padding(.top,UIScreen.main.bounds.height / 8)
                Image(uiImage: UIImage(data: photo.photoData)!)
                    .resizable()
                    .scaledToFit()
//                    .scaleEffect(scale)
//                    .frame(width: width)
                    .clipShape(Circle())
                    .padding([.leading,.trailing],50)
                    .overlay() {
                          Circle()
                            .stroke(.white, lineWidth: 10)
                            .padding([.leading,.trailing],50)
//                            .frame(width: 80,height:80)
//                            .frame(width: width)
//                            .padding(.bottom, 50)
                            
                        }
                ScrollView(.horizontal) {
                            HStack {
                                ForEach(photos, id: \.self) { photo in
                                    Image(uiImage:UIImage(data:photo.photoData)!)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100)
                                        .frame(maxHeight: 150)
//                                        .background(Color.cyan)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                                        .padding(10)
                                        .padding(.horizontal,10)
                                }
                            }
//                            .scrollTargetLayout()
                        }
//                .scrollTargetBehavior(.viewAligned)
                Spacer()
                HStack{
                    
                    Button(action:{
                        isShowAlert.toggle()
                    }){
                        Image(systemName: "trash")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.red)
                            .padding()
                        
                            .frame(width: 60,height:60)
                    }.alert("確認", isPresented: $isShowAlert) {
                        // ダイアログ内で行うアクション処理...
                        Button("戻る",role: .cancel){}
                        Button("削除",role: .destructive){
                            Task{
                               deletePhoto()
                            }
                           
                            
                            
                        }

                    } message: {
                        // アラートのメッセージ...
                        Text("データの削除を実行しますか？")
                    }
                    .alert("保存不可",isPresented: $showToSettingAlert){
                        Button("戻る"){}
                        Button("設定へ"){
                            
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }
                    }message:{
                        Text("フォトへのフルアクセスを許可してください")
                    }
                    .alert("保存完了",isPresented: $phtoSavedAlert){
                        Button("戻る"){}
                    }message:{
                        Text("画像が本体に保存されました")
                    }
                  Spacer()
                    Button(action: {
                        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
                        if  status == .limited || status == .denied {
                            showToSettingAlert.toggle()
                        }
                        if status == .authorized{
                            UIImageWriteToSavedPhotosAlbum(UIImage(data: photo.photoData)!, nil,nil,nil)
                            phtoSavedAlert.toggle()
                        }else{
                            Task{
                                await PHPhotoLibrary.requestAuthorization(for: .readWrite)
                            }
                            
                        }
                    }){
                        Image(systemName:"square.and.arrow.down")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.blue)
                            .padding()
                            .frame(width: 60,height:60)
                        
                    }
                
                }
            }
        }
        
        
    }
    
    @MainActor
    func deletePhoto(){
        do{
            let descriptor = FetchDescriptor<Quest>(predicate: #Predicate<Quest>{$0.title == title})
            let currentQuest = try context.fetch(descriptor).first
            currentQuest?.photos.removeAll()
            context.delete(photo)
            
            try context.save()
            
            clearSum -= 1
            dismiss()
        }catch{
            print(error)
        }
        
    }
}

//#Preview {
//    DetailView(position: CGPoint(x: 500, y: 500))
//}
