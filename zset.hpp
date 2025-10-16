#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>

const int MAX_LEVEL = 16; // 最大层数
const float P = 0.5;      // 提升层的概率

struct Node
{
    int value;
    std::vector<Node *> forward; // 每一层的前进指针
    Node(int val, int level) : value(val), forward(level, nullptr) {}
};

class SkipList
{
private:
    Node *header; // 头节点
    int level;    // 目前实际使用的层数

public:
    SkipList();
    ~SkipList();
    int randomlevel();
    void insert(int value);
    void erase(int value);
    bool search(int value);
    void display();

};