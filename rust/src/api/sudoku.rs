use sudoku::strategy::deduction::Deductions;
pub use sudoku::strategy::Strategy;
use sudoku::strategy::StrategySolver;
use sudoku::Sudoku;

#[flutter_rust_bridge::frb(sync)]
pub fn generate_sudoku() -> String {
    Sudoku::generate().to_string()
}

#[flutter_rust_bridge::frb(sync)]
pub fn unique_solution(sudoku_string: String) -> Option<String> {
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
pub fn get_rating(sudoku_string: String) -> (u32, bool) {
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

    return (
        deductions
            .iter()
            .map(|d| _strategy_to_difficulty(&d.strategy()))
            .sum(),
        is_solved,
    );
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}
