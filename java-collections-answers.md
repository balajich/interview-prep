# Java Collections & Streams — Answers

> Each answer restates the problem briefly, shows a complete solution, explains the key idea, and notes complexity.  
> 💚 Beginner · 🟡 Intermediate · 🔴 Advanced

---

## 1. Lists

---

### 💚 L1 — Filter evens

**Problem:** Return only even numbers from the list.

```java
List<Integer> filterEvens(List<Integer> numbers) {
    List<Integer> result = new ArrayList<>();
    for (int n : numbers) {
        if (n % 2 == 0) result.add(n);
    }
    return result;
}
```

**Key idea:** Iterate once and conditionally copy. The loop version makes the mechanics explicit.  
You'll do this with one line in Streams (`ST1`):
```java
numbers.stream().filter(n -> n % 2 == 0).collect(Collectors.toList());
```

**Complexity:** O(n) time · O(n) space (output list)

---

### 💚 L2 — Remove duplicates (preserve order)

**Problem:** Keep only the first occurrence of each value.

```java
List<String> removeDuplicates(List<String> list) {
    List<String> result = new ArrayList<>();
    for (String s : list) {
        if (!result.contains(s)) {   // O(n) scan each time
            result.add(s);
        }
    }
    return result;
}
```

**Why not `LinkedHashSet`?** The question asks you to implement it yourself so you understand the cost.  
In production, prefer:
```java
// O(n) total — LinkedHashSet preserves insertion order
return new ArrayList<>(new LinkedHashSet<>(list));
```

**Complexity:** Naive loop — O(n²) · `LinkedHashSet` shortcut — O(n)

---

### 💚 L3 — Reverse in-place

**Problem:** Swap elements from both ends toward the middle.

```java
void reverseInPlace(List<Integer> list) {
    int left = 0, right = list.size() - 1;
    while (left < right) {
        int temp = list.get(left);
        list.set(left,  list.get(right));
        list.set(right, temp);
        left++;
        right--;
    }
}
```

**Key idea:** Two-pointer technique — move both pointers inward until they meet.  
For an `ArrayList`, `get`/`set` are O(1), so the whole operation is O(n).

**Complexity:** O(n) time · O(1) space

---

### 💚 L4 — Palindrome check

**Problem:** Compare element `i` with element `n-1-i` for the first half.

```java
boolean isPalindrome(List<String> list) {
    int n = list.size();
    for (int i = 0; i < n / 2; i++) {
        if (!list.get(i).equals(list.get(n - 1 - i))) return false;
    }
    return true;
}
```

**Key idea:** You only need to check the first half; the middle element (odd-length list) is always "equal to itself."

**Complexity:** O(n) time · O(1) space

---

### 🟡 L5 — Merge two sorted lists

**Problem:** Two-pointer merge — always pick the smaller front element.

```java
List<Integer> mergeSorted(List<Integer> a, List<Integer> b) {
    List<Integer> result = new ArrayList<>(a.size() + b.size());
    int i = 0, j = 0;
    while (i < a.size() && j < b.size()) {
        if (a.get(i) <= b.get(j)) result.add(a.get(i++));
        else                       result.add(b.get(j++));
    }
    // Drain whichever list still has elements
    while (i < a.size()) result.add(a.get(i++));
    while (j < b.size()) result.add(b.get(j++));
    return result;
}
```

**Key idea:** Because both lists are already sorted, a single left-to-right pass suffices.  
This is the core of Merge Sort's merge step.

**Complexity:** O(n + m) time · O(n + m) space

---

### 🟡 L6 — Move zeros to end

**Problem:** Overwrite non-zero positions from the front, then fill remaining positions with zeros.

```java
void moveZerosToEnd(List<Integer> list) {
    int insertPos = 0;
    // Copy all non-zero values to the front
    for (int i = 0; i < list.size(); i++) {
        if (list.get(i) != 0) {
            list.set(insertPos++, list.get(i));
        }
    }
    // Fill the remaining slots with zeros
    while (insertPos < list.size()) {
        list.set(insertPos++, 0);
    }
}
```

**Key idea:** `insertPos` acts as a write pointer that only advances when a non-zero is found.  
The relative order of non-zeros is preserved because we process left-to-right.

**Complexity:** O(n) time · O(1) space

---

### 🟡 L7 — All pairs that sum to target

**Problem:** For each element, check if its complement (`target - element`) has been seen before.

