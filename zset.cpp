#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>
#include <limits>

using namespace std;

const int MAX_LEVEL = 16;     // 最大层数
const float P = 0.5;          // 提升层的概率

struct Node {
    int value;
    vector<Node*> forward; // forward[i] -> 第 i 层的下一个节点

    Node(int val, int level) : value(val), forward(level, nullptr) {}
};

class SkipList {
private:
    Node* header;     // 头节点
    int level;        // 目前实际使用的层数

public:
    SkipList() {
        level = 1;
        // 创建头节点，值为最小整数
        header = new Node(std::numeric_limits<int>::min(), MAX_LEVEL);
        srand(time(nullptr)); // 初始化根据时间定义的随机数种子
    }

    // 随机生成节点层数
    int randomLevel() {
        int lvl = 1;
        while ((rand() % 100) < (P * 100) && lvl < MAX_LEVEL)
            lvl++;
        return lvl;
    }

    // 查找
    bool search(int value) {
        Node* curr = header;
        for (int i = level - 1; i >= 0; --i) {
            while (curr->forward[i] && curr->forward[i]->value < value)
                curr = curr->forward[i];
        }
        curr = curr->forward[0];
        return curr && curr->value == value;
    }

    // 插入
    void insert(int value) {
        vector<Node*> update(MAX_LEVEL, nullptr); // 每一层插入前的位置
        Node* curr = header;

        for (int i = level - 1; i >= 0; --i) {
            while (curr->forward[i] && curr->forward[i]->value < value)
                curr = curr->forward[i];
            update[i] = curr;
        }

        curr = curr->forward[0];
        if (curr && curr->value == value) return; // 已存在

        int newLevel = randomLevel();
        if (newLevel > level) {
            for (int i = level; i < newLevel; ++i)
                update[i] = header;
            level = newLevel;
        }

        Node* newNode = new Node(value, newLevel);
        for (int i = 0; i < newLevel; ++i) {
            newNode->forward[i] = update[i]->forward[i];
            update[i]->forward[i] = newNode;
        }
    }

    // 删除
    void erase(int value) {
        vector<Node*> update(MAX_LEVEL, nullptr);
        Node* curr = header;

        for (int i = level - 1; i >= 0; --i) {
            while (curr->forward[i] && curr->forward[i]->value < value)
                curr = curr->forward[i];
            update[i] = curr;
        }

        curr = curr->forward[0];
        if (curr && curr->value == value) {
            for (int i = 0; i < level; ++i) {
                if (update[i]->forward[i] != curr) break;
                update[i]->forward[i] = curr->forward[i];
            }
            delete curr;
            while (level > 1 && !header->forward[level - 1])
                level--;
        }
    }

    // 打印
    void display() {
        cout << "SkipList Levels: " << level << endl;
        for (int i = level - 1; i >= 0; --i) {
            Node* node = header->forward[i];
            cout << "Level " << i + 1 << ": ";
            while (node) {
                cout << node->value << " ";
                node = node->forward[i];
            }
            cout << endl;
        }
    }
};

int main() {
    SkipList sl;
    sl.insert(10);
    sl.insert(20);
    sl.insert(15);
    sl.insert(30);
    sl.insert(5);

    sl.display();

    cout << "Find 15? " << sl.search(15) << endl;
    cout << "Find 100? " << sl.search(100) << endl;

    sl.erase(15);
    sl.display();
}
