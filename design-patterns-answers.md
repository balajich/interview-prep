# Design Patterns — Answers

> Each answer restates the problem briefly, provides a complete implementation, and explains when to prefer the pattern over alternatives.  
> 💚 Beginner · 🟡 Intermediate · 🔴 Advanced

---

## 1. Creational Patterns

---

### 💚 CR1 — Singleton

**Problem:** Thread-safe lazy singleton without synchronizing every call.

```java
public class ConfigRegistry {

    // Initialization-on-demand holder — JVM guarantees thread-safe lazy init
    private static final class Holder {
        static final ConfigRegistry INSTANCE = new ConfigRegistry();
    }

    private final ConcurrentHashMap<String, String> store = new ConcurrentHashMap<>();

    private ConfigRegistry() { }

    public static ConfigRegistry getInstance() {
        return Holder.INSTANCE;   // no synchronization needed — class loading is thread-safe
    }

    public void set(String key, String value) { store.put(key, value); }
    public String get(String key)             { return store.get(key); }
}
```

**Alternative — enum Singleton** (also thread-safe, serialization-safe):
```java
public enum ConfigRegistry {
    INSTANCE;
    private final ConcurrentHashMap<String, String> store = new ConcurrentHashMap<>();
    public void set(String key, String value) { store.put(key, value); }
    public String get(String key)             { return store.get(key); }
}
```

**When Singleton is right:** Stateless utility services, shared resource managers (thread pool, connection pool).  
**When it becomes an anti-pattern:** Mutable global state shared across tests (causes test pollution); tight coupling to a concrete class makes unit testing hard — prefer dependency injection.

---

### 💚 CR2 — Factory Method

**Problem:** Create notifications by type without if/switch.

```java
public enum NotificationType { EMAIL, SMS, PUSH }

public interface Notification {
    void send(String message);
}

public class EmailNotification implements Notification {
    public void send(String message) { System.out.println("Email: " + message); }
}
public class SmsNotification implements Notification {
    public void send(String message) { System.out.println("SMS: " + message); }
}
public class PushNotification implements Notification {
    public void send(String message) { System.out.println("Push: " + message); }
}

public class NotificationFactory {
    private static final Map<NotificationType, Supplier<Notification>> REGISTRY = Map.of(
        NotificationType.EMAIL, EmailNotification::new,
        NotificationType.SMS,   SmsNotification::new,
        NotificationType.PUSH,  PushNotification::new
    );

    public static Notification create(NotificationType type) {
        Supplier<Notification> supplier = REGISTRY.get(type);
        if (supplier == null) throw new IllegalArgumentException("Unknown type: " + type);
        return supplier.get();
    }
}
```

Adding a new notification type = add an enum constant + register a supplier. No existing code changes.

---

### 🟡 CR3 — Abstract Factory

**Problem:** Light/Dark themed UI components.

```java
interface Button    { void render(); }
interface TextField { void render(); }

interface UIFactory {
    Button    createButton();
    TextField createTextField();
}

// Light theme
class LightButton    implements Button    { public void render() { System.out.println("Light Button");    } }
class LightTextField implements TextField { public void render() { System.out.println("Light TextField"); } }
class LightFactory   implements UIFactory {
    public Button    createButton()    { return new LightButton();    }
    public TextField createTextField() { return new LightTextField(); }
}

// Dark theme
class DarkButton    implements Button    { public void render() { System.out.println("Dark Button");    } }
class DarkTextField implements TextField { public void render() { System.out.println("Dark TextField"); } }
class DarkFactory   implements UIFactory {
    public Button    createButton()    { return new DarkButton();    }
    public TextField createTextField() { return new DarkTextField(); }
}

// Client
class Application {
    private final Button    button;
    private final TextField textField;

    Application(UIFactory factory) {
        this.button    = factory.createButton();
        this.textField = factory.createTextField();
    }
    void render() { button.render(); textField.render(); }
}

// Usage
Application app = new Application(new DarkFactory());
app.render();
```

**Abstract Factory vs Factory Method:**
- **Factory Method** — one method creates one product; subclasses decide the concrete type
- **Abstract Factory** — a family of related products created together; ensures products are compatible (Light button with Light text field, never mixed)

---

### 🟡 CR4 — Builder

**Problem:** Mandatory fields enforced at compile time.

