import std.stdio;
import std.datetime.stopwatch;
import std.algorithm : equal;
import std.array;

// We can use a 2D array as a stack in D
alias Stack = int[][];

const int ENTROPY = 10;
const int MAX_DIGIT = 10;

pragma(inline, true)
void initCh(ref Stack s)
{
    foreach (i; 1 .. ENTROPY + 1)
    {
        // In D, [i] creates a new dynamic array
        s ~= [i];
    }
}

pragma(inline, true)
int genCh(ref Stack s, const int[] parentItems, int stat)
{
    if (parentItems.length >= MAX_DIGIT)
    {
        return stat;
    }

    foreach (i; 1 .. ENTROPY + 1)
    {
        // ch = [i] + parentItems (array concatenation)
        int[] ch = [i] ~ parentItems;
        s ~= ch;
    }

    return stat + ENTROPY;
}

void solve(ref Stack s, const int[] solution, int stat)
{
    while (true)
    {
        if (s.length == 0)
        {
            writefln("Q IS EMPTY!, QUITTING!, count: %d", stat);
            return;
        }

        // Pop from the "stack" (end of the array)
        int[] item = s[$ - 1];
        s.popBack();

        if (equal(item, solution))
        {
            writef("FOUND A SOLUTION ");
            foreach (val; item)
                writef("%d ", val);
            writefln(", count: %d", stat);
            return;
        }

        stat = genCh(s, item, stat);
    }
}

void main()
{
    foreach (_; 0 .. 10)
    {
        auto sw = StopWatch(AutoStart.yes);

        int[] solution = [7, 7, 7, 7, 7, 7, 7, 5, 10];
        Stack stack;

        initCh(stack);

        // Use cast(int) for the initial count
        solve(stack, solution, cast(int) stack.length);

        sw.stop();

        // Convert hecto-nanoseconds to seconds
        double duration = sw.peek.total!"usecs" / 1_000_000.0;
        writefln("time: %fs", duration);

        // break; // Remove this if you want to run all 10 iterations
        return;
    }
}
