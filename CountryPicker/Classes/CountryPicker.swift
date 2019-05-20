//
//  CountryPicker.swift
//  Hyber
//
//  Created by Taras on 12/1/16.
//  Copyright © 2016 Taras Markevych. All rights reserved.
//

import UIKit
import CoreTelephony
/// CountryPickerDelegate
///
/// - Parameters:
///   - picker: UIPickerVIew
///   - country: the selected country
@objc public protocol CountryPickerDelegate {
    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountry country: Country)
}

/// Structure of country code picker
@objc public class Country: NSObject {
    public let code: String?
    public let name: String?
    public let phoneCode: String?
    public let flagName: String
    
    /// Country code initialization
    ///
    /// - Parameters:
    ///   - code: String
    ///   - name: String
    ///   - phoneCode: String
    ///   - flagName: String
    public init(code: String?, name: String?, phoneCode: String?, flagName: String) {
        self.code = code
        self.name = name
        self.phoneCode = phoneCode
        self.flagName = flagName
    }

    public var flag: UIImage? {
        return UIImage(named: flagName, in: Bundle(for: CountryPicker.self), compatibleWith: nil)
    }
}

open class CountryPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {

    public static var countries: [Country] = CountryPicker.initCountries()
    open weak var countryPickerDelegate: CountryPickerDelegate?
    open var showPhoneNumbers: Bool = true

    open var selectedCountry: Country {
        return CountryPicker.countries[self.selectedRow(inComponent: 0)]
    }

    /// init
    ///
    /// - Parameter frame: initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /// Setup country code picker
    func setup() {
        super.dataSource = self
        super.delegate = self
    }
    
    // MARK: - Country Methods
    
    /// setCountry
    ///
    /// - Parameter code: selected country
    open func setCountry(_ code: String) {
        var row = 0
        for index in 0..<CountryPicker.countries.count {
            if CountryPicker.countries[index].code == code {
                row = index
                break
            }
        }
        
        self.selectRow(row, inComponent: 0, animated: true)
        let country = CountryPicker.countries[row]
        if let countryPickerDelegate = countryPickerDelegate {
            countryPickerDelegate.countryPhoneCodePicker(self, didSelectCountry: country)
        }
    }
    
    /// setCountryByPhoneCode
    /// Init with phone code
    /// - Parameter phoneCode: String
    open func setCountryByPhoneCode(_ phoneCode: String) {
        var row = 0
        for index in 0..<CountryPicker.countries.count {
            if CountryPicker.countries[index].phoneCode == phoneCode {
                row = index
                break
            }
        }
        
        self.selectRow(row, inComponent: 0, animated: true)
        let country = CountryPicker.countries[row]
        if let countryPickerDelegate = countryPickerDelegate {
            countryPickerDelegate.countryPhoneCodePicker(self, didSelectCountry: country)
        }
    }
    
    // Populates the metadata from the included json file resource
    
    /// sorted array with data
    ///
    /// - Returns: sorted array with all information phone, flag, name

    public static func initCountries() -> [Country] {
        var countries = [Country]()
        let frameworkBundle = Bundle(for: self)
        guard let jsonPath = frameworkBundle.path(forResource: "CountryPicker.bundle/Data/countryCodes", ofType: "json"), let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {
            return countries
        }
        
        do {
            if let jsonObjects = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? NSArray {
                
                for jsonObject in jsonObjects {
                    
                    guard let countryObj = jsonObject as? NSDictionary else {
                        return countries
                    }
                    
                    guard let code = countryObj["code"] as? String, let phoneCode = countryObj["dial_code"] as? String, let name = countryObj["name"] as? String else {
                        return countries
                    }
                    
                    let flagName = "CountryPicker.bundle/Images/\(code.uppercased())"

                    let country = Country(code: code, name: name, phoneCode: phoneCode, flagName: flagName)
                    countries.append(country)
                }
                
            }
        } catch {
            return countries
        }
        return countries
    }
    
    // MARK: - Picker Methods
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /// pickerView
    ///
    /// - Parameters:
    ///   - pickerView: CountryPicker
    ///   - component: Int
    /// - Returns: counts of array's elements
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CountryPicker.countries.count
    }
    
    /// PickerView
    /// Initialization of Country pockerView
    /// - Parameters:
    ///   - pickerView: UIPickerView
    ///   - row: row
    ///   - component: count of countries
    ///   - view: UIView
    /// - Returns: UIView
    open func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var resultView: CountryView
        
        if view == nil {
            resultView = CountryView()
        } else {
            resultView = view as! CountryView
        }
        
        resultView.setup(CountryPicker.countries[row])
        if !showPhoneNumbers {
            resultView.countryCodeLabel.isHidden = true
        }
        return resultView
    }
    
    /// Function for handing data from UIPickerView
    ///
    /// - Parameters:
    ///   - pickerView: CountryPickerView
    ///   - row: selectedRow
    ///   - component: description
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let country = CountryPicker.countries[row]
        if let countryPickerDelegate = countryPickerDelegate {
            countryPickerDelegate.countryPhoneCodePicker(self, didSelectCountry: country)
        }
    }
}
