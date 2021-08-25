module GeometricEquations

    using GeometricBase

    export NullInvariants, NullParameters

    export OptionalAbstractArray, OptionalArray,
           OptionalFunction, OptionalNamedTuple,
           OptionalInvariants, OptionalParameters
    
    export State, StateVector
    
    export GeometricEquation
    export AbstractEquationODE, AbstractEquationPODE,
           AbstractEquationDAE, AbstractEquationPDAE,
           AbstractEquationSDE, AbstractEquationPSDE

    export ODE, IODE, PODE, HODE, LODE, SODE
    export DAE, IDAE, PDAE, HDAE, LDAE, SPDAE
    export SDE, PSDE, SPSDE

    export nsamples, nconstraints
    export initial_conditions, periodicity
    export get_functions, get_solutions, get_invariants
    export hassolution, hasvectorfield, hassecondary,
           hasinvariants, hasparameters, hasperiodicity
           
    
    include("utils.jl")

    include("geometric_equation.jl")

    include("ode.jl")
    include("hode.jl")
    include("iode.jl")
    include("lode.jl")
    include("pode.jl")

    include("dae.jl")
    include("hdae.jl")
    include("idae.jl")
    include("ldae.jl")
    include("pdae.jl")

    include("sode.jl")
    include("spdae.jl")

    include("sde.jl")
    include("psde.jl")
    include("spsde.jl")

    include("conversion.jl")

end