```java
public class HttpRequest {
    private final String method;
    private final String url;
    private final Map<String, String> headers;
    private final String body;
    private final Duration timeout;

    private HttpRequest(Builder builder) {
        this.method  = builder.method;
        this.url     = builder.url;
        this.headers = Collections.unmodifiableMap(builder.headers);
        this.body    = builder.body;
        this.timeout = builder.timeout;
    }

    public static class Builder {
        // mandatory — set via constructor; cannot be null
        private final String method;
        private final String url;
        // optional
        private Map<String, String> headers = new HashMap<>();
        private String body;
        private Duration timeout = Duration.ofSeconds(10);

        public Builder(String method, String url) {
            this.method = Objects.requireNonNull(method, "method required");
            this.url    = Objects.requireNonNull(url, "url required");
        }

        public Builder header(String name, String value) {
            headers.put(name, value); return this;
        }
        public Builder body(String body)       { this.body    = body;    return this; }
        public Builder timeout(Duration t)     { this.timeout = t;       return this; }
        public HttpRequest build()             { return new HttpRequest(this); }
    }

    // getters...
}

// Usage
HttpRequest req = new HttpRequest.Builder("GET", "https://api.example.com/users")
    .header("Accept", "application/json")
    .timeout(Duration.ofSeconds(30))
    .build();
```

Mandatory fields go in the `Builder` constructor — missing them causes a compile error.

---

### 🟡 CR5 — Prototype

**Problem:** Shallow vs deep clone for a shape group.

```java
interface Shape { Shape clone(); }

class Circle implements Shape {
    double radius;
    Circle(double radius) { this.radius = radius; }
    public Shape clone() { return new Circle(this.radius); }  // primitive — same either way
}

class ShapeGroup implements Shape {
    List<Shape> shapes;
    ShapeGroup(List<Shape> shapes) { this.shapes = shapes; }

    // Shallow clone — new list, same Shape references
    public Shape shallowClone() {
        return new ShapeGroup(new ArrayList<>(this.shapes));
    }

    // Deep clone — new list AND new copies of each shape
    public Shape clone() {
        List<Shape> copied = shapes.stream()
                                   .map(Shape::clone)
                                   .collect(Collectors.toList());
        return new ShapeGroup(copied);
    }
}
```

**When shallow copy is safe:** The contained objects are immutable (Strings, Integer, etc.) — shared references can't cause bugs.  
**When deep copy is needed:** The contained objects are mutable. Without deep copy, changes to a shape in the clone affect the original.

**`clone()` pitfalls:**
- `Object.clone()` is `protected` and requires `Cloneable` marker interface (error-prone API)
- Copy constructors or static factory methods are cleaner alternatives
- Deeply nested graphs require careful recursion or serialization tricks

---

### 🔴 CR6 — Object Pool

**Problem:** Thread-safe, blocking object pool.

```java
public class ObjectPool<T> {
    private final BlockingQueue<T> pool;

    public ObjectPool(int capacity, Supplier<T> factory) {
        pool = new ArrayBlockingQueue<>(capacity);
        for (int i = 0; i < capacity; i++) {
            pool.offer(factory.get());
        }
    }

    public T acquire() throws InterruptedException {
        return pool.take();   // blocks until an object is available
    }

    public void release(T obj) {
        pool.offer(obj);      // returns the object for reuse
    }
}

// Usage
ObjectPool<DatabaseConnection> pool = new ObjectPool<>(10, DatabaseConnection::new);
DatabaseConnection conn = pool.acquire();
try {
    conn.executeQuery("SELECT 1");
} finally {
    pool.release(conn);   // always release — prefer try-with-resources via AutoCloseable wrapper
}
```

**Key idea:** `BlockingQueue.take()` provides blocking semantics for free. HikariCP, the most popular JDBC connection pool, uses a similar primitive internally.

---

## 2. Structural Patterns

---

### 💚 ST1 — Adapter

**Problem:** Adapt `XmlParser` to the `ConfigReader` interface.

