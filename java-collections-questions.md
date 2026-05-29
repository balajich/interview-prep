# Java Collections & Streams — Practice Questions

> **How to use:** Work through each question on your own before opening the answers file.  
> Every question includes a method signature — implement it.  
> 💚 Beginner · 🟡 Intermediate · 🔴 Advanced

---

## Table of Contents
1. [Lists](#1-lists)
2. [Sets](#2-sets)
3. [Maps](#3-maps)
4. [Streams](#4-streams)

---

## 1. Lists

### 💚 Beginner

**L1 — Filter evens**  
Given a `List<Integer>`, return a new list containing only the even numbers, in the same order.

```java
List<Integer> filterEvens(List<Integer> numbers) { }
```
Example: `[1, 2, 3, 4, 5, 6]` → `[2, 4, 6]`

---

**L2 — Remove duplicates (preserve order)**  
Remove all duplicate values from a `List<String>` while keeping the first occurrence of each. Do **not** construct a `Set` and convert back — implement the logic yourself.

```java
List<String> removeDuplicates(List<String> list) { }
```
Example: `["apple","banana","apple","cherry","banana"]` → `["apple","banana","cherry"]`

---

**L3 — Reverse in-place**  
Reverse a `List<Integer>` in-place without calling `Collections.reverse()`.

```java
void reverseInPlace(List<Integer> list) { }
```
Example: `[1, 2, 3, 4, 5]` → `[5, 4, 3, 2, 1]`

---

**L4 — Palindrome check**  
Return `true` if the list reads the same forwards and backwards.

```java
boolean isPalindrome(List<String> list) { }
```
Example: `["a","b","c","b","a"]` → `true`,  `["a","b","c"]` → `false`

---

### 🟡 Intermediate

**L5 — Merge two sorted lists**  
Given two already-sorted `List<Integer>` lists, merge them into one sorted list. Do **not** call `Collections.sort()`.

```java
List<Integer> mergeSorted(List<Integer> a, List<Integer> b) { }
```
Example: `[1,3,5]` + `[2,4,6]` → `[1,2,3,4,5,6]`

---

**L6 — Move zeros to end**  
Move all zeros in a `List<Integer>` to the end in-place, preserving the relative order of non-zero elements.

```java
void moveZerosToEnd(List<Integer> list) { }
```
Example: `[0,1,0,3,12]` → `[1,3,12,0,0]`

---

**L7 — All pairs that sum to target**  
Find all unique pairs in a `List<Integer>` whose values sum to `target`. Return each pair as a two-element `List<Integer>` with the smaller value first. Use an O(n) approach.

```java
List<List<Integer>> findPairsWithSum(List<Integer> numbers, int target) { }
```
Example: numbers=`[1,2,3,4,5]`, target=`6` → `[[1,5],[2,4]]`

---

**L8 — Merge overlapping intervals**  
Each interval is an `int[]` of `{start, end}`. Merge all overlapping intervals and return the result sorted.

```java
List<int[]> mergeIntervals(List<int[]> intervals) { }
```
Example: `[[1,3],[2,6],[8,10],[15,18]]` → `[[1,6],[8,10],[15,18]]`

---

### 🔴 Advanced

**L9 — Top-K frequent elements**  
Given a `List<Integer>`, return the `k` most frequently occurring values, in descending frequency order.

```java
List<Integer> topKFrequent(List<Integer> nums, int k) { }
```
Example: nums=`[1,1,1,2,2,3]`, k=`2` → `[1,2]`

---

**L10 — Rotate list right by k**  
Rotate a `List<Integer>` to the right by `k` positions in **O(n) time and O(1) extra space** (no auxiliary list).

```java
void rotateRight(List<Integer> list, int k) { }
```
Example: `[1,2,3,4,5]`, k=`2` → `[4,5,1,2,3]`

> Hint: Think about what three reversals can achieve.

---

## 2. Sets

### 💚 Beginner

**S1 — Intersection of two sets**  
Return a new set containing only the elements present in **both** input sets.

```java
Set<Integer> intersection(Set<Integer> a, Set<Integer> b) { }
```
Example: `{1,2,3,4}` ∩ `{3,4,5,6}` → `{3,4}`

---

**S2 — Detect duplicates**  
Return `true` if the list contains any duplicate values. Aim for O(n) time.

```java
boolean hasDuplicates(List<String> list) { }
```

---

**S3 — Characters that appear more than once**  
Given a `String`, return a `Set<Character>` containing every character that appears at least twice.

```java
Set<Character> duplicateCharacters(String s) { }
```
Example: `"programming"` → `{'r','g','m'}`

---

**S4 — Symmetric difference**  
Return a new set with elements that are in **either** set but **not in both** (XOR of sets).

```java
Set<Integer> symmetricDifference(Set<Integer> a, Set<Integer> b) { }
```
Example: `{1,2,3}` △ `{3,4,5}` → `{1,2,4,5}`

---

### 🟡 Intermediate

**S5 — Group anagrams**  
Given a list of words, group them so that anagrams of each other appear in the same sublist.

```java
List<List<String>> groupAnagrams(List<String> words) { }
```
Example: `["eat","tea","tan","ate","nat","bat"]` → `[["eat","tea","ate"],["tan","nat"],["bat"]]`

> Hint: What single string can represent all anagrams of a word?

---

**S6 — First non-repeating character**  
Return the first character in the string that appears exactly once, or `'\0'` if all characters repeat.  
Your solution must preserve insertion order — choose your data structure accordingly.

```java
char firstNonRepeating(String s) { }
```
Example: `"leetcode"` → `'l'`,  `"aabb"` → `'\0'`

---

**S7 — Longest consecutive sequence**  
Given a `List<Integer>` with potentially unsorted, duplicate values, find the length of the longest sequence of consecutive integers. Aim for O(n) time.

```java
int longestConsecutive(List<Integer> nums) { }
```
Example: `[100,4,200,1,3,2]` → `4`  (sequence `1,2,3,4`)

> Hint: A `HashSet` lets you check `contains()` in O(1). When is the right time to start counting a sequence?

---

### 🔴 Advanced

**S8 — Intersection of a list of sets**  
Given a `List<Set<Integer>>`, return the intersection of **all** the sets.

```java
Set<Integer> intersectionOfAll(List<Set<Integer>> sets) { }
```
Example: `[{1,2,3},{2,3,4},{3,4,5}]` → `{3}`

---

**S9 — Power set**  
Given a `Set<Integer>`, return every possible subset (including the empty set and the full set) as a `Set<Set<Integer>>`.

```java
Set<Set<Integer>> powerSet(Set<Integer> input) { }
```
Example: `{1,2}` → `{{},{1},{2},{1,2}}`

> Note: A set of `n` elements has `2ⁿ` subsets. For `n=20` that is ~1 million — this is expected.

---

## 3. Maps

### 💚 Beginner

**M1 — Character frequency**  
Count how many times each character appears in a string.

```java
Map<Character, Integer> charFrequency(String s) { }
```
Example: `"hello"` → `{'h':1,'e':1,'l':2,'o':1}`

---

**M2 — Group strings by length**  
Given a list of words, group them into a map keyed by word length.

```java
Map<Integer, List<String>> groupByLength(List<String> words) { }
```
Example: `["hi","hey","hello","bye"]` → `{2:["hi"], 3:["hey","bye"], 5:["hello"]}`

---

**M3 — Key with highest value**  
Given a `Map<String, Integer>` of word counts, return the word (key) with the highest count.

```java
String mostFrequentWord(Map<String, Integer> wordCounts) { }
```

---

**M4 — Merge two maps**  
Merge two `Map<String, Integer>` maps into one. When a key exists in both, **sum** their values.

```java
Map<String, Integer> mergeMaps(Map<String, Integer> a, Map<String, Integer> b) { }
```
Example: `{"a":1,"b":2}` + `{"b":3,"c":4}` → `{"a":1,"b":5,"c":4}`

---

### 🟡 Intermediate

**M5 — Two Sum (O(n))**  
Given an integer array and a target value, return the **indices** of the two numbers that add up to the target. Each input has exactly one solution. Use a `Map` to achieve O(n) time.

```java
int[] twoSum(int[] nums, int target) { }
```
Example: nums=`[2,7,11,15]`, target=`9` → `[0,1]`

---

**M6 — Inverted index**  
Given a list of sentences, build an inverted index: a map where each key is a word and the value is the set of sentence indices (0-based) containing that word. Ignore case.

```java
Map<String, Set<Integer>> buildInvertedIndex(List<String> sentences) { }
```
Example: `["hello world","world peace"]` → `{"hello":{0},"world":{0,1},"peace":{1}}`

---

**M7 — LRU Cache**  
Implement a fixed-capacity Least-Recently-Used cache. When the cache is full and a new key is inserted, the least-recently-used entry is evicted. `get()` also counts as a use.

```java
class LRUCache<K, V> {
    LRUCache(int capacity) { }
    V get(K key) { }        // return null if absent
    void put(K key, V value) { }
}
```

> Hint: One standard Java class makes this implementable in ~10 lines. What is it, and which constructor parameter controls access order?

---

### 🔴 Advanced

**M8 — Highest-paid employee per department**  
Given a list of `Employee` records, return a map of the highest-paid employee in each department.

```java
record Employee(String name, String department, double salary) {}

Map<String, Employee> highestPaidPerDepartment(List<Employee> employees) { }
```

---

**M9 — Top N most frequent words**  
Given a paragraph of text and a number `n`, return the top `n` most frequent words in a `LinkedHashMap<String, Long>` ordered by frequency (highest first). Strip punctuation and ignore case.

```java
LinkedHashMap<String, Long> topNWords(String text, int n) { }
```

---

**M10 — Shortest path (BFS)**  
Given an unweighted, undirected graph as a `Map<String, List<String>>` (adjacency list), find the shortest path between `start` and `end`. Return the path as a `List<String>`, or an empty list if no path exists.

```java
List<String> shortestPath(Map<String, List<String>> graph, String start, String end) { }
```
Example:  
graph: `{"A":["B","C"],"B":["D"],"C":["D"],"D":[]}`  
start=`"A"`, end=`"D"` → `["A","B","D"]` or `["A","C","D"]`

---

## 4. Streams

### 💚 Beginner

**ST1 — Filter and transform**  
Using streams, return a new list containing only strings longer than 4 characters, converted to uppercase.

```java
List<String> filterAndUppercase(List<String> words) { }
```
Example: `["hi","hello","hey","world"]` → `["HELLO","WORLD"]`

---

**ST2 — Sum of squares of odd numbers**  
Using streams, compute the sum of the squares of all odd numbers in the list.

```java
int sumOfSquaresOfOdds(List<Integer> numbers) { }
```
Example: `[1,2,3,4,5]` → `1² + 3² + 5² = 35`

---

**ST3 — Count words starting with 'A'**  
Using streams, count how many strings in the list start with `'A'` or `'a'`.

```java
long countStartingWithA(List<String> words) { }
```

---

**ST4 — Flatten nested list**  
Using `flatMap`, flatten a `List<List<Integer>>` into a single `List<Integer>`.

```java
List<Integer> flatten(List<List<Integer>> nested) { }
```
Example: `[[1,2],[3,4],[5]]` → `[1,2,3,4,5]`

---

### 🟡 Intermediate

**ST5 — Group by first character**  
Using streams, group a list of words into a `Map<Character, List<String>>` keyed by each word's first character.

```java
Map<Character, List<String>> groupByFirstChar(List<String> words) { }
```
Example: `["apple","avocado","banana","blueberry"]` → `{'a':["apple","avocado"],'b':["banana","blueberry"]}`

---

**ST6 — Average salary by department**  
Using streams, compute the average salary for each department.

```java
record Employee(String name, String department, double salary) {}

Map<String, Double> avgSalaryByDepartment(List<Employee> employees) { }
```

---

**ST7 — Find the longest string**  
Using streams, find the longest string in the list. Return `Optional<String>` to handle an empty list.

```java
Optional<String> findLongest(List<String> words) { }
```

---

**ST8 — Partition by divisibility**  
Using `Collectors.partitioningBy`, split a list of integers into two groups: those divisible by 3 (`true`) and those that are not (`false`).

```java
Map<Boolean, List<Integer>> partitionByDivisibleBy3(List<Integer> numbers) { }
```

---

### 🔴 Advanced

**ST9 — Highest-value transaction per currency**  
Using streams and collectors, produce a map of the single highest-value transaction per currency.

```java
record Transaction(String currency, double amount) {}

Map<String, Optional<Transaction>> maxTransactionByCurrency(List<Transaction> transactions) { }
```

---

**ST10 — Fibonacci sequence via Stream.iterate**  
Generate the first `n` Fibonacci numbers as a `List<Long>` using `Stream.iterate`. Do not use a loop.

```java
List<Long> fibonacci(int n) { }
```
Example: n=`7` → `[0,1,1,2,3,5,8]`

> Hint: What state do you need to carry from one Fibonacci number to the next?

---

**ST11 — Custom batch Collector**  
Implement a custom `Collector` that groups stream elements into sub-lists (batches) of a fixed size. The last batch may be smaller.

```java
// Implement this factory method:
<T> Collector<T, ?, List<List<T>>> batchCollector(int batchSize) { }

// Expected usage:
List<List<Integer>> batches = Stream.of(1,2,3,4,5,6,7)
    .collect(batchCollector(3));
// → [[1,2,3],[4,5,6],[7]]
```

> Research: `Collector.of(supplier, accumulator, combiner)` — what does each function do?

---

**ST12 — Parallel stream character count + trade-offs**  
Part A: Use a **parallel stream** to count the total number of characters across all strings in the list.

```java
long totalCharCount(List<String> words) { }
```

Part B (written answer): Describe **three scenarios** where using a parallel stream would hurt performance compared to a sequential stream.

---

> 📁 Answers are in `java-collections-answers.md`
