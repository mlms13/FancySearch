package test;

import utest.Runner;
import utest.ui.Report;

class TestAll {
  public static function main() {
    var runner = new Runner();
    runner.addCase(new test.fancy.TestSearch());
    Report.create(runner);
    runner.run();
  }
}
