# Angular — Answers

> Each answer restates the problem briefly, gives a complete explanation or implementation, and highlights the key idea.  
> 💚 Beginner · 🟡 Intermediate · 🔴 Advanced

---

## 1. Components & Templates

---

### 💚 CT1 — Component anatomy

| File | Purpose |
|---|---|
| `*.component.ts` | Component class — logic, properties, lifecycle hooks |
| `*.component.html` | Template — declarative UI with Angular-specific syntax |
| `*.component.css/scss` | Styles scoped to this component via ViewEncapsulation |

The `selector` property defines the custom HTML element name used to embed the component:
```html
<app-header></app-header>   <!-- selector: 'app-header' -->
```
Angular replaces this tag with the component's template at runtime.

---

### 💚 CT2 — Data binding

```typescript
@Component({
  selector: 'app-counter',
  template: `
    <!-- 1. Interpolation: one-way, component → template -->
    <p>Current count: {{ count }}</p>

    <!-- 2. Property binding: one-way, component → DOM property -->
    <button [disabled]="count === 0" (click)="reset()">Reset</button>

    <!-- 3. Event binding: one-way, DOM event → component method -->
    <button (click)="count = count + 1">Increment</button>

    <!-- 4. Two-way binding: NgModel syncs input value ↔ property -->
    <input [(ngModel)]="count" type="number" />
  `
})
export class CounterComponent {
  count = 0;
  reset() { this.count = 0; }
}
```

`[(ngModel)]` is syntactic sugar for `[ngModel]="count" (ngModelChange)="count = $event"`. Requires `FormsModule` to be imported.

---

### 💚 CT3 — Structural directives

```typescript
interface User { id: number; name: string; role: 'admin' | 'viewer'; }

@Component({
  selector: 'app-user-list',
  template: `
    <div *ngIf="users.length > 0; else empty">
      <div *ngFor="let user of users; trackBy: trackById">
        <span [class.admin]="user.role === 'admin'">{{ user.name }}</span>

        <ng-container [ngSwitch]="user.role">
          <span *ngSwitchCase="'admin'">[Admin]</span>
          <span *ngSwitchDefault>[Viewer]</span>
        </ng-container>
      </div>
    </div>

    <ng-template #empty>
      <p>No users found.</p>
    </ng-template>
  `,
  styles: [`.admin { font-weight: bold; color: red; }`]
})
export class UserListComponent {
  users: User[] = [];
  trackById(index: number, user: User): number { return user.id; }
}
```

---

### 🟡 CT4 — Input and Output

```typescript
interface Product { id: number; name: string; price: number; }

@Component({
  selector: 'app-product-card',
  template: `
    <div class="card">
      <h3>{{ product.name }}</h3>
      <p>\${{ product.price }}</p>
      <button (click)="onAddToCart()">Add to Cart</button>
    </div>
  `
})
export class ProductCardComponent {
  @Input()  product!: Product;
  @Output() addToCart = new EventEmitter<Product>();

  onAddToCart() { this.addToCart.emit(this.product); }
}

// Parent template
@Component({
  selector: 'app-shop',
  template: `
    <app-product-card
      *ngFor="let p of products"
      [product]="p"
      (addToCart)="handleAddToCart($event)">
    </app-product-card>
  `
})
export class ShopComponent {
  products: Product[] = [ /* ... */ ];
  handleAddToCart(product: Product) { console.log('Added:', product.name); }
}
```

---

### 🟡 CT5 — Component lifecycle hooks

| Hook | Order | Use case |
|---|---|---|
| `ngOnChanges` | 1st | React to `@Input` changes; receives `SimpleChanges` |
| `ngOnInit` | 2nd | One-time initialization — fetch data, set up subscriptions |
| `ngDoCheck` | 3rd | Custom change detection (costly — avoid unless necessary) |
| `ngAfterContentInit` | 4th | Access projected `@ContentChild` for the first time |
| `ngAfterContentChecked` | 5th | After every check of projected content |
| `ngAfterViewInit` | 6th | Access `@ViewChild` — DOM/child components fully rendered |
| `ngAfterViewChecked` | 7th | After every check of the view |
| `ngOnDestroy` | Last | Unsubscribe, clear timers, detach event listeners |

