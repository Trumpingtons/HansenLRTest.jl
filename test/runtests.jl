# Made by Pollis (Compose > New Methods > Package and Publish) from method.toml: change the method, not this file.
using Test, CSV, Downloads, Tables, HansenLRTest

const DATA = joinpath(@__DIR__, "data")

"An input table: a file of the tests, or downloaded from its link into memory."
function input(source; delim = ',', columns = nothing, header = true, skipto = nothing, limit = nothing)
	bytes = startswith(source, r"https?://") ? take!(Downloads.download(source, IOBuffer())) : read(joinpath(DATA, source))
	named = columns === nothing && header
	header = columns !== nothing ? Symbol.(columns) : named ? 1 : false
	rows = (; skipto = something(skipto, named ? 2 : 1), limit)
	file = delim == "whitespace" ? CSV.File(bytes; header, rows..., delim = ' ', ignorerepeated = true, stripwhitespace = true) : CSV.File(bytes; header, rows..., delim = delim == "tab" ? '\t' : only(delim))
	return Tables.columntable(file)
end

"The published table: its row labels and its values as printed, `nothing` where a cell is empty."
function target(file)
	table = CSV.File(joinpath(DATA, "targets", file * ".csv"); types = String, delim = ',')
	columns = Tables.columnnames(table)
	rows = [string(coalesce(row[columns[1]], "")) for row in table]
	values = [let cell = row[column]; cell === missing ? nothing : strip(cell) end for row in table, column in columns[2:end]]
	return rows, string.(columns[2:end]), values
end

"Tests each printed value against the result rounded to the digits printed."
function check(result, file, tolerance)
	rows, columns, values = target(file)
	result = result isa AbstractVecOrMat ? result : Tables.matrix(result)
	result = reshape(result, size(result, 1), :)
	@test size(result) == size(values)
	for i in axes(values, 1), j in axes(values, 2)
		printed = values[i, j]
		(printed === nothing || isempty(printed)) && continue
		mantissa, exponent = occursin(r"[eE]", printed) ? split(printed, r"[eE]") : (printed, "0")
		digits = (occursin('.', mantissa) ? length(split(mantissa, '.')[2]) : 0) - parse(Int, exponent)
		published = parse(Float64, printed)
		computed = round(result[i, j]; digits)
		@testset "$(rows[i]), $(columns[j])" begin
			@test isapprox(computed, published; atol = (tolerance + 1e-6) * 10.0^-digits)
		end
	end
end

