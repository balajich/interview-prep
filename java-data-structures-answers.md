# Java Data Structures — Answers

> Every solution uses only `java.util` classes — no custom implementations.  
> Each answer shows the key operations, explains why they work, and notes the time complexity.  
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

## Quick-Reference Cheat Sheet

| Structure | Class | Add front | Add back | Remove front | Remove back | Peek front | Peek back |
|---|---|---|---|---|---|---|---|
| Stack | `ArrayDeque` | `push` | — | `pop` | — | `peek` | — |
| Queue | `ArrayDeque` | — | `offer` | `poll` | — | `peek` | — |
| Deque | `ArrayDeque` | `offerFirst` | `offerLast` | `pollFirst` | `pollLast` | `peekFirst` | `peekLast` |
| LinkedList | `LinkedList` | `addFirst` | `addLast` | `removeFirst` | `removeLast` | `peekFirst` | `peekLast` |

---

## 1. Stack

---

### 💚 SK1 — Push and pop

**Problem:** Push A, B, C and pop all. What order?

```java
void pushAndPop() {
    Deque<String> stack = new ArrayDeque<>();

    stack.push("A");   // stack: [A]
    stack.push("B");   // stack: [B, A]
    stack.push("C");   // stack: [C, B, A]

    System.out.println(stack.pop());  // C
    System.out.println(stack.pop());  // B
    System.out.println(stack.pop());  // A
}
```

**Key idea:** `push` adds to the top (front of `ArrayDeque`). `pop` removes from the top.  
Output order is **LIFO** — Last In, First Out. C was pushed last, so it pops first.

**Why not `java.util.Stack`?** It extends `Vector`, which is synchronized on every operation — unnecessary overhead. `ArrayDeque` is the modern replacement.

**Complexity:** `push` O(1) · `pop` O(1)

---

### 💚 SK2 — Peek without removing

**Problem:** Peek at the top without removing.

```java
void peekStack() {
    Deque<Integer> stack = new ArrayDeque<>();
    stack.push(10);
    stack.push(20);
    stack.push(30);

    System.out.println("Top: " + stack.peek());   // 30 — does NOT remove
    System.out.println("Size: " + stack.size());   // 3 — still 3
}
```

**Key idea:** `peek()` looks at the front/top without removing it. Returns `null` if empty (unlike `element()` which throws).

**Complexity:** `peek` O(1)

---

### 💚 SK3 — Safe drain loop

**Problem:** Pop all elements safely without exception.

```java
void drainStack(Deque<Integer> stack) {
    while (!stack.isEmpty()) {            // check before each pop
        System.out.println(stack.pop());
    }
}

// Alternative — peek-then-pop pattern:
void drainStack2(Deque<Integer> stack) {
    Integer top;
    while ((top = stack.peek()) != null) {  // peek returns null when empty
        stack.pop();
        System.out.println(top);
    }
}
```

**Key idea:** Always guard `pop()` with `isEmpty()` or a null check on `peek()`.  
`pop()` on an empty `ArrayDeque` throws `NoSuchElementException`.

---

### 🟡 SK4 — Balanced parentheses

**Problem:** Use a stack to validate bracket nesting.

```java
boolean isBalanced(String s) {
    Deque<Character> stack = new ArrayDeque<>();

    for (char c : s.toCharArray()) {
        // Push opening brackets
        if (c == '(' || c == '[' || c == '{') {
            stack.push(c);
        }
        // For closing brackets, check if the top matches
        else if (c == ')' || c == ']' || c == '}') {
            if (stack.isEmpty()) return false;   // no matching opener
            char top = stack.pop();
            if (c == ')' && top != '(') return false;
            if (c == ']' && top != '[') return false;
            if (c == '}' && top != '{') return false;
        }
    }
    return stack.isEmpty();   // all openers must have been matched
}
```

**How it works:**
- Push every `(`, `[`, `{`
- On every `)`, `]`, `}` — pop and check the match
- If the stack is empty at the end, every opener was matched

| Input | Result |
|---|---|
| `"({[]})"` | `true` |
| `"({[}])"` | `false` — `}` doesn't match `[` |
| `"((("` | `false` — stack not empty at end |

**Complexity:** O(n) time · O(n) space

---

### 🟡 SK5 — Reverse a string using a stack

**Problem:** Push each character, then pop to reverse.

```java
String reverseWithStack(String input) {
    Deque<Character> stack = new ArrayDeque<>();

    // Push every character
    for (char c : input.toCharArray()) {
        stack.push(c);
    }

    // Pop into a StringBuilder
    StringBuilder sb = new StringBuilder();
    while (!stack.isEmpty()) {
        sb.append(stack.pop());
    }
    return sb.toString();
}
```

**Key idea:** Pushing `h e l l o` and popping gives `o l l e h` — LIFO naturally reverses the sequence.

**Complexity:** O(n) time · O(n) space

---

### 🟡 SK6 — Next greater element

**Problem:** For each element, find the next greater element to its right.

