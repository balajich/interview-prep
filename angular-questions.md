# Angular — Practice Questions

> **How to use:** Work through each question on your own before opening the answers file.  
> Questions mix conceptual explanation with TypeScript/template implementation.  
> 💚 Beginner · 🟡 Intermediate · 🔴 Advanced

---

## Table of Contents
1. [Components & Templates](#1-components--templates)
2. [Services & Dependency Injection](#2-services--dependency-injection)
3. [Routing](#3-routing)
4. [Forms](#4-forms)
5. [HTTP & Observables](#5-http--observables)
6. [Performance & Architecture](#6-performance--architecture)

---

## 1. Components & Templates

### 💚 Beginner

**CT1 — Component anatomy**  
List the three files that make up a typical Angular component and explain the purpose of each. What does the `selector` property in `@Component` do?

---

**CT2 — Data binding**  
Show all four types of Angular data binding using a `CounterComponent` with a `count` property and a `reset()` method:
1. Interpolation
2. Property binding
3. Event binding
4. Two-way binding

```typescript
@Component({
  selector: 'app-counter',
  template: `<!-- implement all four binding types -->`
})
export class CounterComponent {
  count = 0;
  reset() { this.count = 0; }
}
```

---

**CT3 — Structural directives**  
Show how to use `*ngIf`, `*ngFor`, and `*ngSwitch` in a template. Display a list of `User` objects; hide the list if it is empty and show a "No users" message instead; highlight users with `role === 'admin'`.

```typescript
interface User { id: number; name: string; role: 'admin' | 'viewer'; }
// write the template
```

---

### 🟡 Intermediate

**CT4 — Input and Output**  
Build a `ProductCardComponent` that:
- Receives a `Product` object via `@Input()`
- Emits an `addToCart` event via `@Output()` when the button is clicked
- Show the parent template wiring up both

```typescript
interface Product { id: number; name: string; price: number; }

@Component({ selector: 'app-product-card', template: `<!-- implement -->` })
export class ProductCardComponent {
  // add @Input and @Output
}
```

---

**CT5 — Component lifecycle hooks**  
List the lifecycle hooks in the order they fire and give a concrete use case for `ngOnInit`, `ngOnChanges`, `ngOnDestroy`, and `ngAfterViewInit`.

---

**CT6 — Content projection**  
Implement a reusable `CardComponent` that accepts projected content in three named slots: `header`, `body`, and `footer`. Show the component definition and a usage example.

```typescript
@Component({
  selector: 'app-card',
  template: `<!-- use ng-content with select -->`
})
export class CardComponent { }
```

---

**CT7 — Custom pipe**  
Write a pipe `truncate` that shortens a string to `n` characters (default 50) and appends `"..."`. Make it pure. Show how to use it in a template.

```typescript
@Pipe({ name: 'truncate' })
export class TruncatePipe implements PipeTransform {
  transform(value: string, limit?: number): string { }
}
```

---

### 🔴 Advanced

**CT8 — Change detection**  
Compare `ChangeDetectionStrategy.Default` vs `OnPush`. Under what conditions does OnPush re-render a component? What Angular signals feature can eliminate change detection checks entirely?

---

**CT9 — ViewChild and ContentChild**  
Explain `@ViewChild` vs `@ContentChild`. Write a component that uses `@ViewChild` to call a method on a child component imperatively after the view initializes.

```typescript
// implement parent and child components
```

---

## 2. Services & Dependency Injection

### 💚 Beginner

**DI1 — Creating a service**  
What does `providedIn: 'root'` mean in `@Injectable`? How does it differ from providing a service in a module's `providers` array?

---

**DI2 — Injection tokens**  
Show how to inject a plain string or configuration object (not a class) into a component using `InjectionToken`.

```typescript
// define APP_CONFIG token and provide it
```

---

### 🟡 Intermediate

**DI3 — Hierarchical injection**  
Explain Angular's hierarchical injector tree. What happens when a component provides a service in its own `providers` array? Give a use case where per-component instances are desirable.

---

**DI4 — useClass, useValue, useFactory**  
Show examples of all three provider alternatives (`useClass`, `useValue`, `useFactory`) for the same `LoggerService` token.

```typescript
// implement all three provider types
```

---

## 3. Routing

### 💚 Beginner

**RO1 — Basic routing**  
Configure routes for `/`, `/products`, `/products/:id`, and a wildcard that redirects to `/`. Show how to use `<router-outlet>` and `[routerLink]`.

---

**RO2 — Route parameters**  
In a `ProductDetailComponent`, read the `:id` route parameter using `ActivatedRoute`. Show both the snapshot approach and the observable approach, and explain when to prefer each.

```typescript
@Component({ ... })
export class ProductDetailComponent implements OnInit {
  // implement both approaches
}
```

---

### 🟡 Intermediate

**RO3 — Lazy loading**  
Configure a `products` feature module to be lazy-loaded when the user navigates to `/products`. What are the performance benefits, and what `loadChildren` syntax does Angular 15+ use?

---

**RO4 — Route guards**  
Implement an `AuthGuard` using the modern functional guard API (`CanActivateFn`) that redirects unauthenticated users to `/login`. Also show `CanDeactivateFn` for a form that warns before leaving.

```typescript
// implement AuthGuard as CanActivateFn
// implement DirtyFormGuard as CanDeactivateFn
```

---

**RO5 — Resolvers**  
Implement a route resolver that fetches a `Product` before the route activates, so the component always has data on init.

```typescript
export const productResolver: ResolveFn<Product> = (route, state) => { }
```

---

## 4. Forms

### 💚 Beginner

**F1 — Template-driven vs Reactive**  
Compare template-driven and reactive forms. List two advantages of each approach and describe a scenario where you would choose reactive forms.

---

### 🟡 Intermediate

**F2 — Reactive form with validation**  
Build a registration form with: `username` (required, min 3 chars), `email` (required, valid email format), `password` (required, min 8 chars), `confirmPassword`. Add a cross-field validator that checks that `password === confirmPassword`.

```typescript
@Component({ ... })
export class RegisterComponent {
  form!: FormGroup;
  // implement form with FormBuilder and validators
  // implement cross-field validator
}
```

---

**F3 — Dynamic form fields**  
Show how to use `FormArray` to allow users to add and remove phone numbers dynamically.

```typescript
@Component({ ... })
export class ProfileComponent {
  form!: FormGroup;
  get phoneNumbers(): FormArray { }
  addPhone() { }
  removePhone(index: number) { }
}
```

---

**F4 — Custom validator**  
Write a custom async validator that checks whether a username is already taken by calling `UserService.checkUsername(username): Observable<boolean>`. Apply it to the username field.

```typescript
export function uniqueUsernameValidator(userService: UserService): AsyncValidatorFn {
  // implement
}
```

---

### 🔴 Advanced

**F5 — ControlValueAccessor**  
Implement a custom `StarRatingComponent` (1–5 stars) that integrates with Angular forms (both template-driven and reactive) by implementing `ControlValueAccessor`.

```typescript
@Component({
  selector: 'app-star-rating',
  template: `<!-- star rating UI -->`
})
export class StarRatingComponent implements ControlValueAccessor {
  // implement writeValue, registerOnChange, registerOnTouched, setDisabledState
}
```

---

## 5. HTTP & Observables

### 💚 Beginner

**H1 — HttpClient basics**  
Show how to make GET, POST, and DELETE requests using `HttpClient`. Return typed responses.

```typescript
interface User { id: number; name: string; email: string; }

@Injectable({ providedIn: 'root' })
export class UserService {
  // implement getUser(id), createUser(user), deleteUser(id)
}
```

---

**H2 — RxJS operators**  
Explain `map`, `switchMap`, `mergeMap`, `catchError`, and `takeUntil`. For each, give a one-line description and a use case.

---

### 🟡 Intermediate

**H3 — HTTP Interceptor**  
Implement an `AuthInterceptor` using the modern functional interceptor API that attaches a Bearer token from `AuthService` to every outgoing request, and an `ErrorInterceptor` that logs errors and rethrows.

```typescript
export const authInterceptor: HttpInterceptorFn = (req, next) => { }
export const errorInterceptor: HttpInterceptorFn = (req, next) => { }
```

---

**H4 — Search with debounce**  
Implement a search box that calls an API only after the user stops typing for 300ms, cancels the previous in-flight request when a new character is typed, and ignores empty queries.

```typescript
@Component({ ... })
export class SearchComponent implements OnInit, OnDestroy {
  searchControl = new FormControl('');
  results: Product[] = [];
  // implement using RxJS operators
}
```

---

**H5 — Caching with shareReplay**  
Implement a service that fetches a list of countries once and caches the result for all subscribers (no repeat HTTP call).

```typescript
@Injectable({ providedIn: 'root' })
export class CountryService {
  private countries$: Observable<Country[]> | null = null;
  getCountries(): Observable<Country[]> { }
}
```

---

### 🔴 Advanced

**H6 — Handling multiple concurrent requests**  
Implement a method that fetches user details for an array of user IDs in parallel (all at once) and returns them as a single array, preserving the original order.

```typescript
getUsersById(ids: number[]): Observable<User[]> { }
```

---

## 6. Performance & Architecture

### 🟡 Intermediate

**A1 — Smart vs dumb components**  
Explain the smart (container) / dumb (presentational) component pattern. What are the benefits, and how does it interact with `OnPush` change detection?

---

**A2 — TrackBy in ngFor**  
What is `trackBy` in `*ngFor`? Show an example where omitting it causes unnecessary DOM re-renders and how adding it fixes the problem.

```typescript
// implement trackBy function and template usage
```

---

### 🔴 Advanced

**A3 — Angular signals**  
Explain Angular Signals (`signal`, `computed`, `effect`) introduced in Angular 16+. Rewrite the following component to use signals instead of plain properties, and explain what advantage this gives.

```typescript
// Original (to rewrite)
@Component({ ... })
export class CartComponent {
  items: CartItem[] = [];
  get totalPrice(): number {
    return this.items.reduce((sum, i) => sum + i.price * i.quantity, 0);
  }
  addItem(item: CartItem) { this.items = [...this.items, item]; }
}
```

---

**A4 — NgRx state management**  
When would you introduce NgRx into an Angular app? Describe the four core concepts (Store, Action, Reducer, Effect) and draw the data flow diagram in text. Show a minimal action + reducer for a `products` slice.

---

**A5 — Standalone components**  
What are standalone components (Angular 14+)? How do they differ from NgModule-based components? Show converting a module-based component to standalone and bootstrapping a standalone app.

---

> 📁 Answers are in `angular-answers.md`
