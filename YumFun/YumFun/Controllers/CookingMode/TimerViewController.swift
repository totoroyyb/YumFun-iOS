//
//  TimerViewController.swift
//  YumFun
//
//  Created by Admin on 2/28/21.
//


import UIKit

import Speech




class TimerViewController: UIViewController {
    var index: Int = 0
    var recipe = Recipe()

    let shapeLayer = CAShapeLayer()

    @IBOutlet weak var timerLabel: UILabel!
    

    @IBOutlet weak var startAndpauseButton: UIButton!
    
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var voiceButton: UIButton!
    
    
    //will be changed to whatever the recipe sends
    var timeRemaining: Int = 100
    var fullTime: Int = 100
    var timer: Timer!
    
    //Voice Recognition Locals
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var task: SFSpeechRecognitionTask!
    var isMicStart: Bool = false

    var voiceCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startAndpauseButton.layer.cornerRadius = startAndpauseButton.frame.size.width/2
        startAndpauseButton.clipsToBounds = true
        startAndpauseButton.layer.borderColor = UIColor.systemGreen.cgColor
        startAndpauseButton.layer.borderWidth = 3.0
        resetButton.layer.cornerRadius = resetButton.frame.size.width/2
        resetButton.clipsToBounds = true
        resetButton.layer.borderColor = UIColor.white.cgColor
        resetButton.layer.borderWidth = 3.0
        
        // Do any additional setup after loading the view.
        let trackLayer = CAShapeLayer()
        let center = timerLabel.center
        let circularPath = UIBezierPath(arcCenter: center, radius: 150, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        //set up background track for looks
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 10
        trackLayer.lineCap = CAShapeLayerLineCap.round
        
        
        shapeLayer.strokeEnd = 0
        view.layer.addSublayer(trackLayer)
        view.layer.addSublayer(shapeLayer)
        
        
        //Voice Recognition
        requestVoicePermissions()
    }


    @IBAction func startTapped(_ sender: UIButton){
        
        if startAndpauseButton.titleLabel?.text == "Start"{
            startAndpauseButton.setTitle("Pause", for: .normal)
            startAndpauseButton.layer.backgroundColor = UIColor.systemRed.cgColor
            startAndpauseButton.layer.borderColor = UIColor.systemRed.cgColor
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(step), userInfo: nil, repeats: true)
        }

    }

    @IBAction func pauseTapped(_ sender: UIButton){

        if startAndpauseButton.titleLabel?.text == "Pause"{
            timer.invalidate()
            
            startAndpauseButton.setTitle("Start", for: .normal)
            startAndpauseButton.layer.backgroundColor = UIColor.systemGreen.cgColor
            startAndpauseButton.layer.borderColor = UIColor.systemGreen.cgColor
        }
        
    }
    @IBAction func resetTapped(_ sender: UIButton){
        timer.invalidate()
        timeRemaining = fullTime
        timerLabel.text = "\(timeRemaining)"
        
        startAndpauseButton.setTitle("Start", for: .normal)
        startAndpauseButton.layer.backgroundColor = UIColor.systemGreen.cgColor
        startAndpauseButton.layer.borderColor = UIColor.systemGreen.cgColor
        shapeLayer.strokeEnd = 0
    }

    @objc func step(){
        if timeRemaining > 0 {
            timeRemaining -= 1
            let percentage = calculatePercentageofSecond()
            shapeLayer.strokeEnd += percentage
        }
        else{
            timer.invalidate()
            timeRemaining = 10
        }
        timerLabel.text = "\(timeRemaining)"
    }
    
    func calculatePercentageofSecond() -> CGFloat{
        print (CGFloat(1.0)/CGFloat(fullTime))
        return CGFloat(1.0)/CGFloat(fullTime)
    }
    
    
    //Voice Rec Functions
    @IBAction func mic_on_off(_sender: Any){
        isMicStart = !isMicStart
        
        if isMicStart {
            startSpeechRecognition()
            voiceButton.setImage(#imageLiteral(resourceName: "micOn"), for: .normal )
            voiceCount = 0

        }
        else {
            stopSpeechRecognition()
            voiceButton.setImage(#imageLiteral(resourceName: "micOff"), for: .normal)
        }
    }
    
    func requestVoicePermissions(){
        self.voiceButton.isEnabled = false
        SFSpeechRecognizer.requestAuthorization { (authState) in
            OperationQueue.main.addOperation {
                if authState == .authorized {
                    print("Accepted")
                    self.voiceButton.isEnabled = true
                } else if authState == .denied{
                    self.alertView(message: "User Denied Permission")
                } else if authState == .notDetermined{
                    self.alertView(message: "No speech recognition on this phone")
                } else if authState == .restricted {
                    self.alertView(message: "User is restricted in using voice recognotion")
                }
            }
        }
    }
    
    func startSpeechRecognition(){
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat){(buffer, _) in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do{
            try audioEngine.start()
        } catch let error {
            alertView(message: "Error in starting audio listener =\(error.localizedDescription)")
        }
        
        guard let myRecognition = SFSpeechRecognizer() else {
            self.alertView(message: "Recognizer not alloed locally")
            return
        }
        if !myRecognition.isAvailable {
            self.alertView(message: "Try agagin later")
        }
        task = speechRecognizer?.recognitionTask(with: request, resultHandler: { [self](response, error) in
            guard let response = response else{
                if error != nil {
                    self.alertView(message: error.debugDescription)
                }
                else {
                    self.alertView(message: "Problem giving response")
                }
                return
            }
            
            let message = response.bestTranscription.formattedString
            
            
            var lastWord: String = ""
            for segment in response.bestTranscription.segments {
                let indexTo = message.index(message.startIndex, offsetBy: segment.substringRange.location)
                lastWord = String(message[indexTo...])
            }
          
            //commands for voice recognition
            //Gets called 2-3 times need a incrementer to keep track and change after a certain time
            if lastWord == "start"{
                if voiceCount == 0 {
                    voiceCount += 1
                    print("start")
                    startTapped(self.startAndpauseButton)
                    DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                        voiceCount = 0
                    })
                    
                }
                
                
                
                
            }
            else if lastWord == "stop" {
                if voiceCount == 0 {
                    voiceCount += 1
                    print("stop")
                    pauseTapped(self.startAndpauseButton)
                    DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                        voiceCount = 0
                    })
                }

            }
            else if lastWord == "reset"{
                if voiceCount == 0 {
                    voiceCount += 1
                    print("reset")
                    resetTapped(self.startAndpauseButton)
                    DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                        voiceCount = 0
                    })
                }

            }
                        
        })
    }
    
    func stopSpeechRecognition(){
        task.finish()
        task.cancel()
        task = nil
        
        request.endAudio()
        audioEngine.stop()
        if audioEngine.inputNode.numberOfInputs > 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
    }
    
    func alertView(message : String){
        let controller = UIAlertController.init(title: "Error Occured", message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: {(_) in
            controller.dismiss(animated: true, completion: nil)
        }))
        self.present(controller, animated: true, completion: nil)
    }
}