```java
List<Integer> nextGreaterElement(List<Integer> nums) {
    int n = nums.size();
    int[] result = new int[n];
    Arrays.fill(result, -1);                  // default: no greater element

    Deque<Integer> stack = new ArrayDeque<>(); // stores indices

    for (int i = 0; i < n; i++) {
        // While the current element is greater than the element at the stack's top index
        while (!stack.isEmpty() && nums.get(i) > nums.get(stack.peek())) {
            int idx = stack.pop();
            result[idx] = nums.get(i);         // found the next greater for idx
        }
        stack.push(i);
    }

    // Convert int[] to List<Integer>
    List<Integer> out = new ArrayList<>();
    for (int v : result) out.add(v);
    return out;
}
```

**Trace for `[4,5,2,10,8]`:**

| i | val | Stack (indices) | Result updated |
|---|---|---|---|
| 0 | 4 | [0] | — |
| 1 | 5 | [1] | result[0]=5 |
| 2 | 2 | [1,2] | — |
| 3 | 10 | [3] | result[1]=10, result[2]=10 |
| 4 | 8 | [3,4] | — |

Output: `[5, 10, 10, -1, -1]`

**Complexity:** O(n) time · O(n) space

---

### 🔴 SK7 — Min stack

**Problem:** O(1) getMin using a parallel min-stack.

```java
class MinStack {
    Deque<Integer> stack    = new ArrayDeque<>();
    Deque<Integer> minStack = new ArrayDeque<>();  // top always holds current minimum

    void push(int val) {
        stack.push(val);
        // Push to minStack if it's empty or val is ≤ current min
        if (minStack.isEmpty() || val <= minStack.peek()) {
            minStack.push(val);
        }
    }

    void pop() {
        int val = stack.pop();
        // Remove from minStack only if it was the current minimum
        if (!minStack.isEmpty() && val == minStack.peek()) {
            minStack.pop();
        }
    }

    int peek()   { return stack.peek(); }
    int getMin() { return minStack.peek(); }
}
```

**Trace for push `5,3,7,2`:**

| Action | stack | minStack | getMin |
|---|---|---|---|
| push 5 | [5] | [5] | 5 |
| push 3 | [3,5] | [3,5] | 3 |
| push 7 | [7,3,5] | [3,5] | 3 |
| push 2 | [2,7,3,5] | [2,3,5] | 2 |
| pop (2) | [7,3,5] | [3,5] | 3 |

**Key idea:** `minStack` only grows when a new minimum arrives. It shrinks only when that exact minimum is popped from the main stack.

**Complexity:** O(1) for all operations

---

## 2. Queue

---

### 💚 Q1 — Offer and poll

**Problem:** Enqueue Alice, Bob, Charlie and dequeue all.

```java
void offerAndPoll() {
    Queue<String> queue = new ArrayDeque<>();

    queue.offer("Alice");    // [Alice]
    queue.offer("Bob");      // [Alice, Bob]
    queue.offer("Charlie");  // [Alice, Bob, Charlie]

    System.out.println(queue.poll());  // Alice
    System.out.println(queue.poll());  // Bob
    System.out.println(queue.poll());  // Charlie
}
```

**Key idea:** `offer` adds to the back (tail). `poll` removes from the front (head).  
Output order is **FIFO** — First In, First Out.

| Method | Throws on failure | Returns on failure |
|---|---|---|
| `add` | throws `IllegalStateException` | — |
| `offer` | — | returns `false` |
| `remove` | throws `NoSuchElementException` | — |
| `poll` | — | returns `null` |

Prefer `offer`/`poll` for safety.

**Complexity:** `offer` O(1) · `poll` O(1)

---

### 💚 Q2 — Peek without removing

```java
void peekQueue() {
    Queue<Integer> queue = new ArrayDeque<>();
    queue.offer(100);
    queue.offer(200);
    queue.offer(300);

    System.out.println("Front: " + queue.peek());   // 100 — not removed
    System.out.println("Size: " + queue.size());     // 3 — still 3
}
```

**Key idea:** `peek()` reads the front without removing. Returns `null` if empty.

---

### 💚 Q3 — Safe poll with null check

```java
void drainQueue(Queue<String> queue) {
    String item;
    while ((item = queue.poll()) != null) {   // poll() returns null when empty
        System.out.println(item);
    }
}
```

**Key idea:** `poll()` returns `null` on an empty queue — use this to write a concise drain loop without a separate `isEmpty()` call. Only works when the queue contains no `null` values (which is always true for `ArrayDeque`).

---

### 🟡 Q4 — Print and restore

**Problem:** Print all elements without permanently changing the queue.

```java
void printAndRestore(Queue<Integer> queue) {
    int size = queue.size();   // snapshot the original size

    for (int i = 0; i < size; i++) {
        Integer val = queue.poll();   // remove from front
        System.out.println(val);
        queue.offer(val);             // re-add to back
    }
    // After exactly `size` rotations, the queue is back to its original state
}
```

**Key idea:** Dequeue and immediately re-enqueue exactly `size` times — one full rotation puts every element back in the original order.