**Key use cases:**
- `ngOnInit` — `this.userService.getUser(this.id).subscribe(...)` (not in constructor — inputs aren't set yet)
- `ngOnChanges` — reset state when `@Input` product changes
- `ngOnDestroy` — `this.subscription.unsubscribe()` or `this.destroy$.next()`
- `ngAfterViewInit` — call `this.chart.draw()` on a `@ViewChild` chart component

---

### 🟡 CT6 — Content projection

```typescript
@Component({
  selector: 'app-card',
  template: `
    <div class="card">
      <div class="card-header">
        <ng-content select="[card-header]"></ng-content>
      </div>
      <div class="card-body">
        <ng-content select="[card-body]"></ng-content>
      </div>
      <div class="card-footer">
        <ng-content select="[card-footer]"></ng-content>
      </div>
    </div>
  `
})
export class CardComponent { }

// Usage
@Component({
  template: `
    <app-card>
      <h2 card-header>User Profile</h2>
      <p card-body>Name: Alice, Role: Admin</p>
      <button card-footer>Edit</button>
    </app-card>
  `
})
export class ProfilePage { }
```

`select` accepts any CSS selector — attribute selector `[card-header]`, class `.card-header`, or element `h2`. Default `<ng-content>` (no `select`) catches everything not matched by other slots.

---

### 🟡 CT7 — Custom pipe

```typescript
@Pipe({ name: 'truncate', pure: true })
export class TruncatePipe implements PipeTransform {
  transform(value: string, limit: number = 50): string {
    if (!value) return '';
    return value.length <= limit ? value : value.slice(0, limit) + '...';
  }
}

// Template usage
// {{ product.description | truncate }}         → uses default 50
// {{ product.description | truncate:100 }}     → custom limit
// {{ product.description | truncate:20 | uppercase }}  → chain pipes
```

**Pure pipe:** Re-evaluated only when the input reference changes. Use `pure: false` for pipes that depend on mutable state (rare — has performance cost because Angular evaluates it on every change detection cycle).

---

### 🔴 CT8 — Change detection

**Default:** Angular checks every component in the tree on every event (click, timer, HTTP response). Fast for most apps but can be slow with hundreds of components.

**OnPush:** Angular skips a component and its subtree unless:
1. An `@Input` reference changes (not just mutation)
2. An event originates from the component or its descendants
3. An `async` pipe resolves a new value
4. `ChangeDetectorRef.markForCheck()` is called manually

```typescript
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  ...
})
export class ProductCardComponent { }
```

**Angular Signals (16+):** A `signal` is a reactive primitive. Components that read a signal are automatically tracked — Angular re-renders only the exact components that consumed a changed signal, with no change detection traversal at all:

```typescript
count = signal(0);
double = computed(() => this.count() * 2);
```

---

### 🔴 CT9 — ViewChild and ContentChild

| Decorator | What it queries | Available in |
|---|---|---|
| `@ViewChild` | Elements/components in the component's own template | `ngAfterViewInit` |
| `@ContentChild` | Elements/components projected via `<ng-content>` | `ngAfterContentInit` |

```typescript
@Component({ selector: 'app-timer', template: `<span>{{ seconds }}</span>` })
export class TimerComponent {
  seconds = 0;
  start() { setInterval(() => this.seconds++, 1000); }
}

@Component({
  selector: 'app-dashboard',
  template: `<app-timer #timer></app-timer><button (click)="startTimer()">Start</button>`
})
export class DashboardComponent implements AfterViewInit {
  @ViewChild('timer') timer!: TimerComponent;

  ngAfterViewInit() {
    // @ViewChild is populated here — not in ngOnInit
  }

  startTimer() { this.timer.start(); }
}
```

---

## 2. Services & Dependency Injection

---

### 💚 DI1 — Creating a service

```typescript
@Injectable({ providedIn: 'root' })
export class UserService { }
```

`providedIn: 'root'` registers the service in the root injector. Angular creates a single instance shared application-wide and tree-shakes the service if nothing injects it (smaller bundle).

Providing in a module's `providers` array:
```typescript
@NgModule({ providers: [UserService] })
export class UserModule { }
```

This also creates one instance, but it is **not tree-shaken** — always included in the bundle whether used or not. Use this when you need a service to be available to a specific feature module only (before standalone components made this simpler).

---

### 💚 DI2 — Injection tokens

```typescript
export interface AppConfig { apiUrl: string; maxRetries: number; }

