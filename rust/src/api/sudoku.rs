use std::collections::HashMap;

use sudoku::strategy::deduction::Deductions;
pub use sudoku::strategy::Strategy;
use sudoku::strategy::StrategySolver;
use sudoku::Sudoku;

#[flutter_rust_bridge::frb(sync)]
pub fn generate_sudoku() -> String {
    Sudoku::generate().to_string()
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_unique_solution(sudoku_string: String) -> Option<String> {
    let sudoku = Sudoku::from_str_line(&sudoku_string);
    if sudoku.is_ok() {
        let solution = sudoku.unwrap().solution();
        if solution.is_some() {
            return Some(solution.unwrap().to_string());
        }
    }

    None
}

#[flutter_rust_bridge::frb(sync)]
fn _strategy_to_difficulty(s: &Strategy) -> u32 {
    // difficulty assigned by SudokuExplainer (except Mutant strategies)
    match s {
        Strategy::NakedSingles => 23,
        Strategy::HiddenSingles => 15,
        Strategy::LockedCandidates => 28,
        Strategy::NakedPairs => 30,
        Strategy::NakedTriples => 36,
        Strategy::NakedQuads => 50,
        Strategy::HiddenPairs => 34,
        Strategy::HiddenTriples => 40,
        Strategy::HiddenQuads => 54,
        Strategy::XWing => 32,
        Strategy::Swordfish => 38,
        Strategy::Jellyfish => 52,
        Strategy::XyWing => 42,
        Strategy::XyzWing => 44,
        // TODO: assign those according to SudokuExplainer
        Strategy::MutantSwordfish => 48,
        Strategy::MutantJellyfish => 62,
        _ => 0,
    }
}

#[flutter_rust_bridge::frb(sync)]
fn _strategy_to_string(s: &Strategy) -> String {
    match s {
        Strategy::NakedSingles => "naked-singles",
        Strategy::HiddenSingles => "hidden-singles",
        Strategy::LockedCandidates => "locked-candidates",
        Strategy::NakedPairs => "naked-pairs",
        Strategy::NakedTriples => "naked-triples",
        Strategy::NakedQuads => "naked-quads",
        Strategy::HiddenPairs => "hidden-pairs",
        Strategy::HiddenTriples => "hidden-triples",
        Strategy::HiddenQuads => "hidden-quads",
        Strategy::XWing => "x-wing",
        Strategy::Swordfish => "swordfish",
        Strategy::Jellyfish => "jellyfish",
        Strategy::XyWing => "xy-wing",
        Strategy::XyzWing => "xyz-wing",
        Strategy::MutantSwordfish => "mutant-swordfish",
        Strategy::MutantJellyfish => "mutant-jellyfish",
        _ => "unknown",
    }
    .to_string()
        + "-strategy"
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_rating(sudoku_string: String) -> (u32, HashMap<String, u32>, bool) {
    let sudoku = Sudoku::from_str_line(&sudoku_string);
    let solver = StrategySolver::from_sudoku(sudoku.unwrap());

    let solver_res = solver.solve(&[
        Strategy::NakedSingles,
        Strategy::HiddenSingles,
        Strategy::LockedCandidates,
        Strategy::NakedPairs,
        Strategy::NakedTriples,
        Strategy::NakedQuads,
        Strategy::HiddenPairs,
        Strategy::HiddenTriples,
        Strategy::HiddenQuads,
        Strategy::XWing,
        Strategy::Swordfish,
        Strategy::Jellyfish,
        Strategy::XyWing,
        Strategy::XyzWing,
        Strategy::MutantSwordfish,
        Strategy::MutantJellyfish,
    ]);

    let deductions: Deductions;
    let is_solved: bool;

    if solver_res.is_ok() {
        deductions = solver_res.unwrap().1;
        is_solved = true;
    } else {
        deductions = solver_res.unwrap_err().1;
        is_solved = false;
    }

    let mut difficulty = 0;
    let mut strategy_count = HashMap::new();

    for deduction in deductions.iter() {
        let strategy = &deduction.strategy();

        difficulty += _strategy_to_difficulty(&strategy);

        *strategy_count
            .entry(_strategy_to_string(strategy))
            .or_insert(0) += 1;
    }

    return (difficulty, strategy_count, is_solved);
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}