```java
List<List<Integer>> findPairsWithSum(List<Integer> numbers, int target) {
    List<List<Integer>> result = new ArrayList<>();
    Set<Integer> seen      = new HashSet<>();
    Set<Integer> usedSmall = new HashSet<>();  // prevents reporting the same pair twice

    for (int n : numbers) {
        int complement = target - n;
        if (seen.contains(complement) && !usedSmall.contains(Math.min(n, complement))) {
            result.add(List.of(Math.min(n, complement), Math.max(n, complement)));
            usedSmall.add(Math.min(n, complement));
        }
        seen.add(n);
    }
    return result;
}
```

**Key idea:** The `seen` set converts "have I encountered the complement?" from O(n) to O(1).  
`usedSmall` prevents emitting `[1,5]` twice if `1` and `5` each appear multiple times.

**Complexity:** O(n) time · O(n) space

---

### 🟡 L8 — Merge overlapping intervals

**Problem:** Sort by start time, then merge each interval into the last merged interval if it overlaps.

```java
List<int[]> mergeIntervals(List<int[]> intervals) {
    intervals.sort(Comparator.comparingInt(iv -> iv[0]));   // sort by start
    List<int[]> merged = new ArrayList<>();

    for (int[] iv : intervals) {
        if (merged.isEmpty() || merged.get(merged.size() - 1)[1] < iv[0]) {
            // No overlap — start a new interval
            merged.add(new int[]{iv[0], iv[1]});
        } else {
            // Overlap — extend the last interval's end if needed
            merged.get(merged.size() - 1)[1] =
                Math.max(merged.get(merged.size() - 1)[1], iv[1]);
        }
    }
    return merged;
}
```

**Key idea:** After sorting, an interval can only overlap with the *immediately preceding* merged interval.  
Extending the end with `Math.max` handles the case where a smaller interval is fully contained inside a larger one.

**Complexity:** O(n log n) due to sort · O(n) space

---

### 🔴 L9 — Top-K frequent elements

**Problem:** Count frequencies, then extract the top `k` by frequency.

```java
List<Integer> topKFrequent(List<Integer> nums, int k) {
    // Step 1: count frequencies
    Map<Integer, Integer> freq = new HashMap<>();
    for (int n : nums) freq.merge(n, 1, Integer::sum);

    // Step 2: sort by frequency descending, take top k
    return freq.entrySet().stream()
        .sorted(Map.Entry.<Integer, Integer>comparingByValue().reversed())
        .limit(k)
        .map(Map.Entry::getKey)
        .collect(Collectors.toList());
}
```

**Alternative — O(n) bucket sort approach:**
```java
List<Integer> topKFrequent(List<Integer> nums, int k) {
    Map<Integer, Integer> freq = new HashMap<>();
    for (int n : nums) freq.merge(n, 1, Integer::sum);

    // Buckets: index = frequency, value = list of numbers with that frequency
    @SuppressWarnings("unchecked")
    List<Integer>[] buckets = new List[nums.size() + 1];
    freq.forEach((num, f) -> {
        if (buckets[f] == null) buckets[f] = new ArrayList<>();
        buckets[f].add(num);
    });

    List<Integer> result = new ArrayList<>();
    for (int f = buckets.length - 1; f >= 0 && result.size() < k; f--) {
        if (buckets[f] != null) result.addAll(buckets[f]);
    }
    return result.subList(0, k);
}
```

**Complexity:** Sort approach — O(n log n) · Bucket approach — O(n) time, O(n) space

---

### 🔴 L10 — Rotate list right by k

**Problem:** Use the three-reversal algorithm — no extra list needed.

```java
void rotateRight(List<Integer> list, int k) {
    int n = list.size();
    if (n == 0) return;
    k = k % n;           // rotating by n is a no-op
    if (k == 0) return;

    reverse(list, 0, n - 1);     // reverse the whole list
    reverse(list, 0, k - 1);     // reverse the first k elements
    reverse(list, k, n - 1);     // reverse the remaining elements
}

private void reverse(List<Integer> list, int lo, int hi) {
    while (lo < hi) {
        int tmp = list.get(lo);
        list.set(lo++, list.get(hi));
        list.set(hi--, tmp);
    }
}
```

**Why does this work?**  
Rotating `[1,2,3,4,5]` right by 2 should give `[4,5,1,2,3]`.

```
Original:         1 2 3 4 5
After full rev:   5 4 3 2 1
After rev [0..1]: 4 5 3 2 1
After rev [2..4]: 4 5 1 2 3  ✓
```

**Complexity:** O(n) time · O(1) space

---

## 2. Sets

---

### 💚 S1 — Intersection of two sets

**Problem:** Keep only elements found in both sets.

