// Implement a small program that demonstrates all major OOP concepts
// Requirements:
// 1. Create a base class
// 2. Encapsulation
// 3. Inheritance
// 4. Polumorphism
// 5. Abstraction
// 6. Object Creation

#include <iostream>
#include <string>
using namespace std;

class Account {
	private:
		string accountNumber;
		double balance;
	
	public:
		// initialise
		Account(string accNum, double amount) : accountNumber(accNum), balance(amount) {}

		// setter functions
		void setAccountNumber(string accNum) {
			accountNumber = accNum;
		}

		void setBalance(double amount) {
			balance = amount;
		}

		// getter functions
		string getAccountNumber() {
			return accountNumber;
		}

		float getBalance() {
			return balance;
		}

		// methods
		void deposit(double amount) {
			balance = balance + amount;
			
			cout << "Rs." << amount << " successfully deposited in your account." << endl;
		}

		virtual void withdraw(double amount) {
			if (amount > balance) {
				cout << "Account balance is insufficient for withdrawal." <<  endl;
			} else {
				balance = balance - amount;

				cout << "Rs." << amount << " successfully withdrawn from your account." << endl;
			}
		}

		void displayBalance() {
			cout << "You have Rs." << balance << " in your account." << endl;
		}

};

class SavingsAccount : public Account {
	public:
		// initialise
		SavingsAccount(string accNum, double amount) : Account(accNum, amount) {}

		// methods
		void withdraw(double amount) override {
			if (Account::getBalance() - amount < 500) {
				cout << "Cannot withdraw! Minimum balance of Rs. 500 is required.\n";
			} else {
				Account::setBalance(Account::getBalance() - amount);
				cout << "Rs." << amount << " successfully withdrawn from your account." << endl;
			}
		}
};

class CurrentAccount : public Account {
	public:
		// initialise
		CurrentAccount(string accNum, double amount) : Account(accNum, amount) {}
		
		// methods
		void withdraw(double amount) override {
			if (Account::getBalance() - amount < -5000) { // overdraft limit
				cout << "Overdraft limit exceeded!\n";
			} else {
			        Account::setBalance(Account::getBalance() - amount);
				cout << "Withdrawn " << amount << " from Current Account.\n";
			}
    		}
};

int main() {
	// Declare pointer of base class type
	Account* acc;

	// Create derived objects
	SavingsAccount s1("Muhammad", 10000);
	CurrentAccount c1("Ahmed", 2000);

	// Point to SavingsAccount object
	acc = &s1;
	acc->withdraw(9600);   // calls SavingsAccount version
	acc->displayBalance();
	acc->deposit(3000);
	acc->displayBalance();
	acc->withdraw(20000);
	acc->displayBalance();

	cout << endl;

	// Point to CurrentAccount object
	acc = &c1;
	acc->withdraw(4000);   // calls CurrentAccount version
	acc->displayBalance();
	acc->deposit(2500);
	acc->displayBalance();
	acc->withdraw(100000);
	acc->displayBalance();

	return 0;
}


