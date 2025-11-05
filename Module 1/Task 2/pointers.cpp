// Task 2: Use pointers to:
// 	1. Store and display value and address of an integer variable

#include <iostream>
using namespace std;

int main() {
	int num;
	int* ptr;

	num = 56;
	ptr = &num;

	cout << "Value of integer variable: " << num;
	cout << "\nAddress of integer vairable: " << ptr << "\n";


	return 0;
}
