/**
 * IMPORTANT: The README.md file contains important information on getting started.
 * Please read before attempting these exercises.
 *
 * Note that passing tests is just an indication the implementation is not incorrect.
 * Marks are only awarded for correct understanding of the question and demonstration of concepts.
 *
 * Ask a tutor if in doubt!
 */

// Stub value to indicate an implementation
const IMPLEMENT_THIS = undefined;
/*****************************************************************
 * Exercise 1:
 *
 * The const keyword is used for creating an un-reassignable variable.
 * see: https://tgdwyer.github.io/javascript1#declaring-variables
 *
 * Create an un-reassignable variable called firstConst and initialise its value to 1.
 *
 * Then create another un-reassignable variable called secondConst
 *  and initialise its value to firstConst + 1.
 */
const firstConst = 1;
const secondConst = firstConst + 1;

/*****************************************************************
 * Exercise 2:
 *
 * For this exercise, each function should initialise a local variable with the value 2
 *  and return double its value.
 * see: https://tgdwyer.github.io/javascript1/#functions
 *
 * Create the following functions, each using a different way to declare a function:
 *  - aFunction: using the "function" keyword
 *  - anonymousFunction: using an anonymous function declared with the "function" keyword
 *  - arrowFunction: using an arrow function
 */
function aFunction() {
    const localVar = 2;
    return localVar * 2;
}

const anonymousFunction = function () {
    const localVar = 2;
    return localVar * 2;
};

const arrowFunction = () => {
    const localVar = 2;
    return localVar * 2;
};

/*****************************************************************
 * Exercise 3:
 *
 * Convert a decimal number into its binary representation.
 *
 * How binary numbers work:
 *
 * Each position in a binary number is a power of 2.
 * From right to left:
 *
 * 2^0, 2^1, 2^2, 2^3, 2^4, ...
 *
 * Example:
 * 1101 (binary)
 *
 * = 1 × 2^3
 * + 1 × 2^2
 * + 0 × 2^1
 * + 1 × 2^0
 *
 * = 8 + 4 + 0 + 1
 * = 13 (decimal)
 *
 * Recursive idea:
 * binary(n, acc) = binary(floor(n / 2), (n % 2) + acc)
 *
 * You must use recursion, immutable variables, and pure functions.
 * You must not use loops.
 *****************************************************************/

/**
 * Recursive function that builds a binary string using an accumulator.
 *
 * /Hint/: Each recursive call should divide the number by 2 and prepend
 * the remainder to the accumulator.
 *
 * @param n Decimal number
 * @param acc Accumulator string
 * @returns Binary representation of n
 */
const decimalToBinaryAcc = (n, acc) => {
    // Base case: stop recursion when n reaches ______
    if (n === 0) {
        // When we reach the base case, return the accumulated binary string
        return acc;
    }

    // Recursive case:

    // Divide n by 2 and take the integer part
    const next = Math.floor(n / 2);

    // Add the remainder (0 or 1) to the front of the accumulator
    const newAcc = (n % 2) + acc;

    // Recursive call
    return decimalToBinaryAcc(next, newAcc);
};

/**
 * Converts a decimal number to binary.
 *
 * /Hint/: Call the accumulator function with an empty string.
 *
 * @param n Decimal number
 * @returns Binary representation of n
 */
const decimalToBinary = n => {
    // Special case: binary of 0 is "0"
    if (n === 0) {
        return "0";
    }

    // Start the recursive helper with an empty accumulator
    return decimalToBinaryAcc(n, "");
};

/*****************************************************************
 * Exercise 4:
 *
 * Practise using array methods.
 * see: https://tgdwyer.github.io/javascript1/#arrays
 */

/**
 * Print each number in the array (one console.log call per number)
 *
 * /Hint/: console.log is used to print
 *
 * @param arr Array to print
 */
const printArray = function (arr) {
    arr.reduce((_, item) => console.log(item), null);
};

/**
 * Create a new array with each item incremented by one (1)
 *
 * @param arr Array to increment
 * @returns New array with incremented items
 */
const addOne = function (arr) {
    return arr.map(item => item + 1);
};

/**
 * Create a new array with ones removed
 *
 * @param arr Input array
 * @returns Array without ones
 */
const removeOnes = function (arr) {
    return arr.filter(item => item !== 1);
};

/**
 * Calculate the sum of the items in an array
 *
 * @param arr Input array
 * @returns Sum of items in arr
 */
const sumArray = arr => {
    return arr.reduce((acc, item) => acc + item, 0);
};

/*****************************************************************
 * Exercise 5:
 *
 * Refactor the following functions to use array methods.
 * see: https://tgdwyer.github.io/javascript1/#arrays
 */

