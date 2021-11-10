//
//  ContentView.swift
//  LocTest
//
//  Created by Arjit Bose on 10/29/21.
//

import MapKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var locationService = LocationService()
    @StateObject private var viewModel = ContentViewModel()
    @State var description: String = ""
    @State private var directions: [String] = []
    @State private var showDirections = false
    @State var createDirections = false
    @State private var eta: String = "" 
    
    var body: some View {
        
        VStack {
            MapView(description: $description, directions: $directions, eta: $eta, createDirections: $createDirections)
                .onAppear{
                    viewModel.checkIfLocationServicesIsEnabled()
                }
                .ignoresSafeArea(edges: .top)
        
                    Form {
                        Section(header: Text("Location Search")) {
                            ZStack(alignment: .trailing) {
                                TextField("Search", text: $locationService.queryFragment)
                                    .disableAutocorrection(true)
                                // This is optional and simply displays an icon during an active search
                                if locationService.status == .isSearching {
                                    Image(systemName: "clock")
                                        .foregroundColor(Color.gray)
                                }
                            }
                        }
                        Section(header: Text("Results")) {
                            List {
                                
                                //checking for errors or no results
                                Group {
                                    switch locationService.status {
                                    case .noResults:
                                        Text("No Results")
                                    case .error(let description):
                                        Text("Error: \(description)")
                                    default:
                                        EmptyView()
                                    }
                                }.foregroundColor(Color.gray)
                                 
                                //displaying the search results
                                List(locationService.searchResults, id: \.self) { completionResult in
                                    VStack(alignment: .leading){
                                        HStack{
                                            Button(action: {
                                                if(completionResult.subtitle != "United States") {
                                                    self.description = completionResult.subtitle
                                                    
                                                }
                                                else{
                                                    self.description = completionResult.title
                                                }
                                                self.createDirections = false
                                                
                                            }) {
                                                Text(completionResult.title)
                                                    .foregroundColor(Color.blue)
                                            } .buttonStyle(BorderlessButtonStyle())
                                            Text(completionResult.subtitle)
                                                .font(.subheadline)
                                                .foregroundColor(Color.gray)
                                            Spacer()
                                            Button(action: {
                                                description = ""
                                                if(completionResult.subtitle != "United States") {
                                                    self.description = completionResult.subtitle
                                                    
                                                }
                                                else{
                                                    self.description = completionResult.title
                                                }
                                                self.createDirections = true
                                            }) {
                                                Text("Directions")
                                            } .buttonStyle(BorderlessButtonStyle())
                                        }
                                               
                                    }
                                }
                            }
                        }
                    }
            //button to toggle showDirections
            Button(action: {
              self.showDirections.toggle()
            }, label: {
              Text("Show directions")
            })
            .disabled(directions.isEmpty)
            .padding()
            
            //displaying directions
          }.sheet(isPresented: $showDirections, content: {
            VStack(spacing: 0) {
              Text("Directions")
                .font(.largeTitle)
                .bold()
                .padding()
              Text("ETA = \(eta)")
                .font(.subheadline)
                .bold()
                .padding()
              
              Divider().background(Color.blue)
              
              List(0..<self.directions.count, id: \.self) { i in
                Text(self.directions[i]).padding()
              }
            }
          })
        }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

