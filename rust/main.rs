use std::time::Instant;

const ENTROPY: u8 = 10;
const MAX_DIGIT: usize = 10;

/// A lightweight, stack-allocated alternative to `std::vector<int>`
/// Since our max size is 10 and max value is 10, u8 is perfectly sized.
#[derive(Clone, Copy)]
struct Sequence {
    items: [u8; MAX_DIGIT],
    len: usize,
}

impl Sequence {
    #[inline(always)]
    fn new(val: u8) -> Self {
        let mut items = [0; MAX_DIGIT];
        items[0] = val;
        Self { items, len: 1 }
    }

    #[inline(always)]
    fn prepend(&self, val: u8) -> Self {
        let mut items = [0; MAX_DIGIT];
        items[0] = val;
        // Shift existing items right by 1 to prepend efficiently
        // This tiny block copy compiles down to a single instruction on modern CPUs.
        items[1..=self.len].copy_from_slice(&self.items[..self.len]);
        Self {
            items,
            len: self.len + 1,
        }
    }

    #[inline(always)]
    fn as_slice(&self) -> &[u8] {
        &self.items[..self.len]
    }
}

fn init_ch(stack: &mut Vec<Sequence>) {
    for i in 1..=ENTROPY {
        stack.push(Sequence::new(i));
    }
}

fn gen_ch(stack: &mut Vec<Sequence>, parent: &Sequence, stat: &mut usize) {
    if parent.len >= MAX_DIGIT {
        return;
    }

    for i in 1..=ENTROPY {
        stack.push(parent.prepend(i));
    }

    *stat += ENTROPY as usize;
}

fn solve(stack: &mut Vec<Sequence>, solution: &[u8], stat: &mut usize) {
    while let Some(item) = stack.pop() {
        // Safe, exact slice comparison. This accurately implements the logic
        // intended by your commented out `isSolution` C++ function.
        if item.as_slice() == solution {
            print!("FOUND A SOLUTION ");
            for &val in item.as_slice() {
                print!("{} ", val);
            }
            println!(", count: {}", stat);
            return;
        }

        gen_ch(stack, &item, stat);
    }
    println!("Q IS EMPTY!, QUITTING!, count: {}", stat);
}

fn main() {
    let start = Instant::now();
    let solution: [u8; 9] = [7, 7, 7, 7, 7, 7, 7, 5, 10];

    // Pre-allocate the stack. DFS only goes as deep as max_digit.
    // Max size of stack is roughly (max_digit * entropy), so 128 is plenty
    // to prevent any runtime vector resizing.
    let mut stack: Vec<Sequence> = Vec::with_capacity(128);
    init_ch(&mut stack);

    let mut stat = stack.len();
    solve(&mut stack, &solution, &mut stat);

    let duration = start.elapsed();
    println!("time: {:.6}s", duration.as_secs_f64());
}