const multiplyArray = (n, arr) => {
    return arr.map(item => item * n);
};

const filterEvenNumbers = arr => {
    return arr.filter(item => item % 2 == 0);
};

// Do *not* use Math.max
// const findMax = array => {
//     let max = array[0];
//     for (let i = 1; i < array.length; i++) {
//         if (array[i] > max) {
//             max = array[i];
//         }
//     }
//     return max;
// };

const findMax = arr => {
    return arr.reduce((max, item) => (item > max ? item : max), arr[0]);
};

const tripleAndFilterOdds = arr => {
    return arr.map(item => item * 3).filter(item => item % 2 !== 0);
};

const countOddNumbers = arr => {
    return arr.reduce((acc, item) => (item % 2 != 0 ? acc + 1 : acc), 0);
};

/*****************************************************************
 * Exercise 6:
 *
 * Solve the Project Euler Problem 1 by implementing the following functions.
 *
 * Use only pure array methods.
 *
 * Project Euler Problem 1 is the following:
 *
 * "If we list all the natural numbers below 10 that are multiples of 3 or 5,
 *  we get 3, 5, 6 and 9. The sum of these multiples is 23.
 *  Find the sum of all the multiples of 3 or 5 below 1000."
 */

/**
 * Create a range of values
 *
 * @param n Target value
 * @returns Array of integers in the range [0, n)
 */
const range = n => {
    return Array(n)
        .fill(0)
        .map((_, index) => index);
};

/**
 * @returns Answer to project euler problem 1
 */
const projectEulerProblem1 = () => {
    const arr = range(1000);
    return arr.reduce(
        (acc, item) => (item % 3 == 0 || item % 5 == 0 ? acc + item : acc),
        0,
    );
};

/*****************************************************************
 * Exercise 7:
 * This exercise starts to explore functional programming concepts.
 * We will go through this in detail in the Workshop.
 *
 * The Cons list is a simple immutable data structure composing
 *  only of functions, using closures to capture data.
 * see also: https://tgdwyer.github.io/functionaljavascript/#computation-with-pure-functions
 *
 * This is essentially equivalent to linked lists.
 *
 * Implement the following functions to define a Cons list.
 */

/**
 * Cons "constructs" a list node, if no second argument is specified it is the last node in the list
 *
 * @param head Head of cons list, the value to be stored
 * @param rest Tail of cons list, reference to the rest of the cons list
 * @returns Cons list, function in closure
 */
function cons(head, rest = null) {
    // return f => f(head, rest);

    return selector => selector(head, rest);
}

/**
 * Head selector
 *
 * @param list Non-empty cons list, remember this is a function!
 * @returns First element in cons list
 */
function head(list) {
    if (!list) throw new TypeError("list is null");

    return list((head, rest) => head);
}

/**
 * Rest selector
 *
 * @param list Non-empty cons list, remember this is a function!
 * @returns Rest of the cons list
 */
function rest(list) {
    if (!list) throw new TypeError("list is null");

    return list((head, rest) => rest);
}

/*****************************************************************
 * Exercise 8
 * This exercise starts to explore functional programming concepts.
 * We will go through this in detail in the Workshop.
 * see https://tgdwyer.github.io/functionaljavascript#computation-with-pure-functions
 *
 * Higher order functions are applicable on any data type we can think of.
 * This, of course, also applies to the Cons list.
 *
 * Implement the following higher order functions for Cons lists.
 */

/**
 * Use this as an example for other functions!
 *
 * @param f Function to use for each element
 * @param list Cons list
 */
function forEach(f, list) {
    if (list) {
        f(head(list));
        forEach(f, rest(list));
    }
}

/**
 * Map for cons list
 *
 * @param f Function to apply
 * @param list Cons list to map
 * @returns New cons list with f applied to elements
 */
function map(f, list) {
    if (!list) return null;

    return cons(f(head(list)), map(f, rest(list)));
}

/**
 * Reduce for cons list
 *
 * @param {(acc, val) => any} f Reducing function, this combines the accumulator with the current value. Note that the accumulator value is the first parameter, and the current value is the second parameter.
 * @param acc Accumulated value, initial value
 * @param list Cons list to reduce
 * @returns The accumulated value after applying f to each element in list, left to right
 */
function reduce(f, acc, list) {
    if (!list) return acc;

    return reduce(f, f(acc, head(list)), rest(list));
}

/**
 * Filter for cons list
 *
 * @param f Function to accept or reject values
 * @param list Cons list to filter
 * @returns New cons list with only accepted values
 */
function filter(f, list) {
    if (!list) return null;

    // Skip value
    if (!f(head(list))) return filter(f, rest(list));

    return cons(head(list), filter(f, rest(list)));
}
