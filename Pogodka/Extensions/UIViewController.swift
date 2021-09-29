//
//  UIViewController.swift
//  Pogodka
//
//  Created by Михаил Звягинцев on 27.09.2021.
//

import UIKit

extension UIViewController {

    func showAlert(title: String, message: String, action: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ок", style: .cancel) { _ in
            if let action = action {
                action()
            }
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    func hideKeyboardOnTap() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
        }

        @objc func dismissKeyboard() {
            view.endEditing(true)
        }

    func showLoading(text: String? = nil) {
        showUniversalLoadingView(true)
    }

    func hideLoading() {
        showUniversalLoadingView(false)
    }

    private func showUniversalLoadingView(_ show: Bool, loadingText: String = "") {
        let existingView = UIApplication.shared.windows[0].viewWithTag(1200)
        if show {
            if existingView != nil {
                return
            }
            let loadingView = self.makeLoadingView(withFrame: UIScreen.main.bounds, loadingText: loadingText)
            loadingView?.tag = 1200
            UIApplication.shared.windows[0].addSubview(loadingView!)
        } else {
            existingView?.removeFromSuperview()
        }
    }

    private func makeLoadingView(withFrame frame: CGRect, loadingText text: String? = nil) -> UIView? {
        let loadingView = UIView(frame: frame)
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        activityIndicator.layer.cornerRadius = 6
        activityIndicator.center = loadingView.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.startAnimating()
        activityIndicator.tag = 100

        loadingView.addSubview(activityIndicator)
        if !text!.isEmpty {
            let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
            let cpoint = CGPoint(x: activityIndicator.frame.origin.x + activityIndicator.frame.size.width / 2, y: activityIndicator.frame.origin.y + 80)
            lbl.center = cpoint
            lbl.textColor = UIColor.white
            lbl.textAlignment = .center
            lbl.text = text
            lbl.tag = 1234
            loadingView.addSubview(lbl)
        }
        return loadingView
    }
}
