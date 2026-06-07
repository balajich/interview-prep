# Java Data Structures — Practice Questions

> **How to use:** Work through each question on your own before opening the answers file.  
> Every question uses only classes from `java.util` — no custom implementations.  
> Focus on learning the key operations: add, remove, peek, iterate, search.  
> 💚 Beginner · 🟡 Intermediate · 🔴 Advanced

---

## Table of Contents
1. [Stack](#1-stack)
2. [Queue](#2-queue)
3. [LinkedList](#3-linkedlist)
4. [Deque (Double-Ended Queue)](#4-deque-double-ended-queue)
5. [PriorityQueue](#5-priorityqueue)
6. [Set & HashSet](#6-set--hashset)
7. [TreeSet](#7-treeset)
8. [Map & HashMap](#8-map--hashmap)

---

## 1. Stack

> Use `java.util.Deque` (backed by `ArrayDeque`) — `java.util.Stack` is legacy and not recommended.

### 💚 Beginner

**SK1 — Push and pop**  
Create a `Deque<String>` used as a stack. Push `"A"`, `"B"`, `"C"` onto it. Pop and print each element. What order do they come out?

```java
void pushAndPop() { }
```
Expected output: `C`, `B`, `A`

---

**SK2 — Peek without removing**  
Push `10`, `20`, `30` onto an integer stack. Peek at the top element without removing it. Print the top, then print the stack size to confirm nothing was removed.

```java
void peekStack() { }
```
Expected: top = `30`, size still = `3`

---

**SK3 — Check empty before pop**  
Pop all elements from a stack safely using a loop. Print each popped value. Do not throw `EmptyStackException` — check before each pop.

```java
void drainStack(Deque<Integer> stack) { }
```

---

### 🟡 Intermediate

**SK4 — Balanced parentheses**  
Given a `String` containing only `(`, `)`, `[`, `]`, `{`, `}`, use a stack to determine if the brackets are balanced and correctly nested.

```java
boolean isBalanced(String s) { }
```
Example: `"({[]})"` → `true`, `"({[}])"` → `false`, `"((("` → `false`

---

**SK5 — Reverse a string using a stack**  
Use a `Deque<Character>` stack to reverse the characters of a given string. Return the reversed string.

```java
String reverseWithStack(String input) { }
```
Example: `"hello"` → `"olleh"`

---

**SK6 — Evaluate a number sequence**  
Given a list of integers, use a stack to return a new list where every element is replaced by the **next greater element** to its right. Use `-1` if no greater element exists to the right.

```java
List<Integer> nextGreaterElement(List<Integer> nums) { }
```
Example: `[4, 5, 2, 10, 8]` → `[5, 10, 10, -1, -1]`

---

### 🔴 Advanced

**SK7 — Min stack**  
Design a stack that supports `push`, `pop`, `peek`, and `getMin` — all in O(1) time. Use two `Deque<Integer>` objects (one main stack, one to track minimums).

```java
class MinStack {
    Deque<Integer> stack    = new ArrayDeque<>();
    Deque<Integer> minStack = new ArrayDeque<>();

    void push(int val)  { }
    void pop()          { }
    int  peek()         { }
    int  getMin()       { }
}
```
Example: push `5,3,7,2` → `getMin()` = `2`; pop → `getMin()` = `3`

---

## 2. Queue

> Use `java.util.Queue` interface backed by `java.util.LinkedList` or `java.util.ArrayDeque`.

### 💚 Beginner

**Q1 — Offer and poll**  
Create a `Queue<String>` and add `"Alice"`, `"Bob"`, `"Charlie"`. Remove and print each element. What order do they come out?

```java
void offerAndPoll() { }
```
Expected output: `Alice`, `Bob`, `Charlie`

---

**Q2 — Peek without removing**  
Enqueue `100`, `200`, `300`. Peek at the front element without removing it. Print the front, then print the size to confirm nothing was removed.

```java
void peekQueue() { }
```
Expected: front = `100`, size still = `3`

---

**Q3 — Safe poll with null check**  
Drain a `Queue<String>` safely. `poll()` returns `null` when empty — use this to loop without an extra `isEmpty()` check.

```java
void drainQueue(Queue<String> queue) { }
```

---

### 🟡 Intermediate

**Q4 — Print queue contents without permanent removal**  
Given a `Queue<Integer>`, print all elements in order, then restore the queue to its original state. (Hint: use `size()` and re-enqueue after dequeuing.)

```java
void printAndRestore(Queue<Integer> queue) { }
```

---

**Q5 — Moving average**  
Given a `Queue<Integer>` of fixed capacity `k`, implement a method that adds a new number, evicts the oldest if at capacity, and returns the current average of the `k` elements.

```java
double movingAverage(Queue<Integer> window, int k, int newVal) { }
```
Example: k=3, add 1→avg=1.0, add 2→avg=1.5, add 3→avg=2.0, add 4→avg=3.0

---

**Q6 — Level-order binary tree print (BFS)**  
Given the root of a simple integer binary tree (use `int[]` parent lookup for simplicity, or define a minimal record), use a `Queue` to print all node values level by level.

```java
record TreeNode(int val, TreeNode left, TreeNode right) { }

void levelOrder(TreeNode root) { }
```
Example: a tree with root 1, children 2 and 3, prints: `1 | 2 3`

---

## 3. LinkedList

> `java.util.LinkedList` implements both `List` and `Deque` — use it to practice positional and front/back operations.

### 💚 Beginner

**LL1 — Add to front and back**  
Create a `LinkedList<String>` and add `"Middle"` normally, then add `"First"` to the front and `"Last"` to the back using the appropriate `LinkedList` methods. Print the result.

```java
void addFrontAndBack() { }
```
Expected: `[First, Middle, Last]`

---

**LL2 — Remove from front and back**  
Given a `LinkedList<Integer>` with values `[10, 20, 30, 40, 50]`, remove the first element and the last element. Print the remaining list.

```java
void removeFrontAndBack(LinkedList<Integer> list) { }
```
Expected: `[20, 30, 40]`

---

**LL3 — Get by index**  
Retrieve the element at index `2` from a `LinkedList<String>` using `get(index)`. Explain why this is O(n) for `LinkedList` compared to O(1) for `ArrayList`.

```java
String getByIndex(LinkedList<String> list) { }
```

---

### 🟡 Intermediate

**LL4 — Rotate list left by one**  
Given a `LinkedList<Integer>`, rotate it left by one position: the first element moves to the end.

```java
void rotateLeft(LinkedList<Integer> list) { }
```
Example: `[1, 2, 3, 4, 5]` → `[2, 3, 4, 5, 1]`

---

**LL5 — Remove all occurrences of a value**  
Remove every occurrence of a given value from a `LinkedList<Integer>` using an `Iterator` (not a regular for-each loop, which would throw `ConcurrentModificationException`).

```java
void removeAll(LinkedList<Integer> list, int value) { }
```
Example: `[1, 2, 3, 2, 4, 2]`, remove `2` → `[1, 3, 4]`

---

**LL6 — Check if palindrome**  
Given a `LinkedList<Integer>`, return `true` if it reads the same forwards and backwards. Use the list's `ListIterator` (supports both forward and backward traversal).

```java
boolean isPalindrome(LinkedList<Integer> list) { }
```
Example: `[1, 2, 3, 2, 1]` → `true`, `[1, 2, 3]` → `false`

---

### 🔴 Advanced

**LL7 — Merge two sorted LinkedLists**  
Given two `LinkedList<Integer>` objects that are each sorted in ascending order, merge them into one sorted `LinkedList<Integer>` without using `Collections.sort()`.

```java
LinkedList<Integer> mergeSorted(LinkedList<Integer> a, LinkedList<Integer> b) { }
```
Example: `[1,3,5]` + `[2,4,6]` → `[1,2,3,4,5,6]`

---

## 4. Deque (Double-Ended Queue)

> Use `java.util.Deque` interface backed by `java.util.ArrayDeque`.

### 💚 Beginner

**DQ1 — Add to both ends**  
Create an `ArrayDeque<String>` and add `"B"` first, then add `"A"` to the front and `"C"` to the back. Print the deque.

```java
void addBothEnds() { }
```
Expected: `[A, B, C]`

---

**DQ2 — Remove from both ends**  
Given a `Deque<Integer>` with values `[10, 20, 30, 40, 50]`, remove the first element and the last element. Print the remaining deque.

```java
void removeBothEnds(Deque<Integer> deque) { }
```
Expected: `[20, 30, 40]`

---

**DQ3 — Peek both ends**  
Given a non-empty `Deque<String>`, peek at the first and last elements without removing them.

```java
void peekBothEnds(Deque<String> deque) { }
```

---

### 🟡 Intermediate

**DQ4 — Deque as both stack and queue**  
Using a single `ArrayDeque<Integer>`, demonstrate:
1. Stack behaviour: push `1,2,3` then pop — prints `3,2,1`
2. Queue behaviour: enqueue `1,2,3` then dequeue — prints `1,2,3`

```java
void stackAndQueueDemo() { }
```

---

**DQ5 — Sliding window maximum**  
Given a `List<Integer>` and a window size `k`, return a list of the maximum value in each window of size `k` as the window slides right. Use a `Deque<Integer>` to store indices.

```java
List<Integer> slidingWindowMax(List<Integer> nums, int k) { }
```
Example: `[1,3,-1,-3,5,3,6,7]`, k=3 → `[3,3,5,5,6,7]`

---

**DQ6 — Palindrome checker using Deque**  
Use a `Deque<Character>` to check if a string is a palindrome. Add all characters, then compare characters removed from both ends simultaneously.

```java
boolean isPalindromeDeque(String s) { }
```
Example: `"racecar"` → `true`, `"hello"` → `false`

---

## 5. PriorityQueue

> `java.util.PriorityQueue` — min-heap by default (smallest element polled first).

### 💚 Beginner

**PQ1 — Natural ordering**  
Add `5, 1, 3, 2, 4` to a `PriorityQueue<Integer>`. Poll all elements and print them. What order comes out?

```java
void naturalOrder() { }
```
Expected: `1, 2, 3, 4, 5`

---

**PQ2 — Max heap**  
Create a `PriorityQueue<Integer>` that polls the **largest** element first (max-heap). Add `5, 1, 3, 2, 4` and poll all.

```java
void maxHeap() { }
```
Expected: `5, 4, 3, 2, 1`

---

**PQ3 — Peek without removing**  
Add several integers to a `PriorityQueue`. Peek at the minimum without polling. Print the minimum and confirm size is unchanged.

```java
void peekMin() { }
```

---

### 🟡 Intermediate

**PQ4 — Custom object ordering**  
Create a `PriorityQueue<String>` that orders strings by **length** (shortest first). Add `"banana"`, `"fig"`, `"apple"`, `"kiwi"`. Poll and print all.

```java
void orderByLength() { }
```
Expected: `fig`, `kiwi`, `apple`, `banana`

---

**PQ5 — K smallest elements**  
Given a `List<Integer>` and an integer `k`, return the `k` smallest values using a `PriorityQueue`. Do not sort the entire list.

```java
List<Integer> kSmallest(List<Integer> nums, int k) { }
```
Example: `[7, 10, 4, 3, 1, 8]`, k=3 → `[1, 3, 4]`

---

**PQ6 — Merge K sorted lists**  
Given a `List<List<Integer>>` where each inner list is sorted in ascending order, merge all into one sorted `List<Integer>` using a `PriorityQueue`.

```java
List<Integer> mergeKSorted(List<List<Integer>> lists) { }
```
Example: `[[1,4,7],[2,5,8],[3,6,9]]` → `[1,2,3,4,5,6,7,8,9]`

---

### 🔴 Advanced

**PQ7 — K most frequent elements**  
Given a `List<Integer>`, return the `k` most frequently occurring values using a `PriorityQueue` (min-heap of size `k` on frequency). Return results in any order.

```java
List<Integer> kMostFrequent(List<Integer> nums, int k) { }
```
Example: `[1,1,1,2,2,3]`, k=2 → `[1, 2]`

---

## 6. Set & HashSet

> `java.util.HashSet` — unordered, O(1) add/remove/contains, no duplicates.

### 💚 Beginner

**SE1 — Add and contains**  
Create a `HashSet<String>` and add `"cat"`, `"dog"`, `"bird"`, `"cat"` (duplicate). Print the size. Check if `"dog"` and `"fish"` are in the set.

```java
void addAndContains() { }
```
Expected: size = `3`, `"dog"` present, `"fish"` absent

---

**SE2 — Remove an element**  
Add `1` through `5` to a `HashSet<Integer>`. Remove `3`. Print all remaining elements (order may vary).

```java
void removeElement() { }
```

---

**SE3 — Eliminate duplicates from a list**  
Given a `List<Integer>` that may contain duplicates, return a `List<Integer>` with only unique values using a `HashSet`.

```java
List<Integer> removeDuplicates(List<Integer> list) { }
```
Example: `[1,2,3,2,1,4]` → `[1,2,3,4]` (order may vary)

---

### 🟡 Intermediate

**SE4 — Union, intersection, difference**  
Given two `Set<Integer>` objects, compute:
1. Union (all elements from both)
2. Intersection (only elements in both)
3. Difference (elements in `a` but not in `b`)

```java
Set<Integer> union(Set<Integer> a, Set<Integer> b)        { }
Set<Integer> intersection(Set<Integer> a, Set<Integer> b) { }
Set<Integer> difference(Set<Integer> a, Set<Integer> b)   { }
```

---

**SE5 — First repeated character**  
Given a `String`, find the first character that appears more than once. Use a `HashSet<Character>` to track seen characters.

```java
char firstRepeated(String s) { }
```
Example: `"abcabc"` → `'a'`, `"abcdef"` → `'\0'` (none)

---

**SE6 — Subsets check**  
Return `true` if `Set<Integer> a` is a subset of `Set<Integer> b` (every element of `a` is also in `b`). Use only `Set` API methods — no loops.

```java
boolean isSubset(Set<Integer> a, Set<Integer> b) { }
```
Example: `a={1,2}`, `b={1,2,3,4}` → `true`; `a={1,5}`, `b={1,2,3}` → `false`

---

## 7. TreeSet

> `java.util.TreeSet` — sorted (natural order or custom `Comparator`), O(log n) operations, no duplicates.

### 💚 Beginner

**TS1 — Natural sorted order**  
Add `5, 3, 1, 4, 2` to a `TreeSet<Integer>`. Print all elements. What order do they appear in?

```java
void naturalOrder() { }
```
Expected: `1, 2, 3, 4, 5`

---

**TS2 — First and last**  
Given a `TreeSet<Integer>` with values `[10, 30, 20, 50, 40]`, retrieve the smallest and largest element using built-in methods.

```java
void firstAndLast(TreeSet<Integer> set) { }
```
Expected: first = `10`, last = `50`

---

**TS3 — Headset and tailset**  
Given a `TreeSet<Integer>` with values `[1,2,3,4,5,6,7,8,9,10]`:
- Get all elements **less than** `5` (headSet)
- Get all elements **greater than or equal to** `7` (tailSet)

```java
void headAndTail(TreeSet<Integer> set) { }
```
Expected head: `[1,2,3,4]` · tail: `[7,8,9,10]`

---

### 🟡 Intermediate

**TS4 — Floor and ceiling**  
Given a `TreeSet<Integer>` with values `[10, 20, 30, 40, 50]`:
- Find the **floor** of `25` (greatest element ≤ 25)
- Find the **ceiling** of `25` (smallest element ≥ 25)

```java
void floorAndCeiling(TreeSet<Integer> set) { }
```
Expected: floor = `20`, ceiling = `30`

---

**TS5 — Custom sort order**  
Create a `TreeSet<String>` sorted by string **length** (shortest first). When lengths are equal, sort alphabetically. Add `"banana"`, `"fig"`, `"apple"`, `"kiwi"`, `"mango"` and print them.

```java
void sortByLength() { }
```
Expected: `fig`, `kiwi`, `apple`, `mango`, `banana`

---

**TS6 — Range query**  
Given a `TreeSet<Integer>`, retrieve all elements in the range `[15, 45]` inclusive using `subSet`.

```java
SortedSet<Integer> range(TreeSet<Integer> set, int from, int to) { }
```
Example: set=`[10,20,30,40,50]`, from=15, to=45 → `[20,30,40]`

---

### 🔴 Advanced

**TS7 — Closest value**  
Given a `TreeSet<Integer>` and a target value, return the element in the set that is **closest** in absolute value to the target. Use `floor` and `ceiling`.

```java
int closestValue(TreeSet<Integer> set, int target) { }
```
Example: set=`[10,20,30,40,50]`, target=`23` → `20`

---

## 8. Map & HashMap

> `java.util.HashMap` — unordered key-value pairs, O(1) average get/put, keys are unique.

### 💚 Beginner

**MP1 — Put and get**  
Create a `HashMap<String, Integer>` representing a word count. Put `("apple", 3)`, `("banana", 5)`, `("cherry", 2)`. Retrieve and print the count for `"banana"`. Try to get `"grape"` and handle the absent key gracefully.

```java
void putAndGet() { }
```
Expected: banana = `5`, grape = `0` (or default)

---

**MP2 — Check key and value existence**  
Given a `HashMap<String, Integer>`, check if key `"mango"` exists and if value `42` exists anywhere in the map.

```java
void containsKeyAndValue(HashMap<String, Integer> map) { }
```

---

**MP3 — Update an existing value**  
Given a `HashMap<String, Integer>` word-count map, increment the count for `"apple"` by 1. Use `getOrDefault` to handle the case where the key may not exist yet.

```java
void incrementCount(HashMap<String, Integer> map, String word) { }
```

---

**MP4 — Remove a key**  
Remove the key `"banana"` from a `HashMap<String, Integer>`. Print the map before and after.

```java
void removeKey(HashMap<String, Integer> map) { }
```

---

### 🟡 Intermediate

**MP5 — Iterate entries, keys, values**  
Given a `HashMap<String, Integer>`, show three ways to iterate it:
1. Over `entrySet()` (key + value together)
2. Over `keySet()` (keys only)
3. Over `values()` (values only)

```java
void iterateMap(HashMap<String, Integer> map) { }
```

---

**MP6 — Frequency count**  
Given a `List<String>` of words, build a `HashMap<String, Integer>` that counts how many times each word appears. Use `merge()` or `getOrDefault`.

```java
HashMap<String, Integer> wordFrequency(List<String> words) { }
```
Example: `["apple","banana","apple","cherry","banana","apple"]` → `{apple=3, banana=2, cherry=1}`

---

**MP7 — Group by first letter**  
Given a `List<String>`, group the words into a `HashMap<Character, List<String>>` keyed by their first character.

```java
HashMap<Character, List<String>> groupByFirstLetter(List<String> words) { }
```
Example: `["apple","avocado","banana","cherry","blueberry"]`  
→ `{a=[apple, avocado], b=[banana, blueberry], c=[cherry]}`

---

**MP8 — Invert a map**  
Given a `HashMap<String, Integer>` where all values are unique, return a new `HashMap<Integer, String>` with keys and values swapped.

```java
HashMap<Integer, String> invertMap(HashMap<String, Integer> map) { }
```
Example: `{a=1, b=2, c=3}` → `{1=a, 2=b, 3=c}`

---

### 🔴 Advanced

**MP9 — Top N entries by value**  
Given a `HashMap<String, Integer>` word-count map and an integer `n`, return a sorted `LinkedHashMap<String, Integer>` containing the top `n` entries by value (highest count first).

```java
LinkedHashMap<String, Integer> topN(HashMap<String, Integer> map, int n) { }
```
Example: `{apple=3, banana=2, cherry=5, date=1}`, n=2 → `{cherry=5, apple=3}`

---

**MP10 — Merge two maps (sum on collision)**  
Given two `HashMap<String, Integer>` maps, produce a new map that contains all keys; if a key exists in both, sum the values. Use `merge()`.

```java
HashMap<String, Integer> mergeMaps(HashMap<String, Integer> a, HashMap<String, Integer> b) { }
```
Example: `{a=1, b=2}` + `{b=3, c=4}` → `{a=1, b=5, c=4}`

---

> 📁 Answers are in `java-data-structures-answers.md`
