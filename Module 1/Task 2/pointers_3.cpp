// Task 2: User pointers to:
// 	3. Dynamically allocate an array of integers (size entered by user)
// 	4. Fill the array with user input using pointer arithmetic
// 	5. Display the array elements and their memory addresses
// 	6. Free the allocated memory using delete() function

#include <iostream>
using namespace std;

int main() {
	int size;

	cout << "Enter the size of array: ";
	cin >> size;

	int* arr = new int[size];

	for (int i = 0; i < size; i++) {
		cout << "Enter integer no." << i+1 << ": ";
		cin >> *(arr + i);
	}

	for (int i = 0; i < size; i++) {
		cout << *(arr + i) << endl;
		cout << (arr + i) << endl << endl;
	}

	return 0;
}