```java
class XmlParser {
    public Document parse(String xml) { /* legacy */ return new Document(); }
}

interface ConfigReader {
    Map<String, String> read(String source);
}

class XmlConfigAdapter implements ConfigReader {
    private final XmlParser parser;

    XmlConfigAdapter(XmlParser parser) { this.parser = parser; }

    @Override
    public Map<String, String> read(String source) {
        Document doc = parser.parse(source);
        Map<String, String> config = new HashMap<>();
        // extract key-value pairs from Document (XPath, NodeList, etc.)
        doc.getElementsByTagName("entry").forEach(node ->
            config.put(node.getAttribute("key"), node.getTextContent()));
        return config;
    }
}
```

The adapter wraps the incompatible class and translates calls — neither the client nor `XmlParser` changes.

---

### 💚 ST2 — Decorator

**Problem:** Chainable text formatters.

```java
interface TextFormatter { String format(String text); }

class PlainText implements TextFormatter {
    public String format(String text) { return text; }
}

abstract class TextDecorator implements TextFormatter {
    protected final TextFormatter wrapped;
    TextDecorator(TextFormatter wrapped) { this.wrapped = wrapped; }
}

class BoldDecorator extends TextDecorator {
    BoldDecorator(TextFormatter f) { super(f); }
    public String format(String text) { return "<b>" + wrapped.format(text) + "</b>"; }
}

class ItalicDecorator extends TextDecorator {
    ItalicDecorator(TextFormatter f) { super(f); }
    public String format(String text) { return "<i>" + wrapped.format(text) + "</i>"; }
}

class UpperCaseDecorator extends TextDecorator {
    UpperCaseDecorator(TextFormatter f) { super(f); }
    public String format(String text) { return wrapped.format(text).toUpperCase(); }
}

// Composed in different orders:
TextFormatter boldItalic = new BoldDecorator(new ItalicDecorator(new PlainText()));
System.out.println(boldItalic.format("hello"));   // <b><i>hello</i></b>

TextFormatter upperBold = new UpperCaseDecorator(new BoldDecorator(new PlainText()));
System.out.println(upperBold.format("hello"));    // <B>HELLO</B>
```

**Decorator vs Inheritance:**
- Inheritance — behavior fixed at compile time; combinatorial explosion for many variations (BoldItalic, BoldUpperCase, ItalicUpperCase...)
- Decorator — behavior composed at runtime; each combination is just a stack of wrappers

---

### 🟡 ST3 — Proxy

**Problem:** Virtual proxy for lazy init; protection proxy for role checking.

```java
interface ReportGenerator { Report generate(String reportId); }

class RealReportGenerator implements ReportGenerator {
    public RealReportGenerator() {
        System.out.println("Expensive initialization...");
    }
    public Report generate(String id) { return new Report(id); }
}

// Virtual proxy — defers initialization
class LazyReportProxy implements ReportGenerator {
    private RealReportGenerator real;

    public synchronized Report generate(String id) {
        if (real == null) real = new RealReportGenerator();  // init on first use
        return real.generate(id);
    }
}

// Protection proxy — checks authorization
class SecureReportProxy implements ReportGenerator {
    private final ReportGenerator delegate;
    private final Set<String> allowedRoles;

    SecureReportProxy(ReportGenerator delegate, Set<String> allowedRoles) {
        this.delegate = delegate;
        this.allowedRoles = allowedRoles;
    }

    public Report generate(String id) {
        String userRole = SecurityContext.getCurrentRole();
        if (!allowedRoles.contains(userRole))
            throw new AccessDeniedException("Role " + userRole + " cannot generate reports");
        return delegate.generate(id);
    }
}
```

**Three proxy types:**
1. **Virtual** — delays expensive creation until first use
2. **Protection** — controls access (authentication/authorization)
3. **Remote** — represents an object in a different address space (RMI stubs, gRPC client stubs)

---

### 🟡 ST4 — Composite

**Problem:** Recursive file-system tree.

```java
interface FileSystemNode {
    long size();
    void print(String indent);
}

class File implements FileSystemNode {
    private final String name;
    private final long bytes;

    File(String name, long bytes) { this.name = name; this.bytes = bytes; }

    public long size() { return bytes; }
    public void print(String indent) {
        System.out.println(indent + name + " (" + bytes + " B)");
    }
}

class Directory implements FileSystemNode {
    private final String name;
    private final List<FileSystemNode> children = new ArrayList<>();

    Directory(String name) { this.name = name; }

    public void add(FileSystemNode node) { children.add(node); }

    public long size() {
        return children.stream().mapToLong(FileSystemNode::size).sum();
    }

    public void print(String indent) {
        System.out.println(indent + "[" + name + "] (" + size() + " B)");
        children.forEach(c -> c.print(indent + "  "));
    }
}

// Usage
Directory root = new Directory("root");
root.add(new File("readme.txt", 1024));
Directory src = new Directory("src");
src.add(new File("Main.java", 2048));
src.add(new File("App.java",  4096));
root.add(src);
root.print("");
```