---

### 🟡 Q5 — Moving average

```java
double movingAverage(Queue<Integer> window, int k, int newVal) {
    window.offer(newVal);              // add new value to back

    if (window.size() > k) {
        window.poll();                 // evict oldest (front) when over capacity
    }

    int sum = 0;
    for (int v : window) sum += v;    // sum current window
    return (double) sum / window.size();
}
```

**Usage:**
```java
Queue<Integer> window = new ArrayDeque<>();
System.out.println(movingAverage(window, 3, 1)); // 1.0
System.out.println(movingAverage(window, 3, 2)); // 1.5
System.out.println(movingAverage(window, 3, 3)); // 2.0
System.out.println(movingAverage(window, 3, 4)); // 3.0  (1 evicted, window=[2,3,4])
```

**Complexity:** O(k) per call (sum loop)

---

### 🟡 Q6 — Level-order BFS

```java
record TreeNode(int val, TreeNode left, TreeNode right) { }

void levelOrder(TreeNode root) {
    if (root == null) return;

    Queue<TreeNode> queue = new ArrayDeque<>();
    queue.offer(root);

    while (!queue.isEmpty()) {
        int levelSize = queue.size();          // number of nodes on this level
        StringBuilder level = new StringBuilder();

        for (int i = 0; i < levelSize; i++) {
            TreeNode node = queue.poll();
            level.append(node.val()).append(" ");

            if (node.left()  != null) queue.offer(node.left());
            if (node.right() != null) queue.offer(node.right());
        }
        System.out.println(level.toString().trim());
    }
}
```

**Key idea:** Process exactly `queue.size()` nodes per iteration to separate levels. After each level's nodes are processed, the queue contains exactly the next level's nodes.

---

## 3. LinkedList

---

### 💚 LL1 — Add to front and back

```java
void addFrontAndBack() {
    LinkedList<String> list = new LinkedList<>();

    list.add("Middle");          // adds to back by default  → [Middle]
    list.addFirst("First");      // adds to front            → [First, Middle]
    list.addLast("Last");        // adds to back             → [First, Middle, Last]

    System.out.println(list);    // [First, Middle, Last]
}
```

**Key `LinkedList`-specific methods:**

| Method | Effect |
|---|---|
| `addFirst(e)` / `offerFirst(e)` | Add to front |
| `addLast(e)` / `offerLast(e)` | Add to back |
| `removeFirst()` / `pollFirst()` | Remove from front |
| `removeLast()` / `pollLast()` | Remove from back |
| `getFirst()` / `peekFirst()` | Peek at front |
| `getLast()` / `peekLast()` | Peek at back |

---

### 💚 LL2 — Remove from front and back

```java
void removeFrontAndBack(LinkedList<Integer> list) {
    // list is [10, 20, 30, 40, 50]
    list.removeFirst();   // removes 10  → [20, 30, 40, 50]
    list.removeLast();    // removes 50  → [20, 30, 40]
    System.out.println(list);  // [20, 30, 40]
}
```

**Complexity:** `removeFirst` O(1) · `removeLast` O(1)  
Both are O(1) because `LinkedList` maintains direct pointers to both head and tail nodes.

---

### 💚 LL3 — Get by index

```java
String getByIndex(LinkedList<String> list) {
    return list.get(2);   // valid but O(n) — traverses from head to index 2
}
```

**Why O(n)?**  
`LinkedList` stores elements in nodes linked by pointers — there is no direct address arithmetic. To reach index 2, Java starts at the head and follows `node.next` twice.  
`ArrayList` stores elements in a contiguous array — `get(2)` computes `array[2]` directly in O(1).

**Rule of thumb:** Use `ArrayList` when you need random access. Use `LinkedList` when you need frequent insertions/deletions at the front or back.

---

### 🟡 LL4 — Rotate left by one

```java
void rotateLeft(LinkedList<Integer> list) {
    if (list.size() <= 1) return;

    Integer first = list.removeFirst();   // remove front element  O(1)
    list.addLast(first);                  // append to back         O(1)
}
```

**Example:** `[1,2,3,4,5]` → remove `1` → `[2,3,4,5]` → add `1` to back → `[2,3,4,5,1]`

**Complexity:** O(1) — both operations touch only head/tail pointers.

---

### 🟡 LL5 — Remove all occurrences

```java
void removeAll(LinkedList<Integer> list, int value) {
    Iterator<Integer> it = list.iterator();
    while (it.hasNext()) {
        if (it.next() == value) {
            it.remove();   // safe removal through iterator — no ConcurrentModificationException
        }
    }
}
```

**Why use `Iterator.remove()` and not a for-each loop?**  
A for-each loop uses an iterator internally. Calling `list.remove(value)` while iterating modifies the list's `modCount`, which the iterator detects and throws `ConcurrentModificationException`.  
`Iterator.remove()` is the only safe way to remove during iteration.

**Complexity:** O(n)

---

### 🟡 LL6 — Palindrome check

