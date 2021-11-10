//
//  PlaceAnnotationView.swift
//  LocTest
//
//  Created by Arjit Bose on 11/8/21.
//

import SwiftUI
import Foundation
import MapKit



struct PlaceAnnotationView: View{
    
  var body: some View {
    VStack(spacing: 0) {
      Image(systemName: "mappin.circle.fill")
        .font(.title)
        .foregroundColor(.blue)

      Image(systemName: "arrowtriangle.down.fill")
        .font(.caption)
        .foregroundColor(.blue)
        .offset(x: 0, y: -5)
    }
  }
}
