//
//  ContentView.swift
//  ImageAnchor
//
//  Created by Nien Lam on 9/21/21.
//  Copyright © 2021 Line Break, LLC. All rights reserved.
//

import SwiftUI
import ARKit
import RealityKit
import Combine
//import Foundation
//import Darwin
//import math.h



// For diffferent app state
enum AppMode {
    case menu
    case arMode
}

enum ViewMode: String{
    case scale
    case amount
    case unit
}

enum Species {
    case tiger
    case boar
    case mouse
    case hamburger
}


// MARK: - View model for handling communication between the UI and ARView.
class ViewModel: ObservableObject {
    let uiSignal = PassthroughSubject<UISignal, Never>()
    @Published var appState:AppMode = AppMode.menu
    @Published var chosenPredator: Species = Species.tiger
    @Published var sliderVal: Float = 9.0
    @Published var viewMode: ViewMode = ViewMode.unit
    @Published var sliderMin: Float = 9.0
    @Published var sliderMax: Float = 50
    @Published var viewingSpecies: Species = Species.tiger
    

    enum UISignal {
        case homeButtonPress
        case largePreyPress
        case smallPreyPress
        case hamburgerPress
        case scalePress
        //case amountPress
        case unitPress
        case startPress
      }
}


// MARK: - UI Layer.
struct ContentView : View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        
        
        ZStack {
            
            if(viewModel.appState == AppMode.menu){
                Color.gray
                
                VStack(alignment: .center){
                    Text("You Are What You Eat")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .foregroundColor(.white)
                        .font(.system(.largeTitle))
                                   
                    Text("See how much a predator consumes a day")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .foregroundColor(.white)
                        .font(.system(.title))
                    HStack{
                        Image("logo")
                     }
                    
                    Button {
                        viewModel.appState = AppMode.arMode
                        //weirdly, the viewModel send doesn't fire so hacking it...
                        viewModel.uiSignal.send(.homeButtonPress)
                    } label: {
                        Text("Start")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .font(.system(.largeTitle))
                            .foregroundColor(.white)
                    }
                }
                
            }
            
            else if(viewModel.appState == AppMode.arMode){
                // AR View.
                ARViewContainer(viewModel: viewModel)

                VStack(alignment: .leading, spacing: 16) {
                    
                     HStack{
                        //Home button
                        Button {
                            viewModel.uiSignal.send(.homeButtonPress)
                        } label: {
                            buttonIcon("house", color: Color.red)
                        }
                        // TODO: Fix this weird layout
                        Spacer()
                        
                        Text(viewModel.viewMode.rawValue)
                            .foregroundColor(.black)
                            .background(Color.white)
                            .font(.system(.headline))
                            .padding()
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .topTrailing)
                    }//End of H Stack Top
                    
                    HStack{
                        
                        if (viewModel.viewMode == ViewMode.scale){
                            VStack(alignment: .leading, spacing: 16){
                                //Large prey
                                Button {
                                    viewModel.uiSignal.send(.largePreyPress)
                                } label: {
                                    Image("boar")
                                       .resizable()
                                       .padding(10)
                                       .frame(width: 60, height: 60)
                                       .foregroundColor(.white)
                                       .background(.purple)
                                       .cornerRadius(5)
                                }
                                
                                
                                //Small prey
                                Button {
                                    viewModel.uiSignal.send(.smallPreyPress)
                                } label: {
                                    Image("mouse")
                                       .resizable()
                                       .padding(10)
                                       .frame(width: 60, height: 60)
                                       .foregroundColor(.white)
                                       .background(.orange)
                                       .cornerRadius(5)
                                }
                                
                                //Hamburger
                                Button {
                                    viewModel.uiSignal.send(.hamburgerPress)
                                } label: {
                                    Image("hamburger")
                                       .resizable()
                                       .padding(10)
                                       .frame(width: 60, height: 60)
                                       .foregroundColor(.white)
                                       .background(.green)
                                       .cornerRadius(5)
                                }
                                
                            }
                            
                        }

                        
                                                
                        Spacer()
 
                        VStack(alignment: .trailing){
                            
                            // Reset mode
                            Button(action: {
                                viewModel.uiSignal.send(.unitPress)
                            }) {
                                Text("Unit Mode")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(Color.white)
                                    .cornerRadius(5)

                            }.frame(width: 80, height: 80)
                            
                            // Scaling mode
                            Button(action: {
                                viewModel.uiSignal.send(.scalePress)
                            }) {
                                Text("Scale Mode")
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(Color.white)
                                    .cornerRadius(5)

                            }.frame(width: 80, height: 80)
                            
                            /* Amount mode - Not working/implemented
                            Button(action: {
                                viewModel.uiSignal.send(.amountPress)
                            }) {
                                Text("# Mode")
                                    .padding()
                                    .background(Color.yellow)
                                    .foregroundColor(Color.white)
                                    .cornerRadius(5)

                            }.frame(width: 80, height: 80, alignment: .topTrailing)
                            */
                            
                            if (viewModel.viewMode == ViewMode.scale){
                                // Slider.
                                Slider(value: $viewModel.sliderVal, in: $viewModel.sliderMin.wrappedValue...$viewModel.sliderMax.wrappedValue)
                                    .frame(width: 120)
        
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding()
                 }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding()
                .padding(.top, 25)
                
                
            }//End of if
            
        }
        .edgesIgnoringSafeArea(.all)
        .statusBar(hidden: true)
         
    }
    
    // Helper methods for rendering icon.
    func buttonIcon(_ systemName: String, color: Color) -> some View {
             Image(systemName: systemName)
                .resizable()
                .padding(10)
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
                .background(color)
                .cornerRadius(5)
            
    }
}