export const APP_CONFIG = new InjectionToken<AppConfig>('AppConfig');

// Provide in app.config.ts or @NgModule
export const appConfig: ApplicationConfig = {
  providers: [
    {
      provide: APP_CONFIG,
      useValue: { apiUrl: 'https://api.example.com', maxRetries: 3 }
    }
  ]
};

// Inject in a component or service
@Injectable({ providedIn: 'root' })
export class ApiService {
  constructor(@Inject(APP_CONFIG) private config: AppConfig) { }
  getBaseUrl() { return this.config.apiUrl; }
}
```

---

### 🟡 DI3 — Hierarchical injection

Angular has a tree of injectors mirroring the component tree. When a component requests a service:
1. Its own injector is checked first
2. Then parent component injector
3. Then module injector
4. Then root injector

Providing a service in a component's `providers` creates a **new, separate instance** for that component and all its descendants:

```typescript
@Component({
  selector: 'app-form',
  providers: [FormStateService]   // new instance per <app-form> — not shared globally
})
export class FormComponent { }
```

**Use case:** A wizard form with multiple steps where each wizard instance (e.g., two wizards on the same page) needs its own isolated state.

---

### 🟡 DI4 — useClass, useValue, useFactory

```typescript
abstract class LoggerService { abstract log(msg: string): void; }

class ConsoleLogger extends LoggerService {
  log(msg: string) { console.log(msg); }
}

class SilentLogger extends LoggerService {
  log(_: string) { /* no-op */ }
}

// useClass — substitute a different implementation
{ provide: LoggerService, useClass: ConsoleLogger }

// useValue — inject a pre-built instance
const silentLogger = new SilentLogger();
{ provide: LoggerService, useValue: silentLogger }

// useFactory — create the instance dynamically (e.g., based on environment)
{
  provide: LoggerService,
  useFactory: (env: EnvironmentService) =>
    env.isProduction() ? new SilentLogger() : new ConsoleLogger(),
  deps: [EnvironmentService]
}
```

---

## 3. Routing

---

### 💚 RO1 — Basic routing

```typescript
// app.routes.ts
export const routes: Routes = [
  { path: '',            component: HomeComponent },
  { path: 'products',   component: ProductListComponent },
  { path: 'products/:id', component: ProductDetailComponent },
  { path: '**',         redirectTo: '' }   // wildcard — must be last
];

// app.config.ts
export const appConfig: ApplicationConfig = {
  providers: [provideRouter(routes)]
};
```

```html
<!-- app.component.html -->
<nav>
  <a routerLink="/">Home</a>
  <a routerLink="/products">Products</a>
</nav>
<router-outlet></router-outlet>
```

---

### 💚 RO2 — Route parameters

```typescript
@Component({ ... })
export class ProductDetailComponent implements OnInit {
  product?: Product;

  constructor(
    private route: ActivatedRoute,
    private productService: ProductService
  ) { }

  ngOnInit() {
    // Snapshot — safe when component is never reused with a different id
    const id = Number(this.route.snapshot.paramMap.get('id'));
    this.productService.getProduct(id).subscribe(p => this.product = p);

    // Observable — required when navigating from /products/1 to /products/2
    // without destroying the component (same route, different params)
    this.route.paramMap.pipe(
      map(params => Number(params.get('id'))),
      switchMap(id => this.productService.getProduct(id))
    ).subscribe(p => this.product = p);
  }
}
```

**When to prefer each:**
- **Snapshot** — simple; component is always destroyed when navigating to a different id
- **Observable** — necessary when the same component instance is reused (navigation between sibling detail pages)

---

### 🟡 RO3 — Lazy loading

```typescript
// app.routes.ts (Angular 15+ syntax)
export const routes: Routes = [
  {
    path: 'products',
    loadChildren: () =>
      import('./products/products.routes').then(m => m.PRODUCT_ROUTES)
  }
];