```java
boolean isPalindrome(LinkedList<Integer> list) {
    if (list.size() <= 1) return true;

    ListIterator<Integer> forward  = list.listIterator(0);
    ListIterator<Integer> backward = list.listIterator(list.size());

    for (int i = 0; i < list.size() / 2; i++) {
        if (!forward.next().equals(backward.previous())) {
            return false;
        }
    }
    return true;
}
```

**Key idea:** `ListIterator` supports both `next()` (forward) and `previous()` (backward).  
Start one at the beginning and one at the end; compare and advance toward the middle.

**Complexity:** O(n) time · O(1) extra space

---

### 🔴 LL7 — Merge two sorted LinkedLists

```java
LinkedList<Integer> mergeSorted(LinkedList<Integer> a, LinkedList<Integer> b) {
    LinkedList<Integer> result = new LinkedList<>();

    Iterator<Integer> ia = a.iterator();
    Iterator<Integer> ib = b.iterator();

    Integer va = ia.hasNext() ? ia.next() : null;
    Integer vb = ib.hasNext() ? ib.next() : null;

    while (va != null && vb != null) {
        if (va <= vb) {
            result.addLast(va);
            va = ia.hasNext() ? ia.next() : null;
        } else {
            result.addLast(vb);
            vb = ib.hasNext() ? ib.next() : null;
        }
    }

    // Drain whichever list still has elements
    while (va != null) { result.addLast(va); va = ia.hasNext() ? ia.next() : null; }
    while (vb != null) { result.addLast(vb); vb = ib.hasNext() ? ib.next() : null; }

    return result;
}
```

**Complexity:** O(n + m) time · O(n + m) space

---

## 4. Deque (Double-Ended Queue)

---

### 💚 DQ1 — Add to both ends

```java
void addBothEnds() {
    Deque<String> deque = new ArrayDeque<>();

    deque.addLast("B");    // [B]
    deque.addFirst("A");   // [A, B]
    deque.addLast("C");    // [A, B, C]

    System.out.println(deque);  // [A, B, C]
}
```

**Key idea:** `ArrayDeque` resizes automatically and provides O(1) operations on both ends.

---

### 💚 DQ2 — Remove from both ends

```java
void removeBothEnds(Deque<Integer> deque) {
    // deque: [10, 20, 30, 40, 50]
    deque.pollFirst();   // removes 10  → [20, 30, 40, 50]
    deque.pollLast();    // removes 50  → [20, 30, 40]
    System.out.println(deque);   // [20, 30, 40]
}
```

Prefer `pollFirst`/`pollLast` (return `null` if empty) over `removeFirst`/`removeLast` (throw if empty).

---

### 💚 DQ3 — Peek both ends

```java
void peekBothEnds(Deque<String> deque) {
    System.out.println("First: " + deque.peekFirst());  // front — no removal
    System.out.println("Last:  " + deque.peekLast());   // back  — no removal
    System.out.println("Size:  " + deque.size());        // unchanged
}
```

---

### 🟡 DQ4 — Deque as stack and queue

```java
void stackAndQueueDemo() {
    // --- Stack (LIFO): use push/pop which operate on the FRONT ---
    Deque<Integer> stack = new ArrayDeque<>();
    stack.push(1);  stack.push(2);  stack.push(3);  // [3,2,1]
    System.out.print("Stack: ");
    while (!stack.isEmpty()) System.out.print(stack.pop() + " ");
    // prints: 3 2 1

    System.out.println();

    // --- Queue (FIFO): use offerLast/pollFirst ---
    Deque<Integer> queue = new ArrayDeque<>();
    queue.offerLast(1);  queue.offerLast(2);  queue.offerLast(3);  // [1,2,3]
    System.out.print("Queue: ");
    while (!queue.isEmpty()) System.out.print(queue.pollFirst() + " ");
    // prints: 1 2 3
}
```

**Summary:**

| Behaviour | Add | Remove |
|---|---|---|
| Stack (LIFO) | `push` (addFirst) | `pop` (removeFirst) |
| Queue (FIFO) | `offerLast` | `pollFirst` |

---

### 🟡 DQ5 — Sliding window maximum

```java
List<Integer> slidingWindowMax(List<Integer> nums, int k) {
    List<Integer> result = new ArrayList<>();
    Deque<Integer> deque = new ArrayDeque<>();  // stores indices, not values

    for (int i = 0; i < nums.size(); i++) {
        // Remove indices that are outside the current window
        while (!deque.isEmpty() && deque.peekFirst() < i - k + 1) {
            deque.pollFirst();
        }
        // Remove indices whose values are less than current (they can never be the max)
        while (!deque.isEmpty() && nums.get(deque.peekLast()) < nums.get(i)) {
            deque.pollLast();
        }
        deque.offerLast(i);

        // Start recording once first full window is formed
        if (i >= k - 1) {
            result.add(nums.get(deque.peekFirst()));  // front holds index of window maximum
        }
    }
    return result;
}
```

**Key idea:** The deque is a **monotonic decreasing deque** — the front always holds the index of the largest element in the current window.