```java
Set<Integer> intersection(Set<Integer> a, Set<Integer> b) {
    Set<Integer> result = new HashSet<>(a);   // copy so we don't mutate a
    result.retainAll(b);
    return result;
}
```

**Key idea:** `retainAll` removes every element not present in `b` — it's the built-in set intersection.  
Copying first is important: mutating the input set would surprise callers.

**Complexity:** O(min(|a|, |b|)) average · O(n) space

---

### 💚 S2 — Detect duplicates

**Problem:** `HashSet.add()` returns `false` when the element was already present.

```java
boolean hasDuplicates(List<String> list) {
    Set<String> seen = new HashSet<>();
    for (String s : list) {
        if (!seen.add(s)) return true;   // add() returns false = already existed
    }
    return false;
}
```

**Key idea:** Short-circuit on the first duplicate found — no need to scan the whole list.

**Complexity:** O(n) time · O(n) space

---

### 💚 S3 — Characters that appear more than once

**Problem:** Track which characters have been seen, and add them to a duplicates set when seen again.

```java
Set<Character> duplicateCharacters(String s) {
    Set<Character> seen       = new HashSet<>();
    Set<Character> duplicates = new HashSet<>();
    for (char c : s.toCharArray()) {
        if (!seen.add(c)) {    // already in 'seen' → it's a duplicate
            duplicates.add(c);
        }
    }
    return duplicates;
}
```

**Complexity:** O(n) time · O(k) space, where k = number of distinct characters (bounded by alphabet size)

---

### 💚 S4 — Symmetric difference

**Problem:** Elements in A or B but not in both = (A ∪ B) − (A ∩ B).

```java
Set<Integer> symmetricDifference(Set<Integer> a, Set<Integer> b) {
    Set<Integer> union        = new HashSet<>(a);
    union.addAll(b);

    Set<Integer> intersection = new HashSet<>(a);
    intersection.retainAll(b);

    union.removeAll(intersection);
    return union;
}
```

**Alternative — XOR approach (mutate copies):**
```java
Set<Integer> symmetricDifference(Set<Integer> a, Set<Integer> b) {
    Set<Integer> onlyInA = new HashSet<>(a); onlyInA.removeAll(b);
    Set<Integer> onlyInB = new HashSet<>(b); onlyInB.removeAll(a);
    onlyInA.addAll(onlyInB);
    return onlyInA;
}
```

**Complexity:** O(n) time · O(n) space

---

### 🟡 S5 — Group anagrams

**Problem:** Sort each word's characters to get a canonical key — anagrams share the same key.

```java
List<List<String>> groupAnagrams(List<String> words) {
    Map<String, List<String>> groups = new HashMap<>();
    for (String word : words) {
        char[] chars = word.toCharArray();
        Arrays.sort(chars);                    // "eat" → "aet", "tea" → "aet"
        String key = new String(chars);
        groups.computeIfAbsent(key, k -> new ArrayList<>()).add(word);
    }
    return new ArrayList<>(groups.values());
}
```

**Key idea:** All anagrams of a word have identical sorted character arrays.  
`computeIfAbsent` creates the list on first encounter and returns it — avoids a null-check.

**Complexity:** O(n · L log L) where L = average word length · O(n) space

---

### 🟡 S6 — First non-repeating character

**Problem:** Preserve insertion order so you find the *first* non-repeating character efficiently.

```java
char firstNonRepeating(String s) {
    // LinkedHashMap preserves insertion order — critical for "first"
    Map<Character, Integer> freq = new LinkedHashMap<>();
    for (char c : s.toCharArray()) {
        freq.merge(c, 1, Integer::sum);
    }
    for (Map.Entry<Character, Integer> e : freq.entrySet()) {
        if (e.getValue() == 1) return e.getKey();
    }
    return '\0';
}
```

**Why `LinkedHashMap` and not `HashMap`?**  
`HashMap` gives no ordering guarantee — iterating it after building the frequency map could visit 'z' before 'a', even if 'a' appeared first.  
`LinkedHashMap` iterates in insertion order, so the first entry with count 1 is guaranteed to be the earliest in the original string.

**Complexity:** O(n) time · O(k) space

---

### 🟡 S7 — Longest consecutive sequence

**Problem:** Use a `HashSet` for O(1) lookups, and only start counting from sequence beginnings.

```java
int longestConsecutive(List<Integer> nums) {
    Set<Integer> numSet = new HashSet<>(nums);
    int longest = 0;

    for (int num : numSet) {
        // Only start a count when 'num' is the beginning of a sequence
        if (!numSet.contains(num - 1)) {
            int current = num;
            int streak  = 1;
            while (numSet.contains(++current)) streak++;
            longest = Math.max(longest, streak);
        }
    }
    return longest;
}
```

