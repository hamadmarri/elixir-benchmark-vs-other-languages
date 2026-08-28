use std::time::Instant;

type MyInt = i32;

#[derive(Clone, Debug, PartialEq, Eq)]
struct QueueItem {
    item_vals: Vec<MyInt>,
    item_len: MyInt,
}

fn init_queue(rng_reversed: &[MyInt]) -> Vec<QueueItem> {
    // Capacity reserved to prevent stack reallocation
    let mut q = Vec::with_capacity(128);

    // In Haskell, reverse rng puts 10 at the head of the list.
    // In a Rust Vec stack, we push 1..=10 in order so 10 is at the top (popped first).
    for &x in rng_reversed.iter().rev() {
        q.push(QueueItem {
            item_vals: vec![x],
            item_len: 1,
        });
    }
    q
}

#[inline(always)]
fn new_children(q: &mut Vec<QueueItem>, parent_items: &[MyInt], parent_len: MyInt, rng: &[MyInt]) {
    for &c in rng {
        // Pre-allocate vector capacity to avoid dynamic reallocation during prepend
        let mut child_vals = Vec::with_capacity(parent_items.len() + 1);
        child_vals.push(c);
        child_vals.extend_from_slice(parent_items);

        q.push(QueueItem {
            item_vals: child_vals,
            item_len: parent_len,
        });
    }
}

#[inline(always)]
fn generate(
    q: &mut Vec<QueueItem>,
    parent_items: &[MyInt],
    parent_len: MyInt,
    entropy: MyInt,
    rng: &[MyInt],
    stat: usize,
) -> usize {
    if parent_len >= entropy {
        return stat;
    }

    new_children(q, parent_items, parent_len + 1, rng);
    stat + entropy as usize
}

fn solve(
    mut q: Vec<QueueItem>,
    solution: &[MyInt],
    entropy: MyInt,
    rng: &[MyInt],
    mut stat: usize,
) {
    // Iterative loop mirroring Haskell's tail-recursion
    while let Some(item) = q.pop() {
        if item.item_len == 9 && item.item_vals == solution {
            print!("FOUND A SOLUTION [");
            for (i, val) in item.item_vals.iter().enumerate() {
                if i > 0 {
                    print!(",");
                }
                print!("{}", val);
            }
            println!("], count: {}", stat);
            return;
        }

        stat = generate(&mut q, &item.item_vals, item.item_len, entropy, rng, stat);
    }

    println!("q IS EMPTY!, QUITTING!, count: {}", stat);
}

fn main() {
    let start = Instant::now();

    let solution: Vec<MyInt> = vec![7, 7, 7, 7, 7, 7, 7, 5, 10];
    let entropy: MyInt = 10;
    let rng: Vec<MyInt> = (1..=entropy).collect();

    let rng_rev: Vec<MyInt> = rng.iter().copied().rev().collect();
    let q = init_queue(&rng_rev);

    // Print initial queue matching Haskell's head-to-tail view
    print!("QUEUE: [");
    for (i, item) in q.iter().rev().enumerate() {
        if i > 0 {
            print!(",");
        }
        print!("{:?}", item.item_vals);
    }
    println!("]");

    let initial_stat = q.len();
    solve(q, &solution, entropy, &rng, initial_stat);

    let duration = start.elapsed();
    println!("time: {:.6}s", duration.as_secs_f64());
}
