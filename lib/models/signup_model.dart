enum AccountType { freelancer, client }

class SignupModel {
  String? nationalId;
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? confirmPassword;

  AccountType? accountType;
}