**Complexity:** O(n) time — each element is added and removed at most once.

---

### 🟡 DQ6 — Palindrome checker

```java
boolean isPalindromeDeque(String s) {
    Deque<Character> deque = new ArrayDeque<>();

    for (char c : s.toCharArray()) {
        deque.offerLast(c);
    }

    while (deque.size() > 1) {
        if (!deque.pollFirst().equals(deque.pollLast())) {
            return false;   // front and back characters differ
        }
    }
    return true;
}
```

**Example trace for `"racecar"`:**
```
Deque: [r, a, c, e, c, a, r]
Remove r == r ✓  → [a, c, e, c, a]
Remove a == a ✓  → [c, e, c]
Remove c == c ✓  → [e]
Size = 1, stop → true
```

**Complexity:** O(n) time · O(n) space

---

## 5. PriorityQueue

---

### 💚 PQ1 — Natural ordering (min-heap)

```java
void naturalOrder() {
    PriorityQueue<Integer> pq = new PriorityQueue<>();  // default: min-heap

    pq.offer(5);
    pq.offer(1);
    pq.offer(3);
    pq.offer(2);
    pq.offer(4);

    while (!pq.isEmpty()) {
        System.out.print(pq.poll() + " ");  // 1 2 3 4 5
    }
}
```

**Key idea:** `PriorityQueue` is a min-heap — `poll()` always returns the **smallest** element.  
Elements are **not** stored in sorted order internally; only the root (minimum) is guaranteed.

**Complexity:** `offer` O(log n) · `poll` O(log n) · `peek` O(1)

---

### 💚 PQ2 — Max heap

```java
void maxHeap() {
    // Pass Comparator.reverseOrder() to flip the natural ordering
    PriorityQueue<Integer> pq = new PriorityQueue<>(Comparator.reverseOrder());

    pq.offer(5); pq.offer(1); pq.offer(3); pq.offer(2); pq.offer(4);

    while (!pq.isEmpty()) {
        System.out.print(pq.poll() + " ");  // 5 4 3 2 1
    }
}
```

---

### 💚 PQ3 — Peek minimum

```java
void peekMin() {
    PriorityQueue<Integer> pq = new PriorityQueue<>();
    pq.offer(8); pq.offer(3); pq.offer(6); pq.offer(1); pq.offer(9);

    System.out.println("Min: " + pq.peek());   // 1 — no removal
    System.out.println("Size: " + pq.size());   // 5 — unchanged
}
```

---

### 🟡 PQ4 — Custom object ordering

```java
void orderByLength() {
    // Order strings by length; tie-break alphabetically
    PriorityQueue<String> pq = new PriorityQueue<>(
        Comparator.comparingInt(String::length).thenComparing(Comparator.naturalOrder())
    );

    pq.offer("banana");
    pq.offer("fig");
    pq.offer("apple");
    pq.offer("kiwi");

    while (!pq.isEmpty()) {
        System.out.print(pq.poll() + " ");  // fig kiwi apple banana
    }
}
```

**Key idea:** Pass a `Comparator` to the constructor. `Comparator.comparingInt` extracts the sort key; `.thenComparing` breaks ties.

---

### 🟡 PQ5 — K smallest elements

```java
List<Integer> kSmallest(List<Integer> nums, int k) {
    PriorityQueue<Integer> pq = new PriorityQueue<>();  // min-heap

    for (int n : nums) pq.offer(n);

    List<Integer> result = new ArrayList<>();
    for (int i = 0; i < k; i++) {
        result.add(pq.poll());   // poll gives the smallest each time
    }
    return result;
}
```

**Example:** `[7,10,4,3,1,8]`, k=3 → polls `1`, `3`, `4` → `[1, 3, 4]`

**Complexity:** O(n) to build heap + O(k log n) to poll k times = O(n + k log n)

---

### 🟡 PQ6 — Merge K sorted lists

```java
List<Integer> mergeKSorted(List<List<Integer>> lists) {
    // Min-heap of [value, listIndex, elementIndex] stored as int[]
    PriorityQueue<int[]> pq = new PriorityQueue<>(Comparator.comparingInt(a -> a[0]));

    // Seed with the first element of each list
    for (int i = 0; i < lists.size(); i++) {
        if (!lists.get(i).isEmpty()) {
            pq.offer(new int[]{ lists.get(i).get(0), i, 0 });
        }
    }

    List<Integer> result = new ArrayList<>();
    while (!pq.isEmpty()) {
        int[] curr = pq.poll();
        int val = curr[0], li = curr[1], ei = curr[2];
        result.add(val);

        // Advance to the next element in the same list
        if (ei + 1 < lists.get(li).size()) {
            pq.offer(new int[]{ lists.get(li).get(ei + 1), li, ei + 1 });
        }
    }
    return result;
}
```

**Complexity:** O(N log k) where N = total elements, k = number of lists

---

### 🔴 PQ7 — K most frequent elements

