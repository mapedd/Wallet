//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 17/03/2023.
//

import AppApi

extension AppApi.Currency.List {
  public static var eur = AppApi.Currency.List(
    code: "EUR",
    name: "Euro",
    namePlural: "Euros",
    symbol: "€",
    symbolNative: "€"
  )
  public static var usd = AppApi.Currency.List(
    code: "USD",
    name: "Dollar",
    namePlural: "Dollars",
    symbol: "$",
    symbolNative: "$"
  )
  public static var pln = AppApi.Currency.List(
    code: "PLN",
    name: "Polish Zloty",
    namePlural: "Polish Zlotys",
    symbol: "PLN",
    symbolNative: "zł"
  )
}
