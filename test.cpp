#include "zset.hpp"
#include <iostream>

using namespace std;

int main() {
    SkipList list;
    list.insert(3);
    list.insert(6);
    list.insert(7);
    list.insert(9);
    list.insert(12);
    list.insert(19);
    list.insert(17);
    list.insert(26);
    list.insert(21);
    list.insert(25);

    cout << "Skip List after insertion:" << endl;
    list.display();

    cout << "Search for 19: " << (list.search(19) ? "Found" : "Not Found") << endl;
    cout << "Search for 15: " << (list.search(15) ? "Found" : "Not Found") << endl;

    list.erase(19);
    cout << "Skip List after deleting 19:" << endl;
    list.display();

    return 0;
}