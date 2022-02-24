//
//  WeatherStackMapData.swift
//  Weather-SwiftUI
//
//  Created by Vasily Petuhov on 22.02.2022.
//

import Foundation

struct WeatherStackMapContainer: Codable {
	var current: WeatherStackMapCurrent?
}

struct WeatherStackMapCurrent: Codable {
	var temperature: Int?
	var weather_descriptions: [String]?
}
