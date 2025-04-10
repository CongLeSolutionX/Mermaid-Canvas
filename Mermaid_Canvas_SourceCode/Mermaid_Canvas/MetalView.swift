import SwiftUI
import Contacts       // Required for CNContact, CNMutableContact, etc.
import ContactsUI     // Required for CNContactViewController

// MARK: - UIViewControllerRepresentable Wrapper

struct ContactViewControllerRepresentable: UIViewControllerRepresentable {

    // The contact to display
    let contact: CNContact

    // Optional: Customize if the user can perform actions (like messaging, calling)
    let allowsActions: Bool = true
    // Optional: Customize if the contact can be edited (doesn't apply when just displaying)
    // let allowsEditing: Bool = false

    // Creates the Coordinator class instance
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Creates the CNContactViewController instance
    func makeUIViewController(context: Context) -> CNContactViewController {
        // Create the view controller for the specific contact
        let viewController = CNContactViewController(for: contact)

        // Set the delegate to handle events (like Done button)
        viewController.delegate = context.coordinator

        // Apply customizations
        viewController.allowsActions = self.allowsActions
        // viewController.allowsEditing = self.allowsEditing // Usually false when just displaying

        // Optional: Specify which properties to show (nil shows default set)
        // viewController.displayedPropertyKeys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey]

        return viewController
    }

    // Updates the view controller if needed (e.g., if `contact` or settings change)
    // Note: CNContactViewController doesn't easily allow changing the contact after creation.
    // If the contact needs to change significantly, SwiftUI will typically recreate the representable.
    // We mainly ensure the delegate and basic properties are still set.
    func updateUIViewController(_ uiViewController: CNContactViewController, context: Context) {
        // Ensure delegate is still set (though usually handled by makeUIViewController)
        uiViewController.delegate = context.coordinator
        // Re-apply properties that might have changed
        uiViewController.allowsActions = self.allowsActions
        // uiViewController.allowsEditing = self.allowsEditing
        
        // --- Important Note on Updating the Contact ---
        // Directly changing the 'contact' property on an existing CNContactViewController
        // instance isn't a standard supported operation. If the `contact` passed into
        // this Representable changes its *identity* (i.e., it's a completely different
        // CNContact object), SwiftUI's diffing mechanism will likely destroy the old
        // `ContactViewControllerRepresentable` and create a new one, triggering
        // `makeUIViewController` again with the new contact.
        // If only internal properties of the *same* contact object instance change,
        // CNContactViewController might not automatically reflect that without being
        // reconstructed. For this simple display example, we assume the contact passed in
        // is the one we want to show initially.
    }

    // MARK: - Coordinator Class

    class Coordinator: NSObject, CNContactViewControllerDelegate {
        var parent: ContactViewControllerRepresentable

        init(_ parent: ContactViewControllerRepresentable) {
            self.parent = parent
        }

        // Delegate method called when the user interacts with the contact view controller
        // (e.g., taps Done, performs an action, finishes editing)
        func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
            // This method is called when the view controller finishes its task.
            // 'contact' parameter is nil if the user cancels or deletes (when editing allowed),
            // or contains the contact if saved/selected.
            //
            // In this embedded scenario (not presented modally), "Done" doesn't typically
            // dismiss the view itself. You might use this callback if you presented it
            // modally using .sheet() to dismiss the sheet.
            // For now, we just print a message.
            if let completedContact = contact {
                print("ContactViewController finished with contact: \(completedContact.givenName)")
            } else {
                print("ContactViewController finished (Cancelled or contact deleted/unavailable).")
            }

            // --- If presented modally using .sheet ---
            // You would typically have a binding passed to the parent or coordinator
            // to control the presentation state, e.g.:
            // parent.isPresented = false
        }

        // Optional Delegate Method: Decide if a property action should be performed
        // func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        //    print("Attempting default action for property: \(property.key)")
        //    return true // Return true to allow the default action (call, email, etc.)
        // }
    }
}

// MARK: - Helper Function to Create Sample Contact

func createSampleContact() -> CNContact {
    let contact = CNMutableContact()

    contact.givenName = "John"
    contact.familyName = "Appleseed"

    let email = CNLabeledValue(label: CNLabelHome, value: "john.appleseed@example.com" as NSString)
    contact.emailAddresses = [email]

    let phone = CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: "555-123-4567"))
    contact.phoneNumbers = [phone]

    let address = CNMutablePostalAddress()
    address.street = "1 Infinite Loop"
    address.city = "Cupertino"
    address.state = "CA"
    address.postalCode = "95014"
    address.country = "USA"
    let addrLabel = CNLabeledValue(label: CNLabelWork, value: address)
//    contact.postalAddresses = [addrLabel]

    // Make it immutable before returning
    return contact.copy() as! CNContact
}

// MARK: - SwiftUI Content View

struct ContentView: View {
    // Hold the sample contact in state (though it's constant in this example)
    @State private var sampleContact: CNContact = createSampleContact()

    var body: some View {
        NavigationView {
            // Embed the CNContactViewController wrapper
            ContactViewControllerRepresentable(contact: sampleContact)
                // Often useful to ignore safe areas if you want it to fill edges,
                // depending on the container. NavigationView handles this well.
                // .edgesIgnoringSafeArea(.all) // Use with caution
                .navigationTitle("Contact Details")
                .navigationBarTitleDisplayMode(.inline) // Or .large
        }
         // Use stack style for consistency, especially on iPad
        .navigationViewStyle(.stack)
    }
}

// MARK: - Preview Provider

#Preview {
    ContentView()
}

// MARK: - App Entry Point (If this is the main file)
/*
@main
struct ContactUIDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/