**Why check `!numSet.contains(num - 1)`?**  
If `num - 1` exists, then `num` is in the middle of a sequence — starting there would double-count.  
By only counting from sequence starts, every element is visited at most twice: once in the outer loop, once in the inner `while`. Total: O(n).

**Complexity:** O(n) time · O(n) space

---

### 🔴 S8 — Intersection of all sets

**Problem:** Start with a copy of the first set and progressively retain only common elements.

```java
Set<Integer> intersectionOfAll(List<Set<Integer>> sets) {
    if (sets == null || sets.isEmpty()) return new HashSet<>();
    Set<Integer> result = new HashSet<>(sets.get(0));
    for (int i = 1; i < sets.size(); i++) {
        result.retainAll(sets.get(i));
        if (result.isEmpty()) return result;   // short-circuit — can't shrink further
    }
    return result;
}
```

**Key idea:** `retainAll` is a destructive intersection, so copy the first set before modifying.  
Short-circuit when the result becomes empty — subsequent retains can't add elements back.

**Complexity:** O(n · k) where n = total elements across all sets, k = number of sets

---

### 🔴 S9 — Power set

**Problem:** Treat each possible `n`-bit integer as a bitmask selecting which elements to include.

```java
Set<Set<Integer>> powerSet(Set<Integer> input) {
    List<Integer> elements = new ArrayList<>(input);
    int n = elements.size();
    Set<Set<Integer>> result = new HashSet<>();

    // Iterate over all 2^n bitmasks
    for (int mask = 0; mask < (1 << n); mask++) {
        Set<Integer> subset = new HashSet<>();
        for (int i = 0; i < n; i++) {
            if ((mask & (1 << i)) != 0) {    // bit i is set → include elements[i]
                subset.add(elements.get(i));
            }
        }
        result.add(subset);
    }
    return result;
}
```

**Bitmask intuition for `{1,2,3}`:**

| mask | binary | subset      |
|------|--------|-------------|
| 0    | 000    | `{}`        |
| 1    | 001    | `{1}`       |
| 2    | 010    | `{2}`       |
| 3    | 011    | `{1,2}`     |
| 4    | 100    | `{3}`       |
| 5    | 101    | `{1,3}`     |
| 6    | 110    | `{2,3}`     |
| 7    | 111    | `{1,2,3}`   |

**Complexity:** O(2ⁿ · n) time · O(2ⁿ · n) space — unavoidable given the output size

---

## 3. Maps

---

### 💚 M1 — Character frequency

**Problem:** Walk the string and tally each character.

```java
Map<Character, Integer> charFrequency(String s) {
    Map<Character, Integer> freq = new HashMap<>();
    for (char c : s.toCharArray()) {
        freq.merge(c, 1, Integer::sum);
    }
    return freq;
}
```

**`merge` explained:**  
`freq.merge(key, 1, Integer::sum)` means:  
- If `key` is absent → put `1`  
- If `key` is present → replace value with `existingValue + 1`  

It replaces the verbose `getOrDefault(key, 0) + 1` / `put` pair.

**Complexity:** O(n) time · O(k) space

---

### 💚 M2 — Group strings by length

**Problem:** Use the word's length as the map key; `computeIfAbsent` handles list creation lazily.

```java
Map<Integer, List<String>> groupByLength(List<String> words) {
    Map<Integer, List<String>> result = new HashMap<>();
    for (String word : words) {
        result.computeIfAbsent(word.length(), k -> new ArrayList<>()).add(word);
    }
    return result;
}
```

**`computeIfAbsent` explained:**  
Returns the existing list if the key is present; otherwise calls the lambda to create a new `ArrayList`, stores it under the key, and returns it. The `.add(word)` call then appends to whichever list was returned.

**Complexity:** O(n) time · O(n) space

---

### 💚 M3 — Key with highest value

**Problem:** Iterate all entries and track the one with the maximum value.

```java
String mostFrequentWord(Map<String, Integer> wordCounts) {
    return wordCounts.entrySet().stream()
        .max(Map.Entry.comparingByValue())
        .map(Map.Entry::getKey)
        .orElseThrow(() -> new NoSuchElementException("Map is empty"));
}
```

**Alternative (no streams):**
```java
String mostFrequentWord(Map<String, Integer> wordCounts) {
    String best = null;
    int    max  = Integer.MIN_VALUE;
    for (Map.Entry<String, Integer> e : wordCounts.entrySet()) {
        if (e.getValue() > max) { max = e.getValue(); best = e.getKey(); }
    }
    return best;
}
```

