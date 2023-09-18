//
//  ContentView.swift
//  marco
//
//  Created by ap on 1/2/2566 BE.
//

import SwiftUI
import AppKit

struct ContentView: View {
    
    @State var isOverContentView: Bool = false
    @State var timer:Timer?
    @State var counter = 0
    @State var maxCounter = 10
    @State var positionX = 0.0
    @State var positionY = 35.0
    @State var isAutoPosition = false
    @ObservedObject var viewTF = ContentViewTextTextField()
    @State private var isEditSettings: Bool = false
    @State var detactEvent = DetactEvent()
    var body: some View {
        
        VStack(spacing: 23){
            VStack(alignment: .leading){
                Text("Settings")
                    .bold()
                HStack(spacing: 8){
                    Text("position:").frame(width: 100)
                    TextField("X:", text: $viewTF.positionXText).frame(width: 100)
                        .disabled(!self.isEditSettings)
                    
                    TextField("Y:", text: $viewTF.positionYText).frame(width: 100).disabled(!self.isEditSettings)
                    Button{
                        if self.isAutoPosition{
                            self.isAutoPosition = false
                            self.detactEvent.stop()
                        }else{
                            self.isAutoPosition = true
                            self.detactEvent.start(){
                                self.viewTF.positionXText = $0.x.description
                                self.viewTF.positionYText = $0.y.description
                                self.isAutoPosition = false
                                self.detactEvent.stop()
                            }
                        }
                        
                    }label: {
                        Text("AUTO").font(.caption2).padding(2)
                    }
                    .background(!self.isEditSettings ? .gray: self.isAutoPosition ? .green: .blue)
                    .cornerRadius(4)
                    .disabled(!self.isEditSettings)
                
                }
                HStack(spacing: 8){
                    Text("Timer:").frame(width: 100)
                    TextField("sec", text: $viewTF.maxCounterText).frame(width: 100).disabled(!self.isEditSettings)
                }
                HStack(){
                    Spacer()
                    Button{
                        self.isEditSettings = !self.isEditSettings
                        if self.isEditSettings{
                            self.stopTimer()
                        }else{
                            let result = self.checkVaridationSettings()
                            self.isEditSettings = !result
                            self.isAutoPosition = false
                            self.detactEvent.stop()
                        }
                    }label: {
                        Text(self.isEditSettings ? "Save":"Edit").padding()
                    }
                    .background(self.isEditSettings ? .green: .blue)
                    .cornerRadius(4)
                }.frame(width: 320)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
            
            
            VStack{
                HStack{
                    Text("Action")
                        .bold()
                    Spacer()
                }
                .padding()
                .frame(width: 320)
                
                Text("\(maxCounter - counter)").bold().font(.largeTitle)
                
                Button() {
                    if timer == nil{
                        self.startTimer()
                    }else{
                        self.stopTimer()
                    }
                }label: {
                    Text(timer == nil ? "Start":"Stop")
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                }
                .background(.blue)
                .cornerRadius(4)
                
            }
            .padding()
            .frame(width: 320)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
            
        }
        .frame(minWidth: 450, minHeight: 400)
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension ContentView{
    func checkVaridationSettings() -> Bool{
        guard let x = Double(self.viewTF.positionXText) else{
            return false
        }
        
        guard let y = Double(self.viewTF.positionYText) else{
            return false
        }
        
        guard let time = Int(self.viewTF.maxCounterText) else{
            return false
        }
        
        self.positionX = x
        self.positionY = y
        self.maxCounter = time
        
        return true
    }
    
    func startTimer(){
        if timer == nil{
            timer = Timer.scheduledTimer(
                withTimeInterval: 1,
                repeats: true,
                block: {_ in
                    if self.counter >= self.maxCounter{
                        self.eventClick()
                        self.counter = 0
                    }else{
                        self.counter += 1
                    }
                    
                })
        }
    }
    
    func stopTimer(){
        if timer != nil{
            timer?.invalidate()
            timer = nil
            self.counter = 0
        }
    }
    
    func eventClick(){
        
        let position = NSPoint(x: self.positionX, y: self.positionY)
        CGDisplayMoveCursorToPoint(0, position)
        let source = CGEventSource.init(stateID: .hidSystemState)
        let eventDown = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown, mouseCursorPosition: position , mouseButton: .left)
        let eventUp = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: position , mouseButton: .left)
        eventDown?.post(tap: .cghidEventTap)
        usleep(50_000)
        eventUp?.post(tap: .cghidEventTap)
    }
    
    
    
}

class DetactEvent {
    private var mouseLocation:NSPoint {NSEvent.mouseLocation}
    private var mouseMoved:Any?
    
    var isRuning = false

    func start(position:((NSPoint)->Void)? = nil){
        if !isRuning{
            self.isRuning = true
            self.positionMouse(position:position)
        }
    }
    
    func stop(){
        if isRuning{
            self.isRuning = false
            if let mouseMoved = mouseMoved {
                   NSEvent.removeMonitor(mouseMoved)
            }
        }
    }
    
    private func positionMouse(position:((NSPoint)->Void)? = nil){
        
        self.mouseMoved = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp]) { event in
            if self.isRuning{
                let positionX = event.locationInWindow.x
                let positionY = event.locationInWindow.y
                var frame:NSRect?
                NSScreen.screens.forEach{ screen in
                    let startX = screen.frame.origin.x
                    let endX = startX + screen.frame.width
                    if positionX >= startX && positionX <= endX{
                        frame = screen.frame
                    }
                }
                
                print("frame::\(String(describing: frame))")
                print("X::\(positionX), Y::\(positionY)")
             
                let minMaxX = (frame?.width ?? 0) + (frame?.origin.x ?? 0)
                let mouseX =  minMaxX - ((positionX * minMaxX) / (frame?.width ?? 0))
                
                let minMaxY = (frame?.height ?? 0) + (frame?.origin.y ?? 0)
                let mouseY = minMaxY - ((positionY * minMaxY) / (frame?.height ?? 0))
                
                print("minMaxX::\(minMaxX), minMaxY::\(minMaxY)")
                position?(NSPoint(x: mouseX , y: mouseY))
            }
        }
        
    }

}

class ContentViewTextTextField: ObservableObject {
    
    @Published var positionXText: String = "0"{
        didSet{
            DispatchQueue.main.async {
                let isPass = self.positionXText.isValidation(regex: .onlyDouble)
                self.positionXText = isPass ? self.positionXText:oldValue
            }
            
        }
    }
    
    @Published var positionYText: String = "35"{
        didSet{
            DispatchQueue.main.async {
                let isPass = self.positionYText.isValidation(regex: .onlyDouble)
                self.positionYText = isPass ? self.positionYText:oldValue
            }
            
        }
    }
    
    @Published var maxCounterText: String = "10"{
        didSet{
            DispatchQueue.main.async {
                let isPass = self.maxCounterText.isValidation(regex: .onlyNumbers)
                self.maxCounterText = isPass ? self.maxCounterText:oldValue
            }
            
        }
    }
}
