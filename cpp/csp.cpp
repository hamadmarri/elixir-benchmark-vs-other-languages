#include <algorithm> // Added for std::equal
#include <chrono> // Must include this
#include <iostream>
#include <stack>
#include <vector> // Added

using namespace std;

static stack<vector<int>> mystack;

const int entropy = 10;
const int max_digit = 10;

void initCh(stack<vector<int>>& mystack)
{
    for (int i = 1; i <= entropy; i++) {
        vector<int> e;
        e.insert(e.begin(), i);
        mystack.push(e);
    }
}

// bool isSolution(const vector<int>& item, const vector<int>& solution) {
//     if (item.size() != solution.size()) {
//         return false;
//     }
//     for (size_t i = 0; i < item.size(); i++) {
//         if (item[i] != solution[i]) {
//             return false;
//         }
//     }
//     return true;
// }

inline int genCh(stack<vector<int>>& mystack, const vector<int>& parentItems, int stat)
{
    if (parentItems.size() >= max_digit) {
        return stat;
    }

    for (int i = 1; i <= entropy; i++) {
        vector<int> ch;
        ch.push_back(i);
        ch.insert(ch.end(), parentItems.begin(), parentItems.end());

        // cout << "children: ";
        // for (int c : ch) {
        //     cout << c << " ";
        // }
        // cout << endl;

        mystack.push(ch);
    }

    return stat + entropy;
}

void solve(stack<vector<int>>& mystack, const vector<int>& solution, int stat)
{
    while (true) {
        if (mystack.empty()) {
            cout << "Q IS EMPTY!, QUITTING!, count: " << stat << endl;
            return;
        }

        vector<int> item = mystack.top();
        mystack.pop();
        // cout << "Solve: ";
        // for (int i : item) {
        //     cout << i << " ";
        // }
        // cout << endl;

        if (equal(item.begin(), item.end(), solution.begin())) {
            // if (isSolution(item, solution)) {
            cout << "FOUND A SOLUTION ";
            for (int i : item) {
                cout << i << " ";
            }
            cout << ", count: " << stat << endl;
            return;
        }

        stat = genCh(mystack, item, stat);
    }
}

int main()
{
    // for (int i = 0; i < 10; i++) {
    auto start = chrono::high_resolution_clock::now();
    vector<int> solution = { 7, 7, 7, 7, 7, 7, 7, 5, 10 };
    mystack = stack<vector<int>>();
    initCh(mystack);
    // cout << "init stack ";
    // for (const auto& s : mystack.top()) {
    //     cout << s << " ";
    // }
    // cout << endl;

    solve(mystack, solution, mystack.size());
    auto end = chrono::high_resolution_clock::now();

    double duration = chrono::duration_cast<chrono::microseconds>(end - start).count();
    duration /= 1000.0; // Convert to milliseconds
    duration /= 1000.0; // Convert to seconds
    cout << "time: " << duration << "s" << endl;
    // }

    return 0;
}
