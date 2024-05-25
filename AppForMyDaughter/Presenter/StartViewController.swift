//
//  ViewController.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 19.05.2024.
//

import UIKit

class StartViewController: UIViewController, UITextFieldDelegate {
    
    var openAI: OpenAIServiceProtocol?
    var voiceService: OpenAIVoiceServiceProtocol?
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter your question..."
        return textField
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Send", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        
        view.addSubview(inputTextField)
        view.addSubview(sendButton)
        
        setupConstraints()
        
      
        inputTextField.delegate = self
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            inputTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            inputTextField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            inputTextField.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func sendButtonTapped() {
        guard let text = inputTextField.text, !text.isEmpty else { return }
        sendMessage(text)
        inputTextField.text = ""
    }
    
    private func sendMessage(_ text: String) {
        Task {
            do {
                print("Sending message: \(text)")
                if let result = try await openAI?.sendMessage(text: text) {
                    print("Request: \(text)")
                    print("Response: \(result)")
                    try await voiceService?.speak(text:result)
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                showErrorAlert(error.localizedDescription)
            }
        }
    }
    
    
    private func showErrorAlert(_ error: String) {
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