// products/products.routes.ts
export const PRODUCT_ROUTES: Routes = [
  { path: '',   component: ProductListComponent },
  { path: ':id', component: ProductDetailComponent }
];
```

**Performance benefits:**
- The `products` bundle is only downloaded when the user first navigates there
- Initial app bundle is smaller → faster Time to Interactive
- Angular's router prefetches lazy modules in the background after initial load (via `PreloadAllModules` strategy)

---

### 🟡 RO4 — Route guards

```typescript
// Functional CanActivate (Angular 15+)
export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isLoggedIn()) return true;

  return router.createUrlTree(['/login'], { queryParams: { returnUrl: state.url } });
};

// Functional CanDeactivate
export interface CanDeactivateComponent {
  canDeactivate(): boolean;
}

export const dirtyFormGuard: CanDeactivateFn<CanDeactivateComponent> = (component) => {
  if (component.canDeactivate()) return true;
  return confirm('You have unsaved changes. Leave anyway?');
};

// Apply to routes
{
  path: 'dashboard',
  component: DashboardComponent,
  canActivate: [authGuard]
}
{
  path: 'profile/edit',
  component: EditProfileComponent,
  canDeactivate: [dirtyFormGuard]
}
```

---

### 🟡 RO5 — Resolvers

```typescript
// products.resolver.ts
export const productResolver: ResolveFn<Product> = (route, state) => {
  const productService = inject(ProductService);
  const id = Number(route.paramMap.get('id'));
  return productService.getProduct(id);
};

// Route config
{ path: ':id', component: ProductDetailComponent, resolve: { product: productResolver } }

// Component — data already available in ngOnInit
@Component({ ... })
export class ProductDetailComponent implements OnInit {
  product!: Product;

  constructor(private route: ActivatedRoute) { }

  ngOnInit() {
    this.product = this.route.snapshot.data['product'];
  }
}
```

**Trade-off:** Resolvers delay navigation until data arrives — the user sees the old page while loading. Prefer loading states within the component for perceived performance.

---

## 4. Forms

---

### 💚 F1 — Template-driven vs Reactive

| | Template-driven | Reactive |
|---|---|---|
| Setup | Minimal — directives in template | More verbose — explicit `FormGroup` in class |
| Access in class | Via `@ViewChild` or `NgForm` | Direct — `this.form.value` |
| Testing | Harder (requires DOM) | Easy — pure TypeScript |
| Dynamic fields | Awkward | First-class via `FormArray` |
| Validation | HTML attributes + directives | Validator functions, composable |

**Choose reactive when:**
- Form structure is dynamic (add/remove fields at runtime)
- Complex cross-field validation
- You want testable logic in TypeScript, not the template

---

### 🟡 F2 — Reactive form with validation

```typescript
function passwordMatchValidator(group: AbstractControl): ValidationErrors | null {
  const pass    = group.get('password')?.value;
  const confirm = group.get('confirmPassword')?.value;
  return pass === confirm ? null : { passwordMismatch: true };
}

@Component({
  template: `
    <form [formGroup]="form" (ngSubmit)="onSubmit()">
      <input formControlName="username" placeholder="Username" />
      <span *ngIf="form.get('username')?.hasError('minlength')">Min 3 characters</span>

      <input formControlName="email" placeholder="Email" />
      <input formControlName="password" type="password" />
      <input formControlName="confirmPassword" type="password" />
      <span *ngIf="form.hasError('passwordMismatch')">Passwords do not match</span>

      <button type="submit" [disabled]="form.invalid">Register</button>
    </form>
  `
})
export class RegisterComponent {
  form = inject(FormBuilder).group({
    username:        ['', [Validators.required, Validators.minLength(3)]],
    email:           ['', [Validators.required, Validators.email]],
    password:        ['', [Validators.required, Validators.minLength(8)]],
    confirmPassword: ['', Validators.required]
  }, { validators: passwordMatchValidator });

  onSubmit() {
    if (this.form.valid) console.log(this.form.value);
  }
}
```

---

### 🟡 F3 — Dynamic form fields

```typescript
@Component({
  template: `
    <form [formGroup]="form">
      <div formArrayName="phoneNumbers">
        <div *ngFor="let phone of phoneNumbers.controls; let i = index">
          <input [formControlName]="i" placeholder="Phone {{ i + 1 }}" />
          <button type="button" (click)="removePhone(i)">Remove</button>
        </div>
      </div>
      <button type="button" (click)="addPhone()">+ Add Phone</button>
    </form>
  `
})
export class ProfileComponent {
  private fb = inject(FormBuilder);