```java
List<Integer> kMostFrequent(List<Integer> nums, int k) {
    // Step 1: build frequency map
    Map<Integer, Integer> freq = new HashMap<>();
    for (int n : nums) freq.merge(n, 1, Integer::sum);

    // Step 2: min-heap of size k, keyed by frequency
    // Heap stores [number, frequency]; ordered by frequency ascending (min-heap of freq)
    PriorityQueue<int[]> pq = new PriorityQueue<>(Comparator.comparingInt(a -> a[1]));

    for (Map.Entry<Integer, Integer> e : freq.entrySet()) {
        pq.offer(new int[]{ e.getKey(), e.getValue() });
        if (pq.size() > k) pq.poll();  // evict least-frequent when over k
    }

    List<Integer> result = new ArrayList<>();
    while (!pq.isEmpty()) result.add(pq.poll()[0]);
    return result;
}
```

**Key idea:** Keep a min-heap of size `k`. When a new element arrives and the heap exceeds `k`, the element with the lowest frequency is evicted — leaving only the `k` most frequent.

**Complexity:** O(n log k)

---

## 6. Set & HashSet

---

### 💚 SE1 — Add and contains

```java
void addAndContains() {
    Set<String> set = new HashSet<>();

    set.add("cat");
    set.add("dog");
    set.add("bird");
    set.add("cat");    // duplicate — silently ignored; add() returns false

    System.out.println("Size: " + set.size());            // 3
    System.out.println("dog: "  + set.contains("dog"));   // true
    System.out.println("fish: " + set.contains("fish"));  // false
}
```

**Key idea:** `HashSet.add()` returns `false` if the element already exists — the set remains unchanged. `contains()` is O(1) on average.

---

### 💚 SE2 — Remove an element

```java
void removeElement() {
    Set<Integer> set = new HashSet<>(Arrays.asList(1, 2, 3, 4, 5));
    set.remove(3);
    System.out.println(set);   // [1, 2, 4, 5] — order not guaranteed
}
```

**Key idea:** `remove()` returns `true` if the element was present, `false` otherwise — useful for conditional logic.

---

### 💚 SE3 — Eliminate duplicates from a list

```java
List<Integer> removeDuplicates(List<Integer> list) {
    Set<Integer> seen = new HashSet<>();
    List<Integer> result = new ArrayList<>();

    for (int n : list) {
        if (seen.add(n)) {      // add() returns true only when it's a new element
            result.add(n);      // preserve insertion order of first occurrence
        }
    }
    return result;
}

// Shorter alternative (doesn't preserve insertion order):
List<Integer> removeDuplicatesShort(List<Integer> list) {
    return new ArrayList<>(new HashSet<>(list));
}

// To preserve insertion order, use LinkedHashSet:
List<Integer> removeDuplicatesOrdered(List<Integer> list) {
    return new ArrayList<>(new LinkedHashSet<>(list));
}
```

---

### 🟡 SE4 — Union, intersection, difference

```java
Set<Integer> union(Set<Integer> a, Set<Integer> b) {
    Set<Integer> result = new HashSet<>(a);   // copy a
    result.addAll(b);                          // add all of b
    return result;
}

Set<Integer> intersection(Set<Integer> a, Set<Integer> b) {
    Set<Integer> result = new HashSet<>(a);
    result.retainAll(b);   // keep only elements also in b
    return result;
}

Set<Integer> difference(Set<Integer> a, Set<Integer> b) {
    Set<Integer> result = new HashSet<>(a);
    result.removeAll(b);   // remove elements that are in b
    return result;
}
```

**Always copy first** — `addAll`, `retainAll`, `removeAll` are destructive (modify the target set).

| Operation | Example a={1,2,3}, b={2,3,4} | Result |
|---|---|---|
| Union | a ∪ b | {1,2,3,4} |
| Intersection | a ∩ b | {2,3} |
| Difference | a − b | {1} |

---

### 🟡 SE5 — First repeated character

```java
char firstRepeated(String s) {
    Set<Character> seen = new HashSet<>();

    for (char c : s.toCharArray()) {
        if (!seen.add(c)) {   // add() returns false → already in set → duplicate found
            return c;
        }
    }
    return '\0';   // no duplicate found
}
```

**Key idea:** `add()` returns `false` when the element already exists. This gives us a one-line duplicate check without `contains()`.

**Complexity:** O(n) time · O(k) space

---

### 🟡 SE6 — Subset check

```java
boolean isSubset(Set<Integer> a, Set<Integer> b) {
    return b.containsAll(a);   // true if every element of a exists in b
}
```

`Set.containsAll()` is the built-in subset test. It returns `true` if and only if every element of `a` is present in `b`.

**Complexity:** O(|a|) on average

---

## 7. TreeSet

---

### 💚 TS1 — Natural sorted order

```java
void naturalOrder() {
    TreeSet<Integer> set = new TreeSet<>();
    set.add(5); set.add(3); set.add(1); set.add(4); set.add(2);

    System.out.println(set);   // [1, 2, 3, 4, 5]
    // TreeSet maintains ascending natural order automatically
}
```