**Complexity:** O(n) time

---

### 💚 M4 — Merge two maps

**Problem:** Copy the first map, then merge each entry from the second — summing values on collision.

```java
Map<String, Integer> mergeMaps(Map<String, Integer> a, Map<String, Integer> b) {
    Map<String, Integer> result = new HashMap<>(a);
    b.forEach((key, value) -> result.merge(key, value, Integer::sum));
    return result;
}
```

**Complexity:** O(n + m) time · O(n + m) space

---

### 🟡 M5 — Two Sum (O(n))

**Problem:** Store each seen value's index; for the current element, check if its complement was already stored.

```java
int[] twoSum(int[] nums, int target) {
    Map<Integer, Integer> seen = new HashMap<>();   // value → index
    for (int i = 0; i < nums.length; i++) {
        int complement = target - nums[i];
        if (seen.containsKey(complement)) {
            return new int[]{seen.get(complement), i};
        }
        seen.put(nums[i], i);
    }
    throw new IllegalArgumentException("No solution exists");
}
```

**Why store *before* checking doesn't work:**  
If you `put` first and then check, a single element could be matched with itself (e.g., target=6, element=3 → complement=3, matches itself). Checking first ensures you only pair with *previously seen* elements.

**Complexity:** O(n) time · O(n) space

---

### 🟡 M6 — Inverted index

**Problem:** For each word in each sentence, record which sentence index it came from.

```java
Map<String, Set<Integer>> buildInvertedIndex(List<String> sentences) {
    Map<String, Set<Integer>> index = new HashMap<>();
    for (int i = 0; i < sentences.size(); i++) {
        for (String word : sentences.get(i).toLowerCase().split("\\s+")) {
            if (!word.isEmpty()) {
                index.computeIfAbsent(word, k -> new HashSet<>()).add(i);
            }
        }
    }
    return index;
}
```

**Why a `Set<Integer>` as the value?**  
A word may appear multiple times in the same sentence — a set deduplicates the sentence index automatically.

**Complexity:** O(n · w) where w = average words per sentence · O(total words) space

---

### 🟡 M7 — LRU Cache

**Problem:** `LinkedHashMap` with `accessOrder=true` maintains entries in least-to-most-recently-used order, making eviction trivial.

```java
class LRUCache<K, V> {
    private final LinkedHashMap<K, V> cache;

    LRUCache(int capacity) {
        // accessOrder=true → get() and put() move the entry to the end (most-recently-used)
        this.cache = new LinkedHashMap<>(capacity, 0.75f, true) {
            @Override
            protected boolean removeEldestEntry(Map.Entry<K, V> eldest) {
                return size() > capacity;   // evict the head (least-recently-used) when over capacity
            }
        };
    }

    V get(K key) {
        return cache.getOrDefault(key, null);   // also moves key to "most recently used" position
    }

    void put(K key, V value) {
        cache.put(key, value);
    }
}
```

**How `accessOrder` works:**  
- `false` (default) → iterates in *insertion* order.  
- `true` → every `get` and `put` moves the touched entry to the **tail**.  
- The **head** is always the LRU entry.  
- `removeEldestEntry` is called after every `put`; returning `true` evicts the head automatically.

**Complexity:** O(1) amortized for both `get` and `put` · O(capacity) space

---

### 🔴 M8 — Highest-paid employee per department

**Problem:** Collect into a map; when two employees share a department, keep the higher-salaried one.

```java
record Employee(String name, String department, double salary) {}

Map<String, Employee> highestPaidPerDepartment(List<Employee> employees) {
    return employees.stream()
        .collect(Collectors.toMap(
            Employee::department,               // key
            e -> e,                             // value
            (e1, e2) -> e1.salary() >= e2.salary() ? e1 : e2   // merge on collision
        ));
}
```

**The merge function** is the third argument to `toMap`. It receives two employees mapped to the same department and returns which one to keep — here we keep the higher-salaried one.

**Alternative using `groupingBy` + `maxBy`:**
```java
Map<String, Optional<Employee>> result = employees.stream()
    .collect(Collectors.groupingBy(
        Employee::department,
        Collectors.maxBy(Comparator.comparingDouble(Employee::salary))
    ));
```

**Complexity:** O(n) time · O(d) space, where d = number of distinct departments

---

### 🔴 M9 — Top N most frequent words

**Problem:** Clean the text, count word frequencies, sort by count descending, and collect into an ordered map.

