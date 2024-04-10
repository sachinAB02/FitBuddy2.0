//
//  ContentView.swift
//  FitBuddy
//
//  Created by Sachin on 2023-12-28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView{
            VStack{
                Image(uiImage: #imageLiteral(resourceName: "Logo.png"))
                    .resizable()
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10), style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/))
                    .padding()
                Spacer()
                Text("Click below to navigate to the AR Body Traking view")
                    .multilineTextAlignment(.center)
                    .padding()
                NavigationLink(destination: JointTrackingView(), label: {
                    Text("Body Tracking")
                })
                .buttonStyle(.borderedProminent)
                .padding()
                Text("Click below to navigate to Export Data View")
                    .multilineTextAlignment(.center)
                    .padding()
                NavigationLink(destination: DownloadView(), label: {
                    Text("Export Data")
                })
                .buttonStyle(.borderedProminent)
                .padding()
                Spacer()
            }
            
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