**Key idea:** `TreeSet` uses a Red-Black tree internally. Every `add` keeps the set sorted in O(log n).  
Unlike `HashSet`, iteration always produces a sorted sequence.

---

### 💚 TS2 — First and last

```java
void firstAndLast(TreeSet<Integer> set) {
    // set: [10, 20, 30, 40, 50]
    System.out.println("First (min): " + set.first());  // 10
    System.out.println("Last  (max): " + set.last());   // 50
}
```

`first()` = minimum, `last()` = maximum. Both are O(log n).

---

### 💚 TS3 — Headset and tailset

```java
void headAndTail(TreeSet<Integer> set) {
    // set: [1,2,3,4,5,6,7,8,9,10]
    System.out.println(set.headSet(5));      // [1,2,3,4]  — strictly less than 5
    System.out.println(set.tailSet(7));      // [7,8,9,10] — >= 7 (inclusive)

    // Inclusive headSet (use headSet(5, true)):
    System.out.println(set.headSet(5, true)); // [1,2,3,4,5]
}
```

**headSet(toElement)** — elements strictly less than `toElement`  
**tailSet(fromElement)** — elements greater than or equal to `fromElement`

---

### 🟡 TS4 — Floor and ceiling

```java
void floorAndCeiling(TreeSet<Integer> set) {
    // set: [10, 20, 30, 40, 50]
    System.out.println("Floor of 25:   " + set.floor(25));    // 20  (greatest <= 25)
    System.out.println("Ceiling of 25: " + set.ceiling(25));  // 30  (smallest >= 25)

    System.out.println("Floor of 30:   " + set.floor(30));    // 30  (exact match)
    System.out.println("Floor of 5:    " + set.floor(5));     // null (no element <= 5)
}
```

Both return `null` if no such element exists — always null-check in production code.

---

### 🟡 TS5 — Custom sort order

```java
void sortByLength() {
    TreeSet<String> set = new TreeSet<>(
        Comparator.comparingInt(String::length)    // primary: length
                  .thenComparing(Comparator.naturalOrder())  // tie-break: alphabetical
    );

    set.add("banana"); set.add("fig"); set.add("apple");
    set.add("kiwi");   set.add("mango");

    System.out.println(set);  // [fig, kiwi, apple, mango, banana]
}
```

**Key idea:** The `Comparator` must be total (handle all pairs) and consistent with `equals`. Using `thenComparing(naturalOrder())` as a tie-breaker prevents two strings of equal length (like "apple" and "mango") from being treated as duplicates.

---

### 🟡 TS6 — Range query

```java
SortedSet<Integer> range(TreeSet<Integer> set, int from, int to) {
    return set.subSet(from, true, to, true);   // inclusive on both ends
    // set.subSet(from, to) — default is inclusive from, exclusive to
}
```

**Example:** set=`[10,20,30,40,50]`, from=15, to=45 → `[20,30,40]`

`subSet`, `headSet`, `tailSet` all return **views** — they reflect changes to the original set and changes through the view are reflected back.

---

### 🔴 TS7 — Closest value

```java
int closestValue(TreeSet<Integer> set, int target) {
    Integer floor   = set.floor(target);    // greatest element <= target
    Integer ceiling = set.ceiling(target);  // smallest element >= target

    if (floor == null)   return ceiling;
    if (ceiling == null) return floor;

    // Return whichever is closer; prefer ceiling on a tie
    return (target - floor <= ceiling - target) ? floor : ceiling;
}
```

**Example:** set=`[10,20,30,40,50]`, target=23  
→ floor=20, ceiling=30, distance to 20 = 3, distance to 30 = 7 → return **20**

**Complexity:** O(log n) for both `floor` and `ceiling`

---

## 8. Map & HashMap

---

### 💚 MP1 — Put and get

```java
void putAndGet() {
    HashMap<String, Integer> map = new HashMap<>();

    map.put("apple",  3);
    map.put("banana", 5);
    map.put("cherry", 2);

    System.out.println("banana: " + map.get("banana"));              // 5
    System.out.println("grape:  " + map.getOrDefault("grape", 0));  // 0 (not present)
}
```

**`get` vs `getOrDefault`:**
- `get("grape")` returns `null` if absent — unboxing to `int` throws `NullPointerException`
- `getOrDefault("grape", 0)` returns `0` safely

**Complexity:** `put` O(1) avg · `get` O(1) avg

---

### 💚 MP2 — Check key and value existence

```java
void containsKeyAndValue(HashMap<String, Integer> map) {
    System.out.println(map.containsKey("mango"));   // O(1) avg
    System.out.println(map.containsValue(42));       // O(n) — scans all values
}
```

**Important:** `containsValue` is O(n) — it has to scan every value in the map. Use a second `HashSet<V>` if you need frequent value lookups.

---

### 💚 MP3 — Increment count safely

```java
void incrementCount(HashMap<String, Integer> map, String word) {
    // Option 1 — getOrDefault
    map.put(word, map.getOrDefault(word, 0) + 1);

    // Option 2 — merge (cleaner)
    map.merge(word, 1, Integer::sum);
    // If key absent: inserts (word, 1)
    // If key present: applies Integer::sum(existing, 1) = existing + 1
}
```

