//
//  ContentView.swift
//  BetterSleep
//
//  Created by Ananya George on 10/14/21.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var sleepAmount: Double = 8.0
    @State private var wakeUp: Date = defaultWakeUpTime
    @State private var coffeeAmount = 1
//    TODO: remove alert and calculate button, display time on screen 
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var showingAlert = false
    
    
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
            }
            .navigationTitle("BetterSleep")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: calculateBedtime) {
                        Text("Calculate")
                    }
                }
            }
            
            
        }
    }
    static var defaultWakeUpTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func calculateBedtime() {
        let model: SleepCalculator = {
            do {
                let config = MLModelConfiguration()
                return try SleepCalculator(configuration: config)
            } catch {
                print(error)
                fatalError("Couldn't create SleepCalculator")
            }
        }()
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minutes = (components.minute ?? 0) * 60
        
        do {
            let prediction = try  model.prediction(wake: Double(hour + minutes), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            alertTitle = "Your ideal bedtime is"
            alertMessage = formatter.string(from: sleepTime)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime"
        }
        
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
