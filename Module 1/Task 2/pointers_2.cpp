// Task 2: Use pointers to:
// 	2. Create a pointer to a pointer and display all levels of indirection


#include <iostream>
using namespace std;

int main() {
	int num;
	int* ptr1;
	int** ptr2;

	num = 56;
	ptr1 = &num;
	ptr2 = &ptr1;

	cout << "Values:\n";
	cout << "num   = " << num << endl;        // actual value
	cout << "*ptr1 = " << *ptr1 << endl;      // value pointed to by ptr1 (num)
	cout << "**ptr2 = " << **ptr2 << endl;    // value pointed to by ptr2 (num)

	cout << "\nAddresses:\n";
	cout << "&num  = " << &num << endl;       // address of num
	cout << "ptr1  = " << ptr1 << endl;       // same as &num
	cout << "*ptr2 = " << *ptr2 << endl;      // same as ptr1
	cout << "&ptr1 = " << &ptr1 << endl;      // address of ptr1
	cout << "ptr2  = " << ptr2 << endl;       // same as &ptr1
	cout << "&ptr2 = " << &ptr2 << endl;      // address of ptr2 (top-level)
					      //
	
	return 0;
}