// MARK: - AR View.
struct ARViewContainer: UIViewRepresentable {
    let viewModel: ViewModel
    
    func makeUIView(context: Context) -> ARView {
        SimpleARView(frame: .zero, viewModel: viewModel)
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

class SimpleARView: ARView, ARSessionDelegate {

    var viewModel: ViewModel
    var arView: ARView { return self }
    var subscriptions = Set<AnyCancellable>()
    
    // Dictionary for tracking image anchors.
    var imageAnchorToEntity: [ARImageAnchor: AnchorEntity] = [:]

    // Materials array for animation.
    
    var materialsArray = [RealityKit.Material]()

    // Variable adjust animated texture timing.
    var lastUpdateTime = Date()
    
    // Pauline's Variables
   
    var plate: ModelEntity?
    
    // Animals
    var tiger: Animal!
    var boar: Animal!
    var mouse: Animal!
    var hamburger: Animal!
    
    var sliderVal: Float = 0.0
    
    
    //For later:
//    var shark: ModelEntity?
//    var seal: ModelEntity?
//    var herring: ModelEntity?
//    var wolf: ModelEntity?
//    var bunny: ModelEntity?


    init(frame: CGRect, viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        UIApplication.shared.isIdleTimerDisabled = true
       
        setupScene()
        
    }
    
    func setupScene() {
        // Setup world tracking and plane detection.
        let configuration = ARImageTrackingConfiguration()
        arView.renderOptions = [.disableDepthOfField, .disableMotionBlur]
        // Marker
        // TODO: Target Image in Meters //////////////////////////////////////
        //let targetImage    = "tigerhabitat.jpeg"
        let targetImage    = "tiger2.png"

        let physicalWidth  = 0.1624
        
        if let refImage = UIImage(named: targetImage)?.cgImage {
            let arReferenceImage = ARReferenceImage(refImage, orientation: .up, physicalWidth: physicalWidth)
            var set = Set<ARReferenceImage>()
            set.insert(arReferenceImage)
            configuration.trackingImages = set
        } else {
            print("❗️ Error loading target image")
        }
    
        arView.session.run(configuration)
        
        // Called every frame.
        scene.subscribe(to: SceneEvents.Update.self) { event in
            // Call renderLoop method on every frame.
            self.renderLoop()
        }.store(in: &subscriptions)
        
        // Process UI signals.
        viewModel.uiSignal.sink { [weak self] in
            self?.processUISignal($0)
        }.store(in: &subscriptions)
        
        // Process slider value.
        viewModel.$sliderVal.sink { value in
            print("👇 Did change slider:", value)
            self.sliderVal = value
            
           
            let currViewingSpecies = self.viewModel.viewingSpecies
            let currViewMode = self.viewModel.viewMode
            
            if(currViewMode == ViewMode.scale){
                
                switch(currViewingSpecies){
                    case Species.boar:
                    self.onLargePreyScaleClick(predator: self.viewModel.chosenPredator)
                        break;
                    case Species.mouse:
                    self.onSmallPreyScaleClick(predator: self.viewModel.chosenPredator)
                        break;
                    case Species.hamburger:
                        self.onHamburgerScaleClick(predator: self.viewModel.chosenPredator)
                        break;
                    case .tiger:
                        break;
                }
            }

        }.store(in: &subscriptions)

        // Set session delegate.
        arView.session.delegate = self
    }
    
    // Process UI signals.
      func processUISignal(_ signal: ViewModel.UISignal) {
          switch signal {
              case .scalePress:
                  print("👇 Did press scale button")
                  viewModel.viewMode = ViewMode.scale
                  break
    //          case .amountPress:
    //              print("👇 Did press amount button")
    //              viewModel.viewMode = ViewMode.amount
    //              break
              case .homeButtonPress:
                  print("👇 Did press home button")
                  viewModel.appState = AppMode.menu
                  break
              case .largePreyPress:
                  print("👇 Did press large prey")
                  viewModel.viewingSpecies = Species.boar
                  onLargePreyScaleClick(predator: viewModel.chosenPredator)

                  break
              case .smallPreyPress:
                  print("👇 Did press small prey")
                  viewModel.viewingSpecies = Species.mouse
                  onSmallPreyScaleClick(predator: viewModel.chosenPredator)
                  break
              case .hamburgerPress:
              print("👇 hamburger press")
              viewModel.viewingSpecies = Species.hamburger
              onHamburgerScaleClick(predator: viewModel.chosenPredator)
              break
          case .unitPress:
              print("unit press")
              resetModeClick(predator: viewModel.chosenPredator)
              viewModel.viewMode = ViewMode.unit
              break;
          case .startPress:
              print("pressing start");
              viewModel.appState = AppMode.arMode

              break;
          }
      }
    func resetModeClick(predator: Species){
        resetAllPreyScaleAndPos(predator: predator)
        boar.model.isEnabled = true
        mouse.model.isEnabled = true
        hamburger.model.isEnabled = true
    }
    
    func resetAllPreyScaleAndPos(predator: Species){
        
        if(predator == Species.tiger){
            print("resetting");
            boar.model.scale = [Float(1.0),Float(1.0),Float(1.0)]
            boar.model.position.x = boar.defaultPosX
            
            mouse.model.scale = [Float(1.0),Float(1.0),Float(1.0)]
            mouse.model.position.x = mouse.defaultPosX

            hamburger.model.scale = [Float(1.0),Float(1.0),Float(1.0)]
            hamburger.model.position.x = hamburger.defaultPosX
        }
    }
    
    func resetAllPreyDisabled(predator: Species){
        if(predator == Species.tiger){
            print("disabling");
            boar.model.isEnabled = false
            mouse.model.isEnabled = false
            hamburger.model.isEnabled = false
         }
        
    }
    
    
    func calculateScaleOfPreyEaten(predator: Animal, prey: Animal) -> Double {
//        let num = predator.dailyAvgConsumption!
        let num = viewModel.sliderVal
        print("slider num")
        print(num)
        
        let denom = prey.weight
        let base = Double(num/denom)
        // Use 1/3 as exp due make weight proportional to vol
        let exp: Double = Double(1.0)/Double(3.0)
        let result = pow(base,exp)
//        print(nom)
//        print(denom)
//        print(base)
//        print(result)
        return result
    }

    func onLargePreyScaleClick(predator: Species){
        if(predator == Species.tiger){
            resetAllPreyScaleAndPos(predator: predator)
            resetAllPreyDisabled(predator: predator)
            boar.model.isEnabled = true
            let newScale = calculateScaleOfPreyEaten(predator: tiger, prey: boar)
            //scale boar entity here:
            boar.model.scale = [Float(newScale),Float(newScale),Float(newScale)]
            boar.model.position.x = 0.007

        }
    }
    
    func onSmallPreyScaleClick(predator: Species){
        if(predator == Species.tiger){
            resetAllPreyScaleAndPos(predator: predator)
            resetAllPreyDisabled(predator: predator)
            mouse.model.isEnabled = true
            let newScale = calculateScaleOfPreyEaten(predator: tiger, prey: mouse)
            //scale mouse entity here:
            print(newScale)
            mouse.model.scale = [Float(newScale),Float(newScale),Float(newScale)]
            mouse.model.position.x = 0.035
        }
    }
    
    
    func onHamburgerScaleClick(predator: Species){
        if(predator == Species.tiger){
            resetAllPreyScaleAndPos(predator: predator)
            resetAllPreyDisabled(predator: predator)
            hamburger.model.isEnabled = true

            let newScale = calculateScaleOfPreyEaten(predator: tiger, prey: hamburger)
            print(newScale)
            //scale hamburger entity here:
            hamburger.model.scale = [Float(newScale),Float(newScale),Float(newScale)]
            hamburger.model.position.x = 0.005

        }

    }

    
    /* Not implementing
     since I had trouble clearing the scene correctly as well as populating models on the fly
     
     func calculateAmountPreyEaten(predator: Animal, prey: Animal) -> Int{
         let num = predator.dailyAvgConsumption!
         let denom = prey.weight
         var numEaten = Float(num/denom);
         print(numEaten)
         numEaten.round(.up)
         print(numEaten)
         return Int(numEaten)
     }
    
    func onLargePreyAmountClick(predator: Species){
        if(predator == Species.tiger){
            resetAllPreyDisabled(predator: predator)
            let totalBoars = calculateAmountPreyEaten(predator: tiger, prey: boar)
            print("total boars needed: ")
            print(totalBoars)
            
            clearScene(predator: predator)

            
            //scale boar entity here:
            //boar.model.scale = [Float(newScale),Float(newScale),Float(newScale)]
        }
    }
    
    func onSmallPreyAmountClick(predator: Species){
        
        if(predator == Species.tiger){
            resetAllPreyDisabled(predator: predator)
            let totalMice = calculateAmountPreyEaten(predator: tiger, prey: mouse)
            print("total mice needed: ")
            print(totalMice)
        
            clearScene(predator: predator)

            
            //scale boar entity here:
            //boar.model.scale = [Float(newScale),Float(newScale),Float(newScale)]
        }
        
        
    }
    
    func onHamburgerAmountClick(predator: Species){
        
        if(predator == Species.tiger){
            resetAllPreyDisabled(predator: predator)
            boar.model.isEnabled = true
            let totalHamburgers = calculateAmountPreyEaten(predator: tiger, prey: hamburger)
            print("total hamburgers needed: ")
            print(totalHamburgers)
            
            clearScene(predator: predator)
            
            //Add models back
            let worldAnchor = imageAnchorToEntity.values.first!
            print(worldAnchor)
            
            if(predator == Species.tiger){
                print("adding back tiger")
                worldAnchor.addChild(tiger)
            }
            let offset = 0.007
            for i in 0...totalHamburgers{
                
                let newPosX = (0*0.02)+offset
                let cloneHamburger = Animal(filename: "hamburgers.usdz", weight: (141.748/1000), height: 0.016458, dailyAvgConsumption: nil, species: Species.hamburger, defaultPosX: Float(newPosX));
                worldAnchor.addChild(cloneHamburger)
            }
        
        }
        
        
    }
     
     */
            
   
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        anchors.compactMap { $0 as? ARImageAnchor }.forEach {
            // Create anchor from image.
            let anchorEntity = AnchorEntity(anchor: $0)
            
            // Track image anchors added to scene.
            imageAnchorToEntity[$0] = anchorEntity
            
            // Add anchor to scene.
            arView.scene.addAnchor(anchorEntity)
            
            // Call setup method for entities.
            // IMPORTANT: Play USDZ animations after entity is added to the scene.
            setupEntities(anchorEntity: anchorEntity)
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
    }

    // TODO: Setup entities. //////////////////////////////////////
    // IMPORTANT: Attach to anchor entity. Called when image target is found.

    func setupEntities(anchorEntity: AnchorEntity) {

//        plate = try! Entity.loadModel(named: "plate.usdz")
//        plate?.scale = [0.025,0.025,0.025]
//        plate?.orientation *= simd_quatf(angle: .pi/2, axis: [1,0,0])
//        //plate?.orientation *= simd_quatf(angle: .pi/2, axis: [1,0,1])
//        plate?.position.y = 0.05
//        //anchorEntity.addChild(plate!)
        
        //Tiger eats 9kg min, 50kg max
        tiger = Animal(filename: "tiger.usdz", weight: 175.0, height: Float(91/1000), dailyAvgConsumption: 9, species: Species.tiger, defaultPosX: -0.025)
        tiger.position.x = tiger.defaultPosX
        tiger.name = "Tiger"
        anchorEntity.addChild(tiger)
        
        boar = Animal(filename: "boar.usdz", weight: 124.5, height: Float(99/1000), dailyAvgConsumption: nil, species: Species.boar, defaultPosX: 0.025 )
        boar.name = "Boar"
         anchorEntity.addChild(boar)

        mouse = Animal(filename: "mouse.usdz", weight: (42.5/1000), height: Float(4/1000) , dailyAvgConsumption: nil, species: Species.mouse, defaultPosX: 0.025)
        //mouse.position.x = 0.045
        mouse.name = "Mouse"
        anchorEntity.addChild(mouse.model!)
        
        hamburger = Animal(filename: "hamburgers.usdz", weight: (141.748/1000), height: 0.016458, dailyAvgConsumption: nil, species: Species.hamburger, defaultPosX: -0.02);
        hamburger.name = "Hambuger"
        anchorEntity.addChild(hamburger);
        
//        wolf = try! Entity.loadModel(named: "wolfy.usdz")
//        wolf?.scale = [0.025,0.025,0.025]
//        wolf?.position.y = 0.05
//        //anchorEntity.addChild(wolf!)
//
//        bunny = try! Entity.loadModel(named: "Bunny.usdz")
//        bunny?.scale = [0.0075,0.0075,0.0075]
//        bunny?.position.y = 0.05
        //anchorEntity.addChild(bunny!)
        
        
//        shark = try! Entity.loadModel(named: "shark3.usdz")
//        shark?.scale = [0.0025,0.0025,0.0025]
//        shark?.position.y = 0.05
//        ///anchorEntity.addChild(shark!)
//
//        seal = try! Entity.loadModel(named: "seal.usdz")
//        seal?.scale = [0.025,0.025,0.025]
//        seal?.position.y = 0.05
//        //anchorEntity.addChild(seal!)
//
//        herring = try! Entity.loadModel(named: "Herring.usdz")
//        herring?.scale = [0.025,0.025,0.025]
//        herring?.position.y = 0.05
//        //anchorEntity.addChild(herring!)
        
    }
    
    func renderLoop() {
        // Time interval from last animated material update.
        let currentTime  = Date()
        let timeInterval = currentTime.timeIntervalSince(lastUpdateTime)

        // Animate material every 1 / 15 of second.
        if timeInterval > 1 / 15 {
 
            // Remember last update time.
            lastUpdateTime = currentTime
        }
    }
    
}

class Animal: Entity {
    var species: Species
    var model: ModelEntity!
    var weight: Float
    var height: Float
    // Daily avg consumption in lbs
    var dailyAvgConsumption: Float?
    var defaultPosX: Float
//    var posY = Float(0.025)
    
    init(filename: String, weight: Float, height: Float, dailyAvgConsumption: Float?, species: Species, defaultPosX: Float){

        self.species = species
        model = try! Entity.loadModel(named: filename)
        self.weight = weight
        self.height = height
        self.dailyAvgConsumption = dailyAvgConsumption
        self.defaultPosX = defaultPosX
        super.init()

        self.addChild(model)
        self.setSpecificOrientation()
        self.model.position.x = self.defaultPosX
        self.model.position.z = 0.05
    }
    
    func setSpecificOrientation(){
        switch(self.species){
            case Species.tiger:
                self.model?.orientation *= simd_quatf(angle: .pi/2 * -1, axis: [1,0,0])
                self.model?.orientation *= simd_quatf(angle: .pi/2, axis: [0,1,0])
                //self.model?.orientation *= simd_quatf(angle: .pi/2, axis: [0,1,0]
                break
            case Species.boar:
                self.model?.orientation *= simd_quatf(angle: .pi/2 * -1, axis: [1,0,0])
                break
            case Species.mouse:
                self.model?.orientation *= simd_quatf(angle: .pi/2 * -1, axis: [1,0,0])
                self.model?.orientation *= simd_quatf(angle: .pi/2 * -1, axis: [0,1,0])
                break
            case Species.hamburger:
                self.model?.orientation *= simd_quatf(angle: -.pi/2, axis: [1,0,0])
                break
        }
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
}

