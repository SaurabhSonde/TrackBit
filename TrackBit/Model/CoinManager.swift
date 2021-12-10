//
//  CoinManager.swift
//  TrackBit
//
//  Created by Saurabh Sonde on 10/12/21.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateExchangeRate(_ coinManager: CoinManager, coinInfo: CoinModel)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = ""
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String) {
       fetchExchangeRate(currency: currency)
    }
    
    func fetchExchangeRate(currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let exchangeRate = self.parseJSON(safeData) {
                        self.delegate?.didUpdateExchangeRate(self, coinInfo: exchangeRate)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data ) -> CoinModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            let currency = decodedData.asset_id_quote
           
            let rate = CoinModel(rate: lastPrice,currency: currency)
            return rate
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