  form = this.fb.group({
    phoneNumbers: this.fb.array([this.fb.control('')])
  });

  get phoneNumbers(): FormArray {
    return this.form.get('phoneNumbers') as FormArray;
  }

  addPhone() {
    this.phoneNumbers.push(this.fb.control(''));
  }

  removePhone(index: number) {
    this.phoneNumbers.removeAt(index);
  }
}
```

---

### 🟡 F4 — Custom async validator

```typescript
export function uniqueUsernameValidator(userService: UserService): AsyncValidatorFn {
  return (control: AbstractControl): Observable<ValidationErrors | null> => {
    if (!control.value) return of(null);

    return timer(300).pipe(   // debounce to avoid calling API on every keystroke
      switchMap(() => userService.checkUsername(control.value)),
      map(isTaken => isTaken ? { usernameTaken: true } : null),
      catchError(() => of(null))   // on error, treat as valid (don't block form)
    );
  };
}

// Usage
username: ['', [Validators.required], [uniqueUsernameValidator(userService)]]
//                     sync validators ↑       async validators ↑
```

---

### 🔴 F5 — ControlValueAccessor

```typescript
@Component({
  selector: 'app-star-rating',
  template: `
    <span *ngFor="let star of stars; let i = index"
          (click)="setValue(i + 1)"
          [class.filled]="i < value">★</span>
  `,
  providers: [{
    provide: NG_VALUE_ACCESSOR,
    useExisting: forwardRef(() => StarRatingComponent),
    multi: true
  }]
})
export class StarRatingComponent implements ControlValueAccessor {
  stars = [1, 2, 3, 4, 5];
  value = 0;
  disabled = false;

  private onChange = (_: number) => {};
  private onTouched = () => {};

  writeValue(val: number) { this.value = val || 0; }

  registerOnChange(fn: (v: number) => void) { this.onChange = fn; }

  registerOnTouched(fn: () => void) { this.onTouched = fn; }

  setDisabledState(isDisabled: boolean) { this.disabled = isDisabled; }

  setValue(rating: number) {
    if (!this.disabled) {
      this.value = rating;
      this.onChange(rating);
      this.onTouched();
    }
  }
}

// Used in reactive form
form = this.fb.group({ rating: [0, Validators.min(1)] });
// <app-star-rating formControlName="rating"></app-star-rating>
```

---

## 5. HTTP & Observables

---

### 💚 H1 — HttpClient basics

```typescript
interface User { id: number; name: string; email: string; }

@Injectable({ providedIn: 'root' })
export class UserService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = 'https://api.example.com/users';

  getUser(id: number): Observable<User> {
    return this.http.get<User>(`${this.apiUrl}/${id}`);
  }

  createUser(user: Omit<User, 'id'>): Observable<User> {
    return this.http.post<User>(this.apiUrl, user);
  }

  deleteUser(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }
}
```

---

### 💚 H2 — RxJS operators

| Operator | Description | Use case |
|---|---|---|
| `map` | Transform each emitted value | Parse/reshape API response |
| `switchMap` | Map to inner observable; cancels previous | Search — cancels stale HTTP request |
| `mergeMap` | Map to inner observable; runs all concurrently | Fire-and-forget parallel requests |
| `catchError` | Intercept errors in the stream | Return fallback value, log, rethrow |
| `takeUntil` | Complete when another observable emits | Unsubscribe on component destroy |

```typescript
// switchMap example — cancels previous search request when user types
searchControl.valueChanges.pipe(
  debounceTime(300),
  distinctUntilChanged(),
  switchMap(query => this.productService.search(query)),
  takeUntil(this.destroy$)
).subscribe(results => this.results = results);
```

---

### 🟡 H3 — HTTP Interceptor

```typescript
// auth.interceptor.ts
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const authService = inject(AuthService);
  const token = authService.getToken();

  const authReq = token
    ? req.clone({ setHeaders: { Authorization: `Bearer ${token}` } })
    : req;

  return next(authReq);
};

