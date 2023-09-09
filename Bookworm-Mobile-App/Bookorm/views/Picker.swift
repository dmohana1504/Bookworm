//
//  Picker.swift
//  Bookorm
//
//  Created by Student Account  on 4/15/23.
//

import Foundation
import SwiftUI
import CoreData

struct ContentView: View {
    @FetchRequest
    var bookList: FetchedResults<BookList>
    @State var selectedList = ""
    var body: some View {
        VStack{
            Picker("", selection: $selectedList){
                ForEach(bookList) { bookList in
                    Text(bookList.title ?? "")
                        .tag(bookList)
                }
            }
            .pickerStyle(WheelPickerStyle())
            Text("\(bookList.count)")
        }
    }
}
