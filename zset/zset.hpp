#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>
#include <limits>
#include "luna.h"

const int MAX_LEVEL = 16; // 最大层数
const float P = 0.5;      // 提升层的概率

template<typename T>
struct Node
{
    T value;
    std::vector<Node<T>*> forward; // 每一层的前进指针，注意这里是 Node<T>*
    Node(T val, int level) : value(val), forward(level, nullptr) {}
};

template<typename T>
class SkipList
{
private:
    Node<T>* header; // 头节点，注意这里是 Node<T>*
    int level;       // 目前实际使用的层数
    int size;        // 元素数量

    // 随机层数函数
    int randomlevel() {
        int lvl = 1;
        while (((float)rand() / RAND_MAX) < P && lvl < MAX_LEVEL) {
            lvl++;
        }
        return lvl;
    }

public:
    SkipList() {
        level = 1;
        header = new Node<T>(std::numeric_limits<T>::min(), MAX_LEVEL);
        srand(static_cast<unsigned>(time(nullptr)));
        size = 0;
    }

    ~SkipList() {
        Node<T>* current = header;
        while (current) {
            Node<T>* next = current->forward[0];
            delete current;
            current = next;
        }
    }

    void insert(T value) {
        Node<T>* current = header;
        std::vector<Node<T>*> update(MAX_LEVEL, nullptr);
        
        for (int i = level - 1; i >= 0; i--) {
            while (current->forward[i] && current->forward[i]->value < value) {
                current = current->forward[i];
            }
            update[i] = current;
        }
        
        int newLevel = randomlevel();
        if (newLevel > level) {
            for (int i = level; i < newLevel; i++) {
                update[i] = header;
            }
            level = newLevel;
        }
        
        Node<T>* newNode = new Node<T>(value, newLevel);
        for (int i = 0; i < newLevel; i++) {
            newNode->forward[i] = update[i]->forward[i];
            update[i]->forward[i] = newNode;
        }
        size++;
    }

    void erase(T value) {
        Node<T>* current = header;
        std::vector<Node<T>*> update(MAX_LEVEL, nullptr);
        
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

    bool search(T value) {
        Node<T>* current = header;
        for (int i = level - 1; i >= 0; i--) {
            while (current->forward[i] && current->forward[i]->value < value) {
                current = current->forward[i];
            }
        }
        current = current->forward[0];
        return current && current->value == value;
    }

    void display() {
        for (int i = level - 1; i >= 0; i--) {
            Node<T>* current = header->forward[i];
            std::cout << "Level " << i + 1 << ": ";
            while (current) {
                std::cout << current->value << " ";
                current = current->forward[i];
            }
            std::cout << std::endl;
        }
    }

    int getRankByScore(T value) {
        Node<T>* curr = header->forward[0];
        int rank = 0;
        while (curr) {
            rank++;
            // 获取该分数的第一位排名
            if (curr->value == value && 
                (curr->forward[0] == nullptr || curr->forward[0]->value != value)) {
                return size - rank + 1; // 转成降序排名
            }
            curr = curr->forward[0];
        }
        return -1;
    }

    int getSize() const { 
        return size; 
    }

    std::vector<T> getTopK(int k) {
        std::vector<T> res;
        std::vector<T> scores;
        Node<T>* curr = header->forward[0];
        while (curr) {
            scores.push_back(curr->value);
            curr = curr->forward[0];
        }
        // 跳表是升序，反转取前k个
        for (int i = static_cast<int>(scores.size()) - 1; i >= 0 && static_cast<int>(res.size()) < k; i--) {
            res.push_back(scores[i]);
        }
        return res;
    }
};

// 为Lua导出创建具体类型的别名
// 这样可以在C++中使用泛型，同时为Lua提供具体类型
using IntSkipList = SkipList<int>;
using DoubleSkipList = SkipList<double>;