// error.interceptor.ts
export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  return next(req).pipe(
    catchError((err: HttpErrorResponse) => {
      console.error(`HTTP ${err.status} on ${req.url}:`, err.message);
      return throwError(() => err);   // rethrow so subscribers can handle it too
    })
  );
};

// Register in app.config.ts
export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(
      withInterceptors([authInterceptor, errorInterceptor])
    )
  ]
};
```

---

### 🟡 H4 — Search with debounce

```typescript
@Component({
  template: `
    <input [formControl]="searchControl" placeholder="Search products..." />
    <div *ngFor="let r of results">{{ r.name }}</div>
  `
})
export class SearchComponent implements OnInit, OnDestroy {
  searchControl = new FormControl('');
  results: Product[] = [];
  private destroy$ = new Subject<void>();

  constructor(private productService: ProductService) { }

  ngOnInit() {
    this.searchControl.valueChanges.pipe(
      debounceTime(300),           // wait 300ms after last keystroke
      distinctUntilChanged(),      // ignore if value didn't change
      filter(query => !!query && query.length > 0),   // skip empty queries
      switchMap(query =>           // cancel previous in-flight request
        this.productService.search(query!).pipe(
          catchError(() => of([]))   // on error, return empty results
        )
      ),
      takeUntil(this.destroy$)     // auto-unsubscribe on destroy
    ).subscribe(results => this.results = results);
  }

  ngOnDestroy() { this.destroy$.next(); this.destroy$.complete(); }
}
```

---

### 🟡 H5 — Caching with shareReplay

```typescript
@Injectable({ providedIn: 'root' })
export class CountryService {
  private readonly http = inject(HttpClient);
  private countries$?: Observable<Country[]>;

  getCountries(): Observable<Country[]> {
    if (!this.countries$) {
      this.countries$ = this.http.get<Country[]>('/api/countries').pipe(
        shareReplay(1)   // cache the last emitted value; replay it to new subscribers
      );
    }
    return this.countries$;
  }
}
```

`shareReplay(1)` multicasts the HTTP response to all subscribers — the HTTP request fires only once regardless of how many components call `getCountries()`. Subsequent subscriptions receive the cached value immediately.

---

### 🔴 H6 — Multiple concurrent requests

```typescript
getUsersById(ids: number[]): Observable<User[]> {
  const requests = ids.map(id => this.http.get<User>(`/api/users/${id}`));
  return forkJoin(requests);   // fires all requests concurrently; emits when ALL complete
}

// forkJoin preserves order — results[0] corresponds to ids[0]
this.userService.getUsersById([1, 2, 3]).subscribe(users => {
  // users: [User1, User2, User3] in original order
});
```

`forkJoin` is the RxJS equivalent of `Promise.all`. For "fire-and-forget" parallel work where order doesn't matter and you want to process results as they arrive, use `mergeMap` instead.

---

## 6. Performance & Architecture

---

### 🟡 A1 — Smart vs dumb components

**Smart (container) components:**
- Inject services, manage state, subscribe to observables
- Know about the application's domain
- Ugly but necessary — glue between data layer and UI

**Dumb (presentational) components:**
- Receive data via `@Input()`, emit events via `@Output()`
- Know nothing about services or state management
- Pure functions of their inputs — same input always renders the same output

**Interaction with OnPush:**  
Dumb components are perfect candidates for `OnPush` — they only re-render when their `@Input` reference changes (new object). Because they don't hold mutable state, this is always correct.

```typescript
// Dumb component with OnPush
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  selector: 'app-user-card',
  template: `<p>{{ user.name }}</p>`
})
export class UserCardComponent {
  @Input() user!: User;
}
```

---

### 🟡 A2 — TrackBy in ngFor

Without `trackBy`, Angular re-creates the entire DOM list on any data change (even if only one item changed).

```typescript
@Component({
  template: `
    <!-- Without trackBy — replaces all DOM elements on every change -->
    <div *ngFor="let user of users">{{ user.name }}</div>

    <!-- With trackBy — only adds/removes changed elements -->
    <div *ngFor="let user of users; trackBy: trackById">{{ user.name }}</div>
  `
})
export class UserListComponent {
  users: User[] = [];