**Key idea:** Clients treat `File` and `Directory` identically through the `FileSystemNode` interface — no `instanceof` checks needed.

---

### 🟡 ST5 — Facade

**Problem:** Simplify a home theatre's complex subsystems.

```java
class Amplifier   { void on() {} void off() {} void setVolume(int v) {} }
class Projector   { void on() {} void off() {} void wideScreenMode() {} }
class StreamingPlayer { void on() {} void off() {} void play(String m) {} }
class Lights      { void dim(int level) {} void on() {} }

class HomeTheatreFacade {
    private final Amplifier    amp;
    private final Projector    proj;
    private final StreamingPlayer player;
    private final Lights       lights;

    HomeTheatreFacade(Amplifier amp, Projector proj,
                      StreamingPlayer player, Lights lights) {
        this.amp = amp; this.proj = proj;
        this.player = player; this.lights = lights;
    }

    public void watchMovie(String movie) {
        lights.dim(10);
        proj.on();
        proj.wideScreenMode();
        amp.on();
        amp.setVolume(5);
        player.on();
        player.play(movie);
    }

    public void endMovie() {
        player.off();
        amp.off();
        proj.off();
        lights.on();
    }
}
```

**Problem Facade solves:** Clients no longer need to know the correct startup sequence or which subsystems to coordinate. Reduces coupling between client code and complex subsystems.

---

### 🔴 ST6 — Flyweight

**Problem:** 100,000 trees share species/texture/color (intrinsic) but differ in position (extrinsic).

```java
// Flyweight — shared, immutable
class TreeType {
    private final String species;
    private final String texture;
    private final String color;

    TreeType(String species, String texture, String color) {
        this.species = species; this.texture = texture; this.color = color;
    }

    public void draw(int x, int y) {
        System.out.printf("Drawing %s tree at (%d,%d)%n", species, x, y);
    }
}

// Flyweight factory — ensures sharing
class TreeFactory {
    private static final Map<String, TreeType> cache = new HashMap<>();

    public static TreeType getTreeType(String species, String texture, String color) {
        String key = species + texture + color;
        return cache.computeIfAbsent(key, k -> new TreeType(species, texture, color));
    }
}

// Context — holds extrinsic state (position)
class Tree {
    private final int x, y;
    private final TreeType type;

    Tree(int x, int y, TreeType type) { this.x = x; this.y = y; this.type = type; }

    public void draw() { type.draw(x, y); }
}

// Client — 100,000 trees, only a handful of TreeType objects
List<Tree> forest = new ArrayList<>();
Random rand = new Random();
String[] species = {"Oak", "Pine", "Maple"};
for (int i = 0; i < 100_000; i++) {
    String s = species[rand.nextInt(3)];
    TreeType type = TreeFactory.getTreeType(s, s + "_texture", "green");
    forest.add(new Tree(rand.nextInt(1000), rand.nextInt(1000), type));
}
```

**Intrinsic state** — shared, immutable, stored in the flyweight (`TreeType`).  
**Extrinsic state** — unique per instance, passed in at use time (`x`, `y` in `draw()`).

---

## 3. Behavioral Patterns

---

### 💚 B1 — Strategy

**Problem:** Swappable sort algorithms.

```java
interface SortStrategy { void sort(int[] arr); }

class BubbleSort implements SortStrategy {
    public void sort(int[] arr) { /* bubble sort */ }
}
class QuickSort implements SortStrategy {
    public void sort(int[] arr) { /* quick sort */ }
}
class MergeSort implements SortStrategy {
    public void sort(int[] arr) { /* merge sort */ }
}

class Sorter {
    private SortStrategy strategy;

    Sorter(SortStrategy strategy) { this.strategy = strategy; }

    public void setStrategy(SortStrategy strategy) { this.strategy = strategy; }

    public void sort(int[] data) { strategy.sort(data); }
}

// Usage
Sorter sorter = new Sorter(new QuickSort());
sorter.sort(data);
sorter.setStrategy(new MergeSort());   // swap at runtime
sorter.sort(data);
```