```java
LinkedHashMap<String, Long> topNWords(String text, int n) {
    return Arrays.stream(
                text.toLowerCase()
                    .replaceAll("[^a-z0-9\\s]", "")  // strip punctuation
                    .split("\\s+")
            )
            .filter(w -> !w.isEmpty())
            .collect(Collectors.groupingBy(w -> w, Collectors.counting()))
            .entrySet().stream()
            .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
            .limit(n)
            .collect(Collectors.toMap(
                Map.Entry::getKey,
                Map.Entry::getValue,
                (a, b) -> a,            // no merges expected after limit
                LinkedHashMap::new      // preserves the sorted order
            ));
}
```

**Why `LinkedHashMap` as the output?**  
Regular `HashMap` does not guarantee iteration order. `LinkedHashMap` preserves insertion order, so the map iterates from highest to lowest frequency — exactly what the caller expects.

**Complexity:** O(n log n) due to sort · O(n) space

---

### 🔴 M10 — Shortest path (BFS)

**Problem:** BFS explores nodes level by level, guaranteeing the shortest path in an unweighted graph.

```java
List<String> shortestPath(Map<String, List<String>> graph, String start, String end) {
    if (start.equals(end)) return List.of(start);

    Queue<String> queue  = new LinkedList<>();
    Map<String, String> parent = new HashMap<>();  // node → how we reached it

    queue.offer(start);
    parent.put(start, null);   // null signals "this is the source"

    while (!queue.isEmpty()) {
        String node = queue.poll();
        for (String neighbor : graph.getOrDefault(node, List.of())) {
            if (!parent.containsKey(neighbor)) {   // not yet visited
                parent.put(neighbor, node);
                if (neighbor.equals(end)) {
                    return reconstructPath(parent, end);
                }
                queue.offer(neighbor);
            }
        }
    }
    return List.of();   // no path found
}

private List<String> reconstructPath(Map<String, String> parent, String end) {
    LinkedList<String> path = new LinkedList<>();
    for (String at = end; at != null; at = parent.get(at)) {
        path.addFirst(at);
    }
    return path;
}
```

**Why BFS guarantees shortest path:**  
BFS processes nodes in order of their distance from `start`. The first time BFS reaches `end`, it has taken the fewest hops possible — any other route would require more steps and would have been found later.

**`parent` map serves two purposes:**  
1. Visited check — if a node is already in `parent`, don't enqueue it again.  
2. Path reconstruction — walk backwards from `end` to `start` using parent pointers.

**Complexity:** O(V + E) time · O(V) space (V = vertices, E = edges)

---

## 4. Streams

---

### 💚 ST1 — Filter and transform

**Problem:** Chain `filter` and `map` — the order matters for correctness and (mildly) for performance.

```java
List<String> filterAndUppercase(List<String> words) {
    return words.stream()
        .filter(w -> w.length() > 4)    // discard short words first
        .map(String::toUpperCase)        // then transform — fewer elements to process
        .collect(Collectors.toList());
}
```

**Why filter before map?**  
`filter` is lazy and runs before `map` for each element. Filtering first means fewer `toUpperCase` calls. It doesn't change correctness but is a good habit.

**Complexity:** O(n) time · O(k) space (k = matching elements)

---

### 💚 ST2 — Sum of squares of odd numbers

**Problem:** Three operations: filter odds, square each, sum.

```java
int sumOfSquaresOfOdds(List<Integer> numbers) {
    return numbers.stream()
        .filter(n -> n % 2 != 0)
        .mapToInt(n -> n * n)     // use primitive IntStream to avoid boxing overhead
        .sum();
}
```

**`mapToInt` vs `map`:**  
`map(n -> n * n)` returns a `Stream<Integer>` (boxed). `mapToInt` returns an `IntStream` (primitive), which has `.sum()`, `.average()`, `.min()`, `.max()` built in and avoids autoboxing.

**Complexity:** O(n) time · O(1) space (no intermediate collection)

---

### 💚 ST3 — Count words starting with 'A'

**Problem:** Use `count()` — a terminal operation that doesn't build a collection.

```java
long countStartingWithA(List<String> words) {
    return words.stream()
        .filter(w -> !w.isEmpty() && Character.toLowerCase(w.charAt(0)) == 'a')
        .count();
}
```

**Why `long` and not `int`?**  
`count()` returns `long` because a stream could theoretically have more than `Integer.MAX_VALUE` elements (e.g., from an infinite source truncated with `limit`).

**Complexity:** O(n) time · O(1) space

---

### 💚 ST4 — Flatten nested list

**Problem:** `flatMap` replaces each element with the elements of a sub-stream.