  trackById(index: number, user: User): number {
    return user.id;   // Angular uses this identity to decide which DOM nodes to reuse
  }
}
```

**Why it matters:** If you refresh 100 users from an API and only one changed, without `trackBy` Angular destroys and recreates 100 DOM nodes. With `trackBy`, it reuses 99 nodes and only updates the changed one.

---

### 🔴 A3 — Angular signals

```typescript
// Signal-based rewrite
@Component({
  selector: 'app-cart',
  template: `
    <div *ngFor="let item of items()">{{ item.name }} x{{ item.quantity }}</div>
    <strong>Total: \${{ totalPrice() }}</strong>
    <button (click)="addItem(sampleItem)">Add</button>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class CartComponent {
  items = signal<CartItem[]>([]);   // writable signal

  totalPrice = computed(() =>       // derived value — re-evaluated only when items changes
    this.items().reduce((sum, i) => sum + i.price * i.quantity, 0)
  );

  addItem(item: CartItem) {
    this.items.update(current => [...current, item]);  // immutable update
  }
}
```

**Advantages over plain properties:**
- `computed` is lazy and memoized — only recalculated when `items` changes
- Angular tracks signal reads at the template level — re-renders only the components that read a changed signal
- No `async` pipe or manual subscription management needed
- Works seamlessly with `OnPush` change detection

`effect(() => { console.log(this.items()); })` runs side effects whenever tracked signals change.

---

### 🔴 A4 — NgRx state management

**When to introduce NgRx:**
- Multiple components need the same data (user profile, permissions)
- Complex async operations with error states
- Undo/redo or time-travel debugging needed
- Team larger than ~5 developers — enforces consistent data flow

**Four core concepts:**

```
Component                    NgRx Store
────────                     ──────────
dispatch(action) ──────────► Reducer ──► new state
                             ▲               │
Effect ◄─────────────────────┘               ▼
(HTTP, async)                          Component reads via selector
```

| Concept | Role |
|---|---|
| **Store** | Single immutable state object for the whole app |
| **Action** | Describes what happened: `{ type: '[Products] Load Success', products: [...] }` |
| **Reducer** | Pure function: `(state, action) => newState` |
| **Effect** | Handles side effects (HTTP); dispatches success/failure actions |

```typescript
// Actions
export const loadProducts = createAction('[Products] Load');
export const loadProductsSuccess = createAction('[Products] Load Success',
  props<{ products: Product[] }>());

// Reducer
export const productsReducer = createReducer(
  { products: [], loading: false } as ProductsState,
  on(loadProducts, state => ({ ...state, loading: true })),
  on(loadProductsSuccess, (state, { products }) =>
    ({ ...state, products, loading: false }))
);

// Effect
@Injectable()
export class ProductsEffects {
  loadProducts$ = createEffect(() =>
    this.actions$.pipe(
      ofType(loadProducts),
      switchMap(() => this.productService.getAll().pipe(
        map(products => loadProductsSuccess({ products }))
      ))
    )
  );
  constructor(private actions$: Actions, private productService: ProductService) { }
}
```

---

### 🔴 A5 — Standalone components

Standalone components declare their own imports — no `NgModule` wrapper needed.

```typescript
// Module-based (before)
@NgModule({
  declarations: [ProductCardComponent],
  imports: [CommonModule],
  exports: [ProductCardComponent]
})
export class ProductCardModule { }

// Standalone (Angular 14+)
@Component({
  standalone: true,
  selector: 'app-product-card',
  imports: [NgIf, NgFor, CurrencyPipe],   // import what you need directly
  template: `<p *ngIf="product">{{ product.name | currency }}</p>`
})
export class ProductCardComponent {
  @Input() product?: Product;
}
```

Bootstrap a standalone app:
```typescript
// main.ts
bootstrapApplication(AppComponent, {
  providers: [
    provideRouter(routes),
    provideHttpClient(withInterceptors([authInterceptor]))
  ]
});
```

**Advantages:**
- No boilerplate `NgModule` files — fewer files, less cognitive overhead
- Lazy loading a single component (not just a module) is straightforward
- Explicit imports make dependencies visible at the component level
- Better tree-shaking — only imported items are bundled

---

> 📁 Questions are in `angular-questions.md`
