import csv
import os
import sys
import getopt
import matplotlib.pyplot as plt
import scipy.ndimage.filters
from itertools import groupby
from pathlib import Path
from typing import List, Set, Dict, Tuple, Optional
from shutil import copyfile
import statistics

TEST_SUBPATH = Path('spoofax.pie/core/statix.completions.bench/src/main/resources/tiger')
TESTRESULT_SUBPATH = Path('spoofax.pie/core/statix.completions.bench/output')

class TestCase:
    def __init__(self, tig_path, csv_path, base_path, output_path):
        self.name = str(tig_path.relative_to(base_path))
        self.tig_path = tig_path
        self.src_csv_path = csv_path / tig_path.relative_to(base_path).with_suffix('.tig.csv')
        self.dst_csv_path = (output_path / "data" / self.src_csv_path.relative_to(csv_path)).absolute()

    def __str__(self):
        return str(self.name) + ": " + str(self.tig_path) + " -> " + str(self.dst_csv_path)


class Results:
    def __init__(self, testNames, testIndexs, testCaseNames, proposalCounts, sorts, textSizes, astSizes,
                 preparationTimes, analysisTimes, completionTimes,
                 expandingPredicatesTimes, expandingInjectionTimes, expandingQueriesTimes, expandingDeterministicTimes):
        self.testNames = testNames
        self.testIndexs = testIndexs
        self.testCaseNames = testCaseNames
        self.proposalCounts = proposalCounts
        self.sorts = sorts
        self.textSizes = textSizes
        self.astSizes = astSizes

        self.preparationTimes = preparationTimes
        self.analysisTimes = analysisTimes
        self.completionTimes = completionTimes

        self.expandingPredicatesTimes = expandingPredicatesTimes
        self.expandingInjectionTimes = expandingInjectionTimes
        self.expandingQueriesTimes = expandingQueriesTimes
        self.expandingDeterministicTimes = expandingDeterministicTimes


class TestResult:
    testName: str
    testIndex: int
    testCaseName: str
    proposalCount: int
    sort: str
    textSize: int
    astSize: int

    preparationTime: int
    analysisTime: int
    completionTime: int

    expandingPredicatesTime: int
    expandingInjectionTime: int
    expandingQueriesTime: int
    expandingDeterministicTime: int

    def __init__(self, testName, testIndex, testCaseName, proposalCount, sort, textSize, astSize,
                 preparationTime, analysisTime, completionTime,
                 expandingPredicatesTime, expandingInjectionTime, expandingQueriesTime, expandingDeterministicTime):
        self.testName = testName
        self.testIndex = testIndex
        self.testCaseName = testCaseName
        self.proposalCount = proposalCount
        self.sors = sort
        self.textSize = textSize
        self.astSize = astSize

        self.preparationTime = preparationTime
        self.analysisTime = analysisTime
        self.completionTime = completionTime

        self.expandingPredicatesTime = expandingPredicatesTime
        self.expandingInjectionTime = expandingInjectionTime
        self.expandingQueriesTime = expandingQueriesTime
        self.expandingDeterministicTime = expandingDeterministicTime


# Main entry point.
def main():
    # Parse the command-line arguments
    try:
        arguments, values = getopt.getopt(sys.argv[1:], "f:o:", [
            "file=",
            "output="
        ])
    except getopt.error as err:
        print(str(err))
        sys.exit(2)

    input_file: Path = Path("results.csv")          # Results.csv file path
    output_dir: Path = Path(".")                    # Output directory for plots
    for arg, val in arguments:
        if arg in ("-f", "--file"):
            input_file = Path(val)
        elif arg in ("-o", "--output"):
            output_dir = Path(val)

    # Read the results.csv
    print('Reading...')
    results: List[TestResult] = read_results(input_file)

    print('Filtering...')
    # TODO: Filter the results we don't care about
    filtered_results: List[TestResult] = results

    print('Sorting...')
    # TODO: Sort by a parameter we care about
    sorted_results: List[TestResult] = sorted(filtered_results, key=lambda tc: tc.astSize)

    print('Plotting...')

    plt.ioff()      # Do not show the plotted images when closed

    box_bin_fig = plot_box_binned(sorted_results, 100, lambda tc: tc.completionTime)
    plt.savefig(output_dir / "box_bin_plt.png", bbox_inches='tight')
    plt.savefig(output_dir / "performance.pdf", bbox_inches='tight')
    plt.close(box_bin_fig)

    print('Calculating...')
    completionTimes = [t.completionTime for t in sorted_results]
    print('Test cases: ' + str(len(completionTimes)))
    print('Test suites: ' + str(len(set([t.testName for t in sorted_results]))))
    print('Median: ' + str(statistics.median(completionTimes)))
    print('Mean: ' + str(statistics.mean(completionTimes)))
    print('Min: ' + str(min(completionTimes)))
    print('Max: ' + str(max(completionTimes)))
    print('Quantiles: ' + str(statistics.quantiles(completionTimes)))

    print('Done!')


# Reads the CSV file and produces an object with n arrays for each value
# where n is the number of test results
def read_results(input_file: Path) -> List[TestResult]:
    try:
        with input_file.open() as csv_file:
            print("Reading CSV: " + str(input_file))
            csv_reader = csv.reader(csv_file, delimiter=',')
            # Go to first row
            next(csv_reader, None)
            # Skip header row
            next(csv_reader, None)

            testResults: List[TestResult] = []

            for row in csv_reader:
                testResults.append(TestResult(
                    row[0],
                    int(row[1]),
                    row[2],
                    int(row[3]),
                    row[4],
                    int(row[5]),
                    int(row[6]),

                    int(int(row[7]) / 1000000),
                    int(int(row[8]) / 1000000),
                    int(int(row[9]) / 1000000),

                    int(int(row[10]) / 1000000),
                    int(int(row[11]) / 1000000),
                    int(int(row[12]) / 1000000),
                    int(int(row[13]) / 1000000),
                ))
            return testResults
    except FileNotFoundError as e:
        print("Not found: " + e.filename)
        pass


def plot_box_binned(test_results: List[TestResult], bin_size: int, projector):
    grouped_tcs: List[Tuple[int, List[TestResult]]] = [(bin, list(tcs)) for (bin, tcs) in groupby(test_results, lambda tc: int(tc.astSize / bin_size))]
    datas: List[List[int]] = [[projector(tc) for tc in tcs] for (_, tcs) in grouped_tcs]
    labels: List[str] = [str(bin * bin_size) + '-' + str((bin + 1) * bin_size) for (bin, _) in grouped_tcs]
    return plot_box(datas, labels)


# Box plots
# datas: a list of data points (a list) for each bin
# labels: labels for each bin
def plot_box(datas: List[List[int]], labels: List[str]):
    fig = plt.figure(figsize=(10, 5))

    plt.title('Tiger performance tests')
    plt.xlabel('time (ms)')
    plt.ylabel('size (AST nodes)')

    # Creating plot
    plt.xlim(0, 10000)
    plt.boxplot(datas, labels=labels, vert=False)
    plt.tight_layout()
    plt.axvline(x=1000, ymin=0, ymax=1)
    return fig


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    main()

