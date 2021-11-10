//
//  MapView.swift
//  LocTest
//
//  Created by Arjit Bose on 10/31/21.
//

import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView

    @State private var searchString = String()
    @Binding var description: String
    @Binding var directions: [String]
    @Binding var eta: String
    @Binding var createDirections: Bool

    class Coordinator: NSObject, MKMapViewDelegate {
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            print("Called!")
            let render = MKPolylineRenderer(overlay: overlay)
            render.strokeColor = .orange
            render.lineWidth = 5
            return render
        }
        

    }


    func makeCoordinator() -> Coordinator {

        return Coordinator()

    }


    func makeUIView(context: Context) -> MKMapView {
        
      let mapView = MKMapView()
        mapView.showsUserLocation = true
      mapView.delegate = context.coordinator


      return mapView
    }


    func updateUIView(_ uiView: MKMapView, context: Context){
        
        uiView.delegate = context.coordinator

        
        //removes any existing overlays and annotations before creating new ones
        removeAnnotations(uiView)
        addAnnotations(uiView)
            
    }
        
        func removeAnnotations(_ uiView: MKMapView){
            
            let overlays = uiView.overlays
            uiView.removeOverlays(overlays)
            let annotations = uiView.annotations
            uiView.removeAnnotations(annotations)
        }
        
    
        func addAnnotations(_ uiView: MKMapView) {
            //initializing the search as an MKLocalSearch for the location that is passed in
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = description // This is where you can pass in you search string parameter.
            let search = MKLocalSearch(request: searchRequest)


            
            search.start { response, error in
                //MKLocalSearch's response to my request
                guard let response = response else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error").")
                    return
                }
                
                //item is the first map item from response
                let item = response.mapItems[0]
                //annotate the destination
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                    
                    
                uiView.addAnnotation(annotation)
                
                if(!createDirections){
                    uiView.setRegion(MKCoordinateRegion(center: item.placemark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)), animated: false)
                }
                    
                createDir(item, uiView)
            }
       }
    
    func createDir(_ item: MKMapItem, _ uiView: MKMapView){
        if(createDirections){
            print("directions showing")
            let p2 = item.placemark
            let request = MKDirections.Request()
        
        
            //details of the request
            request.source = .forCurrentLocation()
            request.destination = MKMapItem(placemark: p2)
            request.transportType = .automobile

            
            let directions = MKDirections(request: request)
              
            
            directions.calculate { response, error in
            //making a route if it exists
              guard let route = response?.routes.first else { return }
                
                
            //drawing the route on the map
              uiView.addOverlay(route.polyline)
              uiView.setVisibleMapRect(
                route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: true)
                
                
                
            //storing the directions
              self.directions = route.steps.map { $0.instructions }.filter { !$0.isEmpty }
            
                getEta(route)
            }
        }
    }
    
    
    func getEta(_ route: MKRoute){
        //expected time for arrival
            var str = ""
            if(Int(route.expectedTravelTime)/3600 != 0){
                str = "\(Int(route.expectedTravelTime)/3600) hr \(Int(route.expectedTravelTime.truncatingRemainder(dividingBy: 60))) min"
            }
            else{
                str = "\(Int(route.expectedTravelTime)/60) min"
            }
            let time = Date() + route.expectedTravelTime
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            let stringDate = timeFormatter.string(from: time)
            self.eta = "\(stringDate) (\(str))"
    }

}
