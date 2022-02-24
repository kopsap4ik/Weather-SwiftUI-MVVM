//
//  WebServiceController.swift
//  Weather-SwiftUI
//
//  Created by Vasily Petuhov on 22.02.2022.
//

import Foundation

public enum WebServiceError {
	case invalidURL(String)
	case invalidPayload(URL)
	case forwarded(Error)
}

public protocol WebServiceProtocol {
	var fallbackService: WebServiceProtocol? { get }
	init(fallbackService: WebServiceProtocol?)
	func fetchWeatherData(for city: String, complitionHandler: @escaping (String?, WebServiceError?) -> Void)
}
