import XCTest
@testable import WalletSkinCore

final class IntegrationTests: XCTestCase {
    func testVersionComparison() {
        XCTAssertTrue(DeviceVersion(major: 27, minor: 2) > DeviceVersion(major: 27, minor: 0, patch: 1))
        XCTAssertTrue(DeviceVersion(major: 27, minor: 3) >= DeviceVersion(major: 27, minor: 2))
        XCTAssertEqual(DeviceVersion(major: 27, minor: 2).description, "27.2.0")
    }

    func testPatchedDeviceCannotUseAirLift() {
        let findings = CompatibilityAssessment.findings(for: DeviceVersion(major: 27, minor: 2))
        let airlift = try! XCTUnwrap(findings.first { $0.feature == .airlift })
        XCTAssertFalse(airlift.supported)
        XCTAssertEqual(airlift.evidence, .unsupported)
    }

    func testEarlierDeviceDoesNotClaimVerifiedExploit() {
        let findings = CompatibilityAssessment.findings(for: DeviceVersion(major: 27, minor: 0))
        let airlift = try! XCTUnwrap(findings.first { $0.feature == .airlift })
        XCTAssertFalse(airlift.supported)
        XCTAssertEqual(airlift.evidence, .unverified)
    }

    func testWorseQueryNeverClaimsWalletCompatibility() {
        for version in [DeviceVersion(major: 26, minor: 7), DeviceVersion(major: 27, minor: 0), DeviceVersion(major: 27, minor: 2)] {
            let findings = CompatibilityAssessment.findings(for: version)
            XCTAssertFalse(findings.first { $0.feature == .worseQuery }!.supported)
            XCTAssertFalse(findings.first { $0.feature == .cardArt }!.supported)
        }
    }

    func testPreviewAdapterDistinguishesPreviewFromRealApply() {
        let artwork = ArtworkMetadata(style: "Obsidian", createdAt: .distantPast)
        let engine = PreviewOnlyAdapter()
        XCTAssertEqual(engine.prepareForPreview(artwork), .previewReady)
        guard case .unavailable = engine.applyToPaymentCard(artwork) else {
            return XCTFail("Must not report Apple Pay application success")
        }
    }

    func testArtManifestExportsMetadataWithoutCardSecrets() throws {
        let artwork = ArtworkMetadata(style: "Gold", createdAt: .distantPast)
        let data = try JSONEncoder().encode(artwork)
        let decoded = try JSONDecoder().decode(ArtworkMetadata.self, from: data)
        XCTAssertEqual(decoded.width, 1536)
        XCTAssertEqual(decoded.height, 969)
        XCTAssertEqual(decoded.format, "png")
        XCTAssertEqual(decoded.style, "Gold")
        XCTAssertFalse(String(data: data, encoding: .utf8)!.contains("token"))
    }

    func testSourceCatalogProvidesURLs() {
        XCTAssertEqual(OpenSourceReference.all.count, 7)
        XCTAssertTrue(OpenSourceReference.all.allSatisfy { $0.url.scheme == "https" })
    }
}
