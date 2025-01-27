using GeometricEquations
using Test

include("functions.jl")
include("initial_conditions.jl")


@testset "$(rpad("Geometric Ensemble",80))" begin

    ics = [(q=x₀,), (q=rand(length(x₀)),)]
    
    @test_nowarn EnsembleProblem(ODE(ode_v), (t₀,t₁), Δt, ics)
    @test_nowarn EnsembleProblem(ODE(ode_v), (t₀,t₁), Δt, ics, nothing)
    @test_nowarn EnsembleProblem(ODE(ode_v), (t₀,t₁), Δt, ics, NullParameters())
    @test_nowarn EnsembleProblem(ODE(ode_v), (t₀,t₁), Δt, ics; parameters=NullParameters())


    ode = ODE(ode_v, parameters = ode_param_types)
    ics = [(q=x₀,), (q=rand(length(x₀)),)]
    params = ode_params
    
    @test_nowarn EnsembleProblem(ode, (t₀,t₁), Δt, ics, params)
    @test_nowarn EnsembleProblem(ode, (t₀,t₁), Δt, ics; parameters=params)

    ens = EnsembleProblem(ode, (t₀,t₁), Δt, ics, params)

    @test typeof(ens) <: EnsembleProblem
    @test typeof(ens) <: ODEEnsemble
    @test typeof(ens).parameters[1] == ODE
    @test typeof(ens).parameters[5] == typeof(ode)

    @test datatype(ens) == eltype(x₀)
    @test timetype(ens) == typeof(t₀)
    @test arrtype(ens) == typeof(x₀)
    @test equtype(ens) == ODE

    @test tspan(ens) == (t₀,t₁)
    @test tbegin(ens) == t₀
    @test tend(ens) == t₁
    @test tstep(ens) == Δt

    @test equation(ens) == ode
    @test functions(ens) == functions(ode)
    @test solutions(ens) == solutions(ode)
    @test parameters(ens) == [params, params]
    @test initial_conditions(ens) == ics
    @test nsamples(ens) == length(ens) == 2

    probs = (
        EquationProblem(ode, (t₀,t₁), Δt, ics[1], params),
        EquationProblem(ode, (t₀,t₁), Δt, ics[2], params),
    )

    for prob in ens
        @test prob ∈ probs
    end


    ode = ODE(ode_v, parameters = ode_param_types)
    ics = (q=x₀,)
    params = [(α=1,), (α=2,)]

    @test_nowarn EnsembleProblem(ode, (t₀,t₁), Δt, ics, params)
    @test_nowarn EnsembleProblem(ode, (t₀,t₁), Δt, ics; parameters=params)

    ens = EnsembleProblem(ode, (t₀,t₁), Δt, ics, params)

    @test equation(ens) == ode
    @test functions(ens) == functions(ode)
    @test solutions(ens) == solutions(ode)
    @test parameters(ens) == params

    @test initial_conditions(ens) == [ics, ics]
    @test nsamples(ens) == length(ens) == 2

    probs = (
        EquationProblem(ode, (t₀,t₁), Δt, ics, params[1]),
        EquationProblem(ode, (t₀,t₁), Δt, ics, params[2]),
    )

    for prob in ens
        @test prob ∈ probs
    end


    ode = ODE(ode_v, parameters = ode_param_types)
    ics = [(q=x₀,), (q=rand(length(x₀)),)]
    params = [(α=1,), (α=2,)]

    @test_nowarn EnsembleProblem(ode, (t₀,t₁), Δt, ics, params)
    @test_nowarn EnsembleProblem(ode, (t₀,t₁), Δt, ics; parameters=params)

    ens = EnsembleProblem(ode, (t₀,t₁), Δt, ics, params)

    @test equation(ens) == ode
    @test functions(ens) == functions(ode)
    @test solutions(ens) == solutions(ode)
    @test parameters(ens) == params

    @test initial_conditions(ens) == ics
    @test nsamples(ens) == length(ens) == 2

    probs = (
        EquationProblem(ode, (t₀,t₁), Δt, ics[1], params[1]),
        EquationProblem(ode, (t₀,t₁), Δt, ics[2], params[2]),
    )

    for prob in ens
        @test prob ∈ probs
    end


    _copy(x, n) = [x for _ in 1:n]

    @test_nowarn ODEEnsemble(ode_eqs..., (t₀,t₁), Δt, _copy(ode_ics, 3))
    @test_nowarn ODEEnsemble(ode_eqs..., (t₀,t₁), Δt, _copy(ode_ics, 3); parameters = _copy((α=1,), 3))

    @test_nowarn SODEEnsemble(sode_eqs, (t₀,t₁), Δt, _copy(ode_ics, 3))
    @test_nowarn SODEEnsemble(sode_eqs, (t₀,t₁), Δt, _copy(ode_ics, 3); parameters = _copy((α=1,), 3))
    @test_nowarn SODEEnsemble(sode_eqs, sode_sols, (t₀,t₁), Δt, _copy(ode_ics, 3))
    @test_nowarn SODEEnsemble(sode_eqs, sode_sols, (t₀,t₁), Δt, _copy(ode_ics, 3); parameters = _copy((α=1,), 3))

    @test_nowarn PODEEnsemble(pode_eqs..., (t₀,t₁), Δt, _copy(pode_ics, 3))
    @test_nowarn PODEEnsemble(pode_eqs..., (t₀,t₁), Δt, _copy(pode_ics, 3); parameters = _copy((α=1,), 3))

    @test_nowarn IODEEnsemble(iode_eqs..., (t₀,t₁), Δt, _copy(iode_ics, 3))
    @test_nowarn IODEEnsemble(iode_eqs..., (t₀,t₁), Δt, _copy(iode_ics, 3); parameters = _copy((α=1,), 3))

    @test_nowarn HODEEnsemble(hode_eqs..., (t₀,t₁), Δt, _copy(hode_ics, 3))
    @test_nowarn HODEEnsemble(hode_eqs..., (t₀,t₁), Δt, _copy(hode_ics, 3); parameters = _copy((α=1,), 3))

    @test_nowarn LODEEnsemble(lode_eqs..., (t₀,t₁), Δt, _copy(lode_ics, 3))
    @test_nowarn LODEEnsemble(lode_eqs..., (t₀,t₁), Δt, _copy(lode_ics, 3); parameters = _copy((α=1,), 3))


    @test_nowarn DAEEnsemble(dae_eqs..., (t₀,t₁), Δt, _copy(dae_ics, 3))
    @test_nowarn DAEEnsemble(dae_eqs..., (t₀,t₁), Δt, _copy(dae_ics, 3); parameters = _copy((α=1,), 3))
    @test_nowarn DAEEnsemble(dae_eqs_full..., (t₀,t₁), Δt, _copy(dae_ics_full, 3))
    @test_nowarn DAEEnsemble(dae_eqs_full..., (t₀,t₁), Δt, _copy(dae_ics_full, 3); parameters = _copy((α=1,), 3))

    @test_nowarn PDAEEnsemble(pdae_eqs..., (t₀,t₁), Δt, _copy(pdae_ics, 3))
    @test_nowarn PDAEEnsemble(pdae_eqs..., (t₀,t₁), Δt, _copy(pdae_ics, 3); parameters = _copy((α=1,), 3))
    @test_nowarn PDAEEnsemble(pdae_eqs_full..., (t₀,t₁), Δt, _copy(pdae_ics_full, 3))
    @test_nowarn PDAEEnsemble(pdae_eqs_full..., (t₀,t₁), Δt, _copy(pdae_ics_full, 3); parameters = _copy((α=1,), 3))

    @test_nowarn IDAEEnsemble(idae_eqs..., (t₀,t₁), Δt, _copy(idae_ics, 3))
    @test_nowarn IDAEEnsemble(idae_eqs..., (t₀,t₁), Δt, _copy(idae_ics, 3); parameters = _copy((α=1,), 3))
    @test_nowarn IDAEEnsemble(idae_eqs_full..., (t₀,t₁), Δt, _copy(idae_ics_full, 3))
    @test_nowarn IDAEEnsemble(idae_eqs_full..., (t₀,t₁), Δt, _copy(idae_ics_full, 3); parameters = _copy((α=1,), 3))

    @test_nowarn HDAEEnsemble(hdae_eqs..., (t₀,t₁), Δt, _copy(hdae_ics, 3))
    @test_nowarn HDAEEnsemble(hdae_eqs..., (t₀,t₁), Δt, _copy(hdae_ics, 3); parameters = _copy((α=1,), 3))
    @test_nowarn HDAEEnsemble(hdae_eqs_full..., (t₀,t₁), Δt, _copy(hdae_ics_full, 3))
    @test_nowarn HDAEEnsemble(hdae_eqs_full..., (t₀,t₁), Δt, _copy(hdae_ics_full, 3); parameters = _copy((α=1,), 3))

    @test_nowarn LDAEEnsemble(ldae_eqs..., (t₀,t₁), Δt, _copy(ldae_ics, 3))
    @test_nowarn LDAEEnsemble(ldae_eqs..., (t₀,t₁), Δt, _copy(ldae_ics, 3); parameters = _copy((α=1,), 3))
    @test_nowarn LDAEEnsemble(ldae_eqs_full..., (t₀,t₁), Δt, _copy(ldae_ics_full, 3))
    @test_nowarn LDAEEnsemble(ldae_eqs_full..., (t₀,t₁), Δt, _copy(ldae_ics_full, 3); parameters = _copy((α=1,), 3))

end
