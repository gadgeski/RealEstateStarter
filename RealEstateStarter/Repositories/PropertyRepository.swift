//
//  PropertyRepository.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/16.
//

protocol PropertyRepository {
    func fetchProperties() async throws -> [Property]
}
