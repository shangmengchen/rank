#include "zset.hpp"
#include <limits>

using namespace std;

SkipList::SkipList() {
    level = 1;
    header = new Node(std::numeric_limits<int>::min(), MAX_LEVEL);
    srand(time(nullptr));
}

SkipList::~SkipList() {
    for (; level >= 0; level--) {
        Node *current = header->forward[level];
        while (current) {
            Node *next = current->forward[level];
            delete current;
            current = next;
        }
    }
}

int SkipList::randomlevel() {
    int lvl = 1;
    while (((float)rand() / RAND_MAX) < P && lvl < MAX_LEVEL) {
        lvl++;
    }
    return lvl;
}

bool SkipList::search(int value) {
    Node *current = header;
    for (int i = level - 1; i >= 0; i--) {
        while (current->forward[i] && current->forward[i]->value < value) {
            current = current->forward[i];
        }
    }
    current = current->forward[0];
    return current && current->value == value;
}

void SkipList::insert(int value) {
    Node *current = header;
    // Find the position brefore insertion point
    vector<Node *> update(MAX_LEVEL, nullptr);    
    for (int i = level - 1; i >= 0; i--) {
        while (current->forward[i] && current->forward[i]->value < value) {
            current = current->forward[i];
        }
        update[i] = current;
    }
    current = current->forward[0];
    if (current && current->value == value) {
        return; // Value already exists
    }
    int newLevel = randomlevel();
    if (newLevel > level) {
        for (int i = level; i < newLevel; i++) {
            update[i] = header;
        }
        level = newLevel;
    }
    Node *newNode = new Node(value, newLevel);
    for (int i = 0; i < newLevel; i++) {
        newNode->forward[i] = update[i]->forward[i];
        update[i]->forward[i] = newNode;
    }
}

void SkipList::erase(int value) {
    Node *current = header;
    vector<Node *> update(MAX_LEVEL, nullptr);
    for (int i = level - 1; i >= 0; i--) {
        while (current->forward[i] && current->forward[i]->value < value) {
            current = current->forward[i];
        }
        update[i] = current;
    }
    current = current->forward[0];
    if (!current || current->value != value) {
        return; // Value not found
    }
    for (int i = 0; i < level; i++) {
        if (update[i]->forward[i] != current) {
            break;
        }
        update[i]->forward[i] = current->forward[i];
    }
    delete current;
}

void SkipList::display() {
    for (int i = level - 1; i >= 0; i--) {
        Node *current = header->forward[i];
        cout << "Level " << i + 1 << ": ";
        while (current) {
            cout << current->value << " ";
            current = current->forward[i];
        }
        cout << endl;
    }
}

// Luna 实现
LUA_EXPORT_CLASS_BEGIN(SkipList)
LUA_EXPORT_METHOD(insert)
LUA_EXPORT_METHOD(erase)
LUA_EXPORT_METHOD(search)
LUA_EXPORT_METHOD(display)
LUA_EXPORT_CLASS_END()