**Strategy vs Template Method:**
- **Strategy** — behavior defined by a separate object; swappable at runtime; uses composition
- **Template Method** — behavior defined by overriding a method in a subclass; fixed at compile time; uses inheritance

Prefer Strategy when you need runtime flexibility or want to avoid subclass proliferation.

---

### 💚 B2 — Observer

**Problem:** Push-model stock price feed.

```java
interface StockObserver { void onPriceChange(String symbol, double newPrice); }

class StockTicker {
    private final Map<String, Double> prices = new HashMap<>();
    private final List<StockObserver> observers = new CopyOnWriteArrayList<>();

    public void subscribe(StockObserver o)   { observers.add(o); }
    public void unsubscribe(StockObserver o) { observers.remove(o); }

    public void setPrice(String symbol, double price) {
        prices.put(symbol, price);
        observers.forEach(o -> o.onPriceChange(symbol, price));  // push data to all observers
    }
}

class PriceAlertObserver implements StockObserver {
    public void onPriceChange(String symbol, double price) {
        if (price > 1000) System.out.println("ALERT: " + symbol + " exceeded $1000!");
    }
}

class LoggingObserver implements StockObserver {
    public void onPriceChange(String symbol, double price) {
        System.out.printf("[LOG] %s = %.2f%n", symbol, price);
    }
}
```

`CopyOnWriteArrayList` is used for thread safety — observers can be added/removed concurrently without `ConcurrentModificationException`.

---

### 🟡 B3 — Command

**Problem:** Undo/redo text editor.

```java
interface Command { void execute(); void undo(); }

class TextEditor {
    private final StringBuilder text = new StringBuilder();
    private final Deque<Command> history = new ArrayDeque<>();
    private final Deque<Command> redoStack = new ArrayDeque<>();

    public void executeCommand(Command cmd) {
        cmd.execute();
        history.push(cmd);
        redoStack.clear();   // new action invalidates redo history
    }

    public void undo() {
        if (!history.isEmpty()) {
            Command cmd = history.pop();
            cmd.undo();
            redoStack.push(cmd);
        }
    }

    public void redo() {
        if (!redoStack.isEmpty()) {
            Command cmd = redoStack.pop();
            cmd.execute();
            history.push(cmd);
        }
    }

    // --- Commands ---
    class InsertCommand implements Command {
        private final int pos;
        private final String insertedText;

        InsertCommand(int pos, String text) { this.pos = pos; this.insertedText = text; }

        public void execute() { text.insert(pos, insertedText); }
        public void undo()    { text.delete(pos, pos + insertedText.length()); }
    }

    class DeleteCommand implements Command {
        private final int start, end;
        private String deletedText;

        DeleteCommand(int start, int end) { this.start = start; this.end = end; }

        public void execute() {
            deletedText = text.substring(start, end);
            text.delete(start, end);
        }
        public void undo() { text.insert(start, deletedText); }
    }
}
```

---

### 🟡 B4 — Template Method

**Problem:** Shared exporter lifecycle.

```java
abstract class ReportExporter {

    // Template method — defines the algorithm skeleton; final to prevent override
    public final void export(List<Record> data) {
        openDocument();
        writeHeader();
        writeBody(data);
        writeFooter();
        closeDocument();
    }

    // Abstract — subclasses must provide format-specific implementation
    protected abstract void openDocument();
    protected abstract void writeHeader();
    protected abstract void writeBody(List<Record> data);
    protected abstract void writeFooter();
    protected abstract void closeDocument();
}

class PdfExporter extends ReportExporter {
    protected void openDocument()           { System.out.println("PDF: open"); }
    protected void writeHeader()            { System.out.println("PDF: header"); }
    protected void writeBody(List<Record> d){ System.out.println("PDF: body"); }
    protected void writeFooter()            { System.out.println("PDF: footer"); }
    protected void closeDocument()          { System.out.println("PDF: close"); }
}

class CsvExporter extends ReportExporter {
    protected void openDocument()           { /* no-op for CSV */ }
    protected void writeHeader()            { System.out.println("CSV: column names"); }
    protected void writeBody(List<Record> d){ System.out.println("CSV: rows"); }
    protected void writeFooter()            { /* no-op */ }
    protected void closeDocument()          { /* no-op */ }
}
```

