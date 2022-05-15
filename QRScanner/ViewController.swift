//
//  ViewController.swift
//  QRScanner
//
//  Created by Ольга on 29.04.2022.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    // Создаем объект видео, который будем транслировать через камеру
    var video = AVCaptureVideoPreviewLayer()
    // 1. Настроим сессию
    var session = AVCaptureSession()
    
    // MARK: - Добавляем на видео рамку для QR кода
    
    var qrCodeFrameView: UIImageView = {
        let view = UIImageView()
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 6
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var prescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Наведите рамку на QR код"
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.font = UIFont(name: "SFProText-Regular", size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

//    var container: UIView = {
//        let view = UIView()
//        view.backgroundColor = .red
//        return view
//    }()

    // MARK: - Настройка видео
    
    func setupVideo() {
        // 2. Настраиваем устройство видео
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        // 3. Настроим input
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            session.addInput(input)
        } catch {
            fatalError(error.localizedDescription)
        }
        // 4. Настроим output
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
    
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        video = AVCaptureVideoPreviewLayer(session: session)
        session.startRunning()
    }

    // MARK: - Settings

    func setupHierarchy() {
        view.layer.addSublayer(video)
        view.addSubview(qrCodeFrameView)
        view.addSubview(prescriptionLabel)
        view.bringSubviewToFront(qrCodeFrameView)
        view.bringSubviewToFront(prescriptionLabel)
    }

    func setupLayout() {
        video.frame = view.layer.bounds

        qrCodeFrameView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        qrCodeFrameView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        qrCodeFrameView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        qrCodeFrameView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -50).isActive = true

        prescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        prescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        prescriptionLabel.topAnchor.constraint(equalTo: qrCodeFrameView.bottomAnchor, constant: 40).isActive = true
    }

//    @IBAction func scanQRAction(_ sender: Any) {
//
//    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideo()
        setupHierarchy()
        setupLayout()

//        view.addSubview(container)
//        container.layer.addSublayer(video)
//
//        container.frame = view.frame
//        video.frame = container.layer.bounds
    }
}

    // MARK: - Обрабатываем полученные данные

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard metadataObjects.count > 0 else { return }
        if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            if object.type == AVMetadataObject.ObjectType.qr {
                let alert = UIAlertController(title: "QR Code", message: object.stringValue, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Перейти", style: .default, handler: { (action) in
                    if let url = URL(string: object.stringValue ?? "") {
                        UIApplication.shared.open(url)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Отменить", style: .default, handler: { (action) in
                    self.session.startRunning()
                }))
                present(alert, animated: true, completion: nil)
            }
        }
    }
}

