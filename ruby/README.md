# Ruby Monkey Patching — Dry Run & Rollback

Demonstrates how to use `class_eval` to intercept side effects in three real
frameworks — ActiveRecord, GraphQL, and Karafka — without touching the original
source code.

Each patch implements the same three-phase pattern:

| Phase | What happens |
|---|---|
| **Dry run** | Intercept the action, capture a before-snapshot, abort the side effect |
| **Real run** | Let the action execute normally |
| **Rollback** | Use the Phase 1 snapshot to restore the original state |

Karafka is capture-only (Phase 1 + 2); rollback is out of scope.

---

## Prerequisites

- Docker + Docker Compose

That's it. Ruby, Jupyter, and all gems run inside the container.

---

## First-time setup

```bash
cd ruby/
docker compose build
```

This builds the image once. Subsequent runs reuse it unless you change the
`Dockerfile` or `Gemfile`.

---

## Running the demos

All commands are run from the `ruby/` directory.

### ActiveRecord

```bash
docker compose run --rm lab bundle exec ruby active_record_monkey_patching/main.rb
```

### GraphQL

```bash
docker compose run --rm lab bundle exec ruby graphql_monkey_patching/main.rb
```

### Karafka

```bash
docker compose run --rm lab bundle exec ruby kafka_monkey_patching/main.rb
```

### All three together

```bash
docker compose run --rm lab bundle exec ruby generic_demo_app/main.rb
```

---

## Querying the database during a demo

Each demo writes a `demo.db` file next to its `setup.rb`. The database is
recreated fresh on every run (`force: :cascade`).

Open a second terminal and query while the demo is running:

```bash
# ActiveRecord demo
docker compose run --rm lab sqlite3 active_record_monkey_patching/demo.db

# GraphQL demo
docker compose run --rm lab sqlite3 graphql_monkey_patching/demo.db

# Combined demo
docker compose run --rm lab sqlite3 generic_demo_app/demo.db
```

Useful queries once inside the sqlite3 shell:

```sql
SELECT name, age FROM users;
.quit
```

Or as a one-liner:

```bash
docker compose run --rm lab \
  sqlite3 active_record_monkey_patching/demo.db "SELECT name, age FROM users;"
```

---

## Jupyter notebooks (interactive presentation)

Start the notebook server:

```bash
docker compose up
```

Then open **http://localhost:8888** in your browser.

Run notebooks in order:

| Notebook | Covers |
|---|---|
| `00_what_is_class_eval` | Core mechanics — `class_eval`, `alias_method`, `singleton_class`, the dry-run pattern. No gems required. |
| `01_active_record` | AR dry run → real run → rollback, step by step |
| `02_graphql` | GraphQL mutation dry run → real run → rollback |
| `03_karafka` | WaterDrop producer capture → passthrough |
| `04_all_together` | All three patches in one session |

Each notebook is **self-contained** — all code is inline, no external files needed.

### Querying the notebook DB from a second terminal

Each notebook setup cell writes a DB file to the `notebooks/` directory (mounted
volume, accessible from the host). Query it while the notebook is running:

```bash
# while notebook 01 is open and cells have been run
docker compose run --rm lab sqlite3 notebooks/ar_demo.db "SELECT name, age FROM users;"

# notebook 02
docker compose run --rm lab sqlite3 notebooks/graphql_demo.db "SELECT name, age FROM users;"

# notebook 04
docker compose run --rm lab sqlite3 notebooks/all_demo.db "SELECT name, age FROM users;"
```

### Querying the DB from inside a notebook cell

You can also query inline without leaving Jupyter:

```ruby
ActiveRecord::Base.connection.execute("SELECT name, age FROM users").to_a
```

### Resetting state between runs

If you want to restart the demo from scratch without restarting the kernel,
re-run the **Setup** cell. `force: :cascade` will drop and re-seed the table.

---

## Project structure

```
ruby/
├── Dockerfile
├── docker-compose.yml
├── Gemfile                          # single gemfile for the container
│
├── active_record_monkey_patching/
│   ├── setup.rb                     # User model + SQLite DB
│   ├── rollback_context.rb          # tracks before-snapshots, handles restore
│   ├── patch.rb                     # ActiveRecord::Base.class_eval
│   └── main.rb                      # runs all three phases
│
├── graphql_monkey_patching/
│   ├── setup.rb                     # User model + GraphQL schema + mutation
│   ├── rollback_context.rb
│   ├── patch.rb                     # Types::UpdateUserAgeMutation.class_eval
│   └── main.rb
│
├── kafka_monkey_patching/
│   ├── setup.rb                     # WaterDrop producer (deliver: false)
│   ├── capture_context.rb           # records intercepted messages
│   ├── patch.rb                     # WaterDrop::Producer.class_eval
│   └── main.rb
│
├── generic_demo_app/                # all three patches in one app
│   ├── setup.rb
│   ├── setup_graphql.rb
│   ├── setup_karafka.rb
│   ├── rollback_context.rb          # combined AR + GraphQL context
│   ├── capture_context.rb
│   ├── patches/
│   │   ├── ar_patch.rb
│   │   ├── graphql_patch.rb
│   │   └── kafka_patch.rb
│   └── main.rb
│
└── notebooks/
    ├── 00_what_is_class_eval.ipynb
    ├── 01_active_record.ipynb
    ├── 02_graphql.ipynb
    ├── 03_karafka.ipynb
    └── 04_all_together.ipynb
```

---

## Full reset

Removes all `.db` files and restarts the Jupyter container (clearing all kernel state):

```bash
./reset.sh
```

After running, refresh `http://localhost:8888` and re-select the Ruby kernel in each notebook.

---

## Stopping the notebook server

```bash
docker compose down
```
