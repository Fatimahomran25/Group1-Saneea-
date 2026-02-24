/// Defines the available account roles in the app.

enum AccountType { freelancer, client }

/// SignupModel is a simple data holder for the signup flow.
/// It stores the user's selected account type and basic profile fields.
/// Note: In this project, the UI mostly reads values from TextEditingControllers,
/// while this model keeps non-text state (like accountType) or can be used later
/// to store the finalized data.
class SignupModel {
  /// Selected role type (Freelancer or Client).
  AccountType? accountType;

  /// National ID / Iqama number (typically 10 digits).
  String? nationalId;

  /// User first name.
  String? firstName;

  /// User last name.
  String? lastName;

  /// User email address.
  String? email;
}