**Abstract vs hook methods:**
- **Abstract** — subclass must override; represents required variation (`writeBody`)
- **Hook** — has a default (often empty) implementation; subclass may override optionally (`openDocument` in CSV — no-op is fine)

---

### 🟡 B5 — Iterator

**Problem:** In-order binary tree iterator without exposing internal structure.

```java
class BinaryTree<T extends Comparable<T>> implements Iterable<T> {
    private Node root;

    private class Node {
        T value; Node left, right;
        Node(T v) { value = v; }
    }

    public void insert(T value) {
        root = insert(root, value);
    }
    private Node insert(Node n, T v) {
        if (n == null) return new Node(v);
        if (v.compareTo(n.value) < 0) n.left  = insert(n.left,  v);
        else                           n.right = insert(n.right, v);
        return n;
    }

    @Override
    public Iterator<T> iterator() {
        return new InOrderIterator();
    }

    private class InOrderIterator implements Iterator<T> {
        private final Deque<Node> stack = new ArrayDeque<>();

        InOrderIterator() { pushLeft(root); }

        private void pushLeft(Node n) {
            while (n != null) { stack.push(n); n = n.left; }
        }

        public boolean hasNext() { return !stack.isEmpty(); }

        public T next() {
            if (!hasNext()) throw new NoSuchElementException();
            Node node = stack.pop();
            pushLeft(node.right);   // push right subtree's leftmost path
            return node.value;
        }
    }
}

// Usage
BinaryTree<Integer> tree = new BinaryTree<>();
Stream.of(5, 3, 7, 1, 4).forEach(tree::insert);
for (int v : tree) System.out.print(v + " ");   // prints: 1 3 4 5 7
```

---

### 🔴 B6 — Chain of Responsibility

**Problem:** HTTP middleware pipeline.

```java
record Request(String path, String token, int callsPerMinute) {}
record Response(int status, String body) {}

abstract class HttpHandler {
    protected HttpHandler next;

    public HttpHandler setNext(HttpHandler next) { this.next = next; return next; }

    protected Response passToNext(Request req) {
        if (next != null) return next.handle(req);
        return new Response(200, "OK");   // end of chain
    }

    public abstract Response handle(Request req);
}

class AuthenticationHandler extends HttpHandler {
    public Response handle(Request req) {
        if (req.token() == null || req.token().isBlank())
            return new Response(401, "Unauthorized");
        return passToNext(req);
    }
}

class RateLimitHandler extends HttpHandler {
    private static final int LIMIT = 100;
    public Response handle(Request req) {
        if (req.callsPerMinute() > LIMIT)
            return new Response(429, "Too Many Requests");
        return passToNext(req);
    }
}

class LoggingHandler extends HttpHandler {
    public Response handle(Request req) {
        System.out.println("Request: " + req.path());
        Response response = passToNext(req);
        System.out.println("Response: " + response.status());
        return response;
    }
}

// Compose the chain
HttpHandler auth  = new AuthenticationHandler();
HttpHandler rate  = new RateLimitHandler();
HttpHandler logger = new LoggingHandler();
auth.setNext(rate).setNext(logger);

Response r = auth.handle(new Request("/api/data", "valid-token", 50));
```

---

### 🔴 B7 — State

**Problem:** Vending machine with explicit state transitions.

