module Tests

@doc raw"""
# Exponential Growth

"""
module ExponentialGrowth

    using ...GeometricEquations

    using Parameters

    export odeproblem

    const x₀ = [1.0]
    const Δt = 0.1
    const tbeg = 0.0
    const tend = 10.0

    const k = 1.0

    const default_parameters = (k=k,)
    
    function vectorfield(v, t, x, params)
        @unpack k = params
        v[1] = k * x[1]
        nothing
    end

    function solution(x₁, t₁, x₀, t₀, params)
        @unpack k = params
        x₁[1] = x₀[1] * exp(k*t₁)
        return x₁
    end

    function odeproblem(x₀ = x₀; parameters = default_parameters, tbegin = tbeg, tend = tend, Δt = Δt)
        ODEProblem(vectorfield, (tbegin, tend), Δt, x₀; parameters = parameters)
    end

end


@doc raw"""
# Harmonic Oscillator

"""
module HarmonicOscillator

    using ...GeometricEquations

    using Parameters

    export odeproblem, iodeproblem, podeproblem, hodeproblem, sodeproblem,
           daeproblem, idaeproblem, pdaeproblem, hdaeproblem

    export hamiltonian, lagrangian


    const Δt = 0.1
    const tbeg = 0.0
    const tend = 1.0
    const tspan = (tbeg, tend)

    const k = 0.5
    const ω = √k

    const default_parameters = (k=k, ω=ω)
    
    ϑ₁(t,q) = q[2]
    ϑ₂(t,q) = zero(eltype(q))

    function ϑ(q)
        p = zero(q)
        p[1] = ϑ₁(0,q)
        p[2] = ϑ₂(0,q)
        return p
    end

    function hamiltonian(t, q, params)
        @unpack k = params
        q[2]^2 / 2 + k * q[1]^2 / 2
    end

    function hamiltonian(t, q, p, params)
        @unpack k = params
        p[1]^2 / 2 + k * q[1]^2 / 2
    end

    function lagrangian(t, q, v, params)
        ϑ₁(t,q) * v[1] + ϑ₂(t,q) * v[2] - hamiltonian(t, q, params)
    end


    const q₀ = [0.5, 0.0]
    const z₀ = [0.5, 0.0, 0.5]
    const p₀ = ϑ(q₀)

    const A = sqrt(q₀[2]^2 / k + q₀[1]^2)
    const ϕ = asin(q₀[1] / A)

    const reference_solution_q = A * sin(ω * tend + ϕ)
    const reference_solution_p = ω * A * cos(ω * tend + ϕ)

    const reference_solution = [reference_solution_q, reference_solution_p]
    

    function oscillator_ode_v(v, t, x, params)
        @unpack k = params
        v[1] = x[2]
        v[2] = -k*x[1]
        nothing
    end

    function odeproblem(x₀=q₀; parameters = default_parameters, tspan = tspan, tstep = Δt)
        # @assert size(x₀,1) == 2
        # ODE(oscillator_ode_v, x₀; invariants=(h=hamiltonian,), parameters=params)
        ODEProblem(oscillator_ode_v, tspan, tstep, x₀; invariants = (h=hamiltonian,), parameters = parameters)
    end


    function oscillator_pode_v(v, t, q, p, params)
        v[1] = p[1]
        nothing
    end

    function oscillator_pode_f(f, t, q, p, params)
        @unpack k = params
        f[1] = -k*q[1]
        nothing
    end

    function podeproblem(q₀=[q₀[1]], p₀=[p₀[1]]; parameters = default_parameters, tspan = tspan, tstep = Δt)
        # @assert length(q₀) == length(p₀)
        # @assert all([length(q) == length(p) == 1 for (q,p) in zip(q₀,p₀)])
        # @assert size(q₀,1) == size(p₀,1) == 1
        PODEProblem(oscillator_pode_v, oscillator_pode_f, tspan, tstep, q₀, p₀; invariants = (h=hamiltonian,), parameters = parameters)
    end


    function hodeproblem(q₀=[q₀[1]], p₀=[p₀[1]]; parameters = default_parameters, tspan = tspan, tstep = Δt)
        # @assert length(q₀) == length(p₀)
        # @assert all([length(q) == length(p) == 1 for (q,p) in zip(q₀,p₀)])
        # @assert size(q₀,1) == size(p₀,1) == 1
        HODEProblem(oscillator_pode_v, oscillator_pode_f, hamiltonian, tspan, tstep, q₀, p₀; parameters = parameters)
    end


    function oscillator_sode_v_1(v, t, q, params)
        v[1] = q[2]
        v[2] = 0
        nothing
    end

    function oscillator_sode_v_2(v, t, q, params)
        @unpack k = params
        v[1] = 0
        v[2] = -k*q[1]
        nothing
    end

    function oscillator_sode_q_1(q₁, t₁, q₀, t₀, params)
        q₁[1] = q₀[1] + (t₁ - t₀) * q₀[2]
        q₁[2] = q₀[2]
        nothing
    end

    function oscillator_sode_q_2(q₁, t₁, q₀, t₀, params)
        @unpack k = params
        q₁[1] = q₀[1]
        q₁[2] = q₀[2] - (t₁ - t₀) * k * q₀[1]
        nothing
    end

    function sodeproblem(q₀=q₀; parameters = default_parameters, tspan = tspan, tstep = Δt)
        SODEProblem((oscillator_sode_v_1, oscillator_sode_v_2),
                    (oscillator_sode_q_1, oscillator_sode_q_2),
                    tspan, tstep, q₀; parameters = parameters)
    end


    function oscillator_iode_ϑ(p, t, q, params)
        p[1] = q[2]
        p[2] = 0
        nothing
    end

    function oscillator_iode_ϑ(p, t, q, v, params)
        oscillator_iode_ϑ(t, q, p, params)
    end

    function oscillator_iode_f(f, t, q, v, params)
        @unpack k = params
        f[1] = -k*q[1]
        f[2] = v[1] - q[2]
        nothing
    end

    function oscillator_iode_g(g, t, q, v, λ, params)
        g[1] = 0
        g[2] = λ[1]
        nothing
    end

    function oscillator_iode_v(v, t, q, params)
        @unpack k = params
        v[1] = q[2]
        v[2] = -k*q[1]
        nothing
    end

    function iodeproblem(q₀=q₀, p₀=ϑ(q₀); parameters = default_parameters, tspan = tspan, tstep = Δt)
        # @assert size(q₀,1) == size(p₀,1) == 2
        IODEProblem(oscillator_iode_ϑ, oscillator_iode_f,
             oscillator_iode_g, tspan, tstep, q₀, p₀;
             invariants = (h=hamiltonian,), parameters = parameters,
             v̄ = oscillator_iode_v)
    end


    function oscillator_dae_v(v, t, z, params)
        @unpack k = params
        v[1] = z[2]
        v[2] = -k*z[1]
        v[3] = z[2] - k*z[1]
        nothing
    end

    function oscillator_dae_u(u, t, z, λ, params)
        u[1] = -λ[1]
        u[2] = -λ[1]
        u[3] = +λ[1]
    end

    function oscillator_dae_ϕ(ϕ, t, z, params)
        ϕ[1] = z[3] - z[1] - z[2]
    end

    function daeproblem(z₀=z₀, λ₀=[zero(eltype(z₀))]; parameters = default_parameters, tspan = tspan, tstep = Δt)
        # @assert size(z₀,1) == 3
        # @assert size(λ₀,1) == 1
        # @assert all([length(z) == 3 for z in z₀])
        # @assert all([length(λ) == 1 for λ in λ₀])
        # DAE(oscillator_dae_v, oscillator_dae_u, oscillator_dae_ϕ,
        #     z₀, λ₀; invariants=(h=hamiltonian,), parameters=params, v̄=oscillator_ode_v)
        DAEProblem(oscillator_ode_v, oscillator_dae_u, oscillator_dae_ϕ, tspan, tstep, z₀, λ₀;
                    v̄ = oscillator_ode_v, invariants = (h=hamiltonian,), parameters = parameters)
    end


    function oscillator_pdae_u(u, t, q, p, λ, params)
        u[1] = λ[1]
        u[2] = λ[2]
        nothing
    end

    function oscillator_pdae_g(g, t, q, p, λ, params)
        g[1] = 0
        g[2] = λ[1]
        nothing
    end

    function oscillator_pdae_ū(u, t, q, p, λ, params)
        u[1] = λ[1]
        u[2] = λ[2]
        nothing
    end

    function oscillator_pdae_ḡ(g, t, q, p, λ, params)
        g[1] = 0
        g[2] = λ[1]
        nothing
    end

    function oscillator_pdae_ϕ(ϕ, t, q, p, params)
        ϕ[1] = p[1] - q[2]
        ϕ[2] = p[2]
        nothing
    end

    function oscillator_pdae_ψ(ψ, t, q, p, q̇, ṗ, params)
        ψ[1] = f[1] - q̇[2]
        ψ[2] = f[2]
        nothing
    end

    oscillator_idae_u(u, t, q, v, p, λ, params) = oscillator_pdae_u(u, t, q, p, λ, params)
    oscillator_idae_g(g, t, q, v, p, λ, params) = oscillator_pdae_g(g, t, q, p, λ, params)
    oscillator_idae_ū(u, t, q, v, p, λ, params) = oscillator_pdae_ū(u, t, q, p, λ, params)
    oscillator_idae_ḡ(g, t, q, v, p, λ, params) = oscillator_pdae_ḡ(g, t, q, p, λ, params)
    oscillator_idae_ϕ(ϕ, t, q, v, p, params) = oscillator_pdae_ϕ(ϕ, t, q, p, params)
    oscillator_idae_ψ(ψ, t, q, v, p, q̇, ṗ, params) = oscillator_pdae_ψ(ψ, t, q, p, q̇, ṗ, params)


    function idaeproblem(q₀=q₀, p₀=ϑ(q₀), λ₀=zero(q₀); parameters = default_parameters, tspan = tspan, tstep = Δt)
        # @assert size(q₀,1) == size(p₀,1) == size(λ₀,1) == 2
        IDAEProblem(oscillator_iode_ϑ, oscillator_iode_f,
                    oscillator_idae_u, oscillator_idae_g, oscillator_idae_ϕ,
                    tspan, tstep, q₀, p₀, λ₀; v̄ = oscillator_iode_v, invariants = (h=hamiltonian,), parameters = parameters)
    end

    function oscillator_pdae_v(v, t, q, p, params)
        @unpack k = params
        v[1] = q[2]
        v[2] = -k*q[1]
        nothing
    end

    function oscillator_pdae_f(f, t, q, p, params)
        @unpack k = params
        f[1] = -k*q[1]
        f[2] = p[1] - q[2]
        nothing
    end

    function pdaeproblem(q₀=q₀, p₀=ϑ(q₀), λ₀=zero(q₀); parameters = default_parameters, tspan = tspan, tstep = Δt)
        # @assert size(q₀,1) == size(p₀,1) == 2
        PDAEProblem(oscillator_pdae_v, oscillator_pdae_f,
                    oscillator_pdae_u, oscillator_pdae_g, oscillator_pdae_ϕ,
                    tspan, tstep, q₀, p₀, λ₀; invariants=(h=hamiltonian,), parameters = parameters)
    end

    function hdaeproblem(q₀=q₀, p₀=ϑ(q₀), λ₀=zero(q₀); parameters = default_parameters, tspan = tspan, tstep = Δt)
        # @assert size(q₀,1) == size(p₀,1) == 2
        HDAEProblem(oscillator_pdae_v, oscillator_pdae_f, 
                    oscillator_pdae_u, oscillator_pdae_g, oscillator_pdae_ϕ,
                    oscillator_pdae_ū, oscillator_pdae_ḡ, oscillator_pdae_ψ,
                    hamiltonian, tspan, tstep, q₀, p₀, λ₀; parameters = parameters)
    end

end

end
