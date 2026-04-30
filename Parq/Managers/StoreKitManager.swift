import Combine
import Foundation
import StoreKit

@MainActor
final class StoreKitManager: ObservableObject {
    static let lifetimeProductID = "com.viditjain.Parq.lifetime"

    @Published private(set) var lifetimeProduct: Product?
    @Published private(set) var isLifetimeUnlocked = false
    @Published private(set) var isPurchasing = false
    @Published private(set) var isRestoring = false
    @Published var errorMessage: String?

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = observeTransactionUpdates()

        Task {
            await loadLifetimeProduct()
            await refreshEntitlements()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    var lifetimePriceText: String {
        lifetimeProduct?.displayPrice ?? "$1.99"
    }

    func syncStartupState() async {
        if lifetimeProduct == nil {
            await loadLifetimeProduct()
        }

        await refreshEntitlements()
    }

    func loadLifetimeProduct() async {
        do {
            let products = try await Product.products(for: [Self.lifetimeProductID])
            lifetimeProduct = products.first
        } catch {
            errorMessage = "Could not load purchase options right now."
        }
    }

    func purchaseLifetimeUnlock() async -> Bool {
        errorMessage = nil

        if lifetimeProduct == nil {
            await loadLifetimeProduct()
        }

        guard let lifetimeProduct else {
            errorMessage = "Lifetime purchase is not configured yet."
            return false
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await lifetimeProduct.purchase()

            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    errorMessage = "Could not verify the purchase."
                    return false
                }

                await handle(transaction: transaction)
                return true
            case .pending:
                errorMessage = "Purchase is pending approval."
                return false
            case .userCancelled:
                return false
            @unknown default:
                errorMessage = "Purchase did not complete."
                return false
            }
        } catch {
            errorMessage = "Purchase failed. Please try again."
            return false
        }
    }

    func restorePurchases() async -> Bool {
        errorMessage = nil
        isRestoring = true
        defer { isRestoring = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()

            if !isLifetimeUnlocked {
                errorMessage = "No lifetime purchase was found to restore."
            }

            return isLifetimeUnlocked
        } catch {
            errorMessage = "Could not restore purchases right now."
            return false
        }
    }

    func clearError() {
        errorMessage = nil
    }

    private func refreshEntitlements() async {
        var unlocked = false

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }

            if transaction.productID == Self.lifetimeProductID,
               transaction.revocationDate == nil {
                unlocked = true
            }
        }

        isLifetimeUnlocked = unlocked
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                guard case .verified(let transaction) = result else { continue }
                await self.handle(transaction: transaction)
            }
        }
    }

    private func handle(transaction: Transaction) async {
        if transaction.productID == Self.lifetimeProductID,
           transaction.revocationDate == nil {
            isLifetimeUnlocked = true
        }

        await transaction.finish()
    }
}