```java
interface VendingMachineState {
    void insertMoney(VendingMachine m, double amount);
    void selectProduct(VendingMachine m, String product);
    void dispense(VendingMachine m);
    void cancel(VendingMachine m);
}

class IdleState implements VendingMachineState {
    public void insertMoney(VendingMachine m, double amount) {
        m.setBalance(amount);
        System.out.println("Money inserted: $" + amount);
        m.setState(new HasMoneyState());
    }
    public void selectProduct(VendingMachine m, String p) { System.out.println("Insert money first"); }
    public void dispense(VendingMachine m)                { System.out.println("Insert money first"); }
    public void cancel(VendingMachine m)                  { System.out.println("Nothing to cancel"); }
}

class HasMoneyState implements VendingMachineState {
    public void insertMoney(VendingMachine m, double amount) { m.setBalance(m.getBalance() + amount); }
    public void selectProduct(VendingMachine m, String product) {
        System.out.println("Selected: " + product);
        m.setState(new DispensingState());
    }
    public void dispense(VendingMachine m) { System.out.println("Select a product first"); }
    public void cancel(VendingMachine m) {
        System.out.println("Returning $" + m.getBalance());
        m.setBalance(0);
        m.setState(new IdleState());
    }
}

class DispensingState implements VendingMachineState {
    public void insertMoney(VendingMachine m, double a) { System.out.println("Please wait"); }
    public void selectProduct(VendingMachine m, String p) { System.out.println("Please wait"); }
    public void dispense(VendingMachine m) {
        System.out.println("Dispensing product");
        m.setBalance(0);
        m.setState(m.hasStock() ? new IdleState() : new OutOfStockState());
    }
    public void cancel(VendingMachine m) { System.out.println("Cannot cancel while dispensing"); }
}

class VendingMachine {
    private VendingMachineState state = new IdleState();
    private double balance = 0;
    private int stock = 10;

    public void setState(VendingMachineState s) { this.state = s; }
    public void setBalance(double b)            { this.balance = b; }
    public double getBalance()                  { return balance; }
    public boolean hasStock()                   { return --stock > 0; }

    public void insertMoney(double a) { state.insertMoney(this, a); }
    public void selectProduct(String p) { state.selectProduct(this, p); }
    public void dispense()            { state.dispense(this); }
    public void cancel()              { state.cancel(this); }
}
```

Each state class encapsulates what is valid and what transitions are legal — no giant switch statement in `VendingMachine`.

---

### 🔴 B8 — Visitor

**Problem:** AST with evaluator and printer visitors.

```java
interface AstVisitor<T> {
    T visit(NumberNode node);
    T visit(AddNode node);
    T visit(MultiplyNode node);
}

interface AstNode { <T> T accept(AstVisitor<T> visitor); }

class NumberNode implements AstNode {
    final double value;
    NumberNode(double v) { this.value = v; }
    public <T> T accept(AstVisitor<T> v) { return v.visit(this); }
}

class AddNode implements AstNode {
    final AstNode left, right;
    AddNode(AstNode l, AstNode r) { left = l; right = r; }
    public <T> T accept(AstVisitor<T> v) { return v.visit(this); }
}

class MultiplyNode implements AstNode {
    final AstNode left, right;
    MultiplyNode(AstNode l, AstNode r) { left = l; right = r; }
    public <T> T accept(AstVisitor<T> v) { return v.visit(this); }
}

class EvaluatorVisitor implements AstVisitor<Double> {
    public Double visit(NumberNode n)   { return n.value; }
    public Double visit(AddNode n)      { return n.left.accept(this) + n.right.accept(this); }
    public Double visit(MultiplyNode n) { return n.left.accept(this) * n.right.accept(this); }
}

class PrintVisitor implements AstVisitor<String> {
    public String visit(NumberNode n)   { return String.valueOf(n.value); }
    public String visit(AddNode n)      { return "(" + n.left.accept(this) + " + " + n.right.accept(this) + ")"; }
    public String visit(MultiplyNode n) { return "(" + n.left.accept(this) + " * " + n.right.accept(this) + ")"; }
}

// Usage: (2 + 3) * 4
AstNode tree = new MultiplyNode(
    new AddNode(new NumberNode(2), new NumberNode(3)),
    new NumberNode(4));

System.out.println(new PrintVisitor().visit((MultiplyNode) tree));   // ((2.0 + 3.0) * 4.0)
System.out.println(new EvaluatorVisitor().visit((MultiplyNode) tree)); // 20.0
```

**Double dispatch:**  
`tree.accept(visitor)` calls `visitor.visit(this)` — at this point Java's dynamic dispatch selects the correct `visit` overload based on the runtime type of `this` (the node). This is called double dispatch: the first dispatch selects the `accept` method on the node, the second dispatch selects the `visit` overload on the visitor.

Without Visitor, adding a new operation (e.g., `OptimiserVisitor`) requires modifying every node class. With Visitor, you add a new visitor class only.

---

> 📁 Questions are in `design-patterns-questions.md`