```java
List<Integer> flatten(List<List<Integer>> nested) {
    return nested.stream()
        .flatMap(List::stream)          // List::stream is equivalent to list -> list.stream()
        .collect(Collectors.toList());
}
```

**`map` vs `flatMap`:**  
`map(List::stream)` would give `Stream<Stream<Integer>>` — a stream of streams.  
`flatMap(List::stream)` *flattens* those inner streams into one continuous `Stream<Integer>`.

**Complexity:** O(n) total elements · O(n) space

---

### 🟡 ST5 — Group by first character

**Problem:** `Collectors.groupingBy` splits a stream into groups based on a classifier function.

```java
Map<Character, List<String>> groupByFirstChar(List<String> words) {
    return words.stream()
        .filter(w -> !w.isEmpty())
        .collect(Collectors.groupingBy(w -> w.charAt(0)));
}
```

**`groupingBy` signature:**  
`groupingBy(classifier)` → `Map<K, List<T>>`  
The classifier function maps each element to its group key.

**Complexity:** O(n) time · O(n) space

---

### 🟡 ST6 — Average salary by department

**Problem:** `groupingBy` + `averagingDouble` computes per-group averages in a single pass.

```java
record Employee(String name, String department, double salary) {}

Map<String, Double> avgSalaryByDepartment(List<Employee> employees) {
    return employees.stream()
        .collect(Collectors.groupingBy(
            Employee::department,
            Collectors.averagingDouble(Employee::salary)
        ));
}
```

**Downstream collectors:**  
The second argument to `groupingBy` is a *downstream collector* — it specifies what to do with the elements in each group instead of collecting them into a list.  
Common downstream collectors: `counting()`, `summingInt()`, `averagingDouble()`, `maxBy()`, `joining()`.

**Complexity:** O(n) time · O(d) space (d = number of departments)

---

### 🟡 ST7 — Find the longest string

**Problem:** `max` with a comparator returns an `Optional` — safe for empty inputs.

```java
Optional<String> findLongest(List<String> words) {
    return words.stream()
        .max(Comparator.comparingInt(String::length));
}
```

**Why `Optional`?**  
If the list is empty, there is no longest string to return. `Optional` forces the caller to handle the absent case, preventing `NullPointerException`.

**Complexity:** O(n) time · O(1) space

---

### 🟡 ST8 — Partition by divisibility

**Problem:** `partitioningBy` is a special case of `groupingBy` that always produces exactly two groups: `true` and `false`.

```java
Map<Boolean, List<Integer>> partitionByDivisibleBy3(List<Integer> numbers) {
    return numbers.stream()
        .collect(Collectors.partitioningBy(n -> n % 3 == 0));
}
```

**`partitioningBy` vs `groupingBy`:**  
- `groupingBy` — arbitrary number of groups, keyed by the classifier's return type.  
- `partitioningBy` — always exactly two groups (`true`/`false`), slightly more efficient than `groupingBy(n -> n % 3 == 0 ? true : false)` because it uses an optimized internal implementation.

**Complexity:** O(n) time · O(n) space

---

### 🔴 ST9 — Highest-value transaction per currency

**Problem:** `groupingBy` + `maxBy` finds the maximum element within each group.

```java
record Transaction(String currency, double amount) {}

Map<String, Optional<Transaction>> maxTransactionByCurrency(List<Transaction> transactions) {
    return transactions.stream()
        .collect(Collectors.groupingBy(
            Transaction::currency,
            Collectors.maxBy(Comparator.comparingDouble(Transaction::amount))
        ));
}
```

**Why `Optional<Transaction>` as the value?**  
`maxBy` returns `Optional` because a group could theoretically be empty (though in practice `groupingBy` only creates groups for elements that exist).  
If you want to unwrap the `Optional`, use `collectingAndThen`:
```java
Collectors.collectingAndThen(
    Collectors.maxBy(Comparator.comparingDouble(Transaction::amount)),
    opt -> opt.orElseThrow()
)
```

**Complexity:** O(n) time · O(c) space (c = number of distinct currencies)

---

### 🔴 ST10 — Fibonacci sequence via Stream.iterate

**Problem:** Carry a pair `[f(n-1), f(n)]` as state — each step produces the next pair.

```java
List<Long> fibonacci(int n) {
    if (n <= 0) return List.of();
    return Stream.iterate(
                new long[]{0L, 1L},         // seed: [F(0), F(1)]
                f -> new long[]{f[1], f[0] + f[1]}  // next state
            )
            .limit(n)
            .map(f -> f[0])                  // extract just F(n) from each pair
            .collect(Collectors.toList());
}
```

