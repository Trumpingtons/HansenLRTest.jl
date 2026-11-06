# HansenLRTest.jl

The standardized likelihood ratio test for Markov switching models of GNP.

Hansen's standardized likelihood ratio test of a one-state autoregression against a two-state switching model, with the 1996 erratum's Bartlett-kernel p-values: maximum likelihood estimates of the AR(4), Hamilton's Markov switching model, the switching intercept model and the switching parameters model of US real GNP, the Wald tests between them, and the standardized LR statistics on grids of the parameters not identified under the null.

Article: Hansen, B. E. (1992). The likelihood ratio test under nonstandard conditions: Testing the Markov switching model of GNP. Journal of Applied Econometrics 7(S1), S61-S82. Erratum: Journal of Applied Econometrics 11(2), 195-198 (1996). [doi:10.1002/jae.3950070506](https://doi.org/10.1002/jae.3950070506)

## Usage

```julia
using HansenLRTest, CSV, Downloads, Tables
url = "https://raw.githubusercontent.com/roga11/MSTest/030123697a62022f6036cd4ec7fbfdc95155a421/inst/extdata/GNP82.DAT"
gnp82 = Tables.columntable(CSV.File(take!(Downloads.download(url, IOBuffer())); delim = '	', header = [:q1, :q2, :q3, :q4]))
ar_estimates(gnp82)                               # Table I: the AR(4)
hamilton_estimates(gnp82)                         # Table II: Hamilton's Markov switching model
standardized_lr(gnp82, :hamilton; grids = 1:3)    # erratum Table III: LR* on Grids 1 to 3
lr_pvalues(gnp82, :hamilton; grids = 1:3)         # and its p-values, Bartlett bandwidths M = 0 to 4
```

## Vignette

[The standardized likelihood ratio test for Markov switching models of GNP](vignette/HansenLRTest.tex), its LaTeX source: Pollis compiles it in Help > Documentation > Package Vignettes.

## License

MIT (see [LICENSE](LICENSE)).

## Tests

The tests compute the published tables below from their data and check every printed value, rounded to the digits printed:

- Erratum, Table X, p. 197: standardized LR statistics (`test/data/targets/erratum10.csv`)
- Erratum, Table X, p. 197: p-values (`test/data/targets/erratum10pvalues.csv`)
- Erratum, Table III, p. 196: standardized LR statistics (`test/data/targets/erratum3.csv`)
- Erratum, Table III, p. 196: p-values (`test/data/targets/erratum3pvalues.csv`)
- Erratum, Table VI, p. 197: standardized LR statistics (`test/data/targets/erratum6.csv`)
- Erratum, Table VI, p. 197: p-values (`test/data/targets/erratum6pvalues.csv`)
- Table I, p. S71 (`test/data/targets/table1.csv`)
- Table II, p. S72 (`test/data/targets/table2.csv`)
- Table III, p. S73: p-values (M = 0) (`test/data/targets/table3pvalues.csv`)
- Table V, p. S75 (`test/data/targets/table5.csv`)
- Table VI, p. S76: p-values (M = 0) (`test/data/targets/table6pvalues.csv`)
- Table VIII, p. S78 (`test/data/targets/table8.csv`)
- Table IX, p. S78 (`test/data/targets/table9.csv`)

The data, downloaded from its links when the tests run or kept in `test/data/inputs`:

- `gnp82`: <https://raw.githubusercontent.com/roga11/MSTest/030123697a62022f6036cd4ec7fbfdc95155a421/inst/extdata/GNP82.DAT>, Hamilton's (1989) US real GNP, quarterly levels from 1951Q1 to 1984Q4, four quarters to a line, as kept in the R package MSTest (Rodriguez-Rondon and Dufour)

Run them with `using Pkg; Pkg.test("HansenLRTest")`.

Made with [Pollis](https://pollis.org).
