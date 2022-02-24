//
//  OpenWeatherMapService.swift
//  Weather-SwiftUI
//
//  Created by Vasily Petuhov on 22.02.2022.
//

import Foundation

private enum API {
	static let keyOpenWeatherMap = "9ec63d85b9c144ed7ba4e335eef34245"
//	static let keyWeatherStack = "3225f258915e8844502bf6dae948fef5"
}

class OpenWeatherMapService: WebServiceProtocol {
	let fallbackService: WebServiceProtocol?

	required init(fallbackService: WebServiceProtocol? = nil) {
		self.fallbackService = fallbackService
	}

	func fetchWeatherData(for city: String, completionHandler: @escaping (String?, WebServiceError?) -> Void) {
		let endpoint = "https://api.openweathermap.org/data/2.5/find?q=\(city)&units=imperial&appid=\(API.keyOpenWeatherMap)"

		guard let safeURLSharing = endpoint.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
			  let endpointURL = URL(string: safeURLSharing)
		else {
			completionHandler(nil, WebServiceError.invalidURL(endpoint))
			return
		}

		let dataTask = URLSession.shared.dataTask(with: endpointURL) { data, response, error in

			guard error == nil else {
				if let fallback = self.fallbackService {
					fallback.fetchWeatherData(for: city, completionHandler: completionHandler)
				} else {
					completionHandler(nil, WebServiceError.forwarded(error!))
				}
				return
			}

			guard let responseData = data else {
				if let fallback = self.fallbackService {
					fallback.fetchWeatherData(for: city, completionHandler: completionHandler)
				} else {
					completionHandler(nil, WebServiceError.invalidPayload(endpointURL))
				}
				return
			}

			/// decode JSON
			let decoder = JSONDecoder()
			do {
				let weatherList = try decoder.decode(OpenWeatherMapContainer.self, from: responseData)
				guard let weatherInfo = weatherList.list?.first,
					  let weather = weatherInfo.weather.first?.main,
					  let temperature = weatherInfo.main.temp
				else {
					completionHandler(nil, WebServiceError.invalidPayload(endpointURL))
					return
				}

				/// compose weather information
				let weatherDescription = "\(weather) \(temperature) F"
				completionHandler(weatherDescription, nil)

			} catch let error {
				completionHandler(nil, WebServiceError.forwarded(error))
			}
		}

		dataTask.resume()
	}
}