**Trace for n=5:**
```
seed  → [0, 1]  → emit 0
step1 → [1, 1]  → emit 1
step2 → [1, 2]  → emit 1
step3 → [2, 3]  → emit 2
step4 → [3, 5]  → emit 3
Result: [0, 1, 1, 2, 3]
```

**Java 9+ alternative with `Stream.iterate(seed, hasNext, next)` (finite by design):**
```java
Stream.iterate(new long[]{0, 1}, f -> f[1] < Long.MAX_VALUE / 2, f -> new long[]{f[1], f[0] + f[1]})
```

**Complexity:** O(n) time · O(n) space (output list)

---

### 🔴 ST11 — Custom batch Collector

**Problem:** Build a `Collector` manually using `Collector.of(supplier, accumulator, combiner)`.

```java
static <T> Collector<T, List<List<T>>, List<List<T>>> batchCollector(int batchSize) {
    return Collector.of(
        ArrayList::new,                     // supplier  — create the mutable container (list of batches)
        (batches, element) -> {             // accumulator — add one element
            if (batches.isEmpty()
                    || batches.get(batches.size() - 1).size() == batchSize) {
                batches.add(new ArrayList<>());   // start a new batch
            }
            batches.get(batches.size() - 1).add(element);
        },
        (left, right) -> {                  // combiner — merge two partial results (parallel streams)
            if (!left.isEmpty() && !right.isEmpty()
                    && left.get(left.size() - 1).size() < batchSize) {
                // Fill the last batch of 'left' from the first batch of 'right'
                List<T> lastLeft  = left.get(left.size() - 1);
                List<T> firstRight = right.get(0);
                int space = batchSize - lastLeft.size();
                lastLeft.addAll(firstRight.subList(0, Math.min(space, firstRight.size())));
                if (space < firstRight.size()) {
                    right.set(0, firstRight.subList(space, firstRight.size()));
                } else {
                    right.remove(0);
                }
            }
            left.addAll(right);
            return left;
        }
    );
}
```

**The three functions of `Collector.of`:**

| Function      | Role                                                 |
|---------------|------------------------------------------------------|
| `supplier`    | Creates the mutable accumulation container           |
| `accumulator` | Folds one stream element into the container          |
| `combiner`    | Merges two containers (only used in parallel streams) |

**Usage:**
```java
List<List<Integer>> batches = Stream.of(1, 2, 3, 4, 5, 6, 7)
    .collect(batchCollector(3));
// → [[1,2,3],[4,5,6],[7]]
```

**Complexity:** O(n) time · O(n) space

---

### 🔴 ST12 — Parallel stream character count + trade-offs

**Part A — Implementation:**

```java
long totalCharCount(List<String> words) {
    return words.parallelStream()
        .mapToLong(String::length)
        .sum();
}
```

`mapToLong` returns a `LongStream`, whose `.sum()` is an associative reduction — safe and efficient in parallel because partial sums can be combined in any order.

---

**Part B — When parallel streams hurt performance:**

**1. Small collections — thread overhead exceeds compute savings.**  
`parallelStream()` uses the common `ForkJoinPool`. Splitting work, scheduling threads, and merging results has fixed overhead of ~10,000–100,000 ns. For a list of 10 strings, this overhead dwarfs the computation.  
Rule of thumb: sequential is faster unless each element takes significant CPU time **and** the list has thousands of elements.

**2. Ordered operations on sequentially-dependent sources.**  
`LinkedList` cannot be efficiently split — elements are not randomly accessible, so the spliterator degenerates to sequential. Also, operations like `findFirst()` on a parallel stream still impose ordering overhead to guarantee "first," negating the parallelism benefit.

**3. Shared mutable state — correctness breaks.**  
```java
// BUG: multiple threads write to 'result' simultaneously
List<String> result = new ArrayList<>();
words.parallelStream().forEach(result::add);  // data race!
```
`ArrayList` is not thread-safe. The result will have missing or duplicated elements.  
Always use thread-safe collectors (`collect(Collectors.toList())`) or concurrent data structures with parallel streams.

**4. I/O-bound operations.**  
If each element involves a network call or disk read, adding threads doesn't help — all threads block on I/O anyway, and you may increase contention at the I/O resource.

**5. Non-associative reduction order.**  
`reduce` with a non-associative function (`-`, `/`) gives different results in parallel vs sequential.  
```java
// Sequential: ((10 - 3) - 2) = 5
// Parallel:   (10 - (3 - 2)) = 9  ← wrong!
Stream.of(10, 3, 2).reduce(0, (a, b) -> a - b);
```

---

> 📁 Questions are in `java-collections-questions.md`