**`merge` explained:** `map.merge(key, value, remappingFn)`:
- Key absent → `put(key, value)`
- Key present → `put(key, remappingFn(oldValue, value))`

---

### 💚 MP4 — Remove a key

```java
void removeKey(HashMap<String, Integer> map) {
    System.out.println("Before: " + map);
    map.remove("banana");
    System.out.println("After:  " + map);

    // Conditional remove — only removes if key maps to a specific value
    map.remove("apple", 3);   // removes only if apple==3; returns true/false
}
```

---

### 🟡 MP5 — Iterate entries, keys, values

```java
void iterateMap(HashMap<String, Integer> map) {
    // 1. entrySet() — both key and value
    System.out.println("--- entrySet ---");
    for (Map.Entry<String, Integer> entry : map.entrySet()) {
        System.out.println(entry.getKey() + " = " + entry.getValue());
    }

    // 2. keySet() — keys only
    System.out.println("--- keySet ---");
    for (String key : map.keySet()) {
        System.out.println(key);
    }

    // 3. values() — values only
    System.out.println("--- values ---");
    for (int val : map.values()) {
        System.out.println(val);
    }

    // 4. forEach (most concise)
    map.forEach((key, val) -> System.out.println(key + " → " + val));
}
```

**Use `entrySet()` when you need both key and value** — it avoids a second `get()` call per iteration that `keySet()` would require.

---

### 🟡 MP6 — Frequency count

```java
HashMap<String, Integer> wordFrequency(List<String> words) {
    HashMap<String, Integer> freq = new HashMap<>();

    for (String word : words) {
        freq.merge(word, 1, Integer::sum);
    }
    return freq;
}
```

**Example:** `["apple","banana","apple","cherry","banana","apple"]`  
→ `{apple=3, banana=2, cherry=1}`

**Complexity:** O(n) time · O(k) space (k = distinct words)

---

### 🟡 MP7 — Group by first letter

```java
HashMap<Character, List<String>> groupByFirstLetter(List<String> words) {
    HashMap<Character, List<String>> groups = new HashMap<>();

    for (String word : words) {
        if (word.isEmpty()) continue;
        char key = word.charAt(0);
        groups.computeIfAbsent(key, k -> new ArrayList<>()).add(word);
        // computeIfAbsent: if key absent, creates new ArrayList, stores it, returns it
        // if key present, just returns the existing list
    }
    return groups;
}
```

**Example output:**  
`{a=[apple, avocado], b=[banana, blueberry], c=[cherry]}`

---

### 🟡 MP8 — Invert a map

```java
HashMap<Integer, String> invertMap(HashMap<String, Integer> map) {
    HashMap<Integer, String> inverted = new HashMap<>();

    for (Map.Entry<String, Integer> entry : map.entrySet()) {
        inverted.put(entry.getValue(), entry.getKey());
    }
    return inverted;
}

// Stream version:
HashMap<Integer, String> invertMapStream(HashMap<String, Integer> map) {
    return map.entrySet().stream()
        .collect(Collectors.toMap(
            Map.Entry::getValue,
            Map.Entry::getKey,
            (a, b) -> a,          // keep first on collision (shouldn't happen if values are unique)
            HashMap::new
        ));
}
```

---

### 🔴 MP9 — Top N entries by value

```java
LinkedHashMap<String, Integer> topN(HashMap<String, Integer> map, int n) {
    return map.entrySet().stream()
        .sorted(Map.Entry.<String, Integer>comparingByValue().reversed())  // sort high→low
        .limit(n)                                                           // take top n
        .collect(Collectors.toMap(
            Map.Entry::getKey,
            Map.Entry::getValue,
            (a, b) -> a,
            LinkedHashMap::new   // preserve sorted insertion order
        ));
}
```

**Why `LinkedHashMap` as output?** Regular `HashMap` does not preserve insertion order — iterating it would not guarantee highest-to-lowest. `LinkedHashMap` keeps entries in insertion order, so the result stays sorted.

**Example:** `{apple=3, banana=2, cherry=5, date=1}`, n=2 → `{cherry=5, apple=3}`

**Complexity:** O(n log n) for sort

---

### 🔴 MP10 — Merge two maps (sum on collision)

```java
HashMap<String, Integer> mergeMaps(HashMap<String, Integer> a, HashMap<String, Integer> b) {
    HashMap<String, Integer> result = new HashMap<>(a);   // copy a

    b.forEach((key, value) -> result.merge(key, value, Integer::sum));
    // For each entry in b:
    //   If key not in result → put(key, value)
    //   If key in result     → put(key, oldValue + value)

    return result;
}
```

**Example:** `{a=1, b=2}` + `{b=3, c=4}` → `{a=1, b=5, c=4}`

**Complexity:** O(n + m) time · O(n + m) space

---

> 📁 Questions are in `java-data-structures-questions.md`
