// Task 2: Coding a calculator using C++

#include <iostream>
using namespace std;

int main() {

	float num1, num2, result;
	char operation;

	cout << "Enter first operand: ";
	cin >> num1;

	cout << "Enter second operand: ";
	cin >> num2;

	cout << "Choose operation: (+, -, *, /): ";
	cin >> operation;

	switch (operation) {
		case '+':
			result = num1 + num2;
			break;
		case '-':
			result = num1 - num2;
			break;
		case '*':
			result = num1 * num2;
			break;
		case '/':
			result = num1 / num2;
			break;
	}

	cout << "\n" << num1 << " " << operation << " " << num2 << " "  << "=" << " " << result << "\n\n";

	return 0;
}
