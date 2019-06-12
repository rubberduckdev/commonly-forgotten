---
layout: default.liquid

title: Targeting wasm32 with Quicksilver and friends.
is_draft: true
---

# Making Quicksilver work with wasm32.

## Disclaimer:

This technology is indistinguishable from magic. I am merely recalling which
  spells and incantations worked for me. If you have anything to add, you can
  reach me on <https://gitgud.io/yuvallanger/kaka.farm/> or
  <https://gitlab.com/yuvallanger/kaka.farm/>.

Several months ago, writing a Flappy Bird clone called [Rectangly
Rect](https://gitgud.io/yuvallanger/rectangly-rect/), I have done a bunch of
asking around and found exactly which parts don't work and how to replace them.
Yesterday, trying to adapt YasamSim to the web, I have re-discovered those
workarounds, and decided to write this down.

## `println!`!

First thing, drop all of your `println!`s.  For some esoteric reason, this
function throws a wrench into the web's machinery.  Same goes for
`std::time::Instance::now()`.  For now I just dropped all calls to `now()`,
maybe I could ask the browser manually with whatever function Javascript has,
or maybe there is a more standardized `std` alternative for the web - I don't
know.

In order to replace `println!`, I had to add to `Cargo.toml` a general
dependency for the crate `log`, an entry for every target that is not wasm32
for the crate `env_logger`, and an entry for the crate `web_logger` for the
wasm32 target:

```Cargo.toml
[dependencies]
log = "0.4"

[target.'cfg(not(wasm32))'.dependencies]
env_logger = "0.6"

[target.'cfg(wasm32)'.dependencies]
web_logger = "0.1"
```

In `src/logging.rs`, conditionally compile a different `init_logger()` function
for each platform, wasm32 and not-wasm32:

```src/logging.rs
#[cfg(target_arch = "wasm32")]
pub fn init_logger() {
    ::web_logger::init();
}

#[cfg(not(target_arch = "wasm32"))]
pub fn init_logger() {
    ::env_logger::init();
}
```

In `src/main.rs`, call the `init_logger()` defined in the `logging.rs`
sub-module at the head of your `main()` function:

```src/main.rs
mod logging;

fn main() {
    logging::init_logger();
    …
}
```

Now you can call `info!()`, `error!()`, `warn!()`, etc., as described in <https://docs.rs/log/0.4/log/>.

If you also debug it in your native target, you can also provide the `RUST_LOG`
environment variable, as per <https://docs.rs/env_logger/0.6/env_logger/>'s
documentation, in your command line incantations:

```
$ RUST_LOG=DEBUG cargo run
```

## Sequentialize SPECS.

For some more esoteric reasons, probably something to do with threads, I had to
rewrite how I run my `specs::System`s , and
how `specs::System`s written.

### Dispatching `specs::Dispatcher`.

One normally builds a dependency graph of `specs::System`s using something
like:

```src/main.rs
fn make_specs_dispatcher() -> specs::Dispatcher<'static, 'static> {
    specs::DispatcherBuilder::new()
        .with(
            SystemFoo,
            "system_foo",
            &[],
        )
        .with(
            SystemBar,
            "system_bar",
            &["system_foo"],
        )
        .build()
}

struct OurGameState {
    specs_world: specs::World,
    specs_dispatcher: specs::Dispatcher,
}


impl State for OurGameState {
    fn new() -> Result<World> {
        let specs_world = make_specs_world_and_register_components(); // Implemented elsewhere…
        let specs_dispatcher = make_specs_dispatcher();

        Ok(
            OurGameState {
                specs_world,
                specs_dispatcher,
            }
        )
    }
            
    fn update(&mut self, window: &mut Window) -> Result<()> {
        let system_foo = SystemFoo;
        let system_bar = SystemBar;
        
        system_foo.run_now(&selfworld.res);
        system_bar.run_now(&world.res);
        
        world.maintain();
        
        Ok(())
    }

    [imagine the rest of the quicksilver::lifecycle::State methods implemented here…]
}
```

In this example `SystemBar` depends on the state of the `specs::World` left by
`SystemFoo` after it does its thing.

Instead of using this `Dispatcher` as described in
<https://slide-rs.github.io/specs/03_dispatcher.html>, you do this in your
`quicksilver::lifecycle::State::update()`

```
struct OurGameState {
    specs_world: specs::World,
}

impl State for OurGameState {
    fn new() -> Result<World> {
        let specs_world = make_specs_world_and_register_components(); // Implemented elsewhere…

        Ok(
            OurGameState {
                specs_world,
            }
        )
    }

    fn update(&mut self, window: &mut Window) -> Result<()> {
        let system_foo = SystemFoo;
        let system_bar = SystemBar;
        
        system_foo.run_now(&selfworld.res);
        system_bar.run_now(&world.res);
        
        world.maintain();
        
        Ok(())
    }

    [imagine the rest of the quicksilver::lifecycle::State methods implemented here…]
}
```

But in order to sequentialize how you deal with `specs`, you'd need to change one more thing:

### Lay off `specs::LazyUpdater`.

If you do anything with `specs::LazyUpdate`, you would have to convert it into
another form, interacting with your `Component` `Storage`s directly with
`WriteStorage` or whatever.
