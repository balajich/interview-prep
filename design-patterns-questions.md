# Design Patterns — Practice Questions

> **How to use:** Work through each question on your own before opening the answers file.  
> Questions ask you to implement the pattern and explain when to use it vs alternatives.  
> 💚 Beginner · 🟡 Intermediate · 🔴 Advanced

---

## Table of Contents
1. [Creational Patterns](#1-creational-patterns)
2. [Structural Patterns](#2-structural-patterns)
3. [Behavioral Patterns](#3-behavioral-patterns)

---

## 1. Creational Patterns

### 💚 Beginner

**CR1 — Singleton**  
Implement a thread-safe `Singleton` class that holds an application-wide configuration registry (`Map<String, String>`). Use lazy initialization without synchronizing every `getInstance()` call.

```java
public class ConfigRegistry {
    // implement thread-safe lazy singleton
    public void set(String key, String value) { }
    public String get(String key) { }
}
```

When is Singleton the right choice, and when does it become an anti-pattern?

---

**CR2 — Factory Method**  
Implement a `NotificationFactory` that creates the correct `Notification` implementation (`EmailNotification`, `SmsNotification`, `PushNotification`) based on a `NotificationType` enum without using `switch`/`if-else` in the factory.

```java
interface Notification { void send(String message); }

// implement factory and concrete classes
```

---

### 🟡 Intermediate

**CR3 — Abstract Factory**  
You are building a UI toolkit that must support two themes: `Light` and `Dark`. Each theme provides `Button` and `TextField` components with different rendering. Implement the Abstract Factory pattern.

```java
interface Button { void render(); }
interface TextField { void render(); }
interface UIFactory {
    Button createButton();
    TextField createTextField();
}
// implement LightFactory, DarkFactory, and concrete components
```

What is the difference between Abstract Factory and Factory Method?

---

**CR4 — Builder**  
Implement a `HttpRequest` builder that has mandatory fields (`method`, `url`) and optional fields (`headers`, `body`, `timeout`). Enforce the mandatory fields at compile time (not runtime). Show the calling code.

```java
public class HttpRequest {
    // implement builder
}
// expected usage:
// HttpRequest req = new HttpRequest.Builder("GET", "https://api.example.com/users")
//     .header("Accept", "application/json")
//     .timeout(Duration.ofSeconds(30))
//     .build();
```

---

**CR5 — Prototype**  
When is `clone()` useful, and what are its pitfalls? Implement a `ShapeGroup` that contains a list of `Shape` objects. Show both a shallow copy and a deep copy, and explain when each is safe.

```java
interface Shape { Shape clone(); }
class Circle implements Shape { double radius; }
class ShapeGroup implements Shape {
    List<Shape> shapes;
    // implement shallow and deep clone
}
```

---

### 🔴 Advanced

**CR6 — Object Pool**  
Object Pool is a creational pattern not in the original GoF book but common in practice (JDBC connection pools, thread pools). Implement a generic, thread-safe `ObjectPool<T>` with a fixed capacity. When the pool is exhausted, the caller blocks until an object is returned.

```java
public class ObjectPool<T> {
    ObjectPool(int capacity, Supplier<T> factory) { }
    T acquire() throws InterruptedException { }
    void release(T obj) { }
}
```

---

## 2. Structural Patterns

### 💚 Beginner

**ST1 — Adapter**  
You have a legacy `XmlParser` that reads configuration from XML. Your new system expects a `ConfigReader` interface that works with key-value maps. Write an adapter without modifying `XmlParser`.

```java
class XmlParser {
    public Document parse(String xml) { /* legacy code */ return null; }
}
interface ConfigReader {
    Map<String, String> read(String source);
}
// implement XmlConfigAdapter
```

---

**ST2 — Decorator**  
Implement a `TextFormatter` system where formatters can be chained at runtime. Start with `PlainText`, then add `BoldDecorator` (wraps in `<b>`), `ItalicDecorator` (wraps in `<i>`), and `UpperCaseDecorator`. Show them composed in different orders.

```java
interface TextFormatter { String format(String text); }
// implement PlainText, BoldDecorator, ItalicDecorator, UpperCaseDecorator
```

What is the difference between Decorator and Inheritance for extending behavior?

---

### 🟡 Intermediate

**ST3 — Proxy**  
Implement a `VirtualProxy` for an expensive `ReportGenerator` that is only initialized when `generate()` is actually called. Then implement a `ProtectionProxy` that checks user roles before delegating.

```java
interface ReportGenerator { Report generate(String reportId); }
class RealReportGenerator implements ReportGenerator { /* expensive init */ }
// implement VirtualProxy and ProtectionProxy
```

What are the three main types of proxy (virtual, protection, remote)?

---

**ST4 — Composite**  
Model a file-system tree where both `File` and `Directory` implement a common `FileSystemNode` interface. `Directory` can contain any mix of files and directories. Implement `size()` and `print(indent)` recursively.

```java
interface FileSystemNode {
    long size();
    void print(String indent);
}
// implement File and Directory
```

---

**ST5 — Facade**  
A home theatre has subsystems: `Amplifier`, `Projector`, `StreamingPlayer`, `Lights`. Implement a `HomeTheatreFacade` with `watchMovie(String movie)` and `endMovie()` methods that coordinate all subsystems. What problem does Facade solve?

```java
// implement all subsystem classes and HomeTheatreFacade
```

---

### 🔴 Advanced

**ST6 — Flyweight**  
A game renders 100,000 `Tree` objects. Each tree has a type (species, texture, color) that is shared and a position (`x`, `y`) that is unique. Implement the Flyweight pattern to minimise memory usage.

```java
// implement TreeType (flyweight), Tree, and TreeFactory
// show how rendering 100,000 trees uses only a handful of TreeType objects
```

What is the intrinsic vs extrinsic state distinction?

---

## 3. Behavioral Patterns

### 💚 Beginner

**B1 — Strategy**  
Implement a `Sorter` that accepts a sorting strategy at runtime: `BubbleSort`, `QuickSort`, `MergeSort`. The client can swap strategies without changing the `Sorter` class.

```java
interface SortStrategy { void sort(int[] arr); }
class Sorter {
    // implement with strategy injection
}
```

How does Strategy differ from Template Method?

---

**B2 — Observer**  
Implement a stock price feed where `StockTicker` publishes price updates and multiple observers (`PriceAlertObserver`, `LoggingObserver`) subscribe to changes. Use the push model (data included in the notification).

```java
interface StockObserver { void onPriceChange(String symbol, double newPrice); }
class StockTicker {
    // implement subscribe, unsubscribe, publish
}
```

---

### 🟡 Intermediate

**B3 — Command**  
Implement an undo/redo system for a text editor. Each operation (`InsertCommand`, `DeleteCommand`) encapsulates the action and its inverse. Maintain a history stack.

```java
interface Command {
    void execute();
    void undo();
}
class TextEditor {
    // implement executeCommand(), undo(), redo()
}
```

---

**B4 — Template Method**  
Different report exporters (`PdfExporter`, `CsvExporter`, `HtmlExporter`) share the same lifecycle: `openDocument()` → `writeHeader()` → `writeBody(data)` → `writeFooter()` → `closeDocument()`. Implement the Template Method pattern.

```java
abstract class ReportExporter {
    // implement template method and abstract/hook methods
}
```

Which methods should be abstract and which should be hook (optional override) methods?

---

**B5 — Iterator**  
Implement a `BinaryTree<T>` with an in-order `Iterator<T>` without exposing the internal tree structure to callers.

```java
class BinaryTree<T extends Comparable<T>> implements Iterable<T> {
    // implement insert and iterator()
}
```

---

### 🔴 Advanced

**B6 — Chain of Responsibility**  
Implement an HTTP middleware chain where each handler (`AuthenticationHandler`, `RateLimitHandler`, `LoggingHandler`) can either handle the request and stop the chain, or pass it to the next handler.

```java
abstract class HttpHandler {
    protected HttpHandler next;
    HttpHandler setNext(HttpHandler next) { this.next = next; return next; }
    abstract Response handle(Request request);
}
// implement concrete handlers and show how to compose the chain
```

---

**B7 — State**  
Model a vending machine with states: `IdleState`, `HasMoneyState`, `DispensingState`, `OutOfStockState`. Transitions occur on events: `insertMoney`, `selectProduct`, `dispense`, `cancel`. Implement the State pattern so that each state class encapsulates its own transition logic.

```java
interface VendingMachineState {
    void insertMoney(VendingMachine machine, double amount);
    void selectProduct(VendingMachine machine, String product);
    void dispense(VendingMachine machine);
    void cancel(VendingMachine machine);
}
class VendingMachine {
    // implement state holder and delegating methods
}
```

---

**B8 — Visitor**  
You have an AST (Abstract Syntax Tree) with node types `NumberNode`, `AddNode`, `MultiplyNode`. Without modifying the node classes, implement two visitors: `EvaluatorVisitor` (computes the result) and `PrintVisitor` (prints the expression).

```java
interface AstVisitor<T> {
    T visit(NumberNode node);
    T visit(AddNode node);
    T visit(MultiplyNode node);
}
interface AstNode { <T> T accept(AstVisitor<T> visitor); }
// implement all node types and both visitors
```

What is the "double dispatch" mechanism, and why is it needed?

---

> 📁 Answers are in `design-patterns-answers.md`
