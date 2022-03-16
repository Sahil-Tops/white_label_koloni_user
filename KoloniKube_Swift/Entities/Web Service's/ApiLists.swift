//
//  ApiLists.swift
//  KoloniKube_Swift
//
//  Created by Sam on 11/02/22.
//  Copyright © 2022 Self. All rights reserved.
//

import Foundation

struct BASE_URLS{
    
    static let baseUrl = "https://dev-mobile.lockers.koloni.io/"
    
}

struct MODULE{
    
    static let instance: MODULE = {
        return MODULE()
    }()
    
    let organizations = "organizations"
    let commands = "commands"
    let devices = "devices"
    let debug = "debug"
    let admin = "admin"
    let stripe = "stripe"
    let algolia = "algolia"
    let locations = "locations"
    let transactions = "transactions"
    let grids = "grids"
    let reservations = "reservations"
    let prices = "prices"
    let signup = "signup"
    let auth0 = "auth0"
    let users = "users"
    let defaults = "default"
    
}

struct API_LISTS{
    
    static let instance: API_LISTS = {
        return API_LISTS()
    }()
    
    let all = "all"
    let members = "members"
    let roles = "roles"
    let invitations = "invitations"
    let enabled_connections = "enabled_connections"
    let possible_connections = "possible_connections"
    let unlock = "unlock"
    let types = "types"
    let whoami = "whoami"
    let whoami_partner = "whoami-partner"
    let auth0_token = "auth0-token"
    let create_account = "create_account"
    let link = "link"
    let refresh_link = "refresh_link"
    let check = "check"
    let confirm_payment = "confirm-payment"
    let webhook = "webhook"
    let api_key = "api-key"
    let stripe = "stripe"
    let payless = "payless"
    let from_user = "from-user"
    let by_location = "by-location"
    let reserve_device = "reserve-device"
    let address = "address"
    let org_by_email = "org-by-email"
    let possible_roles = "possible-roles"
    let reservations = "reservations"
    let login = "login"
    
}

enum HTTP_METHOD: String{
    
    case post = "POST"
    case get = "GET"
    case delete = "DELETE"
    case put = "PUT"
    case patch = "PATCH"
    
}
