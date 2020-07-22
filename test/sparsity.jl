using Test
using SumOfSquares
import MultivariateBases
const MB = MultivariateBases

function xor_complement_test()
    @test Certificate.xor_complement([1], 1) == Int[]
    @test Certificate.xor_complement(Int[], 1) == [1]
    @test Certificate.xor_complement([1], 2) == [2]
    @test Certificate.xor_complement([2], 2) == [1]
    @test Certificate.xor_complement([1, 2], 2) == Int[]
    @test Certificate.xor_complement([1, 3], 2) == Int[]
    @test Certificate.xor_complement(Int[], 2) == [1, 2]
    @test Certificate.xor_complement([7], 3) == [3, 5]
    @test Certificate.xor_complement([5, 6, 3], 3) == [7]
    @test Certificate.xor_complement([3], 3) == [3, 4]
end

set_monos(bases::Vector{<:MB.MonomialBasis}) = Set([basis.monomials for basis in bases])

"""
    wml19()

Examples of [MWL19].

[WML19] Wang, Jie, Victor Magron, and Jean-Bernard Lasserre. "TSSOS: A Moment-SOS hierarchy that exploits term sparsity." arXiv preprint arXiv:1912.08899 (2019).
"""
function wml19()
    @testset "Example 4.2" begin
        @polyvar x[1:3]
        f = 1 + x[1]^4 + x[2]^4 + x[3]^4 + prod(x) + x[2]
        expected = Set([
            [x[1]^2, x[2]^2, x[3]^2, 1],
            [x[2] * x[3], x[1]],
            [x[2], 1],
            [x[1] * x[3], x[2]],
            [x[1] * x[2], x[3]]
        ])
        for i in 0:2
            @test set_monos(Certificate.sparsity(f, MonomialSparsity(i))) == expected
        end
        expected = Set([
            [x[1]^2, x[1] * x[3], x[2]^2, x[3]^2, x[2], 1],
            [x[1] * x[2], x[2] * x[3], x[1], x[3]]
        ])
        @test set_monos(Certificate.sparsity(f, SignSymmetry())) == expected
    end
    @testset "Example 6.7" begin
        @polyvar x[1:2]
        f = 1 + x[1]^2 * x[2]^4 + x[1]^4 * x[2]^2 + x[1]^4 * x[2]^4 - x[1] * x[2]^2 - 3x[1]^2 * x[2]^2
        for i in 0:2
            @test set_monos(Certificate.sparsity(f, MonomialSparsity(i))) == Set([
                [x[1] * x[2]^2, 1], [x[1]^2 * x[2]^2, 1], [x[1] * x[2]], [x[1]^2 * x[2]]
            ])
        end
        @test set_monos(Certificate.sparsity(f, SignSymmetry())) == Set([
            [x[1]^2 * x[2]^2, x[1] * x[2]^2, 1], [x[1]^2 * x[2], x[1] * x[2]]
        ])
    end
end
"""
    l09()

Examples of [MWL19].

[L09] Lofberg, Johan. "Pre-and post-processing sum-of-squares programs in practice." IEEE transactions on automatic control 54.5 (2009): 1007-1011.
"""
function l09()
    @testset "Example 1 and 2" begin
        @polyvar x[1:2]
        f = 1 + x[1]^4 * x[2]^2 + x[1]^2 * x[2]^4
        @test Certificate.monomials_half_newton_polytope(monomials(f), tuple()) == [
            x[1]^2 * x[2], x[1] * x[2]^2, 1
        ]
        expected = Set([
            [x[1]^2 * x[2]], [x[1] * x[2]^2], [1]
        ])
        for i in 0:2
            @test set_monos(Certificate.sparsity(f, MonomialSparsity(i))) == expected
        end
        @test set_monos(Certificate.sparsity(f, SignSymmetry())) == expected
    end
    @testset "Example 3 and 4" begin
        @polyvar x[1:3]
        f = 1 + x[1]^4 + x[1] * x[2] + x[2]^4 + x[3]^2
        for i in 0:2
            @test set_monos(Certificate.sparsity(f, MonomialSparsity(i))) == Set([
                [x[1], x[2]], [x[3]], [x[1]^2, x[2]^2, 1], [x[1] * x[2], 1]
            ])
        end
        @test set_monos(Certificate.sparsity(f, SignSymmetry())) == Set([
            [x[1], x[2]], [x[3]], [x[1]^2, x[1] * x[2], x[2]^2, 1]
        ])
    end
end
function sum_square(n)
    @polyvar x[1:(2n)]
    f = sum((x[1:2:(2n-1)] .- x[2:2:(2n)]).^2)
    expected = Set([monovec([x[(2i - 1)], x[2i], 1]) for i in 1:n])
    @test set_monos(Certificate.sparsity(f, VariableSparsity(), MB.MonomialBasis, 2)) == expected
    expected = Set([[x[(2i - 1)], x[2i]] for i in 1:n])
    @test set_monos(Certificate.sparsity(f, SignSymmetry())) == expected
end
@testset "Sparsity" begin
    xor_complement_test()
    wml19()
    l09()
    sum_square(8)
end