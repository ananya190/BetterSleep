//
//  ContentView.swift
//  BetterSleep
//
//  Created by Ananya George on 10/14/21.
//

import SwiftUI
import CoreML

struct ContentView: View {
    let model: SleepCalculator = {
        do {
            let config = MLModelConfiguration()
            return try SleepCalculator(configuration: config)
        } catch {
            print(error)
            fatalError("Couldn't create SleepCalculator")
        }
    }()
    
    private var calculatedBedTime: String {
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minutes = (components.minute ?? 0) * 60
        
        do {
            let prediction = try  model.prediction(wake: Double(hour + minutes), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
           return formatter.string(from: sleepTime)
        } catch {
            return "Sorry, there was a problem calculating your bedtime"
        }
    }
    
    @State private var sleepAmount: Double = 8.0
    @State private var wakeUp: Date = defaultWakeUpTime
    @State private var coffeeAmount = 1
//    TODO: remove alert and calculate button, display time on screen
//    @State private var alertMessage = ""
//    @State private var alertTitle = ""
//    @State private var showingAlert = false
    
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 10) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("", selection: $wakeUp, displayedComponents:.hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper(value: $sleepAmount, in: 4.0 ... 12.0, step: 0.25) {
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    Picker("\(coffeeAmount) " + (coffeeAmount == 1 ? "cup" : "cups"), selection: $coffeeAmount){
                        ForEach(0..<21) {
                            Text("\($0) " + ($0 == 1 ? "cup" : "cups"))
                        }
                    }
                }
                
                Section {
                    VStack(alignment: .center) {
                        Text("Your ideal bedtime is")
                            .font(.headline)
                        HStack {
                            Spacer()
                            Text(calculatedBedTime)
                                .font(.largeTitle)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("BetterSleep")
            
            
        }
    }
    static var defaultWakeUpTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
