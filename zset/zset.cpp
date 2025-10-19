#include "zset.hpp"
#include <limits>

using namespace std;

SkipList::SkipList() {
    level = 1;
    header = new Node(std::numeric_limits<int>::min(), MAX_LEVEL);
    srand(time(nullptr));
    size = 0;
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
    size++;
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
    size--;
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

int SkipList::getRankByScore(int value) {
    Node* curr = header->forward[0];
    int rank = 0;
     while (curr) {
        rank++;
        if (curr->value == value)
            return size - rank + 1; // 转成降序排名
        curr = curr->forward[0];
    }
    return -1;
}

std::vector<int> SkipList::getTopK(int k) {
    std::vector<int> res;
    std::vector<int> scores;
    Node* curr = header->forward[0];
    while (curr) {
        scores.push_back(curr->value);
        curr = curr->forward[0];
    }
    // 跳表是升序，反转取前k个
    for (int i = scores.size() - 1; i >= 0 && res.size() < k; i--)
        res.push_back(scores[i]);
    return res;
}

// Luna 实现
LUA_EXPORT_CLASS_BEGIN(SkipList)
LUA_EXPORT_METHOD(insert)
LUA_EXPORT_METHOD(erase)
LUA_EXPORT_METHOD(search)
LUA_EXPORT_METHOD(display)
LUA_EXPORT_METHOD(getRankByScore)
LUA_EXPORT_METHOD(getSize)
LUA_EXPORT_METHOD(getTopK)
LUA_EXPORT_CLASS_END()