@testset "HansenLRTest" begin
	@testset "Erratum, Table X, p. 197: standardized LR statistics" begin
		gnp82 = input("https://raw.githubusercontent.com/roga11/MSTest/030123697a62022f6036cd4ec7fbfdc95155a421/inst/extdata/GNP82.DAT"; delim = "tab", columns = ["q1", "q2", "q3", "q4"])
		check(vcat(standardized_lr(gnp82, :modelA; grids = 1:4), standardized_lr(gnp82, :modelB; grids = 1:4)), "erratum10", 1)
	end
	@testset "Erratum, Table X, p. 197: p-values" begin
		gnp82 = input("https://raw.githubusercontent.com/roga11/MSTest/030123697a62022f6036cd4ec7fbfdc95155a421/inst/extdata/GNP82.DAT"; delim = "tab", columns = ["q1", "q2", "q3", "q4"])
		check(vcat(lr_pvalues(gnp82, :modelA; grids = 1:4), lr_pvalues(gnp82, :modelB; grids = 1:4)), "erratum10pvalues", 3)
	end
	@testset "Erratum, Table III, p. 196: standardized LR statistics" begin
		gnp82 = input("https://raw.githubusercontent.com/roga11/MSTest/030123697a62022f6036cd4ec7fbfdc95155a421/inst/extdata/GNP82.DAT"; delim = "tab", columns = ["q1", "q2", "q3", "q4"])
		check(standardized_lr(gnp82, :hamilton; grids = 1:3), "erratum3", 0)
	end
	@testset "Erratum, Table III, p. 196: p-values" begin
		gnp82 = input("https://raw.githubusercontent.com/roga11/MSTest/030123697a62022f6036cd4ec7fbfdc95155a421/inst/extdata/GNP82.DAT"; delim = "tab", columns = ["q1", "q2", "q3", "q4"])
		check(lr_pvalues(gnp82, :hamilton; grids = 1:3), "erratum3pvalues", 7)
	end
	@testset "Erratum, Table VI, p. 197: standardized LR statistics" begin
		gnp82 = input("https://raw.githubusercontent.com/roga11/MSTest/030123697a62022f6036cd4ec7fbfdc95155a421/inst/extdata/GNP82.DAT"; delim = "tab", columns = ["q1", "q2", "q3", "q4"])
		check(standardized_lr(gnp82, :intercept; grids = 1:5), "erratum6", 0)
	end
	@testset "Erratum, Table VI, p. 197: p-values" begin
		gnp82 = input("https://raw.githubusercontent.com/roga11/MSTest/030123697a62022f6036cd4ec7fbfdc95155a421/inst/extdata/GNP82.DAT"; delim = "tab", columns = ["q1", "q2", "q3", "q4"])
		check(lr_pvalues(gnp82, :intercept; grids = 1:5), "erratum6pvalues", 7)
	end
	@testset "Table I, p. S71" begin
		gnp82 = input("https://raw.githubusercontent.com/roga11/MSTest/030123697a62022f6036cd4ec7fbfdc95155a421/inst/extdata/GNP82.DAT"; delim = "tab", columns = ["q1", "q2", "q3", "q4"])
		check(ar_estimates(gnp82), "table1", 0)
	end
	@testset "Table II, p. S72" begin
		gnp82 = input("https://raw.githubusercontent.com/roga11/MSTest/030123697a62022f6036cd4ec7fbfdc95155a421/inst/extdata/GNP82.DAT"; delim = "tab", columns = ["q1", "q2", "q3", "q4"])
		check(hamilton_estimates(gnp82), "table2", 1)
	end
	@testset "Table III, p. S73: p-values (M = 0)" begin
		gnp82 = input("https://raw.githubusercontent.com/roga11/MSTest/030123697a62022f6036cd4ec7fbfdc95155a421/inst/extdata/GNP82.DAT"; delim = "tab", columns = ["q1", "q2", "q3", "q4"])
		check(lr_pvalues(gnp82, :hamilton; grids = 1:3, bandwidths = 0:0), "table3pvalues", 4)
	end
	@testset "Table V, p. S75" begin
		gnp82 = input("https://raw.githubusercontent.com/roga11/MSTest/030123697a62022f6036cd4ec7fbfdc95155a421/inst/extdata/GNP82.DAT"; delim = "tab", columns = ["q1", "q2", "q3", "q4"])
		check(intercept_estimates(gnp82), "table5", 1)
	end
	@testset "Table VI, p. S76: p-values (M = 0)" begin
		gnp82 = input("https://raw.githubusercontent.com/roga11/MSTest/030123697a62022f6036cd4ec7fbfdc95155a421/inst/extdata/GNP82.DAT"; delim = "tab", columns = ["q1", "q2", "q3", "q4"])
		check(lr_pvalues(gnp82, :intercept; grids = 1:5, bandwidths = 0:0), "table6pvalues", 4)
	end
	@testset "Table VIII, p. S78" begin
		gnp82 = input("https://raw.githubusercontent.com/roga11/MSTest/030123697a62022f6036cd4ec7fbfdc95155a421/inst/extdata/GNP82.DAT"; delim = "tab", columns = ["q1", "q2", "q3", "q4"])
		check(switching_estimates(gnp82), "table8", 0)
	end
	@testset "Table IX, p. S78" begin
		gnp82 = input("https://raw.githubusercontent.com/roga11/MSTest/030123697a62022f6036cd4ec7fbfdc95155a421/inst/extdata/GNP82.DAT"; delim = "tab", columns = ["q1", "q2", "q3", "q4"])
		check(wald_tests(gnp82), "table9", 0)
	end
end
